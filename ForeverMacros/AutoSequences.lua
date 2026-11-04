local _, FM = ...
local S = {definitions = {}}
FM.AutoSequences = S
local function spell(id, english) return {id=id, english=english} end
local function one(id, name) return {spell(id,name)} end
-- Original, bounded solo starter recipes. No cooldown, aura or resource reads.
S.recipes = {
 WARRIOR={open={steps={one(772,"Rend"),one(7386,"Sunder Armor")},melee=true,note="Melee opener. Build rage and use a compatible stance first."},
     prep={steps={one(6673,"Battle Shout")},note="Self preparation. Battle Shout needs rage."}},
 PALADIN={open={steps={one(21084,"Seal of Righteousness"),one(20271,"Judgement")},melee=true,required=spell(21084,"Seal of Righteousness"),note="Seal then judge on a living enemy. Forever Judgement does not consume the seal."},
     prep={steps={one(19740,"Blessing of Might"),one(465,"Devotion Aura")},note="Solo melee preparation. Other blessings or auras may suit your group better."}},
 HUNTER={open={steps={one(1978,"Serpent Sting"),one(3044,"Arcane Shot")},shot=true,note="Ranged opener. Auto Shot starts if learned; send your pet separately."},
     prep={steps={one(13165,"Aspect of the Hawk")},note="Ranged preparation. Change aspect manually for travel or melee."}},
 ROGUE={open={steps={one(1752,"Sinister Strike"),one(5171,"Slice and Dice")},melee=true,nostealth=true,note="Begin outside stealth: build one combo point, then Slice and Dice. Open from stealth separately."},
     prep={steps={one(1784,"Stealth")},note="Enter stealth before a pull. This does not select a stealth opener."}},
 PRIEST={open={steps={{spell(14914,"Holy Fire"),spell(585,"Smite")},one(589,"Shadow Word: Pain")},caster=true,note="Caster opener before wand or filler attacks. Use shadow attacks separately in Shadowform."},
     prep={steps={one(1243,"Power Word: Fortitude"),one(588,"Inner Fire")},note="Self preparation outside combat."}},
 SHAMAN={open={steps={one(403,"Lightning Bolt"),{spell(8050,"Flame Shock"),spell(8042,"Earth Shock")}},melee=true,note="Pull with Lightning Bolt, then the learned shock. Starts melee swings when in reach. Keep interrupts separate."},
     prep={steps={one(324,"Lightning Shield")},note="Solo preparation. Choose other shields manually when appropriate."}},
 MAGE={open={steps={{spell(116,"Frostbolt"),spell(133,"Fireball")}},note="Ranged solo pull using the learned slow when available. Continue with your chosen filler afterward."},
     prep={steps={one(1459,"Arcane Intellect"),{spell(7302,"Ice Armor"),spell(168,"Frost Armor")}},note="Solo preparation. Uses Ice Armor when learned; choose Mage Armor separately if preferred."}},
 WARLOCK={open={steps={one(172,"Corruption"),one(348,"Immolate"),one(686,"Shadow Bolt")},note="Short solo damage opener. Send your pet separately; then use filler, wand or drains manually."},
     prep={steps={{spell(706,"Demon Armor"),spell(687,"Demon Skin")},one(5697,"Unending Breath")},note="Self preparation. Uses the learned armor upgrade."}},
 DRUID={open={steps={one(5176,"Wrath"),one(8921,"Moonfire")},caster=true,note="Caster-form ranged opener. Change form manually afterward."},
     prep={steps={one(1126,"Mark of the Wild"),one(467,"Thorns")},caster=true,note="Self preparation outside combat in caster form."},
     cat={steps={one(1822,"Rake"),one(1082,"Claw")},forms={768},melee=true,nostealth=true,note="Cat opener outside Prowl. Use stealth openers and combo-point finishers separately."},
     bear={steps={one(99,"Demoralizing Roar"),one(779,"Swipe")},forms={5487,9634},melee=true,note="Bear multi-target opener. Swipe can hit nearby enemies; use only when that is intended.",optional=true}},
}
for _,class in ipairs({"SHAMAN","PRIEST","PALADIN","HUNTER"}) do S.recipes[class].easy={} end
S.recipes.SHAMAN.totems={}; S.recipes.SHAMAN.recall={}
local labels={easy="Easy",totems="Totems",recall="Recall",open="AutoOpen",prep="AutoPrep",cat="AutoCat",bear="AutoBear"}
local classes={"WARRIOR","PALADIN","HUNTER","ROGUE","PRIEST","SHAMAN","MAGE","WARLOCK","DRUID"}
local kinds={"easy","totems","recall","open","prep","cat","bear"}
local function compact(d, resolve)
    d.spells={}; d.blocked=nil
    local function learned(id, name)
        local s=spell(id,name)
        if not resolve(s) then return nil end
        d.spells[#d.spells+1]=s
        return "{"..#d.spells.."}"
    end
    local function append(list, value) if value then list[#list+1]=value end end
    local lines={"#showtooltip","/stopmacro [channeling]"}
    local cycle={}
    local function once(token, self)
        if token then lines[#lines+1]="/castsequence "..(self and "[@player] " or "")
            .."reset=target/combat/alt "..token..",null" end
    end
    if d.kind=="totems" then
        local call=learned(66842,"Call of the Elements")
        if call then
            lines[#lines+1]="/cast "..call
            d.description="Drops your saved Call of the Elements set with one cast. Configure that set in the game's totem bar first. Press only when you want to spend mana on that set; it is separate from FM Easy."
        else
            append(cycle,learned(3599,"Searing Totem")); append(cycle,learned(8075,"Strength of Earth Totem"))
            if #cycle==0 then d.blocked="Learn a supported totem first." end
            cycle[#cycle+1]="null"
            lines[#lines+1]="/castsequence reset=10/alt "..table.concat(cycle,",")
            d.description="Places learned Searing and Strength of Earth totems, one per successful press, then stops. Wait 10 seconds without pressing or hold Alt to restart. Searing can attack nearby enemies. Upgrades to your saved Call of the Elements set when learned."
        end
    elseif d.kind=="recall" then
        local recall=learned(36936,"Totemic Recall")
        if recall then lines[#lines+1]="/cast "..recall else d.blocked="Learn Totemic Recall first." end
        d.description="Recall your totems on a deliberate keypress. Never recalled automatically during a pull."
    else
        lines[2]="/stopmacro [channeling][noharm][dead]"
        local guard=""
        if d.class=="SHAMAN" then
            once(learned(324,"Lightning Shield"),true)
            lines[#lines+1]="/startattack"
            append(cycle,learned(8050,"Flame Shock")); append(cycle,learned(17364,"Stormstrike"))
            append(cycle,learned(8042,"Earth Shock"))
            if #cycle==0 then append(cycle,learned(403,"Lightning Bolt")) end
            d.description="Shield once per target, melee, then learned Flame Shock, Stormstrike and Earth Shock. Earlier fallback: Lightning Bolt. Refreshing an active shield spends mana. Totems and weapon imbues stay separate."
        elseif d.class=="PRIEST" then
            once(learned(17,"Power Word: Shield"),true)
            local filler=learned(15407,"Mind Flay")
            local main
            if filler then main=learned(8092,"Mind Blast")
            else
                filler=learned(585,"Smite")
                main=learned(nil,"Penance") or learned(8092,"Mind Blast")
                guard="[noform] "
            end
            append(cycle,main); append(cycle,learned(589,"Shadow Word: Pain"))
            for i=1,4 do append(cycle,filler) end
            d.description="Self shield once per target, then Penance/Mind Blast, Pain and four Smites. Learning Mind Flay switches to shadow spells. Channels protected; use a separate wand key to conserve mana."
        elseif d.class=="PALADIN" then
            once(learned(21084,"Seal of Righteousness"),true)
            lines[#lines+1]="/startattack"
            local judge=learned(20271,"Judgement")
            local strike=learned(nil,"Holy Strike")
            if judge then lines[#lines+1]="/cast "..judge end
            if strike then lines[#lines+1]="/cast "..strike end
            d.description="Righteousness once per target, melee, then Judgement and Holy Strike. Off-GCD Judgement preserves the seal. Buff with FM AutoPrep. Reset after manually changing your seal."
        elseif d.class=="HUNTER" then
            lines[#lines+1]="/petattack"
            local shot=learned(75,"Auto Shot")
            if shot then lines[#lines+1]="/cast !"..shot end
            append(cycle,learned(1978,"Serpent Sting"))
            local hawk=learned(nil,"Summon Hawk")
            local arcane=learned(3044,"Arcane Shot")
            for i=1,(hawk and 2 or 3) do append(cycle,hawk or arcane) end
            if hawk then append(cycle,arcane) end
            d.description="Pet + Auto Shot. Cycle Sting and three Arcanes; with Summon Hawk, Sting, two Hawks, Arcane. Shared cooldowns pause casting. Aspect, Mend Pet and Aimed Shot stay separate."
        end
        if #cycle>0 then lines[#lines+1]="/castsequence "..guard.."reset=target/combat/alt "..table.concat(cycle,",") end
        if #cycle==0 and d.class~="PALADIN" and d.class~="HUNTER" then d.blocked="Learn a supported damage spell first." end
        if #d.spells==0 then d.blocked="Learn a supported leveling ability first." end
        d.description=d.description.." Repeat presses. Target/combat end/Alt resets. Mana, range or cooldowns may pause a step. Fixed routine."
    end
    d.body=table.concat(lines,"\n")
end
local function build(d, recipe, resolve)
    if d.kind=="easy" or d.kind=="totems" or d.kind=="recall" then compact(d,resolve); return end
    d.spells={}; d.blocked=nil
    local names={}
    if recipe.required and not resolve(recipe.required) then d.blocked="Learn "..recipe.required.english.." first." end
    for _, choices in ipairs(recipe.steps) do
        for _, candidate in ipairs(choices) do
            if resolve(candidate) then
                local last=d.spells[#d.spells]
                if not last or last.id~=candidate.id then
                    d.spells[#d.spells+1]=candidate; names[#names+1]="{"..#d.spells.."}"
                end
                break
            end
        end
    end
    if #names==0 then d.blocked="No supported sequence abilities learned yet." end
    local guard=(recipe.forms and "form:{form}," or recipe.caster and "noform," or "")
        ..(recipe.nostealth and "nostealth," or "")
    local lines={"#showtooltip", "/stopmacro [channeling]"}
    if d.kind=="prep" then lines[#lines+1]="/stopmacro [combat]" end
    if recipe.melee then lines[#lines+1]="/startattack ["..guard.."harm,nodead]" end
    if recipe.shot and resolve(spell(75,"Auto Shot")) then
        d.spells[#d.spells+1]=spell(75,"Auto Shot")
        lines[#lines+1]="/cast [harm,nodead] !{"..#d.spells.."}"
    end
    -- The terminal null stops replaying damage-over-time effects on extra presses.
    names[#names+1]="null"
    lines[#lines+1]="/castsequence ["..guard..(d.kind=="prep" and "@player" or "harm,nodead").."] reset="
        ..(d.kind=="prep" and "10/alt" or "target/combat/alt").." "..table.concat(names,",")
    d.body=table.concat(lines,"\n")
    d.description=recipe.note.." Learned steps only. One press per cast; stops at the end. Alt resets. "
        ..(d.kind=="prep" and "Ten seconds without pressing also resets. " or "Changing target or leaving combat also resets. ").."A fixed starter, not a live optimal rotation."
end
for _,class in ipairs(classes) do
    for _,kind in ipairs(kinds) do
        local recipe=S.recipes[class][kind]
        if recipe then
            local d={id="auto_"..class:lower().."_"..kind,class=class,kind=kind,name="FM "..labels[kind],
                priority=(kind=="easy" or kind=="totems" or kind=="recall") and 1 or 2,category="Sequences",autoSequence=true,sequenceNames=true,formIDs=recipe.forms,
                optional=recipe.optional==true,attackPolicy=recipe.melee and "Melee on current enemy with form and stealth guards"
                    or recipe.shot and "Ranged Auto Shot if learned; no pet command" or "No attack-start command"}
            if kind=="easy" then
                d.attackPolicy=class=="HUNTER" and "Pet attack and learned Auto Shot on current living enemy"
                    or (class=="SHAMAN" or class=="PALADIN") and "Melee on current living enemy" or "No attack-start command"
            end
            build(d,recipe,function(s) return s.english end)
            S.definitions[#S.definitions+1]=d
            FM.Catalog[#FM.Catalog+1]=d
        end
    end
end
function S.Refresh()
    if FM.InCombat() or not FM.API.Ready() or not FM.API.Supported() then return end
    local _,class=UnitClass("player")
    local cache={}
    local function resolve(s)
        local key=s.id or s.english
        if cache[key]==nil then cache[key]=FM.API.Resolve(s) or false end
        return cache[key] or nil
    end
    for _,d in ipairs(S.definitions) do
        if d.class==class then build(d,S.recipes[class][d.kind],resolve) end
    end
end
