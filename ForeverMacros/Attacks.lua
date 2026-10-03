local _, FM = ...
local byID = {}
for _, d in ipairs(FM.Catalog) do byID[d.id] = d end

-- Off-target utility keeps its cast priority without starting swings at the
-- selected enemy. StopMacro runs only after the cast line has been attempted.
local offTarget = "[mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]"
for _, id in ipairs({"shaman_shock", "shaman_frostshock", "warrior_charge", "warrior_pummel",
    "warrior_intercept", "warrior_disarm", "warrior_hamstring", "warrior_shieldbash",
    "rogue_kick", "rogue_kidney", "hunter_wingclip", "paladin_hammer"}) do
    local d = assert(byID[id])
    local stealth = d.class == "ROGUE" and "nostealth," or ""
    d.body = d.body .. "\n/stopmacro " .. offTarget .. "\n/startattack [" .. stealth .. "harm,nodead]"
    d.description = "Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings."
    d.attackPolicy = "Melee on target branch only"
end

local sinister = byID.rogue_sinister
sinister.body = sinister.body:gsub("/startattack %[harm,nodead%]", "/startattack [nostealth,harm,nodead]")
sinister.description = "Attempt Sinister Strike on your target. Start melee swings when not stealthed, even if energy is low."

for _, id in ipairs({"rogue_sap", "rogue_blind", "rogue_gouge", "mage_polymorph", "mage_nova", "druid_hibernate", "druid_roots", "warrior_intimidate",
    "paladin_repentance", "priest_fear", "warlock_fear", "warlock_howl", "warlock_seduction", "hunter_scatter"}) do
    local d = assert(byID[id])
    if not d.body:find("/stopattack", 1, true) then
        d.body = d.body:gsub("\n", "\n/stopattack\n", 1)
    end
    d.body = d.body .. "\n/stopattack"
    d.description = d.description .. " Stops your attacks for crowd control."
    d.attackPolicy = "Stop attacks for crowd control"
end
byID.hunter_freezing.body = byID.hunter_freezing.body:gsub("/stopattack\n", "/stopattack\n/petpassive\n/petfollow\n", 1)
byID.hunter_freezing.description = "Stop attacking and recall your pet in passive mode before attempting Freezing Trap."
byID.hunter_freezing.attackPolicy = "Stop attacks and recall pet"

local function melee(class, id, name, spellID, english, opts)
    opts = opts or {}
    local form = opts.forms and "form:{form}," or ""
    local stealth = (class == "ROGUE" or class == "DRUID") and "nostealth," or ""
    local d = {class = class, id = id, name = "FM " .. name, optional = true, category = "PvP",
        spells = {{id = spellID, english = english}}, formIDs = opts.forms,
        description = "Current enemy only. Starts melee swings even if the ability is unavailable."
            .. (opts.forms and " Requires the matching animal form; protects Prowl." or class == "ROGUE" and " Protects Stealth on a failed cast." or ""),
        body = "#showtooltip {1}\n/startattack [" .. form .. stealth .. "harm,nodead]\n/cast [" .. form .. "harm,nodead] " .. (opts.queued and "!" or "") .. "{1}",
        attackPolicy = opts.forms and "Melee in matching form, outside stealth" or "Melee on current enemy"}
    table.insert(FM.Catalog, d)
end

melee("SHAMAN", "shaman_flameshock", "FlameShock", 8050, "Flame Shock")
melee("SHAMAN", "shaman_stormstrike", "Stormstrike", 17364, "Stormstrike")
melee("WARRIOR", "warrior_heroic", "HeroicStrike", 78, "Heroic Strike", {queued = true})
melee("WARRIOR", "warrior_cleave", "Cleave", 845, "Cleave", {queued = true})
melee("WARRIOR", "warrior_execute", "Execute", 5308, "Execute")
melee("WARRIOR", "warrior_overpower", "Overpower", 7384, "Overpower")
melee("WARRIOR", "warrior_mortal", "MortalStrike", 12294, "Mortal Strike")
melee("WARRIOR", "warrior_bloodthirst", "Bloodthirst", 23881, "Bloodthirst")
melee("WARRIOR", "warrior_whirlwind", "Whirlwind", 1680, "Whirlwind")
melee("WARRIOR", "warrior_revenge", "Revenge", 6572, "Revenge")
melee("ROGUE", "rogue_backstab", "Backstab", 53, "Backstab")
melee("ROGUE", "rogue_eviscerate", "Eviscerate", 2098, "Eviscerate")
melee("ROGUE", "rogue_hemorrhage", "Hemorrhage", 16511, "Hemorrhage")
melee("DRUID", "druid_maul", "Maul", 680, "Maul", {queued = true, forms = {5487, 9634}})
melee("DRUID", "druid_claw", "Claw", 1082, "Claw", {forms = {768}})
melee("DRUID", "druid_shred", "Shred", 5221, "Shred", {forms = {768}})
melee("PALADIN", "paladin_judgement", "Judgement", 20271, "Judgement")
melee("HUNTER", "hunter_mongoose", "Mongoose", 1495, "Mongoose Bite")

for _, spec in ipairs({{"hunter_arcane", "ArcaneShot", 3044, "Arcane Shot"},
    {"hunter_serpent", "SerpentSting", 1978, "Serpent Sting"}}) do
    table.insert(FM.Catalog, {class = "HUNTER", id = spec[1], name = "FM " .. spec[2], optional = true,
        category = "PvP", spells = {{id = spec[3], english = spec[4]}, {id = 75, english = "Auto Shot"}},
        description = "Current enemy only. Starts ranged Auto Shot and attempts the shot. Does not send your pet.",
        body = "#showtooltip {1}\n/cast [harm,nodead] !{2}\n/cast [harm,nodead] {1}",
        attackPolicy = "Ranged Auto Shot on current enemy"})
end

-- Publish the decision for every template in the catalog and UI.
for _, d in ipairs(FM.Catalog) do
    if not d.attackPolicy then
        d.attackPolicy = d.body:find("/startattack", 1, true) and "Melee on current enemy"
            or (d.id == "hunter_auto" or d.id == "hunter_sequence") and "Ranged Auto Shot and pet on current enemy"
            or d.body:find("/stopattack", 1, true) and "Stop attacks"
            or d.body:find("/petattack", 1, true) and "Pet attack only"
            or "No attack-start command"
    end
end
