local ADDON_NAME, FM = ...
local Core = FM.Core
local frame = CreateFrame("Frame")
local ready, queued, applying, pendingCombat = false, false, false, false
local fault, lastError
local db
local readinessAttempts = 0
local lastSpaceWarning

function FM.ResolveForm(ids)
    if not GetNumShapeshiftForms or not GetShapeshiftFormInfo then return nil end
    for index = 1, GetNumShapeshiftForms() do
        local _, _, _, spellID = GetShapeshiftFormInfo(index)
        if not issecretvalue or not issecretvalue(spellID) then
            for _, id in ipairs(ids) do if spellID == id then return index end end
        end
    end
end

local function say(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd28aForever Macros:|r " .. message)
end

local function supported()
    local version = GetBuildInfo()
    return type(version) == "string" and version:match("^1%.60%.") ~= nil
end

local function checkAPI()
    local constants = Constants and Constants.MacroConsts
    if not constants or type(constants.MAX_ACCOUNT_MACROS) ~= "number"
        or type(constants.MAX_CHARACTER_MACROS) ~= "number" then
        return nil, "The client did not provide macro slot limits."
    end
    if type(GetMacroInfo) ~= "function" or type(GetNumMacros) ~= "function"
        or type(CreateMacro) ~= "function" or type(InCombatLockdown) ~= "function" then
        return nil, "Required macro functions are unavailable."
    end
    return constants
end

local function snapshot()
    local constants, reason = checkAPI()
    if not constants then return nil, reason end
    local ok, accountCount, characterCount = pcall(GetNumMacros)
    if not ok or type(accountCount) ~= "number" or type(characterCount) ~= "number"
        or accountCount < 0 or characterCount < 0
        or accountCount > constants.MAX_ACCOUNT_MACROS
        or characterCount > constants.MAX_CHARACTER_MACROS then
        return nil, "Macro counts are not ready."
    end
    local macros, actualAccount, actualCharacter = {}, 0, 0
    for index = 1, constants.MAX_ACCOUNT_MACROS + constants.MAX_CHARACTER_MACROS do
        local valid, name, icon, body = pcall(GetMacroInfo, index)
        if not valid then return nil, "Macro data could not be read." end
        if name then
            if type(name) ~= "string" or type(body) ~= "string" then
                return nil, "Macro text is not ready."
            end
            local character = index > constants.MAX_ACCOUNT_MACROS
            if character then actualCharacter = actualCharacter + 1 else actualAccount = actualAccount + 1 end
            table.insert(macros, { index = index, name = name, icon = icon, body = body, character = character })
        end
    end
    if actualAccount ~= accountCount or actualCharacter ~= characterCount then
        return nil, "Macro counts and contents disagree; waiting for a fresh snapshot."
    end
    return {
        macros = macros, characterCount = characterCount,
        accountLimit = constants.MAX_ACCOUNT_MACROS, limit = constants.MAX_CHARACTER_MACROS,
    }
end

local function resolve(requirement)
    if not C_SpellBook or not C_SpellBook.FindSpellBookSlotForSpell
        or not C_SpellBook.GetSpellBookItemInfo or not C_SpellBook.IsSpellKnown
        or not Enum or not Enum.SpellBookSpellBank then return nil end
    local candidates = {}
    if requirement.id then table.insert(candidates, requirement.id) end
    if requirement.id and C_Spell and C_Spell.GetSpellName then
        local ok, name = pcall(C_Spell.GetSpellName, requirement.id)
        if ok and type(name) == "string" then table.insert(candidates, name) end
    end
    local locale = GetLocale()
    local english = locale == "enUS" or locale == "enGB"
    if english then
        table.insert(candidates, requirement.english)
        for _, alias in ipairs(requirement.aliases or {}) do table.insert(candidates, alias) end
    end
    local expectedBank = requirement.pet and Enum.SpellBookSpellBank.Pet or Enum.SpellBookSpellBank.Player
    local function accept(slot, bank)
        if bank ~= expectedBank then return nil end
        local read, info = pcall(C_SpellBook.GetSpellBookItemInfo, slot, bank)
        if not read or not info or not info.spellID or info.isPassive or info.isOffSpec then return nil end
        local known, learned = pcall(C_SpellBook.IsSpellKnown, info.spellID, bank)
        if not known or not learned or type(info.name) ~= "string" then return nil end
        if not english or info.name == requirement.english then return info.name end
        for _, alias in ipairs(requirement.aliases or {}) do if info.name == alias then return info.name end end
    end
    for _, candidate in ipairs(candidates) do
        -- Explicitly exclude hidden, flyout, future, and off-spec entries.
        local ok, slot, bank = pcall(C_SpellBook.FindSpellBookSlotForSpell,
            candidate, false, false, false, false)
        if ok and slot and bank == expectedBank then
            local name = accept(slot, bank)
            if name then return name end
        end
    end
    -- FindSpellBookSlotForSpell can return a player's identically named spell first.
    if requirement.pet and C_SpellBook.HasPetSpells then
        local ok, count = pcall(C_SpellBook.HasPetSpells)
        if ok and type(count) == "number" then
            for slot = 1, math.min(count, 200) do
                local read, info = pcall(C_SpellBook.GetSpellBookItemInfo, slot, expectedBank)
                if read and info then
                    for _, candidate in ipairs(candidates) do
                        if candidate == info.spellID or candidate == info.name then
                            local name = accept(slot, expectedBank)
                            if name then return name end
                        end
                    end
                end
            end
        end
    end
end

local function environment()
    return {
        inCombat = InCombatLockdown, snapshot = snapshot, create = CreateMacro, edit = EditMacro,
        getInfo = GetMacroInfo, timestamp = GetServerTime,
        build = GetBuildInfo(),
    }
end

local function reportError(message)
    if lastError ~= message then say(message); lastError = message end
end

local function plan()
    if FM.AutoSequences then FM.AutoSequences.Refresh() end
    local state, reason = snapshot()
    if not state then return nil, reason end
    local _, class = UnitClass("player")
    if not class then return nil, "Character class is not ready." end
    return Core.Plan(db, class, state, resolve)
end

local function run(verbose)
    if not ready or not db then return end
    if not supported() then reportError("This version supports Forever 1.60.x only."); return end
    if fault or (FM.Manager and FM.Manager.fault) then
        if verbose then say("Creation is paused after an error. Use /fm retry after checking your macros.") end
        return
    end
    if not db.enabled then if verbose then say("Automatic additions are off. Use /fm on to enable them.") end; return end
    local constants, apiReason = checkAPI()
    if not constants then reportError(apiReason); return end
    if InCombatLockdown() then
        pendingCombat = true
        if verbose then say("Queued until combat ends.") end
        return
    end
    local ok, result = pcall(function()
        local steps, reason = plan()
        if not steps then return { created = 0, errors = { reason }, waitingForData = true } end
        applying = true
        return Core.Apply(db, steps, environment())
    end)
    applying = false
    if not ok then fault = true; reportError("An API error paused creation. Check /macro before /fm retry."); return end
    pendingCombat = result.deferred or false
    if result.waitingForData then
        readinessAttempts = readinessAttempts + 1
        reportError(result.errors[1] .. " Waiting for macro data; /fm install can retry.")
        if readinessAttempts < 3 then C_Timer.After(1, function() run(false) end) end
        return
    end
    readinessAttempts = 0
    if #result.errors > 0 then
        -- Do not keep writing if the API did not confirm the last creation.
        fault = true
        reportError(result.errors[1] .. " Check /macro, then use /fm retry.")
    elseif result.created > 0 then
        say("Added " .. result.created .. " character macros. Open /macro and drag the FM buttons to your bars.")
    elseif verbose then
        say("No macros added. /fm list explains each template's status.")
    end
    if result.blockedBySpace and result.blockedBySpace ~= lastSpaceWarning then
        say(result.blockedBySpace .. " learned starter macros need a free character slot. See /fm status and /fm list.")
    end
    lastSpaceWarning = result.blockedBySpace
    if FM.Manager then FM.Manager.SyncInstalled() end
end

local function schedule()
    if not ready or queued or applying or not db or not db.enabled or fault then return end
    queued = true
    C_Timer.After(0.5, function() queued = false; run(false) end)
end

local function showList()
    local constants, reason = checkAPI()
    if not constants then say(reason); return end
    if InCombatLockdown() then say("Preview is available after combat."); return end
    local ok, steps, reason = pcall(plan)
    if not ok or not steps then say(reason or "Preview is unavailable."); return end
    for _, item in ipairs(steps) do
        say(item.definition.id .. " | " .. item.definition.name .. " | " .. item.status)
    end
end

local function command(text)
    if not db then say("Character settings are not ready."); return end
    local verb, argument = text:match("^%s*(%S*)%s*(.-)%s*$")
    verb = verb:lower()
    if verb == "" or verb == "ui" then
        if FM.UI then FM.UI.Toggle() else say("The window is not available yet.") end
    elseif verb == "bags" then
        FM.Bags.Command(argument)
    elseif verb == "layout" then
        FM.Layout.Command(argument)
    elseif verb == "move" then
        FM.Layout.Move()
    elseif verb == "training" then
        FM.UI.tab = "Training"
        if FM.UI.frame and FM.UI.frame:IsShown() then FM.UI.Refresh() else FM.UI.Toggle() end
    elseif verb == "easy" or verb == "totems" then
        FM.UI.tab = "Macros"
        FM.UI.filter = "Sequences"
        FM.UI.page = 1
        if not FM.UI.frame or not FM.UI.frame:IsShown() then FM.UI.Toggle() end
        if FM.UI.search then FM.UI.search:SetText(verb == "easy" and "FM Easy" or "FM Totems") end
        FM.UI.Refresh()
    elseif verb == "coach" or verb == "talents" then
        if argument == "status" then say(FM.Advisor.NativeStatus()); return end
        if argument == "off" then FM.Advisor.Settings().hud=false; FM.CoachUI.RefreshHUD(); return end
        FM.UI.tab = "Coach"
        if FM.UI.frame and FM.UI.frame:IsShown() then FM.UI.Refresh() else FM.UI.Toggle() end
    elseif verb == "sequences" or verb == "builds" then
        FM.UI.tab = verb == "sequences" and "Sequences" or "Builds"
        if FM.UI.frame and FM.UI.frame:IsShown() then FM.UI.Refresh() else FM.UI.Toggle() end
    elseif verb == "check" then
        local report, reason = FM.Workshop.Audit()
        if report then for _, line in ipairs(report) do say(line) end else say(reason) end
    elseif verb == "update" then
        local ok, reason = FM.Manager.UpdateInstalled()
        if not ok then say(reason) end
    elseif verb == "status" then
        local state, reason = snapshot()
        local version, build, _, interface = GetBuildInfo()
        say("v" .. FM.Version .. " | client " .. tostring(version) .. "." .. tostring(build)
            .. " | interface " .. tostring(interface) .. " | " .. (db.enabled and "auto updates on" or "paused"))
        say(state and (state.characterCount .. "/" .. state.limit .. " character slots used; " .. db.reserve .. " reserved. /fm list shows missing skills and space limits.") or reason)
        say("Rankless spell names use the highest learned rank. Your personal edits are preserved.")
    elseif verb == "on" then db.enabled = true; say("Automatic additions enabled."); run(true)
    elseif verb == "off" then db.enabled = false; pendingCombat = false; say("Automatic additions disabled. Existing macros are unchanged.")
    elseif verb == "install" then run(true)
    elseif verb == "retry" then fault = false; lastError = nil; if FM.Manager then FM.Manager.fault = nil end; run(true)
    elseif verb == "list" then showList()
    elseif verb == "reserve" then
        local value = tonumber(argument)
        local constants = checkAPI()
        if not value or value < 0 or value ~= math.floor(value) or not constants
            or value > constants.MAX_CHARACTER_MACROS then
            say("Use /fm reserve NUMBER within the character slot limit."); return
        end
        db.reserve = value; say("Reserved slots: " .. value); schedule()
    elseif verb == "skip" or verb == "restore" then
        local definition = Core.FindDefinition(argument)
        if not definition and verb == "restore" and FM.Gear then
            definition = FM.Gear.Definition(argument)
            if argument == "equipment_set" and db.managed[argument] then definition = {class = "ALL"} end
        end
        local _, class = UnitClass("player")
        if not definition or (definition.class ~= "ALL" and definition.class ~= class) then
            say("Use a template ID for this class, or a saved gear preset ID."); return
        end
        if verb == "skip" then
            db.skipped[argument] = true
            db.wanted[argument] = nil
            say("Skipped " .. argument .. ". Any existing macro is unchanged.")
        else
            db.skipped[argument] = nil
            db.managed[argument] = nil
            say("Restored eligibility for " .. argument .. ". Existing macros remain unchanged.")
            schedule()
        end
    elseif verb == "show" then
        local constants, apiReason = checkAPI()
        if not constants then say(apiReason); return end
        if InCombatLockdown() then say("Preview is available after combat."); return end
        local definition = Core.FindDefinition(argument)
        local _, class = UnitClass("player")
        if not definition or (definition.class ~= "ALL" and definition.class ~= class) then
            say("Use a template ID for this class from /fm list."); return
        end
        local body, reason = Core.Render(definition, resolve)
        say(definition.description)
        if body then for line in body:gmatch("[^\n]+") do say(line) end else say(reason) end
    else
        say("/fm opens the window. Also: status, update, list, show ID, install, on, off, skip ID, restore ID, reserve NUMBER, retry")
        say("Creates character macros only. You choose action bars and press the buttons.")
    end
end

SLASH_FOREVERMACROS1 = "/fm"
SLASH_FOREVERMACROS2 = "/forevermacros"
SlashCmdList.FOREVERMACROS = command

for _, event in ipairs({
    "ADDON_LOADED", "PLAYER_ENTERING_WORLD", "SPELLS_CHANGED",
    "SPELL_TEXT_UPDATE", "PLAYER_REGEN_ENABLED", "UPDATE_MACROS", "UNIT_PET", "PLAYER_LEVEL_UP", "TRAIT_CONFIG_UPDATED",
}) do frame:RegisterEvent(event) end

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        local reason
        db, reason = Core.NewState(ForeverMacrosDB)
        if not db then reportError(reason); return end
        ForeverMacrosDB = db
        if FM.Workshop then FM.Workshop.Initialize() end
        if FM.Layout then FM.Layout.Prepare() end
    elseif event == "PLAYER_ENTERING_WORLD" then
        ready = true
        schedule()
    elseif event == "PLAYER_REGEN_ENABLED" then
        if pendingCombat then pendingCombat = false; schedule() end
    elseif event == "SPELLS_CHANGED" or event == "SPELL_TEXT_UPDATE" or event == "UPDATE_MACROS"
        or event == "PLAYER_LEVEL_UP" or event == "TRAIT_CONFIG_UPDATED" or (event == "UNIT_PET" and arg1 == "player") then
        schedule()
    end
end)

-- UI operations use the same validated snapshot and spellbook resolver.
FM.API = {State = function() return db end, Ready = function() return ready end,
    Supported = supported, Snapshot = snapshot, Resolve = resolve, Environment = environment,
    Say = say, Faulted = function() return fault end}
-- No macro execution, key binding changes, deletion, or action-bar placement.
