local _, FM = ...
local M = {}
FM.Managed = M
local function normal(s) return (s or ""):gsub("\r\n", "\n"):gsub("%s+$", "") end
function M.SameBody(a, b) return normal(a) == normal(b) end

-- The game can put back the text the add-on itself wrote before an update: add-on data saves on
-- every /reload, macros only at a normal logout, so a client that closes without one keeps the
-- new record and the old macro (Forever, 2026-11-07). Text equal to the pre-update backup is the
-- add-on's own, not a personal edit, so it may still be updated. Anything else stays preserved.
-- Exact lines Hunter templates lost in 0.11.1 (Auto Shot recast) and 0.11.2 (melee start and
-- Wing Clip's off-target stop). Texts written before the add-on kept a history are recognized
-- as its own when they equal the current record plus only these lines.
local HUNTER_LEGACY = {
    ["/cast [harm,nodead] !Auto Shot"] = true, ["/cast !Auto Shot"] = true,
    ["/startattack [harm,nodead]"] = true,
    ["/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]"] = true,
}
local function withoutHunterLegacy(body)
    local out = {}
    for line in (normal(body) .. "\n"):gmatch("([^\n]*)\n") do
        if not HUNTER_LEGACY[line] then out[#out + 1] = line end
    end
    return table.concat(out, "\n")
end
M.PRIOR_LIMIT = 6
function M.Reverted(db, id, body)
    local backup = db and db.editBackup and db.editBackup[id]
    if backup ~= nil and type(backup.body) == "string" and normal(backup.body) == normal(body) then return true end
    local record = db and db.managed and db.managed[id]
    if type(record) ~= "table" or type(record.body) ~= "string" then return false end
    for _, old in ipairs(type(record.prior) == "table" and record.prior or {}) do
        if type(old) == "string" and normal(old) == normal(body) then return true end
    end
    local d = FM.Core and FM.Core.FindDefinition and FM.Core.FindDefinition(id)
    return d ~= nil and d.class == "HUNTER" and normal(body) ~= normal(record.body)
        and withoutHunterLegacy(body) == normal(record.body)
end

function M.ValidUnit(unit)
    return type(unit) == "string" and #unit > 0 and #unit < 110
        and not unit:find("[%s%c%[%];,@/\\|{}]")
end

function M.Render(definition, resolve, choice)
    if not choice or choice.kind == "default" then return FM.Core.Render(definition, resolve) end
    if not definition.unitBody then return nil, "This action does not accept a friendly teammate." end
    if choice.kind ~= "name" and choice.kind ~= "slot" then return nil, "Unknown assignment type." end
    if not M.ValidUnit(choice.unit) then return nil, "The teammate name is not ready." end
    if choice.kind == "slot" and not choice.unit:match("^party[1-4]$")
        and not choice.unit:match("^raid%d+$") and choice.unit ~= "player" then
        return nil, "Choose a current party or raid slot."
    end
    if choice.kind == "slot" and choice.unit:match("^raid") then
        local index = tonumber(choice.unit:match("%d+"))
        if index < 1 or index > 40 then return nil, "Invalid raid slot." end
    end
    local copy = {name = definition.name, spells = definition.spells,
        body = definition.unitBody:gsub("{unit}", function() return choice.unit end)}
    return FM.Core.Render(copy, resolve)
end

-- Only still-owned macros with unchanged text may be changed.
function M.Write(db, definition, body, env)
    if env.inCombat() then return nil, "Queued until combat ends." end
    if type(body) ~= "string" or #body == 0 or #body > 255 then return nil, "Macro must contain 1 to 255 bytes." end
    local snapshot, reason = env.snapshot()
    if not snapshot then return nil, reason end
    local record, found, count = db.managed[definition.id], nil, 0
    local name = record and record.name or definition.name
    for _, macro in ipairs(snapshot.macros) do
        if macro.name == name then found = macro; count = count + 1 end
    end
    if record then
        if count ~= 1 or not found or not found.character then
            return nil, "Managed macro is missing, renamed, or ambiguous. Restore it explicitly before replacing it."
        end
        if normal(found.body) ~= normal(record.body) then
            if not M.Reverted(db, definition.id, found.body) then
                return nil, "Your edit was preserved. This macro will not be overwritten."
            end
            record.body = found.body
        end
        if normal(body) == normal(found.body) then return true end
        if type(env.edit) ~= "function" then return nil, "The client does not expose macro editing." end
        if not db.editBackup[definition.id] then
            db.editBackup[definition.id] = {name = found.name, body = found.body, icon = found.icon}
        end
        if env.inCombat() then return nil, "Queued until combat ends." end
        local ok, index = pcall(env.edit, found.index, nil, nil, body)
        if not ok or type(index) ~= "number" then return nil, "Macro update failed. Further updates are paused.", true end
        local read, actualName, _, actualBody = pcall(env.getInfo, index)
        if not read or actualName ~= name or normal(actualBody) ~= normal(body)
            or index <= snapshot.accountLimit or index > snapshot.accountLimit + snapshot.limit then
            return nil, "The macro update could not be verified. Further updates are paused.", true
        end
        -- Remember the text this replaces, so a later revert by the game is still recognized.
        if type(record.prior) ~= "table" then record.prior = {} end
        table.insert(record.prior, 1, record.body)
        while #record.prior > M.PRIOR_LIMIT do table.remove(record.prior) end
        record.body = actualBody
        return true
    end
    if count > 0 then return nil, "A macro with this name already exists. It was preserved." end
    for _, macro in ipairs(snapshot.macros) do
        if normal(macro.body) == normal(body) then return nil, "An identical macro already exists. It was preserved." end
    end
    if snapshot.characterCount >= snapshot.limit - db.reserve then return nil, "No free character slots after your reserve." end
    local result = FM.Core.Apply(db, {{status = "ready", definition = definition, body = body}}, env)
    if #result.errors > 0 then return nil, result.errors[1], true end
    if result.created ~= 1 then return nil, "Macro creation was deferred or no space remains." end
    return true
end

function M.GearBody(items, trinkets)
    local lines = {"#showtooltip"}
    if trinkets then table.insert(lines, "/stopmacro [combat]") end
    local count = 0
    for _, slot in ipairs(trinkets and {13, 14} or {16, 17, 18}) do
        local id = items and items[slot]
        if id then
            if type(id) ~= "number" or id < 1 or id ~= math.floor(id) then return nil, "Invalid equipment item." end
            table.insert(lines, "/equipslot " .. slot .. " item:" .. id)
            count = count + 1
        end
    end
    if count == 0 then return nil, "Choose an item or capture your equipped items first." end
    local body = table.concat(lines, "\n")
    if #body > 255 then return nil, "This equipment macro is too long." end
    return body
end
