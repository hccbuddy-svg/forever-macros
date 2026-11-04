local _, FM = ...
local C = {}
FM.Coach = C
-- Original reference cards, not a simulated rotation or a cast sequence.
C.cards = {
    WARRIOR = {{"Rend","Mortal Strike","Slam"},{"Bloodthirst","Whirlwind","Execute"},{"Revenge","Thunder Clap","Sunder Armor"}},
    PALADIN = {{"Holy Shock","Holy Light","Flash of Light"},{"Consecration","Holy Shield","Judgement"},{"Seal of Command","Judgement","Consecration"}},
    HUNTER = {{"Summon Hawk","Aimed Shot","Serpent Sting"},{"Aimed Shot","Multi-Shot","Arcane Shot"},{"Raptor Strike","Wing Clip","Immolation Trap"}},
    ROGUE = {{"Mutilate","Slice and Dice","Eviscerate"},{"Sinister Strike","Blade Flurry","Slice and Dice"},{"Hemorrhage","Ambush","Eviscerate"}},
    PRIEST = {{"Penance","Power Word: Shield","Smite"},{"Flash Heal","Heal","Renew"},{"Shadow Word: Pain","Mind Blast","Mind Flay"}},
    SHAMAN = {{"Flame Shock","Lava Burst","Lightning Bolt"},{"Stormstrike","Flame Shock","Earth Shock"},{"Healing Wave","Lesser Healing Wave","Chain Heal"}},
    MAGE = {{"Arcane Missiles","Arcane Explosion","Fire Blast"},{"Fireball","Fire Blast","Scorch"},{"Frostbolt","Ice Lance","Frost Nova"}},
    WARLOCK = {{"Corruption","Bane of Agony","Drain Life"},{"Corruption","Shadow Bolt","Health Funnel"},{"Immolate","Conflagrate","Shadow Bolt"}},
    DRUID = {{"Moonfire","Wrath","Starfire"},{"Rake","Claw","Rip"},{"Rejuvenation","Regrowth","Healing Touch"}},
}
C.bear = {"Maul","Swipe","Demoralizing Roar"}
C.summary = {
    WARRIOR={tree=3,popular="Protection (52.6%)",advice="Method favors Protection for solo grinding and Arms with a two-handed weapon for supported group play.",date="2026-10-09"},
    PALADIN={tree=3,popular="Retribution (41%)",advice="Method starts with Holy damage talents, then Retribution for mana and movement. Reconsider the build around level 30 for your chosen role.",date="2026-09-24"},
    HUNTER={tree=1,popular="Survival (43.9%)",advice="Method favors Beast Mastery for solo leveling. The pet provides damage and keeps enemies away from you.",date="2026-10-09"},
    ROGUE={tree=2,popular="Subtlety (38.5%)",advice="Method offers Combat and Assassination. Weapon choice matters. Its current builds include respec decisions and optional Legacy points.",date="2026-10-09"},
    PRIEST={tree=1,popular="Discipline (42.7%)",advice="Method starts with wand support, suggests a Discipline respec for Penance at 30, then Shadow at 40. These are separate plans.",date="2026-10-04"},
    SHAMAN={tree=2,popular="Enhancement (60.5%)",advice="Method recommends Enhancement. Plan for Improved Ghost Wolf before level 20 and Stormstrike at 25.",date="2026-09-30"},
    MAGE={tree=3,popular="Frost (45.3%)",advice="Method favors Frost for control and ranged leveling. Its current beta plans include a version with extra Legacy points.",date="2026-10-09"},
    WARLOCK={tree=1,popular="Affliction (43.5%)",advice="Method prefers Affliction early. Demonology and Destruction have alternatives, with Demonology becoming stronger later.",date="2026-10-08"},
    DRUID={tree=2,popular="Feral Combat (45.4%)",advice="Method recommends Feral, using Bear early and Cat after the level 20 quest. Keep healing gear for group flexibility.",date="2026-09-29"},
}
for class,entry in pairs(C.summary) do
    entry.url = "https://www.method.gg/wow-forever/wow-forever-" .. class:lower() .. "-leveling-guide-and-talents"
end
function C.Tree()
    local class = FM.Advisor.Class()
    local s = FM.Advisor.Settings()
    return s and s.tree or C.summary[class] and C.summary[class].tree or 1
end
local bars = {
    {"ActionButton","ACTIONBUTTON"},{"MultiBarBottomLeftButton","MULTIACTIONBAR1BUTTON"},
    {"MultiBarBottomRightButton","MULTIACTIONBAR2BUTTON"},{"MultiBarRightButton","MULTIACTIONBAR3BUTTON"},
    {"MultiBarLeftButton","MULTIACTIONBAR4BUTTON"},{"MultiBar5Button","MULTIACTIONBAR5BUTTON"},
    {"MultiBar6Button","MULTIACTIONBAR6BUTTON"},{"MultiBar7Button","MULTIACTIONBAR7BUTTON"},
}
-- One bounded action-bar pass, only outside combat. No macro parsing guesses.
local function bindings()
    local map = {}
    if not GetActionInfo or not GetBindingKey then return map end
    for _,bar in ipairs(bars) do
        for i=1,12 do
            local b = _G[bar[1] .. i]
            if b and FM.Advisor.Public(b.action) and type(b.action)=="number" then
                local ok,kind,id=pcall(GetActionInfo,b.action)
                if ok and FM.Advisor.Public(kind) and FM.Advisor.Public(id) and type(id)=="number" then
                    local spell
                    if kind=="spell" then spell=id
                    elseif kind=="macro" and GetMacroSpell then spell=FM.Advisor.Call(GetMacroSpell,id) end
                    if type(spell)=="number" then
                        local name=C_Spell and FM.Advisor.Call(C_Spell.GetSpellName,spell)
                        local key=FM.Advisor.Call(GetBindingKey,bar[2] .. i)
                        if type(name)=="string" and type(key)=="string" and not map[name] then map[name]=key end
                    end
                end
            end
        end
    end
    return map
end
local requirements
local function requirement(class, name)
    if not requirements then
        requirements={}
        for _,d in ipairs(FM.Catalog) do
            requirements[d.class]=requirements[d.class] or {}
            for _,r in ipairs(d.spells) do requirements[d.class][r.english]=r end
        end
    end
    local r=requirements[class] and requirements[class][name]
    if r then return r end
    -- Talent-granted abilities have client-specific IDs in the attributed dataset.
    for _,tree in ipairs(FM.TalentData.classes[class].trees) do
        for _,talent in ipairs(tree.talents) do if talent.name==name then return {english=name,id=talent.spell} end end
    end
    return {english=name}
end
function C.ReadCards(class, tree, bear)
    if FM.InCombat() then return nil end
    local names=C.cards[class] and C.cards[class][tree]
    if not names then return {} end
    if class=="DRUID" and tree==2 and bear then names=C.bear end
    local current=class==FM.Advisor.Class()
    local keys=current and bindings() or {}
    local cards={}
    for _,name in ipairs(names) do
        local r=requirement(class,name)
        local learned=current and FM.Advisor.Call(FM.API.Resolve,r)
        local icon
        if C_Spell and C_Spell.GetSpellTexture then icon=FM.Advisor.Call(C_Spell.GetSpellTexture,learned or r.id or name) end
        if type(icon)~="number" and type(icon)~="string" then icon=134400 end
        cards[#cards+1]={name=learned or name,icon=icon,learned=type(learned)=="string",key=learned and keys[learned] or nil}
    end
    return cards
end
