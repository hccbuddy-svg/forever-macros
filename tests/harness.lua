TEST = {
    macros = {}, messages = {}, timers = {}, known = {}, names = {}, entries = {},
    class = "HUNTER", version = "1.60.1", combat = false, writes = 0, frames = {},
    failCreate = false, noReturn = false, corruptReturn = false, denied = 0,
}
Constants = {MacroConsts = {MAX_ACCOUNT_MACROS = 120, MAX_CHARACTER_MACROS = 30}}
Enum = {SpellBookSpellBank = {Player = 0, Pet = 1}}
SlashCmdList = {}
DEFAULT_CHAT_FRAME = {AddMessage = function(_, message) table.insert(TEST.messages, message) end}
TEST.time = 0
TEST.roster = {player = {name = "Tester", realm = "TestRealm"}}
TEST.inventory, TEST.bags, TEST.items, TEST.equipmentSets = {}, {}, {}, {}
-- Superset for catalog-wide rendering. Form-specific cases replace this list.
TEST.forms = {5487, 1066, 768, 783, 2457}
function GetNumShapeshiftForms() return #TEST.forms end
function GetShapeshiftFormInfo(index) return 123, false, true, TEST.forms[index] end
C_Timer = {After = function(delay, callback) table.insert(TEST.timers, {at = TEST.time + delay, run = callback}) end}
function GetTime() return TEST.time end
function CreateFrame(kind, name, parent)
    local frame = {events = {}, scripts = {}, shown = true, enabled = true, kind = kind, parent = parent}
    function frame:RegisterEvent(event) self.events[event] = true end
    function frame:SetScript(script, callback) self.scripts[script] = callback; if script == "OnEvent" then self.callback = callback end end
    function frame:SetText(value)
        self.value = value; if self.fontString then self.fontString:SetText(value) end
        if self.kind == "EditBox" and self.scripts.OnTextChanged then self.scripts.OnTextChanged(self) end
    end
    function frame:SetFontString(value) self.fontString = value end
    function frame:GetText() return self.value or "" end
    function frame:Show() local old=self.shown;self.shown=true;if not old and self.scripts.OnShow then self.scripts.OnShow(self) end end
    function frame:Hide() local old=self.shown;self.shown=false;if old and self.scripts.OnHide then self.scripts.OnHide(self) end end
    function frame:IsShown() return self.shown end
    -- Like the game: shown and every parent visible (a replacement bag addon
    -- keeps Blizzard's bags shown inside a hidden parent).
    function frame:IsVisible()
        if not self.shown then return false end
        local p = self.parent
        if type(p) == "table" and p.IsVisible then return p:IsVisible() end
        return true
    end
    function frame:Enable() self.enabled = true; if self.scripts.OnEnable then self.scripts.OnEnable(self) end end
    function frame:Disable() self.enabled = false; if self.scripts.OnDisable then self.scripts.OnDisable(self) end end
    function frame:IsEnabled() return self.enabled end
    function frame:GetWidth() return self.width or 1920 end
    function frame:GetHeight() return self.height or 1080 end
    function frame:SetSize(w, h) self.width = w; self.height = h end
    function frame:SetWidth(w) self.width = w end
    function frame:CreateFontString() return CreateFrame("FontString", nil, self) end
    function frame:CreateTexture() return CreateFrame("Texture", nil, self) end
    function frame:SetTexture(value) self.texture = value; return not TEST.missingTexture end
    function frame:SetAtlas(value) self.atlas = value end
    function frame:SetTexCoord(...) self.coords = {...} end
    function frame:SetVertexColor(...) self.color = {...} end
    function frame:SetAlpha(value) self.alpha = value end
    function frame:SetScrollChild(child) self.scrollChild = child end
    function frame:SetVerticalScroll(value) self.scroll = value end
    function frame:Click() if self.enabled and self.scripts.OnClick then self.scripts.OnClick(self) end end
    for _, method in ipairs({"SetPoint", "SetJustifyH", "SetJustifyV", "SetTextColor", "SetFont", "SetAutoFocus", "SetMaxLetters", "ClearFocus", "SetWordWrap",
        "SetFrameStrata", "SetClampedToScreen", "SetMovable", "EnableMouse", "RegisterForDrag", "StartMoving", "StopMovingOrSizing",
        "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor", "SetScale", "SetShadowOffset",
        "SetMultiLine", "SetFontObject", "SetFocus", "HighlightText", "ClearAllPoints"}) do frame[method] = function() end end
    function frame:HookScript(event,fn) local old=self.scripts[event];self.scripts[event]=function(...) if old then old(...) end;fn(...) end end
    function frame:SetParent(value) self.parent=value end
    function frame:GetParent() return self.parent end
    function frame:SetScale(value) self.scale=value end
    function frame:GetScale() return self.scale or 1 end
    function frame:SetHeight(value) self.height=value end
    function frame:EnableMouse(value) self.mouse=value end
    function frame:IsMouseEnabled() return self.mouse~=false end
    function frame:SetPoint(...) self.point={...} end
    function frame:ClearAllPoints() self.point=nil end
    function frame:GetNumPoints() return self.point and 1 or 0 end
    function frame:GetPoint() return unpack(self.point or {"CENTER", UIParent, "CENTER", 20, -160}) end
    function frame:SetFrameStrata(value) self.strata=value end
    if name then _G[name] = frame end
    table.insert(TEST.frames, frame)
    return frame
end
UIParent = CreateFrame("Frame")
function TEST.fire(event, ...)
    for _, frame in ipairs(TEST.frames) do
        if frame.events[event] then frame.callback(frame, event, ...) end
    end
end
function TEST.flush()
    local loops = 0
    while #TEST.timers > 0 do
        loops = loops + 1
        assert(loops < 20, "Unbounded event loop")
        local timers = TEST.timers
        TEST.timers = {}
        table.sort(timers, function(a, b) return a.at < b.at end)
        for _, timer in ipairs(timers) do TEST.time = math.max(TEST.time, timer.at); timer.run() end
    end
end
function TEST.advance(seconds)
    local target, loops = TEST.time + seconds, 0
    while true do
        loops = loops + 1; assert(loops < 100, "Unbounded timer loop")
        table.sort(TEST.timers, function(a, b) return a.at < b.at end)
        if not TEST.timers[1] or TEST.timers[1].at > target then break end
        local timer = table.remove(TEST.timers, 1); TEST.time = timer.at; timer.run()
    end
    TEST.time = target
end
function GetBuildInfo() return TEST.version, "70338", "Oct 9 2026", 16001 end
function GetServerTime() return 100000 end
function UnitClass() return TEST.class, TEST.class end
function UnitFactionGroup() return TEST.faction, TEST.factionLabel or TEST.faction end
C_Texture = {GetAtlasInfo = function(name) return TEST.atlases and TEST.atlases[name] end}
function GetLocale() return TEST.locale or "enUS" end
function InCombatLockdown() return TEST.combat end
function GetNumMacros()
    if TEST.badCounts then return 1, 1 end
    local account, character = 0, 0
    for _, macro in ipairs(TEST.macros) do
        if macro.character then character = character + 1 else account = account + 1 end
    end
    return account, character
end
function TEST.lookup(index)
    local character = index > Constants.MacroConsts.MAX_ACCOUNT_MACROS
    local slot = character and index - Constants.MacroConsts.MAX_ACCOUNT_MACROS or index
    local matches = {}
    for _, macro in ipairs(TEST.macros) do
        if macro.character == character then table.insert(matches, macro) end
    end
    table.sort(matches, function(a, b) return a.name < b.name end)
    return matches[slot]
end
function GetMacroInfo(index)
    local macro = TEST.lookup(index)
    if macro then return macro.name, macro.icon or 134400, macro.body end
end
function TEST.named(name)
    for _, macro in ipairs(TEST.macros) do if macro.name == name then return macro end end
end
function TEST.seed(name, body, character)
    table.insert(TEST.macros, {name = name, body = body, character = character == true})
end
function CreateMacro(name, icon, body, character)
    assert(not TEST.combat, "Attempted combat write")
    assert(character == true, "Attempted account macro write")
    assert(#name <= 16 and #body <= 255, "Macro too long")
    local _, count = GetNumMacros()
    assert(count < Constants.MacroConsts.MAX_CHARACTER_MACROS, "Slot overflow")
    if TEST.failCreate then error("Simulated denied creation") end
    TEST.writes = TEST.writes + 1
    TEST.seed(name, body, character)
    TEST.fire("UPDATE_MACROS")
    if TEST.noReturn then return nil end
    if TEST.corruptReturn then return 1 end
    for index = Constants.MacroConsts.MAX_ACCOUNT_MACROS + 1,
        Constants.MacroConsts.MAX_ACCOUNT_MACROS + Constants.MacroConsts.MAX_CHARACTER_MACROS do
        local found = TEST.lookup(index)
        if found and found.name == name then return index end
    end
end
function EditMacro(index, name, icon, body)
    assert(not TEST.combat, "Attempted combat edit")
    local macro = assert(TEST.lookup(index), "Missing macro")
    assert(macro.character, "Attempted account edit")
    assert(name == nil and icon == nil, "Must preserve macro name and icon")
    if TEST.failEdit then error("Simulated edit failure") end
    macro.body = body; TEST.edits = (TEST.edits or 0) + 1
    TEST.fire("UPDATE_MACROS")
    if TEST.badEditReturn then return 1 end
    return index
end
function DeleteMacro() TEST.denied = TEST.denied + 1; error("Must never delete") end
function SetBinding() TEST.denied = TEST.denied + 1; error("Must never bind") end
function RunMacroText() TEST.denied = TEST.denied + 1; error("Must never execute") end
C_Spell = {GetSpellName = function(id) return TEST.names[id] end}
C_SpellBook = {}
function C_SpellBook.FindSpellBookSlotForSpell(candidate, hidden, flyouts, future, offspec)
    assert(hidden == false and flyouts == false and future == false and offspec == false)
    for id, entry in pairs(TEST.entries) do
        if candidate == id or candidate == entry.name then return id, entry.bank or 0 end
    end
end
function C_SpellBook.GetSpellBookItemInfo(id) return TEST.entries[id] end
function C_SpellBook.IsSpellKnown(id) return TEST.known[id] == true end
function TEST.learn(id, name, overrides)
    TEST.known[id] = true
    TEST.names[id] = name
    local entry = {spellID = id, name = name, isPassive = false, isOffSpec = false}
    for key, value in pairs(overrides or {}) do entry[key] = value end
    TEST.entries[id] = entry
end
function TEST.learnAll(class)
    local synthetic = 8000000
    for _, definition in ipairs(FM.Catalog) do
        if definition.class == class then
            for _, spell in ipairs(definition.spells) do
                synthetic = synthetic + 1
                TEST.learn(spell.id or synthetic, spell.english, {bank = spell.pet and 1 or 0})
            end
        end
    end
end
function TEST.login()
    TEST.fire("ADDON_LOADED", "ForeverMacros")
    TEST.fire("PLAYER_ENTERING_WORLD", true, false)
    TEST.flush()
end
function TEST.command(text) SlashCmdList.FOREVERMACROS(text); TEST.flush() end

function UnitExists(unit) return TEST.roster[unit] ~= nil end
function UnitName(unit) local value = TEST.roster[unit]; if value then return value.name, value.realm end end
UnitFullName = UnitName
function IsInRaid() return TEST.raid == true end
function GetInventoryItemID(_, slot) return TEST.inventory[slot] end
C_Item = {}
function C_Item.GetItemInfo(id) return TEST.items[id] and TEST.items[id].name end
function C_Item.GetItemInfoInstant(id) return id, nil, nil, TEST.items[id] and TEST.items[id].location end
function C_Item.RequestLoadItemDataByID() end
C_Container = {
    GetContainerNumSlots = function(bag) return #(TEST.bags[bag] or {}) end,
    GetContainerItemID = function(bag, slot) return (TEST.bags[bag] or {})[slot] end,
}
C_EquipmentSet = {
    GetEquipmentSetIDs = function() local list = {}; for id in pairs(TEST.equipmentSets) do list[#list + 1] = id end; return list end,
    GetEquipmentSetInfo = function(id) return TEST.equipmentSets[id] end,
}
function issecretvalue(v) return type(v) == "table" and v.secret == true end
TEST.dbmCallbacks = {}
DBM = {RegisterCallback = function(_, event, callback) TEST.dbmCallbacks[event] = callback end}
function TEST.dbm(event, ...) if TEST.dbmCallbacks[event] then TEST.dbmCallbacks[event](event, ...) end end
function TEST.member(unit, name, realm) TEST.roster[unit] = {name = name, realm = realm or "TestRealm"} end
function TEST.clickText(value)
    for _, frame in ipairs(TEST.frames) do
        if frame.kind == "Button" and frame:GetText() == value then frame:Click(); return true end
    end
    error("Button not found: " .. value)
end
