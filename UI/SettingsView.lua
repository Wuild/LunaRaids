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
function Raid:CreateSettingsView()
    if self.settingsView then return self.settingsView end
    local view = CreateFrame("Frame", nil, self.frame)
    view:SetPoint("TOPLEFT", 1, -46)
    view:SetPoint("BOTTOMRIGHT", -1, 1)
    view:SetFrameLevel(self.frame:GetFrameLevel() + 3)
    view.Background = view:CreateTexture(nil, "BACKGROUND")
    view.Background:SetTexture(WHITE)
    view.Background:SetAllPoints()
    view.Background:SetVertexColor(.012, .022, .031, 1)
    view.Title = Font(view, 15, "accent", "ADDON SETTINGS")
    view.Title:SetPoint("TOPLEFT", 20, -22)
    view.Title:Hide()
    view.Subtitle = Font(
        view, 10, "muted",
        "Interface, communication, and automation")
    view.Subtitle:SetPoint("TOPLEFT", 21, -50)
    view.Subtitle:Hide()
    view.GeneralTab = Button(view, "GENERAL", 126, 28)
    view.GeneralTab:SetPoint("TOPLEFT", 8, -8)
    view.AdminTab = Button(view, "RAID ADMIN", 126, 28)
    view.AdminTab:SetPoint("LEFT", view.GeneralTab, "RIGHT", 8, 0)
    view.CooldownTab = Button(view, "COOLDOWNS", 126, 28)
    view.CooldownTab:SetPoint("LEFT", view.AdminTab, "RIGHT", 8, 0)
    view.GeneralTab:SetScript("OnClick", function()
        Raid.settingsTab = "GENERAL"
        if Raid.settingsView and Raid.settingsView.Scroll then
            Raid.settingsView.Scroll:SetVerticalScroll(0)
        end
        Raid:RedrawSettingsView()
    end)
    view.AdminTab:SetScript("OnClick", function()
        Raid.settingsTab = "ADMIN"
        if Raid.settingsView and Raid.settingsView.Scroll then
            Raid.settingsView.Scroll:SetVerticalScroll(0)
        end
        Raid:RedrawSettingsView()
    end)
    view.CooldownTab:SetScript("OnClick", function()
        Raid.settingsTab = "COOLDOWNS"
        if Raid.settingsView and Raid.settingsView.Scroll then
            Raid.settingsView.Scroll:SetVerticalScroll(0)
        end
        Raid:RedrawSettingsView()
    end)
    view.Footer = CreateFrame("Frame", nil, view)
    view.Footer:SetPoint("BOTTOMLEFT", 1, 1)
    view.Footer:SetPoint("BOTTOMRIGHT", -1, 1)
    view.Footer:SetHeight(43)
    view.Footer.Background =
        view.Footer:CreateTexture(nil, "BACKGROUND")
    view.Footer.Background:SetTexture(WHITE)
    view.Footer.Background:SetAllPoints()
    view.Footer.Background:SetVertexColor(.018, .045, .062, 1)
    view.Footer.TopLine = view.Footer:CreateTexture(nil, "ARTWORK")
    view.Footer.TopLine:SetTexture(WHITE)
    view.Footer.TopLine:SetPoint("TOPLEFT")
    view.Footer.TopLine:SetPoint("TOPRIGHT")
    SetPixelHeight(view.Footer.TopLine, 1)
    view.Footer.TopLine:SetVertexColor(.12, .30, .40, 1)
    view.ResetAllSettings =
        Button(view.Footer, "RESET ALL SETTINGS", 168, 28)
    view.ResetAllSettings:SetPoint("RIGHT", -12, 0)
    StyleButton(view.ResetAllSettings, "danger")
    view.ResetAllSettings:SetScript("OnClick", function()
        StaticPopup_Show("LUNARAIDS_RESET_ALL_SETTINGS")
    end)
    AddButtonTooltip(
        view.ResetAllSettings, "Reset All Settings",
        "Restore addon options and every movable window to defaults.")
    view.Scroll, view.Content = CreateScrollArea(view)
    view.Scroll:SetPoint("TOPLEFT", 8, -44)
    view.Scroll:SetPoint("BOTTOMRIGHT", -8, 49)
    view.Content:SetWidth(math.max(1, view:GetWidth() - 28))

    local general = CreateFrame("Frame", nil, view.Content)
    general:SetPoint("TOPLEFT", 12, -8)
    general:SetPoint("TOPRIGHT", -12, -8)
    general:SetHeight(224)
    SectionHeader(general, "GENERAL")
    local interfaceCard = Panel(general)
    interfaceCard:SetPoint("TOPLEFT", 0, -40)
    interfaceCard:SetPoint("TOPRIGHT", 0, -40)
    interfaceCard:SetHeight(184)
    SectionHeader(interfaceCard, "INTERFACE & MESSAGES")
    local function SettingLabel(parent, text, description, y)
        local label = Font(parent, 10, "text", text)
        label:SetPoint("TOPLEFT", 14, y)
        local detail = Font(parent, 9, "muted", description)
        detail:SetPoint("TOPLEFT", 14, y - 16)
        return label, detail
    end

    SettingLabel(interfaceCard, "Minimap launcher",
        "Show the LibDBIcon button.", -36)
    view.Minimap = Button(interfaceCard, "", 142, 28)
    view.Minimap:SetPoint("TOPRIGHT", -14, -39)
    view.Minimap:SetScript("OnClick", function()
        Raid.db.minimap.hide = not Raid.db.minimap.hide
        Raid:RefreshMinimapButton()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(interfaceCard, "Announcement channel",
        "Click to cycle the assignment channel.", -82)
    view.Channel = Button(interfaceCard, "", 142, 28)
    view.Channel:SetPoint("TOPRIGHT", -14, -85)
    view.Channel:SetScript("OnClick", function()
        local order = {
            "AUTO", "RAID_WARNING", "RAID", "PARTY", "SAY",
        }
        local current = Raid.db.announcementChannel or "AUTO"
        local index = 1
        for candidate, value in ipairs(order) do
            if value == current then index = candidate break end
        end
        Raid.db.announcementChannel =
            order[(index % #order) + 1]
        Raid:RefreshSettingsView()
    end)
    SettingLabel(interfaceCard, "Message interval",
        "Delay between chat messages to avoid throttling.", -128)
    view.DelayMinus = Button(interfaceCard, "-", 30, 28)
    view.DelayMinus:SetPoint("TOPRIGHT", -126, -131)
    view.DelayValue = Button(interfaceCard, "", 88, 28)
    view.DelayValue:SetPoint(
        "LEFT", view.DelayMinus, "RIGHT", 4, 0)
    view.DelayPlus = Button(interfaceCard, "+", 30, 28)
    view.DelayPlus:SetPoint(
        "LEFT", view.DelayValue, "RIGHT", 4, 0)
    view.DelayMinus:SetScript("OnClick", function()
        Raid.db.messageDelay = math.max(
            .20, (Raid.db.messageDelay or .45) - .05)
        Raid:RefreshSettingsView()
    end)
    view.DelayPlus:SetScript("OnClick", function()
        Raid.db.messageDelay = math.min(
            1.50, (Raid.db.messageDelay or .45) + .05)
        Raid:RefreshSettingsView()
    end)

    view.ResetWindow = Button(view, "RESET WINDOW", 138, 27)
    view.ResetWindow:SetPoint(
        "BOTTOMLEFT", view, "BOTTOMLEFT", 116, 14)
    view.ResetWindow:SetScript(
        "OnClick", function() Raid:ResetWindowPosition() end)
    AddButtonTooltip(view.ResetWindow, "Reset Window",
        "Return LunaRaids to the center of the screen.")
    view.AutoMarker = Button(view, "", 174, 27)
    view.AutoMarker:SetPoint("BOTTOMLEFT", 264, 14)
    view.AutoMarker:SetScript("OnClick", function()
        Raid:ToggleAutoMarker()
        Raid:RefreshSettingsView()
    end)
    AddButtonTooltip(
        view.AutoMarker, "Auto Marker",
        "Automatically apply the configured marks when matching "
            .. "units for the current encounter are targeted.")
    view.QuickBar = Button(view, "", 174, 27)
    view.QuickBar:SetScript("OnClick", function()
        Raid.db.quickBar.hide = not Raid.db.quickBar.hide
        Raid:RefreshQuickActionBar()
        Raid:RefreshSettingsView()
    end)
    AddButtonTooltip(
        view.QuickBar, "Quick Action Bar",
        "Enable the standalone toolbar. Its visibility and permission "
            .. "rules are configured below.")
    local automation = Panel(view.Content)
    automation:SetPoint("TOPLEFT", general, "BOTTOMLEFT", 0, -10)
    automation:SetPoint("TOPRIGHT", general, "BOTTOMRIGHT", 0, -10)
    automation:SetHeight(416)
    SectionHeader(
        automation, "AUTOMATION",
        "Ready checks, raid markers, and quick-action behavior.")
    view.AutoMarker:SetParent(automation)
    view.AutoMarker:SetFrameLevel(automation:GetFrameLevel() + 1)
    view.QuickBar:SetParent(automation)
    view.QuickBar:SetFrameLevel(automation:GetFrameLevel() + 1)
    SettingLabel(
        automation, "Encounter auto marker",
        "Apply configured boss and add markers as units are targeted.",
        -38)
    view.AutoMarker:ClearAllPoints()
    view.AutoMarker:SetPoint("TOPRIGHT", automation, -14, -42)
    SettingLabel(
        automation, "Quick action bar",
        "Standalone controls for ready checks, roles, and pull timers.",
        -84)
    view.QuickBar:SetPoint("TOPRIGHT", automation, -14, -88)
    SettingLabel(
        automation, "Ready-check results",
        "Time the completed window remains open before fading.", -130)
    view.ReadyHoldMinus = Button(automation, "-", 30, 28)
    view.ReadyHoldMinus:SetPoint("TOPRIGHT", -126, -134)
    view.ReadyHoldValue = Button(automation, "", 88, 28)
    view.ReadyHoldValue:SetPoint(
        "LEFT", view.ReadyHoldMinus, "RIGHT", 4, 0)
    view.ReadyHoldPlus = Button(automation, "+", 30, 28)
    view.ReadyHoldPlus:SetPoint(
        "LEFT", view.ReadyHoldValue, "RIGHT", 4, 0)
    view.ReadyHoldMinus:SetScript("OnClick", function()
        Raid.db.readyCheck.holdDuration = math.max(
            5, (Raid.db.readyCheck.holdDuration or 15) - 5)
        Raid:RefreshSettingsView()
    end)
    view.ReadyHoldPlus:SetScript("OnClick", function()
        Raid.db.readyCheck.holdDuration = math.min(
            60, (Raid.db.readyCheck.holdDuration or 15) + 5)
        Raid:RefreshSettingsView()
    end)
    SettingLabel(
        automation, "Compact toolbar",
        "Show action icons without text labels.", -176)
    view.QuickBarIcons = Button(automation, "", 174, 27)
    view.QuickBarIcons:SetPoint("TOPRIGHT", automation, -14, -180)
    view.QuickBarIcons:SetScript("OnClick", function()
        Raid.db.quickBar.iconOnly = not Raid.db.quickBar.iconOnly
        Raid:RefreshQuickActionBar()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(
        automation, "Toolbar visibility",
        "Grouped modes require leader or assistant permissions.", -222)
    view.QuickBarVisibility = Button(automation, "", 174, 27)
    AddDropdownArrow(view.QuickBarVisibility)
    view.QuickBarVisibility:SetPoint(
        "TOPRIGHT", automation, -14, -226)
    view.QuickBarVisibility:SetScript("OnClick", function()
        ShowSelectionMenu(view.QuickBarVisibility, {
            { "ALWAYS", "Always" },
            { "GROUP", "Party or Raid" },
            { "RAID", "Raid Only" },
        }, Raid.db.quickBar.visibility or "GROUP", function(value)
            Raid.db.quickBar.visibility = value
            Raid:RefreshQuickActionBar()
            Raid:RefreshSettingsView()
        end)
    end)
    SettingLabel(
        automation, "Combat visibility",
        "Hide the quick action bar while you are in combat.", -268)
    view.QuickBarCombat = Button(automation, "", 174, 27)
    view.QuickBarCombat:SetPoint("TOPRIGHT", automation, -14, -272)
    view.QuickBarCombat:SetScript("OnClick", function()
        Raid.db.quickBar.hideInCombat =
            not Raid.db.quickBar.hideInCombat
        Raid:RefreshQuickActionBar()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(
        automation, "Ready-check window",
        "Automatically open LunaRaids results during ready checks.", -314)
    view.ReadyCheckWindow = Button(automation, "", 174, 27)
    view.ReadyCheckWindow:SetPoint(
        "TOPRIGHT", automation, -14, -318)
    view.ReadyCheckWindow:SetScript("OnClick", function()
        Raid.db.readyCheck.showWindow =
            Raid.db.readyCheck.showWindow == false
        if Raid.db.readyCheck.showWindow == false
            and Raid.readyCheckWindow
        then
            Raid.readyCheckWindow:Hide()
        end
        Raid:RefreshSettingsView()
    end)
    SettingLabel(
        automation, "Personal assignment panel",
        "Show your current boss duties in a movable info frame.", -360)
    view.AssignmentInfo = Button(automation, "", 174, 27)
    view.AssignmentInfo:SetPoint(
        "TOPRIGHT", automation, -14, -364)
    view.AssignmentInfo:SetScript("OnClick", function()
        Raid.db.assignmentInfo.hide =
            not Raid.db.assignmentInfo.hide
        Raid:RefreshPersonalAssignments()
        Raid:RefreshSettingsView()
    end)
    local cooldowns = CreateFrame("Frame", nil, view.Content)
    cooldowns:SetPoint("TOPLEFT", 12, -8)
    cooldowns:SetPoint("TOPRIGHT", -12, -8)
    cooldowns:SetHeight(628)
    SectionHeader(
        cooldowns, "RAID COOLDOWNS",
        "Choose the raid abilities displayed by the standalone cooldown HUD.",
        162)
    view.CooldownEnabled = Button(cooldowns, "", 142, 28)
    view.CooldownEnabled:SetPoint("TOPRIGHT", cooldowns, -10, -2)
    view.CooldownEnabled:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.enabled = not settings.enabled
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    view.CooldownAppearanceTab =
        Button(cooldowns, "APPEARANCE", 148, 28)
    view.CooldownAppearanceTab:SetPoint("TOPLEFT", 14, -42)
    view.CooldownAppearanceTab:SetScript("OnClick", function()
        Raid.cooldownSettingsSection = "APPEARANCE"
        Raid:RefreshSettingsView()
    end)
    view.CooldownSpellsTab = Button(cooldowns, "SPELLS", 148, 28)
    view.CooldownSpellsTab:SetPoint(
        "LEFT", view.CooldownAppearanceTab, "RIGHT", 6, 0)
    view.CooldownSpellsTab:SetScript("OnClick", function()
        Raid.cooldownSettingsSection = "SPELLS"
        Raid:RefreshSettingsView()
    end)
    view.CooldownBody = Panel(cooldowns)
    view.CooldownBody:SetPoint("TOPLEFT", cooldowns, 0, -78)
    view.CooldownBody:SetPoint("TOPRIGHT", cooldowns, 0, -78)
    view.CooldownBody:SetHeight(536)
    view.CooldownBody:SetFrameLevel(
        math.max(0, cooldowns:GetFrameLevel() - 1))
    view.CooldownBody:EnableMouse(false)
    view.CooldownDisplayControls = {}
    local positionLabel, positionDetail = SettingLabel(
        cooldowns, "HUD position",
        "Move the HUD in-game, or return it to its default position.", -92)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        positionLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        positionDetail
    view.CooldownReset = Button(cooldowns, "RESET POSITION", 142, 28)
    view.CooldownReset:SetPoint("TOPRIGHT", cooldowns, -14, -96)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownReset
    view.CooldownReset:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.point, settings.x, settings.y =
            "CENTER", -330, 20
        if Raid.raidCooldownFrame then
            Raid.raidCooldownFrame:ClearAllPoints()
            Raid.raidCooldownFrame:SetPoint(
                "CENTER", UIParent, "CENTER", -330, 20)
        end
    end)
    local layoutLabel, layoutDetail = SettingLabel(
        cooldowns, "Layout",
        "Show each ability as a category column or as a compact row.", -136)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        layoutLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        layoutDetail
    view.CooldownLayout = Button(cooldowns, "", 180, 28)
    AddDropdownArrow(view.CooldownLayout)
    view.CooldownLayout:SetPoint("TOPRIGHT", cooldowns, -14, -140)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownLayout
    view.CooldownLayout:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        ShowSelectionMenu(view.CooldownLayout, {
            { "CATEGORIES", "Category columns" },
            { "ROWS", "Ability rows" },
            { "LIST", "Vertical player list" },
        }, settings.layout or "CATEGORIES", function(value)
            settings.layout = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local sortLabel, sortDetail = SettingLabel(
        cooldowns, "Sort abilities",
        "Order by the configured spell list, class, or ability name.", -180)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        sortLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        sortDetail
    view.CooldownSort = Button(cooldowns, "", 180, 28)
    AddDropdownArrow(view.CooldownSort)
    view.CooldownSort:SetPoint("TOPRIGHT", cooldowns, -14, -184)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownSort
    view.CooldownSort:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        ShowSelectionMenu(view.CooldownSort, {
            { "SPELL", "Configured order" },
            { "CLASS", "Class" },
            { "NAME", "Ability name" },
        }, settings.sortMode or "SPELL", function(value)
            settings.sortMode = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local colorLabel, colorDetail = SettingLabel(
        cooldowns, "Ready-bar colors",
        "Use each player's class color, or choose one shared color.", -224)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        colorLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        colorDetail
    view.CooldownClassColors = Button(cooldowns, "", 180, 28)
    view.CooldownClassColors:SetPoint("TOPRIGHT", cooldowns, -14, -228)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownClassColors
    view.CooldownClassColors:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.classColors = not settings.classColors
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    view.CooldownReadyColor = Button(cooldowns, "READY", 92, 28)
    view.CooldownReadyColor:SetPoint("TOPLEFT", cooldowns, 14, -270)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownReadyColor
    view.CooldownReadyColor:SetScript("OnClick", function()
        Raid:OpenRaidCooldownColorPicker("readyColor")
    end)
    view.CooldownCooldownColor =
        Button(cooldowns, "COOLDOWN", 112, 28)
    view.CooldownCooldownColor:SetPoint(
        "LEFT", view.CooldownReadyColor, "RIGHT", 7, 0)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownCooldownColor
    view.CooldownCooldownColor:SetScript("OnClick", function()
        Raid:OpenRaidCooldownColorPicker("cooldownColor")
    end)
    local scaleLabel, scaleDetail = SettingLabel(
        cooldowns, "HUD scale",
        "Scale the complete cooldown display without changing its layout.",
        -314)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        scaleLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        scaleDetail
    view.CooldownScale = Button(cooldowns, "", 180, 28)
    AddDropdownArrow(view.CooldownScale)
    view.CooldownScale:SetPoint("TOPRIGHT", cooldowns, -14, -318)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownScale
    view.CooldownScale:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        ShowSelectionMenu(view.CooldownScale, {
            { .75, "75%" }, { .85, "85%" }, { 1, "100%" },
            { 1.1, "110%" }, { 1.25, "125%" },
        }, settings.scale or 1, function(value)
            settings.scale = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local alphaLabel, alphaDetail = SettingLabel(
        cooldowns, "Overall HUD opacity",
        "Fade the complete display, including icons, names, and bars.", -358)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        alphaLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        alphaDetail
    view.CooldownAlpha = Button(cooldowns, "", 180, 28)
    AddDropdownArrow(view.CooldownAlpha)
    view.CooldownAlpha:SetPoint("TOPRIGHT", cooldowns, -14, -362)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownAlpha
    view.CooldownAlpha:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        ShowSelectionMenu(view.CooldownAlpha, {
            { .45, "45%" }, { .6, "60%" }, { .75, "75%" },
            { .9, "90%" }, { 1, "100%" },
        }, settings.hudOpacity or .82, function(value)
            settings.hudOpacity = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local lockLabel, lockDetail = SettingLabel(
        cooldowns, "Lock HUD",
        "Prevent accidental movement after positioning the display.", -402)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        lockLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        lockDetail
    view.CooldownLock = Button(cooldowns, "", 180, 28)
    view.CooldownLock:SetPoint("TOPRIGHT", cooldowns, -14, -406)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownLock
    view.CooldownLock:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.locked = not settings.locked
        Raid:RefreshSettingsView()
    end)
    local rowNameLabel, rowNameDetail = SettingLabel(
        cooldowns, "Ability-row names",
        "Show the spell name beside its icon in Ability Rows layout.", -446)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        rowNameLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        rowNameDetail
    view.CooldownRowNames = Button(cooldowns, "", 180, 28)
    view.CooldownRowNames:SetPoint("TOPRIGHT", cooldowns, -14, -450)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownRowNames
    view.CooldownRowNames:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.showAbilityName = not settings.showAbilityName
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    local rowTotalLabel, rowTotalDetail = SettingLabel(
        cooldowns, "Ability-row totals",
        "Show the number of ready players and total available.", -490)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        rowTotalLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        rowTotalDetail
    view.CooldownRowTotals = Button(cooldowns, "", 180, 28)
    view.CooldownRowTotals:SetPoint("TOPRIGHT", cooldowns, -14, -494)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownRowTotals
    view.CooldownRowTotals:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.showAbilityTotal = not settings.showAbilityTotal
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    local visibilityLabel, visibilityDetail = SettingLabel(
        cooldowns, "HUD visibility",
        "Choose whether cooldowns appear solo, in groups, or only in raids.",
        -534)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        visibilityLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        visibilityDetail
    view.CooldownVisibility = Button(cooldowns, "", 180, 28)
    AddDropdownArrow(view.CooldownVisibility)
    view.CooldownVisibility:SetPoint(
        "TOPRIGHT", cooldowns, -14, -538)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownVisibility
    view.CooldownVisibility:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        ShowSelectionMenu(view.CooldownVisibility, {
            { "ALWAYS", "Always" },
            { "GROUP", "Party & raid" },
            { "RAID", "Raid only" },
        }, settings.visibility or "GROUP", function(value)
            settings.visibility = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local cooldownDefinitions = Raid.GetRaidCooldownDefinitions
        and Raid:GetRaidCooldownDefinitions() or {}
    view.CooldownClassButtons = {}
    local filters = {
        { "ALL", "ALL" },
        { "ENABLED", "ENABLED" },
    }
    local seenClasses = {}
    for _, definition in ipairs(cooldownDefinitions) do
        if not seenClasses[definition[3]] then
            seenClasses[definition[3]] = true
            filters[#filters + 1] = {
                definition[3], definition[3],
            }
        end
    end
    table.sort(filters, function(left, right)
        if left[1] == "ALL" then return true end
        if right[1] == "ALL" then return false end
        if left[1] == "ENABLED" then return true end
        if right[1] == "ENABLED" then return false end
        return left[2] < right[2]
    end)
    for index, filter in ipairs(filters) do
        local filterKey = filter[1]
        local button = Button(cooldowns, filter[2], 92, 27)
        local column = (index - 1) % 6
        local row = math.floor((index - 1) / 6)
        button:SetPoint(
            "TOPLEFT", 14 + (column * 98), -88 - (row * 32))
        button.filterKey = filterKey
        button:SetScript("OnClick", function()
            Raid.cooldownClassFilter = filterKey
            Raid:RefreshSettingsView()
        end)
        view.CooldownClassButtons[index] = button
    end
    view.CooldownEnableAll = Button(cooldowns, "ENABLE SHOWN", 132, 27)
    view.CooldownEnableAll:SetPoint("BOTTOMLEFT", cooldowns, 14, 8)
    view.CooldownEnableAll:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        local filter = Raid.cooldownClassFilter or "ALL"
        for _, definition in ipairs(cooldownDefinitions) do
            if filter == "ALL" or filter == "ENABLED"
                or definition[3] == filter
            then
                settings.spells[definition[1]] = true
            end
        end
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    view.CooldownDisableAll = Button(cooldowns, "DISABLE SHOWN", 132, 27)
    view.CooldownDisableAll:SetPoint(
        "LEFT", view.CooldownEnableAll, "RIGHT", 6, 0)
    view.CooldownDisableAll:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        local filter = Raid.cooldownClassFilter or "ALL"
        for _, definition in ipairs(cooldownDefinitions) do
            if filter == "ALL" or filter == "ENABLED"
                or definition[3] == filter
            then
                settings.spells[definition[1]] = false
            end
        end
        Raid:RefreshRaidCooldowns()
        Raid:RefreshSettingsView()
    end)
    view.CooldownSpellButtons = {}
    for index, definition in ipairs(cooldownDefinitions) do
        local definitionForButton = definition
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        local button = Button(cooldowns, "", 294, 30)
        button:SetPoint(
            "TOPLEFT", 14 + (column * 304), -158 - (row * 36))
        AddButtonIcon(
            button,
            GetSpellTexture and GetSpellTexture(definition[4])
                or definition[4],
            18)
        button.Text:ClearAllPoints()
        button.Text:SetPoint("LEFT", 34, 0)
        button.Text:SetPoint("RIGHT", -42, 0)
        button.Text:SetJustifyH("LEFT")
        button.State = Font(button, 9, "muted", "")
        button.State:SetPoint("RIGHT", -9, 0)
        button.definition = definitionForButton
        button:SetScript("OnClick", function()
            local settings = Raid:GetRaidCooldownSettings()
            local key = definitionForButton[1]
            settings.spells[key] = not settings.spells[key]
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
        view.CooldownSpellButtons[index] = button
    end

    local admin = CreateFrame("Frame", nil, view.Content)
    admin:SetPoint("TOPLEFT", 12, -8)
    admin:SetPoint("TOPRIGHT", -12, -8)
    admin:SetHeight(480)
    SectionHeader(
        admin,
        "RAID ADMINISTRATION",
        "Automate entry, permissions, and loot without opening Blizzard menus.")

    local inviteCard = Panel(admin)
    inviteCard:SetPoint("TOPLEFT", 0, -40)
    inviteCard:SetPoint("TOPRIGHT", 0, -40)
    inviteCard:SetHeight(96)
    local promoteCard = Panel(admin)
    promoteCard:SetPoint("TOPLEFT", inviteCard, "BOTTOMLEFT", 0, -9)
    promoteCard:SetPoint("TOPRIGHT", inviteCard, "BOTTOMRIGHT", 0, -9)
    promoteCard:SetHeight(150)
    local lootCard = Panel(admin)
    lootCard:SetPoint("TOPLEFT", promoteCard, "BOTTOMLEFT", 0, -9)
    lootCard:SetPoint("TOPRIGHT", promoteCard, "BOTTOMRIGHT", 0, -9)
    lootCard:SetHeight(140)

    SectionHeader(
        inviteCard, "AUTO INVITE",
        "Invite exact whisper keywords, separated by commas.", 162)
    view.AutoInvite = Button(inviteCard, "", 142, 28)
    view.AutoInvite:SetPoint("TOPRIGHT", inviteCard, -10, -2)
    view.AutoInvite:SetScript("OnClick", function()
        local settings = Raid.db.raidAdmin
        settings.autoInvite = not settings.autoInvite
        Raid:RefreshSettingsView()
    end)
    view.InviteKeywords = EditField(
        inviteCard, 330, "inv, invite")
    view.InviteKeywords:SetPoint("BOTTOMLEFT", inviteCard, 14, 10)
    view.InviteKeywords:SetScript("OnTextChanged", function(self, user)
        self.Placeholder:SetShown(self:GetText() == "")
        if user then Raid.db.raidAdmin.inviteKeywords = self:GetText() end
    end)

    SectionHeader(
        promoteCard, "ASSISTANT PROMOTION",
        "Promote named players or guild ranks while you are raid leader.", 162)
    view.AutoPromote = Button(promoteCard, "", 142, 28)
    view.AutoPromote:SetPoint("TOPRIGHT", promoteCard, -10, -2)
    view.AutoPromote:SetScript("OnClick", function()
        local settings = Raid.db.raidAdmin
        settings.autoPromote = not settings.autoPromote
        Raid:ApplyAutoPromote()
        Raid:RefreshSettingsView()
    end)
    view.PromoteNames = EditField(
        promoteCard, 430, "Names or shift-click player links")
    view.PromoteNames:SetPoint("TOPLEFT", promoteCard, 14, -56)
    view.PromoteNames:SetScript("OnTextChanged", function(self, user)
        self.Placeholder:SetShown(self:GetText() == "")
        if user then Raid.db.raidAdmin.promoteNames = self:GetText() end
    end)
    view.PromoteNames:HookScript("OnEditFocusGained", function(self)
        Raid.playerNameInsertBox = self
        Raid.playerNameInsertKey = "promoteNames"
    end)
    view.PromoteNames:HookScript(
        "OnEditFocusLost", function() Raid:ApplyAutoPromote() end)
    view.PromoteNames:HookScript("OnHide", function(self)
        if Raid.playerNameInsertBox == self then
            Raid.playerNameInsertBox = nil
            Raid.playerNameInsertKey = nil
        end
    end)
    view.PromoteGuildRank = Button(promoteCard, "", 260, 28)
    AddDropdownArrow(view.PromoteGuildRank)
    view.PromoteGuildRank:SetPoint("TOPLEFT", promoteCard, 14, -94)
    view.PromoteGuildRank:SetScript("OnClick", function()
        if C_GuildInfo and C_GuildInfo.GuildRoster then
            C_GuildInfo.GuildRoster()
        elseif GuildRoster then
            GuildRoster()
        end
        local entries = CurrentGuildRankEntries()
        if #entries == 0 then
            Raid:Print(
                "Guild ranks are not available yet. Open the guild roster and try again.")
            return
        end
        Raid.db.raidAdmin.promoteGuildRanks =
            Raid.db.raidAdmin.promoteGuildRanks or {}
        ShowMultiSelectionMenu(
            view.PromoteGuildRank, entries,
            Raid.db.raidAdmin.promoteGuildRanks,
            function()
                Raid:ApplyAutoPromote()
                Raid:RefreshSettingsView()
            end)
    end)

    SectionHeader(
        lootCard, "LOOT RULES",
        "Apply saved method and quality while leading a raid.", 162)
    view.ManageLoot = Button(lootCard, "", 142, 28)
    view.ManageLoot:SetPoint("TOPRIGHT", lootCard, -10, -2)
    view.ManageLoot:SetScript("OnClick", function()
        local settings = Raid.db.raidAdmin
        settings.manageLoot = not settings.manageLoot
        if settings.manageLoot then Raid:ApplyLootRules(false, true) end
        Raid:RefreshSettingsView()
    end)
    view.LootMethod = Button(lootCard, "", 210, 28)
    AddDropdownArrow(view.LootMethod)
    view.LootMethod:SetPoint("TOPLEFT", lootCard, 14, -56)
    view.LootMethod:SetScript("OnClick", function()
        ShowSelectionMenu(view.LootMethod, {
            { "group", "Group Loot" },
            { "master", "Master Loot" },
            { "roundrobin", "Round Robin" },
            { "freeforall", "Free For All" },
        }, Raid.db.raidAdmin.lootMethod or "group", function(value)
            Raid.db.raidAdmin.manageLoot = true
            Raid.db.raidAdmin.lootMethod = value
            Raid:RefreshSettingsView()
            Raid:ApplyLootRules(false, true)
        end)
    end)
    view.LootThreshold = Button(lootCard, "", 210, 28)
    AddDropdownArrow(view.LootThreshold)
    view.LootThreshold:SetPoint(
        "LEFT", view.LootMethod, "RIGHT", 8, 0)
    view.LootThreshold:SetScript("OnClick", function()
        ShowSelectionMenu(view.LootThreshold, {
            { 0, "|cff9d9d9dPoor|r" },
            { 1, "|cffffffffCommon|r" },
            { 2, "|cff1eff00Uncommon|r" },
            { 3, "|cff0070ddRare|r" },
            { 4, "|cffa335eeEpic|r" },
        }, Raid.db.raidAdmin.lootThreshold or 2, function(value)
            Raid.db.raidAdmin.manageLoot = true
            Raid.db.raidAdmin.lootThreshold = value
            Raid:RefreshSettingsView()
            Raid:ApplyLootRules(false)
        end)
    end)
    view.MasterLooter = EditField(
        lootCard, 330, "Fallback names, first available wins")
    view.MasterLooter:SetPoint("TOPLEFT", lootCard, 14, -94)
    view.MasterLooter:SetScript("OnTextChanged", function(self, user)
        self.Placeholder:SetShown(self:GetText() == "")
        if user then Raid.db.raidAdmin.masterLooter = self:GetText() end
    end)
    view.MasterLooter:HookScript("OnEditFocusGained", function(self)
        Raid.playerNameInsertBox = self
        Raid.playerNameInsertKey = "masterLooter"
    end)
    view.MasterLooter:HookScript(
        "OnEditFocusLost", function(self)
            Raid:ApplyLootRules(false, true)
        end)
    view.MasterLooter:HookScript("OnHide", function(self)
        if Raid.playerNameInsertBox == self then
            Raid.playerNameInsertBox = nil
            Raid.playerNameInsertKey = nil
        end
    end)
    view.AdminPanel = admin
    view.GeneralPanel = general
    view.AutomationPanel = automation
    view.CooldownPanel = cooldowns

    view.Back = Button(view, "BACK", 86, 28)
    view.Back:SetPoint("BOTTOMLEFT", 20, 14)
    view.Back:SetScript(
        "OnClick", function() Raid:ExitSettingsView() end)
    view.Back:Hide()
    view.ResetWindow:Hide()
    view:Hide()
    self.settingsView = view
    return view
end

function Raid:RefreshSettingsView()
    local view = self.settingsView
    if not view or not view:IsShown() then return end
    local adminTab = self.settingsTab == "ADMIN"
    local cooldownTab = self.settingsTab == "COOLDOWNS"
    view.Subtitle:SetText(
        adminTab
            and "Invites, assistant promotion, and loot rules"
            or cooldownTab
                and "Raid cooldown visibility and tracked abilities"
            or "Interface, communication, and toolbar behavior")
    view.GeneralPanel:SetShown(not adminTab and not cooldownTab)
    view.AutomationPanel:SetShown(not adminTab and not cooldownTab)
    view.AdminPanel:SetShown(adminTab)
    view.CooldownPanel:SetShown(cooldownTab)
    view.ResetWindow:Hide()
    view.Back:Hide()
    view.Content:SetWidth(math.max(1, view:GetWidth() - 28))
    view.Content:SetHeight(
        adminTab and 496 or cooldownTab and 644 or 658)
    if view.Scroll.UpdateScrollbar then
        view.Scroll:UpdateScrollbar()
    end
    StyleButton(
        view.GeneralTab,
        not adminTab and not cooldownTab and "primary" or nil)
    StyleButton(view.AdminTab, adminTab and "primary" or nil)
    StyleButton(
        view.CooldownTab, cooldownTab and "primary" or nil)
    local cooldownSettings = self:GetRaidCooldownSettings()
    local cooldownSection =
        self.cooldownSettingsSection or "APPEARANCE"
    local spellSection = cooldownSection == "SPELLS"
    StyleButton(
        view.CooldownAppearanceTab,
        not spellSection and "primary" or nil)
    StyleButton(
        view.CooldownSpellsTab,
        spellSection and "primary" or nil)
    for _, control in ipairs(view.CooldownDisplayControls or {}) do
        control:SetShown(not spellSection)
    end
    local classFilter = self.cooldownClassFilter or "ALL"
    for _, button in ipairs(view.CooldownClassButtons or {}) do
        button:SetShown(spellSection)
        StyleButton(
            button,
            button.filterKey == classFilter and "primary" or nil)
        if button.filterKey ~= "ALL"
            and button.filterKey ~= "ENABLED"
        then
            local classColor = RAID_CLASS_COLORS
                and RAID_CLASS_COLORS[button.filterKey]
            if classColor then
                button.Text:SetTextColor(
                    classColor.r, classColor.g, classColor.b, 1)
            end
        end
    end
    view.CooldownEnableAll:SetShown(spellSection)
    view.CooldownDisableAll:SetShown(spellSection)
    view.CooldownEnabled.Text:SetText(
        cooldownSettings.enabled and "COOLDOWNS: ON"
            or "COOLDOWNS: OFF")
    StyleButton(
        view.CooldownEnabled,
        cooldownSettings.enabled and "positive" or "danger")
    local layoutLabels = {
        CATEGORIES = "CATEGORY COLUMNS",
        ROWS = "ABILITY ROWS",
        LIST = "VERTICAL PLAYER LIST",
    }
    view.CooldownLayout.Text:SetText(
        layoutLabels[cooldownSettings.layout] or "CATEGORY COLUMNS")
    local sortLabels = {
        SPELL = "CONFIGURED ORDER",
        CLASS = "CLASS",
        NAME = "ABILITY NAME",
    }
    view.CooldownSort.Text:SetText(
        sortLabels[cooldownSettings.sortMode] or "CONFIGURED ORDER")
    view.CooldownClassColors.Text:SetText(
        cooldownSettings.classColors
            and "CLASS COLORS: ON" or "CLASS COLORS: OFF")
    StyleButton(
        view.CooldownClassColors,
        cooldownSettings.classColors and "positive" or nil)
    local readyColor = cooldownSettings.readyColor
    local cooldownColor = cooldownSettings.cooldownColor
    view.CooldownReadyColor:SetBackdropBorderColor(
        readyColor[1], readyColor[2], readyColor[3], 1)
    view.CooldownReadyColor.Text:SetTextColor(
        readyColor[1], readyColor[2], readyColor[3], 1)
    view.CooldownCooldownColor:SetBackdropBorderColor(
        cooldownColor[1], cooldownColor[2], cooldownColor[3], 1)
    view.CooldownCooldownColor.Text:SetTextColor(
        cooldownColor[1], cooldownColor[2], cooldownColor[3], 1)
    view.CooldownScale.Text:SetText(
        ("%d%%"):format(
            math.floor((cooldownSettings.scale or 1) * 100 + .5)))
    view.CooldownAlpha.Text:SetText(
        ("%d%%"):format(
            math.floor(
                (cooldownSettings.hudOpacity or .82) * 100 + .5)))
    view.CooldownLock.Text:SetText(
        cooldownSettings.locked and "HUD: LOCKED" or "HUD: UNLOCKED")
    StyleButton(
        view.CooldownLock,
        cooldownSettings.locked and "positive" or nil)
    view.CooldownRowNames.Text:SetText(
        cooldownSettings.showAbilityName
            and "SPELL NAMES: ON" or "SPELL NAMES: OFF")
    StyleButton(
        view.CooldownRowNames,
        cooldownSettings.showAbilityName and "positive" or nil)
    view.CooldownRowTotals.Text:SetText(
        cooldownSettings.showAbilityTotal
            and "TOTALS: ON" or "TOTALS: OFF")
    StyleButton(
        view.CooldownRowTotals,
        cooldownSettings.showAbilityTotal and "positive" or nil)
    local cooldownVisibilityLabels = {
        ALWAYS = "ALWAYS",
        GROUP = "PARTY & RAID",
        RAID = "RAID ONLY",
    }
    view.CooldownVisibility.Text:SetText(
        cooldownVisibilityLabels[cooldownSettings.visibility]
            or "PARTY & RAID")
    local visibleSpellIndex = 0
    for _, button in ipairs(view.CooldownSpellButtons or {}) do
        local enabled =
            cooldownSettings.spells[button.definition[1]] ~= false
        local matchesFilter = classFilter == "ALL"
            or classFilter == "ENABLED" and enabled
            or button.definition[3] == classFilter
        button:SetShown(spellSection and matchesFilter)
        if spellSection and matchesFilter then
            local column = visibleSpellIndex % 2
            local row = math.floor(visibleSpellIndex / 2)
            button:ClearAllPoints()
            button:SetPoint(
                "TOPLEFT", view.CooldownPanel,
                "TOPLEFT", 14 + (column * 304),
                -158 - (row * 36))
            visibleSpellIndex = visibleSpellIndex + 1
        end
        button.Text:SetText(
            button.definition[2] .. "  |cff71818c"
                .. button.definition[3] .. " · "
                .. tostring(button.definition[5]) .. "s|r")
        button.State:SetText(enabled and "ON" or "OFF")
        button.State:SetTextColor(
            enabled and .18 or .75,
            enabled and .9 or .25,
            enabled and .55 or .25, 1)
        StyleButton(button, enabled and "positive" or nil)
    end
    view.Minimap.Text:SetText(
        self.db.minimap.hide and "HIDDEN" or "SHOWN")
    StyleButton(
        view.Minimap,
        self.db.minimap.hide and "danger" or "positive")
    local labels = {
        AUTO = "AUTOMATIC", RAID_WARNING = "RAID WARNING",
        RAID = "RAID", PARTY = "PARTY", SAY = "SAY",
    }
    view.Channel.Text:SetText(
        labels[self.db.announcementChannel or "AUTO"])
    view.DelayValue.Text:SetText(
        ("%.2f SEC"):format(self.db.messageDelay or .45))
    view.ReadyHoldValue.Text:SetText(
        ("%d SEC"):format(self.db.readyCheck.holdDuration or 15))
    local autoMarkerEnabled = self:IsAutoMarkerEnabled()
    view.AutoMarker.Text:SetText(
        autoMarkerEnabled and "AUTO MARK: ON" or "AUTO MARK: OFF")
    StyleButton(
        view.AutoMarker,
        autoMarkerEnabled and "positive" or "danger")
    local quickBarShown = not self.db.quickBar.hide
    view.QuickBar.Text:SetText(
        quickBarShown and "TOOLBAR: ENABLED" or "TOOLBAR: DISABLED")
    StyleButton(
        view.QuickBar,
        quickBarShown and "positive" or "danger")
    local iconOnly = self.db.quickBar.iconOnly
    view.QuickBarIcons.Text:SetText(
        iconOnly and "ICONS ONLY: ON" or "ICONS ONLY: OFF")
    StyleButton(
        view.QuickBarIcons, iconOnly and "positive" or "danger")
    local visibilityLabels = {
        ALWAYS = "ALWAYS", GROUP = "PARTY OR RAID", RAID = "RAID ONLY",
    }
    view.QuickBarVisibility.Text:SetText(
        visibilityLabels[self.db.quickBar.visibility or "GROUP"]
            or "PARTY OR RAID")
    local hideInCombat = self.db.quickBar.hideInCombat ~= false
    view.QuickBarCombat.Text:SetText(
        hideInCombat and "HIDE IN COMBAT: ON"
            or "HIDE IN COMBAT: OFF")
    StyleButton(
        view.QuickBarCombat,
        hideInCombat and "positive" or "danger")
    local showReadyWindow = self.db.readyCheck.showWindow ~= false
    view.ReadyCheckWindow.Text:SetText(
        showReadyWindow and "RESULTS WINDOW: ON"
            or "RESULTS WINDOW: OFF")
    StyleButton(
        view.ReadyCheckWindow,
        showReadyWindow and "positive" or "danger")
    local showAssignmentInfo = not self.db.assignmentInfo.hide
    view.AssignmentInfo.Text:SetText(
        showAssignmentInfo and "ASSIGNMENTS: ON"
            or "ASSIGNMENTS: OFF")
    StyleButton(
        view.AssignmentInfo,
        showAssignmentInfo and "positive" or "danger")
    local settings = self.db.raidAdmin
    view.AutoInvite.Text:SetText(
        settings.autoInvite and "AUTO INVITE: ON" or "AUTO INVITE: OFF")
    StyleButton(
        view.AutoInvite, settings.autoInvite and "positive" or "danger")
    view.AutoPromote.Text:SetText(
        settings.autoPromote and "PROMOTE: ON" or "PROMOTE: OFF")
    StyleButton(
        view.AutoPromote, settings.autoPromote and "positive" or "danger")
    local selectedRankNames = {}
    for _, entry in ipairs(CurrentGuildRankEntries()) do
        if settings.promoteGuildRanks
            and settings.promoteGuildRanks[entry[1]]
        then
            selectedRankNames[#selectedRankNames + 1] = entry[2]
        end
    end
    view.PromoteGuildRank.Text:SetText(
        #selectedRankNames > 0
            and table.concat(selectedRankNames, ", "):upper()
            or "SELECT GUILD RANKS")
    view.ManageLoot.Text:SetText(
        settings.manageLoot and "LOOT RULES: ON" or "LOOT RULES: OFF")
    StyleButton(
        view.ManageLoot, settings.manageLoot and "positive" or "danger")
    local methods = {
        group = "GROUP LOOT", master = "MASTER LOOT",
        roundrobin = "ROUND ROBIN", freeforall = "FREE FOR ALL",
    }
    local thresholds = {
        [0] = "|cff9d9d9dPOOR|r",
        [1] = "|cffffffffCOMMON|r",
        [2] = "|cff1eff00UNCOMMON|r",
        [3] = "|cff0070ddRARE|r",
        [4] = "|cffa335eeEPIC|r",
    }
    view.LootMethod.Text:SetText(
        methods[settings.lootMethod] or "GROUP LOOT")
    view.LootThreshold.Text:SetText(
        thresholds[settings.lootThreshold or 2]
            or "|cff1eff00UNCOMMON|r")
    if not view.InviteKeywords:HasFocus() then
        view.InviteKeywords:SetText(settings.inviteKeywords or "")
    end
    if not view.PromoteNames:HasFocus() then
        view.PromoteNames:SetText(settings.promoteNames or "")
    end
    if not view.MasterLooter:HasFocus() then
        view.MasterLooter:SetText(settings.masterLooter or "")
    end
    view.MasterLooter:SetShown(settings.lootMethod == "master")
end

function Raid:RedrawSettingsView()
    self:RefreshSettingsView()
    self:UpdateWindowLayout()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if Raid.settingsView and Raid.settingsView:IsShown() then
                Raid:RefreshSettingsView()
                Raid:UpdateWindowLayout()
            end
        end)
    end
end

function Raid:ShowSettingsView()
    self:CreateUI()
    if C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    elseif GuildRoster then
        GuildRoster()
    end
    local view = self:CreateSettingsView()
    if self.newRaidWizard then self.newRaidWizard:Hide() end
    self.workspaceMode = "SETTINGS"
    self:SetRaidWorkspaceVisible(false)
    if self.workspaceRail then self.workspaceRail:Show() end
    if self.bossSettingsPanel then self.bossSettingsPanel:Hide() end
    if self.manualPlayerPanel then self.manualPlayerPanel:Hide() end
    self.frame.Title:SetText("SETTINGS")
    self.frame.Subtitle:SetText(
        "INTERFACE, COMMUNICATION, AND RAID ADMINISTRATION")
    self.settingsTab = self.settingsTab or "GENERAL"
    view:Show()
    self:RefreshWorkspaceNavigation()
    self:RefreshFooterLayout()
    self:RedrawSettingsView()
    self.frame:Show()
end

function Raid:ExitSettingsView()
    if self.settingsView then self.settingsView:Hide() end
    if self.db.raidLocked then
        self:EnterBossUI()
    elseif self:CanStartRaid() then
        self:ShowNewRaidWizard()
    else
        self.frame:Hide()
    end
end

function Raid:CreateNewRaidWizard()
    if self.newRaidWizard then return self.newRaidWizard end
    local wizard = Panel(self.assignmentPanel)
    wizard:SetPoint("TOPLEFT", 1, -1)
    wizard:SetPoint("BOTTOMRIGHT", -1, 1)
    wizard:SetFrameLevel(self.assignmentPanel:GetFrameLevel() + 20)
    wizard:SetBackdropColor(.018, .030, .043, 1)
    wizard:EnableMouse(true)
    wizard.Title = Font(wizard, 15, "accent", "START A RAID")
    wizard.Title:SetPoint("TOPLEFT", 20, -22)
    wizard.Subtitle = Font(wizard, 10, "muted", "")
    wizard.Subtitle:SetPoint("TOPLEFT", 21, -50)
    wizard.Subtitle:SetPoint("RIGHT", -20, 0)
    wizard.Subtitle:SetJustifyH("LEFT")
    wizard.Back = Button(wizard, "BACK", 86, 26)
    wizard.Back:SetPoint("BOTTOMLEFT", 20, 14)
    wizard.Back:SetScript("OnClick", function()
        wizard.step = "EXPANSION"
        Raid:RefreshNewRaidWizard()
    end)
    wizard.Buttons = {}
    wizard:Hide()
    self.newRaidWizard = wizard
    return wizard
end

function Raid:WizardButton(index)
    local wizard = self.newRaidWizard
    local button = wizard.Buttons[index]
    if not button then
        button = Button(
            wizard, "", math.max(1, wizard:GetWidth() - 40), 42)
        button.Text:ClearAllPoints()
        button.Text:SetPoint("LEFT", 12, 0)
        button.Text:SetPoint("RIGHT", -10, 0)
        button.Text:SetJustifyH("LEFT")
        button.Delete = Button(button, "X", 26, 26)
        button.Delete:SetPoint("RIGHT", -4, 0)
        button.Delete:SetFrameLevel(button:GetFrameLevel() + 3)
        button.Delete.Text:SetTextColor(1, .35, .35)
        AddButtonTooltip(
            button.Delete, "Delete Saved Raid",
            "Permanently remove this saved raid plan.")
        button.Delete:Hide()
        wizard.Buttons[index] = button
    end
    return button
end

function Raid:RefreshNewRaidWizard()
    local wizard = self:CreateNewRaidWizard()
    if not wizard:IsShown() then return end
    for _, button in ipairs(wizard.Buttons) do
        button:Hide()
        button.Delete:Hide()
        button.Text:ClearAllPoints()
        button.Text:SetPoint("LEFT", 12, 0)
        button.Text:SetPoint("RIGHT", -10, 0)
    end
    local entries = {}
    if wizard.step == "RAID" then
        wizard.Subtitle:SetText("Select a raid  -  Back returns to expansions")
        wizard.Back:Show()
        for _, raid in ipairs(self.raids) do
            if raid.expansion == wizard.expansion then
                local raidKey = raid.key
                local raidExpansion = raid.expansion
                entries[#entries + 1] = {
                    label = raid.name .. "  (" .. raid.size .. " player)",
                    action = function()
                        self.db.newRaidExpansion = raidExpansion
                        if self:BeginRaid(raidKey) then
                            self:EnterBossUI("ASSIGNMENTS")
                        end
                    end,
                }
            end
        end
    else
        wizard.step = "EXPANSION"
        wizard.Subtitle:SetText(
            "Choose an expansion, or open a raid saved in advance")
        wizard.Back:Hide()
        for _, expansion in ipairs(self.expansions) do
            local expansionKey = expansion.key
            entries[#entries + 1] = {
                label = "EXPANSION  -  " .. expansion.name,
                action = function()
                    wizard.expansion = expansionKey
                    self.db.newRaidExpansion = expansionKey
                    wizard.step = "RAID"
                    self:RefreshNewRaidWizard()
                end,
            }
        end
        local saved = {}
        for id, data in pairs(self.db.savedRaids or {}) do
            saved[#saved + 1] = { id = id, data = data }
        end
        table.sort(saved, function(left, right)
            return (left.data.savedAt or 0) > (right.data.savedAt or 0)
        end)
        for savedIndex, entry in ipairs(saved) do
            if savedIndex > 9 then break end
            local savedID, data = entry.id, entry.data
            local raid = self.raidByKey[data.raidKey]
            entries[#entries + 1] = {
                label = "SAVED  -  " .. data.name
                    .. (raid and "  [" .. raid.name .. "]" or ""),
                action = function()
                    if self:LoadSavedRaid(savedID) then
                        self:EnterBossUI()
                    end
                end,
                deleteID = savedID,
                deleteName = data.name,
            }
        end
    end
    for index, entry in ipairs(entries) do
        local button = self:WizardButton(index)
        button:SetPoint("TOPLEFT", 20, -78 - ((index - 1) * 47))
        button.Text:SetText(entry.label)
        button:SetScript("OnClick", entry.action)
        if entry.deleteID then
            local deleteID = entry.deleteID
            local deleteName = entry.deleteName
            button.Text:ClearAllPoints()
            button.Text:SetPoint("LEFT", 12, 0)
            button.Text:SetPoint("RIGHT", -40, 0)
            button.Delete:SetScript("OnClick", function()
                Raid.pendingDeleteSavedRaidID = deleteID
                if StaticPopup_Show then
                    StaticPopup_Show(
                        "LUNARAIDS_DELETE_SAVED_RAID",
                        deleteName or "Saved Raid", nil, deleteID)
                else
                    Raid:DeleteSavedRaid(deleteID)
                end
            end)
            button.Delete:Show()
        end
        button:Show()
    end
end

function Raid:SetRaidWorkspaceVisible(visible)
    for _, frame in ipairs(self.workspaceFrames or {}) do
        frame:SetShown(visible)
    end
    for _, button in ipairs(self.raidActionButtons or {}) do
        button:SetShown(visible)
    end
    if visible then self:RefreshWorkspaceNavigation() end
end

function Raid:ExitNewRaidWizard()
    if not self.db.raidLocked then
        if self.newRaidWizard then self.newRaidWizard:Show() end
        return
    end
    if self.newRaidWizard then self.newRaidWizard:Hide() end
    self:SetRaidPickerMode(false)
    if self.db.raidLocked then
        self:SetRaidWorkspaceVisible(true)
        self:RefreshAll()
    elseif self.frame then
        self:SetRaidWorkspaceVisible(true)
        self:RefreshWorkspaceNavigation()
        self:RefreshAssignments()
    end
end

function Raid:FinishOpeningNewRaid(saveCurrent, name)
    if not self:CanStartRaid() then
        self:Print(
            "Only the raid leader can create or load the active raid.")
        return
    end
    if saveCurrent then
        self:SaveCurrentRaid(name)
    end
    self:ClearCurrentRaidSession()
    self:ShowNewRaidWizard(false)
end

function Raid:RequestNewRaid()
    if not self:CanStartRaid() then
        self:Print(
            "Only the raid leader can create or load the active raid.")
        return
    end
    if not self.db.raidLocked then
        self:ShowNewRaidWizard(false)
        return
    end
    local saved = self.db.activeSavedRaid
        and self.db.savedRaids[self.db.activeSavedRaid]
    if saved then
        self:SaveCurrentRaid(saved.name)
        self:FinishOpeningNewRaid(false)
        return
    end
    if StaticPopup_Show then
        local raid = self:GetRaid()
        local popup = StaticPopup_Show(
            "LUNARAIDS_NEW_RAID_SAVE", raid.name)
        local editBox = self:GetPopupEditBox(popup)
        if editBox then
            editBox:SetText(raid.name .. " Plan")
            editBox:HighlightText()
            editBox:SetFocus()
        end
    else
        self:FinishOpeningNewRaid(false)
    end
end

function Raid:ShowNewRaidWizard(clearCurrentRaid)
    if not self:CanStartRaid() then
        self:Print(
            "Only the raid leader can create or load the active raid.")
        return
    end
    if clearCurrentRaid then
        self:ClearCurrentRaidSession()
    end
    local wizard = self:CreateNewRaidWizard()
    if self.settingsView then self.settingsView:Hide() end
    wizard.step = "EXPANSION"
    wizard.expansion = self.db.newRaidExpansion
        or self.db.activeExpansion
    if self.bossSettingsPanel then self.bossSettingsPanel:Hide() end
    self.workspaceMode = "ASSIGNMENTS"
    self.activeBossTab = "ASSIGNMENTS"
    self:SetRaidWorkspaceVisible(true)
    self:SetRaidPickerMode(true)
    self:UpdateRoster()
    self:RefreshWorkspaceNavigation()
    for _, button in ipairs(self.assignmentActionButtons or {}) do
        button:Hide()
    end
    if self.generalFooterActionButtons
        and self.generalFooterActionButtons[2]
    then
        self.generalFooterActionButtons[2]:Hide()
    end
    self:RefreshFooterLayout()
    self:UpdateWindowLayout()
    self.frame.Title:SetText("LUNA RAIDS")
    if self.frame.Subtitle then
        self.frame.Subtitle:SetText("CREATE OR LOAD A RAID PLAN")
    end
    wizard:Show()
    self:RefreshNewRaidWizard()
end

