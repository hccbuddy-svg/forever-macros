local _, FM = ...
local T = {dirty = true}
FM.Advisor = T
local D = FM.TalentData
T.classes = {"WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID"}
local function public(v) return not (issecretvalue and issecretvalue(v)) end
local function number(v) return public(v) and type(v) == "number" and v == v and v >= 0 and v < 1000000000 end
local function integer(v) return number(v) and v == math.floor(v) end
local function tab(v) return public(v) and type(v) == "table" end
local function boolean(v) return public(v) and type(v) == "boolean" end
local function call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, ...)
    if ok and public(value) then return value end
end
T.Public, T.Call = public, call
function T.Class() return select(2, UnitClass("player")) end
function T.Settings()
    local db = FM.API.State()
    if not db then return nil end
    if type(db.advisor) ~= "table" then db.advisor = {} end
    local s = db.advisor
    s.hud = s.hud == true
    if not integer(s.tree) or s.tree < 1 or s.tree > 3 then s.tree = nil end
    if type(s.build) ~= "string" then s.build = nil end
    return s
end
function T.Builds(class, tree)
    local out = {}
    local data = D.classes[class]
    if not data or not data.trees[tree] then return out end
    for _, b in ipairs(D.builds) do
        if b.class == class and b.spec == data.trees[tree].name then out[#out + 1] = b end
    end
    table.sort(out, function(a,b)
        local function weight(p) return (p.source == "Method" and 0 or p.category == "Leveling" and 10 or 20) + (p.group == "Group" and 5 or 0) end
        local aw,bw = weight(a),weight(b)
        if aw ~= bw then return aw < bw end
        if #a.order ~= #b.order then return #a.order < #b.order end
        return a.id < b.id
    end)
    return out
end
function T.TargetRank(build, tree, i) return tonumber(build.ranks[tree]:sub(i,i)) or 0 end
function T.TalentName(class, tree, i)
    local talent = D.classes[class].trees[tree].talents[i]
    local localized = talent.spell and C_Spell and call(C_Spell.GetSpellName, talent.spell)
    return type(localized) == "string" and localized ~= "" and localized or talent.name
end

-- Read only committed, public trait data. Spell identity and grid geometry must both match.
local function read(class)
    local data = D.classes[class]
    if not data or not C_ClassTalents or not C_Traits then return nil, "Talent API unavailable. Preview only." end
    local configID = call(C_ClassTalents.GetActiveConfigID)
    if not integer(configID) or configID == 0 then return nil, "No active talent configuration. Preview only." end
    local staged = call(C_Traits.ConfigHasStagedChanges, configID)
    if staged ~= false then return nil, "Apply or discard pending talent changes in the game's talent window first." end
    local config = call(C_Traits.GetConfigInfo, configID)
    if not tab(config) or not tab(config.treeIDs) or #config.treeIDs ~= 1 or not integer(config.treeIDs[1]) then
        return nil, "Talent tree layout unavailable. Preview only."
    end
    local nodes = call(C_Traits.GetTreeNodes, config.treeIDs[1])
    if not tab(nodes) or #nodes < 1 or #nodes > 200 then return nil, "Talent nodes unavailable. Preview only." end
    local bySpell, byMissingName, result, expected, seen = {}, {}, {class=class, ranks={{},{},{}}, nodes={{},{},{}}, points={0,0,0}, spent=0}, 0, {}
    for t, tree in ipairs(data.trees) do
        for i, talent in ipairs(tree.talents) do
            if talent.spell then
                if bySpell[talent.spell] then return nil, "Ambiguous talent data. Preview only." end
                bySpell[talent.spell] = {t,i}
            else byMissingName[talent.name] = {t,i} end
            expected = expected + 1
        end
    end
    local count = 0
    for _, id in ipairs(nodes) do
        if not integer(id) or seen[id] then return nil, "Invalid talent node list. Preview only." end
        seen[id] = true
        local node = call(C_Traits.GetNodeInfo, configID, id)
        if not tab(node) or not integer(node.maxRanks) or not boolean(node.isVisible) then return nil, "Unreadable talent node. Preview only." end
        if node.isVisible and node.maxRanks > 0 then
            if not tab(node.entryIDs) or #node.entryIDs ~= 1 or not integer(node.entryIDs[1]) then return nil, "Talent choices differ from this data version." end
            local entry = call(C_Traits.GetEntryInfo, configID, node.entryIDs[1])
            if not tab(entry) or not integer(entry.definitionID) then return nil, "Talent entry unavailable. Preview only." end
            local definition = call(C_Traits.GetDefinitionInfo, entry.definitionID)
            if not tab(definition) or not integer(definition.spellID) then return nil, "Talent identity unavailable. Preview only." end
            local at = bySpell[definition.spellID]
            if not at and (GetLocale()=="enUS" or GetLocale()=="enGB") then
                local name=C_Spell and call(C_Spell.GetSpellName,definition.spellID)
                if type(name)=="string" then at=byMissingName[name] end
            end
            if not at then return nil, "Talent data differs from the client. Update the addon. Preview only." end
            local t,i = at[1],at[2]
            if result.nodes[t][i] or node.maxRanks ~= data.trees[t].talents[i].max
                or not integer(node.currentRank) or node.currentRank > node.maxRanks
                or not boolean(node.canPurchaseRank) or not number(node.posX) or not number(node.posY) then
                return nil, "Talent ranks or layout differ from this data version. Preview only."
            end
            result.ranks[t][i], result.nodes[t][i] = node.currentRank, {id=id, x=node.posX, y=node.posY, available=node.canPurchaseRank}
            result.points[t] = result.points[t] + node.currentRank
            result.spent = result.spent + node.currentRank
            count = count + 1
        end
    end
    if count ~= expected then return nil, "Incomplete talent tree. Preview only." end
    for t,tree in ipairs(data.trees) do
        local minX,minY,minCol,minRow = math.huge,math.huge,math.huge,math.huge
        for i,talent in ipairs(tree.talents) do
            local n=result.nodes[t][i]
            minX,minY=math.min(minX,n.x),math.min(minY,n.y)
            minCol,minRow=math.min(minCol,talent.col),math.min(minRow,talent.row)
        end
        for i,talent in ipairs(tree.talents) do
            local n=result.nodes[t][i]
            if math.abs((n.x-minX)/600 + minCol-talent.col)>0.01 or math.abs((n.y-minY)/600 + minRow-talent.row)>0.01 then
                return nil, "Talent positions changed. Update the addon. Preview only."
            end
        end
    end
    return result
end
function T.Snapshot(force)
    if FM.InCombat() then return nil, "Talent comparison resumes after combat." end
    if not FM.API.Ready() or not FM.API.Supported() then return nil, "A supported Forever client must finish loading first." end
    if force or T.dirty then
        T.dirty = false
        local ok, value, reason = pcall(read, T.Class())
        T.snapshot, T.reason = ok and value or nil, ok and reason or "Talent API read failed. Preview only."
    end
    return T.snapshot, T.reason
end
function T.Progress(build, snapshot)
    local data = D.classes[build.class]
    if not snapshot or snapshot.class ~= build.class then return {next={}, status="Preview only. No character comparison."} end
    local missing, counts, outside = {}, {{},{},{}}, 0
    for t,tree in ipairs(data.trees) do
        for i in ipairs(tree.talents) do
            local rank = snapshot.ranks[t][i]
            if rank > T.TargetRank(build,t,i) then outside = outside + rank - T.TargetRank(build,t,i) end
        end
    end
    if outside > 0 then return {next={},outside=outside,status=outside .. " point(s) outside this plan. Review the build before continuing."} end
    for ordinal,step in ipairs(build.order) do
        local t,i=step[1],step[2]
        counts[t][i]=(counts[t][i] or 0)+1
        if counts[t][i] > snapshot.ranks[t][i] and #missing < 3 then
            missing[#missing+1]={tree=t,index=i,rank=counts[t][i],ordinal=ordinal,available=#missing==0 and snapshot.nodes[t][i].available}
        end
    end
    return {next=missing,status=#missing==0 and "This plan is complete. Choose another plan to continue beyond its endpoint." or
        (missing[1].available and "Next planned talent is available. Choose it in the game's talent window." or "Next planned talent is not currently purchasable. Check points and requirements in the talent window.")}
end
function T.Select(build)
    if build.class ~= T.Class() then return false end
    local s = T.Settings(); if not s then return false end
    for t, tree in ipairs(D.classes[build.class].trees) do if tree.name == build.spec then s.tree = t end end
    s.build = build.id
    return true
end
function T.NativeStatus()
    if FM.InCombat() then return "Compatibility check is available after combat." end
    local available = C_AssistedCombat and call(C_AssistedCombat.IsAvailable)
    if available == true then return "Blizzard Assisted Combat reports available. Live recommendations are not connected in this version." end
    return "No usable Blizzard Assisted Combat provider detected. The combat bar shows fixed reference cards."
end
local events = CreateFrame("Frame")
for _,event in ipairs({"PLAYER_ENTERING_WORLD","PLAYER_LEVEL_UP","PLAYER_REGEN_DISABLED","PLAYER_REGEN_ENABLED",
    "TRAIT_CONFIG_UPDATED","TRAIT_NODE_CHANGED","ACTIVE_TALENT_GROUP_CHANGED","SPELLS_CHANGED","UPDATE_BINDINGS","ACTIONBAR_SLOT_CHANGED"}) do
    events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_,event)
    T.dirty, T.snapshot = true, nil
    if T.pending then return end
    local shown = FM.CoachUI and ((FM.UI.frame and FM.UI.frame:IsShown() and FM.UI.tab=="Coach") or (FM.CoachUI.hud and FM.CoachUI.hud:IsShown()))
    local s=T.Settings()
    if not shown and not (event=="PLAYER_ENTERING_WORLD" and s and s.hud) then return end
    T.pending = true
    C_Timer.After(0.25, function()
        T.pending = nil
        if FM.CoachUI then FM.CoachUI.RefreshHUD(); if FM.UI.tab=="Coach" then FM.UI.Refresh() end end
    end)
end)
