local _, FM = ...
FM.Version = "0.11.0"
local byID = {}
for _, d in ipairs(FM.Catalog) do byID[d.id] = d end
local enemy = "[mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead]"
local friend = "[mod:alt,@player][@mouseover,help,nodead][help,nodead][@player]"
local offTarget = "[mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]"
local function spell(id, name, pet) return {id = id, english = name, pet = pet} end
local function add(class, id, name, spells, body, description, policy, opts)
    opts = opts or {}
    assert(not byID[id], id)
    local d = {class = class, id = id, name = "FM " .. name, spells = spells, body = body,
        description = description, attackPolicy = policy or "No attack-start command",
        optional = not opts.auto, category = opts.category or "Utility", pvp = opts.pvp,
        formIDs = opts.forms, unitBody = opts.unitBody, priority = opts.auto and 5 or 20}
    byID[id] = d; table.insert(FM.Catalog, d)
    return d
end
local function cast(class, suffix, label, id, name, kind, opts)
    opts = opts or {}
    local cond = kind == "friend" and friend or kind == "enemy" and enemy or kind or ""
    local base = "#showtooltip {1}\n" .. (opts.prefix or "") .. "/cast "
    if kind == "friend" then opts.unitBody = base .. "[@{unit},help,nodead] {1}" end
    return add(class, class:lower() .. "_" .. suffix, label, {spell(id, name, opts.pet)}, base .. cond .. " {1}",
        opts.description or (kind == "friend" and "Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment."
        or kind == "enemy" and "Shift: focus. Otherwise hostile mouseover, then your target."
        or "Press to attempt " .. name .. ". Requires the learned ability."), opts.policy, opts)
end
local function melee(class, suffix, label, id, name, forms)
    local form = forms and "form:{form}," or ""
    local guard = (class == "ROGUE" or class == "DRUID") and "nostealth," or ""
    return add(class, class:lower() .. "_" .. suffix, label, {spell(id, name)},
        "#showtooltip {1}\n/startattack [" .. form .. guard .. "harm,nodead]\n/cast [" .. form .. "harm,nodead] {1}",
        "Current enemy only. Starts melee swings even when the spell cannot cast."
            .. (forms and " Requires the matching form; protects Prowl." or class == "ROGUE" and " Protects Stealth on failed casts." or ""),
        forms and "Melee in matching form, outside stealth" or "Melee on current enemy", {auto = true, category = "Attacks", forms = forms})
end
local function shot(suffix, label, id, name)
    add("HUNTER", "hunter_" .. suffix, label, {spell(id, name), spell(75, "Auto Shot")},
        "#showtooltip {1}\n/cast [harm,nodead] !{2}\n/cast [harm,nodead] {1}",
        "Current enemy only. Starts Auto Shot without toggling it off. Does not send your pet.",
        "Ranged Auto Shot on current enemy", {auto = true, category = "Attacks"})
end

-- Existing primary damage buttons are now automatic, with priority over utility.
for _, d in ipairs(FM.Catalog) do
    if d.body:find("/startattack", 1, true) or d.id == "hunter_arcane" or d.id == "hunter_serpent" then
        d.optional = false; d.category = "Attacks"; d.priority = 5; d.pvp = true
    elseif d.class == "ALL" then d.priority = 50 end
end

-- Preserve off-target utility without starting shots into a different selected enemy.
for _, id in ipairs({"hunter_concussive", "hunter_viper", "hunter_tranq"}) do
    local d = byID[id]
    d.spells[2] = spell(75, "Auto Shot")
    d.body = d.body .. "\n/stopmacro " .. offTarget .. "\n/cast [harm,nodead] !{2}"
    d.description = "Shift-focus, then hostile mouseover, then target. Only the target branch starts Auto Shot."
    d.attackPolicy = "Ranged Auto Shot on target branch only"
end
byID.hunter_raptor.body = byID.hunter_raptor.body:gsub("%] {1}", "] !{1}")
shot("aimed", "AimedShot", 19434, "Aimed Shot")
shot("multi", "MultiShot", 2643, "Multi-Shot")
shot("scorpid", "ScorpidSting", 3043, "Scorpid Sting")
shot("distracting", "DistractShot", 20736, "Distracting Shot")
shot("sniper", "SniperShot", nil, "Sniper Shot")
shot("summonhawk", "SummonHawk", nil, "Summon Hawk")
melee("HUNTER", "strider", "StriderKick", nil, "Strider Kick")
melee("HUNTER", "counterattack", "Counteratk", 19306, "Counterattack")
cast("HUNTER", "volley", "Volley", 1510, "Volley", "[@cursor]", {category = "Attacks", description = "Place Volley at the cursor. No Auto Shot to interrupt the channel."})
cast("HUNTER", "flare", "Flare", 1543, "Flare", "[@cursor]", {pvp = true})
cast("HUNTER", "immolation", "ImmoTrap", 13795, "Immolation Trap", "", {pvp = true})
cast("HUNTER", "explosive", "ExplodeTrap", 13813, "Explosive Trap", "", {pvp = true})
cast("HUNTER", "rapidfire", "RapidFire", 3045, "Rapid Fire", "")
cast("HUNTER", "bestial", "BestialWrath", 19574, "Bestial Wrath", "")
cast("HUNTER", "disengage", "Disengage", 781, "Disengage", "[harm,nodead]", {prefix = "/stopattack\n", policy = "Stop attacks", description = "Stop attacking and attempt the Classic threat-reduction ability on your enemy. This is not a backward leap."})
add("HUNTER", "hunter_fdtrap", "FeignTrap", {spell(1499, "Freezing Trap"), spell(5384, "Feign Death")},
    "#showtooltip\n/stopcasting\n/stopattack\n/petpassive\n/petfollow\n/cast [mod:alt] {2}; {1}",
    "Press for Freezing Trap. Alt: Feign Death. Separate choices; Forever traps can be placed in combat.", "Stop attacks and recall pet", {pvp = true})
add("HUNTER", "hunter_melee", "MeleeWeave", {spell(2973, "Raptor Strike"), spell(1495, "Mongoose Bite")},
    "#showtooltip {1}\n/stopcasting\n/startattack [harm,nodead]\n/cast [harm,nodead] !{1}\n/cast [harm,nodead] {2}",
    "Stop your cast and attempt Raptor Strike and Mongoose Bite. Cooldowns and the global cooldown still apply.", "Melee on current enemy", {category = "Attacks"})
add("HUNTER", "hunter_markshot", "MarkShot", {spell(1130, "Hunter's Mark"), spell(75, "Auto Shot")},
    "#showtooltip {1}\n/cast [harm,nodead] !{2}\n/cast [harm,nodead] {1}\n/petattack [harm,nodead]",
    "Mark your current enemy, start Auto Shot, and send your pet.", "Ranged Auto Shot and pet on current enemy", {category = "Attacks"})
for _, s in ipairs({{"hawk","Hawk",13165,"Aspect of the Hawk"},{"monkey","Monkey",13163,"Aspect of the Monkey"},
    {"cheetah","Cheetah",5118,"Aspect of the Cheetah"},{"pack","Pack",13159,"Aspect of the Pack"},
    {"wild","Wild",20043,"Aspect of the Wild"},{"beast","Beast",13161,"Aspect of the Beast"},
    {"trueshot","Trueshot",19506,"Trueshot Aura"}}) do
    local d = cast("HUNTER", s[1], s[2], s[3], s[4], "")
    d.body = d.body:gsub("/cast  {1}", "/cast !{1}")
end
for _, s in ipairs({{"beasts","TrackBeasts",1494,"Track Beasts"},{"humanoids","TrackHumans",19883,"Track Humanoids"},
    {"hidden","TrackHidden",19885,"Track Hidden"},{"undead","TrackUndead",19884,"Track Undead"},
    {"demons","TrackDemons",19878,"Track Demons"},{"elementals","TrackElem",19880,"Track Elementals"},
    {"giants","TrackGiants",19882,"Track Giants"},{"dragonkin","TrackDragons",19879,"Track Dragonkin"}}) do
    cast("HUNTER", "track_" .. s[1], s[2], s[3], s[4], "")
end
for _, s in ipairs({{"eyes","EyesBeast",1002,"Eyes of the Beast"},{"eagle","EagleEye",6197,"Eagle Eye"},
    {"tame","TameBeast",1515,"Tame Beast"},{"dismiss","DismissPet",2641,"Dismiss Pet"},
    {"feed","FeedPet",6991,"Feed Pet"},{"scare","ScareBeast",1513,"Scare Beast"}}) do
    cast("HUNTER", s[1], s[2], s[3], s[4], s[1] == "scare" and "enemy" or "", {
        prefix = s[1] == "scare" and "/stopattack\n/petpassive\n/petfollow\n" or nil,
        policy = s[1] == "scare" and "Stop attacks and recall pet" or nil,
        description = s[1] == "feed" and "Activate Feed Pet, then click suitable food in your bag." or nil})
end
for _, s in ipairs({{"dash","PetDash",1850,"Dash"},{"dive","PetDive",23145,"Dive"},
    {"charge","PetCharge",7371,"Charge"},{"growl","PetGrowl",2649,"Growl"},
    {"cower","PetCower",1742,"Cower"},{"bite","PetBite",17253,"Bite"},
    {"claw","PetClaw",16827,"Claw"},{"screech","PetScreech",24423,"Demoralizing Screech"},
    {"lightning","PetLightning",24844,"Lightning Breath"},{"sonic","PetSonic",false,"Sonic Blast"},
    {"prowl","PetProwl",24450,"Prowl"}}) do
    cast("HUNTER", "pet_" .. s[1], s[2], s[3] or nil, s[4],
        (s[1] == "dash" or s[1] == "dive" or s[1] == "prowl") and "" or "enemy", {pet = true, category = "Pet"})
end
byID.hunter_pet_screech.spells[1].aliases = {"Screech"}
for _, s in ipairs({{"swipe","PetSwipe","Swipe"},{"web","PetWeb","Web"},{"pinch","PetPinch","Pinch"},
    {"dismember","PetDismember","Dismember"},{"rend","PetRend","Savage Rend"},{"tendon","PetTendon","Tendon Rip"},
    {"dust","PetDust","Dust Cloud"},{"mine","PetDisarm","Mine!"},{"lava","PetLava","Lava Breath"},
    {"poison","PetPoison","Scorpid Poison"},{"stomp","PetStomp","Thunderstomp"}}) do
    cast("HUNTER","pet_" .. s[1],s[2],nil,s[3],"enemy",{pet=true,category="Pet"})
end
for _, s in ipairs({{"trickster","PetTrickster","Trickster's Dance"},{"howl","PetHowl","Furious Howl"},
    {"shell","PetShell","Shell Shield"}}) do
    cast("HUNTER","pet_" .. s[1],s[2],nil,s[3],"",{pet=true,category="Pet"})
end
add("HUNTER","hunter_burst","RapidTrinkets",{spell(3045,"Rapid Fire")},
    "#showtooltip {1}\n/use 13\n/use 14\n/cast {1}",
    "Attempt both equipped on-use trinkets and Rapid Fire. Shared cooldowns can prevent the second trinket.",nil,{pvp=true})
for _, s in ipairs({{"growl_on","GrowlOn","/petautocaston"},{"growl_off","GrowlOff","/petautocastoff"}}) do
    add("HUNTER", "hunter_" .. s[1], s[2], {spell(2649,"Growl",true)}, "#showtooltip {1}\n" .. s[3] .. " {1}",
        "Set Growl autocast for your current pet. Choose off when another player is tanking.", nil, {category = "Pet"})
end
for _, class in ipairs({"HUNTER", "WARLOCK"}) do
    add(class, class:lower() .. "_pet_stay", "PetStay", {}, "/petpassive\n/petstay", "Stop your pet and keep it at its current position.", nil, {category = "Pet"})
    add(class, class:lower() .. "_pet_aggressive", "PetAggressive", {}, "/petaggressive [pet]",
        "Set your active pet to Aggressive. It can attack nearby enemies without a target command. Choose this mode manually.",
        "Pet chooses nearby enemies after activation", {category = "Pet"})
end

add("WARRIOR", "warrior_spearing", "SpearStrike", {spell(nil, "Spearing Strike")},
    "#showtooltip {1}\n/startattack [form:{form},harm,nodead]\n/cast [form:{form},harm,nodead] {1}",
    "Current enemy only, in Battle Stance. Starts melee swings even when the ability cannot cast. No two-handed weapon requirement.",
    "Melee in Battle Stance on current enemy", {auto = true, category = "Attacks", forms = {2457}})
for _, s in ipairs({{"slam","Slam",1464,"Slam"},{"shieldslam","ShieldSlam",23922,"Shield Slam"},
    {"thunder","ThunderClap",6343,"Thunder Clap"},{"mocking","MockingBlow",694,"Mocking Blow"},
    {"concussion","ConcussBlow",12809,"Concussion Blow"}}) do melee("WARRIOR", unpack(s)) end
for _, s in ipairs({{"battle","BattleShout",6673,"Battle Shout"},{"demo","DemoShout",1160,"Demoralizing Shout"},
    {"bloodrage","Bloodrage",2687,"Bloodrage"},{"shieldblock","ShieldBlock",2565,"Shield Block"},
    {"retaliation","Retaliation",20230,"Retaliation"},{"reckless","Reckless",1719,"Recklessness"},
    {"laststand","LastStand",12975,"Last Stand"},{"sweeping","Sweeping",12328,"Sweeping Strikes"},
    {"piercing","PierceHowl",12323,"Piercing Howl"}}) do cast("WARRIOR", s[1],s[2],s[3],s[4],"") end
for _, s in ipairs({{"rupture","Rupture",1943,"Rupture"},{"riposte","Riposte",14251,"Riposte"},
    {"expose","ExposeArmor",8647,"Expose Armor"},{"slice","SliceDice",5171,"Slice and Dice"}}) do melee("ROGUE", unpack(s)) end
-- Forever talent IDs from the attributed October 8 tree snapshot, not Retail IDs.
melee("ROGUE","mutilate","Mutilate",1310707,"Mutilate")
melee("ROGUE","venom","Venom",1310703,"Venom")
melee("ROGUE","ghostly","GhostlyStrike",14278,"Ghostly Strike")
for _, s in ipairs({{"ambush","Ambush",8676,"Ambush"},{"garrote","Garrote",703,"Garrote"},
    {"pickpocket","PickPocket",921,"Pick Pocket"}}) do
    cast("ROGUE",s[1],s[2],s[3],s[4],"[stealth,harm,nodead]", {category = "Attacks", description = "Stealthed current enemy only. No auto attack before the opener."})
end
cast("ROGUE","feint","Feint",1966,"Feint","[harm,nodead]")
cast("ROGUE","bladeflurry","BladeFlurry",13877,"Blade Flurry","")
cast("ROGUE","adrenaline","Adrenaline",13750,"Adrenaline Rush","")
cast("ROGUE","preparation","Preparation",14185,"Preparation","")
for _, class in ipairs({"ROGUE", "WARRIOR"}) do
    for _, s in ipairs({{"throw","Throw",2764,"Throw"},{"bow","ShootBow",2480,"Shoot Bow"},
        {"gun","ShootGun",7918,"Shoot Gun"},{"crossbow","ShootXbow",7919,"Shoot Crossbow"}}) do
        cast(class,s[1],s[2],s[3],s[4],"[harm,nodead]", {category="Attacks", description="Pull your current enemy with the matching ranged weapon. Requires that weapon and its learned skill."})
    end
end

for _, s in ipairs({{"rake","Rake",1822,"Rake"},{"rip","Rip",1079,"Rip"},{"ferocious","FeroBite",22568,"Ferocious Bite"}}) do
    melee("DRUID",s[1],s[2],s[3],s[4],{768})
end
melee("DRUID","swipe","Swipe",779,"Swipe",{5487,9634})
melee("DRUID","primalbite","PrimalBite",nil,"Primal Bite",{5487,9634})
cast("DRUID", "shiftingpower", "ShiftingPower", nil, "Shifting Power", "[form:{form}]", {
    forms = {768}, description = "Use Shifting Power while already in Cat Form. Spends mana for energy. The game rejects it at full energy. Does not shift forms or start attacks."})
for _, s in ipairs({{"wrath","Wrath",5176,"Wrath"},{"starfire","Starfire",2912,"Starfire"},{"moonfire","Moonfire",8921,"Moonfire"}}) do
    cast("DRUID",s[1],s[2],s[3],s[4],"enemy",{category="Attacks"})
end
for _, s in ipairs({{"mark","MarkWild",1126,"Mark of the Wild"},{"thorns","Thorns",467,"Thorns"}}) do
    cast("DRUID",s[1],s[2],s[3],s[4],"friend")
end
cast("DRUID","regrowth_shift","ShiftRegrow",8936,"Regrowth","friend",{prefix="/cancelform\n",description="Leave animal form, then heal a friendly mouseover, target, or self. Costs the form and heal mana when shifting back."})
add("DRUID","druid_prowl","Prowl",{spell(5215,"Prowl")},
    "#showtooltip {1}\n/stopattack\n/cast [form:{form},nocombat,nostealth] !{1}",
    "Stop attacking and enter Prowl only while already in Cat Form outside combat. Repeated presses leave Prowl active. Does not shift forms.",
    "Stop attacks; enter stealth in Cat Form",{forms={768}})
cast("DRUID","dash","Dash",1850,"Dash","[form:{form}]",{forms={768},
    description="Use Dash while already in Cat Form. Does not shift forms, cancel Prowl, or start attacks."})
cast("DRUID","growl","Growl",6795,"Growl","enemy")
cast("DRUID","feralcharge","FeralCharge",16979,"Feral Charge","enemy")
cast("DRUID","tranquility","Tranquility",740,"Tranquility","[nochanneling]")
byID.druid_bear.spells[1].aliases = {"Dire Bear Form"}

melee("PALADIN","holystrike","HolyStrike",nil,"Holy Strike")
cast("PALADIN","consecration","Consecrate",26573,"Consecration","",{category="Attacks"})
cast("PALADIN","exorcism","Exorcism",879,"Exorcism","enemy",{category="Attacks"})
cast("PALADIN","wrath","HammerWrath",24275,"Hammer of Wrath","enemy",{category="Attacks"})
cast("PALADIN","holyshock","HolyShock",20473,"Holy Shock","friend")
cast("PALADIN","holyshock_enemy","ShockEnemy",20473,"Holy Shock","enemy",{category="Attacks"})
for _, id in ipairs({"paladin_exorcism","paladin_wrath","paladin_holyshock_enemy","warrior_taunt"}) do
    local d=byID[id]
    d.body=d.body .. "\n/stopmacro " .. offTarget .. "\n/startattack [harm,nodead]"
    d.description="Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings, including when the spell cannot cast."
    d.attackPolicy="Melee on target branch only"
    d.optional=false; d.category="Attacks"; d.priority=5
end
byID.paladin_consecration.body=byID.paladin_consecration.body .. "\n/startattack [harm,nodead]"
byID.paladin_consecration.description="Attempt Consecration at your feet. Also start melee swings at a living selected enemy, even if the spell cannot cast."
byID.paladin_consecration.attackPolicy="Melee on current enemy"
byID.paladin_consecration.optional=false; byID.paladin_consecration.priority=5
for _, s in ipairs({{"might","Might",19740,"Blessing of Might"},{"wisdom","Wisdom",19742,"Blessing of Wisdom"},
    {"kings","Kings",20217,"Blessing of Kings"}}) do
    -- Blessing of Light, Salvation and Sanctuary are no longer taught since the 30 Oct Paladin rebuild.
    cast("PALADIN",s[1],s[2],s[3],s[4],"friend")
end
for _, s in ipairs({{"sealright","SealRight",21084,"Seal of Righteousness"},{"sealcommand","SealCommand",20375,"Seal of Command"},
    {"sealwisdom","SealWisdom",20166,"Seal of Wisdom"},{"seallight","SealLight",20165,"Seal of Light"}}) do
    cast("PALADIN",s[1],s[2],s[3],s[4],"")
end

for _, s in ipairs({{"bolt","LightnBolt",403,"Lightning Bolt"},{"chainlight","ChainLightn",421,"Chain Lightning"},
    {"lavaburst","LavaBurst",false,"Lava Burst"}}) do
    local d = melee("SHAMAN",s[1],s[2],s[3] or nil,s[4])
    d.description = d.description .. " Intended for melee weaving; casting can delay swings."
end
cast("SHAMAN","riptide","Riptide",nil,"Riptide","friend")
cast("SHAMAN","farseer","FarSeer",nil,"Rage of the Far Seer","")
-- Forever renamed Elemental Mastery (16166) to Lightning Mastery; the macro keeps its name.
cast("SHAMAN","mastery","ElemMastery",16166,"Lightning Mastery","").spells[1].aliases = {"Elemental Mastery"}
cast("SHAMAN","swiftness","NatSwift",16188,"Nature's Swiftness","")
for _, s in ipairs({{"searing","Searing",3599,"Searing Totem"},{"magma","Magma",8190,"Magma Totem"},
    {"firenova","FireNova",1535,"Fire Nova"},{"manaspring","ManaSpring",5675,"Mana Spring Totem"},
    {"manatide","ManaTide",16190,"Mana Tide Totem"},{"healingstream","HealStream",5394,"Healing Stream Totem"},
    {"windfury","Windfury",8512,"Windfury Totem"},{"graceair","GraceAir",8835,"Grace of Air Totem"},
    {"strength","Strength",8075,"Strength of Earth Totem"},{"stoneclaw","Stoneclaw",5730,"Stoneclaw Totem"},
    {"poisonclean","PoisonClean",8166,"Poison Cleansing Totem"},{"diseaseclean","DiseaseClean",8170,"Disease Cleansing Totem"}}) do
    cast("SHAMAN",s[1],s[2],s[3],s[4],"")
end
-- Fire Nova is a spell in Forever, no longer a totem.
byID.shaman_firenova.spells[1].aliases = {"Fire Nova Totem"}

for _, class in ipairs({"MAGE", "PRIEST", "WARLOCK"}) do
    add(class,class:lower() .. "_wand","Wand",{spell(5019,"Shoot")},"#showtooltip {1}\n/cast [harm,nodead] !{1}",
        "Attempt wand shooting at your current enemy with !Shoot. Repeat-press behavior has an open Forever beta bug report; test it on your build. Use this separate button between spells.",
        "Ranged wand Shoot on current enemy",{auto=true,category="Attacks"})
end
for _, s in ipairs({{"fireball","Fireball",133,"Fireball"},{"scorch","Scorch",2948,"Scorch"}}) do
    cast("MAGE",s[1],s[2],s[3],s[4],"enemy",{category="Attacks"})
end
cast("MAGE","missiles","Missiles",5143,"Arcane Missiles","[nochanneling,harm,nodead]",{category="Attacks",description="Cast at your current enemy only when not channeling. Prevents early channel clipping."})
cast("MAGE","flamestrike","Flamestrike",2120,"Flamestrike","[@cursor]",{category="Attacks"})
cast("MAGE","explosion","ArcExplosion",1449,"Arcane Explosion","",{category="Attacks"})
cast("MAGE","cone","ConeCold",120,"Cone of Cold","",{category="Attacks"})
cast("MAGE","intellect","Intellect",1459,"Arcane Intellect","friend")
cast("MAGE","dampen","Dampen",604,"Dampen Magic","friend")
cast("MAGE","amplify","Amplify",1008,"Amplify Magic","friend")
cast("MAGE","evocation","Evocation",12051,"Evocation","[nochanneling]")
add("MAGE","mage_conjure","Conjure",{spell(5504,"Conjure Water"),spell(587,"Conjure Food")},
    "#showtooltip\n/cast [mod:shift] {2}; {1}","Conjure water. Hold Shift for food. Uses the highest learned rank.")

for _, s in ipairs({{"smite","Smite",585,"Smite"},{"holyfire","HolyFire",14914,"Holy Fire"},
    {"pain","ShadowPain",589,"Shadow Word: Pain"},{"mindblast","MindBlast",8092,"Mind Blast"},
    {"manaburn","ManaBurn",8129,"Mana Burn"}}) do cast("PRIEST",s[1],s[2],s[3],s[4],"enemy",{category="Attacks"}) end
cast("PRIEST","flay","MindFlay",15407,"Mind Flay","[nochanneling,harm,nodead]",{category="Attacks"})
cast("PRIEST","penance_heal","PenanceHeal",nil,"Penance","friend",{prefix="/stopmacro [channeling]\n",
    description="Heal with Penance. Alt: self, then friendly mouseover, target, self. Supports teammate assignment. Waits for any current channel to finish."})
cast("PRIEST","penance_harm","PenanceHarm",nil,"Penance","enemy",{prefix="/stopmacro [channeling]\n",category="Attacks",
    description="Damage with Penance. Shift: hostile focus, then hostile mouseover, target. Waits for any current channel to finish. Does not start melee or wand attacks."})
cast("PRIEST","greater","GreaterHeal",2060,"Greater Heal","friend")
cast("PRIEST","fortitude","Fortitude",1243,"Power Word: Fortitude","friend")
cast("PRIEST","spirit","DivineSpirit",14752,"Divine Spirit","friend")
cast("PRIEST","shadowprotect","ShadowProt",976,"Shadow Protection","friend")
cast("PRIEST","powerinfuse","PowerInfuse",10060,"Power Infusion","friend")
cast("PRIEST","shackle","Shackle",9484,"Shackle Undead","enemy",{prefix="/stopattack\n",policy="Stop attacks for crowd control"})
cast("PRIEST","fade","Fade",586,"Fade","")

for _, s in ipairs({{"shadowbolt","ShadowBolt",686,"Shadow Bolt"},{"immolate","Immolate",348,"Immolate"},
    {"searingpain","SearingPain",5676,"Searing Pain"},{"soulfire","SoulFire",6353,"Soul Fire"},
    {"shadowburn","Shadowburn",17877,"Shadowburn"},{"conflagrate","Conflagrate",17962,"Conflagrate"},
    {"elements","Elements",1490,"Curse of the Elements"},{"recklessness","RecklessCurse",704,"Curse of Recklessness"},
    {"weakness","Weakness",702,"Curse of Weakness"},{"doom","Doom",603,"Bane of Doom"}}) do cast("WARLOCK",s[1],s[2],s[3],s[4],"enemy",{category="Attacks"}) end
byID.warlock_doom.spells[1].aliases = {"Curse of Doom"}
for _, s in ipairs({{"drainlife","DrainLife",689,"Drain Life"},{"drainsoul","DrainSoul",1120,"Drain Soul"},
    {"drainmana","DrainMana",5138,"Drain Mana"}}) do cast("WARLOCK",s[1],s[2],s[3],s[4],"[nochanneling,harm,nodead]",{category="Attacks"}) end
cast("WARLOCK","rainfire","RainFire",5740,"Rain of Fire","[@cursor]",{category="Attacks"})
cast("WARLOCK","lifetap","LifeTap",1454,"Life Tap","")
cast("WARLOCK","sacrifice","PetSacrifice",7812,"Sacrifice","",{pet=true,category="Pet"})
cast("WARLOCK","soulstone","MakeSoulstone",693,"Create Soulstone","")
cast("WARLOCK","healthstone","MakeHealth",6201,"Create Healthstone","")
cast("WARLOCK","unending","UnendBreath",5697,"Unending Breath","friend")
cast("WARLOCK","detect","DetectInvis",132,"Detect Invisibility","friend")

-- Expose explicit cancellation rather than cancelling a fresh defensive on repeated presses.
for _, s in ipairs({{"MAGE","cancelblock","CancelBlock",45438,"Ice Block"},
    {"PALADIN","cancelbubble","CancelBubble",642,"Divine Shield"},
    {"ALL","cancelprotection","CancelBoP",1022,"Blessing of Protection"}}) do
    if s[1] ~= "ALL" then
        add(s[1],s[1]:lower() .. "_" .. s[2],s[3],{spell(s[4],s[5])},"#showtooltip {1}\n/cancelaura {1}",
            "Cancel your " .. s[5] .. " aura. This button does not cast it.",nil,{pvp=true})
    end
end
