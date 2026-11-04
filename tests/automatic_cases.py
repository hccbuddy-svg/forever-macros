"""Learned sequences, compact leveling controls, ownership and trainer window."""
CASES=[]
def case(name,code): CASES.append((name,code))

for cls,sid,name in [('SHAMAN',403,'Lightning Bolt'),('PRIEST',585,'Smite'),
                     ('PALADIN',21084,'Seal of Righteousness'),('HUNTER',75,'Auto Shot')]:
 case(cls+' compact routine installs only learned abilities and defers combat creation',f'''
TEST.class='{cls}';TEST.login();assert(not TEST.named('FM Easy'))
TEST.combat=true;TEST.learn({sid},'{name}');TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(not TEST.named('FM Easy'));TEST.combat=false;TEST.fire('PLAYER_REGEN_ENABLED');TEST.flush()
local m=assert(TEST.named('FM Easy'));assert(m.body:find('{name}',1,true) and #m.body<=255)
assert(ForeverMacrosDB.managed.auto_{cls.lower()}_easy)
local writes,edits=TEST.writes,TEST.edits;TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(TEST.writes==writes and TEST.edits==edits)
''')
 case(cls+' compact routine stops before attacks against friendly dead absent or channel targets',f'''
TEST.class='{cls}';TEST.learn({sid},'{name}');TEST.login();local body=TEST.named('FM Easy').body
for _,state in ipairs({{ {{}}, {{target={{exists=true,harm=false}}}},
 {{target={{exists=true,harm=true,dead=true}}}}, {{target={{exists=true,harm=true}},channeling=true}} }}) do
 assert(#TEST.macroModel(body,state)==0)
end
local actions=TEST.macroModel(body,{{target={{exists=true,harm=true}},player={{exists=true}}}})
assert(#actions>0 and not body:find('/targetenemy',1,true))
''')

case('Shaman shield is a separate self opener and totems stay out of the attack loop','''
TEST.class='SHAMAN';TEST.learn(324,'Lightning Shield');TEST.login();assert(not TEST.named('FM Easy'))
TEST.learn(8042,'Earth Shock');TEST.fire('SPELLS_CHANGED');TEST.flush()
local m=TEST.named('FM Easy');local body=m.body
assert(body:find('/castsequence [@player] reset=target/combat/alt Lightning Shield,null',1,true))
assert(body:find('/startattack',1,true) and body:find('reset=target/combat/alt Earth Shock',1,true))
TEST.learn(8050,'Flame Shock');TEST.learn(17364,'Stormstrike');TEST.combat=true
TEST.fire('SPELLS_CHANGED');TEST.flush();assert(m.body==body)
TEST.combat=false;TEST.fire('PLAYER_REGEN_ENABLED');TEST.flush()
assert(m==TEST.named('FM Easy') and m.body:find('Flame Shock,Stormstrike,Earth Shock',1,true))
assert(not m.body:find('Totem',1,true) and not m.body:find('Recall',1,true))
local acts=TEST.macroModel(m.body,{target={exists=true,harm=true},player={exists=true}})
local seq=TEST.actionsOf(acts,'castsequence');assert(#seq==2 and seq[1].unit=='player' and seq[2].unit=='target')
assert(#TEST.actionsOf(acts,'startattack')==1)
''')

case('Totems add learned steps then upgrade the same macro to native Call only after combat','''
TEST.class='SHAMAN';TEST.login();assert(not TEST.named('FM Totems'))
TEST.learn(3599,'Searing Totem');TEST.fire('SPELLS_CHANGED');TEST.flush()
local m=assert(TEST.named('FM Totems'));m.icon=12345
assert(m.body:find('reset=10/alt Searing Totem,null',1,true))
TEST.learn(8075,'Strength of Earth Totem');TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(m.body:find('Searing Totem,Strength of Earth Totem,null',1,true))
local body=m.body;TEST.learn(66842,'Call of the Elements');TEST.combat=true
TEST.fire('SPELLS_CHANGED');TEST.flush();assert(m.body==body)
TEST.combat=false;TEST.fire('PLAYER_REGEN_ENABLED');TEST.flush()
assert(TEST.named('FM Totems')==m and m.icon==12345)
assert(m.body=='#showtooltip\\n/stopmacro [channeling]\\n/cast Call of the Elements')
assert(not m.body:find('castsequence',1,true))
TEST.learn(36936,'Totemic Recall');TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(TEST.named('FM Recall').body:find('/cast Totemic Recall',1,true))
assert(not m.body:find('Recall',1,true))
''')

case('Paladin attempts off GCD Judgement and Holy Strike without resealing after Judgement','''
TEST.class='PALADIN';TEST.learn(21084,'Seal of Righteousness');TEST.learn(20271,'Judgement')
TEST.learn(999002,'Holy Strike');TEST.login();local body=TEST.named('FM Easy').body
assert(body:find('Seal of Righteousness,null',1,true))
assert(body:find('/cast Judgement\\n/cast Holy Strike',1,true))
assert(not body:find('Crusader Strike',1,true))
assert(TEST.named('FM AutoOpen').body:find('Seal of Righteousness,Judgement,null',1,true))
''')

case('Priest keeps shield on self and uses a separate guarded damage cycle','''
TEST.class='PRIEST';TEST.learn(17,'Power Word: Shield');TEST.learn(585,'Smite')
TEST.learn(589,'Shadow Word: Pain');TEST.learn(8092,'Mind Blast');TEST.login()
local m=TEST.named('FM Easy');assert(m.body:find('Mind Blast,Shadow Word: Pain,Smite,Smite,Smite,Smite',1,true))
local state={target={exists=true,harm=true},player={exists=true}}
local seq=TEST.actionsOf(TEST.macroModel(m.body,state),'castsequence')
assert(#seq==2 and seq[1].unit=='player' and seq[2].unit=='target')
state.form=1;seq=TEST.actionsOf(TEST.macroModel(m.body,state),'castsequence');assert(#seq==1 and seq[1].unit=='player')
TEST.learn(999003,'Penance');TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(m.body:find('Penance,Shadow Word: Pain,Smite',1,true))
TEST.learn(15407,'Mind Flay');TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(m.body:find('Mind Blast,Shadow Word: Pain,Mind Flay',1,true))
assert(not m.body:find('Smite',1,true) and not m.body:find('Penance',1,true))
assert(not m.body:find('Shoot',1,true) and not m.body:find('/startattack',1,true) and #m.body<=255)
''')

case('Hunter includes pet and Auto Shot then upgrades shared cooldown cycle without AoE','''
TEST.class='HUNTER';TEST.learn(75,'Auto Shot');TEST.learn(1978,'Serpent Sting')
TEST.learn(3044,'Arcane Shot');TEST.learn(2643,'Multi-Shot');TEST.login()
local m=TEST.named('FM Easy');assert(m.body:find('Serpent Sting,Arcane Shot,Arcane Shot,Arcane Shot',1,true))
assert(m.body:find('/petattack\\n/cast !Auto Shot',1,true))
TEST.learn(999004,'Summon Hawk');TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(m.body:find('Serpent Sting,Summon Hawk,Summon Hawk,Arcane Shot',1,true))
assert(not m.body:find('Multi-Shot',1,true) and not m.body:find('Aspect',1,true) and not m.body:find('/startattack',1,true))
local actions=TEST.macroModel(m.body,{target={exists=true,harm=true}})
assert(TEST.actionsOf(actions,'petattack')[1].unit=='target')
''')

case('Easy and totem commands open learned controls and automatic navigation includes them','''
TEST.class='SHAMAN';TEST.learn(8042,'Earth Shock');TEST.learn(3599,'Searing Totem');TEST.login()
TEST.command('easy');assert(FM.UI.tab=='Macros' and FM.UI.query=='fm easy')
assert(FM.UI.rows[1].definition.id=='auto_shaman_easy')
TEST.command('totems');assert(FM.UI.query=='fm totems' and FM.UI.rows[1].definition.id=='auto_shaman_totems')
FM.TrainingUI.ShowAutomatic();assert(FM.UI.query=='fm ' and FM.UI.filter=='Sequences')
''')

case('Compact updates preserve manual changes and retained slots after recall is learned','''
TEST.class='SHAMAN';TEST.learn(8042,'Earth Shock');TEST.learn(3599,'Searing Totem');TEST.login()
local m=TEST.named('FM Easy');m.body='/say personal'
local t=TEST.named('FM Totems');t.body='/say chosen totems'
TEST.learn(324,'Lightning Shield');TEST.learn(66842,'Call of the Elements');TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(m.body=='/say personal' and t.body=='/say chosen totems')
local _,count=GetNumMacros();Constants.MacroConsts.MAX_CHARACTER_MACROS=count+ForeverMacrosDB.reserve
TEST.learn(36936,'Totemic Recall');TEST.fire('SPELLS_CHANGED');TEST.flush();assert(not TEST.named('FM Recall'))
Constants.MacroConsts.MAX_CHARACTER_MACROS=30;TEST.fire('UPDATE_MACROS');TEST.flush();assert(TEST.named('FM Recall'))
''')

case('Compact builder rejects injected and excessive localized spell names','''
TEST.class='SHAMAN';TEST.learn(8042,'Earth Shock,Injected');TEST.login();assert(not TEST.named('FM Easy'))
TEST.locale='deDE';TEST.learn(8042,string.rep('A',240));TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(not TEST.named('FM Easy'))
TEST.learn(8042,'Erdschock');TEST.fire('SPELLS_CHANGED');TEST.flush();assert(TEST.named('FM Easy').body:find('Erdschock',1,true))
''')

case('Preparation is reusable after inactivity and retains its combat guard','''
TEST.class='PRIEST';TEST.learn(1243,'Power Word: Fortitude');TEST.learn(588,'Inner Fire');TEST.login()
local body=TEST.named('FM AutoPrep').body
assert(body:find('/stopmacro [combat]',1,true) and body:find('reset=10/alt Power Word: Fortitude,Inner Fire,null',1,true))
''')

for cls,sid,name in [('WARRIOR',772,'Rend'),('PALADIN',21084,'Seal of Righteousness'),
 ('HUNTER',1978,'Serpent Sting'),('ROGUE',1752,'Sinister Strike'),('PRIEST',585,'Smite'),
 ('SHAMAN',403,'Lightning Bolt'),('MAGE',133,'Fireball'),('WARLOCK',686,'Shadow Bolt'),('DRUID',5176,'Wrath')]:
 case(cls+' automatically receives a learned-only class sequence',f'''
TEST.class='{cls}';TEST.login();assert(not TEST.named('FM AutoOpen'))
TEST.fire('PLAYER_LEVEL_UP',2);TEST.flush();assert(not TEST.named('FM AutoOpen'))
TEST.learn({sid},'{name}');TEST.fire('SPELLS_CHANGED');TEST.flush()
local m=assert(TEST.named('FM AutoOpen'));assert(m.body:find('{name},null',1,true))
assert(#m.body<=255 and m.body:find('reset=target/combat/alt',1,true))
assert(ForeverMacrosDB.managed.auto_{cls.lower()}_open)
local writes,edits=TEST.writes,TEST.edits
TEST.fire('SPELLS_CHANGED');TEST.flush();assert(TEST.writes==writes and TEST.edits==edits)
''')

case('Shaman opener expands only after learning and retains macro identity and icon','''
TEST.class='SHAMAN';TEST.learn(403,'Lightning Bolt');TEST.login()
local m=assert(TEST.named('FM AutoOpen'));m.icon=8123
local before=m.body;TEST.fire('PLAYER_LEVEL_UP',4);TEST.flush();assert(m.body==before)
TEST.learn(8042,'Earth Shock');TEST.combat=true;TEST.fire('SPELLS_CHANGED');TEST.flush();assert(m.body==before)
TEST.combat=false;TEST.fire('PLAYER_REGEN_ENABLED');TEST.flush()
assert(TEST.named('FM AutoOpen')==m and m.icon==8123 and m.body:find('Lightning Bolt,Earth Shock,null',1,true))
TEST.learn(8050,'Flame Shock');TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(m.body:find('Lightning Bolt,Flame Shock,null',1,true) and not m.body:find('Earth Shock',1,true))
assert(m.body:find('/startattack [harm,nodead]',1,true))
''')

case('Automatic sequence ownership preserves edits removals pauses and reserves','''
TEST.class='MAGE';TEST.learn(133,'Fireball');TEST.login();local m=TEST.named('FM AutoOpen')
m.body='/say my version';TEST.learn(116,'Frostbolt');TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(m.body=='/say my version');m.name='My opener';TEST.fire('SPELLS_CHANGED');TEST.flush();assert(not TEST.named('FM AutoOpen'))
TEST.macros={};TEST.fire('SPELLS_CHANGED');TEST.flush();assert(not TEST.named('FM AutoOpen'))
TEST.command('off');TEST.learn(1459,'Arcane Intellect');TEST.fire('SPELLS_CHANGED');TEST.flush();assert(not TEST.named('FM AutoPrep'))
local _,n=GetNumMacros();Constants.MacroConsts.MAX_CHARACTER_MACROS=n+ForeverMacrosDB.reserve
TEST.command('on');assert(not TEST.named('FM AutoPrep'))
Constants.MacroConsts.MAX_CHARACTER_MACROS=30;TEST.fire('UPDATE_MACROS');TEST.flush();assert(TEST.named('FM AutoPrep'))
''')

case('Rank changes and localized names do not duplicate automatic sequences','''
TEST.class='MAGE';TEST.locale='deDE';TEST.learn(116,'Frostblitz');TEST.login()
local m=assert(TEST.named('FM AutoOpen'));assert(m.body:find('Frostblitz,null',1,true))
TEST.known[116]=false;TEST.entries[116]=nil;TEST.learn(205,'Frostblitz')
TEST.fire('SPELLS_CHANGED');TEST.flush();assert(TEST.named('FM AutoOpen')==m and not m.body:find('Rank',1,true))
''')

case('Automatic sequences reject future spells unsafe names and preserve form guards','''
TEST.class='DRUID';TEST.learn(5176,'Wrath');TEST.known[5176]=false;TEST.login();assert(not TEST.named('FM AutoOpen'))
TEST.learn(5176,'Wrath,Injected');TEST.fire('SPELLS_CHANGED');TEST.flush();assert(not TEST.named('FM AutoOpen'))
TEST.learn(1822,'Rake');TEST.learn(1082,'Claw');TEST.forms={5487,768};TEST.fire('SPELLS_CHANGED');TEST.flush()
local m=assert(TEST.named('FM AutoCat'));assert(m.body:find('form:2,nostealth,harm,nodead',1,true))
assert(not TEST.named('FM AutoBear'))
''')

case('Automatic openers never insert new abilities midway through combat','''
TEST.class='WARLOCK';TEST.learn(686,'Shadow Bolt');TEST.login()
local m=TEST.named('FM AutoOpen');local body=m.body;TEST.combat=true
TEST.learn(172,'Corruption');TEST.fire('PLAYER_LEVEL_UP',4);TEST.fire('SPELLS_CHANGED');TEST.flush()
assert(m.body==body);TEST.combat=false;TEST.fire('PLAYER_REGEN_ENABLED');TEST.flush()
assert(m.body:find('Corruption,Shadow Bolt,null',1,true))
''')

FIXTURE='''
TEST.login();TEST.command('training')
local T=FM.TrainingUI
local f=CreateFrame('Frame','WhatsTrainingFrame',UIParent);f:SetSize(400,540);f:SetScale(0.9)
f:SetPoint('CENTER',UIParent,'CENTER',37,52);f:Hide();f.titlebar=CreateFrame('Frame',nil,f)
local originalPoint={f:GetPoint()}
C_AddOns={GetAddOnMetadata=function() return '1.1.1' end}
SlashCmdList.WHATSTRAINING=function() f:Show() end
hooksecurefunc=function(object,name,fn) local old=object[name];object[name]=function(...) old(...);fn(...) end end
'''
case('Training shows missing provider guidance without affecting macro generation','''
TEST.login();TEST.command('training')
assert(FM.UI.tab=='Training' and FM.TrainingUI.message:find('Install and enable',1,true))
assert(not FM.TrainingUI.mounted)
''')
case('Training embeds the original provider and restores its size parent and position',FIXTURE+'''
assert(T.Mount() and T.mounted==f);assert(f:GetParent()==T.host and f:GetHeight()==495 and f:IsShown())
assert(not f.titlebar:IsMouseEnabled());assert(f:GetScale()==1)
f:SetPoint('CENTER',UIParent,'CENTER',0,0);local _,parent=f:GetPoint();assert(parent==T.host)
FM.UI.tab='Macros';FM.UI.Refresh();assert(not T.mounted and f:GetParent()==UIParent and f:GetHeight()==540)
assert(f:GetScale()==0.9 and f.titlebar:IsMouseEnabled() and not f:IsShown())
local point={f:GetPoint()};assert(point[4]==37 and point[5]==52)
''')
case('Closing Forever Macros restores an already open training provider',FIXTURE+'''
f:Show();assert(T.Mount());FM.UI.frame:Hide()
assert(not T.mounted and f:GetParent()==UIParent and f:IsShown())
''')
case('Training rejects unsupported provider versions and combat attachment',FIXTURE+'''
C_AddOns.GetAddOnMetadata=function() return '9.3.1' end
assert(not T.Mount() and not T.mounted)
C_AddOns.GetAddOnMetadata=function() return '1.1.1' end
TEST.combat=true;assert(not T.Mount() and not T.mounted)
''')
case('Automatic macro navigation is visible in the library',FIXTURE+'''
T.ShowAutomatic();assert(FM.UI.tab=='Macros' and FM.UI.query=='fm ')
assert(FM.UI.rows[1].definition.autoSequence)
''')
