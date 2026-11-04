local _, FM = ...
local B = {handles={}, sortButtons={}, watched={}, hooks={}, status="Sort runs only when you click Sort."}
FM.Bags = B
local function public(v) return not (issecretvalue and issecretvalue(v)) end
local function finite(v) return public(v) and type(v)=="number" and v==v and math.abs(v)<1000000 end
local function call(fn,...)
    if type(fn)~="function" then return false end
    local ok,value=pcall(fn,...)
    return ok and public(value),value
end
local function notice(text) B.status=text; if B.label then B.label:SetText(text) end end
function B.Settings()
    local db=FM.API.State(); if not db then return end
    if type(db.bags)~="table" then db.bags={} end
    if type(db.bags.positions)~="table" then db.bags.positions={} end
    if not db.bags.headerControls then
        -- Old Hide tools disabled both our header and the fallback bag mover.
        if db.bags.toolbarHidden==nil then db.bags.toolbarHidden=true end
        db.bags.enabled=true;db.bags.headerControls=1
    end
    if B.unlocked==nil then B.unlocked=not db.bags.locked end
    return db.bags
end
local function key(frame)
    if frame==ContainerFrameCombinedBags then return "combined" end
    local ok,combined=call(frame.IsCombinedBagContainer,frame)
    if ok and combined==true then return "combined" end
    local good,id=call(frame.GetBagID,frame)
    if good and finite(id) and id>=0 and id<=4 and id==math.floor(id) then return "bag:"..id end
end
local function frames()
    -- The combined root owns the entire backpack, including its bag sections.
    -- Visible, not just shown: a replacement bag addon (DaylightUI) keeps the
    -- native bags shown inside a hidden parent, and our UIParent-level Sort
    -- button and header strip must not float where those invisible bags sit.
    local combined=ContainerFrameCombinedBags
    local ok,visible=call(combined and combined.IsVisible,combined)
    if ok and visible==true then return {combined} end
    local manager=ContainerFrameSettingsManager
    local ok,list=call(manager and manager.GetBagsShown,manager)
    local out={}
    if not ok or type(list)~="table" or #list>20 then return out end
    for _,frame in ipairs(list) do
        if public(frame) and type(frame)=="table" and frame.IsVisible and frame:IsVisible() and key(frame) then
            if key(frame)=="combined" then return {frame} end
            out[#out+1]=frame
        end
    end
    return out
end
local function position(frame)
    local x,y=frame:GetCenter()
    local fs,ps=frame:GetEffectiveScale(),UIParent:GetEffectiveScale()
    local w,h=UIParent:GetWidth(),UIParent:GetHeight()
    if not finite(x) or not finite(y) or not finite(fs) or not finite(ps) or fs<=0 or ps<=0 or w<=0 or h<=0 then return end
    return {x=math.max(0,math.min(1,x*fs/(w*ps))),y=math.max(0,math.min(1,y*fs/(h*ps)))}
end
local function place(frame,p)
    if type(p)~="table" or not finite(p.x) or not finite(p.y) or p.x<0 or p.x>1 or p.y<0 or p.y>1 then return end
    local fs,ps=frame:GetEffectiveScale(),UIParent:GetEffectiveScale()
    if not finite(fs) or not finite(ps) or fs<=0 or ps<=0 then return end
    frame:SetClampedToScreen(true)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER",UIParent,"BOTTOMLEFT",p.x*UIParent:GetWidth()*ps/fs,p.y*UIParent:GetHeight()*ps/fs)
end
B.Position, B.Place = position, place
function B.Sort()
    if not FM.API.Ready() or not FM.API.Supported() then notice("Wait for a supported Forever client to finish loading."); return false end
    if FM.InCombat() then notice("Sort after combat. No sort is queued."); return false end
    if B.drag then notice("Finish moving the bag before sorting."); return false end
    local ok,cursor=call(GetCursorInfo)
    if not ok or cursor~=nil then notice("Put down the cursor item before sorting."); return false end
    if B.lastSort and GetTime()-B.lastSort<1 then notice("Wait a moment before sorting again."); return false end
    if not C_Container or type(C_Container.SortBags)~="function" then notice("This client does not expose bag sorting."); return false end
    local total=0
    for bag=0,4 do
        local valid,n=call(C_Container.GetContainerNumSlots,bag)
        if not valid or not finite(n) or n<0 or n>100 or n~=math.floor(n) then notice("Bag information is unavailable. Try again shortly."); return false end
        total=total+n
        for slot=1,n do
            local readable,item=call(C_Container.GetContainerItemInfo,bag,slot)
            if not readable or (item~=nil and (type(item)~="table" or not public(item.isLocked) or item.isLocked~=false)) then
                notice("An item is busy or unreadable. Try Sort again shortly."); return false
            end
        end
    end
    if total==0 then notice("Bags are not ready. Open them and try again."); return false end
    local sorted=call(C_Container.SortBags)
    if not sorted then notice("The client rejected sorting. Check its error message and try again."); return false end
    B.lastSort=GetTime()
    notice("Sort requested. Excluded bags keep their settings.")
    return true
end
function B.Reverse()
    if not FM.API.Ready() or not FM.API.Supported() then notice("Wait for a supported Forever client to finish loading."); return false end
    if FM.InCombat() then notice("Change sort direction after combat."); return false end
    local ok,value=call(C_Container and C_Container.GetSortBagsRightToLeft)
    if not ok or type(value)~="boolean" or not call(C_Container and C_Container.SetSortBagsRightToLeft,not value) then
        notice("Sort direction is unavailable on this client."); return false
    end
    notice(value and "Direction: left to right. Click Sort to apply." or "Direction: right to left. Click Sort to apply.")
    return true
end
function B.StopDrag()
    local drag=B.drag; if not drag then return end
    B.drag=nil
    pcall(drag.frame.StopMovingOrSizing,drag.frame)
    if FM.InCombat() then B.restoreMove=drag; return end
    drag.frame:SetMovable(drag.wasMovable)
    if key(drag.frame)==drag.key then
        local p=position(drag.frame); if p then B.Settings().positions[drag.key]=p end
    end
    B.Refresh()
end
function B.StartDrag(frame)
    if not B.unlocked or B.drag or FM.InCombat() then return end
    local settings=B.Settings(); if not settings or settings.enabled==false then return end
    local identity=key(frame); if not identity then return end
    local visible,allowed=frames(),false
    for _,other in ipairs(visible) do if other==frame then allowed=true end end
    if not allowed then return end
    -- Freeze every visible bag before detaching one from Blizzard's relative stack.
    for _,other in ipairs(visible) do
        local p=position(other)
        if p then settings.positions[key(other)]=p; place(other,p) end
    end
    local _,movable=call(frame.IsMovable,frame)
    B.drag={frame=frame,key=identity,wasMovable=movable==true}
    frame:SetMovable(true); frame:StartMoving()
end
function B.ToggleMove()
    if FM.InCombat() then notice("Move bags after combat."); return end
    B.StopDrag(); B.unlocked=not B.unlocked
    B.Settings().locked=not B.unlocked
    local visible=frames()
    local combined=visible[1] and key(visible[1])=="combined"
    notice(B.unlocked and "Drag the window header. Right-click its header to lock." or "Position saved. Right-click the header to unlock.")
    B.Refresh()
end
function B.Reset()
    if FM.InCombat() then notice("Reset the layout after combat."); return false end
    B.StopDrag(); local s=B.Settings(); if not s then return false end
    s.positions={}; B.unlocked=true;s.locked=false
    if UpdateContainerFrameAnchors then UpdateContainerFrameAnchors() end
    notice("Saved bag positions cleared. Using the game's layout."); B.Refresh(); return true
end
local function text(parent,x,y,width,height,size,value)
    local t=parent:CreateFontString(nil,"OVERLAY","GameFontNormal")
    t:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y);t:SetSize(width,height)
    t:SetTextColor(0.20,0.17,0.12);t:SetJustifyH("LEFT");t:SetJustifyV("TOP")
    t:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",size,"");t:SetText(value);return t
end
local function button(parent,label,x,y,width,action)
    local f=CreateFrame("Button",nil,parent,"BackdropTemplate")
    f:SetSize(width,25);f:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y)
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    f:SetBackdropColor(0.94,0.88,0.72,1);f:SetBackdropBorderColor(0.6,0.45,0.2,1)
    f.caption=text(f,5,5,width-10,18,11,label)
    f:SetScript("OnClick",action);return f
end
local function build()
    if B.toolbar then return end
    local f=CreateFrame("Frame","ForeverMacrosBagTools",UIParent,"BackdropTemplate")
    f:SetSize(300,119);f:SetClampedToScreen(true);f:SetFrameStrata("DIALOG")
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    f:SetBackdropColor(0.97,0.93,0.83,1);f:SetBackdropBorderColor(0.6,0.45,0.2,1)
    text(f,10,7,280,18,13,"Forever bag tools")
    B.sort=button(f,"Sort",10,30,64,B.Sort)
    B.move=button(f,"Move bags",80,30,100,B.ToggleMove)
    B.reset=button(f,"Reset layout",186,30,104,B.Reset)
    B.reverse=button(f,"Reverse sort direction",10,60,178,B.Reverse)
    button(f,"Hide tools",194,60,96,function() B.Command("off") end)
    B.label=text(f,10,91,280,27,10,B.status)
    B.toolbar=f
end
function B.Refresh()
    if B.refreshing or FM.InCombat() then return end
    local s=B.Settings(); if not s or not FM.API.Ready() or not FM.API.Supported() then return end
    B.refreshing=true
    local visible=frames()
    local active={};for _,frame in ipairs(visible) do active[frame]=true end
    for frame,h in pairs(B.handles) do
        if not active[frame] or s.enabled==false then
            h:Hide();if B.sortButtons[frame] then B.sortButtons[frame]:Hide() end
        end
    end
    if s.enabled==false or #visible==0 then
        if B.toolbar then B.toolbar:Hide() end
        B.refreshing=nil;return
    end
    build()
    local anchor=visible[1]
    for _,frame in ipairs(visible) do
        local identity=key(frame)
        if identity=="combined" or identity=="bag:0" then anchor=frame end
        if not B.drag then place(frame,s.positions[identity]) end
        if not B.handles[frame] then
            -- A transparent hit area over the native title, excluding its icon and
            -- close button. Top-level parenting avoids native container clipping.
            local h=CreateFrame("Frame",nil,UIParent)
            h:SetHeight(24)
            h:EnableMouse(true);h:SetFrameStrata("FULLSCREEN_DIALOG")
            h:RegisterForDrag("LeftButton")
            h:SetScript("OnDragStart",function() B.StartDrag(frame) end)
            h:SetScript("OnDragStop",B.StopDrag)
            h:SetScript("OnMouseUp",function(_,mouse)
                B.StopDrag()
                if mouse=="RightButton" then B.ToggleMove() end
            end)
            h:SetScript("OnEnter",function()
                if GameTooltip then
                    GameTooltip:SetOwner(h,"ANCHOR_TOP")
                    GameTooltip:SetText(B.unlocked and "Drag the header to move. Right-click to lock." or "Right-click the header to unlock.")
                    GameTooltip:Show()
                end
            end)
            h:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
            h:Hide(); B.handles[frame]=h
        end
        local h=B.handles[frame]
        local combined=identity=="combined"
        local width=math.max(40,frame:GetWidth()-144)
        local fs,ps=frame:GetEffectiveScale(),UIParent:GetEffectiveScale()
        if finite(fs) and finite(ps) and fs>0 and ps>0 then h:SetScale(fs/ps) end
        h:ClearAllPoints()
        h:SetPoint("TOPLEFT",frame,"TOPLEFT",106,-4)
        h:SetWidth(width)
        h:Show()
        local sort=B.sortButtons[frame]
        if not sort then
            sort=button(UIParent,"Sort",0,0,58,B.Sort)
            sort:SetFrameStrata("FULLSCREEN_DIALOG")
            sort.caption:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",13,"")
            B.sortButtons[frame]=sort
        end
        if finite(fs) and finite(ps) and fs>0 and ps>0 then sort:SetScale(fs/ps) end
        sort:ClearAllPoints();sort:SetPoint("TOPLEFT",frame,"TOPLEFT",42,-4);sort:Show()
    end
    local combined=key(anchor)=="combined"
    B.move.caption:SetText(combined and (B.unlocked and "Lock backpack" or "Move backpack") or (B.unlocked and "Lock bags" or "Move bags"))
    B.toolbar:ClearAllPoints();B.toolbar:SetPoint("TOPRIGHT",anchor,"TOPLEFT",-6,0)
    if s.toolbarHidden then B.toolbar:Hide() else B.toolbar:Show() end
    B.refreshing=nil
end
function B.Setup()
    local candidates={}
    if ContainerFrameCombinedBags then candidates[#candidates+1]=ContainerFrameCombinedBags end
    for i=1,5 do local frame=_G["ContainerFrame"..i];if frame then candidates[#candidates+1]=frame end end
    for _,frame in ipairs(frames()) do candidates[#candidates+1]=frame end
    for _,frame in ipairs(candidates) do
        if not B.watched[frame] and type(frame.HookScript)=="function" then
            frame:HookScript("OnShow",B.Schedule)
            frame:HookScript("OnHide",function()
                if B.drag and B.drag.frame==frame then B.StopDrag() end
                if B.handles[frame] then B.handles[frame]:Hide() end
                if B.sortButtons[frame] then B.sortButtons[frame]:Hide() end
                B.Schedule()
            end)
            B.watched[frame]=true
        end
    end
    for _,name in ipairs({"UpdateContainerFrameAnchors","OpenAllBags","ToggleAllBags","OpenBackpack","OpenBag"}) do
        if not B.hooks[name] and hooksecurefunc and type(_G[name])=="function" then
            hooksecurefunc(name,name=="UpdateContainerFrameAnchors" and B.Refresh or B.Schedule)
            B.hooks[name]=true
        end
    end
end
function B.Schedule()
    if B.pending then return end
    B.pending=true
    C_Timer.After(0.1,function() B.pending=nil;B.Setup();B.Refresh() end)
end
function B.Command(argument)
    if not FM.API.Ready() or not FM.API.Supported() then FM.API.Say("Bag tools support the loaded Forever 1.60.x client only."); return end
    if FM.InCombat() then notice("Open bag tools after combat.");FM.API.Say(B.status);return end
    local s=B.Settings();if not s then return end
    if argument=="status" then
        local visible=frames();local root=ContainerFrameCombinedBags
        FM.API.Say("Bag tools v"..FM.Version.." | combined root: "..(root and "found" or "missing")
            .." | visible: "..#visible.." | dragging enabled: "..tostring(B.unlocked==true)
            .." | layout hook: "..tostring(B.hooks.UpdateContainerFrameAnchors==true))
        return
    elseif argument=="reset" then B.Reset()
    elseif argument=="off" then
        B.StopDrag();s.toolbarHidden=true
        B.Refresh();FM.API.Say("Toolbar hidden. Bag headers still drag. Use /fm bags to show the controls.")
    else
        s.enabled=true;s.toolbarHidden=false;B.Setup()
        if OpenAllBags then OpenAllBags() end
        B.Refresh()
        if argument=="move" and not B.unlocked then B.ToggleMove() end
        if #frames()==0 then FM.API.Say("Open Blizzard's bags to show the tools. Replacement bag addons are not supported.") end
    end
end
local events=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_ENTERING_WORLD","ADDON_LOADED","PLAYER_REGEN_DISABLED","PLAYER_REGEN_ENABLED","BAG_UPDATE_DELAYED","DISPLAY_SIZE_CHANGED","UI_SCALE_CHANGED"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent",function(_,event)
    if event=="PLAYER_REGEN_DISABLED" then
        B.StopDrag()
        if B.toolbar then B.toolbar:Hide() end
        for _,h in pairs(B.handles) do h:Hide() end
        for _,b in pairs(B.sortButtons) do b:Hide() end
        return
    end
    if event=="PLAYER_REGEN_ENABLED" and B.restoreMove then
        B.restoreMove.frame:SetMovable(B.restoreMove.wasMovable);B.restoreMove=nil
    end
    B.Schedule()
end)
