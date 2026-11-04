local _, FM = ...
local T = {}
FM.TrainingUI = T
local function errorText(message) T.message=message; if T.status then T.status:SetText(message) end end
function T.Place()
    local f=T.mounted
    if not f or T.placing or FM.InCombat() then return end
    T.placing=true
    f:ClearAllPoints();f:SetPoint("TOPLEFT",T.host,"TOPLEFT",570,0)
    T.placing=nil
end
function T.Detach()
    local f,s=T.mounted,T.saved
    if not f then return end
    T.mounted,T.saved=nil,nil
    f:Hide()
    f:SetParent(s.parent);f:SetScale(s.scale);f:SetSize(s.width,s.height)
    f:ClearAllPoints()
    for _,point in ipairs(s.points) do f:SetPoint(unpack(point)) end
    if f.titlebar then f.titlebar:EnableMouse(s.mouse) end
    if s.shown then f:Show() end
end
function T.Mount()
    if not T.host or FM.InCombat() or not FM.API.Ready() or not FM.API.Supported() then
        errorText("Open Training after combat on the supported Forever client.");return false
    end
    if T.mounted then T.Place();return true end
    local version=C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("WhatsTraining","Version")
    if version~="1.1.1" or not SlashCmdList or type(SlashCmdList.WHATSTRAINING)~="function" then
        errorText("Install and enable What's Training? Forever 1.1.1, then restart WoW. Other versions need an adapter check.");return false
    end
    local existed=WhatsTrainingFrame
    if not existed then
        local ok=pcall(SlashCmdList.WHATSTRAINING,"show")
        if not ok then errorText("What's Training? could not open. Try /wt debug.");return false end
    end
    local f=WhatsTrainingFrame
    if not f or type(f.GetParent)~="function" or not f.titlebar then
        errorText("What's Training? window is unavailable. Try /wt debug.");return false
    end
    local s={parent=f:GetParent(),scale=f:GetScale(),width=f:GetWidth(),height=f:GetHeight(),
        shown=existed and f:IsShown() or false,points={},mouse=f.titlebar:IsMouseEnabled()}
    for i=1,math.min(f:GetNumPoints(),16) do s.points[#s.points+1]={f:GetPoint(i)} end
    T.saved,T.mounted=s,f
    f:SetParent(T.host);f:SetScale(1);f:SetSize(400,495)
    f.titlebar:EnableMouse(false)
    if not T.hooked and hooksecurefunc then
        hooksecurefunc(f,"SetPoint",T.Place);T.hooked=true
    end
    T.Place();f:Show()
    errorText("What's Training? Forever 1.1.1 is shown here. Its original list handles levels, ranks, prices and trainer updates.")
    return true
end
function T.ShowAutomatic()
    FM.UI.tab="Macros";FM.UI.filter="Sequences";FM.UI.page=1
    FM.UI.search:SetText("FM ");FM.UI.Refresh()
end
function T.Build(h)
    T.host=FM.UI.panels.Training
    h.text(T.host,20,0,525,30,19):SetText("Training and automatic sequences")
    h.text(T.host,20,43,525,105,13):SetText("Your training list is on the right. Expand Available now or Next two levels to plan your trainer visit. The provider also lists missing previous ranks, later levels and known spells.\n\nLearning a skill updates eligible automatic macros after combat, including FM Easy and FM Totems. Gaining a level alone does not mean you learned it.")
    h.button(T.host,"View my automatic macros",20,167,270,T.ShowAutomatic)
    h.button(T.host,"Open training list",302,167,240,function() if T.Mount() and T.mounted then T.mounted:Show() end end)
    T.summary=h.text(T.host,20,213,520,125,12)
    h.text(T.host,20,345,520,91,12):SetText("Press FM Easy repeatedly for its fixed leveling routine. FM AutoOpen stops after its opener. Neither chooses the best next spell. Review the macro description before using it.\n\nPrices marked ~ are estimates. Visit your class trainer to verify costs. Pet skills and demon grimoires are not included by this provider.")
    T.status=h.text(T.host,20,448,520,48,11)
    T.host:SetScript("OnHide",T.Detach)
    FM.UI.frame:HookScript("OnHide",T.Detach)
end
function T.Refresh()
    local _,class=UnitClass("player")
    local db=FM.API.State();local lines={"Automatic macros for this character:"}
    for _,d in ipairs(FM.AutoSequences.definitions) do
        if d.class==class then
            local owned=db and db.managed[d.id]
            local body,reason=FM.Manager.Preview(d)
            local state=owned and (FM.Manager.Owned(d.id) and "installed" or "personal edit or removal preserved")
                or d.optional and "optional; install from Macros" or body and "needs a free character macro slot" or reason
            lines[#lines+1]=d.name..": "..state
        end
    end
    T.summary:SetText(table.concat(lines,"\n"))
    T.Mount()
end
