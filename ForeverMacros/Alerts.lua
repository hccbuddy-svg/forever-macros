local _, FM = ...
local A = {recent = {}, running = {}, revision = 0, blocked = 0, connected = false}
FM.Alerts = A
local function public(v) return not issecretvalue or not issecretvalue(v) end
local function db() local state = FM.API.State(); return state and state.alerts end
local function changed() if FM.UI then FM.UI.Refresh() end end
local function now() return GetTime and GetTime() or 0 end
local function plain(s) return s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):sub(1, 100) end

function A.Show(macroID, label, test)
    local state = FM.API.State()
    local record = state and state.managed[macroID]
    local owned = record and FM.Manager.Owned(macroID)
    if not test and not owned then return end
    local macroName = record and record.name or "Choose a macro"
    local binding = record and FM.Manager.BindingFor(macroName)
    local text = (test and "TEST REMINDER\n" or "REMINDER\n") .. macroName
        .. (binding and "  [" .. binding .. "]" or "") .. "\n" .. label
    local icon = owned and owned.icon or 134400
    local trinketSlot = macroID == "trinket_top" and 13 or macroID == "trinket_bottom" and 14
    if trinketSlot and GetInventoryItemTexture then
        local ok, texture = pcall(GetInventoryItemTexture, "player", trinketSlot)
        if ok and public(texture) and texture then icon = texture end
    end
    if owned and GetMacroSpell and C_Spell and C_Spell.GetSpellTexture then
        local ok, spellID = pcall(GetMacroSpell, owned.index)
        if ok and public(spellID) and spellID then
            local read, texture = pcall(C_Spell.GetSpellTexture, spellID)
            if read and public(texture) and texture then icon = texture end
        end
    end
    if FM.UI then FM.UI.Alert(text, icon) end
    if PlaySound and SOUNDKIT and SOUNDKIT.RAID_WARNING then PlaySound(SOUNDKIT.RAID_WARNING, "Master") end
end

function A.Schedule(id, remaining)
    local run, settings = A.running[id], db()
    if not run or not settings or not settings.enabled or run.paused or run.fired then return end
    local rule = settings.rules[run.key]
    if not rule then return end
    A.revision = A.revision + 1
    run.revision = A.revision
    local revision = run.revision
    local delay = math.max(0, remaining - rule.lead)
    C_Timer.After(delay, function()
        local current, currentSettings = A.running[id], db()
        if not current or current.revision ~= revision or current.paused or current.fired
            or not currentSettings or not currentSettings.enabled then return end
        local currentRule = currentSettings.rules[current.key]
        if not currentRule or currentRule ~= rule then return end
        current.fired = true
        A.Show(rule.macroID, current.label, false)
    end)
end

function A.Begin(_, id, message, duration, icon, timerType, spellID, _, modID)
    if not FM.API.Supported() then return end
    if not public(id) or not public(message) or not public(duration) or not public(timerType)
        or not public(spellID) or not public(modID) then A.blocked = A.blocked + 1; return end
    if type(id) ~= "string" or type(message) ~= "string" or type(duration) ~= "number"
        or duration <= 0 or duration > 3600 or duration ~= duration
        or (type(spellID) ~= "number" and type(spellID) ~= "string") or spellID == ""
        or type(modID) ~= "string" or type(timerType) ~= "string" then return end
    local key = modID .. ":" .. tostring(spellID) .. ":" .. timerType
    local label = plain(message) .. " (" .. timerType .. ")"
    A.running[id] = {key = key, label = label, ends = now() + duration}
    local found
    for _, entry in ipairs(A.recent) do if entry.key == key then entry.label = label; found = true end end
    if not found then
        table.insert(A.recent, 1, {key = key, label = label})
        if #A.recent > 20 then table.remove(A.recent) end
    end
    A.Schedule(id, duration)
    changed()
end

function A.Stop(_, id)
    if public(id) and type(id) == "string" then A.running[id] = nil end
end
function A.Update(_, id, elapsed, total)
    if not public(id) or not public(elapsed) or not public(total) then A.blocked = A.blocked + 1; return end
    local run = type(id) == "string" and A.running[id]
    if not run or type(elapsed) ~= "number" or type(total) ~= "number" or total <= 0
        or total > 3600 or elapsed < 0 or elapsed ~= elapsed or total ~= total then return end
    run.ends = now() + math.max(0, total - elapsed)
    A.revision = A.revision + 1; run.revision = A.revision
    if total <= elapsed then A.running[id] = nil; return end
    if run.paused then run.remaining = total - elapsed else A.Schedule(id, total - elapsed) end
end
function A.Pause(_, id)
    if not public(id) then return end
    local run = type(id) == "string" and A.running[id]
    if run then run.paused = true; run.remaining = math.max(0, run.ends - now()); run.revision = -1 end
end
function A.Resume(_, id)
    if not public(id) then return end
    local run = type(id) == "string" and A.running[id]
    if run and run.paused then
        run.paused = nil; run.ends = now() + run.remaining; A.Schedule(id, run.remaining)
    end
end
function A.Clear() A.running = {} end
function A.Link(entry, macroID, lead)
    if FM.InCombat() then return nil, "Configure reminders after combat." end
    local state, settings = FM.API.State(), db()
    if not state or not FM.Manager.Owned(macroID) then return nil, "Choose an installed, unedited library macro first." end
    if not entry or type(entry.key) ~= "string" then return nil, "Choose an observed boss timer first." end
    lead = tonumber(lead)
    if not lead or lead < 0 or lead > 10 or lead ~= lead then return nil, "Lead time must be between 0 and 10 seconds." end
    settings.rules[entry.key] = {macroID = macroID, lead = lead, label = entry.label}
    return true
end
function A.Attach()
    if A.connected or not DBM or type(DBM.RegisterCallback) ~= "function" then return end
    for event, callback in pairs({DBM_TimerBegin = A.Begin, DBM_TimerStop = A.Stop,
        DBM_TimerUpdate = A.Update, DBM_TimerPause = A.Pause, DBM_TimerResume = A.Resume}) do
        DBM:RegisterCallback(event, callback)
    end
    A.connected = true
end
local frame = CreateFrame("Frame")
for _, event in ipairs({"ADDON_LOADED", "PLAYER_ENTERING_WORLD", "ENCOUNTER_END", "PLAYER_DEAD"}) do frame:RegisterEvent(event) end
frame:SetScript("OnEvent", function(_, event)
    if event == "ENCOUNTER_END" or event == "PLAYER_DEAD" or event == "PLAYER_ENTERING_WORLD" then A.Clear() end
    A.Attach()
end)
