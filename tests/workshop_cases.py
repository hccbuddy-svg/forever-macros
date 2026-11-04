"""Workshop contracts. Native cast progression still requires a live client check."""
CASES = []
def case(title, code):
    CASES.append((title, code))

SETUP = '''
TEST.class="PRIEST"; TEST.learn(1243,"Power Word: Fortitude"); TEST.learn(588,"Inner Fire")
TEST.login(); W=assert(FM.Workshop); model=assert(W.Starter("PRIEST"))
'''

case("Workshop compiles a learned class starter and does not execute it", SETUP + '''
local d=assert(W.Definition(1,model)); local body=assert(FM.Core.Render(d,FM.API.Resolve))
assert(body:find("/castsequence [@player,nocombat] reset=alt Power Word: Fortitude, Inner Fire",1,true))
assert(body:find("/stopmacro [channeling]",1,true) and #body<=255)
assert(not TEST.named("FM Seq1")); assert(W.Install(1,model)); TEST.flush()
assert(TEST.named("FM Seq1").body==body and W.State().slots[1])
''')

case("Workshop imports are data only, bounded and class checked", SETUP + '''
local text=assert(W.Export(model)); assert(W.Export(assert(W.Import(text)))==text)
for _,bad in ipairs({"return os.execute('no')", "!GSE:abc", text.."|extra", string.rep("a",6145),
    text:gsub("FMSEQ1", "FMSEQ9"),text:gsub("PRIEST", "WARRIOR"),text:gsub("i588", "i99999999")}) do
    assert(not W.Import(bad))
end
assert(not W.Validate({class="PRIEST",steps={}, mode="sequence",target="self",reset="alt",ooc=true,caster=false,channel=true,script="evil"}))
assert(not TEST.named("FM Seq1"))
''')

case("Workshop queue freezes the requested draft and honors combat", SETUP + '''
local original=assert(W.Export(model)); TEST.combat=true
assert(W.Install(1,model)); model.steps[2]=model.steps[1]
assert(not W.State().slots[1] and not TEST.named("FM Seq1"))
TEST.combat=false; TEST.fire("PLAYER_REGEN_ENABLED"); TEST.flush()
assert(W.Export(W.State().slots[1])==original)
''')

case("Workshop manual edits and icons survive rejected updates", SETUP + '''
assert(W.Install(1,model)); local m=TEST.named("FM Seq1"); m.icon=998; local saved=W.Export(W.State().slots[1])
m.body="/say My personal edit"; model.ooc=false; W.Install(1,model); TEST.flush()
assert(m.body=="/say My personal edit" and m.icon==998 and W.Export(W.State().slots[1])==saved)
assert(#W.History(1)==0)
''')

case("Workshop history only records confirmed changes and restores through drafts", SETUP + '''
assert(W.Install(1,model)); local original=assert(W.Export(model))
model.ooc=false; assert(W.Install(1,model)); TEST.flush()
assert(#W.History(1)==1 and W.Export(W.History(1)[1])==original)
local m=TEST.named("FM Seq1"); local current=m.body; local old=W.Copy(W.History(1)[1]); old.channel=false
assert(m.body==current and W.History(1)[1].channel==true)
assert(W.Install(1,W.History(1)[1])); TEST.flush(); assert(W.Export(W.State().slots[1])==original)
for i=1,15 do model.ooc=not model.ooc; W.Install(1,model) end
assert(#W.History(1)<=10)
''')

case("Workshop profiles preview all slots before changing macros", SETUP + '''
assert(W.Install(1,model)); model.ooc=false; assert(W.Install(2,model)); TEST.flush()
assert(W.SaveProfile("Dungeon")); local profile=assert(W.Profile("Dungeon")); local export=assert(W.ExportProfile(profile))
assert(W.ExportProfile(assert(W.ImportProfile(export)))==export)
local writes,edits=TEST.writes,TEST.edits; assert(W.Plan(profile)); assert(TEST.writes==writes and TEST.edits==edits)
TEST.named("FM Seq2").body="/say manual"; profile.slots[1].channel=false
assert(not W.ApplyProfile(profile)); assert(TEST.named("FM Seq1").body:find("channeling",1,true))
assert(TEST.named("FM Seq2").body=="/say manual")
''')

case("Workshop rejects delimiter injection and macros over 255 bytes", SETUP + '''
local d=assert(W.Definition(1,model))
assert(not FM.Core.Render(d,function(s) return s.english..", Injected" end))
assert(not FM.Core.Render(d,function(s) return string.rep("x",240) end))
model.steps={}; for i=1,9 do model.steps[i]="i588" end; assert(not W.Validate(model))
''')

case("Workshop detects missing skills and modifier binding conflicts without writes", SETUP + '''
assert(W.Install(1,model)); FM.Manager.BindingsFor=function() return {"ALT-1"} end
local writes,edits=TEST.writes,TEST.edits; local report=assert(W.Audit())
assert(table.concat(report,"\\n"):find("ALT-1",1,true))
assert(TEST.writes==writes and TEST.edits==edits)
TEST.known[588]=nil; assert(not W.Plan({class="PRIEST",slots={[1]=model}}))
''')

for cls in ["WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID"]:
    case(f"Workshop {cls}: starter learns, renders, shares and installs only on request", f'''
TEST.class="{cls}"; W=FM.Workshop; local m=assert(W.Starter(TEST.class))
for _,key in ipairs(m.steps) do local s=assert(W.registry[TEST.class][key]); TEST.learn(s.id,s.english) end
TEST.login(); assert(not TEST.named("FM Seq1"))
assert(W.Export(assert(W.Import(W.Export(m))))==W.Export(m))
local body=assert(W.Preview(1,m)); assert(#body<=255 and not body:find("/startattack",1,true))
assert(W.Install(1,m)); TEST.flush(); assert(TEST.named("FM Seq1").body==body)
local writes,edits=TEST.writes,TEST.edits
TEST.fire("SPELLS_CHANGED"); TEST.flush(); assert(TEST.writes==writes and TEST.edits==edits)
''')

case("Workshop drafts persist separately and cannot auto-install on events", SETUP + '''
assert(W.SaveDraft(1,model)); model.ooc=false; assert(W.State().drafts[1].ooc)
TEST.fire("SPELLS_CHANGED"); TEST.fire("PLAYER_ENTERING_WORLD"); TEST.flush()
assert(not TEST.named("FM Seq1") and not W.State().slots[1])
assert(not W.SaveDraft(0,model) and not W.SaveDraft(9,model))
''')

case("Workshop slot reserves and pause reject installation without claiming success", SETUP + '''
ForeverMacrosDB.reserve=30; assert(not W.Install(1,model)); assert(not W.State().slots[1])
ForeverMacrosDB.reserve=2; ForeverMacrosDB.enabled=false
assert(not W.Install(1,model)); assert(not TEST.named("FM Seq1"))
''')

case("Workshop uncertain writes do not commit a model or history", SETUP + '''
assert(W.Install(1,model)); local original=W.Export(model)
model.ooc=false; TEST.badEditReturn=true
assert(not W.Install(1,model)); assert(FM.Manager.fault)
assert(W.Export(W.State().slots[1])==original and #W.History(1)==0)
''')

case("Workshop reload registration uses confirmed definitions and preserves user edits", SETUP + '''
assert(W.Install(1,model)); local count=#FM.Catalog
W.Initialize(); W.Initialize(); assert(#FM.Catalog==count)
TEST.named("FM Seq1").body="/say Mine"; TEST.fire("ADDON_LOADED","ForeverMacros"); TEST.fire("PLAYER_ENTERING_WORLD"); TEST.flush()
assert(TEST.named("FM Seq1").body=="/say Mine")
''')

case("Workshop damaged state and future schemas are retained without throwing", SETUP + '''
ForeverMacrosDB.workshop={schema=2,secretMarker="preserve"}
assert(not W.State()); assert(not W.Install(1,model)); W.Initialize()
assert(ForeverMacrosDB.workshop.secretMarker=="preserve")
ForeverMacrosDB.workshop={schema=1,slots={[1]=42},history={},profiles={}}
W.Initialize(); assert(not W.SaveProfile("Bad"))
''')

case("Workshop profile import rejects duplicates oversized strings and scripts", SETUP + '''
local one="1:"..W.Export(model); local header="FMPROFILE1:PRIEST\\n"
assert(not W.ImportProfile(header..one.."\\n"..one))
assert(not W.ImportProfile(header.."9:"..W.Export(model)))
assert(not W.ImportProfile(header.."1:loadstring('bad')"))
assert(not W.ImportProfile(string.rep("x",6145)))
assert(not W.ImportProfile(header..one.."\\n\\n"))
assert(not W.ImportProfile(header:gsub("PRIEST","DRUID")..one))
''')

case("Workshop profile application stops on API error and reports partial work", SETUP + '''
local second=W.Copy(model); second.ooc=false
local p={class="PRIEST",slots={[1]=model,[2]=second}}
local original=CreateMacro; local count=0
CreateMacro=function(...) count=count+1; if count==2 then error("Second write failed") end; return original(...) end
local ok,reason=W.ApplyProfile(p); assert(not ok and reason:find("Applied 1 slots",1,true))
assert(TEST.named("FM Seq1") and not TEST.named("FM Seq2"))
assert(W.State().slots[1] and not W.State().slots[2])
''')

case("Workshop profile limits do not overwrite named builds", SETUP + '''
assert(W.Install(1,model))
for i=1,12 do assert(W.SaveProfile("Build "..i)) end
assert(not W.SaveProfile("Build 13")); assert(not W.SaveProfile("Build 1"))
assert(not W.SaveProfile("Bad|name") and not W.SaveProfile(string.rep("a",25)))
local p=W.Profile("Build 1"); p.slots[1].ooc=false; assert(W.Profile("Build 1").slots[1].ooc)
''')

case("Workshop modifier compiler preserves explicit choices and precedence", SETUP + '''
model.mode="modifier"; model.steps={"i1243","i588","i1243"}
local body=assert(FM.Core.Render(W.Definition(1,model),FM.API.Resolve))
assert(body:find("/cast [mod:ctrl,@player,nocombat] Power Word: Fortitude; [mod:shift,@player,nocombat] Inner Fire; [nomod,@player,nocombat] Power Word: Fortitude",1,true))
assert(not body:find("reset=",1,true)); model.steps[4]="i588"; assert(not W.Validate(model))
''')

case("Workshop localized spell names are resolved by learned IDs", SETUP + '''
TEST.locale="frFR"; TEST.learn(1243,"Mot de pouvoir : Robustesse"); TEST.learn(588,"Feu interieur")
W.RefreshCache(); local body=assert(W.Preview(1,model))
assert(body:find("Mot de pouvoir : Robustesse, Feu interieur",1,true))
''')

case("Workshop patch audit works with real manager binding lookup and no action bars", SETUP + '''
assert(W.Install(1,model)); local writes=TEST.writes
local report=assert(W.Audit()); assert(#report>=3 and TEST.writes==writes)
TEST.combat=true; assert(not W.Audit() and not W.Plan({class="PRIEST",slots={[1]=model}}))
''')

case("Workshop GUI supports drafts history sharing builds and combat cancellation", SETUP + '''
TEST.command(""); TEST.clickText("Sequences"); local V=FM.WorkshopUI
assert(FM.UI.panels.Sequences:IsShown() and V.preview:GetText():find("castsequence",1,true))
TEST.clickText("Save draft"); assert(W.State().drafts[1] and not TEST.named("FM Seq1"))
TEST.clickText("Install this draft"); assert(TEST.named("FM Seq1"))
V.ooc:Click(); TEST.clickText("Install this draft"); assert(#W.History(1)==1)
V.history:Click(); assert(V.drafts[1].ooc and not W.State().slots[1].ooc)
TEST.clickText("Share / import"); local exported=V.shareBox:GetText(); V.shareBox:SetText("bad")
V.shareImport:Click(); assert(V.dialog:IsShown() and V.shareMessage:GetText()~="")
V.shareBox:SetText(exported); V.shareImport:Click(); assert(not V.dialog:IsShown())
TEST.combat=true; TEST.clickText("Install this draft"); assert(FM.Manager.pending.workshop_1)
TEST.clickText("Cancel queued"); assert(not FM.Manager.pending.workshop_1)
TEST.combat=false; TEST.clickText("Builds"); V.profileNameBox:SetText("Raid")
TEST.clickText("Save installed slots as build"); assert(W.Profile("Raid"))
TEST.clickText("Preview listed slots"); assert(V.plan and V.apply:IsEnabled())
TEST.clickText("Apply previewed build"); assert(not V.plan)
TEST.clickText("Run read-only patch check"); assert(V.dialog:IsShown())
''')

case("Workshop has no recurring tick and UI previews cannot mutate macros", SETUP + '''
TEST.command(""); TEST.clickText("Sequences"); local writes,edits=TEST.writes,TEST.edits
for i=1,25 do FM.WorkshopUI.search:SetText(i%2==0 and "fire" or ""); FM.UI.Refresh() end
TEST.flush(); assert(TEST.writes==writes and TEST.edits==edits and #TEST.timers==0)
for _,f in ipairs(TEST.frames) do assert(not f.scripts.OnUpdate) end
''')

case("Workshop reuses spell cache including automatic preparation spells", SETUP + '''
local calls,original=0,FM.API.Resolve
FM.API.Resolve=function(spec) calls=calls+1; return original(spec) end
local seen={}; for _,d in ipairs(FM.Catalog) do if d.class=="PRIEST" or d.class=="ALL" then
    for _,s in ipairs(d.spells) do seen[(s.pet and "pet:" or "player:")..(s.id or s.english)]=true end
end end
W.RefreshCache(seen); assert(calls==0)
''')

case("Workshop collects secondary and repeated default-bar bindings read-only", SETUP + '''
assert(W.Install(1,model)); local snapshot=assert(FM.API.Snapshot()); local index
for _,m in ipairs(snapshot.macros) do if m.name=="FM Seq1" then index=m.index end end
ActionButton1=CreateFrame("Button"); ActionButton1.action=1
ActionButton2=CreateFrame("Button"); ActionButton2.action=2
GetActionInfo=function() return "macro",index end
GetBindingKey=function() return "1","ALT-1" end
local keys=FM.Manager.BindingsFor("FM Seq1"); assert(#keys==2)
local report=table.concat(assert(W.Audit()),"\\n"); assert(report:find("ALT-1",1,true))
''')

case("Workshop refuses paused updates even when the requested definition is unchanged", SETUP + '''
assert(W.Install(1,model)); ForeverMacrosDB.enabled=false
assert(not W.Install(1,model))
TEST.combat=true; assert(not W.Install(1,model)); assert(not FM.Manager.pending.workshop_1)
''')

case("Workshop command routes open the requested panel and audit stays read-only", SETUP + '''
TEST.command("sequences"); assert(FM.UI.tab=="Sequences" and FM.UI.frame:IsShown())
TEST.command("builds"); assert(FM.UI.tab=="Builds" and FM.UI.frame:IsShown())
local writes,edits=TEST.writes,TEST.edits; TEST.command("check")
assert(TEST.writes==writes and TEST.edits==edits)
''')

case("Workshop lint identifies malformed conditions and scripts without editing them", SETUP + '''
assert(#W.Lint("#showtooltip\\n/cast [@player] Inner Fire")==0)
assert(#W.Lint("/cast [@player Inner Fire")==1)
assert(#W.Lint("/cast [[harm]] Smite")==1)
assert(#W.Lint("/run print('test')\\n/click Example")==2)
assert(#W.Lint(string.rep("x",256))==1)
assert(W.Install(1,model)); TEST.named("FM Seq1").body="/run print('my code')"
local edits=TEST.edits; local report=table.concat(W.Audit(),"\\n")
assert(report:find("Lua script needs manual review",1,true) and TEST.edits==edits)
''')

case("Workshop invalid import corpus always rejects without evaluating input", SETUP + '''
for i=1,1000 do
    local text="FMSEQ1:PRIEST:sequence:self:alt:1:0:1:i"..(9000000+i)
    assert(not W.Import(text)); assert(not W.ImportProfile("FMPROFILE1:PRIEST\\n1:"..text))
end
assert(not W.Import(W.Export(model).."\\n/run something"))
assert(not W.Export(model):find("|",1,true), "Share text must avoid WoW escape introducers")
''')

case("Workshop stale build preview requires another review before applying", SETUP + '''
assert(W.Install(1,model)); local p={class="PRIEST",slots={[1]=W.Copy(model)}}; p.slots[1].ooc=false
local plan=assert(W.Plan(p)); model.channel=false; assert(W.Install(1,model))
local body=TEST.named("FM Seq1").body; local edits=TEST.edits
local ok,reason=W.ApplyProfile(p,plan)
assert(not ok and reason:find("changed since preview",1,true))
assert(TEST.named("FM Seq1").body==body and TEST.edits==edits)
local fresh=assert(W.Plan(p)); assert(W.ApplyProfile(p,fresh))
''')
