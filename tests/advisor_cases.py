"""Dated talent plans and read-only guidance. No simulated optimal DPS or live FPS claims."""
CASES = []
def case(title, code): CASES.append((title, code))

FIXTURE = '''
local T,D=FM.Advisor,FM.TalentData
TEST.nodes,TEST.nodeList,TEST.definitions,TEST.nodeReads={},{},{},0
for t,tree in ipairs(D.classes[TEST.class].trees) do
 for i,talent in ipairs(tree.talents) do
  local id=t*100+i
  TEST.nodeList[#TEST.nodeList+1]=id
  TEST.nodes[id]={ID=id,isVisible=true,maxRanks=talent.max,currentRank=0,canPurchaseRank=true,
   entryIDs={id},posX=t*10000+talent.col*600,posY=talent.row*600}
  TEST.definitions[id]={spellID=talent.spell or 999000+id}
  if not talent.spell then TEST.names[999000+id]=talent.name end
 end
end
C_ClassTalents={GetActiveConfigID=function() return 1 end}
C_Traits={
 ConfigHasStagedChanges=function() return false end,
 GetConfigInfo=function() return {treeIDs={7}} end,
 GetTreeNodes=function() return TEST.nodeList end,
 GetNodeInfo=function(_,id) TEST.nodeReads=TEST.nodeReads+1; return TEST.nodes[id] end,
 GetEntryInfo=function(_,id) return {definitionID=id} end,
 GetDefinitionInfo=function(id) return TEST.definitions[id] end,
 PurchaseRank=function() TEST.denied=TEST.denied+1; error('No spending') end,
 CommitConfig=function() TEST.denied=TEST.denied+1; error('No committing') end,
 RollbackConfig=function() TEST.denied=TEST.denied+1; error('No rollback') end,
}
LearnTalent=function() TEST.denied=TEST.denied+1; error('No spending') end
'''

case("Advisor data covers all nine classes, 27 trees and 96 distinct plans", '''
local seen,trees,talents={ },0,0
assert(#FM.TalentData.builds==96)
for _,class in ipairs(FM.Advisor.classes) do
 for t,tree in ipairs(FM.TalentData.classes[class].trees) do
  trees=trees+1; talents=talents+#tree.talents
  assert(#FM.Advisor.Builds(class,t)>0,class..tree.name)
  assert(#FM.Coach.cards[class][t]==3)
 end
end
assert(trees==27 and talents==468)
for _,b in ipairs(FM.TalentData.builds) do
 assert(not seen[b.id],b.id);seen[b.id]=true
 assert(b.url:match('^https://') and b.calculator:match('^https://'))
end
''')

case("Every plan point satisfies rows, prerequisites, caps and its final rank totals", '''
for _,b in ipairs(FM.TalentData.builds) do
 local d=FM.TalentData.classes[b.class];local ranks={{},{},{}}; local totals={0,0,0}
 for ordinal,step in ipairs(b.order) do
  local t,i=step[1],step[2];local talent=d.trees[t].talents[i]
  assert(totals[t]>=(talent.row-1)*5,b.id..':'..ordinal)
  assert(not talent.req or ranks[t][talent.req]==d.trees[t].talents[talent.req].max,b.id)
  ranks[t][i]=(ranks[t][i] or 0)+1;totals[t]=totals[t]+1
  assert(ranks[t][i]<=talent.max)
 end
 for t,tree in ipairs(d.trees) do
  assert(totals[t]==b.points[t])
  for i in ipairs(tree.talents) do assert((ranks[t][i] or 0)==FM.Advisor.TargetRank(b,t,i),b.id) end
 end
end
''')

for cls in ['WARRIOR','PALADIN','HUNTER','ROGUE','PRIEST','SHAMAN','MAGE','WARLOCK','DRUID']:
    case(f"{cls}: complete trait snapshot maps by identity and geometry, then caches",f'TEST.class="{cls}"\n'+FIXTURE+'''
TEST.login();local s=assert(T.Snapshot(true));assert(s.class==TEST.class and s.spent==0)
local reads=TEST.nodeReads;T.Snapshot();T.Snapshot();assert(TEST.nodeReads==reads)
for tree=1,3 do
 local b=assert(T.Builds(TEST.class,tree)[1]);local p=T.Progress(b,s)
 assert(#p.next==3 and p.next[1].ordinal==1 and p.next[1].available)
end
''')

case("Advisor next points follow every prefix of every bundled build", '''
for _,b in ipairs(FM.TalentData.builds) do
 local s={class=b.class,ranks={{},{},{}},nodes={{},{},{}}}
 for t,tree in ipairs(FM.TalentData.classes[b.class].trees) do
  for i in ipairs(tree.talents) do s.ranks[t][i]=0;s.nodes[t][i]={available=true} end
 end
 for ordinal,step in ipairs(b.order) do
  local p=FM.Advisor.Progress(b,s)
  assert(p.next[1].ordinal==ordinal and p.next[1].tree==step[1] and p.next[1].index==step[2],b.id)
  s.ranks[step[1]][step[2]]=s.ranks[step[1]][step[2]]+1
 end
 local done=FM.Advisor.Progress(b,s)
 assert(#done.next==0 and done.status:find('plan is complete',1,true))
end
''')

case("Advisor suppresses suggestions for off-plan talents and another class", FIXTURE+'''
TEST.login();local s=assert(T.Snapshot(true));local b=T.Builds(TEST.class,1)[1]
local found
for t,tree in ipairs(D.classes[TEST.class].trees) do
 for i,talent in ipairs(tree.talents) do
  if not found and T.TargetRank(b,t,i)<talent.max then s.ranks[t][i]=T.TargetRank(b,t,i)+1;found=true end
 end
end
local p=T.Progress(b,s);assert(p.outside==1 and #p.next==0)
s.class='WARRIOR';assert(#T.Progress(b,s).next==0)
''')

FAILURES = {
 "missing APIs": 'C_Traits=nil',
 "no active config": 'C_ClassTalents.GetActiveConfigID=function() return nil end',
 "staged changes": 'C_Traits.ConfigHasStagedChanges=function() return true end',
 "unknown staging state": 'C_Traits.ConfigHasStagedChanges=nil',
 "multiple trees": 'C_Traits.GetConfigInfo=function() return {treeIDs={7,8}} end',
 "partial tree": 'table.remove(TEST.nodeList)',
 "duplicate node": 'TEST.nodeList[#TEST.nodeList+1]=TEST.nodeList[1]',
 "unknown spell": 'TEST.definitions[101].spellID=999999',
 "moved talent": 'TEST.nodes[101].posY=TEST.nodes[101].posY+600',
 "rank cap mismatch": 'TEST.nodes[101].maxRanks=99',
 "negative rank": 'TEST.nodes[101].currentRank=-1',
 "too many ranks": 'TEST.nodes[101].currentRank=99',
 "secret rank": 'TEST.nodes[101].currentRank={secret=true}',
 "secret node": 'TEST.nodes[101]={secret=true}',
 "secret ID": 'TEST.definitions[101].spellID={secret=true}',
 "secret position": 'TEST.nodes[101].posY={secret=true}',
 "secret visibility": 'TEST.nodes[101].isVisible={secret=true}',
 "secret eligibility": 'TEST.nodes[101].canPurchaseRank={secret=true}',
 "API throws": 'C_Traits.GetNodeInfo=function() error("unavailable") end',
 "choice node": 'TEST.nodes[101].entryIDs={101,102}',
}
for title, mutation in FAILURES.items():
    case("Advisor fails closed for " + title, FIXTURE+'''
TEST.login();assert(T.Snapshot(true))
'''+mutation+'''
local result,reason=T.Snapshot(true);assert(not result and type(reason)=='string')
assert(T.snapshot==nil)
''')

case("Advisor makes no combat reads and clears stale snapshots on respec",FIXTURE+'''
TEST.login();assert(T.Snapshot(true));local reads=TEST.nodeReads
TEST.combat=true;TEST.fire('PLAYER_REGEN_DISABLED');TEST.flush()
assert(not T.Snapshot(true));assert(TEST.nodeReads==reads and not T.snapshot)
TEST.combat=false;TEST.nodes[101].currentRank=1;TEST.fire('PLAYER_REGEN_ENABLED');TEST.flush()
assert(T.Snapshot().ranks[1][1]==1)
TEST.nodes[101].currentRank=0;TEST.fire('TRAIT_CONFIG_UPDATED');TEST.flush()
assert(T.Snapshot().ranks[1][1]==0)
''')

case("Advisor uses client purchase eligibility without guessing character levels",FIXTURE+'''
TEST.login();local b=T.Builds(TEST.class,1)[1];local step=b.order[1]
TEST.nodes[step[1]*100+step[2]].canPurchaseRank=false
local s=assert(T.Snapshot(true));local p=T.Progress(b,s)
assert(not p.next[1].available and p.status:find('not currently purchasable',1,true))
''')

case("Coach UI browses all classes, trees and plans without changing macros or talents",FIXTURE+'''
TEST.learnAll(TEST.class);TEST.login();local writes,edits=TEST.writes,TEST.edits
TEST.command('talents');assert(FM.UI.tab=='Coach');local u=FM.CoachUI
for _,class in ipairs(T.classes) do
 u.classes[class]:Click()
 for tree=1,3 do
  u.trees[tree]:Click();assert(u.selected.class==class)
  for _,b in ipairs(T.Builds(class,tree)) do
   u.selected=b;FM.UI.Refresh();u.orderNext:Click();u.orderPrev:Click()
  end
  u.modes['Combat guide']:Click();u.modes.Talents:Click()
 end
end
assert(TEST.writes==writes and TEST.edits==edits)
''')

case("Coach follows only the player's selected plan and stores it per character",FIXTURE+'''
TEST.login();TEST.command('coach');local u=FM.CoachUI
u.use:Click();assert(T.Settings().build==u.selected.id)
local saved=T.Settings().build;u.classes.WARRIOR:Click();assert(not u.use:IsEnabled())
u.use:Click();assert(T.Settings().build==saved)
u.Copy(u.selected.url);assert(u.linkBox:GetText()==u.selected.url)
''')

case("Coach HUD restores, hides, persists its position and never polls combat",FIXTURE+'''
TEST.login();TEST.command('coach');local u=FM.CoachUI
u.hudToggle:Click();assert(T.Settings().hud and u.hud:IsShown())
u.hud:SetPoint('CENTER',UIParent,'CENTER',20,-160)
u.hud.scripts.OnDragStop(u.hud);assert(T.Settings().position.x==20)
local reads=TEST.nodeReads
TEST.combat=true;TEST.fire('PLAYER_REGEN_DISABLED');TEST.flush()
assert(u.hud:IsShown() and TEST.nodeReads==reads)
for _,frame in ipairs(TEST.frames) do assert(not frame.scripts.OnUpdate) end
assert(#TEST.timers==0)
TEST.command('coach off');assert(not u.hud:IsShown() and not T.Settings().hud)
''')

case("Coach saved enabled HUD reappears on world entry without opening main window",FIXTURE+'''
TEST.login();T.Settings().hud=true;TEST.fire('PLAYER_ENTERING_WORLD');TEST.flush()
assert(FM.CoachUI.hud:IsShown() and not FM.UI.frame:IsShown())
''')

case("Coach native capability check never advertises an attached prediction engine",'''
TEST.login();assert(FM.Advisor.NativeStatus():find('No usable',1,true))
C_AssistedCombat={IsAvailable=function() return true end,GetNextCastSpell=function() error('Must not infer combat') end}
assert(FM.Advisor.NativeStatus():find('not connected',1,true))
C_AssistedCombat.IsAvailable=function() return {secret=true} end
assert(FM.Advisor.NativeStatus():find('No usable',1,true))
TEST.combat=true;C_AssistedCombat.IsAvailable=function() error('No combat query') end
assert(FM.Advisor.NativeStatus():find('after combat',1,true))
''')

case("Coach cards resolve learned ranks and public direct-spell bindings",'''
TEST.class='SHAMAN';TEST.learn(8044,'Earth Shock');TEST.login()
ActionButton1={action=1}
GetActionInfo=function() return 'spell',8044 end
GetBindingKey=function() return '4' end
C_Spell.GetSpellTexture=function() return 136026 end
local cards=FM.Coach.ReadCards('SHAMAN',2)
assert(cards[3].learned and cards[3].key=='4' and cards[3].icon==136026)
GetBindingKey=function() return {secret=true} end
assert(FM.Coach.ReadCards('SHAMAN',2)[3].key==nil)
TEST.combat=true;assert(FM.Coach.ReadCards('SHAMAN',2)==nil)
''')

case("Coach isolated preview cannot override the active HUD class",FIXTURE+'''
TEST.login();TEST.command('coach');local u=FM.CoachUI
u.hudToggle:Click();local tree=FM.Coach.Tree()
u.classes.WARRIOR:Click();u.trees[3]:Click();u.hudToggle:Click();u.hudToggle:Click()
assert(FM.Coach.Tree()==tree and u.hudTitle:GetText():find(D.classes.HUNTER.trees[tree].name,1,true))
''')

case("Coach coalesces event bursts and has no hidden periodic talent reads",FIXTURE+'''
TEST.login();local reads=TEST.nodeReads
for i=1,100 do TEST.fire('TRAIT_NODE_CHANGED') end
TEST.flush();assert(TEST.nodeReads==reads)
TEST.command('coach');reads=TEST.nodeReads
for i=1,100 do TEST.fire('TRAIT_NODE_CHANGED') end
TEST.flush();assert(TEST.nodeReads-reads==#TEST.nodeList and #TEST.timers==0)
''')

for locale in ['deDE','frFR']:
    case(f"Priest missing spell identity fails closed on {locale}",'TEST.class="PRIEST"\n'+FIXTURE+f'''
TEST.login();GetLocale=function() return '{locale}' end
local s,reason=T.Snapshot(true)
assert(not s and reason:find('differs from the client',1,true))
''')

case("Priest missing spell identity requires an exact English talent name",'TEST.class="PRIEST"\n'+FIXTURE+'''
TEST.login();for id in pairs(TEST.names) do if id>999000 then TEST.names[id]='Other talent' end end
assert(not T.Snapshot(true))
''')

case("Changing plans in combat keeps the HUD title paired with its cached cards",FIXTURE+'''
TEST.login();TEST.command('coach');local u=FM.CoachUI
u.hudToggle:Click();local title=u.hudTitle:GetText()
TEST.combat=true;T.Select(T.Builds(TEST.class,3)[1]);u.RefreshHUD()
assert(u.hudTitle:GetText()==title)
TEST.combat=false;u.RefreshHUD()
assert(u.hudTitle:GetText():find(D.classes[TEST.class].trees[3].name,1,true))
''')
