local _, FM = ...
local U = {tab = "Macros", filter = "All", page = 1, partyPage = 1, mode = "name", gearIndex = 1, gearSlot = 16, itemPage = 1, setPage = 1, timerPage = 1}
FM.UI = U
local M, G, A = FM.Manager, FM.Gear, FM.Alerts
local ink = {0.20, 0.17, 0.12}
local white = "Interface\\Buttons\\WHITE8X8"
local classIcons = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
local themes = {
    WARRIOR = {color = {0.78, 0.61, 0.43}, coords = {0, 0.25, 0, 0.25}},
    MAGE = {color = {0.41, 0.80, 0.94}, coords = {0.25, 0.50, 0, 0.25}},
    ROGUE = {color = {1, 0.96, 0.41}, coords = {0.50, 0.75, 0, 0.25}},
    DRUID = {color = {1, 0.49, 0.04}, coords = {0.75, 1, 0, 0.25}},
    HUNTER = {color = {0.67, 0.83, 0.45}, coords = {0, 0.25, 0.25, 0.50}},
    SHAMAN = {color = {0, 0.44, 0.87}, coords = {0.25, 0.50, 0.25, 0.50}},
    PRIEST = {color = {1, 1, 1}, coords = {0.50, 0.75, 0.25, 0.50}},
    WARLOCK = {color = {0.58, 0.51, 0.79}, coords = {0.75, 1, 0.25, 0.50}},
    PALADIN = {color = {0.96, 0.55, 0.73}, coords = {0, 0.25, 0.50, 0.75}},
}
local neutralTheme = {color = {0.75, 0.61, 0.36}}
local factionColors = {Alliance = {0.17, 0.35, 0.65}, Horde = {0.65, 0.16, 0.12}}
local function texture(parent, x, y, width, height, layer, sublevel)
    local t = parent:CreateTexture(nil, layer or "BACKGROUND", nil, sublevel or 0)
    t:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y); t:SetSize(width, height)
    return t
end
local function fill(parent, x, y, width, height, r, g, b, a)
    local t = texture(parent, x, y, width, height)
    t:SetTexture(white); t:SetVertexColor(r, g, b, a or 1)
    return t
end
local function atlas(t, name)
    if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name) then
        t:SetTexCoord(0, 1, 0, 1); t:SetAtlas(name); return true
    end
    return false
end
local function classArt(t, class, theme)
    if theme.coords then
        if not atlas(t, "classicon-" .. string.lower(class)) then
            t:SetTexture(classIcons); t:SetTexCoord(unpack(theme.coords))
        end
        t:Show()
    else t:Hide() end
end
local function paintButton(b)
    local color = (U.theme or neutralTheme).color
    if not b:IsEnabled() then
        b:SetBackdropColor(0.86, 0.83, 0.76, 1)
        b:SetBackdropBorderColor(0.68, 0.62, 0.50, 0.65)
        b.caption:SetTextColor(0.46, 0.43, 0.36)
    elseif b.selected or b.hovered then
        local depth = b.selected and 0.22 or 0.10
        b:SetBackdropColor(0.98 - (1 - color[1]) * depth, 0.96 - (1 - color[2]) * depth, 0.88 - (1 - color[3]) * depth, 1)
        b:SetBackdropBorderColor(color[1] * 0.60, color[2] * 0.57, color[3] * 0.48, 1)
        b.caption:SetTextColor(unpack(ink))
    else
        b:SetBackdropColor(0.94, 0.90, 0.80, 1)
        b:SetBackdropBorderColor(0.64, 0.51, 0.30, 0.80)
        b.caption:SetTextColor(unpack(ink))
    end
end
local function choose(b, active)
    b.selected = active; paintButton(b)
end
local function text(parent, x, y, width, height, size)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    label:SetSize(width, height)
    label:SetJustifyH("LEFT"); label:SetJustifyV("TOP")
    label:SetTextColor(unpack(ink))
    label:SetShadowOffset(0, 0)
    if size then label:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size, "") end
    return label
end
local function button(parent, label, x, y, width, callback)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y); b:SetSize(width, 25)
    b:SetBackdrop({bgFile = white, edgeFile = white, edgeSize = 1})
    b.caption = text(b, 8, 4, width - 16, 18, 12)
    b.caption:SetJustifyH("CENTER"); b.caption:SetJustifyV("MIDDLE")
    b:SetFontString(b.caption); b:SetText(label)
    b:SetScript("OnClick", callback)
    b:SetScript("OnEnter", function(self) self.hovered = true; paintButton(self) end)
    b:SetScript("OnLeave", function(self) self.hovered = false; paintButton(self) end)
    b:SetScript("OnEnable", paintButton); b:SetScript("OnDisable", paintButton)
    paintButton(b)
    return b
end
local function edit(parent, x, y, width)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y); box:SetSize(width, 25)
    box:SetAutoFocus(false); box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return box
end
local function notice(ok, reason)
    if not ok then M.notice = reason or "No change made."; FM.API.Say(M.notice) end
    U.Refresh()
end
local function selected() return U.selected and FM.Core.FindDefinition(U.selected) end
local function selectedMacro()
    local db = FM.API.State()
    return db and U.selected and db.managed[U.selected]
end

function U.ApplyTheme()
    if not U.frame then return end
    local className, class = UnitClass("player")
    local faction, factionName
    if UnitFactionGroup then faction, factionName = UnitFactionGroup("player") end
    U.theme = themes[class] or neutralTheme
    U.themeClass, U.themeFaction = class, faction
    local artPath = themes[class] and ("Interface\\AddOns\\ForeverMacros\\Art\\" .. string.lower(class) .. ".tga")
    if artPath then
        if U.artPath ~= artPath or not U.artLoaded then
            U.artLoaded = U.classBackground:SetTexture(artPath) ~= false
        end
        if U.artLoaded then U.classBackground:Show() else U.classBackground:Hide() end
    else U.classBackground:Hide() end
    U.artPath = artPath
    local color = U.theme.color
    U.headerWash:SetVertexColor(color[1], color[2], color[3], 0.19)
    U.classRule:SetVertexColor(color[1] * 0.68, color[2] * 0.65, color[3] * 0.60, 1)
    U.identity:SetText((UnitName("player") or "Adventurer") .. "  /  " .. (className or "Classic"))
    classArt(U.classIcon, class, U.theme)
    classArt(U.classWatermark, class, U.theme)
    if artPath and U.artLoaded then U.classWatermark:Hide() end
    if U.artStatus then U.artStatus:SetText(artPath and (U.artLoaded and "Class art" or "Art missing. Restart WoW.") or "Classic theme") end
    local factionColor = factionColors[faction]
    U.factionText:SetText(factionColor and (factionName or faction) or "Azeroth")
    U.factionText:SetTextColor(unpack(factionColor or ink))
    U.factionRule:SetVertexColor(unpack(factionColor or neutralTheme.color))
    if factionColor and atlas(U.factionCrest, "charactercreate-icon-" .. string.lower(faction) .. "bg") then
        U.factionCrest:Show()
    else U.factionCrest:Hide() end
end

function U.Build()
    if U.frame then return end
    local f = CreateFrame("Frame", "ForeverMacrosWindow", UIParent, "BackdropTemplate")
    U.frame = f
    f:SetSize(1000, 724); f:SetPoint("CENTER"); f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true); f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    f:SetBackdrop({bgFile = white, edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 24,
        insets = {left = 8, right = 8, top = 8, bottom = 8}})
    f:SetBackdropColor(0.97, 0.93, 0.83, 1); f:SetBackdropBorderColor(1, 0.84, 0.52, 1)
    U.parchment = texture(f, 12, 12, 976, 700, "BACKGROUND", -7)
    U.parchment:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal")
    U.parchment:SetAlpha(0.35)
    U.classBackground = texture(f, 12, 12, 976, 700, "BACKGROUND", -6)
    U.classBackground:SetAlpha(0.88)
    U.headerWash = fill(f, 14, 14, 972, 86, 1, 1, 1, 0.19)
    fill(f, 20, 18, 498, 78, 1, 0.97, 0.90, 0.84)
    fill(f, 534, 22, 180, 73, 1, 0.97, 0.90, 0.84)
    fill(f, 726, 64, 177, 28, 1, 0.97, 0.90, 0.84)
    fill(f, 18, 678, 964, 34, 1, 0.97, 0.90, 0.94)
    fill(f, 22, 102, 956, 1, 0.55, 0.41, 0.22, 0.65)
    fill(f, 22, 105, 956, 1, 1, 0.98, 0.88, 0.8)
    fill(f, 22, 673, 956, 1, 0.55, 0.41, 0.22, 0.4)
    U.classRule = fill(f, 106, 87, 312, 2, 1, 1, 1)
    U.classIcon = texture(f, 28, 26, 60, 60, "ARTWORK")
    U.classWatermark = texture(f, 708, 363, 238, 238)
    U.classWatermark:SetAlpha(0.32)
    U.factionCrest = texture(f, 538, 28, 56, 56, "ARTWORK")
    U.factionText = text(f, 600, 42, 108, 24, 16)
    U.factionRule = fill(f, 600, 74, 94, 2, 1, 1, 1)
    text(f, 106, 24, 510, 34, 28):SetText("Forever Macros")
    U.identity = text(f, 108, 63, 398, 23, 14)
    U.ApplyTheme()
    if UIParent and UIParent.GetWidth then
        f:SetScale(math.min(1, (UIParent:GetWidth() - 20) / 1000, (UIParent:GetHeight() - 20) / 724))
    end
    button(f, "Close", 910, 28, 66, function() f:Hide() end)
    U.status = text(f, 24, 686, 850, 28, 12)
    text(f, 902, 690, 76, 18, 11):SetText("v" .. FM.Version)
    U.artStatus = text(f, 730, 68, 245, 23, 11)
    button(f, "Update installed macros", 700, 120, 280, function() notice(M.UpdateInstalled()) end)
    U.panels, U.tabs, U.filters = {}, {}, {}
    for i, name in ipairs({"Macros", "Equipment", "Boss reminders", "Help"}) do
        local tab = name
        U.tabs[name] = button(f, name, 20 + (i - 1) * 165, 120, 155, function() U.tab = tab; U.Refresh() end)
        local panel = CreateFrame("Frame", nil, f)
        panel:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -164); panel:SetSize(1000, 500)
        fill(panel, 14, -7, 972, 514, 1, 0.98, 0.91, 0.62)
        U.panels[name] = panel
    end
    local p = U.panels.Macros
    fill(p, 297, 0, 1, 495, 0.55, 0.41, 0.22, 0.22)
    fill(p, 675, 0, 1, 495, 0.55, 0.41, 0.22, 0.22)
    fill(p, 304, 118, 362, 175, 0.92, 0.88, 0.78, 0.80)
    U.classText = text(p, 20, 0, 265, 22, 14)
    for i, name in ipairs({"All", "Starter", "Attacks", "PvP"}) do
        local filter = name
        U.filters[name] = button(p, name, 20 + (i - 1) * 67, 26, 64, function() U.filter = filter; U.page = 1; U.Refresh() end)
    end
    U.search = CreateFrame("EditBox", nil, p, "InputBoxTemplate")
    U.search:SetPoint("TOPLEFT", p, "TOPLEFT", 26, -59); U.search:SetSize(259, 24)
    U.search:SetAutoFocus(false); U.search:SetMaxLetters(60)
    U.search:SetScript("OnTextChanged", function(self) U.query = self:GetText():lower(); U.page = 1; U.Refresh() end)
    U.search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    U.search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    U.rows = {}
    for i = 1, 15 do
        local b = button(p, "", 20, 91 + (i - 1) * 25, 265, function(self)
            U.selected = self.definition.id; U.Refresh()
        end)
        b:SetSize(265, 24)
        U.rows[i] = b
    end
    button(p, "Previous", 20, 470, 85, function() U.page = math.max(1, U.page - 1); U.Refresh() end)
    U.pageLabel = text(p, 115, 475, 65, 20)
    button(p, "Next", 195, 470, 90, function() U.page = U.page + 1; U.Refresh() end)
    U.title = text(p, 310, 0, 350, 27, 18)
    U.description = text(p, 310, 35, 350, 82, 11)
    U.preview = text(p, 310, 126, 350, 164, 11)
    U.assignment = text(p, 310, 296, 350, 75, 12)
    button(p, "Install / update selected", 310, 380, 245, function()
        local d, db = selected(), FM.API.State()
        if not d then return end
        notice(M.Request(d.id, db.choices[d.id]))
    end)
    button(p, "Use default targeting", 310, 411, 245, function()
        if selected() then notice(M.Request(U.selected, {kind = "default"})) end
    end)
    button(p, "Cancel queued change", 310, 442, 245, function()
        M.pending[U.selected or ""] = nil
        FM.API.State().wanted[U.selected or ""] = nil
        M.notice = "Queued change cancelled. The active macro is unchanged."; U.Refresh()
    end)
    text(p, 690, 0, 285, 26, 18):SetText("Assign a teammate")
    text(p, 690, 32, 285, 66, 12):SetText("Select a friendly action, then click a name. The same macro stays on your bar. During combat, the change waits until combat ends.")
    U.modeButton = button(p, "Mode: pin this person", 690, 106, 285, function()
        U.mode = U.mode == "name" and "slot" or "name"; U.Refresh()
    end)
    U.partyRows = {}
    for i = 1, 8 do
        U.partyRows[i] = button(p, "", 690, 142 + (i - 1) * 33, 285, function(self)
            local d = selected()
            if not d then return end
            notice(M.Request(d.id, {kind = U.mode, unit = U.mode == "name" and self.member.name or self.member.unit}))
        end)
    end
    button(p, "Previous", 690, 414, 100, function() U.partyPage = math.max(1, U.partyPage - 1); U.Refresh() end)
    button(p, "Next", 875, 414, 100, function() U.partyPage = U.partyPage + 1; U.Refresh() end)
    text(p, 690, 451, 285, 48, 11):SetText("Pin follows one name. Slot follows whoever occupies that party or raid slot, including replacements. Frame sorting can differ from slot order.")

    p = U.panels.Equipment
    text(p, 20, 0, 960, 48, 13):SetText("Select a preset. Capture your equipped items, or choose a slot and click an item from your bags. Save its macro, then drag it to your bar once.")
    for i, preset in ipairs(G.presets) do
        local index = i
        button(p, preset.label, 20, 60 + (i - 1) * 31, 245, function()
            U.gearIndex = index; U.gearSlot = G.Slots(G.presets[index].id)[1]; U.itemPage = 1; U.Refresh()
        end)
    end
    U.gearTitle = text(p, 20, 196, 245, 25, 16)
    U.slotButtons = {}
    for i = 1, 3 do
        U.slotButtons[i] = button(p, "", 20, 230 + (i - 1) * 31, 245, function(self)
            U.gearSlot = self.slot; U.itemPage = 1; U.Refresh()
        end)
    end
    button(p, "Capture equipped items", 20, 336, 245, function()
        local ok, reason = G.Capture(G.presets[U.gearIndex].id)
        if ok then M.notice = "Captured. Review the items, then save the macro." end
        notice(ok, reason)
    end)
    button(p, "Save preset macro", 20, 369, 245, function() notice(G.Save(G.presets[U.gearIndex].id)) end)
    button(p, "Leave selected slot unchanged", 20, 402, 245, function() notice(G.Choose(G.presets[U.gearIndex].id, U.gearSlot, nil)) end)
    text(p, 20, 446, 245, 53, 11):SetText("An empty preset slot leaves that slot unchanged. The game checks class, level, ownership, cooldowns, and combat restrictions when you press the macro.")
    U.itemTitle = text(p, 290, 60, 365, 25, 16)
    U.itemRows = {}
    for i = 1, 10 do
        U.itemRows[i] = button(p, "", 290, 95 + (i - 1) * 31, 365, function(self)
            notice(G.Choose(G.presets[U.gearIndex].id, U.gearSlot, self.item.id))
        end)
    end
    button(p, "Previous", 290, 414, 100, function() U.itemPage = math.max(1, U.itemPage - 1); U.Refresh() end)
    button(p, "Next", 555, 414, 100, function() U.itemPage = U.itemPage + 1; U.Refresh() end)
    U.gearPreview = text(p, 690, 60, 285, 210, 12)
    text(p, 690, 282, 285, 25, 15):SetText("Existing equipment sets")
    U.setRows = {}
    for i = 1, 4 do
        U.setRows[i] = button(p, "", 690, 317 + (i - 1) * 31, 285, function(self) notice(G.LinkSet(self.entry.id)) end)
    end
    button(p, "Previous", 690, 445, 100, function() U.setPage = math.max(1, U.setPage - 1); U.Refresh() end)
    button(p, "Next", 875, 445, 100, function() U.setPage = U.setPage + 1; U.Refresh() end)
    U.setHint = text(p, 690, 480, 285, 22, 11)

    p = U.panels["Boss reminders"]
    U.alertStatus = text(p, 20, 0, 950, 45, 13)
    U.alertToggle = button(p, "Enable reminders", 20, 54, 235, function()
        local db = FM.API.State()
        db.alerts.enabled = not db.alerts.enabled; A.Clear(); U.Refresh()
    end)
    button(p, "Test selected macro reminder", 270, 54, 270, function() A.Show(U.selected, "Preview only. No spell is cast.", true) end)
    U.alertMacro = button(p, "Choose installed macro", 20, 96, 520, function()
        local choices, db = {}, FM.API.State()
        for _, d in ipairs(FM.Catalog) do if db.managed[d.id] then choices[#choices + 1] = d.id end end
        local index = 0
        for i, id in ipairs(choices) do if id == U.selected then index = i end end
        if #choices > 0 then U.selected = choices[index % #choices + 1] end
        U.Refresh()
    end)
    text(p, 570, 98, 170, 25, 12):SetText("Seconds before timer ends:")
    U.lead = edit(p, 760, 94, 60); U.lead:SetText("3")
    text(p, 20, 140, 520, 30, 16):SetText("Observed DBM timers")
    U.timerRows = {}
    for i = 1, 8 do
        U.timerRows[i] = button(p, "", 20, 180 + (i - 1) * 31, 520, function(self) U.alertEntry = self.entry; U.Refresh() end)
    end
    button(p, "Previous timers", 20, 430, 150, function() U.timerPage = math.max(1, U.timerPage - 1); U.Refresh() end)
    button(p, "Next timers", 390, 430, 150, function() U.timerPage = U.timerPage + 1; U.Refresh() end)
    U.timerHint = text(p, 20, 460, 520, 40, 11)
    U.alertSelection = text(p, 570, 140, 405, 60, 12)
    button(p, "Link timer to chosen macro", 570, 215, 310, function()
        notice(A.Link(U.alertEntry, U.selected, U.lead:GetText()))
    end)
    button(p, "Remove selected reminder", 570, 248, 310, function()
        if U.alertEntry then FM.API.State().alerts.rules[U.alertEntry.key] = nil; A.Clear(); U.Refresh() end
    end)
    text(p, 570, 292, 405, 170, 12):SetText("Configure after combat. Choose a timer only after checking what its endpoint means in that encounter.\n\nReminders follow readable DBM timers, not cooldown or debuff decisions. Secret or missing data is skipped.\n\nNo boss coverage or advance timing has been verified in-game. Some Forever boss modules are still placeholders.")

    p = U.panels.Help
    text(p, 25, 5, 945, 460, 14):SetText("MACROS\nSearch for an action and install it. Core attacks appear when learned and space is free. Choosing an unlearned optional action saves it for later. + installed, ~ saved, * unavailable. Drag the macro to your bar once; assignment changes update the same macro.\n\nTEAMMATES\nPin a person, or follow a party/raid slot. Clicking a name requests the change. During combat, the old assignment stays active until the queued change is applied. Reloading clears unsaved pending requests. Manual edits are preserved.\n\nEQUIPMENT\nNo item names need typing. Capture equipment or select items from your bags. Weapon macros equip the saved items when you press them. Trinket equipping and full equipment sets are blocked in combat. Use TrinketTop or TrinketBottom from the macro library to activate an equipped trinket.\n\nREMINDERS\nBoss reminders are optional and off by default. Test displays are demonstrations. Live reminders require a readable DBM timer that you link to a macro. They do not cast or change your action buttons.\n\nCOMMANDS\n/fm opens this window. /fm status shows version and slots. /fm off pauses additions. /fm on enables them. /fm reserve NUMBER keeps slots free. /fm retry clears an API fault. See README.md for restoration and live-test steps.")
    UISpecialFrames = UISpecialFrames or {}; table.insert(UISpecialFrames, "ForeverMacrosWindow")
    f:Hide()
end

function U.Refresh()
    if not U.frame or not U.frame:IsShown() then return end
    local db = FM.API.State()
    if not db then return end
    U.ApplyTheme()
    for name, b in pairs(U.tabs) do choose(b, name == U.tab) end
    for name, b in pairs(U.filters) do choose(b, name == U.filter) end
    for name, panel in pairs(U.panels) do if name == U.tab then panel:Show() else panel:Hide() end end
      U.status:SetText((FM.InCombat() and "In combat. " or "") .. M.notice)
    if U.tab == "Macros" then
        local _, class = UnitClass("player")
        local list = {}
        for _, d in ipairs(FM.Catalog) do
            if (d.class == "ALL" or d.class == class) and (U.filter == "All" or d.category == U.filter
                or (U.filter == "Starter" and not d.optional) or (U.filter == "PvP" and d.pvp)) then
                local haystack = d.name .. " " .. d.id .. " " .. d.description .. " " .. d.category
                for _, s in ipairs(d.spells) do haystack = haystack .. " " .. s.english end
                if not U.query or U.query == "" or haystack:lower():find(U.query, 1, true) then list[#list + 1] = d end
            end
        end
        U.page = math.max(1, math.min(U.page, math.ceil(#list / 15)))
        local snapshot = not FM.InCombat() and FM.API.Snapshot()
        if snapshot then U.slotCount = snapshot.characterCount .. "/" .. snapshot.limit end
        U.classText:SetText((class or "CLASSIC") .. " | " .. #list .. " | Slots " .. (U.slotCount or "?"))
        U.pageLabel:SetText(U.page .. " / " .. math.max(1, math.ceil(#list / 15)))
        for i, b in ipairs(U.rows) do
            local d = list[(U.page - 1) * 15 + i]; b.definition = d
            choose(b, d and U.selected == d.id)
            if d then
                local body = M.Preview(d)
                b:SetText((U.selected == d.id and "> " or "") .. d.name .. (db.managed[d.id] and " +" or db.wanted[d.id] and " ~" or body and "" or " *")); b:Show()
            else b:Hide() end
        end
        local d = selected()
        U.title:SetText(d and d.name or "Choose a macro")
        U.description:SetText(d and (d.description .. "\nAttack: " .. d.attackPolicy) or "Search by ability or purpose in the box above the list. + installed, ~ saved for learning, * unavailable. Starter and attack macros install as you learn skills, while slots remain.")
        local body, reason
        if d then body, reason = M.Preview(d, db.choices[d.id]) end
        U.preview:SetText(body or reason or "Preview appears here.")
        local pending = d and M.pending[d.id]
        U.assignment:SetText(d and ((db.managed[d.id] and (M.Owned(d.id) and "Active: " .. M.AssignmentText(db.choices[d.id]) or "Edited, missing, or ambiguous. Preserved.") or "Not installed")
            .. (pending and "\nPending: " .. M.AssignmentText(pending.choice) or "")
            .. (db.wanted[d.id] and "\nSaved: installs when learned and space is free." or "")
            .. (not db.enabled and "\nAutomatic updates paused. /fm on" or "")
            .. (snapshot and snapshot.characterCount >= snapshot.limit - db.reserve and "\nSlots full after reserve. Free a character slot in /macro." or "")) or "")
        U.modeButton:SetText(U.mode == "name" and "Mode: pin this person" or "Mode: follow party / raid slot")
        local roster = M.Roster()
        U.partyPage = math.max(1, math.min(U.partyPage, math.ceil(#roster / 8)))
        for i, b in ipairs(U.partyRows) do
            local member = roster[(U.partyPage - 1) * 8 + i]; b.member = member
            if member then b:SetText(member.short .. " (" .. member.unit .. ")"); b:Show()
                if d and d.unitBody then b:Enable() else b:Disable() end
            else b:Hide() end
        end
    elseif U.tab == "Equipment" then
        local preset = G.presets[U.gearIndex]
        U.gearTitle:SetText(preset.label)
        local slots = G.Slots(preset.id)
        for i, b in ipairs(U.slotButtons) do
            b.slot = slots[i]
            choose(b, b.slot == U.gearSlot)
            if b.slot then b:SetText((b.slot == U.gearSlot and "> " or "") .. G.slots[b.slot]); b:Show() else b:Hide() end
        end
        local items = G.Items(U.gearSlot)
        U.itemPage = math.max(1, math.min(U.itemPage, math.ceil(#items / 10)))
        U.itemTitle:SetText(G.slots[U.gearSlot] .. " | equipped and bags")
        for i, b in ipairs(U.itemRows) do
            b.item = items[(U.itemPage - 1) * 10 + i]
            if b.item then b:SetText(b.item.name); b:Show() else b:Hide() end
        end
        local summary = {"Selected items:"}
        for _, slot in ipairs(slots) do summary[#summary + 1] = G.slots[slot] .. ": " .. G.ItemName(G.Preset(preset.id)[slot]) end
        local def, reason = G.Definition(preset.id)
        summary[#summary + 1] = "\n" .. (def and def.body or reason)
        U.gearPreview:SetText(table.concat(summary, "\n"))
        local sets = G.EquipmentSets()
        U.setPage = math.max(1, math.min(U.setPage, math.ceil(#sets / 4)))
        for i, b in ipairs(U.setRows) do
            b.entry = sets[(U.setPage - 1) * 4 + i]
            if b.entry then b:SetText(b.entry.name); b:Show() else b:Hide() end
        end
        U.setHint:SetText(#sets == 0 and "No native equipment sets available." or "Page " .. U.setPage .. ". Click a set to update FM GearSet.")
    elseif U.tab == "Boss reminders" then
        U.alertStatus:SetText((A.connected and "DBM connected. " or "DBM is not loaded. ") .. "Live encounter timing is unverified. Restricted signals skipped: " .. A.blocked)
        U.alertToggle:SetText(db.alerts.enabled and "Disable reminders" or "Enable reminders")
        U.alertMacro:SetText("Chosen macro: " .. (selectedMacro() and selectedMacro().name or "click to choose an installed macro"))
        local entries, seen = {}, {}
        for _, entry in ipairs(A.recent) do entries[#entries + 1] = entry; seen[entry.key] = true end
        for key, rule in pairs(db.alerts.rules) do if not seen[key] then entries[#entries + 1] = {key = key, label = rule.label} end end
        table.sort(entries, function(a, b) return a.key < b.key end)
        U.timerPage = math.max(1, math.min(U.timerPage, math.ceil(#entries / 8)))
        for i, b in ipairs(U.timerRows) do
            b.entry = entries[(U.timerPage - 1) * 8 + i]
            choose(b, b.entry and U.alertEntry and U.alertEntry.key == b.entry.key)
            if b.entry then b:SetText((U.alertEntry and U.alertEntry.key == b.entry.key and "> " or "") .. b.entry.label); b:Show() else b:Hide() end
        end
        U.timerHint:SetText(#entries == 0 and "No readable timers observed yet. Run a supported encounter with DBM, then return here to link a timer. The Test button previews the display only." or "Selected timers are estimates from DBM. Encounter delays or phase changes may change them.")
        local rule = U.alertEntry and db.alerts.rules[U.alertEntry.key]
        U.alertSelection:SetText(U.alertEntry and (U.alertEntry.label .. (rule and "\nLinked. Reminder: " .. rule.lead .. " seconds before the end." or "\nNot linked yet.")) or "Select an observed timer.")
    end
end

function U.Toggle()
    if not FM.API.Supported() then FM.API.Say("This release supports Forever 1.60.x only."); return end
    U.Build()
    if U.frame:IsShown() then U.frame:Hide() else M.RefreshCache(); U.frame:Show(); U.Refresh() end
end

function U.Alert(message, icon)
    if not U.alertFrame then
        local f = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        f:SetSize(480, 105); f:SetPoint("TOP", UIParent, "TOP", 0, -140); f:SetFrameStrata("HIGH")
        f:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2})
        f:SetBackdropColor(1, 0.94, 0.77, 0.96); f:SetBackdropBorderColor(0.8, 0.3, 0.15, 1)
        f.icon = f:CreateTexture(nil, "ARTWORK"); f.icon:SetSize(48, 48); f.icon:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -28)
        f.label = text(f, 72, 12, 396, 85, 16)
        U.alertFrame = f
    end
    U.alertFrame.icon:SetTexture(icon or 134400)
    U.alertFrame.label:SetText(message); U.alertFrame:Show()
    U.alertSerial = (U.alertSerial or 0) + 1
    local serial = U.alertSerial
    C_Timer.After(4, function() if U.alertSerial == serial then U.alertFrame:Hide() end end)
end

local frame = CreateFrame("Frame")
for _, event in ipairs({"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "EQUIPMENT_SETS_CHANGED", "GET_ITEM_INFO_RECEIVED", "PLAYER_REGEN_DISABLED", "PLAYER_ENTERING_WORLD", "UNIT_FACTION"}) do frame:RegisterEvent(event) end
frame:SetScript("OnEvent", function(_, event, unit)
    if event == "UNIT_FACTION" and unit ~= "player" then return end
    U.Refresh()
end)
