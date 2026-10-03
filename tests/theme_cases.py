"""Character theme integration. The real WoW renderer is not exercised here."""
CASES = [
    ("All nine class themes select the player identity and available faction artwork", '''
TEST.login()
TEST.atlases = { ["charactercreate-icon-alliancebg"] = true, ["charactercreate-icon-hordebg"] = true }
TEST.command("")
local writes, edits = TEST.writes, TEST.edits
for _, class in ipairs({"WARRIOR", "MAGE", "ROGUE", "DRUID", "HUNTER", "SHAMAN", "PRIEST", "WARLOCK", "PALADIN"}) do
    TEST.class = class
    local classAtlas = "classicon-" .. string.lower(class)
    TEST.atlases[classAtlas] = true
    for _, faction in ipairs({"Alliance", "Horde"}) do
        TEST.faction = faction
        TEST.fire("UNIT_FACTION", "player")
        assert(FM.UI.themeClass == class and FM.UI.themeFaction == faction)
        assert(FM.UI.classIcon.atlas == classAtlas and FM.UI.classIcon:IsShown())
        assert(FM.UI.classWatermark.atlas == classAtlas)
        assert(FM.UI.classBackground.texture == "Interface\\\\AddOns\\\\ForeverMacros\\\\Art\\\\" .. string.lower(class) .. ".tga")
        assert(FM.UI.classBackground:IsShown() and not FM.UI.classWatermark:IsShown())
        assert(FM.UI.factionCrest.atlas == "charactercreate-icon-" .. string.lower(faction) .. "bg")
        assert(FM.UI.factionCrest:IsShown() and FM.UI.factionText:GetText() == faction)
        assert(FM.UI.identity:GetText():find(class, 1, true))
        assert(FM.UI.tabs.Macros.selected)
    end
end
assert(TEST.writes == writes and TEST.edits == edits, "Theme changes must not write macros")
'''),
    ("Missing atlases keep the class icon fallback and faction label usable", '''
TEST.faction = "Horde"
TEST.login(); TEST.command("")
assert(FM.UI.classIcon.texture:find("UI-CHARACTERCREATE-CLASSES", 1, true))
assert(FM.UI.classIcon.coords[1] == 0 and FM.UI.classIcon.coords[3] == 0.25)
assert(FM.UI.factionText:GetText() == "Horde" and not FM.UI.factionCrest:IsShown())
TEST.clickText("Equipment")
assert(FM.UI.tabs.Equipment.selected and not FM.UI.tabs.Macros.selected)
assert(FM.UI.panels.Equipment:IsShown())
TEST.clickText("Macros"); TEST.clickText("PvP")
assert(FM.UI.filters.PvP.selected and not FM.UI.filters.All.selected)
TEST.clickText("Close")
assert(not FM.UI.frame:IsShown())
TEST.faction = "Alliance"
TEST.command("")
assert(FM.UI.factionText:GetText() == "Alliance")
'''),
    ("Unknown player identity stays neutral and never shows a guessed faction", '''
TEST.login(); TEST.command("")
TEST.class = nil; TEST.faction = nil
FM.UI.Refresh()
assert(FM.UI.factionText:GetText() == "Azeroth")
assert(not FM.UI.classIcon:IsShown() and not FM.UI.classWatermark:IsShown())
assert(not FM.UI.classBackground:IsShown() and FM.UI.artPath == nil)
assert(not FM.UI.factionCrest:IsShown())
TEST.class = "HUNTER"; TEST.faction = "Neutral"
FM.UI.Refresh()
assert(FM.UI.classIcon:IsShown() and FM.UI.factionText:GetText() == "Azeroth")
'''),
    ("Faction refresh respects player events and retains character labels", '''
TEST.faction = "Alliance"; TEST.factionLabel = "The Alliance"
TEST.login(); TEST.command("")
assert(FM.UI.factionText:GetText() == "The Alliance")
TEST.faction = "Horde"; TEST.factionLabel = "The Horde"
TEST.fire("UNIT_FACTION", "target")
assert(FM.UI.themeFaction == "Alliance")
TEST.fire("UNIT_FACTION", "player")
assert(FM.UI.themeFaction == "Horde" and FM.UI.factionText:GetText() == "The Horde")
'''),
]
