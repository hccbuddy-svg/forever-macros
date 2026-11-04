local _, FM = ...
local Core = {}
FM.Core = Core

local function normalize(body)
    return (body or ""):gsub("\r\n", "\n"):gsub("%s+$", "")
end

function Core.NewState(db)
    if type(db) ~= "table" then db = {} end
    if db.schema ~= nil and db.schema ~= 1 then return nil, "Unsupported saved-data schema." end
    db.schema = 1
    if db.enabled == nil then db.enabled = true end
    if type(db.reserve) ~= "number" or db.reserve < 0 then db.reserve = 2 end
    db.reserve = math.floor(db.reserve)
    if type(db.managed) ~= "table" then db.managed = {} end
    if type(db.skipped) ~= "table" then db.skipped = {} end
    if type(db.choices) ~= "table" then db.choices = {} end
    if type(db.gear) ~= "table" then db.gear = {} end
    if type(db.alerts) ~= "table" then db.alerts = {rules = {}} end
    if type(db.alerts.rules) ~= "table" then db.alerts.rules = {} end
    if type(db.editBackup) ~= "table" then db.editBackup = {} end
    if type(db.wanted) ~= "table" then db.wanted = {} end
    return db
end

function Core.FindDefinition(id)
    for _, definition in ipairs(FM.Catalog) do
        if definition.id == id then return definition end
    end
end

function Core.Render(definition, resolve)
    if definition.blocked then return nil, definition.blocked end
    local names = {}
    for index, requirement in ipairs(definition.spells) do
        local name = resolve(requirement)
        if type(name) ~= "string" or name == "" or name:find("[\r\n;%[%]]") then
            return nil, "Ability not learned or name unavailable: " .. requirement.english
        end
        if definition.sequenceNames and name:find("[,|{}]") then
            return nil, "Spell name contains a sequence separator."
        end
        names[index] = name
    end
    local body = definition.body:gsub("{(%d+)}", function(index) return names[tonumber(index)] or "" end)
    if definition.formIDs then
        local index = FM.ResolveForm and FM.ResolveForm(definition.formIDs)
        if type(index) ~= "number" or index < 1 or index ~= math.floor(index) then
            return nil, "Required form or stance is not available in this character's form bar."
        end
        body = body:gsub("{form}", tostring(index))
    end
    if #definition.name > 16 or #body > 255 then
        return nil, "Template exceeds the conservative macro length limit."
    end
    return body
end

-- Planning is read-only. Only Apply may write macros or persist managed records.
function Core.Plan(db, class, snapshot, resolve)
    local plan = {}
    local available = math.max(0, snapshot.limit - snapshot.characterCount - db.reserve)
    local names, bodies, characterNames = {}, {}, {}
    for _, macro in ipairs(snapshot.macros) do
        names[macro.name] = true
        bodies[normalize(macro.body)] = true
        if macro.character then characterNames[macro.name] = true end
    end
    local ordered, positions = {}, {}
    for i, d in ipairs(FM.Catalog) do ordered[i] = d; positions[d.id] = i end
    table.sort(ordered, function(a, b)
        local ap, bp = a.priority or 20, b.priority or 20
        if ap ~= bp then return ap < bp end
        return positions[a.id] < positions[b.id]
    end)
    for _, definition in ipairs(ordered) do
        if definition.class == "ALL" or definition.class == class then
            local item = { definition = definition }
            local managed = db.managed[definition.id]
            if db.skipped[definition.id] then
                item.status = "skipped"
            elseif managed then
                item.status = characterNames[managed.name] and "installed" or "removed"
            elseif definition.optional then
                item.status = "choose in /fm"
            else
                item.body, item.reason = Core.Render(definition, resolve)
                if not item.body then
                    item.status = "unavailable"
                elseif names[definition.name] then
                    item.status = "name exists"
                elseif bodies[normalize(item.body)] then
                    item.status = "body exists"
                elseif available == 0 then
                    item.status = "no space"
                else
                    item.status = "ready"
                    available = available - 1
                    names[definition.name] = true
                    bodies[normalize(item.body)] = true
                end
            end
            table.insert(plan, item)
        end
    end
    return plan
end

function Core.Apply(db, plan, env)
    local result = { created = 0, errors = {} }
    for _, item in ipairs(plan) do
        if item.status == "no space" then result.blockedBySpace = (result.blockedBySpace or 0) + 1 end
    end
    if not db.enabled then result.disabled = true; return result end
    if env.inCombat() then result.deferred = true; return result end
    for _, item in ipairs(plan) do
        if item.status == "ready" then
            if env.inCombat() then result.deferred = true; break end
            local snapshot, reason = env.snapshot()
            if not snapshot then table.insert(result.errors, reason or "Cannot read macros."); break end
            local collision = false
            for _, macro in ipairs(snapshot.macros) do
                if macro.name == item.definition.name or normalize(macro.body) == normalize(item.body) then
                    collision = true
                    break
                end
            end
            if not collision then
                if snapshot.characterCount >= snapshot.limit - db.reserve then break end
                -- Capture original macro text once, before the first write. No account identity is read.
                if not db.backup then
                    db.backup = { macros = {}, build = env.build, createdAt = env.timestamp() }
                    for _, macro in ipairs(snapshot.macros) do
                        table.insert(db.backup.macros, {
                            name = macro.name, body = macro.body, icon = macro.icon,
                            character = macro.character,
                        })
                    end
                end
                local ok, index = pcall(env.create, item.definition.name, 134400, item.body, true)
                if not ok or type(index) ~= "number" then
                    table.insert(result.errors, "Creation failed for " .. item.definition.name .. ".")
                    break
                end
                -- Read by returned index immediately: macro indices may change when later names are added.
                local actualName, _, actualBody = env.getInfo(index)
                if index <= snapshot.accountLimit or index > snapshot.accountLimit + snapshot.limit
                    or actualName ~= item.definition.name or normalize(actualBody) ~= normalize(item.body) then
                    table.insert(result.errors, "Creation could not be verified for " .. item.definition.name .. ".")
                    break
                end
                db.managed[item.definition.id] = { name = actualName, body = actualBody }
                result.created = result.created + 1
            end
        end
    end
    return result
end
