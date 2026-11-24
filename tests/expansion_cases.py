"""Behavior checks for explicit macro ownership, gear selection, UI and DBM timers."""
CASES = []

def case(title, code):
    CASES.append((title, code))

GROUP = '''
TEST.login(); TEST.member("party1", "Cupcake", "Some Realm"); TEST.member("party2", "Irebelz")
FM.Manager.Request("ally_assist", {kind="name", unit="Cupcake-SomeRealm"})
TEST.flush()
local macro = assert(TEST.named("FM AllyAssist"))
local original = macro.body
'''

case("optional library never fills starter slots automatically", '''
-- All talents are learned together by this mock, which is not a real character build.
Constants.MacroConsts.MAX_CHARACTER_MACROS=60
TEST.learnAll("HUNTER"); TEST.login()
for _, d in ipairs(FM.Catalog) do if d.optional then assert(not ForeverMacrosDB.managed[d.id]) end end
assert(not TEST.named("FM Scatter") and not TEST.named("FM TrinketTop"))
FM.Manager.Request("hunter_scatter"); assert(TEST.named("FM Scatter"))
FM.Manager.Request("trinket_top"); assert(TEST.named("FM TrinketTop").body:find("/use 13",1,true))
''')

for cls in ["HUNTER", "WARRIOR", "ROGUE", "MAGE", "PRIEST", "DRUID", "PALADIN", "SHAMAN", "WARLOCK"]:
    case(f"{cls}: every class PvP template can be selected independently", f'''
TEST.class = "{cls}"; TEST.learnAll(TEST.class); TEST.login()
local count = 0
for _, d in ipairs(FM.Catalog) do
 if d.class == TEST.class and d.optional then
  TEST.macros = {{}}; ForeverMacrosDB.managed = {{}}; ForeverMacrosDB.choices = {{}}
  FM.Manager.Request(d.id)
  assert(TEST.named(d.name), d.id .. ": " .. FM.Manager.notice)
  count = count + 1
 end
end
assert(count >= 5)
''')

case("explicit unknown and foreign-class actions stay unavailable", '''
TEST.login(); local count = TEST.writes
FM.Manager.Request("hunter_scatter"); FM.Manager.Request("mage_iceblock")
assert(TEST.writes == count and not TEST.named("FM Scatter"))
''')
case("wrong English spell ID cannot resolve an unrelated learned spell", '''
TEST.class="MAGE"; TEST.learn(45438,"Completely Different Spell"); TEST.login()
FM.Manager.Request("mage_iceblock"); assert(not TEST.named("FM IceBlock"))
TEST.learn(987654,"Ice Block"); FM.Manager.Request("mage_iceblock")
assert(TEST.named("FM IceBlock").body:find("Ice Block",1,true))
''')
case("pet abilities require the active pet bank", '''
TEST.class="WARLOCK"; TEST.learn(19244,"Spell Lock",{bank=0}); TEST.login()
FM.Manager.Request("warlock_spelllock"); assert(not TEST.named("FM SpellLock"))
TEST.entries[19244].bank=1; FM.Manager.Request("warlock_spelllock")
assert(TEST.named("FM SpellLock"))
''')
case("teammate reassignment edits the same macro and keeps icon", GROUP + '''
macro.icon=777; local count=TEST.writes
FM.Manager.Request("ally_assist",{kind="name",unit="Irebelz-TestRealm"})
assert(TEST.named("FM AllyAssist") == macro and TEST.writes == count and macro.icon == 777)
assert(macro.body == "/assist [@Irebelz-TestRealm,help,nodead]")
assert(ForeverMacrosDB.editBackup.ally_assist.body == original)
FM.Manager.Request("ally_assist",{kind="default"})
assert(macro.body:find("@mouseover",1,true) and ForeverMacrosDB.editBackup.ally_assist.body == original)
''')
case("existing friendly starter macro supports named assignment", '''
TEST.class="PRIEST"; TEST.learnAll("PRIEST"); TEST.login(); TEST.member("party1","Cupcake")
local def
for _, d in ipairs(FM.Catalog) do if d.class=="PRIEST" and not d.optional and d.unitBody then def=d; break end end
local macro=assert(TEST.named(def.name)); local count=TEST.writes
FM.Manager.Request(def.id,{kind="name",unit="Cupcake-TestRealm"})
assert(TEST.named(def.name)==macro and TEST.writes==count)
assert(macro.body:find("[@Cupcake-TestRealm,help,nodead]",1,true))
''')
case("slot follows replacement teammate without rewriting combat macro", GROUP + '''
FM.Manager.Request("ally_assist",{kind="slot",unit="party1"})
local edits=TEST.edits; TEST.combat=true; TEST.member("party1","NewFriend")
TEST.fire("GROUP_ROSTER_UPDATE"); TEST.flush()
assert(TEST.edits==edits and macro.body=="/assist [@party1,help,nodead]")
assert(FM.Manager.AssignmentText(ForeverMacrosDB.choices.ally_assist):find("NewFriend",1,true))
''')
case("pinned name remains pinned when party slot changes", GROUP + '''
TEST.member("party1","NewFriend"); TEST.fire("GROUP_ROSTER_UPDATE"); TEST.flush()
assert(macro.body==original and FM.Manager.AssignmentText(ForeverMacrosDB.choices.ally_assist):find("absent",1,true))
''')
case("combat queue keeps old body and applies only latest selection", GROUP + '''
TEST.combat=true
FM.Manager.Request("ally_assist",{kind="name",unit="Irebelz-TestRealm"})
FM.Manager.Request("ally_assist",{kind="slot",unit="party2"})
assert(macro.body==original and TEST.edits==nil)
TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(macro.body=="/assist [@party2,help,nodead]" and TEST.edits==1)
assert(next(FM.Manager.pending)==nil)
''')
case("departed queued teammate is cancelled after combat", GROUP + '''
TEST.combat=true; FM.Manager.Request("ally_assist",{kind="name",unit="Irebelz-TestRealm"})
TEST.roster.party2=nil; TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(macro.body==original and not next(FM.Manager.pending))
''')
case("queued empty slot is cancelled after combat", GROUP + '''
TEST.combat=true; FM.Manager.Request("ally_assist",{kind="slot",unit="party2"})
TEST.roster.party2=nil; TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(macro.body==original)
''')
case("manual edits after queuing are preserved", GROUP + '''
TEST.combat=true; FM.Manager.Request("ally_assist",{kind="slot",unit="party2"})
macro.body="/say personal"; TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(macro.body=="/say personal" and TEST.edits==nil and not FM.Manager.Owned("ally_assist"))
''')
case("deleted managed macros are not silently recreated by UI", GROUP + '''
for i, m in ipairs(TEST.macros) do if m==macro then table.remove(TEST.macros,i); break end end
local count=TEST.writes; FM.Manager.Request("ally_assist",{kind="default"})
assert(TEST.writes==count and not TEST.named("FM AllyAssist"))
''')
case("renamed managed macros are preserved by explicit updates", GROUP + '''
macro.name="My assist"; FM.Manager.Request("ally_assist",{kind="default"})
assert(macro.name=="My assist" and macro.body==original and not TEST.named("FM AllyAssist"))
''')
case("ambiguous account and character names block edits", GROUP + '''
TEST.seed("FM AllyAssist","/say account",false)
FM.Manager.Request("ally_assist",{kind="default"})
assert(macro.body==original and TEST.edits==nil and not FM.Manager.Owned("ally_assist"))
''')
case("unowned macro with matching name cannot be adopted", '''
TEST.seed("FM TrinketTop","/say personal",true); TEST.login()
FM.Manager.Request("trinket_top")
assert(TEST.named("FM TrinketTop").body=="/say personal" and not ForeverMacrosDB.managed.trinket_top)
''')
case("full slots and reserve block optional installation", '''
Constants.MacroConsts.MAX_CHARACTER_MACROS=8; TEST.login()
FM.Manager.Request("trinket_top"); assert(not TEST.named("FM TrinketTop"))
TEST.command("reserve 0"); FM.Manager.Request("trinket_top"); assert(TEST.named("FM TrinketTop"))
''')
case("paused additions also prevent explicit updates", GROUP + '''
TEST.command("off"); FM.Manager.Request("ally_assist",{kind="default"})
assert(macro.body==original and TEST.edits==nil)
''')
case("edit failure pauses starter writes as well as managed changes", GROUP + '''
TEST.failEdit=true; FM.Manager.Request("ally_assist",{kind="default"})
assert(FM.Manager.fault and macro.body==original)
local count=TEST.writes; TEST.learn(136,"Mend Pet"); TEST.fire("SPELLS_CHANGED"); TEST.flush()
assert(TEST.writes==count); FM.Manager.Request("trinket_top"); assert(TEST.writes==count)
TEST.failEdit=false; TEST.command("retry"); assert(TEST.named("FM MendPet"))
''')
case("uncertain edit readback retains the last confirmed body", GROUP + '''
TEST.badEditReturn=true; FM.Manager.Request("ally_assist",{kind="default"})
assert(FM.Manager.fault and ForeverMacrosDB.managed.ally_assist.body==original)
assert(macro.body~=original)
''')
case("raid slots are bounded and injection-like unit text is rejected", '''
local d=FM.Core.FindDefinition("ally_assist")
local resolve=function(r) return r.english end
for _, unit in ipairs({"raid0","raid41","party5","target"}) do assert(not FM.Managed.Render(d,resolve,{kind="slot",unit=unit})) end
for _, unit in ipairs({"Name; /cast", "A]", "A\\n/stopattack", "", "A B"}) do assert(not FM.Managed.ValidUnit(unit)) end
assert(FM.Managed.Render(d,resolve,{kind="slot",unit="raid40"}))
''')
case("raid roster preserves full realm and hides restricted names", '''
TEST.raid=true; TEST.member("raid1","Cupcake","Some Realm"); TEST.member("raid40","Irebelz")
TEST.roster.raid2={name={secret=true},realm="Realm"}; TEST.login()
local roster=FM.Manager.Roster(); assert(#roster==2 and roster[1].name=="Cupcake-SomeRealm")
FM.Manager.Request("ally_assist",{kind="slot",unit="raid40"}); assert(TEST.named("FM AllyAssist"))
''')
case("default action button label and binding follow actual macro ownership", GROUP + '''
ActionButton1=CreateFrame("Button"); ActionButton1.action=1
GetActionInfo=function() for i=121,150 do if TEST.lookup(i)==macro then return "macro",i end end end
GetBindingKey=function(command) assert(command=="ACTIONBUTTON1"); return "SHIFT-F" end
FM.Manager.RefreshLabels(); assert(ActionButton1.fmName:GetText()=="Cupcake")
assert(FM.Manager.BindingFor("FM AllyAssist")=="SHIFT-F")
macro.body="/say changed"; FM.Manager.RefreshLabels(); assert(ActionButton1.fmName:GetText()=="")
''')

GEAR = '''
TEST.items[101]={name="Training Axe",location="INVTYPE_WEAPON"}
TEST.items[102]={name="Training Shield",location="INVTYPE_SHIELD"}
TEST.items[103]={name="Training Bow",location="INVTYPE_RANGED"}
TEST.items[104]={name="Large Axe",location="INVTYPE_2HWEAPON"}
TEST.items[201]={name="Top Badge",location="INVTYPE_TRINKET"}
TEST.items[202]={name="Bottom Badge",location="INVTYPE_TRINKET"}
TEST.items[999]={name="Hat",location="INVTYPE_HEAD"}
TEST.inventory={[16]=101,[17]=102,[18]=103,[13]=201,[14]=202}
TEST.bags[0]={101,102,103,104,201,202,999}; TEST.login()
'''
case("weapon capture uses item IDs without requiring typed names", GEAR + '''
assert(FM.Gear.Capture("weapons_a")); FM.Gear.Save("weapons_a")
local body=assert(TEST.named("FM Weapons A")).body
assert(body:find("/equipslot 16 item:101",1,true) and body:find("/equipslot 17 item:102",1,true))
assert(body:find("/equipslot 18 item:103",1,true) and not body:find("Training",1,true) and #body<=255)
''')
case("item picker filters slot types and deduplicates equipped and bag items", GEAR + '''
assert(#FM.Gear.Items(16)==2 and #FM.Gear.Items(17)==2 and #FM.Gear.Items(13)==2)
assert(#FM.Gear.Items(999)==0)
assert(not FM.Gear.Choose("weapons_a",13,201))
assert(not FM.Gear.Choose("weapons_a",16,999))
assert(not FM.Gear.Choose("weapons_a",16,888))
''')
case("two-handed selection clears offhand and rejects incompatible pair", GEAR + '''
FM.Gear.Capture("weapons_a"); assert(FM.Gear.Choose("weapons_a",16,104))
assert(ForeverMacrosDB.gear.weapons_a[17]==nil)
assert(not FM.Gear.Choose("weapons_a",17,102))
assert(FM.Gear.Choose("weapons_a",16,101)); assert(FM.Gear.Choose("weapons_a",17,102))
''')
case("trinket equip presets are guarded while activation uses equipped slots", GEAR + '''
FM.Gear.Capture("trinkets_b"); FM.Gear.Save("trinkets_b")
local body=assert(TEST.named("FM Trinkets B")).body
assert(body:find("/stopmacro [combat]",1,true) and body:find("/equipslot 13 item:201",1,true))
FM.Manager.Request("trinket_bottom"); assert(TEST.named("FM TrinketBottom").body=="#showtooltip\\n/use 14")
''')
case("gear selections freeze in combat and queued saves are explicit", GEAR + '''
FM.Gear.Capture("weapons_a"); TEST.combat=true; TEST.inventory[16]=104
assert(not FM.Gear.Capture("weapons_a") and not FM.Gear.Choose("weapons_a",16,104))
FM.Gear.Save("weapons_a"); assert(not TEST.named("FM Weapons A"))
TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(TEST.named("FM Weapons A").body:find("item:101",1,true))
''')
case("empty preset slots leave equipped items unchanged", GEAR + '''
FM.Gear.Capture("weapons_a"); FM.Gear.Choose("weapons_a",17,nil)
local d=assert(FM.Gear.Definition("weapons_a")); assert(not d.body:find("/equipslot 17",1,true))
assert(not FM.Gear.Definition("weapons_b"))
assert(not FM.Managed.GearBody({[16]=-1}))
''')
case("native equipment sets are selected from existing names and updated in place", GEAR + '''
TEST.equipmentSets={[3]="My PvP Set",[4]="My Quest Set",[9]="Bad\\n/run nope",[10]="[combat] Wrong"}
assert(#FM.Gear.EquipmentSets()==2); FM.Gear.LinkSet(3)
local macro=assert(TEST.named("FM GearSet")); assert(macro.body:find("/equipset My PvP Set",1,true))
FM.Gear.LinkSet(4); assert(TEST.named("FM GearSet")==macro and macro.body:find("My Quest Set",1,true))
C_EquipmentSet=nil; assert(#FM.Gear.EquipmentSets()==0)
''')
case("gear macro edits preserve user customizations", GEAR + '''
FM.Gear.Capture("weapons_a"); FM.Gear.Save("weapons_a"); local macro=TEST.named("FM Weapons A")
macro.body="/say custom"; FM.Gear.Choose("weapons_a",16,104); FM.Gear.Save("weapons_a")
assert(macro.body=="/say custom")
''')
case("UI opens without installing optional macros and clicks a teammate", GROUP + '''
local count=TEST.writes; TEST.command(""); assert(FM.UI.frame:IsShown() and TEST.writes==count)
FM.UI.selected="ally_assist"; FM.UI.Refresh()
FM.UI.partyRows[3]:Click(); assert(macro.body:find("Irebelz-TestRealm",1,true))
TEST.combat=true; FM.UI.partyRows[2]:Click(); assert(FM.UI.assignment:GetText():find("Pending:",1,true))
TEST.clickText("Cancel queued change"); assert(not next(FM.Manager.pending))
TEST.command(""); assert(not FM.UI.frame:IsShown())
''')
case("UI equipment flow captures and saves a macro without equipping", GEAR + '''
TEST.command(""); TEST.clickText("Equipment"); TEST.clickText("Capture equipped items")
TEST.clickText("Save preset macro"); assert(TEST.named("FM Weapons A"))
assert(TEST.inventory[16]==101 and TEST.inventory[17]==102)
TEST.clickText("Reminders"); TEST.clickText("Help"); assert(FM.UI.panels.Help:IsShown())
''')

ALERTS = '''
TEST.login(); FM.Manager.Request("trinket_top"); TEST.flush()
TEST.alerts={}; FM.UI.Alert=function(message) table.insert(TEST.alerts,message) end
local function begin(id, duration)
 TEST.dbm("DBM_TimerBegin",id or "timer","Heavy attack",duration or 10,nil,"cast",12345,1,"TestBoss")
end
begin("observe",10); TEST.dbm("DBM_TimerStop","observe")
assert(FM.Alerts.Link(FM.Alerts.recent[1],"trinket_top",3))
'''
case("DBM reminders remain disabled until explicitly enabled", ALERTS + '''
begin(); TEST.advance(12); assert(#TEST.alerts==0)
ForeverMacrosDB.alerts.enabled=true; begin(); TEST.advance(6); assert(#TEST.alerts==0)
TEST.advance(1); assert(#TEST.alerts==1 and TEST.alerts[1]:find("FM TrinketTop",1,true))
TEST.advance(10); assert(#TEST.alerts==1)
''')
case("unlinked DBM timer produces no reminder", ALERTS + '''
ForeverMacrosDB.alerts.enabled=true; ForeverMacrosDB.alerts.rules={}
begin(); TEST.advance(20); assert(#TEST.alerts==0)
''')
case("stopped timer cancels pending reminder", ALERTS + '''
ForeverMacrosDB.alerts.enabled=true; begin(); TEST.advance(2)
TEST.dbm("DBM_TimerStop","timer"); TEST.advance(20); assert(#TEST.alerts==0)
''')
case("updated timer reschedules rather than firing the old warning", ALERTS + '''
ForeverMacrosDB.alerts.enabled=true; begin(); TEST.advance(2)
TEST.dbm("DBM_TimerUpdate","timer",2,20); TEST.advance(5); assert(#TEST.alerts==0)
TEST.advance(10); assert(#TEST.alerts==1)
''')
case("paused timer resumes with remaining duration", ALERTS + '''
ForeverMacrosDB.alerts.enabled=true; begin(); TEST.advance(2)
TEST.dbm("DBM_TimerPause","timer"); TEST.advance(20); assert(#TEST.alerts==0)
TEST.dbm("DBM_TimerResume","timer"); TEST.advance(4); assert(#TEST.alerts==0)
TEST.advance(1); assert(#TEST.alerts==1)
''')
case("reused DBM timer ID invalidates the old timer callback", ALERTS + '''
ForeverMacrosDB.alerts.enabled=true; begin(); TEST.advance(2); begin("timer",20)
TEST.advance(5); assert(#TEST.alerts==0); TEST.advance(12); assert(#TEST.alerts==1)
''')
for event in ["ENCOUNTER_END", "PLAYER_ENTERING_WORLD", "PLAYER_DEAD"]:
    case(f"{event} cancels old encounter reminders", ALERTS + f'''
ForeverMacrosDB.alerts.enabled=true; begin(); TEST.fire("{event}")
TEST.advance(20); assert(#TEST.alerts==0)
''')
case("restricted timer fields are skipped before inspection", ALERTS + '''
local before=#FM.Alerts.recent
for position=1,9 do
 if position~=4 and position~=7 then
  local args={"secretTimer","Heavy attack",10,1,"cast",12345,1,"TestBoss"}
  if position<=8 then args[position]={secret=true}; FM.Alerts.Begin("DBM_TimerBegin",unpack(args)) end
 end
end
assert(#FM.Alerts.recent==before and FM.Alerts.running.secretTimer==nil and FM.Alerts.blocked==6)
''')
case("invalid timer duration is ignored", ALERTS + '''
for _, value in ipairs({0,-1,3601,math.huge,0/0,"10"}) do begin("bad",value); assert(FM.Alerts.running.bad==nil) end
''')
case("edited macro prevents live reminder and new link", ALERTS + '''
ForeverMacrosDB.alerts.enabled=true; begin(); TEST.named("FM TrinketTop").body="/say personal"
TEST.advance(10); assert(#TEST.alerts==0)
assert(not FM.Alerts.Link(FM.Alerts.recent[1],"trinket_top",3))
''')
case("removing or replacing a rule cancels its pending callback", ALERTS + '''
ForeverMacrosDB.alerts.enabled=true; begin()
FM.Alerts.Link(FM.Alerts.recent[1],"trinket_top",5)
TEST.advance(10); assert(#TEST.alerts==0)
begin(); ForeverMacrosDB.alerts.rules={}; TEST.advance(10); assert(#TEST.alerts==0)
''')
case("timer configuration validates ownership lead time and combat", ALERTS + '''
assert(not FM.Alerts.Link(FM.Alerts.recent[1],"trinket_top",11))
assert(not FM.Alerts.Link(FM.Alerts.recent[1],"trinket_top",0/0))
assert(not FM.Alerts.Link(FM.Alerts.recent[1],"not-installed",3))
TEST.combat=true; assert(not FM.Alerts.Link(FM.Alerts.recent[1],"trinket_top",3))
''')
case("test reminder is visibly labeled and requires no DBM", '''
DBM=nil; TEST.login(); assert(not FM.Alerts.connected)
FM.Alerts.Show(nil,"Preview only",true)
assert(FM.UI.alertFrame:IsShown() and FM.UI.alertFrame.label:GetText():find("TEST REMINDER",1,true))
TEST.advance(4); assert(not FM.UI.alertFrame:IsShown())
''')

case("UI offers every observed timer and native equipment set across pages", GEAR + '''
for i=1,12 do TEST.equipmentSets[i]="Set "..i end
TEST.command(""); FM.UI.tab="Equipment"; FM.UI.setPage=3; FM.UI.Refresh()
assert(FM.UI.setRows[4].entry and #FM.Gear.EquipmentSets()==12)
for i=1,20 do FM.Alerts.Begin("DBM_TimerBegin","t"..i,"Attack "..i,10,nil,"cast",i,1,"TestBoss") end
FM.UI.tab="Boss reminders"; FM.UI.timerPage=3; FM.UI.Refresh()
assert(FM.UI.timerRows[4].entry and not FM.UI.timerRows[5].entry)
''')
case("reminder shows the learned macro spell icon when exposed", '''
TEST.login(); FM.Manager.Request("trinket_top"); TEST.flush()
GetMacroSpell=function() return 123 end
C_Spell.GetSpellTexture=function(id) assert(id==123); return 456 end
FM.Alerts.Show("trinket_top","Test",true)
assert(FM.UI.alertFrame.icon.texture==456)
''')
case("PvP filter includes starter interrupts and cleanses", '''
TEST.class="MAGE"; TEST.learnAll("MAGE"); TEST.login(); TEST.command("")
FM.UI.filter="PvP"; FM.UI.Refresh(); local counter,decurse=false,false
for _, row in ipairs(FM.UI.rows) do
 if row.definition then counter=counter or row.definition.id=="mage_counterspell"; decurse=decurse or row.definition.id=="mage_decurse" end
end
assert(counter and decurse)
''')

case("explicit restore makes a deleted gear macro eligible for Save again", GEAR + '''
FM.Gear.Capture("weapons_a"); FM.Gear.Save("weapons_a")
for i,m in ipairs(TEST.macros) do if m.name=="FM Weapons A" then table.remove(TEST.macros,i); break end end
FM.Gear.Save("weapons_a"); assert(not TEST.named("FM Weapons A"))
TEST.command("restore weapons_a"); FM.Gear.Save("weapons_a"); assert(TEST.named("FM Weapons A"))
''')
case("trinket reminders use the currently equipped item icon", '''
TEST.login(); FM.Manager.Request("trinket_top"); TEST.flush()
GetInventoryItemTexture=function(unit,slot) assert(unit=="player" and slot==13); return 999 end
FM.Alerts.Show("trinket_top","Test",true); assert(FM.UI.alertFrame.icon.texture==999)
''')
