local _, Raid = ...
local UI = Raid.UI

local ROW_HEIGHT = UI.ROW_HEIGHT
local FRAME_WIDTH, FRAME_HEIGHT = UI.FRAME_WIDTH, UI.FRAME_HEIGHT
local ROSTER_WIDTH, ROSTER_ROW_WIDTH = UI.ROSTER_WIDTH, UI.ROSTER_ROW_WIDTH
local ASSIGNMENT_ROW_WIDTH = UI.ASSIGNMENT_ROW_WIDTH
local BOSS_RAIL_WIDTH, BOSS_BUTTON_SIZE = UI.BOSS_RAIL_WIDTH, UI.BOSS_BUTTON_SIZE
local NAV_RAIL_WIDTH, BOSS_RAIL_GAP = UI.NAV_RAIL_WIDTH, UI.BOSS_RAIL_GAP
local ACCENT, BORDER, MUTED, WHITE = UI.ACCENT, UI.BORDER, UI.MUTED, UI.WHITE
local ROLE_TEXTURE, ROLE_COORDS = UI.ROLE_TEXTURE, UI.ROLE_COORDS
local READY_CHECK_COLUMNS = UI.READY_CHECK_COLUMNS
local READY_CHECK_BY_SPELL = UI.READY_CHECK_BY_SPELL
local READY_CHECK_FOOD_MATCHES = UI.READY_CHECK_FOOD_MATCHES
local READY_CHECK_GRID_START = UI.READY_CHECK_GRID_START
local READY_CHECK_COLUMN_WIDTH = UI.READY_CHECK_COLUMN_WIDTH
local GEAR_INSPECT_SLOTS = UI.GEAR_INSPECT_SLOTS
local Pixel, PixelForRegion = UI.Pixel, UI.PixelForRegion
local PhysicalPixels = UI.PhysicalPixels
local SetPixelHeight, SetPixelWidth = UI.SetPixelHeight, UI.SetPixelWidth
local PixelSetSize, FitAndClampToScreen = UI.PixelSetSize, UI.FitAndClampToScreen
local SnapAnchors, SnapTree = UI.SnapAnchors, UI.SnapTree
local BackdropFrame, Font = UI.BackdropFrame, UI.Font
local InstallPixelBorder, Button = UI.InstallPixelBorder, UI.Button
local StyleButton, AddButtonIcon = UI.StyleButton, UI.AddButtonIcon
local AddDropdownArrow, AddButtonTooltip = UI.AddDropdownArrow, UI.AddButtonTooltip
local Panel, SectionHeader, EditField = UI.Panel, UI.SectionHeader, UI.EditField
local ShowSelectionMenu = UI.ShowSelectionMenu
local ShowMultiSelectionMenu = UI.ShowMultiSelectionMenu
local CurrentGuildRankEntries = UI.CurrentGuildRankEntries
local SetClassText, GetClassRowColor = UI.SetClassText, UI.GetClassRowColor
local CreateScrollArea = UI.CreateScrollArea
function Raid:CreateQuickActionBar()
    if self.quickActionBar then return self.quickActionBar end
    local saved = self.db.quickBar
    local bar = Panel(UIParent)
    PixelSetSize(bar, 430, 42)
    bar:SetPoint(
        saved.point or "CENTER", UIParent,
        saved.point or "CENTER", saved.x or 0, saved.y or 0)
    bar:SetFrameStrata("MEDIUM")
    bar:SetScale(self:GetHUDScale())
    bar:SetClampedToScreen(true)
    bar:SetMovable(true)
    bar:EnableMouse(true)

    bar.Handle = CreateFrame("Frame", nil, bar)
    bar.Handle:SetPoint("TOPLEFT", 1, -1)
    bar.Handle:SetPoint("BOTTOMLEFT", 1, 1)
    bar.Handle:SetWidth(88)
    bar.Handle:EnableMouse(true)
    bar.Handle:RegisterForDrag("LeftButton")
    bar.Handle:SetScript(
        "OnDragStart", function() bar:StartMoving() end)
    bar.Handle:SetScript("OnDragStop", function()
        bar:StopMovingOrSizing()
        local point, _, _, x, y = bar:GetPoint(1)
        Raid.db.quickBar.point = point
        Raid.db.quickBar.x, Raid.db.quickBar.y = x, y
    end)
    bar.Handle:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            bar:ClearAllPoints()
            bar:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            Raid.db.quickBar.point = "CENTER"
            Raid.db.quickBar.x, Raid.db.quickBar.y = 0, 0
        end
    end)
    bar.Handle:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Raid Tools")
        GameTooltip:AddLine(
            "Drag to move. Right-click to reset position.",
            MUTED[1], MUTED[2], MUTED[3], true)
        GameTooltip:Show()
    end)
    bar.Handle:HookScript(
        "OnLeave", function() GameTooltip:Hide() end)
    bar.Handle.Icon = bar.Handle:CreateTexture(nil, "ARTWORK")
    bar.Handle.Icon:SetTexture("Interface\\Icons\\INV_BannerPVP_02")
    PixelSetSize(bar.Handle.Icon, 22, 22)
    bar.Handle.Icon:SetPoint("LEFT", 8, 0)
    bar.Handle.Title = Font(bar.Handle, 9, "accent", "RAID\nTOOLS")
    bar.Handle.Title:SetPoint("LEFT", bar.Handle.Icon, "RIGHT", 6, 0)

    local actions = {
        {
            label = "READY",
            icon = "Interface\\RaidFrame\\ReadyCheck-Ready",
            title = "Ready Check",
            detail = "Start Blizzard's raid ready check.",
            action = function() Raid:StartReadyCheck() end,
            rightAction = function()
                Raid:ShowPinnedReadyCheckWindow()
            end,
        },
        {
            label = "ROLES",
            icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
            title = "Role Check",
            detail = "Ask the group to confirm their combat roles.",
            action = function() Raid:StartRoleCheck() end,
        },
        {
            label = "PULL 10",
            icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
            title = "Pull Timer",
            detail = "Start a 10-second group countdown.",
            action = function() Raid:StartPullCountdown(10) end,
        },
        {
            label = "BREAK 5",
            icon = "Interface\\Icons\\INV_Drink_05",
            title = "Break Timer",
            detail = "Announce and start a five-minute break.",
            action = function() Raid:StartBreakTimer(5) end,
            rightAction = function(button)
                ShowSelectionMenu(
                    button,
                    {
                        { 5, "5 minutes" },
                        { 10, "10 minutes" },
                        { 15, "15 minutes" },
                    },
                    5,
                    function(minutes)
                        Raid:StartBreakTimer(minutes)
                    end,
                    156)
            end,
            rightDetail =
                "\nRight-click to choose 5, 10, or 15 minutes.",
        },
        {
            label = "ASSIGN",
            icon = "Interface\\Icons\\INV_Misc_Note_05",
            title = "Raid Assignments",
            detail = "Open LunaRaids directly to the raid assignments.",
            action = function()
                Raid:CreateUI()
                if Raid.settingsView and Raid.settingsView:IsShown() then
                    Raid:ExitSettingsView()
                end
                Raid.frame:Show()
                Raid:SetWorkspaceMode("ASSIGNMENTS")
            end,
        },
    }
    bar.Actions = {}
    local previous
    for index, entry in ipairs(actions) do
        local button = Button(bar, entry.label, 106, 30)
        local action, rightAction =
            entry.action, entry.rightAction
        if previous then
            button:SetPoint("LEFT", previous, "RIGHT", 4, 0)
        else
            button:SetPoint("LEFT", bar.Handle, "RIGHT", 4, 0)
        end
        AddButtonIcon(button, entry.icon, 16)
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:SetScript("OnClick", function(_, mouseButton)
            if mouseButton == "RightButton" and rightAction then
                rightAction(button)
            else
                action()
            end
        end)
        button.tooltipAnchorFrame = bar
        AddButtonTooltip(
            button, entry.title,
            entry.detail .. (
                entry.rightDetail
                or rightAction
                    and "\nRight-click to open and pin the latest results."
                or ""))
        if index == 1 then StyleButton(button, "primary") end
        bar.Actions[index] = button
        previous = button
    end
    bar.BossNav = CreateFrame("Frame", nil, bar)
    bar.BossNav:SetPoint("TOPLEFT", bar, "TOPLEFT", 4, -40)
    bar.BossNav:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -4, 4)
    bar.BossNav.Background =
        bar.BossNav:CreateTexture(nil, "BACKGROUND")
    bar.BossNav.Background:SetTexture(WHITE)
    bar.BossNav.Background:SetAllPoints()
    bar.BossNav.Background:SetVertexColor(.018, .045, .062, .92)
    bar.BossNav.Previous = Button(bar.BossNav, "", 28, 24)
    bar.BossNav.Previous:SetPoint("LEFT", 4, -1)
    bar.BossNav.Previous.Icon =
        bar.BossNav.Previous:CreateTexture(nil, "ARTWORK")
    bar.BossNav.Previous.Icon:SetTexture(
        "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    PixelSetSize(bar.BossNav.Previous.Icon, 16, 16)
    bar.BossNav.Previous.Icon:SetPoint("CENTER")
    bar.BossNav.Previous:SetScript(
        "OnClick", function() Raid:NavigateBoss(-1) end)
    bar.BossNav.Previous.tooltipAnchorFrame = bar
    AddButtonTooltip(
        bar.BossNav.Previous, "Previous Boss",
        "Select the previous boss and set it as the current encounter.")
    bar.BossNav.Next = Button(bar.BossNav, "", 28, 24)
    bar.BossNav.Next:SetPoint("RIGHT", -4, -1)
    bar.BossNav.Next.Icon =
        bar.BossNav.Next:CreateTexture(nil, "ARTWORK")
    bar.BossNav.Next.Icon:SetTexture(
        "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    PixelSetSize(bar.BossNav.Next.Icon, 16, 16)
    bar.BossNav.Next.Icon:SetPoint("CENTER")
    bar.BossNav.Next:SetScript(
        "OnClick", function() Raid:NavigateBoss(1) end)
    bar.BossNav.Next.tooltipAnchorFrame = bar
    AddButtonTooltip(
        bar.BossNav.Next, "Next Boss",
        "Select the next boss and set it as the current encounter.")
    bar.BossNav.Name = Font(bar.BossNav, 9, "accent", "")
    bar.BossNav.Name:SetPoint(
        "LEFT", bar.BossNav.Previous, "RIGHT", 8, -1)
    bar.BossNav.Name:SetPoint(
        "RIGHT", bar.BossNav.Next, "LEFT", -8, -1)
    bar.BossNav.Name:SetJustifyH("CENTER")
    self.quickActionBar = bar
    return bar
end

function Raid:RefreshQuickActionBar()
    local bar = self:CreateQuickActionBar()
    local settings = self.db.quickBar
    local iconOnly = settings.iconOnly
    local buttonWidth = iconOnly and 38 or 106
    local actionCount = #(bar.Actions or {})
    bar:SetWidth(
        92 + (actionCount * buttonWidth)
            + (math.max(0, actionCount - 1) * 4) + 4)
    for _, button in ipairs(bar.Actions or {}) do
        button:SetWidth(buttonWidth)
        button.ActionIcon:ClearAllPoints()
        if iconOnly then
            button.ActionIcon:SetPoint("CENTER")
            button.Text:Hide()
        else
            button.ActionIcon:SetPoint("LEFT", 8, 0)
            button.Text:Show()
            button.Text:ClearAllPoints()
            button.Text:SetPoint("LEFT", 31, 0)
            button.Text:SetPoint("RIGHT", -8, 0)
            button.Text:SetJustifyH("LEFT")
        end
    end
    local raid = self.db.raidLocked and self:GetRaid() or nil
    local encounterIndex = raid and (
        self:GetCurrentBossIndex(raid)
            or tonumber(self.db.activeEncounter)) or nil
    local encounter = encounterIndex and encounterIndex >= 2
        and raid.encounters[encounterIndex] or nil
    local showBossNav = encounter
        and IsInRaid and IsInRaid()
        and self:IsLocalRaidEditor() or false
    bar:SetHeight(showBossNav and 76 or 42)
    bar.Handle:ClearAllPoints()
    bar.Handle:SetPoint("TOPLEFT", 1, -1)
    bar.Handle:SetPoint(
        "BOTTOMLEFT", 1, showBossNav and 35 or 1)
    bar.BossNav:SetShown(showBossNav)
    if showBossNav then
        bar.BossNav.Name:SetText(encounter.name:upper())
        local hasPrevious = encounterIndex > 2
        local hasNext = encounterIndex < #raid.encounters
        bar.BossNav.Previous:SetEnabled(hasPrevious)
        bar.BossNav.Next:SetEnabled(hasNext)
        bar.BossNav.Previous:SetAlpha(hasPrevious and 1 or .35)
        bar.BossNav.Next:SetAlpha(hasNext and 1 or .35)
    end
    local grouped = IsInGroup and IsInGroup()
    local raidGroup = IsInRaid and IsInRaid()
    local authorized = grouped and (
        UnitIsGroupLeader and UnitIsGroupLeader("player")
        or UnitIsGroupAssistant and UnitIsGroupAssistant("player"))
    local visibility = settings.visibility or "GROUP"
    local allowed = visibility == "ALWAYS"
        or visibility == "GROUP" and authorized
        or visibility == "RAID" and raidGroup and authorized
    if settings.hideInCombat
        and InCombatLockdown and InCombatLockdown()
    then
        allowed = false
    end
    bar:SetShown(not settings.hide and allowed or false)
end

