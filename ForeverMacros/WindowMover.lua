local _, FM = ...
local W = {hooked={},handling={}}
FM.WindowMover = W
local function provider()
    if not LibStub or not BlizzMoveAPI or BlizzMoveAPI:GetVersion()~="v3.8.4" then return end
    local ok,ace=pcall(LibStub,"AceAddon-3.0",true)
    if not ok or not ace then return end
    local good,bm=pcall(ace.GetAddon,ace,"BlizzMove",true)
    if good and bm and bm.initialized and bm.FrameData then return bm end
end
local function settings()
    local db=FM.API.State();if not db then return end
    db.windows=db.windows or {locked={},positions={}}
    db.windows.owners=db.windows.owners or {}
    return db.windows
end
local function bag(name) return name:match("^ContainerFrame")~=nil end
function W.Toggle(root,data)
    if FM.InCombat() or W.handling[root] then return end
    local s=settings();if not s then return end
    W.handling[root]=true
    C_Timer.After(0,function() W.handling[root]=nil end)
    local name,addon=data.storage.frameName,data.storage.addOnName
    local locked=not s.locked[name]
    local p=FM.Bags.Position(root)
    BlizzMoveAPI:SetFrameDisabled(addon,name,locked)
    if locked and p then s.positions[name]=p;FM.Bags.Place(root,p) end
    s.locked[name]=locked or nil
    s.owners[name]=addon
    -- BlizzMove disables frame mouse input along with movement. Keep the existing
    -- title's right-click available so it can be enabled again without a command.
    for frame,entry in pairs(W.hooked) do
        if entry.root==root then frame:EnableMouse(true) end
    end
    W.Refresh()
    FM.API.Say(name..(locked and ": position locked. Right-click the header to unlock." or ": drag its header to move. Right-click to lock."))
end
function W.Refresh()
    if FM.InCombat() or not FM.API.Ready() or not FM.API.Supported() then return end
    local bm=provider();if not bm then return end
    local s=settings()
    if not s.configured then
        s.previous={savePosStrategy=bm.DB.savePosStrategy,requireMoveModifier=bm.DB.requireMoveModifier}
        local old=bm.DB.savePosStrategy
        bm.DB.savePosStrategy="permanent";bm.DB.requireMoveModifier=false
        bm:SavePositionStrategyChanged(old,"permanent")
        s.configured=true
    end
    -- Forever Macros alone owns native bag movement and its saved positions.
    for _,name in ipairs({"ContainerFrameCombinedBags","ContainerFrame1"}) do
        if not BlizzMoveAPI:IsFrameDisabled(nil,name) then BlizzMoveAPI:SetFrameDisabled(nil,name,true) end
    end
    for name in pairs(s.locked) do
        local root=bm:GetFrameFromName(s.owners[name],name)
        if root and not W.hooked[root] then
            BlizzMoveAPI:SetFrameDisabled(s.owners[name],name,false)
            BlizzMoveAPI:SetFrameDisabled(s.owners[name],name,true)
        end
    end
    local targets={}
    for frame,data in pairs(bm.FrameData) do targets[frame]={root=frame,data=data} end
    for handle in pairs(bm.MoveHandles or {}) do
        local parent=handle:GetParent()
        if parent and bm.FrameData[parent] then targets[handle]={root=parent,data=bm.FrameData[parent]} end
    end
    for frame,item in pairs(targets) do
        local root,entry=item.root,item.data
        for _=1,8 do
            local parent=entry.storage and entry.storage.frameParent
            if not parent or not bm.FrameData[parent] then break end
            root,entry=parent,bm.FrameData[parent]
        end
        local storage=entry.storage
        if storage and storage.frameName and not bag(storage.frameName) and not W.hooked[frame]
            and frame.HookScript and (not storage.disabled or s.locked[storage.frameName]) then
            local target,definition=root,entry
            W.hooked[frame]={root=root}
            frame:HookScript("OnMouseUp",function(_,mouse)
                if mouse~="RightButton" or FM.InCombat() or IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown() then return end
                local _,y=GetCursorPosition()
                local scale,top=target:GetEffectiveScale(),target:GetTop()
                if not y or not top or not scale or (issecretvalue and (issecretvalue(y) or issecretvalue(top) or issecretvalue(scale))) then return end
                if type(y)~="number" or type(top)~="number" or type(scale)~="number" or scale<=0 then return end
                if y/scale<=top and y/scale>=top-32 then W.Toggle(target,definition) end
            end)
            frame:HookScript("OnShow",function()
                if not FM.InCombat() and s.locked[storage.frameName] then FM.Bags.Place(target,s.positions[storage.frameName]) end
            end)
            if s.locked[storage.frameName] then frame:EnableMouse(true) end
        end
    end
end
function W.Schedule()
    if W.pending then return end
    W.pending=true
    C_Timer.After(0.2,function() W.pending=nil;W.Refresh() end)
end
local f=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_ENTERING_WORLD","ADDON_LOADED","PLAYER_REGEN_ENABLED"}) do f:RegisterEvent(event) end
f:SetScript("OnEvent",W.Schedule)
