-- Small independent condition model for branch regression tests. This is not
-- the WoW engine and does not certify native spell or swing execution.
function TEST.macroModel(body, state)
    local actions = {}
    local function conditions(clause)
        local unit = clause:match("@([%w]+)") or "target"
        local data = state[unit] or {}
        for token in clause:gmatch("[^,]+") do
            if token:sub(1,1) == "@" then
            elseif token == "harm" then if not data.harm then return false end
            elseif token == "noharm" then if data.harm then return false end
            elseif token == "dead" then if not data.dead then return false end
            elseif token == "help" then if not data.exists or data.harm then return false end
            elseif token == "nodead" then if data.dead or not data.exists then return false end
            elseif token == "mod:shift" then if not state.shift then return false end
            elseif token == "mod:alt" then if not state.alt then return false end
            elseif token == "nostealth" then if state.stealth then return false end
            elseif token == "nocombat" then if state.combat then return false end
            elseif token == "channeling" then if not state.channeling then return false end
            elseif token == "noform" then if state.form and state.form~=0 then return false end
            elseif token:match("^form:") then if state.form ~= tonumber(token:match("%d+")) then return false end
            else error("Unsupported test condition "..token) end
        end
        return true, unit
    end
    for line in body:gmatch("[^\n]+") do
        local command, rest = line:match("^/(%w+)%s*(.*)")
        if command then
            local matched, unit, conditional = false, "target", false
            for clause in rest:gmatch("%[([^%]]*)%]") do
                conditional = true
                local ok, selected = conditions(clause)
                if ok then matched, unit = true, selected; break end
            end
            if not conditional then matched = true end
            if matched then
                if command == "stopmacro" then break end
                local value = rest:gsub("%[[^%]]*%]", ""):gsub("^%s+", "")
                table.insert(actions, {command=command, unit=unit, value=value})
            end
        end
    end
    return actions
end
function TEST.actionsOf(actions, command)
    local list = {}; for _, action in ipairs(actions) do if action.command==command then list[#list+1]=action end end
    return list
end
