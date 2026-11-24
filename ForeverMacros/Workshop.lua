local _, FM = ...
local W = {registry = {}, cache = {}, maxSlots = 8, maxProfiles = 12, maxHistory = 10}
FM.Workshop = W
local classes = {WARRIOR=true, PALADIN=true, HUNTER=true, ROGUE=true, PRIEST=true, SHAMAN=true, MAGE=true, WARLOCK=true, DRUID=true}
local targets = {self="@player", enemy="harm,nodead", friendly="help,nodead", current=""}
local resets = {alt=true, ["target/combat/alt"]=true, ["5/target/alt"]=true, ["10/target/alt"]=true, ["combat/alt"]=true}
local fields = {class=true, steps=true, mode=true, target=true, reset=true, ooc=true, caster=true, channel=true}
local function classNow() local _, class = UnitClass("player"); return class end
local function slotOK(slot) return type(slot)=="number" and slot>=1 and slot<=W.maxSlots and slot==math.floor(slot) end
local function copyModel(model)
    if type(model) ~= "table" then return nil end
    local out = {}
    for key in pairs(fields) do if key~="steps" then out[key]=model[key] end end
    out.steps={}; for i, key in ipairs(model.steps or {}) do out.steps[i]=key end
    return out
end
W.Copy = copyModel
local function addSpell(class, spell)
    if spell.pet then return end
    W.registry[class] = W.registry[class] or {}
    local key = spell.id and ("i"..spell.id) or ("n"..spell.english:gsub("[^%w]", ""))
    if not W.registry[class][key] then W.registry[class][key] = spell end
    return key
end
for _, d in ipairs(FM.Catalog) do
    if classes[d.class] then for _, spell in ipairs(d.spells) do addSpell(d.class, spell) end end
end
for _, s in ipairs({{"PRIEST",588,"Inner Fire"},{"MAGE",168,"Frost Armor"},{"WARLOCK",706,"Demon Armor"}}) do
    addSpell(s[1], {id=s[2], english=s[3]})
end

W.starters = {
    WARRIOR={steps={"i772","i7386"}, target="enemy", note="Rend, then Sunder Armor. Needs a valid melee target, rage and a usable stance. This short opener can stall; keep interrupts and defensives separate."},
    PALADIN={steps={"i19740","i21084"}, target="self", ooc=true, note="Blessing of Might, then Seal of Righteousness. Two preparation presses outside combat. Reset with Alt when starting again."},
    HUNTER={steps={"i1978","i3044"}, target="enemy", note="Serpent Sting, then Arcane Shot. Each successful step needs a press. Cooldowns can hold the sequence. Pet attack and Auto Shot stay on your other buttons."},
    ROGUE={steps={"i1833","i1752"}, target="enemy", note="Cheap Shot, then Sinister Strike. Begin in stealth with enough energy. After the opener, use your usual attacks; this is not a repeating rotation."},
    PRIEST={steps={"i1243","i588"}, target="self", ooc=true, note="Power Word: Fortitude, then Inner Fire. Self preparation outside combat, with existing channels protected."},
    SHAMAN={steps={"i8075","i5394","i8512"}, target="current", note="Strength of Earth, Healing Stream, then Windfury Totem. One totem per successful press. Check mana, learned totems and the group's needs."},
    MAGE={steps={"i1459","i168"}, target="self", ooc=true, note="Arcane Intellect, then Frost Armor. Self preparation outside combat. Choose the armor you use before installing."},
    WARLOCK={steps={"i706","i5697"}, target="self", ooc=true, note="Demon Armor, then Unending Breath. Self preparation outside combat. Requires both learned spells."},
    DRUID={steps={"i1126","i467"}, target="self", ooc=true, caster=true, note="Mark of the Wild, then Thorns. Self preparation outside combat in caster form. Does not cancel an animal form."},
}

function W.Starter(class)
    local s=W.starters[class]; if not s then return nil, "Choose one of the nine supported classes." end
    local model={class=class, steps={}, mode="sequence", target=s.target,
        reset=s.ooc and "alt" or "target/combat/alt", ooc=s.ooc==true, caster=s.caster==true, channel=true}
    for i,key in ipairs(s.steps) do model.steps[i]=key end
    return model, s.note
end

function W.Validate(model)
    if type(model)~="table" then return nil, "A sequence must be structured data." end
    for key in pairs(model) do if not fields[key] then return nil, "Unknown sequence field." end end
    if not classes[model.class] then return nil, "Unsupported sequence class." end
    if model.mode~="sequence" and model.mode~="modifier" then return nil, "Choose sequence or modifier mode." end
    if targets[model.target]==nil or not resets[model.reset] then return nil, "Invalid targeting or reset option." end
    for _, key in ipairs({"ooc","caster","channel"}) do
        if type(model[key])~="boolean" then return nil, "Invalid sequence guard." end
    end
    if type(model.steps)~="table" then return nil, "Choose at least one ability." end
    local count=0
    for index, key in pairs(model.steps) do
        if type(index)~="number" or index<1 or index~=math.floor(index) or index>8
            or type(key)~="string" or not (W.registry[model.class] or {})[key] then return nil, "Unknown class ability or invalid step." end
        count=count+1
    end
    if count<1 or count~=#model.steps or (model.mode=="modifier" and count>3) then
        return nil, "Use 1 to 8 sequence steps, or up to 3 modifier choices."
    end
    for i=1,count do if not model.steps[i] then return nil, "Sequence steps cannot have gaps." end end
    return copyModel(model)
end

function W.Definition(slot, model)
    if not slotOK(slot) then return nil, "Choose sequence slot 1 to 8." end
    local m,reason=W.Validate(model); if not m then return nil, reason end
    local conditions={}
    if targets[m.target]~="" then conditions[#conditions+1]=targets[m.target] end
    if m.ooc then conditions[#conditions+1]="nocombat" end
    if m.caster then conditions[#conditions+1]="noform" end
    local condition=table.concat(conditions,",")
    local function brackets(extra)
        local c=extra and (extra..(condition~="" and (","..condition) or "")) or condition
        return c~="" and ("["..c.."] ") or ""
    end
    local spells,steps={},{}
    for i,key in ipairs(m.steps) do spells[i]=W.registry[m.class][key]; steps[i]="{"..i.."}" end
    local lines={"#showtooltip"}
    if m.channel then lines[#lines+1]="/stopmacro [channeling]" end
    if m.mode=="sequence" then
        lines[#lines+1]="/castsequence "..brackets().."reset="..m.reset.." "..table.concat(steps,", ")
    else
        local parts={}
        if steps[3] then parts[#parts+1]=brackets("mod:ctrl")..steps[3] end
        if steps[2] then parts[#parts+1]=brackets("mod:shift")..steps[2] end
        parts[#parts+1]=brackets("nomod")..steps[1]
        lines[#lines+1]="/cast "..table.concat(parts,"; ")
    end
    return {id="workshop_"..slot, name="FM Seq"..slot, class=m.class, spells=spells, body=table.concat(lines,"\n"),
        optional=true, priority=30, category="Sequences", attackPolicy="No attack-start command",
        description=m.mode=="sequence" and "Native sequence. Press for each step; an unavailable spell holds the sequence. Alt resets to step one."
            or "Modifier selector. No modifier: first choice. Shift: second. Ctrl: third, with Ctrl taking precedence.",
        sequenceNames=true, workshopSlot=slot, workshopModel=m}
end

local function split(s, separator)
    local out={}; local start=1
    while true do
        local at=s:find(separator,start,true)
        if not at then out[#out+1]=s:sub(start); return out end
        out[#out+1]=s:sub(start,at-1); start=at+#separator
    end
end
function W.Export(model)
    local m,reason=W.Validate(model); if not m then return nil,reason end
    return table.concat({"FMSEQ1",m.class,m.mode,m.target,m.reset,m.ooc and "1" or "0",m.caster and "1" or "0",
        m.channel and "1" or "0",table.concat(m.steps,",")},":")
end
function W.Import(value)
    if type(value)~="string" or #value>1024 or value:find("[%c]") then return nil,"Invalid or oversized sequence text." end
    local p=split(value,":")
    if #p~=9 or p[1]~="FMSEQ1" then return nil,"Paste an FMSEQ1 share string. GSE and Lua imports are not supported." end
    if p[2]~=classNow() then return nil,"This sequence belongs to another class." end
    for i=6,8 do if p[i]~="1" and p[i]~="0" then return nil,"Invalid guard in share string." end end
    return W.Validate({class=p[2],mode=p[3],target=p[4],reset=p[5],ooc=p[6]=="1",caster=p[7]=="1",channel=p[8]=="1",steps=split(p[9],",")})
end

function W.State()
    local db=FM.API.State(); if not db then return nil end
    if db.workshop~=nil and (type(db.workshop)~="table" or db.workshop.schema~=1) then return nil,"Unsupported workshop save format. Existing data was preserved." end
    if not db.workshop then db.workshop={schema=1,slots={},history={},profiles={},drafts={}} end
    if db.workshop.drafts==nil then db.workshop.drafts={} end
    for _,key in ipairs({"slots","history","profiles","drafts"}) do
        if type(db.workshop[key])~="table" then return nil,"Damaged workshop save data. Existing data was preserved." end
    end
    return db.workshop
end
local function register(d)
    for i,current in ipairs(FM.Catalog) do if current.id==d.id then FM.Catalog[i]=d; return end end
    FM.Catalog[#FM.Catalog+1]=d
end
function W.Initialize()
    local state=W.State(); if not state then return end
    for slot=1,W.maxSlots do
        local m=state.slots[slot]
        if type(m)=="table" and m.class==classNow() then local d=W.Definition(slot,m); if d then register(d) end end
    end
end
function W.Confirmed(d)
    if not d.workshopSlot then return end
    local state=W.State(); if not state then return end
    local slot,m=d.workshopSlot,d.workshopModel
    local old=state.slots[slot]
    if W.Validate(old) and W.Export(old)~=W.Export(m) then
        local history=type(state.history[slot])=="table" and state.history[slot] or {}
        table.insert(history,1,copyModel(old))
        while #history>W.maxHistory do table.remove(history) end
        state.history[slot]=history
    end
    state.slots[slot]=copyModel(m); register(d)
end
function W.History(slot)
    local state=W.State(); local result={}
    if not state or not slotOK(slot) then return result end
    for _,m in ipairs(type(state.history[slot])=="table" and state.history[slot] or {}) do
        local valid=W.Validate(m); if valid and valid.class==classNow() then result[#result+1]=valid end
        if #result>=W.maxHistory then break end
    end
    return result
end
function W.RefreshCache(seen)
    if FM.InCombat() or not FM.API.Ready() or not FM.API.Supported() then return end
    W.cache={}
    for key,spell in pairs(W.registry[classNow()] or {}) do
        local cacheKey="player:"..(spell.id or spell.english)
        if seen and seen[cacheKey] then W.cache[key]=FM.Manager.cache[cacheKey]
        else W.cache[key]=FM.API.Resolve(spell) end
    end
end
function W.Spells(query)
    local result={}; query=(query or ""):lower()
    for key,spec in pairs(W.registry[classNow()] or {}) do
        local name=W.cache[key]
        if (spec.english.." "..(name or "")):lower():find(query,1,true) then
            result[#result+1]={key=key,name=name or spec.english,learned=name~=nil,spec=spec}
        end
    end
    table.sort(result,function(a,b)
        if a.learned~=b.learned then return a.learned end
        if a.name==b.name then return a.key<b.key end
        return a.name<b.name
    end)
    return result
end
function W.Preview(slot,model)
    local d,reason=W.Definition(slot,model); if not d then return nil,reason end
    return FM.Core.Render(d,function(s)
        for key,spec in pairs(W.registry[model.class] or {}) do if spec==s then return W.cache[key] end end
    end)
end
function W.Install(slot,model)
    local state,reason=W.State(); if not state then return nil,reason end
    local d; d,reason=W.Definition(slot,model); if not d then return nil,reason end
    if d.class~=classNow() then return nil,"Choose a sequence for this class." end
    local db=FM.API.State()
    if not db.enabled or FM.Manager.fault or FM.API.Faulted() then return nil,"Updates are paused. Check /fm status and /macro." end
    local expectedBody
    if not FM.InCombat() then
        expectedBody,reason=FM.Core.Render(d,FM.API.Resolve); if not expectedBody then return nil,reason end
    end
    FM.API.State().skipped[d.id]=nil
    local ok; ok,reason=FM.Manager.RequestDefinition(d)
    if not ok then return nil,reason end
    if FM.Manager.pending[d.id] then return true,"Queued until combat ends. The current macro is unchanged." end
    if FM.Manager.fault or not state.slots[slot] or W.Export(state.slots[slot])~=W.Export(d.workshopModel)
        or not FM.Manager.Owned(d.id) or not FM.Managed.SameBody(db.managed[d.id].body,expectedBody) then
        return nil,FM.Manager.notice
    end
    return true,d.name.." installed. Drag it to your bar once; later updates use the same button."
end

function W.SaveDraft(slot,model)
    if not slotOK(slot) then return nil,"Invalid draft slot." end
    local m,reason=W.Validate(model); if not m then return nil,reason end
    if m.class~=classNow() then return nil,"Choose a draft for this class." end
    local state; state,reason=W.State(); if not state then return nil,reason end
    state.drafts[slot]=m; return true,"Draft saved. The installed macro is unchanged."
end

local function validateProfile(profile)
    if type(profile)~="table" or profile.class~=classNow() or type(profile.slots)~="table" then return nil,"Invalid profile for this class." end
    for key in pairs(profile) do if key~="class" and key~="slots" then return nil,"Unknown profile field." end end
    local out={class=profile.class,slots={}}; local count=0
    for slot,model in pairs(profile.slots) do
        if not slotOK(slot) then return nil,"Invalid profile slot." end
        local m,reason=W.Validate(model); if not m then return nil,reason end
        if m.class~=out.class then return nil,"Mixed classes are not supported." end
        out.slots[slot]=m; count=count+1
    end
    if count==0 then return nil,"Install a workshop sequence before saving a build." end
    return out
end
function W.SaveProfile(name)
    if type(name)~="string" or #name<1 or #name>24 or name:find("[%c|]") or not name:find("%S") then return nil,"Use a build name of 1 to 24 bytes without control characters or pipes." end
    local state,reason=W.State(); if not state then return nil,reason end
    if state.profiles[name] then return nil,"That build name already exists. Choose a new name to keep both versions." end
    local count=0; for _ in pairs(state.profiles) do count=count+1 end
    if count>=W.maxProfiles then return nil,"Twelve builds are already saved. Remove one after exporting it." end
    local profile; profile,reason=validateProfile({class=classNow(),slots=state.slots})
    if not profile then return nil,reason end
    state.profiles[name]=profile; return true
end
function W.Profile(name)
    local state,reason=W.State(); if not state then return nil,reason end
    return validateProfile(state.profiles[name])
end
function W.ExportProfile(profile)
    local p,reason=validateProfile(profile); if not p then return nil,reason end
    local lines={"FMPROFILE1:"..p.class}
    for slot=1,W.maxSlots do if p.slots[slot] then lines[#lines+1]=slot..":"..W.Export(p.slots[slot]) end end
    return table.concat(lines,"\n")
end
function W.ImportProfile(value)
    if type(value)~="string" or #value>6144 then return nil,"Invalid or oversized profile text." end
    value=value:gsub("\r\n","\n"):gsub("\n$","")
    local lines=split(value,"\n")
    if #lines<2 or #lines>9 or lines[1]~="FMPROFILE1:"..tostring(classNow()) then return nil,"Unsupported profile version or class." end
    local profile={class=classNow(),slots={}}
    for i=2,#lines do
        local digit,body=lines[i]:match("^([1-8]):(.+)$")
        local slot=tonumber(digit); if not slot or profile.slots[slot] then return nil,"Invalid or duplicate profile slot." end
        local m,reason=W.Import(body); if not m then return nil,reason end
        profile.slots[slot]=m
    end
    return validateProfile(profile)
end
function W.Plan(profile)
    if FM.InCombat() then return nil,"Preview builds after combat." end
    if not FM.API.Ready() or not FM.API.Supported() then return nil,"Wait for a supported Forever character." end
    local p,reason=validateProfile(profile); if not p then return nil,reason end
    local state; state,reason=W.State(); if not state then return nil,reason end
    local db=FM.API.State()
    if not db.enabled or FM.Manager.fault or FM.API.Faulted() then return nil,"Updates are paused. Check /fm status and /macro." end
    local snapshot; snapshot,reason=FM.API.Snapshot(); if not snapshot then return nil,reason end
    local plan={profile=p,rows={},needed=0,signature=W.ExportProfile(p)}
    local observations={tostring(snapshot.characterCount),tostring(snapshot.limit),tostring(db.reserve)}
    local seen={}
    for slot=1,W.maxSlots do
        if p.slots[slot] then
            local d=W.Definition(slot,p.slots[slot]); local body,missing=FM.Core.Render(d,FM.API.Resolve)
            if not body then return nil,d.name..": "..missing end
            if FM.Manager.pending[d.id] then return nil,d.name.." already has a queued change." end
            if seen[body] then return nil,"Two profile slots have identical bodies. Keep one copy." end
            seen[body]=true
            local record=db.managed[d.id]; local status="create"
            if record then
                if not FM.Manager.Owned(d.id) then return nil,d.name.." was edited, renamed, removed or is ambiguous. Preserved." end
                status=FM.Managed.SameBody(record.body,body) and "unchanged" or "update"
            else
                for _,macro in ipairs(snapshot.macros) do
                    if macro.name==d.name or FM.Managed.SameBody(macro.body,body) then return nil,d.name.." conflicts with an existing macro. Preserved." end
                end
                plan.needed=plan.needed+1
            end
            plan.rows[#plan.rows+1]={slot=slot,definition=d,body=body,status=status}
            observations[#observations+1]=tostring(slot)
            observations[#observations+1]=status
            observations[#observations+1]=body
            observations[#observations+1]=record and record.body or ""
            observations[#observations+1]=W.Export(state.slots[slot]) or ""
        end
    end
    if snapshot.characterCount+plan.needed>snapshot.limit-db.reserve then return nil,"The build needs "..plan.needed.." free slots beyond your reserve." end
    for i,value in ipairs(observations) do observations[i]=#value..":"..value end
    plan.fingerprint=table.concat(observations)
    return plan
end
function W.ApplyProfile(profile,expected)
    local plan,reason=W.Plan(profile); if not plan then return nil,reason end
    if expected and (expected.signature~=plan.signature or expected.fingerprint~=plan.fingerprint) then
        return nil,"Macros or slot settings changed since preview. Preview this build again."
    end
    local completed=0
    for _,row in ipairs(plan.rows) do
        local ok; ok,reason=W.Install(row.slot,plan.profile.slots[row.slot])
        local state=W.State()
        local queued=FM.Manager.pending[row.definition.id]
        if queued then FM.Manager.pending[row.definition.id]=nil end
        if not ok or queued or FM.Manager.fault
            or W.Export(state.slots[row.slot])~=W.Export(plan.profile.slots[row.slot]) then
            return nil, "Applied "..completed.." slots. Stopped at "..row.definition.name..": "..(queued and "Combat began; this slot was not applied. Preview again after combat." or reason or FM.Manager.notice)
        end
        completed=completed+1
    end
    return true,"Applied "..completed.." listed sequence slots. Omitted slots are unchanged."
end

function W.Lint(body)
    local issues={}
    if type(body)~="string" then return {"Macro text is unavailable."} end
    if #body==0 or #body>255 then issues[#issues+1]="Macro text is outside the 1 to 255 byte limit." end
    if #body>8192 then return issues end
    local number=0
    for line in (body.."\n"):gmatch("([^\n]*)\n") do
        number=number+1
        local command=line:match("^%s*/([%a]+)")
        if command then
            command=command:lower()
            if command=="run" or command=="script" then issues[#issues+1]="Line "..number..": Lua script needs manual review."
            elseif command=="click" then issues[#issues+1]="Line "..number..": button chaining needs a client compatibility check."
            elseif command=="cast" or command=="castsequence" or command=="use" or command=="stopmacro" then
                local depth,broken=0,false
                for c in line:gmatch("[%[%]]") do
                    depth=depth+(c=="[" and 1 or -1)
                    if depth<0 or depth>1 then broken=true end
                end
                if broken or depth~=0 then issues[#issues+1]="Line "..number..": unmatched or nested condition brackets." end
            end
        end
    end
    return issues
end

function W.Audit()
    if FM.InCombat() then return nil,"Run the patch check after combat." end
    local db=FM.API.State(); if not db or not FM.API.Supported() then return nil,"A supported Forever character is required." end
    local snapshot,reason=FM.API.Snapshot(); if not snapshot then return nil,reason end
    local version,build=GetBuildInfo()
    local result={"Client "..tostring(version).."."..tostring(build).." | "..snapshot.characterCount.."/"..snapshot.limit.." slots, "..db.reserve.." reserved."}
    local ids={}; for id in pairs(db.managed) do ids[#ids+1]=id end; table.sort(ids)
    for _,id in ipairs(ids) do
        local d=FM.Core.FindDefinition(id)
        if d then
            local body,missing=FM.Managed.Render(d,FM.API.Resolve,db.choices[id])
            local status=FM.Manager.Owned(id) and "Owned" or "Edited / missing / ambiguous. Preserved"
            if not body then status=status.."; "..(missing or "unavailable")
            elseif not FM.Managed.SameBody(body,db.managed[id].body) then status=status.."; generated text differs" end
            result[#result+1]=d.name..": "..status
            for _,macro in ipairs(snapshot.macros) do
                if macro.character and macro.name==db.managed[id].name then
                    for _,issue in ipairs(W.Lint(macro.body)) do result[#result+1]="  "..issue end
                end
            end
            for _,binding in ipairs(FM.Manager.BindingsFor(db.managed[id].name)) do
              if body then
                for _,modifier in ipairs({"ALT","SHIFT","CTRL"}) do
                    local lower=modifier:lower()
                    if binding:find(modifier.."-",1,true) and (body:find("mod:"..lower,1,true)
                        or (body:find("reset=",1,true) and lower=="alt")) then
                        result[#result+1]="  Check "..binding..": holds the "..modifier.." branch or reset on every press."
                    end
                end
              end
            end
        end
    end
    result[#result+1]="Read-only check. Binding checks cover readable default bars. Range, resources, talents, cooldowns and native sequence progression need an in-game test."
    return result
end
