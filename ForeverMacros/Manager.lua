local _, FM = ...
local M = {pending = {}, cache = {}, notice = "Select an action to preview it."}
FM.Manager = M
FM.InCombat = function() return type(InCombatLockdown) ~= "function" or InCombatLockdown() end
local API = FM.API
local function secret(v) return issecretvalue and issecretvalue(v) end
local function key(s) return (s.pet and "pet:" or "player:") .. (s.id or s.english) end
local function copy(t) local out = {}; for k, v in pairs(t or {}) do out[k] = v end; return out end

function M.Owned(id)
    local db = API.State()
    local record = db and db.managed[id]
    if not record then return nil end
    local snapshot = API.Snapshot()
    if not snapshot then return nil end
    local found, count = nil, 0
    for _, macro in ipairs(snapshot.macros) do
        if macro.name == record.name then found = macro; count = count + 1 end
    end
    if count == 1 and found.character and FM.Managed.SameBody(found.body, record.body) then return found end
end

function M.Roster()
    local result = {}
    if not UnitExists or not UnitName then return result end
    local raid = IsInRaid and IsInRaid()
    local units = {}
    if raid then for i = 1, 40 do units[#units + 1] = "raid" .. i end
    else units = {"player", "party1", "party2", "party3", "party4"} end
    for _, unit in ipairs(units) do
        if UnitExists(unit) then
            local name, realm = (UnitFullName or UnitName)(unit)
            if not secret(name) and not secret(realm) and type(name) == "string" and name ~= "" then
                local full = name
                if type(realm) == "string" and realm ~= "" then full = name .. "-" .. realm:gsub("%s", "") end
                if FM.Managed.ValidUnit(full) then
                    result[#result + 1] = {unit = unit, name = full, short = name}
                end
            end
        end
    end
    return result
end

function M.ChoicePresent(choice)
    if not choice or choice.kind == "default" then return true end
    for _, member in ipairs(M.Roster()) do
        if (choice.kind == "name" and member.name == choice.unit)
            or (choice.kind == "slot" and member.unit == choice.unit) then return true end
    end
    return false
end

function M.AssignmentText(choice)
    if not choice or choice.kind == "default" then return "Default targeting" end
    if choice.kind == "name" then return choice.unit .. (M.ChoicePresent(choice) and " (pinned)" or " (absent)") end
    for _, member in ipairs(M.Roster()) do
        if member.unit == choice.unit then return member.name .. " (" .. choice.unit .. ")" end
    end
    return choice.unit .. " (empty)"
end

function M.RefreshCache()
    if FM.InCombat() or not API.Ready() or not API.Supported() then return end
    M.cache = {}
    local _, class = UnitClass("player")
    local seen = {}
    for _, d in ipairs(FM.Catalog) do
        if d.class == class or d.class == "ALL" then
            for _, spell in ipairs(d.spells) do
                local k = key(spell)
                if not seen[k] then M.cache[k] = API.Resolve(spell); seen[k] = true end
            end
        end
    end
end

function M.Preview(definition, choice)
    return FM.Managed.Render(definition, function(s) return M.cache[key(s)] end, choice)
end

function M.Process()
    if FM.InCombat() or not API.Ready() or M.busy or M.fault then return end
    local db = API.State()
    if not db or not API.Supported() or API.Faulted() then return end
    M.busy = true
    local ids = {}; for id in pairs(M.pending) do ids[#ids + 1] = id end; table.sort(ids)
    for _, id in ipairs(ids) do
        if FM.InCombat() or M.fault then break end
        local request = M.pending[id]
        local d, choice = request.definition, request.choice
        local ok, reason, fatal
        if not db.enabled then reason = "Additions are paused. Use /fm on to enable them."
        elseif not request.automatic and not M.ChoicePresent(choice) then reason = "Assignment cancelled: that teammate or slot is no longer in your group."
        else
            local body, missing = FM.Managed.Render(d, API.Resolve, choice)
            if not body then
                reason = missing
                if choice.kind == "default" and not db.managed[id] and FM.Core.FindDefinition(id) then
                    db.wanted[id] = copy(choice)
                    reason = d.name .. " saved for when learned and a character slot is free."
                end
            else
                local called, result, detail, uncertain = pcall(FM.Managed.Write, db, d, body, API.Environment())
                if called then ok, reason, fatal = result, detail, uncertain
                else reason, fatal = "An API error paused managed updates. Check /macro, then /fm retry.", true end
            end
        end
        if ok then
            db.choices[id] = copy(choice)
            db.wanted[id] = nil
            M.notice = d.name .. " updated. " .. M.AssignmentText(choice) .. "."
        else M.notice = reason or "No change made." end
        M.pending[id] = nil
        if fatal then M.fault = true end
        if not request.automatic then API.Say(M.notice) end
    end
    M.busy = false
    M.RefreshLabels()
end

function M.RequestDefinition(definition, choice)
    local db = API.State()
    if not db or not API.Ready() then return nil, "Wait until your character has entered the world." end
    if not API.Supported() then return nil, "This release supports Forever 1.60.x only." end
    if M.fault or API.Faulted() then return nil, "Updates are paused. Check /macro, then /fm retry." end
    local _, class = UnitClass("player")
    if definition.class ~= "ALL" and definition.class ~= class then return nil, "Choose an action for this character's class." end
    choice = copy(choice or {kind = "default"})
    if choice.kind ~= "default" and not definition.unitBody then return nil, "This action does not accept a teammate." end
    if not M.ChoicePresent(choice) then return nil, "Choose a teammate from your current group." end
    if choice.kind ~= "default" and not FM.Managed.ValidUnit(choice.unit) then return nil, "Invalid teammate." end
    if not FM.InCombat() and not db.managed[definition.id] then
        local body = FM.Managed.Render(definition, API.Resolve, choice)
        if not body and choice.kind == "default" then
            db.wanted[definition.id] = copy(choice)
            db.skipped[definition.id] = nil
            M.notice = definition.name .. " saved. It will install when learned and a character slot is free."
            API.Say(M.notice)
            if FM.UI then FM.UI.Refresh() end
            return true
        end
    end
    M.pending[definition.id] = {definition = definition, choice = choice}
    if FM.InCombat() then
        M.notice = "Queued for after combat. The current macro still uses its previous assignment."
        API.Say(M.notice)
    else M.Process() end
    if FM.UI then FM.UI.Refresh() end
    return true
end

function M.Request(id, choice)
    local definition = FM.Core.FindDefinition(id)
    if not definition then return nil, "Unknown action." end
    return M.RequestDefinition(definition, choice)
end

-- Coalesced events refresh only unchanged, owned macros. Never recreate deleted ones.
function M.SyncInstalled()
    local db = API.State()
    if FM.InCombat() or not db or not db.enabled or not API.Ready() or not API.Supported()
        or M.fault or API.Faulted() then return end
    local _, class = UnitClass("player")
    for _, d in ipairs(FM.Catalog) do
        if (d.class == class or d.class == "ALL") and not db.skipped[d.id] and not M.pending[d.id] then
            local owned = db.managed[d.id] and M.Owned(d.id)
            local choice = copy(db.choices[d.id] or db.wanted[d.id] or {kind = "default"})
            if owned or (db.wanted[d.id] and not db.managed[d.id]) then
                local body = FM.Managed.Render(d, API.Resolve, choice)
                if body and (not owned or not FM.Managed.SameBody(body, owned.body)) then
                    M.pending[d.id] = {definition = d, choice = choice, automatic = true}
                elseif body and owned then db.wanted[d.id] = nil end
            end
        end
    end
    M.Process()
end

function M.UpdateInstalled()
    local db = API.State()
    if not db or not API.Ready() or not API.Supported() then return nil, "Character data is not ready or this client is unsupported." end
    if not db.enabled then return nil, "Updates are paused. Use /fm on first." end
    if M.fault or API.Faulted() then return nil, "Check your macros before /fm retry." end
    local _, class = UnitClass("player")
    local count = 0
    for _, d in ipairs(FM.Catalog) do
        if (d.class == class or d.class == "ALL") and db.managed[d.id] and not M.pending[d.id] then
            M.pending[d.id] = {definition = d, choice = copy(db.choices[d.id] or {kind = "default"})}
            count = count + 1
        end
    end
    M.notice = "Checking " .. count .. " installed library macros. Personal edits are preserved."
    if FM.InCombat() then M.notice = M.notice .. " Queued until combat ends."
    else M.Process() end
    API.Say(M.notice)
    if FM.UI then FM.UI.Refresh() end
    return true
end

function M.RefreshForms()
    local db = API.State()
    if not db or not API.Ready() or not API.Supported() or not db.enabled or M.fault or API.Faulted() then return end
    local _, class = UnitClass("player")
    for _, d in ipairs(FM.Catalog) do
        if d.class == class and d.formIDs and db.managed[d.id] and not db.skipped[d.id] and not M.pending[d.id] then
            local body = FM.Core.Render(d, API.Resolve)
            if body and not FM.Managed.SameBody(body, db.managed[d.id].body) and M.Owned(d.id) then
                M.pending[d.id] = {definition = d, choice = {kind = "default"}, automatic = true}
            end
        end
    end
end

local bars = {
    {"ActionButton", "ACTIONBUTTON"}, {"MultiBarBottomLeftButton", "MULTIACTIONBAR1BUTTON"},
    {"MultiBarBottomRightButton", "MULTIACTIONBAR2BUTTON"}, {"MultiBarRightButton", "MULTIACTIONBAR3BUTTON"},
    {"MultiBarLeftButton", "MULTIACTIONBAR4BUTTON"}, {"MultiBar5Button", "MULTIACTIONBAR5BUTTON"},
    {"MultiBar6Button", "MULTIACTIONBAR6BUTTON"}, {"MultiBar7Button", "MULTIACTIONBAR7BUTTON"},
}

function M.BarButtons(visitor)
    if not GetActionInfo then return end
    for _, bar in ipairs(bars) do
        for n = 1, 12 do
            local button = _G[bar[1] .. n]
            if button then
                local action = button.action
                if not secret(action) and type(action) == "number" then
                    local ok, kind, index = pcall(GetActionInfo, action)
                    if ok and not secret(kind) and not secret(index) and kind == "macro" and type(index) == "number" then
                        local valid, name, _, body = pcall(GetMacroInfo, index)
                        if valid and not secret(name) and not secret(body) and type(name) == "string" and type(body) == "string" then
                            visitor(button, name, bar[2] .. n, body)
                        elseif button.fmName then button.fmName:SetText("") end
                    elseif button.fmName then button.fmName:SetText("") end
                elseif button.fmName then button.fmName:SetText("") end
            end
        end
    end
end

function M.BindingFor(name)
    local found
    M.BarButtons(function(_, macroName, command)
        if not found and macroName == name and GetBindingKey then found = GetBindingKey(command) end
    end)
    return found
end

function M.RefreshLabels()
    local db = API.State()
    if not db then return end
    local assignments = {}
    for id, choice in pairs(db.choices) do
        local record = db.managed[id]
        if record and choice.kind ~= "default" and M.Owned(id) then
            assignments[record.name] = {label = M.AssignmentText(choice), body = record.body}
        end
    end
    M.BarButtons(function(button, name, _, body)
        local assignment = assignments[name]
        local label = assignment and FM.Managed.SameBody(body, assignment.body) and assignment.label
        if label and not button.fmName and not FM.InCombat() then
            button.fmName = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            button.fmName:SetPoint("BOTTOM", button, "BOTTOM", 0, 12)
            button.fmName:SetWidth(62)
            button.fmName:SetWordWrap(false)
        end
        if button.fmName then button.fmName:SetText(label and label:match("^[^ %(%-]+") or "") end
    end)
end

local frame = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_ENTERING_WORLD", "GROUP_ROSTER_UPDATE", "UNIT_NAME_UPDATE", "PLAYER_REGEN_ENABLED",
    "SPELLS_CHANGED", "SPELL_TEXT_UPDATE", "PLAYER_LEVEL_UP", "UNIT_PET", "UPDATE_SHAPESHIFT_FORMS", "ACTIONBAR_SLOT_CHANGED", "UPDATE_MACROS", "UPDATE_BINDINGS"}) do frame:RegisterEvent(event) end
frame:SetScript("OnEvent", function(_, event)
    if event == "UPDATE_SHAPESHIFT_FORMS" or event == "SPELLS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then M.formsDirty = true end
    if M.scheduled then return end
    M.scheduled = true
    C_Timer.After(0.2, function()
        M.scheduled = false
        if not FM.InCombat() then
            M.RefreshCache()
            if M.formsDirty then M.formsDirty = nil; M.RefreshForms() end
            M.SyncInstalled()
            M.Process()
        end
        M.RefreshLabels()
        if FM.UI then FM.UI.Refresh() end
    end)
end)
