"""ElvUI profile installation and movement integration contracts."""
CASES=[]
def case(title,code): CASES.append((title,code))

FIXTURE='''
local E={Forever=true,mynameRealm='Tester - TestRealm',version=15.26,private={bags={enable=true},auras={enable=true}}}
ElvUI={E};ElvDB={profileKeys={[E.mynameRealm]='Original'},profiles={Original={custom=123}},global={general={UIScale=0.42}}}
ElvPrivateDB={profileKeys={[E.mynameRealm]='PrivateOriginal'},profiles={PrivateOriginal={custom=456,bags={enable=true}}}}
E.data={GetCurrentProfile=function() return ElvDB.profileKeys[E.mynameRealm] end,SetProfile=function(_,name) TEST.switches=(TEST.switches or 0)+1;ElvDB.profileKeys[E.mynameRealm]=name end}
TEST.login()
local L=FM.Layout;local s=FM.API.State().layout
'''
case('ElvUI initial setup creates 28 distinct profiles before engine enable',FIXTURE+'''
local count=0;for name in pairs(ElvDB.profiles) do if name:find(L.prefix,1,true)==1 then count=count+1 end end
assert(count==28 and s.revision==2 and s.auto)
assert(ElvDB.profileKeys[E.mynameRealm]=='FM LG v2 Hunter Beast Mastery')
assert(ElvDB.profiles.Original.custom==123 and ElvPrivateDB.profiles.PrivateOriginal.custom==456)
local private=ElvPrivateDB.profiles[s.privateName]
assert(private.custom==456 and not private.bags.enable and not private.auras.enable and not private.auras.disableBlizzard)
assert(private.install_complete==15.26 and ElvDB.global.general.UIScale==0.6)
assert(s.previous.profile=='Original' and s.previous.private=='PrivateOriginal' and s.previous.scale==0.42)
assert(not TEST.switches)
''')
case('Repeated events preserve edits to existing ElvUI profiles and scale',FIXTURE+'''
local p=ElvDB.profiles[L.Name('HUNTER',1)];p.actionbar.bar1.buttonSize=51
ElvDB.global.general.UIScale=0.63;E.Initialized=true
for i=1,5 do TEST.fire('PLAYER_ENTERING_WORLD');TEST.flush() end
assert(p.actionbar.bar1.buttonSize==51 and ElvDB.global.general.UIScale==0.63)
assert(s.previous.scale==0.42)
''')
case('Every generated party and raid direction has both ElvUI spacing multipliers',FIXTURE+'''
local vectors={DOWN_RIGHT={1,-1},DOWN_LEFT={-1,-1},UP_RIGHT={1,1},UP_LEFT={-1,1},
 RIGHT_DOWN={1,-1},RIGHT_UP={1,1},LEFT_DOWN={-1,-1},LEFT_UP={-1,1}}
for name,p in pairs(ElvDB.profiles) do
 if name:find(L.prefix,1,true)==1 then
  for _,unit in ipairs({'party','raid1','raid2','raid3'}) do
   local db=p.unitframe.units[unit];local v=vectors[db.growthDirection]
   assert(v,name..' '..unit..' has unsupported spacing direction '..db.growthDirection)
   assert(type(db.verticalSpacing*v[2])=='number')
  end
 end
end
''')
case('Upgrade repairs all 28 saved party profiles without changing layout choices',FIXTURE+'''
local count=0
for name,p in pairs(ElvDB.profiles) do
 if name:find(L.prefix,1,true)==1 then
  p.unitframe.units.party.growthDirection='DOWN';p.unitframe.units.party.height=73
  p.actionbar.bar1.buttonSize=51;count=count+1
 end
end
local selected=ElvDB.profileKeys[E.mynameRealm];local previous=s.previous
ElvDB.global.general.UIScale=0.63
L.Prepare()
for name,p in pairs(ElvDB.profiles) do
 if name:find(L.prefix,1,true)==1 then
  assert(p.unitframe.units.party.growthDirection=='DOWN_RIGHT')
  assert(p.unitframe.units.party.height==73 and p.actionbar.bar1.buttonSize==51)
  assert(s.partyDirectionBackup[name]=='DOWN')
 end
end
assert(count==28 and selected==ElvDB.profileKeys[E.mynameRealm])
assert(s.previous==previous and ElvDB.global.general.UIScale==0.63 and not TEST.switches)
''')
case('Direction repair preserves customized and unrelated profiles and its first backup',FIXTURE+'''
local p=ElvDB.profiles[L.Name('HUNTER',1)]
p.unitframe.units.party.growthDirection='DOWN';L.Prepare()
local backup=s.partyDirectionBackup
p.unitframe.units.party.growthDirection='UP_LEFT'
local custom={unitframe={units={party={growthDirection='DOWN'}}}}
ElvDB.profiles['FM LG v1 My Custom Copy']=custom;ElvDB.profiles.Original=custom
for i=1,3 do L.Prepare() end
assert(p.unitframe.units.party.growthDirection=='UP_LEFT')
assert(custom.unitframe.units.party.growthDirection=='DOWN')
assert(s.partyDirectionBackup==backup and backup[L.Name('HUNTER',1)]=='DOWN')
''')
case('Previously disabled layout switching still repairs saved startup data',FIXTURE+'''
s.disabled=true;s.auto=false
local p=ElvDB.profiles[L.Name('HUNTER',1)];p.unitframe.units.party.growthDirection='DOWN'
L.Prepare()
assert(p.unitframe.units.party.growthDirection=='DOWN_RIGHT' and s.disabled and not s.auto)
''')
case('Party direction repair waits for combat to finish',FIXTURE+'''
local p=ElvDB.profiles[L.Name('HUNTER',1)];p.unitframe.units.party.growthDirection='DOWN'
TEST.combat=true;L.Prepare();assert(p.unitframe.units.party.growthDirection=='DOWN')
TEST.combat=false;TEST.fire('PLAYER_REGEN_ENABLED');TEST.flush()
assert(p.unitframe.units.party.growthDirection=='DOWN_RIGHT')
''')
case('Saved party direction is repaired on addon load before entering the world',FIXTURE+'''
local p=ElvDB.profiles[L.Name('HUNTER',1)];p.unitframe.units.party.growthDirection='DOWN'
FM.API.Ready=function() return false end
TEST.fire('ADDON_LOADED','ForeverMacros')
assert(p.unitframe.units.party.growthDirection=='DOWN_RIGHT' and not E.Initialized)
''')
case('ElvUI chooses a unique dominant talent tree and leaves manual profiles alone',FIXTURE+'''
E.Initialized=true
FM.Advisor.Snapshot=function() return {class='HUNTER',spent=21,points={1,20,0}} end
L.Sync();assert(E.data:GetCurrentProfile()==L.Name('HUNTER',2) and TEST.switches==1)
L.Sync();assert(TEST.switches==1)
FM.Advisor.Snapshot=function() return {class='HUNTER',spent=40,points={20,20,0}} end
L.Sync();assert(TEST.switches==1)
ElvDB.profileKeys[E.mynameRealm]='Original';L.Sync();assert(not s.auto and E.data:GetCurrentProfile()=='Original')
''')
case('ElvUI combat changes deferred and explicit tree selection disables auto mode',FIXTURE+'''
E.Initialized=true;TEST.combat=true
assert(not L.Select(3));L.Sync();assert(not TEST.switches)
TEST.combat=false;assert(L.Select(3) and not s.auto);assert(TEST.switches==1)
assert(not L.Select(1.5) and not L.Select(2,true))
''')
case('ElvUI restore preserves backups and selects prior setup for reload',FIXTURE+'''
L.Command('restore')
assert(ElvDB.profileKeys[E.mynameRealm]=='Original')
assert(ElvPrivateDB.profileKeys[E.mynameRealm]=='PrivateOriginal' and ElvDB.global.general.UIScale==0.42)
assert(s.disabled and not s.auto);L.Prepare();assert(ElvDB.profileKeys[E.mynameRealm]=='Original')
assert(ElvDB.profiles[L.Name('HUNTER',1)] and s.previous.scale==0.42)
''')
case('ElvUI late loading creates profiles but does not mutate initialized modules','''
TEST.login();local E={Forever=true,Initialized=true,mynameRealm='T',version=15.26}
ElvUI={E};ElvDB={profiles={},profileKeys={T='Existing'},global={general={UIScale=0.42}}}
FM.Layout.Prepare();assert(FM.API.State().layout.needsSetup)
assert(ElvDB.profileKeys.T=='Existing' and not ElvPrivateDB)
''')
case('ElvUI profiles include readable action keys and distinct healer and tank arrangements','''
TEST.login();local L=FM.Layout
for _,class in ipairs(FM.Advisor.classes) do
 for tree=1,3 do
  local p=L.Profile(class,tree)
  assert(p.actionbar.bar1.buttonSize==44 and p.actionbar.bar1.hotkeyFontSize==14)
  assert(p.chat.fontSize==16 and p.unitframe.units.player.height==62)
  assert(p.movers.ShiftAB and not p.movers.StanceBarAnchor)
  for key in pairs(p) do assert(key~='bindings') end
 end
end
local healer=L.Profile('SHAMAN',3);local damage=L.Profile('SHAMAN',1)
assert(healer.unitframe.units.party.height>damage.unitframe.units.party.height)
assert(healer.movers.ElvUF_Raid1Mover~=damage.movers.ElvUF_Raid1Mover)
assert(L.Profile('DRUID',2,true).unitframe.units.target.threatPrimary)
''')

case('LG layout supplies 60 slots with utility blocks adjacent to three main rows',FIXTURE+'''
for _,class in ipairs(FM.Advisor.classes) do for tree=1,3 do
 local p=L.Profile(class,tree);local total=0
 for i=1,5 do local bar=p.actionbar['bar'..i];assert(bar.enabled);total=total+bar.buttons end
 assert(total==60)
 assert(p.actionbar.bar4.buttonsPerRow==4 and p.actionbar.bar5.buttonsPerRow==4)
 local function x(m) local a,b,c,d,e=m:match('([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)');assert(a=='BOTTOM' and c=='BOTTOM');return tonumber(d),tonumber(e) end
 local left,y=x(p.movers.ElvAB_4);local right,ry=x(p.movers.ElvAB_5)
 local mainHalf=(12*44+11*4)/2;local wingHalf=(4*44+3*4)/2
 assert(left+wingHalf < -mainHalf and right-wingHalf > mainHalf)
 assert(-mainHalf-(left+wingHalf)<30 and right-wingHalf-mainHalf<30)
 assert(y==30 and ry==30)
 assert(p.movers.MinimapMover=='TOPRIGHT,UIParent,TOPRIGHT,-24,-24')
 assert(p.unitframe.units.raid1.groupsPerRowCol==1)
end end
''')
case('LG class controls distinguish pet classes forms and resource priorities',FIXTURE+'''
assert(L.Profile('HUNTER',1).actionbar.barPet.enabled)
assert(L.Profile('WARLOCK',2).unitframe.units.pet.enable)
assert(not L.Profile('SHAMAN',2).actionbar.barPet.enabled)
assert(L.Profile('WARRIOR',3).actionbar.stanceBar.enabled)
assert(L.Profile('PALADIN',3).actionbar.stanceBar.enabled)
assert(L.Profile('DRUID',2).actionbar.stanceBar.enabled)
assert(not L.Profile('MAGE',3).actionbar.stanceBar.enabled)
assert(L.Profile('ROGUE',2).unitframe.units.player.classbar.height==18)
for _,class in ipairs({'PRIEST','SHAMAN','DRUID','PALADIN'}) do
 local heal=L.Profile(class,class=='PALADIN' and 1 or (class=='PRIEST' and 2 or 3))
 assert(heal.unitframe.units.party.healPrediction.enable and heal.unitframe.units.party.buffIndicator.enable)
end
''')
case('LG v2 upgrade retains v1 and custom fields and changes only the selected owned layout',FIXTURE+'''
local name=L.Name('HUNTER',2);local oldName=L.legacyPrefix..name:sub(#L.prefix+1)
ElvDB.profiles[oldName]={custom=91,actionbar={bar4={buttonsPerRow=1}},movers={MinimapMover='old'}}
ElvDB.profiles[name]=nil;ElvDB.profileKeys[E.mynameRealm]=oldName;s.revision=1;s.auto=false
local previous=s.previous;ElvDB.global.general.UIScale=0.63
L.Prepare()
assert(ElvDB.profiles[oldName].movers.MinimapMover=='old')
assert(ElvDB.profiles[name].custom==91 and ElvDB.profiles[name].actionbar.bar4.buttonsPerRow==4)
assert(ElvDB.profileKeys[E.mynameRealm]==name and s.beforeV2.profile==oldName)
assert(s.previous==previous and not s.auto and ElvDB.global.general.UIScale==0.63)
ElvDB.profiles[name].actionbar.bar4.buttonSize=50;L.Prepare();assert(ElvDB.profiles[name].actionbar.bar4.buttonSize==50)
L.Command('previous');assert(s.disabled and ElvDB.profileKeys[E.mynameRealm]==oldName)
''')
case('LG upgrade leaves an unrelated selected profile and paused layout intact',FIXTURE+'''
s.revision=1;ElvDB.profileKeys[E.mynameRealm]='Original';L.Prepare()
assert(ElvDB.profileKeys[E.mynameRealm]=='Original')
s.revision=1;s.disabled=true;ElvDB.profileKeys[E.mynameRealm]='FM LG v1 Hunter Beast Mastery';L.Prepare()
assert(ElvDB.profileKeys[E.mynameRealm]=='FM LG v1 Hunter Beast Mastery')
''')
case('Move windows uses native ElvUI movers and refuses combat without sorting',FIXTURE+'''
E.Initialized=true;E.ToggleMoveMode=function(self) self.moves=(self.moves or 0)+1 end
assert(L.Move() and E.moves==1 and FM.Bags.unlocked)
TEST.combat=true;assert(not L.Move() and E.moves==1)
TEST.combat=false;E.ToggleMoveMode=nil;assert(not L.Move())
''')

case('Frame spacing upgrades old defaults once per account and retains custom positions',FIXTURE+'''
ElvDB.global.foreverMacrosFrameSpacing=nil
local name=L.Name('SHAMAN',2);local p=ElvDB.profiles[name]
p.movers.ElvUF_PlayerMover='BOTTOM,UIParent,BOTTOM,-158,272'
p.movers.ElvUF_TargetMover='BOTTOM,UIParent,BOTTOM,158,272'
p.movers.ElvUF_PlayerCastbarMover='BOTTOM,UIParent,BOTTOM,0,232'
p.unitframe.units.player.castbar.width=580
p.movers.ElvUF_Raid1Mover='BOTTOMLEFT,UIParent,BOTTOM,-945,290'
p.movers.ElvUF_FocusMover='BOTTOM,UIParent,BOTTOM,600,600'
local unrelated={movers={ElvUF_PlayerMover=p.movers.ElvUF_PlayerMover}}
ElvDB.profiles.Original=unrelated
local selected=ElvDB.profileKeys[E.mynameRealm]
L.Prepare()
local saved=ElvDB.global.foreverMacrosFrameSpacing[name]
assert(saved.previous.ElvUF_PlayerMover=='BOTTOM,UIParent,BOTTOM,-158,272')
assert(saved.previousPlayerCastbarWidth==580 and p.unitframe.units.player.castbar.width==290)
assert(p.movers.ElvUF_PlayerMover==L.Profile('SHAMAN',2).movers.ElvUF_PlayerMover)
assert(p.movers.ElvUF_TargetMover==L.Profile('SHAMAN',2).movers.ElvUF_TargetMover)
assert(p.movers.ElvUF_Raid1Mover==L.Profile('SHAMAN',2).movers.ElvUF_Raid1Mover)
assert(p.movers.ElvUF_FocusMover=='BOTTOM,UIParent,BOTTOM,600,600' and not saved.previous.ElvUF_FocusMover)
assert(unrelated.movers.ElvUF_PlayerMover=='BOTTOM,UIParent,BOTTOM,-158,272')
assert(ElvDB.profileKeys[E.mynameRealm]==selected and s.auto)
-- Another character must not reapply migration to an intentionally restored point.
p.movers.ElvUF_PlayerMover=saved.previous.ElvUF_PlayerMover
FM.API.State().layout={revision=2}
L.Prepare()
assert(p.movers.ElvUF_PlayerMover==saved.previous.ElvUF_PlayerMover)
assert(ElvDB.global.foreverMacrosFrameSpacing[name]==saved)
-- Recreating a removed profile uses the updated shared geometry.
ElvDB.profiles[name]=nil;L.Prepare()
assert(ElvDB.profiles[name].movers.ElvUF_PlayerMover==L.Profile('SHAMAN',2).movers.ElvUF_PlayerMover)
''')
case('Frame spacing migration waits for combat and is ready before ElvUI starts',FIXTURE+'''
local name=L.Name('HUNTER',1);local p=ElvDB.profiles[name]
ElvDB.global.foreverMacrosFrameSpacing=nil
p.movers.ElvUF_TargetMover='BOTTOM,UIParent,BOTTOM,158,272'
TEST.combat=true;L.Prepare()
assert(p.movers.ElvUF_TargetMover=='BOTTOM,UIParent,BOTTOM,158,272')
assert(not ElvDB.global.foreverMacrosFrameSpacing)
TEST.combat=false;TEST.fire('ADDON_LOADED','ForeverMacros')
assert(not E.Initialized and p.movers.ElvUF_TargetMover==L.Profile('HUNTER',1).movers.ElvUF_TargetMover)
''')

MOVE='''
TEST.login();local W=FM.WindowMover
local root=CreateFrame('Frame','CharacterFrame',UIParent)
root.GetEffectiveScale=function() return 1 end;root.GetCenter=function() return 500,500 end
root.GetTop=function() return 900 end;UIParent.GetEffectiveScale=function() return 1 end
local data={storage={frameName='CharacterFrame',addOnName='BlizzMove'}}
local bm={initialized=true,DB={savePosStrategy='session'},FrameData={[root]=data}}
bm.SavePositionStrategyChanged=function(_,old,new) assert(old=='session' and new=='permanent') end
bm.GetFrameFromName=function(_,addon,name) if name=='CharacterFrame' then return root end end
LibStub=function() return {GetAddon=function() return bm end} end
BlizzMoveAPI={GetVersion=function() return 'v3.8.4' end,disabled={}}
BlizzMoveAPI.IsFrameDisabled=function(self,addon,name) return self.disabled[name] end
BlizzMoveAPI.SetFrameDisabled=function(self,addon,name,value)
 assert(not TEST.combat);self.disabled[name]=value
 if name=='CharacterFrame' then data.storage.disabled=value;root:EnableMouse(not value) end
end
IsShiftKeyDown=function() return false end;IsControlKeyDown=IsShiftKeyDown;IsAltKeyDown=IsShiftKeyDown
TEST.mouseY=890;GetCursorPosition=function() return 500,TEST.mouseY end
W.Refresh()
'''
case('Window header right-click toggles BlizzMove while native bags have one owner',MOVE+'''
assert(BlizzMoveAPI.disabled.ContainerFrameCombinedBags and BlizzMoveAPI.disabled.ContainerFrame1)
root.scripts.OnMouseUp(root,'RightButton')
assert(data.storage.disabled and root:IsMouseEnabled() and FM.API.State().windows.locked.CharacterFrame)
TEST.flush()
root.scripts.OnMouseUp(root,'RightButton')
assert(not data.storage.disabled and not FM.API.State().windows.locked.CharacterFrame)
assert(bm.DB.savePosStrategy=='permanent')
''')
case('Window locks ignore body clicks modifier shortcuts and combat',MOVE+'''
TEST.mouseY=500;root.scripts.OnMouseUp(root,'RightButton');assert(not data.storage.disabled)
TEST.mouseY=890;IsShiftKeyDown=function() return true end;root.scripts.OnMouseUp(root,'RightButton');assert(not data.storage.disabled)
IsShiftKeyDown=function() return false end;TEST.combat=true
root.scripts.OnMouseUp(root,'RightButton');W.Refresh();assert(not data.storage.disabled)
''')
case('Persistently locked BlizzMove frame regains a usable title after addon reload',MOVE+'''
root.scripts.OnMouseUp(root,'RightButton');W.hooked={};root:EnableMouse(false)
W.Refresh();assert(root:IsMouseEnabled() and data.storage.disabled)
''')

case('Secure BlizzMove overlays receive header locks without toggling twice on propagation',MOVE+'''
local handle=CreateFrame('Frame',nil,root);bm.MoveHandles={[handle]=true};W.Refresh()
assert(handle.scripts.OnMouseUp)
handle.scripts.OnMouseUp(handle,'RightButton')
root.scripts.OnMouseUp(root,'RightButton')
assert(data.storage.disabled)
TEST.flush();root.scripts.OnMouseUp(root,'RightButton');assert(not data.storage.disabled)
TEST.flush()
local replacement=CreateFrame('Frame',nil,root);bm.MoveHandles={[replacement]=true};W.Refresh()
replacement.scripts.OnMouseUp(replacement,'RightButton');assert(data.storage.disabled)
''')
