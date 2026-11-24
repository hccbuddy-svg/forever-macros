local _, FM = ...
local U = {page=1, orderPage=1, mode="Talents"}
FM.CoachUI = U
local T, C, D = FM.Advisor, FM.Coach, FM.TalentData
local h
local function chooseClass(class)
    if not D.classes[class] then class=T.classes[1] end
    U.class, U.tree, U.selected, U.page, U.orderPage = class, C.summary[class].tree, nil, 1, 1
end
local function setImage(widget, card)
    widget.icon:SetTexture(card and card.icon or 134400)
    widget.name:SetText(card and card.name or "")
    widget.key:SetText(card and (card.learned and (card.key and "Key: " .. card.key or "No default-bar key found") or "Not learned / preview") or "")
end
local function card(parent,x,y,width)
    local icon=parent:CreateTexture(nil,"ARTWORK"); icon:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y); icon:SetSize(44,44)
    return {icon=icon,name=h.text(parent,x,y+50,width,35,12),key=h.text(parent,x,y+86,width,30,10)}
end
function U.Build(helpers)
    h=helpers
    chooseClass(T.Class())
    local settings=T.Settings(); U.tree=settings.tree or U.tree
    local p=FM.UI.panels.Coach
    U.classes,U.trees,U.rows={},{},{}
    for i,class in ipairs(T.classes) do
        local chosen=class
        U.classes[class]=h.button(p,class:sub(1,1)..class:sub(2):lower(),20+(i-1)*106,0,100,function() chooseClass(chosen); FM.UI.Refresh() end)
    end
    for i=1,3 do
        local tree=i
        U.trees[i]=h.button(p,"",20+(i-1)*180,35,174,function() U.tree=tree; U.selected=nil; U.page=1; U.orderPage=1; FM.UI.Refresh() end)
    end
    U.modes={}
    for i,name in ipairs({"Talents","Combat guide"}) do
        local mode=name
        U.modes[name]=h.button(p,name,700+(i-1)*140,35,135,function() U.mode=mode; FM.UI.Refresh() end)
    end
    U.advice=h.text(p,20,72,955,50,12)
    U.talents=CreateFrame("Frame",nil,p); U.talents:SetPoint("TOPLEFT",p,"TOPLEFT",0,-130); U.talents:SetSize(990,314)
    U.combat=CreateFrame("Frame",nil,p); U.combat:SetPoint("TOPLEFT",p,"TOPLEFT",0,-130); U.combat:SetSize(990,314)
    local a=U.talents
    U.listTitle=h.text(a,20,0,300,20,12)
    for i=1,9 do
        local row=h.button(a,"",20,24+(i-1)*27,310,function(self) U.selected=self.build; U.orderPage=1; FM.UI.Refresh() end)
        U.rows[i]=row
    end
    U.prev=h.button(a,"Previous",20,273,90,function() U.page=math.max(1,U.page-1); FM.UI.Refresh() end)
    U.pageText=h.text(a,122,278,110,18,11)
    U.next=h.button(a,"Next",240,273,90,function() U.page=U.page+1; FM.UI.Refresh() end)
    U.title=h.text(a,350,0,620,25,16)
    U.meta=h.text(a,350,30,620,47,11)
    U.progress=h.text(a,350,80,620,86,12)
    U.points=h.text(a,350,172,620,92,11)
    U.orderPrev=h.button(a,"Earlier points",350,273,122,function() U.orderPage=math.max(1,U.orderPage-1); FM.UI.Refresh() end)
    U.orderNext=h.button(a,"Later points",480,273,122,function() U.orderPage=U.orderPage+1; FM.UI.Refresh() end)
    U.use=h.button(a,"Follow this plan",752,273,217,function()
        if U.selected and T.Select(U.selected) then U.notice="Plan saved for this character. Spend points in the game's talent window."; U.RefreshHUD(); FM.UI.Refresh() end
    end)
    U.combatTitle=h.text(U.combat,25,0,930,28,18)
    U.cards={}
    for i=1,3 do U.cards[i]=card(U.combat,25+(i-1)*310,40,285) end
    h.text(U.combat,25,170,925,75,13):SetText("Fixed ability reference. These cards do not check cooldowns, resources, buffs or targets, and their order is not a cast sequence.\n\nChoose actions from your own combat situation. Key hints are refreshed outside combat; a macro can have additional conditions.")
    U.native=h.text(U.combat,25,254,925,56,11)
    U.hudToggle=h.button(p,"Show reference bar",20,455,177,function()
        local s=T.Settings(); s.hud=not s.hud
        if U.class==T.Class() then s.tree=U.tree end
        U.RefreshHUD(); FM.UI.Refresh()
    end)
    U.bearToggle=h.button(p,"Cat / Bear",207,455,105,function()
        local s=T.Settings(); s.bear=not s.bear; U.RefreshHUD(); FM.UI.Refresh()
    end)
    h.button(p,"Refresh / check API",322,455,170,function()
        T.Snapshot(true); U.compatibility=T.NativeStatus(); U.RefreshHUD(); FM.UI.Refresh()
    end)
    h.button(p,"Copy build link",502,455,150,function() U.Copy(U.selected and U.selected.calculator or C.summary[U.class].url) end)
    h.button(p,"Copy class guide",662,455,154,function() U.Copy(C.summary[U.class].url) end)
    h.button(p,"Lock / move bar",826,455,150,function()
        local s=T.Settings(); s.unlocked=not s.unlocked; U.RefreshHUD(); FM.UI.Refresh()
    end)
    U.footer=h.text(p,20,488,955,20,10)
end
function U.Copy(value)
    if not U.linkWindow then
        local f=CreateFrame("Frame", "ForeverMacrosCoachLink", UIParent,"BackdropTemplate")
        f:SetSize(820,160); f:SetPoint("CENTER"); f:SetFrameStrata("FULLSCREEN_DIALOG")
        f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=2})
        f:SetBackdropColor(0.97,0.93,0.83,1); f:SetBackdropBorderColor(0.6,0.45,0.2,1)
        h.text(f,20,15,780,30,13):SetText("Press Ctrl+C to copy this source link. Open it in your browser.")
        U.linkBox=h.edit(f,25,58,768); U.linkBox:SetMaxLetters(2048)
        h.button(f,"Close",690,111,100,function() f:Hide() end)
        U.linkWindow=f
        UISpecialFrames=UISpecialFrames or {}; table.insert(UISpecialFrames,"ForeverMacrosCoachLink")
    end
    U.linkBox:SetText(value); U.linkWindow:Show(); U.linkBox:SetFocus(); U.linkBox:HighlightText()
end
function U.Refresh()
    if not U.talents then return end
    local s=T.Settings()
    for class,b in pairs(U.classes) do h.choose(b,class==U.class) end
    for i,b in ipairs(U.trees) do b:SetText(D.classes[U.class].trees[i].name); h.choose(b,i==U.tree) end
    for mode,b in pairs(U.modes) do h.choose(b,U.mode==mode) end
    local summary=C.summary[U.class]
    U.advice:SetText(summary.advice .. "\nCommunity's most-planned tree: " .. summary.popular .. ". Popularity is not a speed ranking.")
    U.hudToggle:SetText(s.hud and "Hide reference bar" or "Show reference bar")
    if U.class=="DRUID" and U.tree==2 then U.bearToggle:Enable(); U.bearToggle:SetText(s.bear and "Bear reference" or "Cat reference") else U.bearToggle:Disable() end
    U.footer:SetText(U.notice or "Data: " .. D.date .. ". Talents Forever (CC BY 4.0), ZBuilds and linked guide authors. Beta advice can change. No talents are spent here.")
    if U.mode=="Combat guide" then
        U.talents:Hide(); U.combat:Show()
        U.combatTitle:SetText(U.class .. " / " .. D.classes[U.class].trees[U.tree].name .. " / reference only")
        local cards=C.ReadCards(U.class,U.tree,s.bear)
        if not cards then
            U.combatTitle:SetText("Combat guide preview refreshes after combat. The floating bar keeps its fixed reference.")
            for _,w in ipairs(U.cards) do setImage(w,nil) end
        else for i,w in ipairs(U.cards) do setImage(w,cards[i]) end end
        U.native:SetText(U.compatibility or "Use Refresh / check API to test native Assisted Combat availability. This version does not show live next-spell predictions.")
        return
    end
    U.combat:Hide(); U.talents:Show()
    local builds=T.Builds(U.class,U.tree)
    U.page=math.max(1,math.min(U.page,math.ceil(#builds/9)))
    if not U.selected then
        for _,b in ipairs(builds) do if b.id==s.build then U.selected=b end end
        U.selected=U.selected or builds[1]
    end
    U.listTitle:SetText(#builds .. " plans / choose a source and endpoint")
    U.pageText:SetText(U.page .. " / " .. math.max(1,math.ceil(#builds/9)))
    for i,row in ipairs(U.rows) do
        local b=builds[(U.page-1)*9+i]; row.build=b
        if b then row:SetText(b.source .. " / " .. #b.order .. "pt" .. (b.group=="Group" and " / group" or "")); h.choose(row,U.selected==b); row:Show() else row:Hide() end
    end
    local build=U.selected
    if not build then return end
    U.title:SetText(build.spec .. " / " .. build.category .. " / " .. #build.order .. " points")
    U.meta:SetText(build.source .. " | " .. table.concat(build.points,"/") .. " | " .. (build.estimated and "Estimated order from final ranks" or "Source point order") ..
        "\n" .. (build.beta and "Partial beta plan. " or "Theorycraft. ") .. "Point numbers are not character levels. Legacy points can change timing.")
    local snapshot,reason=T.Snapshot()
    local progress=T.Progress(build,snapshot)
    local lines={snapshot and progress.status or (reason or progress.status)}
    if build.class~=T.Class() then lines={"Another class: static preview only."} end
    for i,step in ipairs(progress.next) do lines[#lines+1]=i .. ". " .. T.TalentName(build.class,step.tree,step.index) .. " rank " .. step.rank .. " (plan point " .. step.ordinal .. ")" end
    U.progress:SetText(table.concat(lines,"\n"))
    U.orderPage=math.max(1,math.min(U.orderPage,math.ceil(#build.order/4)))
    local text, counts={},{{},{},{}}
    for ordinal,step in ipairs(build.order) do
        local t,i=step[1],step[2]; counts[t][i]=(counts[t][i] or 0)+1
        if ordinal>(U.orderPage-1)*4 and ordinal<=U.orderPage*4 then
            text[#text+1]="Point " .. ordinal .. ": " .. T.TalentName(build.class,t,i) .. " " .. counts[t][i] .. "/" .. D.classes[build.class].trees[t].talents[i].max
        end
    end
    U.points:SetText(table.concat(text,"\n"))
    if U.class==T.Class() then U.use:Enable() else U.use:Disable() end
    U.use:SetText(s.build==build.id and "Following this plan" or "Follow this plan")
end
function U.RefreshHUD()
    local s=T.Settings()
    if not s or not s.hud or not FM.API.Supported() then if U.hud then U.hud:Hide() end; return end
    if FM.InCombat() and not U.hud then return end
    if not h then FM.UI.Build() end
    if not U.hud then
        if FM.InCombat() then return end
        local f=CreateFrame("Frame","ForeverMacrosReferenceBar",UIParent,"BackdropTemplate")
        f:SetSize(550,159); f:SetPoint("CENTER",UIParent,"CENTER",0,-170); f:SetFrameStrata("MEDIUM")
        f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
        f:SetBackdropColor(0.97,0.93,0.83,0.96); f:SetBackdropBorderColor(0.60,0.45,0.20,1)
        f:SetClampedToScreen(true); f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart",function(self) if T.Settings().unlocked and not FM.InCombat() then self:StartMoving() end end)
        f:SetScript("OnDragStop",function(self)
            self:StopMovingOrSizing()
            local point,_,relative,x,y=self:GetPoint()
            T.Settings().position={point=point,relative=relative,x=x,y=y}
        end)
        local pos=s.position
        local anchors={CENTER=true,TOP=true,BOTTOM=true,LEFT=true,RIGHT=true,TOPLEFT=true,TOPRIGHT=true,BOTTOMLEFT=true,BOTTOMRIGHT=true}
        if type(pos)=="table" and anchors[pos.point] and anchors[pos.relative] and type(pos.x)=="number" and type(pos.y)=="number"
            and pos.x==pos.x and pos.y==pos.y and math.abs(pos.x)<10000 and math.abs(pos.y)<10000 then
            f:ClearAllPoints(); f:SetPoint(pos.point,UIParent,pos.relative,pos.x,pos.y)
        end
        U.hud=f; U.hudTitle=h.text(f,12,8,530,22,11); U.hudCards={}
        for i=1,3 do U.hudCards[i]=card(f,12+(i-1)*179,36,167) end
    end
    local class,tree=T.Class(),C.Tree()
    local cards=C.ReadCards(class,tree,s.bear)
    if cards then
        U.hudTitle:SetText(D.classes[class].trees[tree].name .. " / fixed reference / " .. (s.unlocked and "drag to move" or "locked"))
        for i,w in ipairs(U.hudCards) do setImage(w,cards[i]) end
    end
    U.hud:Show()
end
