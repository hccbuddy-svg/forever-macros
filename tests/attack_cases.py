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
for ability in ["shaman_shock", "shaman_frostshock", "warrior_charge", "warrior_pummel", "warrior_intercept", "warrior_disarm", "warrior_hamstring", "warrior_shieldbash", "rogue_kick", "rogue_kidney", "hunter_wingclip", "paladin_hammer"]:
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

case("attack commands remain eligible even when the spell is on cooldown", SETUP + '''
for _, id in ipairs({"shaman_shock","shaman_flameshock","shaman_stormstrike","warrior_execute","rogue_backstab","paladin_judgement"}) do
 local actions=TEST.macroModel(render(id),{target=enemy,spellUnavailable=true})
 assert(#TEST.actionsOf(actions,"startattack")==1, id)
end
''')
case("new melee buttons never acquire an unselected enemy", SETUP + '''
for _, id in ipairs({"shaman_flameshock","shaman_stormstrike","warrior_heroic","warrior_cleave","warrior_execute","warrior_overpower","warrior_mortal","warrior_bloodthirst","warrior_whirlwind","warrior_revenge","rogue_backstab","rogue_eviscerate","rogue_hemorrhage","paladin_judgement","hunter_mongoose"}) do
 local body=render(id)
 assert(#TEST.actionsOf(TEST.macroModel(body,{target=enemy}),"startattack")==1,id)
 for _, target in ipairs({{},friendly,dead}) do
  assert(#TEST.actionsOf(TEST.macroModel(body,{target=target}),"startattack")==0,id)
 end
end
''')
case("rogue damage does not start auto attacks from stealth on failed casts", SETUP + '''
for _, id in ipairs({"rogue_sinister","rogue_backstab","rogue_eviscerate","rogue_hemorrhage","rogue_kick","rogue_kidney"}) do
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
case("hunter shots use non-toggle Auto Shot while traps recall the pet", SETUP + '''
for _, id in ipairs({"hunter_arcane","hunter_serpent"}) do
 local a=TEST.macroModel(render(id),{target=enemy})
 assert(TEST.actionsOf(a,"cast")[1].value=="!Auto Shot")
 assert(#TEST.actionsOf(a,"startattack")==0 and #TEST.actionsOf(a,"petattack")==0)
end
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
