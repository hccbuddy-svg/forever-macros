"""Training, automatic migration, spellbook isolation, and expanded library regressions."""
CASES = []
def case(title, code):
    CASES.append((title, code))

for event in ["SPELLS_CHANGED", "SPELL_TEXT_UPDATE", "PLAYER_LEVEL_UP", "PLAYER_ENTERING_WORLD"]:
    case(f"{event}: newly learned Hunter shots install without a command", f'''
TEST.login(); assert(not TEST.named("FM ArcaneShot"))
TEST.learn(75,"Auto Shot"); TEST.learn(3044,"Arcane Shot")
TEST.fire("{event}"); TEST.flush()
assert(TEST.named("FM ArcaneShot").body:find("!Auto Shot",1,true))
local writes=TEST.writes
TEST.fire("{event}"); TEST.flush(); assert(TEST.writes==writes)
''')

case("Training during combat defers all macro writes until combat ends", '''
TEST.login(); local writes=TEST.writes
TEST.combat=true; TEST.learn(75,"Auto Shot"); TEST.learn(3044,"Arcane Shot")
TEST.fire("SPELLS_CHANGED"); TEST.flush(); assert(TEST.writes==writes)
TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(TEST.named("FM ArcaneShot"))
''')

case("Owned outdated macros automatically migrate in place on spell changes", '''
TEST.class="SHAMAN"; TEST.learn(8042,"Earth Shock"); TEST.login()
local macro=assert(TEST.named("FM EarthShock"))
macro.body="#showtooltip Earth Shock\\n/cast Earth Shock"
ForeverMacrosDB.managed.shaman_shock.body=macro.body
TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(TEST.named("FM EarthShock")==macro and macro.body:find("/startattack",1,true))
local edits=TEST.edits
TEST.fire("UPDATE_MACROS"); TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(TEST.edits==edits, "Idempotent updates must settle")
''')

case("Automatic updates preserve edited deleted renamed skipped and paused macros", '''
TEST.class="SHAMAN"; TEST.learn(8042,"Earth Shock"); TEST.login()
local macro=TEST.named("FM EarthShock")
macro.body="/say personal"; TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(macro.body=="/say personal")
macro.name="My shock"; TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(not TEST.named("FM EarthShock"))
TEST.macros={}; TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(not TEST.named("FM EarthShock"))
TEST.command("skip shaman_stormstrike"); TEST.learn(17364,"Stormstrike")
TEST.fire("SPELLS_CHANGED"); TEST.flush(); assert(not TEST.named("FM Stormstrike"))
TEST.command("off"); TEST.learn(8050,"Flame Shock"); TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(not TEST.named("FM FlameShock")); TEST.command("on"); assert(TEST.named("FM FlameShock"))
''')

case("Opted-in unknown utility persists and installs when learned", '''
TEST.login(); FM.Manager.Request("hunter_flare")
assert(ForeverMacrosDB.wanted.hunter_flare and not TEST.named("FM Flare"))
TEST.fire("ADDON_LOADED","ForeverMacros"); TEST.fire("PLAYER_ENTERING_WORLD"); TEST.flush()
assert(ForeverMacrosDB.wanted.hunter_flare)
TEST.learn(1543,"Flare"); TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(TEST.named("FM Flare") and not ForeverMacrosDB.wanted.hunter_flare)
''')

case("Full slots defer learned opted-in utility until space becomes available", '''
TEST.login(); FM.Manager.Request("hunter_flare")
local _,count=GetNumMacros(); Constants.MacroConsts.MAX_CHARACTER_MACROS=count+ForeverMacrosDB.reserve
TEST.learn(1543,"Flare"); TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(not TEST.named("FM Flare") and ForeverMacrosDB.wanted.hunter_flare)
Constants.MacroConsts.MAX_CHARACTER_MACROS=30
TEST.fire("UPDATE_MACROS"); TEST.flush()
assert(TEST.named("FM Flare"))
''')

case("Higher spell rank ID resolves by learned name and keeps rankless macro", '''
TEST.class="SHAMAN"; TEST.learn(8042,"Earth Shock"); TEST.login()
local macro=TEST.named("FM EarthShock"); local body=macro.body
TEST.known[8042]=false; TEST.entries[8042]=nil
TEST.learn(8044,"Earth Shock"); TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(FM.API.Resolve({id=8042,english="Earth Shock"})=="Earth Shock")
assert(macro.body==body and not macro.body:find("Rank",1,true))
''')

case("Forever abilities resolve learned names without borrowing retail IDs", '''
TEST.class="HUNTER"; TEST.login()
assert(not TEST.named("FM StriderKick"))
TEST.learn(999001,"Strider Kick"); TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(TEST.named("FM StriderKick").body:find("/startattack",1,true))
TEST.locale="deDE"
assert(not FM.API.Resolve({english="Holy Strike"}))
TEST.locale="enUS"; TEST.learn(999002,"Primal Bite",{isPassive=true})
assert(not FM.API.Resolve({english="Primal Bite"}))
''')

case("Pet spell lookup does not confuse a player's same-named ability", '''
TEST.learn(1850,"Dash"); TEST.login()
local find=C_SpellBook.FindSpellBookSlotForSpell
C_SpellBook.FindSpellBookSlotForSpell=function(...) return 1850,0 end
C_SpellBook.HasPetSpells=function() return 1 end
local info=C_SpellBook.GetSpellBookItemInfo
C_SpellBook.GetSpellBookItemInfo=function(slot,bank)
 if bank==1 and slot==1 then return {spellID=999003,name="Dash",isPassive=false,isOffSpec=false} end
 return info(slot,bank)
end
TEST.known[999003]=true
assert(FM.API.Resolve({id=1850,english="Dash",pet=true})=="Dash")
TEST.known[999003]=false
assert(not FM.API.Resolve({id=1850,english="Dash",pet=true}))
''')

case("Automatic refresh retains pinned teammate and pending latest request", '''
TEST.class="PRIEST"; TEST.learn(17,"Power Word: Shield"); TEST.member("party1","Cupcake"); TEST.login()
FM.Manager.Request("priest_shield",{kind="name",unit="Cupcake-TestRealm"})
local d=FM.Core.FindDefinition("priest_shield"); local macro=TEST.named(d.name)
d.unitBody=d.unitBody.."\\n/stopmacro"
TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(macro.body:find("Cupcake-TestRealm",1,true) and macro.body:find("/stopmacro",1,true))
''')

case("New attack policy never adds melee to Hunter shots or wand caster spells", '''
for _, d in ipairs(FM.Catalog) do
 assert(#d.name<=16 and type(d.attackPolicy)=="string",d.id)
 local body=assert(FM.Core.Render(d,function(s) return s.english end)); assert(#body<=255,d.id)
 if d.class=="MAGE" or d.class=="PRIEST" or d.class=="WARLOCK" or d.unitBody then
  assert(not body:find("/startattack",1,true),d.id)
 end
end
for _, id in ipairs({"hunter_aimed","hunter_multi","hunter_scorpid","hunter_distracting"}) do
 local d=FM.Core.FindDefinition(id)
 local body=assert(FM.Core.Render(d,function(s) return s.english end))
 assert(body:find("!Auto Shot",1,true) and not body:find("/startattack",1,true),id)
end
''')

case("Off-target Hunter slows and dispels never start Auto Shot on selected enemy", '''
local enemy={exists=true,harm=true,dead=false}
for _, id in ipairs({"hunter_concussive","hunter_viper","hunter_tranq"}) do
 local body=assert(FM.Core.Render(FM.Core.FindDefinition(id),function(s) return s.english end))
 for _, state in ipairs({{target=enemy,mouseover=enemy},{target=enemy,focus=enemy,shift=true}}) do
  assert(#TEST.actionsOf(TEST.macroModel(body,state),"cast")==1,id)
 end
 local casts=TEST.actionsOf(TEST.macroModel(body,{target=enemy}),"cast")
 assert(#casts==2 and casts[2].value=="!Auto Shot",id)
end
''')

case("Attack starters win limited free slots before generic utility", '''
TEST.class="SHAMAN"; Constants.MacroConsts.MAX_CHARACTER_MACROS=3
TEST.learn(17364,"Stormstrike"); TEST.login()
assert(TEST.named("FM Stormstrike") and not TEST.named("FM Focus"))
''')

case("Search finds new abilities and saved-learning cancellation is explicit", '''
TEST.login(); TEST.command("")
FM.UI.search:SetText("strider")
assert(FM.UI.rows[1].definition.id=="hunter_strider" and not FM.UI.rows[2]:IsShown())
FM.UI.selected="hunter_flare"; FM.Manager.Request("hunter_flare")
TEST.clickText("Cancel queued change"); assert(not ForeverMacrosDB.wanted.hunter_flare)
TEST.command("status"); assert(TEST.messages[#TEST.messages]:find("highest learned rank",1,true))
''')

case("Missing background shows fallback and retries on reopening", '''
TEST.login(); TEST.missingTexture=true; TEST.command("")
assert(not FM.UI.artLoaded and not FM.UI.classBackground:IsShown() and FM.UI.classWatermark:IsShown())
TEST.missingTexture=false; FM.UI.Refresh()
assert(FM.UI.artLoaded and FM.UI.classBackground:IsShown() and not FM.UI.classWatermark:IsShown())
''')

case("Learning request made in combat survives until the ability is trained", '''
TEST.login(); TEST.combat=true; FM.Manager.Request("hunter_flare")
TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(ForeverMacrosDB.wanted.hunter_flare)
TEST.learn(1543,"Flare"); TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(TEST.named("FM Flare"))
''')

case("Renamed pet ability refreshes an existing owned pet macro", '''
TEST.learn(24423,"Screech",{bank=1}); TEST.login()
FM.Manager.Request("hunter_pet_screech")
local macro=assert(TEST.named("FM PetScreech"))
assert(macro.body:find("Screech",1,true))
TEST.learn(24423,"Demoralizing Screech",{bank=1})
TEST.fire("UNIT_PET","player"); TEST.flush()
assert(TEST.named("FM PetScreech")==macro and macro.body:find("Demoralizing Screech",1,true))
''')

case("Learning new attacks with full slots reports the cause without repeated spam", '''
TEST.class="SHAMAN"; Constants.MacroConsts.MAX_CHARACTER_MACROS=2; TEST.login()
TEST.messages={}
TEST.learn(17364,"Stormstrike"); TEST.fire("SPELLS_CHANGED"); TEST.flush()
local warnings=0
for _, msg in ipairs(TEST.messages) do if msg:find("learned starter macros need",1,true) then warnings=warnings+1 end end
assert(warnings==1 and not TEST.named("FM Stormstrike"))
local count=#TEST.messages; TEST.fire("SPELLS_CHANGED"); TEST.flush(); assert(#TEST.messages==count)
TEST.command("reserve 0"); assert(TEST.named("FM Stormstrike"))
''')

case("October build status includes the client build and interface", '''
TEST.login(); TEST.messages={}; TEST.command("status")
assert(TEST.messages[1]:find("1.60.1.70205",1,true))
assert(TEST.messages[1]:find("interface 16001",1,true))
''')

case("Shifting Power waits for the learned active talent and stays in Cat Form", '''
TEST.class="DRUID"; TEST.forms={5487,768}; TEST.login()
assert(FM.Manager.Request("druid_shiftingpower"))
assert(ForeverMacrosDB.wanted.druid_shiftingpower and not TEST.named("FM ShiftingPower"))
TEST.learn(999101,"Shifting Power",{isPassive=true})
TEST.fire("SPELLS_CHANGED"); TEST.flush(); assert(not TEST.named("FM ShiftingPower"))
TEST.learn(999101,"Shifting Power"); TEST.fire("SPELLS_CHANGED"); TEST.flush()
local body=assert(TEST.named("FM ShiftingPower")).body
assert(not ForeverMacrosDB.wanted.druid_shiftingpower)
assert(#TEST.actionsOf(TEST.macroModel(body,{form=2}),"cast")==1)
for _, form in ipairs({0,1,3}) do assert(#TEST.actionsOf(TEST.macroModel(body,{form=form}),"cast")==0) end
assert(not body:find("/cancelform",1,true) and not body:find("/startattack",1,true))
assert(not body:find("Tiger's Fury",1,true))
''')

case("Shifting Power retains form guards through combat and preserves edits", '''
TEST.class="DRUID"; TEST.forms={5487,768}; TEST.learn(999101,"Shifting Power"); TEST.login()
assert(FM.Manager.Request("druid_shiftingpower"))
local macro=assert(TEST.named("FM ShiftingPower")); local old=macro.body
TEST.combat=true; TEST.forms={768,5487}; TEST.fire("UPDATE_SHAPESHIFT_FORMS"); TEST.flush()
assert(macro.body==old)
TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(macro.body:find("[form:1]",1,true))
macro.body="/say personal"; TEST.forms={5487,768}; TEST.fire("UPDATE_SHAPESHIFT_FORMS"); TEST.flush()
assert(macro.body=="/say personal")
''')

case("Spearing Strike installs after learning and only attacks in Battle Stance", '''
TEST.class="WARRIOR"; TEST.forms={2458,2457,71}; TEST.login()
assert(not TEST.named("FM SpearStrike"))
TEST.learn(999102,"Spearing Strike"); TEST.fire("SPELLS_CHANGED"); TEST.flush()
local body=assert(TEST.named("FM SpearStrike")).body
local enemy={exists=true,harm=true,dead=false}
local actions=TEST.macroModel(body,{form=2,target=enemy})
assert(#TEST.actionsOf(actions,"startattack")==1 and #TEST.actionsOf(actions,"cast")==1)
for _, form in ipairs({0,1,3}) do assert(#TEST.macroModel(body,{form=form,target=enemy})==0) end
for _, target in ipairs({{}, {exists=true,harm=false,dead=false}, {exists=true,harm=true,dead=true}}) do
 assert(#TEST.macroModel(body,{form=2,target=target})==0)
end
assert(not body:find("equipped",1,true) and not body:find("/equip",1,true))
local writes=TEST.writes; TEST.fire("SPELLS_CHANGED"); TEST.flush(); assert(TEST.writes==writes)
''')

case("Spearing Strike follows stance layout changes after combat", '''
TEST.class="WARRIOR"; TEST.forms={2457,71,2458}; TEST.learn(999102,"Spearing Strike"); TEST.login()
local macro=assert(TEST.named("FM SpearStrike")); local body=macro.body
TEST.combat=true; TEST.forms={71,2458,2457}; TEST.fire("UPDATE_SHAPESHIFT_FORMS"); TEST.flush()
assert(macro.body==body)
TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(macro.body:find("[form:3,harm,nodead]",1,true))
''')

for class_name in ["HUNTER", "WARLOCK"]:
    case(f"{class_name}: Aggressive pet mode is opt-in and combat queues the macro", f'''
TEST.class="{class_name}"; TEST.login()
assert(not TEST.named("FM PetAggressive"))
for _, macro in ipairs(TEST.macros) do assert(not macro.body:find("/petaggressive",1,true)) end
TEST.combat=true; local writes=TEST.writes
assert(FM.Manager.Request("{class_name.lower()}_pet_aggressive"))
assert(TEST.writes==writes and not TEST.named("FM PetAggressive"))
TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(TEST.named("FM PetAggressive").body=="/petaggressive [pet]")
''')

case("Level 30 can fulfill a saved Berserker Rage request", '''
TEST.class="WARRIOR"; TEST.login(); FM.Manager.Request("warrior_berserker")
assert(ForeverMacrosDB.wanted.warrior_berserker)
TEST.learn(18499,"Berserker Rage"); TEST.fire("PLAYER_LEVEL_UP",30); TEST.flush()
assert(TEST.named("FM BerserkRage") and not ForeverMacrosDB.wanted.warrior_berserker)
''')

case("Corrected pet ranks preserve the installed macro while the ability is absent", '''
TEST.learn(17253,"Bite",{bank=1}); TEST.login(); FM.Manager.Request("hunter_pet_bite")
local macro=assert(TEST.named("FM PetBite")); local body=macro.body
TEST.known[17253]=false; TEST.entries[17253]=nil
TEST.fire("SPELLS_CHANGED"); TEST.flush(); assert(macro.body==body)
assert(not FM.API.Resolve({id=17253,english="Bite",pet=true}))
TEST.learn(999103,"Bite",{bank=1}); TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(FM.API.Resolve({id=17253,english="Bite",pet=true})=="Bite")
assert(TEST.named("FM PetBite")==macro and macro.body==body)
''')
