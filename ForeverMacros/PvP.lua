local _, FM = ...
local friend = "[mod:alt,@player][@mouseover,help,nodead][help,nodead][@player]"
local enemy = "[mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead]"

-- Existing starter macros can be explicitly enrolled in teammate management.
for _, d in ipairs(FM.Catalog) do
    d.category = "Starter"
    d.pvp = d.id ~= "hunter_sequence" and d.id ~= "warrior_taunt"
    if d.body:find(friend, 1, true) then
        d.targetKind = "friendly"
        local start, finish = d.body:find(friend, 1, true)
        d.unitBody = d.body:sub(1, start - 1) .. "[@{unit},help,nodead]" .. d.body:sub(finish + 1)
    end
end

local function add(class, id, name, description, spells, body, unitBody)
    table.insert(FM.Catalog, {class = class, id = id, name = "FM " .. name,
        description = description, spells = spells or {}, body = body,
        category = "PvP", optional = true, unitBody = unitBody,
        targetKind = unitBody and "friendly" or nil})
end
local function cast(class, id, name, spellID, spellName, kind, prefix, pet)
    local conditions = kind == "friendly" and friend or kind == "enemy" and enemy or kind or ""
    local base = "#showtooltip {1}\n" .. (prefix or "") .. "/cast "
    local description = kind == "enemy" and "Shift: focus. Otherwise hostile mouseover, then target."
        or kind == "friendly" and "Friendly mouseover, target, or self. Alt: self. Can assign a teammate."
        or "Press to attempt " .. spellName .. ". Spell requirements still apply."
    add(class, id, name, description,
        {{id = spellID, english = spellName, pet = pet}}, base .. conditions .. " {1}",
        kind == "friendly" and base .. "[@{unit},help,nodead] {1}" or nil)
end

add("ALL", "ally_assist", "AllyAssist", "Assist a friendly mouseover or focus. Assign a teammate in the window.", nil,
    "/assist [@mouseover,help,nodead][@focus,help,nodead]", "/assist [@{unit},help,nodead]")
add("ALL", "trinket_top", "TrinketTop", "Use the equipped top trinket. This does not equip a different item.", nil, "#showtooltip\n/use 13")
add("ALL", "trinket_bottom", "TrinketBottom", "Use the equipped bottom trinket. This does not equip a different item.", nil, "#showtooltip\n/use 14")

cast("HUNTER", "hunter_scatter", "Scatter", 19503, "Scatter Shot", "enemy", "/stopcasting\n/stopattack\n/petpassive\n/petfollow\n")
cast("HUNTER", "hunter_wingclip", "WingClip", 2974, "Wing Clip", "enemy")
cast("HUNTER", "hunter_intimidation", "Intimidate", 19577, "Intimidation", "enemy")
cast("HUNTER", "hunter_deterrence", "Deterrence", 19263, "Deterrence", "", "/stopcasting\n")
cast("HUNTER", "hunter_freezing", "FreezeTrap", 1499, "Freezing Trap", "", "/stopattack\n")
cast("HUNTER", "hunter_frost", "FrostTrap", 13809, "Frost Trap", "")
cast("HUNTER", "hunter_viper", "ViperSting", 3034, "Viper Sting", "enemy")
cast("HUNTER", "hunter_tranq", "TranqShot", 19801, "Tranquilizing Shot", "enemy")

cast("WARRIOR", "warrior_intercept", "Intercept", 20252, "Intercept", "enemy")
cast("WARRIOR", "warrior_disarm", "Disarm", 676, "Disarm", "enemy")
cast("WARRIOR", "warrior_hamstring", "Hamstring", 1715, "Hamstring", "enemy")
cast("WARRIOR", "warrior_shieldbash", "ShieldBash", 72, "Shield Bash", "enemy")
cast("WARRIOR", "warrior_shieldwall", "ShieldWall", 871, "Shield Wall", "", "/stopcasting\n")
cast("WARRIOR", "warrior_berserker", "BerserkRage", 18499, "Berserker Rage", "")
cast("WARRIOR", "warrior_intimidate", "IntimShout", 5246, "Intimidating Shout", "[harm,nodead]")
cast("WARRIOR", "warrior_battle_stance", "BattleStance", 2457, "Battle Stance", "")
cast("WARRIOR", "warrior_def_stance", "DefStance", 71, "Defensive Stance", "")
cast("WARRIOR", "warrior_berserk_stance", "BersStance", 2458, "Berserker Stance", "")

cast("ROGUE", "rogue_gouge", "Gouge", 1776, "Gouge", "enemy", "/stopattack\n")
cast("ROGUE", "rogue_kidney", "Kidney", 408, "Kidney Shot", "enemy")
cast("ROGUE", "rogue_cheap", "CheapShot", 1833, "Cheap Shot", "enemy")
cast("ROGUE", "rogue_vanish", "Vanish", 1856, "Vanish", "", "/stopattack\n")
cast("ROGUE", "rogue_evasion", "Evasion", 5277, "Evasion", "")
cast("ROGUE", "rogue_sprint", "Sprint", 2983, "Sprint", "")
cast("ROGUE", "rogue_distract", "Distract", 1725, "Distract", "[@cursor]")

cast("MAGE", "mage_nova", "FrostNova", 122, "Frost Nova", "", "/stopcasting\n")
cast("MAGE", "mage_iceblock", "IceBlock", 45438, "Ice Block", "", "/stopcasting\n")
cast("MAGE", "mage_barrier", "IceBarrier", 11426, "Ice Barrier", "")
cast("MAGE", "mage_cold", "ColdSnap", 11958, "Cold Snap", "")
cast("MAGE", "mage_fireblast", "FireBlast", 2136, "Fire Blast", "enemy")
cast("MAGE", "mage_frostbolt", "Frostbolt", 116, "Frostbolt", "enemy")

cast("PRIEST", "priest_offdispel", "PurgeMagic", 527, "Dispel Magic", "enemy")
cast("PRIEST", "priest_cure", "CureDisease", 528, "Cure Disease", "friendly")
cast("PRIEST", "priest_abolish", "AbolDisease", 552, "Abolish Disease", "friendly")
cast("PRIEST", "priest_fear", "PsychScream", 8122, "Psychic Scream", "", "/stopcasting\n")
cast("PRIEST", "priest_silence", "Silence", 15487, "Silence", "enemy", "/stopcasting\n")
cast("PRIEST", "priest_mindcontrol", "MindControl", 605, "Mind Control", "enemy")

cast("DRUID", "druid_poison", "CurePoison", 8946, "Cure Poison", "friendly")
cast("DRUID", "druid_abolish", "AbolPoison", 2893, "Abolish Poison", "friendly")
cast("DRUID", "druid_bash", "Bash", 5211, "Bash", "enemy")
cast("DRUID", "druid_hibernate", "Hibernate", 2637, "Hibernate", "enemy")
cast("DRUID", "druid_barkskin", "Barkskin", 22812, "Barkskin", "")
cast("DRUID", "druid_swiftmend", "Swiftmend", 18562, "Swiftmend", "friendly")
cast("DRUID", "druid_innervate", "Innervate", 29166, "Innervate", "friendly")
cast("DRUID", "druid_bear", "BearForm", 5487, "Bear Form", "")
cast("DRUID", "druid_cat", "CatForm", 768, "Cat Form", "")
cast("DRUID", "druid_travel", "TravelForm", 783, "Travel Form", "")

cast("PALADIN", "paladin_protection", "Protection", 1022, "Blessing of Protection", "friendly")
cast("PALADIN", "paladin_sacrifice", "Sacrifice", 6940, "Blessing of Sacrifice", "friendly")
cast("PALADIN", "paladin_bubble", "DivineShield", 642, "Divine Shield", "", "/stopcasting\n")
cast("PALADIN", "paladin_layhands", "LayHands", 633, "Lay on Hands", "friendly")
cast("PALADIN", "paladin_repentance", "Repentance", 20066, "Repentance", "enemy")

cast("SHAMAN", "shaman_poison", "CurePoison", 526, "Cure Poison", "friendly")
cast("SHAMAN", "shaman_disease", "CureDisease", 2870, "Cure Disease", "friendly")
cast("SHAMAN", "shaman_frostshock", "FrostShock", 8056, "Frost Shock", "enemy")
cast("SHAMAN", "shaman_grounding", "Grounding", 8177, "Grounding Totem", "")
cast("SHAMAN", "shaman_tremor", "Tremor", 8143, "Tremor Totem", "")
cast("SHAMAN", "shaman_earthbind", "Earthbind", 2484, "Earthbind Totem", "")
cast("SHAMAN", "shaman_ghostwolf", "GhostWolf", 2645, "Ghost Wolf", "")

cast("WARLOCK", "warlock_deathcoil", "DeathCoil", 6789, "Death Coil", "enemy", "/stopcasting\n")
cast("WARLOCK", "warlock_howl", "HowlTerror", 5484, "Howl of Terror", "")
cast("WARLOCK", "warlock_tongues", "Tongues", 1714, "Curse of Tongues", "enemy")
cast("WARLOCK", "warlock_exhaustion", "Exhaustion", 18223, "Curse of Exhaustion", "enemy")
cast("WARLOCK", "warlock_spelllock", "SpellLock", 19244, "Spell Lock", "enemy", nil, true)
cast("WARLOCK", "warlock_seduction", "Seduction", 6358, "Seduction", "enemy", nil, true)
cast("WARLOCK", "warlock_devour_friend", "PetCleanse", 19505, "Devour Magic", "friendly", nil, true)
cast("WARLOCK", "warlock_devour_enemy", "PetPurge", 19505, "Devour Magic", "enemy", nil, true)

-- Racial abilities remain unavailable unless present in this character's spellbook.
cast("ALL", "racial_will", "WillForsaken", 7744, "Will of the Forsaken", "")
cast("ALL", "racial_escape", "EscapeArtist", 20589, "Escape Artist", "")
cast("ALL", "racial_stoneform", "Stoneform", 20594, "Stoneform", "")
cast("ALL", "racial_warstomp", "WarStomp", 20549, "War Stomp", "")
