"""Native bag controls: explicit sorting, stable layout identity, and combat boundaries."""
CASES=[]
def case(title,code): CASES.append((title,code))

FIXTURE='''
local B=FM.Bags
TEST.sorts,TEST.directionWrites,TEST.anchors=0,0,0
TEST.cursor=nil;TEST.locked=false;TEST.reverse=false
GetCursorInfo=function() return TEST.cursor end
C_Container.GetContainerNumSlots=function(bag) return bag==0 and 16 or 0 end
C_Container.GetContainerItemInfo=function(bag,slot) if slot==1 then return {isLocked=TEST.locked} end end
C_Container.SortBags=function() TEST.sorts=TEST.sorts+1 end
C_Container.GetSortBagsRightToLeft=function() return TEST.reverse end
C_Container.SetSortBagsRightToLeft=function(value) TEST.reverse=value;TEST.directionWrites=TEST.directionWrites+1 end
UIParent.GetEffectiveScale=function() return 1 end
function TEST.bag(id,combined,x,y,scale)
 local f=CreateFrame('Frame');f.bag=id;f.combined=combined;f.x=x or 1700;f.y=y or 300;f.scale=scale or 1
 f.GetBagID=function(self) return self.bag end
 f.IsCombinedBagContainer=function(self) return self.combined==true end
 f.GetCenter=function(self) return self.x,self.y end
 f.GetEffectiveScale=function(self) return self.scale end
 f.IsMovable=function(self) return self.movable==true end
 f.SetMovable=function(self,v) assert(not TEST.combat);self.movable=v end
 f.SetPoint=function(self,point,relative,relativePoint,x,y) assert(not TEST.combat);self.x,self.y=x,y;self.point=point end
 f.StartMoving=function(self) assert(not TEST.combat);self.moving=true end
 f.StopMovingOrSizing=function(self) self.moving=false end
 f.HookScript=function(self,event,fn) self.scripts[event]=fn end
 f:SetSize(192,250);return f
end
TEST.bag0=TEST.bag(0,false,1750,200)
TEST.bag1=TEST.bag(1,false,1750,500)
TEST.visible={TEST.bag0,TEST.bag1}
ContainerFrameSettingsManager={GetBagsShown=function() return TEST.visible end}
UpdateContainerFrameAnchors=function() TEST.anchors=TEST.anchors+1 end
hooksecurefunc=function(name,fn) local original=_G[name];_G[name]=function(...) original(...);fn(...) end end
OpenAllBags=function() TEST.bag0:Show();TEST.bag1:Show();UpdateContainerFrameAnchors() end
TEST.login()
B.unlocked=false
B.Settings().toolbarHidden=false;B.Refresh()
'''

case('Bag events and open controls never sort automatically',FIXTURE+'''
TEST.command('bags');assert(B.toolbar:IsShown())
for i=1,5 do TEST.fire('BAG_UPDATE_DELAYED');TEST.fire('PLAYER_ENTERING_WORLD');TEST.flush() end
TEST.command('bags reset');TEST.command('bags off');TEST.command('bags')
assert(TEST.sorts==0 and TEST.directionWrites==0)
for _,f in ipairs(TEST.frames) do assert(not f.scripts.OnUpdate) end
assert(#TEST.timers==0)
''')

case('Sort click calls native bag sort once and prevents rapid repeat requests',FIXTURE+'''
B.sort:Click();assert(TEST.sorts==1 and B.status:find('requested',1,true))
B.sort:Click();assert(TEST.sorts==1)
TEST.advance(1);B.sort:Click();assert(TEST.sorts==2)
assert(TEST.directionWrites==0)
''')

for title,setup in [
    ('combat','TEST.combat=true'),('cursor item',"TEST.cursor='item'"),
    ('cursor spell',"TEST.cursor='spell'"),('locked item','TEST.locked=true'),
    ('secret lock','TEST.locked={secret=true}'),('missing lock','TEST.locked=nil'),
    ('secret slot count','C_Container.GetContainerNumSlots=function() return {secret=true} end'),
    ('slot query error',"C_Container.GetContainerNumSlots=function() error('unavailable') end"),
    ('item query error',"C_Container.GetContainerItemInfo=function() error('unavailable') end"),
    ('missing sort API','C_Container.SortBags=nil'),('missing cursor API','GetCursorInfo=nil'),
    ('wrong client',"TEST.version='12.1.5'"),('no bag data','C_Container.GetContainerNumSlots=function() return 0 end'),
]:
    case('Sort refuses '+title+' without changing inventory or queuing a retry',FIXTURE+setup+'''
assert(not B.Sort() and TEST.sorts==0)
TEST.combat=false;TEST.cursor=nil;TEST.locked=false
TEST.fire('PLAYER_REGEN_ENABLED');TEST.fire('BAG_UPDATE_DELAYED');TEST.flush()
assert(TEST.sorts==0)
''')

case('Native sorting errors produce a failure message rather than a success claim',FIXTURE+'''
C_Container.SortBags=function() error('client failure') end
assert(not B.Sort() and not B.lastSort and B.status:find('rejected',1,true))
''')

case('Reverse direction changes only the preference and leaves sorting for a click',FIXTURE+'''
B.reverse:Click();assert(TEST.reverse and TEST.directionWrites==1 and TEST.sorts==0)
B.reverse:Click();assert(not TEST.reverse and TEST.directionWrites==2 and TEST.sorts==0)
TEST.combat=true;assert(not B.Reverse() and TEST.directionWrites==2)
''')

case('Sort respects native exclusions without rewriting flags or using cursor movement',FIXTURE+'''
C_Container.GetBackpackAutosortDisabled=function() return true end
C_Container.SetBackpackAutosortDisabled=function() error('Do not change exclusions') end
C_Container.SetBagSlotFlag=function() error('Do not change flags') end
C_Container.PickupContainerItem=function() error('No item cursor manipulation') end
C_Container.SortBank=function() error('No bank sort') end
B.sort:Click();assert(TEST.sorts==1)
''')

case('Bag mover preserves independent saved positions and restores native movable state',FIXTURE+'''
B.ToggleMove();B.StartDrag(TEST.bag0);assert(TEST.bag0.moving and B.drag)
TEST.bag0.x=500;TEST.bag0.y=450;B.StopDrag()
assert(not TEST.bag0.movable and not B.drag)
local p=B.Settings().positions
assert(p['bag:0'].x==500/1920 and p['bag:0'].y==450/1080)
assert(p['bag:1'].x==1750/1920 and p['bag:1'].y==500/1080)
TEST.bag0.x=1900;UpdateContainerFrameAnchors();assert(math.abs(TEST.bag0.x-500)<0.001)
B.ToggleMove();assert(B.handles[TEST.bag0]:IsShown() and not B.unlocked)
''')

case('Bag positions use bag identity when native frame objects are recycled',FIXTURE+'''
B.Settings().positions={['bag:0']={x=0.2,y=0.3},['bag:3']={x=0.6,y=0.7}}
B.Refresh();assert(TEST.bag0.x==1920*0.2)
TEST.bag0.bag=3;B.Refresh();assert(TEST.bag0.x==1920*0.6)
''')

case('Combined bag positions are separate and bank frames are excluded',FIXTURE+'''
local combined=TEST.bag(0,true);local bank=TEST.bag(-1,false)
TEST.visible={combined,bank};B.Settings().positions={combined={x=0.3,y=0.4},['bag:0']={x=0.8,y=0.8}}
B.Refresh();assert(combined.x==1920*0.3 and not B.handles[bank])
TEST.visible={TEST.bag0};B.Refresh();assert(TEST.bag0.x==1920*0.8)
''')

case('Saved bag positions survive UI scale changes and reject malformed coordinates',FIXTURE+'''
B.Settings().positions={['bag:0']={x=0.25,y=0.5},['bag:1']={x=0/0,y=0.5}}
TEST.bag0.scale=0.8;B.Refresh();assert(TEST.bag0.x==1920*0.25/0.8 and TEST.bag1.x==1750)
TEST.bag0.scale=1.2;UIParent.GetEffectiveScale=function() return 0.9 end
B.Refresh();assert(math.abs(TEST.bag0.x-1920*0.25*0.9/1.2)<0.01)
''')

case('Combat cancels dragging and defers only layout restoration',FIXTURE+'''
B.ToggleMove();B.StartDrag(TEST.bag0);TEST.combat=true
TEST.fire('PLAYER_REGEN_DISABLED');assert(not B.drag and not TEST.bag0.moving)
assert(not B.toolbar:IsShown())
assert(not B.Sort() and not B.Reset())
TEST.combat=false;TEST.fire('PLAYER_REGEN_ENABLED');TEST.flush()
assert(not TEST.bag0.movable and B.toolbar:IsShown() and TEST.sorts==0)
''')

case('Reset removes saved layouts without sorting or changing exclusions',FIXTURE+'''
B.Settings().positions={['bag:0']={x=0.2,y=0.3}}
local count=TEST.anchors;B.reset:Click()
assert(next(B.Settings().positions)==nil and TEST.anchors>count and TEST.sorts==0)
''')

case('Bag toolbar hides with closed bags and stays hidden after Hide tools',FIXTURE+'''
TEST.bag0:Hide();TEST.bag1:Hide();B.Schedule();TEST.flush();assert(not B.toolbar:IsShown())
TEST.command('bags');assert(B.toolbar:IsShown())
TEST.command('bags off');assert(not B.toolbar:IsShown() and B.Settings().toolbarHidden and B.Settings().enabled)
TEST.fire('BAG_UPDATE_DELAYED');TEST.flush();assert(not B.toolbar:IsShown())
''')

case('Missing native bag manager fails quietly without affecting macro UI',FIXTURE+'''
ContainerFrameSettingsManager=nil;TEST.command('bags');assert(not B.toolbar:IsShown())
TEST.command('coach');assert(FM.UI.tab=='Coach' and TEST.sorts==0)
''')

case('Combined backpack root is found directly when the manager omits it',FIXTURE+'''
local root=TEST.bag(0,true);ContainerFrameCombinedBags=root
ContainerFrameSettingsManager=nil;B.Refresh()
assert(B.toolbar:IsShown() and B.handles[root])
assert(B.move.caption:GetText()=='Move backpack')
assert(not B.handles[TEST.bag0]:IsShown())
''')

case('Combined drag handle moves the whole window without changing its contents',FIXTURE+'''
local root=TEST.bag(0,true);ContainerFrameCombinedBags=root
local child=TEST.bag(1,false,50,60);child.parent=root
TEST.visible={child,root,TEST.bag1};B.Settings().positions['bag:1']={x=0.8,y=0.8}
B.Refresh();B.ToggleMove();local handle=assert(B.handles[root])
assert(handle:GetPoint()=='TOPLEFT' and handle:GetParent()==UIParent)
handle.scripts.OnDragStart(handle)
assert(root.moving and B.drag.frame==root and not child.moving)
assert(not B.handles[child] and not B.handles[TEST.bag1]:IsShown())
root.x=400;root.y=350;handle.scripts.OnDragStop(handle)
assert(math.abs(B.Settings().positions.combined.x-400/1920)<0.001)
assert(B.Settings().positions['bag:1'].x==0.8 and child.x==50 and child.y==60)
assert(TEST.sorts==0 and TEST.directionWrites==0 and not TEST.cursor)
''')

case('Combined mode rejects internal bag sections as direct drag targets',FIXTURE+'''
ContainerFrameCombinedBags=TEST.bag(0,true)
local section=TEST.bag(2,false);section.parent=ContainerFrameCombinedBags
TEST.visible={section};B.Refresh();B.ToggleMove();B.StartDrag(section)
assert(not B.drag and not section.moving)
''')

case('Bag move command opens and unlocks the complete combined backpack',FIXTURE+'''
ContainerFrameCombinedBags=TEST.bag(0,true)
ContainerFrameCombinedBags.IsCombinedBagContainer=nil
TEST.command('bags move')
assert(B.unlocked and B.handles[ContainerFrameCombinedBags]:IsShown())
assert(B.move.caption:GetText()=='Lock backpack' and TEST.sorts==0)
''')

case('Native backpack header toggles lock without a separate drag bar',FIXTURE+'''
local root=TEST.bag(0,true);ContainerFrameCombinedBags=root;B.Refresh()
local header=assert(B.handles[root]);assert(header:IsShown() and not header.caption)
assert(header:GetPoint()=='TOPLEFT' and header:GetHeight()==24)
header.scripts.OnDragStart(header);assert(not root.moving)
header.scripts.OnMouseUp(header,'RightButton');assert(B.unlocked)
header.scripts.OnDragStart(header);assert(root.moving)
root.x=600;header.scripts.OnMouseUp(header,'LeftButton');assert(not root.moving)
header.scripts.OnMouseUp(header,'RightButton');assert(not B.unlocked and header:IsShown())
assert(B.Settings().positions.combined.x==600/1920 and TEST.sorts==0)
''')

case('Hidden combined backpack gets its header controls on first opening',FIXTURE+'''
local root=TEST.bag(0,true);ContainerFrameCombinedBags=root;root:Hide()
B.Setup();assert(B.watched[root] and not B.handles[root])
root:Show();TEST.flush();assert(B.handles[root]:IsShown())
root:Hide();assert(not B.handles[root]:IsShown())
''')

case('Hiding the toolbar leaves the combined backpack title draggable',FIXTURE+'''
local root=TEST.bag(0,true);ContainerFrameCombinedBags=root;B.Refresh()
TEST.command('bags move');TEST.command('bags off')
local header=B.handles[root]
assert(header:IsShown(),'Hide tools removed the bag drag target')
header.scripts.OnDragStart(header)
assert(root.moving,'Hidden toolbar disabled bag movement')
root.x=620;header.scripts.OnDragStop(header)
assert(B.Settings().positions.combined.x==620/1920 and not B.toolbar:IsShown())
assert(TEST.sorts==0)
''')
case('Legacy hidden-tools setting migrates to hidden toolbar with working movement',FIXTURE+'''
local s=B.Settings();s.enabled=false;s.toolbarHidden=nil;s.headerControls=nil;s.locked=nil;B.unlocked=nil
local root=TEST.bag(0,true);ContainerFrameCombinedBags=root;B.Refresh()
assert(B.handles[root] and B.handles[root]:IsShown())
B.handles[root].scripts.OnDragStart(B.handles[root])
assert(root.moving and not B.toolbar:IsShown())
B.StopDrag();assert(s.enabled and s.toolbarHidden and s.headerControls==1)
''')
case('New bag headers drag immediately and a saved lock survives refresh',FIXTURE+'''
local s=B.Settings();s.headerControls=nil;s.locked=nil;B.unlocked=nil;B.Refresh()
local h=B.handles[TEST.bag0];h.scripts.OnDragStart(h);assert(TEST.bag0.moving)
B.StopDrag();h.scripts.OnMouseUp(h,'RightButton');assert(not B.unlocked and s.locked)
B.unlocked=nil;B.Refresh();h.scripts.OnDragStart(h);assert(not TEST.bag0.moving)
h.scripts.OnMouseUp(h,'RightButton');h.scripts.OnDragStart(h);assert(TEST.bag0.moving)
''')
case('Backpack Sort button remains visible without the FM panel or toolbar',FIXTURE+'''
local root=TEST.bag(0,true);ContainerFrameCombinedBags=root;B.Refresh()
TEST.command('bags off')
local sort=assert(B.sortButtons[root]);assert(sort:IsShown() and not B.toolbar:IsShown())
local _,relative,_,x=sort:GetPoint();assert(relative==root and x==42)
local _,_,_,dragX=B.handles[root]:GetPoint();assert(dragX>=x+sort:GetWidth())
sort:Click();assert(TEST.sorts==1)
TEST.fire('PLAYER_REGEN_DISABLED');assert(not sort:IsShown())
TEST.combat=false;TEST.fire('PLAYER_REGEN_ENABLED');TEST.flush();assert(sort:IsShown())
root:Hide();B.Schedule();TEST.flush();assert(not sort:IsShown())
''')
case('Bags kept shown inside a hidden parent by a replacement bag addon get no Sort button or drag strip',FIXTURE+'''
local root=TEST.bag(0,true);ContainerFrameCombinedBags=root
local hidden=CreateFrame('Frame');hidden:Hide();root:SetParent(hidden)
TEST.visible={root}
B.Refresh()
assert(not (B.sortButtons[root] and B.sortButtons[root]:IsShown()),'Sort button shown for an invisible backpack')
assert(not (B.handles[root] and B.handles[root]:IsShown()),'drag strip shown for an invisible backpack')
assert(not B.toolbar:IsShown(),'toolbar shown for an invisible backpack')
''')
case('A Sort button already on screen goes away when a replacement addon hides the backpack',FIXTURE+'''
local root=TEST.bag(0,true);ContainerFrameCombinedBags=root;B.Refresh()
local sort=assert(B.sortButtons[root]);assert(sort:IsShown())
local hidden=CreateFrame('Frame');hidden:Hide();root:SetParent(hidden)
TEST.fire('BAG_UPDATE_DELAYED');TEST.flush()
assert(not sort:IsShown(),'Sort button left floating after the backpack became invisible')
assert(not B.handles[root]:IsShown(),'drag strip left behind after the backpack became invisible')
''')
