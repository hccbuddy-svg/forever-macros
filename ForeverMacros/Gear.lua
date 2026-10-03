local _, FM = ...
local G = {}
FM.Gear = G
G.presets = {{id = "weapons_a", label = "Weapons A"}, {id = "weapons_b", label = "Weapons B"},
    {id = "trinkets_a", label = "Trinkets A"}, {id = "trinkets_b", label = "Trinkets B"}}
G.slots = {[13] = "Top trinket", [14] = "Bottom trinket", [16] = "Main hand", [17] = "Off hand", [18] = "Ranged"}
local allowed = {
    [13] = {INVTYPE_TRINKET = true}, [14] = {INVTYPE_TRINKET = true},
    [16] = {INVTYPE_WEAPON = true, INVTYPE_WEAPONMAINHAND = true, INVTYPE_2HWEAPON = true},
    [17] = {INVTYPE_WEAPON = true, INVTYPE_WEAPONOFFHAND = true, INVTYPE_SHIELD = true, INVTYPE_HOLDABLE = true},
    [18] = {INVTYPE_RANGED = true, INVTYPE_RANGEDRIGHT = true, INVTYPE_THROWN = true, INVTYPE_RELIC = true},
}
function G.Slots(preset) return preset:match("^trinkets_") and {13, 14} or {16, 17, 18} end
function G.Preset(id)
    local db = FM.API.State()
    if not db then return end
    if not db.gear[id] then db.gear[id] = {} end
    return db.gear[id]
end
function G.Capture(id)
    if FM.InCombat() then return nil, "Capture equipment after combat." end
    local current = G.Preset(id)
    if not current or not GetInventoryItemID then return nil, "Equipment data is unavailable." end
    for _, slot in ipairs(G.Slots(id)) do current[slot] = GetInventoryItemID("player", slot) end
    return true
end
function G.ItemName(id)
    if not id then return "Empty" end
    local fn = C_Item and C_Item.GetItemInfo or GetItemInfo
    local name = fn and fn(id)
    if name then return name end
    if C_Item and C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(id) end
    return "Loading item " .. id
end
function G.Items(slot)
    local list, seen = {}, {}
    if not allowed[slot] then return list end
    local info = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
    if not info then return list end
    local function add(id)
        if type(id) ~= "number" or seen[id] then return end
        local _, _, _, location = info(id)
        if not location or not allowed[slot][location] then return end
        seen[id] = true
        list[#list + 1] = {id = id, name = G.ItemName(id), location = location}
    end
    if GetInventoryItemID then for _, s in ipairs({13, 14, 16, 17, 18}) do add(GetInventoryItemID("player", s)) end end
    if C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemID then
        for bag = 0, 4 do
            for position = 1, C_Container.GetContainerNumSlots(bag) do add(C_Container.GetContainerItemID(bag, position)) end
        end
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end
function G.Choose(preset, slot, id)
    if FM.InCombat() then return nil, "Change your equipment selection after combat." end
    local validSlot
    for _, s in ipairs(G.Slots(preset)) do if s == slot then validSlot = true end end
    if not validSlot then return nil, "That slot is not in this preset." end
    local items = G.Preset(preset)
    if not items then return nil, "Character settings are not ready." end
    if id == nil then items[slot] = nil; return true end
    for _, item in ipairs(G.Items(slot)) do
        if item.id == id then
            if slot == 17 and items[16] then
                local info = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
                local _, _, _, mainType = info(items[16])
                if mainType == "INVTYPE_2HWEAPON" then return nil, "Select a one-handed main weapon before adding an off-hand item." end
            end
            items[slot] = id
            if slot == 16 and item.location == "INVTYPE_2HWEAPON" then items[17] = nil end
            return true
        end
    end
    return nil, "That item is no longer in your bags or equipped."
end
function G.Definition(preset)
    local label
    for _, p in ipairs(G.presets) do if p.id == preset then label = p.label end end
    if not label then return nil, "Unknown gear preset." end
    local body, reason = FM.Managed.GearBody(G.Preset(preset), preset:match("^trinkets_") ~= nil)
    if not body then return nil, reason end
    return {id = preset, class = "ALL", name = "FM " .. label, body = body, spells = {}}
end
function G.Save(preset)
    local d, reason = G.Definition(preset)
    if not d then return nil, reason end
    return FM.Manager.RequestDefinition(d)
end
function G.EquipmentSets()
    local result = {}
    if not C_EquipmentSet or not C_EquipmentSet.GetEquipmentSetIDs or not C_EquipmentSet.GetEquipmentSetInfo then return result end
    for _, id in ipairs(C_EquipmentSet.GetEquipmentSetIDs()) do
        local name = C_EquipmentSet.GetEquipmentSetInfo(id)
        if type(name) == "string" and #name > 0 and not name:find("[%c%[%];]") then result[#result + 1] = {id = id, name = name} end
    end
    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end
function G.LinkSet(id)
    for _, item in ipairs(G.EquipmentSets()) do
        if item.id == id then
            local d = {id = "equipment_set", class = "ALL", name = "FM GearSet", spells = {},
                body = "#showtooltip\n/stopmacro [combat]\n/equipset " .. item.name}
            return FM.Manager.RequestDefinition(d)
        end
    end
    return nil, "Choose an existing equipment set from the list."
end
