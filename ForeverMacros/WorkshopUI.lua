local _, FM = ...
local W, V = FM.Workshop, {slot=1,page=1,step=1,drafts={},historyIndex=0}
FM.WorkshopUI = V
local text,button,edit,choose
local function refresh() FM.UI.Refresh() end
local function tell(ok,reason)
    FM.Manager.notice=reason or (ok and "Saved." or "No change made.")
    refresh()
end
local function classNow() local _,class=UnitClass("player"); return class end
local function model()
    if not V.drafts[V.slot] then
        local state=W.State()
        local saved=state and (state.drafts[V.slot] or state.slots[V.slot])
        V.drafts[V.slot]=(W.Validate(saved) and W.Copy(saved)) or W.Starter(classNow())
    end
    return V.drafts[V.slot]
end
local function loadDraft(m,source)
    V.drafts[V.slot]=W.Copy(m); V.step=1
    FM.Manager.notice=(source or "Draft loaded")..". Review it, then install to change the active macro."
    refresh()
end
local function cycle(values,current)
    local index=0; for i,value in ipairs(values) do if value==current then index=i end end
    return values[index%#values+1]
end
local function multiline(parent,x,y,width,height)
    local scroll=CreateFrame("ScrollFrame",nil,parent,"UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y); scroll:SetSize(width,height)
    local box=CreateFrame("EditBox",nil,scroll)
    box:SetMultiLine(true); box:SetAutoFocus(false); box:SetFontObject("ChatFontNormal")
    box:SetTextColor(0.20,0.17,0.12); box:SetWidth(width-8); box:SetMaxLetters(6144)
    box:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    scroll:SetScrollChild(box)
    return box,scroll
end
function V.Share(value,mode)
    if not V.dialog then
        local f=CreateFrame("Frame","ForeverMacrosShare",FM.UI.frame,"BackdropTemplate")
        V.dialog=f; f:SetPoint("CENTER"); f:SetSize(850,430); f:SetFrameStrata("FULLSCREEN_DIALOG")
        f:EnableMouse(true); f:SetClampedToScreen(true)
        f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=2})
        f:SetBackdropColor(0.98,0.95,0.87,1); f:SetBackdropBorderColor(0.55,0.41,0.22,1)
        V.shareTitle=text(f,22,18,790,28,18)
        V.shareHint=text(f,22,56,790,48,12)
        V.shareBox,V.shareScroll=multiline(f,26,118,770,220)
        V.shareMessage=text(f,22,342,790,40,12)
        V.shareImport=button(f,"Import to preview",22,392,180,function()
            if V.shareMode=="sequence" then
                local m,reason=W.Import(V.shareBox:GetText())
                if m then loadDraft(m,"Imported draft"); f:Hide() else V.shareMessage:SetText(reason) end
            elseif V.shareMode=="profile" then
                local p,reason=W.ImportProfile(V.shareBox:GetText())
                if p then V.profile=p; V.profileName="Imported build"; V.plan=nil; FM.UI.tab="Builds"; refresh(); f:Hide()
                else V.shareMessage:SetText(reason) end
            end
        end)
        button(f,"Select all",610,392,100,function() V.shareBox:SetFocus(); V.shareBox:HighlightText() end)
        button(f,"Close",726,392,100,function() f:Hide() end)
        table.insert(UISpecialFrames,"ForeverMacrosShare")
    end
    V.shareMode=mode
    V.shareTitle:SetText(mode=="sequence" and "Share or import a sequence" or mode=="profile" and "Share or import a sequence build" or "Copy text")
    V.shareHint:SetText(mode and "Copy with Ctrl+C. Paste matching ForeverMacros share text with Ctrl+V. Import opens a preview; installing is a separate action."
        or "Copy this text with Ctrl+C. Raw macro text can be edited in /macro or another macro editor. This is not a GSE encoded import.")
    V.shareMessage:SetText(""); V.shareBox:SetText(value or ""); V.shareScroll:SetVerticalScroll(0)
    if mode then V.shareImport:Show() else V.shareImport:Hide() end
    V.dialog:Show(); V.shareBox:SetFocus(); V.shareBox:HighlightText()
end
function V.Build(helpers)
    text,button,edit,choose=helpers.text,helpers.button,helpers.edit,helpers.choose
    local p=FM.UI.panels.Sequences
    text(p,20,0,290,26,17):SetText("Class spell picker")
    V.search=edit(p,26,34,284); V.search:SetMaxLetters(60)
    V.search:SetScript("OnTextChanged",function(self) V.query=self:GetText(); V.page=1; refresh() end)
    V.spells={}
    for i=1,11 do
        V.spells[i]=button(p,"",20,73+(i-1)*31,290,function(self)
            local m=model(); if not m or not self.spell then return end
            if #m.steps>=(m.mode=="modifier" and 3 or 8) then tell(nil,"Remove a step before adding another."); return end
            m.steps[#m.steps+1]=self.spell.key; V.step=#m.steps; refresh()
        end)
    end
    button(p,"Previous spells",20,422,128,function() V.page=math.max(1,V.page-1); refresh() end)
    button(p,"Next spells",182,422,128,function() V.page=V.page+1; refresh() end)
    V.spellPage=text(p,20,453,290,20,11)
    button(p,"View automatic class sequences",20,478,290,function() FM.TrainingUI.ShowAutomatic() end)

    V.slotButton=button(p,"",330,0,150,function()
        V.slot=V.slot%W.maxSlots+1; V.step=1; V.historyIndex=0; refresh()
    end)
    button(p,"Class starter",490,0,160,function() local m=W.Starter(classNow()); if m then loadDraft(m,"Class starter loaded") end end)
    V.mode=button(p,"",330,34,205,function()
        local m=model(); if not m then return end
        if m.mode=="sequence" and #m.steps>3 then tell(nil,"Remove steps until three remain before switching to modifier mode."); return end
        m.mode=m.mode=="sequence" and "modifier" or "sequence"; refresh()
    end)
    button(p,"Clear draft",543,34,107,function() local m=model(); if m then m.steps={}; V.step=1; refresh() end end)
    V.steps={}
    for i=1,8 do
        local index=i
        V.steps[i]=button(p,"",330,72+(i-1)*28,320,function() V.step=index; refresh() end)
    end
    button(p,"Up",330,303,80,function()
        local m=model(); if m and V.step>1 and m.steps[V.step] then
            m.steps[V.step],m.steps[V.step-1]=m.steps[V.step-1],m.steps[V.step]; V.step=V.step-1; refresh()
        end
    end)
    button(p,"Down",418,303,80,function()
        local m=model(); if m and m.steps[V.step+1] then
            m.steps[V.step],m.steps[V.step+1]=m.steps[V.step+1],m.steps[V.step]; V.step=V.step+1; refresh()
        end
    end)
    button(p,"Remove step",506,303,144,function()
        local m=model(); if m and m.steps[V.step] then table.remove(m.steps,V.step); V.step=math.max(1,math.min(V.step,#m.steps)); refresh() end
    end)
    V.target=button(p,"",330,340,154,function()
        local m=model(); if m then m.target=cycle({"self","enemy","friendly","current"},m.target); refresh() end
    end)
    V.reset=button(p,"",492,340,158,function()
        local m=model(); if m then m.reset=cycle({"alt","target/combat/alt","5/target/alt","10/target/alt","combat/alt"},m.reset); refresh() end
    end)
    V.ooc=button(p,"",330,374,154,function() local m=model(); if m then m.ooc=not m.ooc; refresh() end end)
    V.caster=button(p,"",492,374,158,function() local m=model(); if m then m.caster=not m.caster; refresh() end end)
    V.channel=button(p,"",330,408,320,function() local m=model(); if m then m.channel=not m.channel; refresh() end end)
    button(p,"Save draft",330,446,154,function() tell(W.SaveDraft(V.slot,model())) end)
    V.install=button(p,"Install this draft",492,446,158,function() tell(W.Install(V.slot,model())) end)
    V.slotStatus=text(p,330,478,320,22,11)

    text(p,675,0,300,26,17):SetText("Exact macro preview")
    V.preview=text(p,675,35,300,175,12)
    V.detail=text(p,675,214,300,99,11)
    button(p,"Copy macro",675,317,140,function()
        local body,reason=W.Preview(V.slot,model()); if body then V.Share(body) else tell(nil,reason) end
    end)
    button(p,"Share / import",825,317,150,function() V.Share(W.Export(model()),"sequence") end)
    V.history=button(p,"History: none",675,351,300,function()
        local history=W.History(V.slot)
        if #history==0 then tell(nil,"History starts after the first confirmed update to this slot."); return end
        V.historyIndex=V.historyIndex%#history+1
        loadDraft(history[V.historyIndex],"History revision "..V.historyIndex.." loaded")
    end)
    button(p,"Load installed",675,385,140,function()
        local state=W.State(); local m=state and state.slots[V.slot]
        if W.Validate(m) then loadDraft(m,"Installed definition loaded") else tell(nil,"This slot has no confirmed definition.") end
    end)
    button(p,"Cancel queued",825,385,150,function()
        local id="workshop_"..V.slot; FM.Manager.pending[id]=nil; FM.API.State().wanted[id]=nil
        tell(true,"Queued change cancelled. The active macro is unchanged.")
    end)
    V.starterNote=text(p,675,425,300,74,11)

    p=FM.UI.panels.Builds
    text(p,20,0,280,28,18):SetText("Saved sequence builds")
    V.profileRows={}
    for i=1,12 do
        V.profileRows[i]=button(p,"",20,39+(i-1)*29,285,function(self)
            local profile,reason=W.Profile(self.profileName)
            if profile then V.profile=profile; V.profileName=self.profileName; V.plan=nil; refresh() else tell(nil,reason) end
        end)
    end
    V.profileNameBox=edit(p,26,403,279); V.profileNameBox:SetMaxLetters(24)
    button(p,"Save installed slots as build",20,442,285,function()
        local name=V.profileNameBox:GetText(); local ok,reason=W.SaveProfile(name)
        if ok then V.profile=W.Profile(name); V.profileName=name; V.plan=nil end
        tell(ok,reason or "Saved all installed sequence definitions in this build.")
    end)
    text(p,20,478,290,22,11):SetText("Up to 12 named builds per character.")
    V.buildTitle=text(p,330,0,640,28,18)
    V.buildSummary=text(p,330,40,640,252,12)
    button(p,"Preview listed slots",330,311,200,function()
        local plan,reason=W.Plan(V.profile); V.plan=plan
        tell(plan~=nil,reason or "Preview ready. Apply changes only the listed sequence slots.")
    end)
    V.apply=button(p,"Apply previewed build",545,311,200,function()
        if not V.plan or W.ExportProfile(V.profile)~=V.plan.signature then tell(nil,"Preview the build first."); return end
        local ok,reason=W.ApplyProfile(V.profile,V.plan); V.plan=nil; tell(ok,reason)
    end)
    button(p,"Share / import build",760,311,215,function() V.Share(V.profile and W.ExportProfile(V.profile) or "","profile") end)
    button(p,"Run read-only patch check",330,352,310,function()
        local report,reason=W.Audit(); if report then V.Share(table.concat(report,"\n")) else tell(nil,reason) end
    end)
    button(p,"Remove saved build",660,352,315,function()
        if V.profileName=="Imported build" or not V.profileName then tell(nil,"Choose a saved build first."); return end
        local state=W.State(); if not state then return end
        if V.removeName~=V.profileName then V.removeName=V.profileName; tell(true,"Click Remove saved build again to confirm. Installed macros are unchanged."); return end
        state.profiles[V.profileName]=nil; V.profile=nil; V.profileName=nil; V.plan=nil; V.removeName=nil
        tell(true,"Saved build removed. Installed macros are unchanged.")
    end)
    text(p,330,403,640,95,12):SetText("Builds contain the eight workshop slots. Omitted slots stay as they are. Preview checks learned spells, ownership and available space. API failures stop application and report how many slots completed.\n\nBars, keys, talent builds and other macros stay under your control. Save another build before switching if you want to return to it.")
end

function V.Refresh()
    if FM.UI.tab=="Sequences" then
        local m=model(); local state,stateReason=W.State()
        if not m then V.preview:SetText("Choose a supported class."); V.install:Disable(); return end
        local spells=W.Spells(V.query); V.page=math.max(1,math.min(V.page,math.ceil(#spells/11)))
        for i,b in ipairs(V.spells) do
            local s=spells[(V.page-1)*11+i]; b.spell=s
            if s then b:SetText(s.name..(s.learned and "" or " *")); b:Show() else b:Hide() end
        end
        V.spellPage:SetText("Page "..V.page..". Click to add a step.\n* Not learned. Preview waits for every step.")
        V.slotButton:SetText("Slot "..V.slot.." / 8")
        V.mode:SetText(m.mode=="sequence" and "Mode: cast sequence" or "Mode: modifier choices")
        for i,b in ipairs(V.steps) do
            local key=m.steps[i]; local spec=key and (W.registry[m.class] or {})[key]
            if spec then b:SetText(i..". "..(W.cache[key] or spec.english)); b:Show(); choose(b,V.step==i) else b:Hide() end
        end
        V.target:SetText("Target: "..m.target)
        V.reset:SetText("Reset: "..m.reset:gsub("target","tgt"):gsub("combat","fight"))
        if m.mode=="sequence" then V.reset:Enable() else V.reset:Disable() end
        V.ooc:SetText(m.ooc and "Outside combat only" or "Combat: allowed")
        V.caster:SetText(m.caster and "Caster form only" or "Form: any")
        V.channel:SetText(m.channel and "Protect channels: on" or "Protect channels: off")
        local body,reason=W.Preview(V.slot,m)
        V.preview:SetText(body or reason or stateReason)
        V.detail:SetText((body and (#body.." / 255 bytes\n") or "Cannot install this draft.\n")..
            (m.mode=="sequence" and "One step per successful press. Failed casts hold the step. Alt resets; time resets count inactivity, not a scheduled delay. Keep interrupts and emergency spells separate."
                or "No modifier: step 1. Shift: step 2. Ctrl: step 3. Ctrl wins if both are held. Check that your keybind does not consume these modifiers."))
        if body and state then V.install:Enable() else V.install:Disable() end
        local id="workshop_"..V.slot
        V.slotStatus:SetText(FM.Manager.pending[id] and "Queued. Active macro still unchanged." or
            (FM.API.State().managed[id] and (FM.Manager.Owned(id) and "Installed and owned" or "Personal edit / missing. Preserved.") or "No macro installed in this slot"))
        local history=W.History(V.slot)
        V.history:SetText("History: "..#history.." previous versions (click to load)")
        V.starterNote:SetText((W.starters[m.class] or {}).note or "")
    elseif FM.UI.tab=="Builds" then
        local state,reason=W.State(); local names={}
        if state then for name in pairs(state.profiles) do if type(name)=="string" then names[#names+1]=name end end end
        table.sort(names)
        for i,b in ipairs(V.profileRows) do
            local name=names[i]; b.profileName=name
            if name then b:SetText(name); b:Show(); choose(b,name==V.profileName) else b:Hide() end
        end
        V.buildTitle:SetText(V.profileName or "Choose a build or import one")
        local lines={}
        if V.plan then
            for _,row in ipairs(V.plan.rows) do lines[#lines+1]=row.definition.name..": "..row.status.." ("..#row.body.." bytes)" end
            lines[#lines+1]="\nNew slots needed: "..V.plan.needed
        elseif V.profile then
            for slot=1,8 do
                local m=V.profile.slots[slot]
                if m then lines[#lines+1]="FM Seq"..slot..": "..#m.steps.." steps, "..m.mode..", target "..m.target end
            end
            lines[#lines+1]="\nClick Preview listed slots before applying."
        else lines={reason or "Install sequences, enter a build name, then save. Profiles contain confirmed definitions. Unsaved drafts are separate."} end
        V.buildSummary:SetText(table.concat(lines,"\n"))
        if V.plan and not FM.InCombat() then V.apply:Enable() else V.apply:Disable() end
    end
end
