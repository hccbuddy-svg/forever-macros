local _, FM = ...
local M = {}
FM.Managed = M
local function normal(s) return (s or ""):gsub("\r\n", "\n"):gsub("%s+$", "") end
function M.SameBody(a, b) return normal(a) == normal(b) end

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
            return nil, "Your edit was preserved. This macro will not be overwritten."
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
