local _, FM = ...
local L = {revision=2, prefix="FM LG v2 ", legacyPrefix="FM LG v1 ", scale=0.60}
FM.Layout = L
local labels={WARRIOR="Warrior",PALADIN="Paladin",HUNTER="Hunter",ROGUE="Rogue",PRIEST="Priest",SHAMAN="Shaman",MAGE="Mage",WARLOCK="Warlock",DRUID="Druid"}
local leveling={WARRIOR=1,PALADIN=3,HUNTER=1,ROGUE=2,PRIEST=3,SHAMAN=2,MAGE=3,WARLOCK=1,DRUID=2}
-- Shared geometry for every class. Each pair is the original v2 point and
-- its replacement; migration changes only points still at our old defaults.
local frameSpacing={
    ElvUF_PlayerMover={"BOTTOM,UIParent,BOTTOM,-158,272","BOTTOM,UIParent,BOTTOM,-230,380"},
    ElvUF_TargetMover={"BOTTOM,UIParent,BOTTOM,158,272","BOTTOM,UIParent,BOTTOM,230,380"},
    ElvUF_PlayerCastbarMover={"BOTTOM,UIParent,BOTTOM,0,232","BOTTOM,UIParent,BOTTOM,-230,338"},
    ElvUF_TargetCastbarMover={"BOTTOM,UIParent,BOTTOM,158,346","BOTTOM,UIParent,BOTTOM,230,338"},
    ElvUF_PetMover={"BOTTOM,UIParent,BOTTOM,-414,230","BOTTOM,UIParent,BOTTOM,-414,270"},
    ElvUF_TargetTargetMover={"BOTTOM,UIParent,BOTTOM,414,230","BOTTOM,UIParent,BOTTOM,414,270"},
    ElvUF_FocusMover={"BOTTOM,UIParent,BOTTOM,414,410","BOTTOM,UIParent,BOTTOM,414,510"},
    TotemTrackerMover={"BOTTOM,UIParent,BOTTOM,0,390","BOTTOM,UIParent,BOTTOM,0,530"},
}
local function copy(v)
    if type(v)~="table" then return v end
    local out={};for k,value in pairs(v) do out[k]=copy(value) end;return out
end
local function merge(target,values)
    for k,v in pairs(values) do
        if type(v)=="table" then
            if type(target[k])~="table" then target[k]={} end
            merge(target[k],v)
        else target[k]=v end
    end
end
function L.Name(class,tree,bear)
    return L.prefix..labels[class].." "..(bear and "Feral Tank" or FM.TalentData.classes[class].trees[tree].name)
end
function L.Profile(class,tree,bear)
    local heal=(class=="PRIEST" and tree~=3) or ((class=="DRUID" or class=="SHAMAN") and tree==3) or (class=="PALADIN" and tree==1)
    local tank=bear or ((class=="WARRIOR" or class=="PALADIN") and tree==(class=="WARRIOR" and 3 or 2))
    local p={general={font="Expressway",fontSize=14,fontStyle="OUTLINE",loginmessage=false},
        chat={font="Expressway",fontSize=16,panelWidth=420,panelHeight=210,panelBackdrop="LEFT"},
        actionbar={font="Expressway",fontSize=14},unitframe={font="Expressway",fontSize=15,units={},colors={healthclass=true}},
        movers={},nameplates={font="Expressway",fontSize=14}}
    local units=p.unitframe.units
    for _,unit in ipairs({"player","target","focus","pet","targettarget"}) do
        units[unit]={width=(unit=="player" or unit=="target") and 290 or 190,
            height=(unit=="player" or unit=="target") and 62 or 40,
            portrait={enable=false},castbar={height=28},fader={enable=false},
            name={text_format="[name]",position="TOPLEFT",xOffset=6,yOffset=-5},
            health={text_format="[health:current:shortvalue] | [perhp]%",position="BOTTOMRIGHT",xOffset=-6,yOffset=5}}
    end
    units.player.castbar.width=290
    units.target.castbar.width=290
    units.targettarget.castbar=nil
    units.player.power={enable=true,height=(class=="ROGUE" or class=="WARRIOR" or class=="DRUID") and 18 or 15,
        text_format="[power:current:shortvalue]",position="CENTER",xOffset=0}
    units.target.power={enable=true,height=12,text_format="[power:current:shortvalue]",position="CENTER",xOffset=0}
    units.player.classbar={enable=true,height=(class=="ROGUE" or class=="DRUID") and 18 or 14}
    units.pet.enable=class=="HUNTER" or class=="WARLOCK"
    units.party={enable=true,showPlayer=true,width=heal and 235 or 210,height=heal and 70 or 60,
        growthDirection="DOWN_RIGHT",verticalSpacing=10,horizontalSpacing=0,
        name={text_format="[name:medium]",position="TOPLEFT",xOffset=6,yOffset=-5},
        health={text_format=heal and "[health:deficit:shortvalue]" or "[perhp]%",position="BOTTOMRIGHT",xOffset=-6,yOffset=5},
        power={enable=true,height=10,text_format="[perpp]%",position="BOTTOMLEFT",xOffset=6,yOffset=5},
        healPrediction={enable=heal},buffIndicator={enable=heal},
        rdebuffs={enable=true,size=28,fontSize=13},roleIcon={enable=true},debuffHighlight={enable=true},
        threatStyle="GLOW",raidRoleIcons={enable=true}}
    for _,raid in ipairs({"raid1","raid2","raid3"}) do
        units[raid]={width=heal and 115 or 94,height=heal and 62 or 46,
            growthDirection="RIGHT_DOWN",groupsPerRowCol=1,horizontalSpacing=6,verticalSpacing=6,
            groupBy="GROUP",name={text_format="[name:short]"},healPrediction={enable=heal},
            buffIndicator={enable=heal},rdebuffs={enable=true,size=26,fontSize=12},
            health={text_format=heal and "[health:deficit:shortvalue]" or "[perhp]%"},
            debuffHighlight={enable=true},threatStyle="GLOW"}
    end
    if tank then units.target.threatStyle="GLOW";units.target.threatPrimary=true end
    for i=1,5 do
        p.actionbar["bar"..i]={enabled=true,buttons=12,buttonsPerRow=i<=3 and 12 or 4,
            buttonSize=44,buttonHeight=44,buttonSpacing=4,mouseover=false,alpha=1,
            hotkeyFont="Expressway",hotkeyFontSize=14,countFont="Expressway",countFontSize=14,
            macroFont="Expressway",macroFontSize=12,macrotext=false,inheritGlobalFade=false}
    end
    p.actionbar.barPet={enabled=class=="HUNTER" or class=="WARLOCK",buttonSize=36,buttonHeight=36,buttonSpacing=4}
    p.actionbar.stanceBar={enabled=class=="WARRIOR" or class=="DRUID" or class=="PALADIN",buttonSize=36,buttonHeight=36,buttonSpacing=4}
    p.actionbar.totemBar={buttonSize=40,buttonHeight=40,font="Expressway",fontSize=14,spacing=6}
    p.general.minimap={size=190}
    local m=p.movers
    for i=1,3 do m["ElvAB_"..i]="BOTTOM,UIParent,BOTTOM,0,"..(30+(i-1)*48) end
    m.ElvAB_4="BOTTOM,UIParent,BOTTOM,-398,30"
    m.ElvAB_5="BOTTOM,UIParent,BOTTOM,398,30"
    m.ElvAB_6="BOTTOM,UIParent,BOTTOM,0,174"
    m.PetAB="BOTTOM,UIParent,BOTTOM,0,184"
    m.ShiftAB="BOTTOM,UIParent,BOTTOM,0,184"
    m.TotemBarMover="BOTTOM,UIParent,BOTTOM,0,184"
    for mover,points in pairs(frameSpacing) do m[mover]=points[2] end
    m.ElvUF_PartyMover=heal and "TOPRIGHT,UIParent,BOTTOM,-535,620" or "TOPRIGHT,UIParent,BOTTOM,-550,620"
    for i=1,3 do m["ElvUF_Raid"..i.."Mover"]=heal and "BOTTOMLEFT,UIParent,BOTTOM,-1005,260" or "BOTTOMLEFT,UIParent,BOTTOM,-1005,290" end
    m.LeftChatMover="BOTTOMLEFT,UIParent,BOTTOMLEFT,20,30"
    m.RightChatMover="BOTTOMRIGHT,UIParent,BOTTOMRIGHT,-24,30"
    m.MinimapMover="TOPRIGHT,UIParent,TOPRIGHT,-24,-24"
    m.ObjectiveFrameMover="TOPRIGHT,UIParent,TOPRIGHT,-24,-270"
    return p
end
local function engine()
    local e=ElvUI and ElvUI[1]
    if type(e)~="table" or not e.Forever then return end
    return e
end
local function settings()
    local db=FM.API.State();if not db then return end
    db.layout=db.layout or {};return db.layout
end
local function upgradeFrameSpacing(p,name)
    -- Account-wide metadata prevents a different character from repeating the
    -- migration after someone deliberately moves a frame back to an old point.
    ElvDB.global=ElvDB.global or {}
    ElvDB.global.foreverMacrosFrameSpacing=ElvDB.global.foreverMacrosFrameSpacing or {}
    local upgrades=ElvDB.global.foreverMacrosFrameSpacing
    if upgrades[name] or type(p)~="table" then return end
    local backup={}
    if type(p.movers)=="table" then
        for mover,points in pairs(frameSpacing) do
            if p.movers[mover]==points[1] then
                backup[mover]=p.movers[mover];p.movers[mover]=points[2]
            end
        end
        for i=1,3 do
            local mover="ElvUF_Raid"..i.."Mover"
            for _,height in ipairs({260,290}) do
                if p.movers[mover]=="BOTTOMLEFT,UIParent,BOTTOM,-945,"..height then
                    backup[mover]=p.movers[mover]
                    p.movers[mover]="BOTTOMLEFT,UIParent,BOTTOM,-1005,"..height
                end
            end
        end
    end
    local previousWidth
    local player=type(p.unitframe)=="table" and type(p.unitframe.units)=="table" and p.unitframe.units.player
    if backup.ElvUF_PlayerCastbarMover and type(player)=="table" and type(player.castbar)=="table" and player.castbar.width==580 then
        previousWidth=player.castbar.width;player.castbar.width=290
    end
    upgrades[name]={revision=1,previous=backup,previousPlayerCastbarWidth=previousWidth}
end
local function prepareProfile(class,tree,bear,s)
    local name=L.Name(class,tree,bear)
    if not ElvDB.profiles[name] then
        local legacy=L.legacyPrefix..name:sub(#L.prefix+1)
        local old=ElvDB.profiles[legacy]
        local profile=type(old)=="table" and copy(old) or {}
        merge(profile,L.Profile(class,tree,bear));ElvDB.profiles[name]=profile
    end
    local p=ElvDB.profiles[name]
    upgradeFrameSpacing(p,name)
    local units=type(p)=="table" and type(p.unitframe)=="table" and p.unitframe.units
    local party=type(units)=="table" and units.party
    -- 0.8.0 wrote an obsolete value. ElvUI reads its spacing multipliers before
    -- converting that value, so repair it before the engine creates its headers.
    if type(party)=="table" and party.growthDirection=="DOWN" then
        s.partyDirectionBackup=s.partyDirectionBackup or {}
        if s.partyDirectionBackup[name]==nil then s.partyDirectionBackup[name]=party.growthDirection end
        party.growthDirection="DOWN_RIGHT"
    end
end
function L.Prepare()
    if FM.InCombat() or not FM.API.State() or not FM.API.Supported() then return false end
    local e,s=engine(),settings()
    if not e or not s or not e.mynameRealm then return false end
    ElvDB=ElvDB or {};ElvDB.profiles=ElvDB.profiles or {};ElvDB.profileKeys=ElvDB.profileKeys or {}
    for class in pairs(labels) do
        for tree=1,3 do prepareProfile(class,tree,false,s) end
    end
    prepareProfile("DRUID",2,true,s)
    if s.revision==L.revision or s.disabled then return true end
    -- Run before ElvUI's OnEnable. An already initialized engine needs a reload
    -- for private modules, so leave it intact and make the profiles available.
    if e.Initialized then s.needsSetup=true;return true end
    local key=e.mynameRealm
    if s.revision then
        local current=ElvDB.profileKeys[key]
        s.beforeV2=s.beforeV2 or {profile=current,scale=ElvDB.global and ElvDB.global.general and ElvDB.global.general.UIScale}
        if type(current)=="string" and current:sub(1,#L.legacyPrefix)==L.legacyPrefix then
            local updated=L.prefix..current:sub(#L.legacyPrefix+1)
            if ElvDB.profiles[updated] then ElvDB.profileKeys[key]=updated end
        end
        s.revision=L.revision;s.needsSetup=nil
        return true
    end
    ElvPrivateDB=ElvPrivateDB or {};ElvPrivateDB.profiles=ElvPrivateDB.profiles or {};ElvPrivateDB.profileKeys=ElvPrivateDB.profileKeys or {}
    local oldPrivate=ElvPrivateDB.profileKeys[key]
    ElvDB.global=ElvDB.global or {};ElvDB.global.general=ElvDB.global.general or {}
    s.previous={profile=ElvDB.profileKeys[key],private=oldPrivate,scale=ElvDB.global.general.UIScale}
    local privateName="FM LG v1 Native "..key
    if not ElvPrivateDB.profiles[privateName] then
        local p=copy((oldPrivate and ElvPrivateDB.profiles[oldPrivate]) or e.private or {})
        merge(p,{bags={enable=false},auras={enable=false,disableBlizzard=false},install_complete=e.version})
        ElvPrivateDB.profiles[privateName]=p
    end
    local _,class=UnitClass("player")
    if not labels[class] then return false end
    ElvDB.profileKeys[key]=L.Name(class,leveling[class])
    ElvPrivateDB.profileKeys[key]=privateName
    ElvDB.global.general.UIScale=L.scale
    s.revision=L.revision;s.auto=true;s.privateName=privateName;s.needsSetup=nil
    return true
end
function L.Move()
    if FM.InCombat() then FM.API.Say("Move windows after combat.");return false end
    local e=engine()
    if e and e.Initialized and type(e.ToggleMoveMode)=="function" then
        e:ToggleMoveMode()
        if FM.Bags then
            local s=FM.Bags.Settings();if s then s.locked=false;FM.Bags.unlocked=true;FM.Bags.Refresh() end
        end
        FM.API.Say("Drag the ElvUI anchors, then click Lock. Backpack headers and supported Blizzard window titles drag outside this mode too.")
        return true
    end
    FM.API.Say("ElvUI is not ready. Reload once, then use Move windows again.")
    return false
end
function L.Select(tree,bear)
    if FM.InCombat() then return false end
    local e,s=engine(),settings();local _,class=UnitClass("player")
    if not e or not e.Initialized or not e.data or not labels[class] or not tree or tree~=math.floor(tree) or tree<1 or tree>3 then return false end
    if bear and class~="DRUID" then return false end
    e.data:SetProfile(L.Name(class,tree,bear));s.auto=false;return true
end
function L.Sync()
    if FM.InCombat() then return end
    local e,s=engine(),settings()
    if not e or not s or not s.auto or not e.Initialized or not e.data then return end
    local current=e.data:GetCurrentProfile()
    if type(current)~="string" or current:sub(1,#L.prefix)~=L.prefix then s.auto=false;return end
    local snapshot=FM.Advisor.Snapshot(true)
    if not snapshot or snapshot.spent==0 then return end
    local best,tied=1,false
    for i=2,3 do
        if snapshot.points[i]>snapshot.points[best] then best=i;tied=false
        elseif snapshot.points[i]==snapshot.points[best] then tied=true end
    end
    if not tied then
        local name=L.Name(snapshot.class,best)
        if current~=name then e.data:SetProfile(name) end
    end
end
function L.Command(argument)
    local e,s=engine(),settings()
    if not e or not s then FM.API.Say("Install the Forever ElvUI development package, then restart the game.");return end
    if FM.InCombat() then FM.API.Say("Change layouts after combat.");return end
    if argument=="move" then return L.Move()
    elseif argument=="previous" then
        if s.beforeV2 and s.beforeV2.profile then
            ElvDB.profileKeys[e.mynameRealm]=s.beforeV2.profile
            s.auto=false;s.disabled=true
            FM.API.Say("Previous LG profile selected. Type /reload to restore it.")
        end
        return
    elseif argument=="restore" then
        if s.previous then
            ElvDB.profileKeys[e.mynameRealm]=s.previous.profile
            ElvPrivateDB.profileKeys[e.mynameRealm]=s.previous.private
            ElvDB.global.general.UIScale=s.previous.scale
            s.disabled=true;s.auto=false
            FM.API.Say("Previous profile and scale selected for the next reload. Type /reload when ready.")
        end
        return
    elseif argument=="off" then s.auto=false;s.disabled=true
    elseif argument=="auto" then s.auto=true;s.disabled=nil;L.Sync()
    elseif argument=="bear" then L.Select(2,true)
    elseif tonumber(argument) then L.Select(tonumber(argument))
    end
    FM.API.Say("28 LG layouts ready. /fm layout 1, 2 or 3 selects a talent tree; bear selects Druid tank. /fm layout auto follows talents. /fm layout restore restores the prior setup. Adjust with /ec.")
    if s.needsSetup then FM.API.Say("Profiles created. Reload to apply the initial LG setup.") end
end
local f=CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED");f:RegisterEvent("PLAYER_ENTERING_WORLD");f:RegisterEvent("TRAIT_CONFIG_UPDATED");f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent",function(_,event,name)
    if event=="ADDON_LOADED" and name=="ForeverMacros" then L.Prepare()
    elseif event~="ADDON_LOADED" and not L.pending then
        L.pending=true
        C_Timer.After(0.4,function() L.pending=nil;L.Prepare();L.Sync() end)
    end
end)
