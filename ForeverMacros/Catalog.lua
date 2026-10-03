local _, FM = ...
FM.Catalog = {}

local function add(class, id, name, description, spells, body)
    table.insert(FM.Catalog, {
        class = class, id = id, name = "FM " .. name,
        description = description, spells = spells or {}, body = body,
    })
end

local function spell(id, english)
    return { id = id, english = english }
end

local friendly = "[mod:alt,@player][@mouseover,help,nodead][help,nodead][@player]"
local hostile = "[mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead]"
local deadFriend = "[@mouseover,help,dead][help,dead]"
local function cast(class, id, name, description, ability, conditions, prefix)
    add(class, id, name, description, {ability},
        "#showtooltip {1}\n" .. (prefix or "") .. "/cast " .. (conditions or "") .. " {1}")
end

-- Keep general utility small so class templates receive most available slots.
add("ALL", "stop", "Stop", "Stop your current cast and auto attack.", nil,
    "/stopcasting\n/stopattack")
add("ALL", "focus", "Focus", "Set focus to your living mouseover, otherwise target.", nil,
    "/focus [@mouseover,exists,nodead][@target,exists,nodead]")
add("ALL", "clear_focus", "ClearFocus", "Clear your focus.", nil, "/clearfocus")
add("ALL", "assist", "Assist", "Assist a living friendly focus.", nil,
    "/assist [@focus,help,nodead]")

for _, class in ipairs({"HUNTER", "WARLOCK"}) do
    add(class, class .. "_pet_attack", "PetAttack",
        "Send your pet to the living hostile mouseover, otherwise target.", nil,
        "/petattack [@mouseover,harm,nodead][harm,nodead]")
    add(class, class .. "_pet_follow", "PetFollow",
        "Set your pet passive and call it back. It stays passive afterward.", nil,
        "/petpassive\n/petfollow")
end

add("HUNTER", "hunter_mark", "MarkPet", "Mark and send your pet to the same chosen enemy.",
    {spell(1130, "Hunter's Mark")},
    "#showtooltip {1}\n/cast [@mouseover,harm,nodead][harm,nodead] {1}\n/petattack [@mouseover,harm,nodead][harm,nodead]")
add("HUNTER", "hunter_auto", "AutoShot", "Start Auto Shot and send your pet to your current enemy.",
    {spell(75, "Auto Shot")},
    "#showtooltip {1}\n/cast [harm,nodead] !{1}\n/petattack [harm,nodead]")
cast("HUNTER", "hunter_concussive", "Concuss", "Slow a hostile mouseover, target, or Shift-focus.",
    spell(5116, "Concussive Shot"), hostile)
cast("HUNTER", "hunter_mend", "MendPet", "Mend your living pet.",
    spell(136, "Mend Pet"), "[@pet,exists,nodead]")
cast("HUNTER", "hunter_revive", "RevivePet", "Revive your pet with the normal spell targeting rules.",
    spell(982, "Revive Pet"), "")
cast("HUNTER", "hunter_call", "CallPet", "Call your pet when none is present.",
    spell(883, "Call Pet"), "[nopet]")
cast("HUNTER", "hunter_raptor", "Raptor", "Start melee attacking and attempt Raptor Strike on your target.",
    spell(2973, "Raptor Strike"), "[harm,nodead]", "/startattack [harm,nodead]\n")
cast("HUNTER", "hunter_feign", "Feign", "Stop attacking, recall your pet in passive mode, then attempt Feign Death.",
    spell(5384, "Feign Death"), "", "/stopcasting\n/stopattack\n/petpassive\n/petfollow\n")

-- A native sequence advances only after a successful cast. Auto Shot and pet attack
-- remain independent of the Arcane Shot cooldown. No timer resets or fake spells.
add("HUNTER", "hunter_sequence", "HuntSeq",
    "Press repeatedly: Serpent Sting, then three Arcane Shots. Waits on cooldowns. Alt resets; use MarkPet separately.",
    {spell(75, "Auto Shot"), spell(1978, "Serpent Sting"), spell(3044, "Arcane Shot")},
    "#showtooltip\n/petattack [harm,nodead]\n/cast [harm,nodead] !{1}\n/castsequence [harm,nodead] reset=target/combat/alt {2}, {3}, {3}, {3}")

cast("WARRIOR", "warrior_charge", "Charge", "Charge your hostile mouseover, target, or Shift-focus if usable.",
    spell(100, "Charge"), hostile)
cast("WARRIOR", "warrior_taunt", "Taunt", "Taunt your hostile mouseover, target, or Shift-focus if usable.",
    spell(355, "Taunt"), hostile)
cast("WARRIOR", "warrior_pummel", "Pummel", "Attempt Pummel on a hostile mouseover, target, or Shift-focus.",
    spell(6552, "Pummel"), hostile)
cast("WARRIOR", "warrior_sunder", "Sunder", "Start melee attacking and attempt Sunder Armor.",
    spell(7386, "Sunder Armor"), "[harm,nodead]", "/startattack [harm,nodead]\n")
cast("WARRIOR", "warrior_rend", "Rend", "Start melee attacking and attempt Rend.",
    spell(772, "Rend"), "[harm,nodead]", "/startattack [harm,nodead]\n")

cast("ROGUE", "rogue_kick", "Kick", "Kick a hostile mouseover, target, or Shift-focus.",
    spell(1766, "Kick"), hostile)
cast("ROGUE", "rogue_blind", "Blind", "Blind a hostile mouseover, target, or Shift-focus.",
    spell(2094, "Blind"), hostile)
cast("ROGUE", "rogue_sap", "Sap", "Sap a hostile mouseover, target, or Shift-focus when usable.",
    spell(6770, "Sap"), hostile)
cast("ROGUE", "rogue_sinister", "Sinister", "Start melee attacking and attempt Sinister Strike.",
    spell(1752, "Sinister Strike"), "[harm,nodead]", "/startattack [harm,nodead]\n")
add("ROGUE", "rogue_stealth", "Stealth", "Enter Stealth without toggling it off on repeat presses.",
    {spell(1784, "Stealth")}, "#showtooltip {1}\n/cast !{1}")

cast("MAGE", "mage_counterspell", "Counter", "Interrupt your own cast and attempt Counterspell.",
    spell(2139, "Counterspell"), hostile, "/stopcasting\n")
cast("MAGE", "mage_polymorph", "Polymorph", "Polymorph a hostile mouseover, target, or Shift-focus.",
    spell(118, "Polymorph"), hostile)
cast("MAGE", "mage_decurse", "Decurse", "Remove Lesser Curse from mouseover, friendly target, or yourself.",
    spell(475, "Remove Lesser Curse"), friendly)
cast("MAGE", "mage_blink", "Blink", "Interrupt your own cast and attempt Blink.",
    spell(1953, "Blink"), "", "/stopcasting\n")
cast("MAGE", "mage_blizzard", "Blizzard", "Place Blizzard at the mouse cursor when the spell supports it.",
    spell(10, "Blizzard"), "[@cursor]")

cast("PRIEST", "priest_lesser", "LesserHeal", "Heal mouseover, friendly target, or yourself; Alt forces self.",
    spell(2050, "Lesser Heal"), friendly)
cast("PRIEST", "priest_heal", "Heal", "Heal mouseover, friendly target, or yourself; Alt forces self.",
    spell(2054, "Heal"), friendly)
cast("PRIEST", "priest_flash", "FlashHeal", "Flash Heal mouseover, friendly target, or yourself.",
    spell(2061, "Flash Heal"), friendly)
cast("PRIEST", "priest_shield", "Shield", "Shield mouseover, friendly target, or yourself.",
    spell(17, "Power Word: Shield"), friendly)
cast("PRIEST", "priest_renew", "Renew", "Renew mouseover, friendly target, or yourself.",
    spell(139, "Renew"), friendly)
cast("PRIEST", "priest_dispel", "Dispel", "Friendly Dispel Magic on mouseover, target, or yourself.",
    spell(527, "Dispel Magic"), friendly)
cast("PRIEST", "priest_res", "Resurrect", "Resurrect a dead friendly mouseover or target.",
    spell(2006, "Resurrection"), deadFriend)

cast("DRUID", "druid_rejuv", "Rejuvenate", "Rejuvenate mouseover, friendly target, or yourself.",
    spell(774, "Rejuvenation"), friendly)
cast("DRUID", "druid_regrowth", "Regrowth", "Regrowth mouseover, friendly target, or yourself.",
    spell(8936, "Regrowth"), friendly)
cast("DRUID", "druid_touch", "HealTouch", "Healing Touch on mouseover, friendly target, or yourself.",
    spell(5185, "Healing Touch"), friendly)
cast("DRUID", "druid_roots", "Roots", "Root a hostile mouseover, target, or Shift-focus.",
    spell(339, "Entangling Roots"), hostile)
cast("DRUID", "druid_decurse", "Decurse", "Remove Curse from mouseover, friendly target, or yourself.",
    spell(2782, "Remove Curse"), friendly)
cast("DRUID", "druid_rebirth", "Rebirth", "Rebirth a dead friendly mouseover or target when usable.",
    spell(20484, "Rebirth"), deadFriend)

cast("PALADIN", "paladin_holy", "HolyLight", "Holy Light on mouseover, friendly target, or yourself.",
    spell(635, "Holy Light"), friendly)
cast("PALADIN", "paladin_flash", "FlashLight", "Flash of Light on mouseover, friendly target, or yourself.",
    spell(19750, "Flash of Light"), friendly)
cast("PALADIN", "paladin_purify", "Purify", "Purify mouseover, friendly target, or yourself.",
    spell(1152, "Purify"), friendly)
cast("PALADIN", "paladin_cleanse", "Cleanse", "Cleanse mouseover, friendly target, or yourself.",
    spell(4987, "Cleanse"), friendly)
cast("PALADIN", "paladin_freedom", "Freedom", "Blessing of Freedom on mouseover, friendly target, or yourself.",
    spell(1044, "Blessing of Freedom"), friendly)
cast("PALADIN", "paladin_hammer", "Hammer", "Hammer of Justice on a hostile mouseover, target, or Shift-focus.",
    spell(853, "Hammer of Justice"), hostile)
cast("PALADIN", "paladin_res", "Redemption", "Redemption on a dead friendly mouseover or target.",
    spell(7328, "Redemption"), deadFriend)

cast("SHAMAN", "shaman_heal", "HealingWave", "Healing Wave on mouseover, friendly target, or yourself.",
    spell(331, "Healing Wave"), friendly)
cast("SHAMAN", "shaman_lesser", "LesserWave", "Lesser Healing Wave on mouseover, friendly target, or yourself.",
    spell(8004, "Lesser Healing Wave"), friendly)
cast("SHAMAN", "shaman_chain", "ChainHeal", "Chain Heal on mouseover, friendly target, or yourself.",
    spell(1064, "Chain Heal"), friendly)
cast("SHAMAN", "shaman_shock", "EarthShock", "Interrupt your own cast and attempt Earth Shock.",
    spell(8042, "Earth Shock"), hostile, "/stopcasting\n")
cast("SHAMAN", "shaman_purge", "Purge", "Purge a hostile mouseover, target, or Shift-focus.",
    spell(370, "Purge"), hostile)
cast("SHAMAN", "shaman_res", "Ancestral", "Ancestral Spirit on a dead friendly mouseover or target.",
    spell(2008, "Ancestral Spirit"), deadFriend)

cast("WARLOCK", "warlock_fear", "Fear", "Fear a hostile mouseover, target, or Shift-focus.",
    spell(5782, "Fear"), hostile)
cast("WARLOCK", "warlock_banish", "Banish", "Banish a hostile mouseover, target, or Shift-focus.",
    spell(710, "Banish"), hostile)
cast("WARLOCK", "warlock_corruption", "Corruption", "Corruption on a hostile mouseover, target, or Shift-focus.",
    spell(172, "Corruption"), hostile)
cast("WARLOCK", "warlock_agony", "Agony", "Curse of Agony on a hostile mouseover, target, or Shift-focus.",
    spell(980, "Curse of Agony"), hostile)
cast("WARLOCK", "warlock_funnel", "HealthFunnel", "Health Funnel to your living pet.",
    spell(755, "Health Funnel"), "[@pet,exists,nodead]")
