"""Attack semantics, target isolation, form guards and explicit upgrade checks."""
CASES = []
def case(title, code):
    CASES.append((title, code))

SETUP = '''
local enemy={exists=true,harm=true,dead=false}
local friendly={exists=true,harm=false,dead=false}
local dead={exists=true,harm=true,dead=true}
local function render(id) return assert(FM.Core.Render(FM.Core.FindDefinition(id),function(r) return r.english end)) end
'''
for ability in ["shaman_shock", "shaman_frostshock", "warrior_charge", "warrior_pummel", "warrior_intercept", "warrior_disarm", "warrior_hamstring", "warrior_shieldbash", "rogue_kick", "rogue_kidney", "paladin_hammer", "paladin_exorcism", "paladin_wrath", "paladin_holyshock_enemy", "warrior_taunt"]:
    case(ability + ": target swings while focus and mouseover do not start swings", SETUP + f'''
local body=render("{ability}")
local actions=TEST.macroModel(body,{{target=enemy}})
assert(#TEST.actionsOf(actions,"startattack")==1)
assert(TEST.actionsOf(actions,"cast")[1].unit=="target")
for _, state in ipairs({{{{target=enemy,mouseover=enemy}},{{target=enemy,focus=enemy,shift=true}},{{target=enemy,mouseover=enemy,focus=enemy,shift=true}}}}) do
 local a=TEST.macroModel(body,state)
 assert(#TEST.actionsOf(a,"startattack")==0)
 assert(TEST.actionsOf(a,"cast")[1].unit==(state.shift and "focus" or "mouseover"))
end
for _, target in ipairs({{friendly,dead,{{}}}}) do
 local a=TEST.macroModel(body,{{target=target}})
 assert(#TEST.actionsOf(a,"startattack")==0 and #TEST.actionsOf(a,"cast")==0)
end
local a=TEST.macroModel(body,{{target=enemy,mouseover=friendly,shift=true}})
assert(#TEST.actionsOf(a,"startattack")==1 and TEST.actionsOf(a,"cast")[1].unit=="target")
''')

# Hunter melee lost /startattack in 0.11.2: a Hunter's melee swing and Auto Shot share one
# auto-repeat slot, so a start pressed at range would replace a running Auto Shot. Wing Clip's
# off-target /stopmacro guarded only that start and went with it.
case("hunter_wingclip: casts by focus, mouseover, target priority and never starts or stops attacks", SETUP + '''
local body=render("hunter_wingclip")
for _, command in ipairs({"/startattack","/stopmacro","/stopattack"}) do assert(not body:find(command,1,true),command) end
for _, spec in ipairs({{{target=enemy},"target"},{{target=enemy,mouseover=enemy},"mouseover"},
 {{target=enemy,focus=enemy,shift=true},"focus"},{{target=enemy,mouseover=enemy,focus=enemy,shift=true},"focus"},
 {{target=enemy,mouseover=friendly,shift=true},"target"}}) do
 local a=TEST.macroModel(body,spec[1])
 assert(#a==1 and a[1].command=="cast" and a[1].unit==spec[2] and a[1].value=="Wing Clip",spec[2])
end
for _, target in ipairs({friendly,dead,{}}) do
 assert(#TEST.macroModel(body,{target=target})==0)
end
assert(FM.Core.FindDefinition("hunter_wingclip").attackPolicy=="Strike starts melee in range; never replaces Auto Shot")
''')
case("Hunter melee strikes carry no melee start and cast only at a living selected enemy", SETUP + '''
for _, id in ipairs({"hunter_raptor","hunter_mongoose","hunter_strider","hunter_counterattack","hunter_melee"}) do
 local d=FM.Core.FindDefinition(id); local body=render(id)
 assert(not body:find("/startattack",1,true) and not body:find("/targetenemy",1,true),id)
 assert(d.attackPolicy=="Strike starts melee in range; never replaces Auto Shot",id)
 if id=="hunter_melee" then assert(d.optional and body:find("/stopcasting",1,true),id)
 else assert(not d.optional and d.category=="Attacks" and d.priority==5,id) end
 local casts=TEST.actionsOf(TEST.macroModel(body,{target=enemy}),"cast")
 assert(#casts>=1,id)
 for _, cast in ipairs(casts) do assert(cast.unit=="target",id) end
 for _, target in ipairs({{},friendly,dead}) do
  local idle=TEST.macroModel(body,{target=target})
  assert(#TEST.actionsOf(idle,"startattack")==0 and #TEST.actionsOf(idle,"cast")==0,id)
 end
end
''')

case("attack commands remain eligible even when the spell is on cooldown", SETUP + '''
for _, id in ipairs({"shaman_shock","shaman_flameshock","shaman_stormstrike","warrior_execute","rogue_backstab","paladin_judgement","paladin_exorcism","paladin_wrath","paladin_holyshock_enemy","paladin_consecration","warrior_taunt","rogue_mutilate","rogue_venom","rogue_ghostly"}) do
 local actions=TEST.macroModel(render(id),{target=enemy,spellUnavailable=true})
 assert(#TEST.actionsOf(actions,"startattack")==1, id)
end
''')
case("new melee buttons never acquire an unselected enemy", SETUP + '''
for _, id in ipairs({"shaman_flameshock","shaman_stormstrike","warrior_heroic","warrior_cleave","warrior_execute","warrior_overpower","warrior_mortal","warrior_bloodthirst","warrior_whirlwind","warrior_revenge","rogue_backstab","rogue_eviscerate","rogue_hemorrhage","paladin_judgement"}) do
 local body=render(id)
 assert(#TEST.actionsOf(TEST.macroModel(body,{target=enemy}),"startattack")==1,id)
 for _, target in ipairs({{},friendly,dead}) do
  assert(#TEST.actionsOf(TEST.macroModel(body,{target=target}),"startattack")==0,id)
 end
end
''')
case("rogue damage does not start auto attacks from stealth on failed casts", SETUP + '''
for _, id in ipairs({"rogue_sinister","rogue_backstab","rogue_eviscerate","rogue_hemorrhage","rogue_kick","rogue_kidney","rogue_mutilate","rogue_venom","rogue_ghostly"}) do
 assert(#TEST.actionsOf(TEST.macroModel(render(id),{target=enemy,stealth=true,spellUnavailable=true}),"startattack")==0,id)
end
''')
case("crowd control stops attacks without restarting them", SETUP + '''
for _, id in ipairs({"rogue_sap","rogue_blind","rogue_gouge","mage_polymorph","mage_nova","druid_hibernate","druid_roots","warrior_intimidate","paladin_repentance","priest_fear","warlock_fear","warlock_howl","warlock_seduction","hunter_scatter"}) do
 local actions=TEST.macroModel(render(id),{target=enemy})
 assert(#TEST.actionsOf(actions,"startattack")==0,id)
 assert(actions[1].command=="stopattack" or actions[1].command=="stopcasting",id)
 assert(actions[#actions].command=="stopattack",id)
end
''')
case("friendly templates and caster damage never receive melee start commands", '''
for _, d in ipairs(FM.Catalog) do
 if d.unitBody or d.class=="MAGE" or d.class=="PRIEST" or d.class=="WARLOCK" then
  assert(not d.body:find("/startattack",1,true),d.id)
 end
 assert(type(d.attackPolicy)=="string", d.id)
end
''')
# Shot buttons lost their Auto Shot recast in 0.11.1: Forever starts Auto Shot whenever a shot
# casts, and an extra Auto Shot cast on each press delays the next shot (forever-bugs #43).
case("hunter shots carry no Auto Shot recast, FM AutoShot stays non-toggle, traps recall the pet", SETUP + '''
for id, name in pairs({hunter_arcane="Arcane Shot",hunter_serpent="Serpent Sting"}) do
 local body=render(id); assert(not body:find("Auto Shot",1,true),id)
 local a=TEST.macroModel(body,{target=enemy})
 local casts=TEST.actionsOf(a,"cast")
 assert(#casts==1 and casts[1].value==name and casts[1].unit=="target",id)
 assert(#TEST.actionsOf(a,"startattack")==0 and #TEST.actionsOf(a,"petattack")==0,id)
end
local auto=TEST.actionsOf(TEST.macroModel(render("hunter_auto"),{target=enemy}),"cast")
assert(#auto==1 and auto[1].value=="!Auto Shot")
local a=TEST.macroModel(render("hunter_freezing"),{target=enemy})
assert(#TEST.actionsOf(a,"petpassive")==1 and #TEST.actionsOf(a,"petfollow")==1)
assert(#TEST.actionsOf(a,"startattack")==0)
''')
case("feral macro follows actual learned form slots and guards other forms", SETUP + '''
TEST.forms={768,5487,783}
for _, spec in ipairs({{"druid_claw",1},{"druid_shred",1},{"druid_maul",2}}) do
 local body=render(spec[1])
 assert(#TEST.actionsOf(TEST.macroModel(body,{target=enemy,form=spec[2]}),"startattack")==1)
 for _, form in ipairs({0,3,4}) do
  local actions=TEST.macroModel(body,{target=enemy,form=form})
  assert(#TEST.actionsOf(actions,"startattack")==0 and #TEST.actionsOf(actions,"cast")==0)
 end
 assert(#TEST.actionsOf(TEST.macroModel(body,{target=enemy,form=spec[2],stealth=true}),"startattack")==0)
end
TEST.forms={9634}; assert(render("druid_maul"):find("form:1",1,true))
local body=FM.Core.Render(FM.Core.FindDefinition("druid_claw"),function(r) return r.english end); assert(not body)
''')
case("form changes refresh an owned feral macro after combat without losing the button", '''
TEST.class="DRUID"; TEST.learnAll("DRUID"); TEST.forms={5487,768}; TEST.login()
FM.Manager.Request("druid_claw"); TEST.flush(); local macro=assert(TEST.named("FM Claw"))
assert(macro.body:find("form:2",1,true))
TEST.combat=true; TEST.forms={5487,1066,768}; TEST.fire("UPDATE_SHAPESHIFT_FORMS"); TEST.flush()
assert(macro.body:find("form:2",1,true))
TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(TEST.named("FM Claw")==macro and macro.body:find("form:3",1,true))
macro.body="/say personal"; TEST.forms={768}; TEST.fire("UPDATE_SHAPESHIFT_FORMS"); TEST.flush()
assert(macro.body=="/say personal")
''')

UPGRADE = '''
TEST.class="SHAMAN"; TEST.learnAll("SHAMAN"); TEST.login()
local macro=assert(TEST.named("FM EarthShock"))
local previous="#showtooltip Earth Shock\\n/stopcasting\\n/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Earth Shock"
macro.body=previous; ForeverMacrosDB.managed.shaman_shock.body=previous
'''
case("upgrade updates an old owned macro in place without installing extra macros", UPGRADE + '''
local count=TEST.writes; TEST.command("update")
assert(TEST.named("FM EarthShock")==macro and TEST.writes==count)
assert(macro.body:find("/startattack",1,true) and TEST.named("FM Stormstrike"))
assert(ForeverMacrosDB.editBackup.shaman_shock.body==previous)
''')
case("upgrade queues in combat and preserves personal edits", UPGRADE + '''
TEST.combat=true; SlashCmdList.FOREVERMACROS("update")
assert(macro.body==previous)
macro.body="/say personal"; TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(macro.body=="/say personal")
''')
case("upgrade never replaces an existing pending teammate selection", '''
TEST.login(); TEST.member("party1","Cupcake"); TEST.member("party2","Irebelz")
FM.Manager.Request("ally_assist",{kind="name",unit="Cupcake-TestRealm"})
TEST.combat=true; FM.Manager.Request("ally_assist",{kind="name",unit="Irebelz-TestRealm"})
FM.Manager.UpdateInstalled(); TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(TEST.named("FM AllyAssist").body:find("Irebelz",1,true))
''')
case("upgrade leaves deleted renamed and unowned macros alone", UPGRADE + '''
macro.name="Personal Shock"; TEST.command("update")
assert(not TEST.named("FM EarthShock") and macro.body==previous)
TEST.seed("FM EarthShock","/say different",true); TEST.command("update")
assert(TEST.named("FM EarthShock").body=="/say different")
''')
case("UI update control invokes the same ownership-preserving upgrade", UPGRADE + '''
TEST.command(""); TEST.clickText("Update installed macros")
assert(macro.body:find("/startattack",1,true))
''')
case("upgrade is blocked while additions are paused", UPGRADE + '''
TEST.command("off"); assert(not FM.Manager.UpdateInstalled()); assert(macro.body==previous)
''')
