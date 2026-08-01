local _, Raid = ...
local UI = Raid.UI
local L = Raid.L

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
local Slider = UI.Slider
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
    view.Title = Font(view, 15, "accent", L.SETTINGS_TITLE)
    view.Title:SetPoint("TOPLEFT", 20, -22)
    view.Title:Hide()
    view.Subtitle = Font(view, 10, "muted", L.SETTINGS_INTRO)
    view.Subtitle:SetPoint("TOPLEFT", 21, -50)
    view.Subtitle:Hide()
    view.GeneralTab = Button(view, L.SETTINGS_GENERAL, 126, 28)
    view.GeneralTab:SetPoint("TOPLEFT", 8, -8)
    view.AdminTab = Button(view, L.SETTINGS_RAID_ADMIN, 126, 28)
    view.AdminTab:SetPoint("LEFT", view.GeneralTab, "RIGHT", 8, 0)
    view.CooldownTab = Button(view, L.SETTINGS_COOLDOWNS, 126, 28)
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
        Button(view.Footer, L.RESET_ALL_SETTINGS, 168, 28)
    view.ResetAllSettings:SetPoint("RIGHT", -12, 0)
    StyleButton(view.ResetAllSettings, "danger")
    view.ResetAllSettings:SetScript("OnClick", function()
        StaticPopup_Show("LUNARAIDS_RESET_ALL_SETTINGS")
    end)
    AddButtonTooltip(
        view.ResetAllSettings, L.RESET_ALL_SETTINGS_TITLE,
        "Restore addon options and every movable window to defaults.")
    view.Scroll, view.Content = CreateScrollArea(view)
    view.Scroll:SetPoint("TOPLEFT", 8, -44)
    view.Scroll:SetPoint("BOTTOMRIGHT", -8, 49)
    view.Content:SetWidth(math.max(1, view:GetWidth() - 28))

    local general = CreateFrame("Frame", nil, view.Content)
    general:SetPoint("TOPLEFT", 12, -8)
    general:SetPoint("TOPRIGHT", -12, -8)
    general:SetHeight(270)
    SectionHeader(general, L.GENERAL)
    local interfaceCard = Panel(general)
    interfaceCard:SetPoint("TOPLEFT", 0, -40)
    interfaceCard:SetPoint("TOPRIGHT", 0, -40)
    interfaceCard:SetHeight(230)
    SectionHeader(interfaceCard, L.INTERFACE_MESSAGES)
    local function SettingLabel(parent, text, description, y)
        local label = Font(parent, 10, "text", text)
        label:SetPoint("TOPLEFT", 14, y)
        local detail = Font(parent, 9, "muted", description)
        detail:SetPoint("TOPLEFT", 14, y - 16)
        return label, detail
    end
    local function ScaleSlider(name, parent, y, onChanged)
        local slider = Slider(
            parent, 164, .25, 1.25, .05,
            function(value)
                return ("%d%%"):format(value * 100)
            end,
            function(value)
                if not view.updatingScaleSliders then
                    onChanged(value)
                end
            end)
        slider:SetPoint("TOPRIGHT", parent, -14, y)
        slider.Low:SetText("25%")
        slider.High:SetText("125%")
        return slider
    end
    local function SpacingSlider(name, parent, y, onChanged)
        local slider = Slider(
            parent, 164, 0, 12, 1,
            function(value)
                return ("%dpx"):format(value)
            end,
            function(value)
                if not view.updatingScaleSliders then
                    onChanged(value)
                end
            end)
        slider:SetPoint("TOPRIGHT", parent, -14, y)
        return slider
    end
    local function TextSizeSlider(parent, y, onChanged)
        local slider = Slider(
            parent, 164, 6, 14, 1,
            function(value)
                return ("%dpx"):format(value)
            end,
            function(value)
                if not view.updatingScaleSliders then
                    onChanged(value)
                end
            end)
        slider:SetPoint("TOPRIGHT", parent, -14, y)
        return slider
    end

    SettingLabel(interfaceCard, L.MINIMAP_LAUNCHER,
        L.MINIMAP_LAUNCHER_DESC, -36)
    view.Minimap = Button(interfaceCard, "", 142, 28)
    view.Minimap:SetPoint("TOPRIGHT", -14, -39)
    view.Minimap:SetScript("OnClick", function()
        Raid.db.minimap.hide = not Raid.db.minimap.hide
        Raid:RefreshMinimapButton()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(interfaceCard, L.ANNOUNCEMENT_CHANNEL,
        L.ANNOUNCEMENT_CHANNEL_DESC, -82)
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
    SettingLabel(interfaceCard, L.MESSAGE_INTERVAL,
        L.MESSAGE_INTERVAL_DESC, -128)
    view.DelayMinus = Button(interfaceCard, "-", 26, 28)
    view.DelayValue = Button(interfaceCard, "", 68, 28)
    view.DelayPlus = Button(interfaceCard, "+", 26, 28)
    view.DelayPlus:SetPoint("TOPRIGHT", -14, -131)
    view.DelayValue:SetPoint(
        "RIGHT", view.DelayPlus, "LEFT", -4, 0)
    view.DelayMinus:SetPoint(
        "RIGHT", view.DelayValue, "LEFT", -4, 0)
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
    SettingLabel(interfaceCard, L.HUD_SCALE,
        L.HUD_SCALE_DESC,
        -174)
    view.HUDScale = ScaleSlider(
        "LunaRaidsHUDScale", interfaceCard, -181,
        function(value)
            Raid.db.hudScale = value
            Raid:ApplyInterfaceScale()
        end)

    view.ResetWindow = Button(view, L.RESET_WINDOW, 138, 27)
    view.ResetWindow:SetPoint(
        "BOTTOMLEFT", view, "BOTTOMLEFT", 116, 14)
    view.ResetWindow:SetScript(
        "OnClick", function() Raid:ResetWindowPosition() end)
    AddButtonTooltip(view.ResetWindow, L.RESET_WINDOW_TITLE,
        L.RESET_WINDOW_DESC)
    view.AutoMarker = Button(view, "", 174, 27)
    view.AutoMarker:SetPoint("BOTTOMLEFT", 264, 14)
    view.AutoMarker:SetScript("OnClick", function()
        Raid:ToggleAutoMarker()
        Raid:RefreshSettingsView()
    end)
    AddButtonTooltip(
        view.AutoMarker, L.AUTO_MARKER, L.AUTO_MARKER_TOOLTIP)
    view.QuickBar = Button(view, "", 174, 27)
    view.QuickBar:SetScript("OnClick", function()
        Raid.db.quickBar.hide = not Raid.db.quickBar.hide
        Raid:RefreshQuickActionBar()
        Raid:RefreshSettingsView()
    end)
    AddButtonTooltip(
        view.QuickBar, L.QUICK_ACTION_BAR, L.QUICK_ACTION_BAR_TOOLTIP)
    local automation = Panel(view.Content)
    automation:SetPoint("TOPLEFT", general, "BOTTOMLEFT", 0, -10)
    automation:SetPoint("TOPRIGHT", general, "BOTTOMRIGHT", 0, -10)
    automation:SetHeight(416)
    SectionHeader(
        automation, L.AUTOMATION, L.AUTOMATION_DESC)
    view.AutoMarker:SetParent(automation)
    view.AutoMarker:SetFrameLevel(automation:GetFrameLevel() + 1)
    view.QuickBar:SetParent(automation)
    view.QuickBar:SetFrameLevel(automation:GetFrameLevel() + 1)
    SettingLabel(
        automation, L.ENCOUNTER_AUTO_MARKER,
        L.ENCOUNTER_AUTO_MARKER_DESC,
        -38)
    view.AutoMarker:ClearAllPoints()
    view.AutoMarker:SetPoint("TOPRIGHT", automation, -14, -42)
    SettingLabel(
        automation, L.QUICK_ACTION_BAR,
        L.QUICK_ACTION_BAR_DESC,
        -84)
    view.QuickBar:SetPoint("TOPRIGHT", automation, -14, -88)
    SettingLabel(
        automation, L.READY_CHECK_RESULTS_LABEL,
        L.READY_CHECK_RESULTS_DESC, -130)
    view.ReadyHoldMinus = Button(automation, "-", 26, 28)
    view.ReadyHoldValue = Button(automation, "", 68, 28)
    view.ReadyHoldPlus = Button(automation, "+", 26, 28)
    view.ReadyHoldPlus:SetPoint("TOPRIGHT", automation, -14, -134)
    view.ReadyHoldValue:SetPoint(
        "RIGHT", view.ReadyHoldPlus, "LEFT", -4, 0)
    view.ReadyHoldMinus:SetPoint(
        "RIGHT", view.ReadyHoldValue, "LEFT", -4, 0)
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
        automation, L.COMPACT_TOOLBAR,
        L.COMPACT_TOOLBAR_DESC, -176)
    view.QuickBarIcons = Button(automation, "", 174, 27)
    view.QuickBarIcons:SetPoint("TOPRIGHT", automation, -14, -180)
    view.QuickBarIcons:SetScript("OnClick", function()
        Raid.db.quickBar.iconOnly = not Raid.db.quickBar.iconOnly
        Raid:RefreshQuickActionBar()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(
        automation, L.TOOLBAR_VISIBILITY,
        L.TOOLBAR_VISIBILITY_DESC, -222)
    view.QuickBarVisibility = Button(automation, "", 174, 27)
    AddDropdownArrow(view.QuickBarVisibility)
    view.QuickBarVisibility:SetPoint(
        "TOPRIGHT", automation, -14, -226)
    view.QuickBarVisibility:SetScript("OnClick", function()
        ShowSelectionMenu(view.QuickBarVisibility, {
            { "ALWAYS", L.VISIBILITY_ALWAYS },
            { "GROUP", L.VISIBILITY_GROUP },
            { "RAID", L.VISIBILITY_RAID },
        }, Raid.db.quickBar.visibility or "GROUP", function(value)
            Raid.db.quickBar.visibility = value
            Raid:RefreshQuickActionBar()
            Raid:RefreshSettingsView()
        end)
    end)
    SettingLabel(
        automation, L.COMBAT_VISIBILITY,
        L.COMBAT_VISIBILITY_DESC, -268)
    view.QuickBarCombat = Button(automation, "", 174, 27)
    view.QuickBarCombat:SetPoint("TOPRIGHT", automation, -14, -272)
    view.QuickBarCombat:SetScript("OnClick", function()
        Raid.db.quickBar.hideInCombat =
            not Raid.db.quickBar.hideInCombat
        Raid:RefreshQuickActionBar()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(
        automation, L.READY_CHECK_WINDOW,
        L.READY_CHECK_WINDOW_DESC, -314)
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
        automation, L.PERSONAL_ASSIGNMENT_PANEL,
        L.PERSONAL_ASSIGNMENT_PANEL_DESC, -360)
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
    cooldowns:SetHeight(804)
    SectionHeader(
        cooldowns, L.RAID_COOLDOWNS,
        L.RAID_COOLDOWNS_DESC,
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
        Button(cooldowns, L.APPEARANCE, 148, 28)
    view.CooldownAppearanceTab:SetPoint("TOPLEFT", 14, -42)
    view.CooldownAppearanceTab:SetScript("OnClick", function()
        Raid.cooldownSettingsSection = "APPEARANCE"
        Raid:RefreshSettingsView()
    end)
    view.CooldownSpellsTab = Button(cooldowns, L.SPELLS, 148, 28)
    view.CooldownSpellsTab:SetPoint(
        "LEFT", view.CooldownAppearanceTab, "RIGHT", 6, 0)
    view.CooldownSpellsTab:SetScript("OnClick", function()
        Raid.cooldownSettingsSection = "SPELLS"
        Raid:RefreshSettingsView()
    end)
    view.CooldownBody = Panel(cooldowns)
    view.CooldownBody:SetPoint("TOPLEFT", cooldowns, 0, -78)
    view.CooldownBody:SetPoint("TOPRIGHT", cooldowns, 0, -78)
    view.CooldownBody:SetHeight(712)
    view.CooldownBody:SetFrameLevel(
        math.max(0, cooldowns:GetFrameLevel() - 1))
    view.CooldownBody:EnableMouse(false)
    view.CooldownDisplayControls = {}
    local positionLabel, positionDetail = SettingLabel(
        cooldowns, L.HUD_POSITION, L.HUD_POSITION_DESC, -92)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        positionLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        positionDetail
    view.CooldownReset = Button(cooldowns, L.RESET_POSITION, 142, 28)
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
        cooldowns, L.LAYOUT, L.LAYOUT_DESC, -136)
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
            { "CATEGORIES", L.CATEGORY_COLUMNS },
            { "ROWS", L.ABILITY_ROWS },
            { "LIST", L.VERTICAL_PLAYER_LIST },
        }, settings.layout or "CATEGORIES", function(value)
            settings.layout = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local sortLabel, sortDetail = SettingLabel(
        cooldowns, L.SORT_ABILITIES, L.SORT_ABILITIES_DESC, -180)
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
            { "SPELL", L.CONFIGURED_ORDER },
            { "CLASS", L.CLASS },
            { "NAME", L.ABILITY_NAME },
        }, settings.sortMode or "SPELL", function(value)
            settings.sortMode = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local colorLabel, colorDetail = SettingLabel(
        cooldowns, L.READY_BAR_COLORS, L.READY_BAR_COLORS_DESC, -224)
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
    view.CooldownReadyColor = Button(cooldowns, L.READY_UPPER, 92, 28)
    view.CooldownReadyColor:SetPoint("TOPLEFT", cooldowns, 14, -270)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownReadyColor
    view.CooldownReadyColor:SetScript("OnClick", function()
        Raid:OpenRaidCooldownColorPicker("readyColor")
    end)
    view.CooldownCooldownColor =
        Button(cooldowns, L.COOLDOWN_UPPER, 112, 28)
    view.CooldownCooldownColor:SetPoint(
        "LEFT", view.CooldownReadyColor, "RIGHT", 7, 0)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownCooldownColor
    view.CooldownCooldownColor:SetScript("OnClick", function()
        Raid:OpenRaidCooldownColorPicker("cooldownColor")
    end)
    local scaleLabel, scaleDetail = SettingLabel(
        cooldowns, L.HUD_SCALE,
        L.COOLDOWN_HUD_SCALE_DESC,
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
            { .25, "25%" }, { .5, "50%" },
            { .75, "75%" }, { .85, "85%" }, { 1, "100%" },
            { 1.1, "110%" }, { 1.25, "125%" },
        }, settings.scale or 1, function(value)
            settings.scale = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local alphaLabel, alphaDetail = SettingLabel(
        cooldowns, L.PROGRESS_OPACITY, L.PROGRESS_OPACITY_DESC, -358)
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
        cooldowns, L.LOCK_HUD, L.LOCK_HUD_DESC, -402)
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
        cooldowns, L.ABILITY_ROW_NAMES, L.ABILITY_ROW_NAMES_DESC, -446)
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
        cooldowns, L.ABILITY_ROW_TOTALS, L.ABILITY_ROW_TOTALS_DESC, -490)
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
        cooldowns, L.HUD_VISIBILITY,
        L.COOLDOWN_VISIBILITY_DESC,
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
            { "ALWAYS", L.VISIBILITY_ALWAYS },
            { "GROUP", L.PARTY_RAID },
            { "RAID", L.VISIBILITY_RAID },
        }, settings.visibility or "GROUP", function(value)
            settings.visibility = value
            Raid:RefreshRaidCooldowns()
            Raid:RefreshSettingsView()
        end)
    end)
    local rowSpacingLabel, rowSpacingDetail = SettingLabel(
        cooldowns, L.ROW_SPACING, L.ROW_SPACING_DESC, -578)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        rowSpacingLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        rowSpacingDetail
    view.CooldownRowSpacing = SpacingSlider(
        "LunaRaidsCooldownRowSpacing", cooldowns, -585,
        function(value)
            Raid:GetRaidCooldownSettings().rowSpacing = value
            Raid:RefreshRaidCooldowns()
        end)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownRowSpacing
    local columnSpacingLabel, columnSpacingDetail = SettingLabel(
        cooldowns, L.COLUMN_SPACING, L.COLUMN_SPACING_DESC, -622)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        columnSpacingLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        columnSpacingDetail
    view.CooldownColumnSpacing = SpacingSlider(
        "LunaRaidsCooldownColumnSpacing", cooldowns, -629,
        function(value)
            Raid:GetRaidCooldownSettings().columnSpacing = value
            Raid:RefreshRaidCooldowns()
        end)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownColumnSpacing
    local textSizeLabel, textSizeDetail = SettingLabel(
        cooldowns, L.PROGRESS_TEXT_SIZE, L.PROGRESS_TEXT_SIZE_DESC, -666)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        textSizeLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        textSizeDetail
    view.CooldownTextSize = TextSizeSlider(cooldowns, -673,
        function(value)
            Raid:GetRaidCooldownSettings().textSize = value
            Raid:RefreshRaidCooldowns()
        end)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownTextSize
    local whisperLabel, whisperDetail = SettingLabel(
        cooldowns, L.COOLDOWN_WHISPERS, L.COOLDOWN_WHISPERS_DESC, -710)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        whisperLabel
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        whisperDetail
    view.CooldownWhispers = Button(cooldowns, "", 180, 28)
    view.CooldownWhispers:SetPoint("TOPRIGHT", cooldowns, -14, -714)
    view.CooldownDisplayControls[#view.CooldownDisplayControls + 1] =
        view.CooldownWhispers
    view.CooldownWhispers:SetScript("OnClick", function()
        local settings = Raid:GetRaidCooldownSettings()
        settings.whisperEnabled = not settings.whisperEnabled
        Raid:RefreshSettingsView()
    end)
    local mechanicsHUD = Panel(view.Content)
    mechanicsHUD:SetPoint("TOPLEFT", automation, "BOTTOMLEFT", 0, -10)
    mechanicsHUD:SetPoint("TOPRIGHT", automation, "BOTTOMRIGHT", 0, -10)
    mechanicsHUD:SetHeight(344)
    SectionHeader(mechanicsHUD, L.MECHANICS_HUD_SECTION,
        L.MECHANICS_HUD_SECTION_DESC)
    SettingLabel(mechanicsHUD, L.MECHANICS_HUD_ENABLED,
        L.MECHANICS_HUD_ENABLED_DESC, -48)
    view.MechanicsEnabled = Button(mechanicsHUD, "", 174, 27)
    view.MechanicsEnabled:SetPoint("TOPRIGHT", mechanicsHUD, -14, -52)
    view.MechanicsEnabled:SetScript("OnClick", function()
        Raid.db.mechanicsHUD.enabled = not Raid.db.mechanicsHUD.enabled
        Raid:RefreshMechanicsHUD()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(mechanicsHUD, L.MECHANICS_HUD_VISIBILITY,
        L.MECHANICS_HUD_VISIBILITY_DESC, -94)
    view.MechanicsVisibility = Button(mechanicsHUD, "", 174, 27)
    AddDropdownArrow(view.MechanicsVisibility)
    view.MechanicsVisibility:SetPoint("TOPRIGHT", mechanicsHUD, -14, -98)
    view.MechanicsVisibility:SetScript("OnClick", function()
        ShowSelectionMenu(view.MechanicsVisibility, {
            { "ALWAYS", L.VISIBILITY_ALWAYS },
            { "GROUP", L.VISIBILITY_GROUP },
            { "RAID", L.VISIBILITY_RAID },
        }, Raid.db.mechanicsHUD.visibility or "GROUP", function(value)
            Raid.db.mechanicsHUD.visibility = value
            Raid:RefreshMechanicsHUD()
            Raid:RefreshSettingsView()
        end)
    end)
    SettingLabel(mechanicsHUD, L.MECHANICS_HUD_COMBAT_ONLY,
        L.MECHANICS_HUD_COMBAT_ONLY_DESC, -140)
    view.MechanicsCombat = Button(mechanicsHUD, "", 174, 27)
    view.MechanicsCombat:SetPoint("TOPRIGHT", mechanicsHUD, -14, -144)
    view.MechanicsCombat:SetScript("OnClick", function()
        Raid.db.mechanicsHUD.combatOnly = not Raid.db.mechanicsHUD.combatOnly
        Raid:RefreshMechanicsHUD()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(mechanicsHUD, L.MECHANICS_HUD_LINES,
        L.MECHANICS_HUD_LINES_DESC, -186)
    view.MechanicsMinus = Button(mechanicsHUD, "-", 26, 27)
    view.MechanicsValue = Button(mechanicsHUD, "", 68, 27)
    view.MechanicsPlus = Button(mechanicsHUD, "+", 26, 27)
    view.MechanicsPlus:SetPoint("TOPRIGHT", mechanicsHUD, -14, -190)
    view.MechanicsValue:SetPoint("RIGHT", view.MechanicsPlus, "LEFT", -4, 0)
    view.MechanicsMinus:SetPoint("RIGHT", view.MechanicsValue, "LEFT", -4, 0)
    view.MechanicsMinus:SetScript("OnClick", function()
        Raid.db.mechanicsHUD.maxLines = math.max(1,
            (Raid.db.mechanicsHUD.maxLines or 6) - 1)
        Raid:RefreshMechanicsHUD()
        Raid:RefreshSettingsView()
    end)
    view.MechanicsPlus:SetScript("OnClick", function()
        Raid.db.mechanicsHUD.maxLines = math.min(10,
            (Raid.db.mechanicsHUD.maxLines or 6) + 1)
        Raid:RefreshMechanicsHUD()
        Raid:RefreshSettingsView()
    end)
    SettingLabel(mechanicsHUD, L.MECHANICS_HUD_CONTROLS,
        L.MECHANICS_HUD_CONTROLS_DESC, -232)
    view.MechanicsLock = Button(mechanicsHUD, "", 116, 27)
    view.MechanicsTitle = Button(mechanicsHUD, "", 116, 27)
    view.MechanicsReset = Button(mechanicsHUD, L.RESET, 86, 27)
    view.MechanicsReset:SetPoint("TOPRIGHT", mechanicsHUD, -14, -236)
    view.MechanicsTitle:SetPoint("RIGHT", view.MechanicsReset, "LEFT", -5, 0)
    view.MechanicsLock:SetPoint("RIGHT", view.MechanicsTitle, "LEFT", -5, 0)
    view.MechanicsLock:SetScript("OnClick", function()
        Raid.db.mechanicsHUD.locked = not Raid.db.mechanicsHUD.locked
        Raid:RefreshSettingsView()
    end)
    view.MechanicsTitle:SetScript("OnClick", function()
        Raid.db.mechanicsHUD.showTitle = Raid.db.mechanicsHUD.showTitle == false
        Raid:RefreshMechanicsHUD()
        Raid:RefreshSettingsView()
    end)
    view.MechanicsReset:SetScript("OnClick", function()
        local settings = Raid.db.mechanicsHUD
        settings.point, settings.x, settings.y = "CENTER", 330, 120
        if Raid.mechanicsHUDFrame then
            Raid.mechanicsHUDFrame:ClearAllPoints()
            Raid.mechanicsHUDFrame:SetPoint("CENTER", UIParent, "CENTER", 330, 120)
        end
    end)
    SettingLabel(mechanicsHUD, L.MECHANICS_HUD_OPACITY,
        L.MECHANICS_HUD_OPACITY_DESC, -278)
    view.MechanicsOpacity = Button(mechanicsHUD, "", 174, 27)
    AddDropdownArrow(view.MechanicsOpacity)
    view.MechanicsOpacity:SetPoint("TOPRIGHT", mechanicsHUD, -14, -282)
    view.MechanicsOpacity:SetScript("OnClick", function()
        ShowSelectionMenu(view.MechanicsOpacity, {
            { .6, "60%" }, { .75, "75%" },
            { .9, "90%" }, { 1, "100%" },
        }, Raid.db.mechanicsHUD.opacity or .9, function(value)
            Raid.db.mechanicsHUD.opacity = value
            Raid:RefreshMechanicsHUD()
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
    view.CooldownEnableAll = Button(cooldowns, L.ENABLE_SHOWN, 132, 27)
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
    view.CooldownDisableAll = Button(cooldowns, L.DISABLE_SHOWN, 132, 27)
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
    view.MechanicsHUDPanel = mechanicsHUD
    view.CooldownPanel = cooldowns

    view.Back = Button(view, L.BACK, 86, 28)
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
            and L.SETTINGS_SUBTITLE_ADMIN
            or cooldownTab
                and L.SETTINGS_SUBTITLE_COOLDOWNS
            or L.SETTINGS_SUBTITLE_GENERAL)
    view.GeneralPanel:SetShown(not adminTab and not cooldownTab)
    view.AutomationPanel:SetShown(not adminTab and not cooldownTab)
    view.MechanicsHUDPanel:SetShown(not adminTab and not cooldownTab)
    view.AdminPanel:SetShown(adminTab)
    view.CooldownPanel:SetShown(cooldownTab)
    view.ResetWindow:Hide()
    view.Back:Hide()
    view.Content:SetWidth(math.max(1, view:GetWidth() - 28))
    view.Content:SetHeight(
        adminTab and 496 or cooldownTab and 820 or 1060)
    if view.Scroll.UpdateScrollbar then
        view.Scroll:UpdateScrollbar()
    end
    StyleButton(
        view.GeneralTab,
        not adminTab and not cooldownTab and "primary" or nil)
    StyleButton(view.AdminTab, adminTab and "primary" or nil)
    StyleButton(
        view.CooldownTab, cooldownTab and "primary" or nil)
    local mechanicsSettings = self.db.mechanicsHUD
    view.MechanicsEnabled.Text:SetText(
        mechanicsSettings.enabled and L.MECHANICS_ON or L.MECHANICS_OFF)
    StyleButton(view.MechanicsEnabled,
        mechanicsSettings.enabled and "positive" or "danger")
    local mechanicsVisibility = {
        ALWAYS = L.VISIBILITY_ALWAYS,
        GROUP = L.VISIBILITY_GROUP,
        RAID = L.VISIBILITY_RAID,
    }
    view.MechanicsVisibility.Text:SetText(
        mechanicsVisibility[mechanicsSettings.visibility]
            or L.VISIBILITY_GROUP)
    view.MechanicsCombat.Text:SetText(
        mechanicsSettings.combatOnly and L.COMBAT_ONLY_ON
            or L.COMBAT_ONLY_OFF)
    StyleButton(view.MechanicsCombat,
        mechanicsSettings.combatOnly and "positive" or nil)
    view.MechanicsValue.Text:SetText(tostring(mechanicsSettings.maxLines or 6))
    view.MechanicsLock.Text:SetText(
        mechanicsSettings.locked and L.LOCKED or L.UNLOCKED)
    StyleButton(view.MechanicsLock,
        mechanicsSettings.locked and "positive" or nil)
    view.MechanicsTitle.Text:SetText(
        mechanicsSettings.showTitle == false and L.TITLE_OFF or L.TITLE_ON)
    view.MechanicsOpacity.Text:SetText(("%d%%"):format(
        math.floor((mechanicsSettings.opacity or .92) * 100 + .5)))
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
        cooldownSettings.enabled and L.COOLDOWNS_ON
            or L.COOLDOWNS_OFF)
    StyleButton(
        view.CooldownEnabled,
        cooldownSettings.enabled and "positive" or "danger")
    local layoutLabels = {
        CATEGORIES = L.CATEGORY_COLUMNS_UPPER,
        ROWS = L.ABILITY_ROWS_UPPER,
        LIST = L.VERTICAL_PLAYER_LIST_UPPER,
    }
    view.CooldownLayout.Text:SetText(
        layoutLabels[cooldownSettings.layout] or L.CATEGORY_COLUMNS_UPPER)
    local sortLabels = {
        SPELL = L.CONFIGURED_ORDER_UPPER,
        CLASS = L.CLASS_UPPER,
        NAME = L.ABILITY_NAME_UPPER,
    }
    view.CooldownSort.Text:SetText(
        sortLabels[cooldownSettings.sortMode] or L.CONFIGURED_ORDER_UPPER)
    view.CooldownClassColors.Text:SetText(
        cooldownSettings.classColors
            and L.CLASS_COLORS_ON or L.CLASS_COLORS_OFF)
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
    view.updatingScaleSliders = true
    view.HUDScale:SetValue(self.db.hudScale or 1)
    view.CooldownRowSpacing:SetValue(cooldownSettings.rowSpacing or 1)
    view.CooldownColumnSpacing:SetValue(
        cooldownSettings.columnSpacing or 1)
    view.CooldownTextSize:SetValue(cooldownSettings.textSize or 8)
    view.updatingScaleSliders = nil
    view.CooldownAlpha.Text:SetText(
        ("%d%%"):format(
            math.floor(
                (cooldownSettings.hudOpacity or .82) * 100 + .5)))
    view.CooldownLock.Text:SetText(
        cooldownSettings.locked and L.HUD_LOCKED or L.HUD_UNLOCKED)
    StyleButton(
        view.CooldownLock,
        cooldownSettings.locked and "positive" or nil)
    view.CooldownRowNames.Text:SetText(
        cooldownSettings.showAbilityName
            and L.SPELL_NAMES_ON or L.SPELL_NAMES_OFF)
    StyleButton(
        view.CooldownRowNames,
        cooldownSettings.showAbilityName and "positive" or nil)
    view.CooldownRowTotals.Text:SetText(
        cooldownSettings.showAbilityTotal
            and L.TOTALS_ON or L.TOTALS_OFF)
    StyleButton(
        view.CooldownRowTotals,
        cooldownSettings.showAbilityTotal and "positive" or nil)
    view.CooldownWhispers.Text:SetText(
        cooldownSettings.whisperEnabled
            and L.WHISPERS_ON or L.WHISPERS_OFF)
    StyleButton(
        view.CooldownWhispers,
        cooldownSettings.whisperEnabled and "positive" or nil)
    local cooldownVisibilityLabels = {
        ALWAYS = L.VISIBILITY_ALWAYS,
        GROUP = L.PARTY_RAID,
        RAID = L.VISIBILITY_RAID,
    }
    view.CooldownVisibility.Text:SetText(
        cooldownVisibilityLabels[cooldownSettings.visibility]
            or L.PARTY_RAID)
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
        button.State:SetText(enabled and L.ON or L.OFF)
        button.State:SetTextColor(
            enabled and .18 or .75,
            enabled and .9 or .25,
            enabled and .55 or .25, 1)
        StyleButton(button, enabled and "positive" or nil)
    end
    view.Minimap.Text:SetText(
        self.db.minimap.hide and L.HIDDEN or L.SHOWN)
    StyleButton(
        view.Minimap,
        self.db.minimap.hide and "danger" or "positive")
    local labels = {
        AUTO = L.AUTOMATIC, RAID_WARNING = L.RAID_WARNING,
        RAID = L.RAID, PARTY = L.PARTY, SAY = L.SAY,
    }
    view.Channel.Text:SetText(
        labels[self.db.announcementChannel or "AUTO"])
    view.DelayValue.Text:SetText(
        Raid:Localize("SECONDS_SHORT", self.db.messageDelay or .45))
    view.ReadyHoldValue.Text:SetText(
        Raid:Localize(
            "SECONDS_WHOLE", self.db.readyCheck.holdDuration or 15))
    local autoMarkerEnabled = self:IsAutoMarkerEnabled()
    view.AutoMarker.Text:SetText(
        autoMarkerEnabled and L.AUTO_MARK_ON or L.AUTO_MARK_OFF)
    StyleButton(
        view.AutoMarker,
        autoMarkerEnabled and "positive" or "danger")
    local quickBarShown = not self.db.quickBar.hide
    view.QuickBar.Text:SetText(
        quickBarShown and L.TOOLBAR_ENABLED or L.TOOLBAR_DISABLED)
    StyleButton(
        view.QuickBar,
        quickBarShown and "positive" or "danger")
    local iconOnly = self.db.quickBar.iconOnly
    view.QuickBarIcons.Text:SetText(
        iconOnly and L.ICONS_ONLY_ON or L.ICONS_ONLY_OFF)
    StyleButton(
        view.QuickBarIcons, iconOnly and "positive" or "danger")
    local visibilityLabels = {
        ALWAYS = L.VISIBILITY_ALWAYS,
        GROUP = L.VISIBILITY_GROUP,
        RAID = L.VISIBILITY_RAID,
    }
    view.QuickBarVisibility.Text:SetText(
        visibilityLabels[self.db.quickBar.visibility or "GROUP"]
            or L.VISIBILITY_GROUP)
    local hideInCombat = self.db.quickBar.hideInCombat ~= false
    view.QuickBarCombat.Text:SetText(
        hideInCombat and L.HIDE_IN_COMBAT_ON
            or L.HIDE_IN_COMBAT_OFF)
    StyleButton(
        view.QuickBarCombat,
        hideInCombat and "positive" or "danger")
    local showReadyWindow = self.db.readyCheck.showWindow ~= false
    view.ReadyCheckWindow.Text:SetText(
        showReadyWindow and L.RESULTS_WINDOW_ON
            or L.RESULTS_WINDOW_OFF)
    StyleButton(
        view.ReadyCheckWindow,
        showReadyWindow and "positive" or "danger")
    local showAssignmentInfo = not self.db.assignmentInfo.hide
    view.AssignmentInfo.Text:SetText(
        showAssignmentInfo and L.ASSIGNMENTS_ON
            or L.ASSIGNMENTS_OFF)
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
    self.frame.Title:SetText(L.SETTINGS)
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
    wizard.Title = Font(wizard, 15, "accent", L.START_A_RAID)
    wizard.Title:SetPoint("TOPLEFT", 20, -22)
    wizard.Subtitle = Font(wizard, 10, "muted", "")
    wizard.Subtitle:SetPoint("TOPLEFT", 21, -50)
    wizard.Subtitle:SetPoint("RIGHT", -20, 0)
    wizard.Subtitle:SetJustifyH("LEFT")
    wizard.Back = Button(wizard, L.BACK, 86, 26)
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
        button.Logo = button:CreateTexture(nil, "ARTWORK")
        button.Logo:SetPoint("LEFT", 8, 0)
        button.Logo:SetSize(34, 34)
        button.Logo:SetTexCoord(0, 1, 0, 1)
        button.Logo:Hide()
        button.Description = Font(button, 9, "muted", "")
        button.Description:SetJustifyH("CENTER")
        button.Description:Hide()
        button.Meta = Font(button, 8, "accent", "")
        button.Meta:SetJustifyH("CENTER")
        button.Meta:Hide()
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

function Raid:LayoutNewRaidWizardButtons()
    local wizard = self.newRaidWizard
    if not wizard then return end
    local availableWidth = math.max(1, wizard:GetWidth() - 40)
    local columns = availableWidth >= 510 and 3
        or availableWidth >= 340 and 2 or 1
    local gap = 7
    local cardWidth = math.floor(
        (availableWidth - ((columns - 1) * gap)) / columns)
    local cardCount = 0
    for _, button in ipairs(wizard.Buttons or {}) do
        if button:IsShown() and button.WizardCard then
            cardCount = cardCount + 1
        end
    end
    local cardRows = math.ceil(cardCount / columns)
    for _, button in ipairs(wizard.Buttons or {}) do
        if button:IsShown() then
            button:ClearAllPoints()
            if button.WizardCard then
                local ordinal = button.WizardOrder or 0
                local column = ordinal % columns
                local row = math.floor(ordinal / columns)
                button:SetSize(cardWidth, 106)
                button:SetPoint("TOPLEFT",
                    20 + (column * (cardWidth + gap)),
                    -78 - (row * 113))
            else
                local top = wizard.step == "EXPANSION"
                    and (-78 - (cardRows * 113) - 18) or -78
                button:SetSize(availableWidth, 42)
                button:SetPoint("TOPLEFT", 20,
                    top - ((button.WizardRow or 0) * 47))
            end
        end
    end
end

function Raid:RefreshNewRaidWizard()
    local wizard = self:CreateNewRaidWizard()
    for _, button in ipairs(wizard.Buttons) do
        button:Hide()
        button.Delete:Hide()
        button.Logo:Hide()
        button.Description:Hide()
        button.Meta:Hide()
        button.Logo:ClearAllPoints()
        button.Logo:SetPoint("LEFT", 8, 0)
        button.Text:ClearAllPoints()
        button.Text:SetPoint("LEFT", 12, 0)
        button.Text:SetPoint("RIGHT", -10, 0)
        button.Text:SetJustifyH("LEFT")
        button.WizardCard = nil
        button.WizardOrder = nil
        button.WizardRow = nil
    end
    local entries = {}
    if wizard.step == "RAID" then
        wizard.Subtitle:SetText(L.SELECT_RAID_HINT)
        wizard.Back:Show()
        for _, raid in ipairs(self.raids) do
            if raid.expansion == wizard.expansion then
                local raidKey = raid.key
                local raidExpansion = raid.expansion
                entries[#entries + 1] = {
                    label = raid.name .. "  "
                        .. Raid:Localize("PLAYER_COUNT", raid.size),
                    logo = raid.icon,
                    logoWidth = 34,
                    logoHeight = 34,
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
            local raidCount, bossCount = 0, 0
            local sizes = {}
            for _, raid in ipairs(self.raids) do
                if raid.expansion == expansionKey then
                    raidCount = raidCount + 1
                    bossCount = bossCount
                        + math.max(0, #(raid.encounters or {}) - 1)
                    sizes[raid.size or 25] = true
                end
            end
            local playerSizes = {}
            for playerCount in pairs(sizes) do
                playerSizes[#playerSizes + 1] = playerCount
            end
            table.sort(playerSizes)
            for index, playerCount in ipairs(playerSizes) do
                playerSizes[index] = tostring(playerCount)
            end
            entries[#entries + 1] = {
                label = expansion.name,
                logo = expansion.logo,
                logoWidth = 94,
                logoHeight = 46,
                card = true,
                description = raidCount .. " raids  |  "
                    .. bossCount .. " bosses",
                meta = table.concat(playerSizes, "/") .. " player plans",
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
                label = L.SAVED .. "  -  " .. data.name
                    .. (raid and "  [" .. raid.name .. "]" or ""),
                logo = raid and raid.icon,
                logoWidth = 34,
                logoHeight = 34,
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
    local cardIndex, rowIndex = 0, 0
    for index, entry in ipairs(entries) do
        local button = self:WizardButton(index)
        if entry.card then
            button.WizardCard = true
            button.WizardOrder = cardIndex
            cardIndex = cardIndex + 1
        else
            button.WizardRow = rowIndex
            rowIndex = rowIndex + 1
        end
        button.Text:SetText(entry.label)
        button:SetScript("OnClick", entry.action)
        if entry.logo then
            button.Logo:SetTexture(entry.logo)
            button.Logo:SetSize(
                entry.logoWidth or 34, entry.logoHeight or 34)
            button.Logo:Show()
            button.Text:ClearAllPoints()
            if entry.card then
                button.Logo:ClearAllPoints()
                button.Logo:SetPoint("TOP", 0, -5)
                button.Text:SetPoint("TOPLEFT", 8, -55)
                button.Text:SetPoint("TOPRIGHT", -8, -55)
                button.Text:SetJustifyH("CENTER")
                button.Description:SetText(entry.description or "")
                button.Description:ClearAllPoints()
                button.Description:SetPoint("TOPLEFT", 7, -73)
                button.Description:SetPoint("TOPRIGHT", -7, -73)
                button.Description:Show()
                button.Meta:SetText(entry.meta or "")
                button.Meta:ClearAllPoints()
                button.Meta:SetPoint("TOPLEFT", 7, -89)
                button.Meta:SetPoint("TOPRIGHT", -7, -89)
                button.Meta:Show()
            else
                button.Text:SetPoint(
                    "LEFT", 14 + (entry.logoWidth or 34), 0)
                button.Text:SetPoint("RIGHT", -10, 0)
                button.Text:SetJustifyH("LEFT")
            end
        end
        if entry.deleteID then
            local deleteID = entry.deleteID
            local deleteName = entry.deleteName
            button.Text:ClearAllPoints()
            button.Text:SetPoint(
                "LEFT", entry.logo and 14 + (entry.logoWidth or 34)
                    or 12, 0)
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
    self:LayoutNewRaidWizardButtons()
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
            editBox:SetText(Raid:Localize("RAID_PLAN_NAME", raid.name))
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
    wizard:Show()
    self:RefreshNewRaidWizard()
    self.frame.Title:SetText("LUNA RAIDS")
    if self.frame.Subtitle then
        self.frame.Subtitle:SetText(L.CREATE_OR_LOAD_RAID_PLAN)
    end
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
end

