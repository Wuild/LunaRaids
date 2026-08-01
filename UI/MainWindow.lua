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
local ShowSelectionMenu = UI.ShowSelectionMenu
local ShowMultiSelectionMenu = UI.ShowMultiSelectionMenu
local CurrentGuildRankEntries = UI.CurrentGuildRankEntries
local SetClassText, GetClassRowColor = UI.SetClassText, UI.GetClassRowColor
local CreateScrollArea = UI.CreateScrollArea
function Raid:EnterBossUI(initialWorkspace)
    self:CreateUI()
    if self.newRaidWizard then self.newRaidWizard:Hide() end
    self:SetRaidPickerMode(false)
    if self.settingsView then self.settingsView:Hide() end
    self:SetRaidWorkspaceVisible(true)
    if self.manualPlayerPanel then self.manualPlayerPanel:Hide() end
    if self.bossSettingsPanel then self.bossSettingsPanel:Hide() end
    self.workspaceMode = initialWorkspace == "ASSIGNMENTS"
        and "ASSIGNMENTS" or "GROUPS"
    self.activeBossTab = "ASSIGNMENTS"
    self:UpdateRoster()
    self:RefreshAll()
    self.frame:Show()
end

function Raid:PromptSaveRaid()
    local current = self.db.activeSavedRaid
        and self.db.savedRaids[self.db.activeSavedRaid]
    if current then
        self:SaveCurrentRaid(current.name)
        return
    end
    if StaticPopup_Show then
        local popup = StaticPopup_Show("LUNARAIDS_SAVE_RAID")
        local editBox = self:GetPopupEditBox(popup)
        if editBox then
            editBox:SetText(
                self:GetRaid().name .. " Plan")
            editBox:HighlightText()
        end
    else
        self:SaveCurrentRaid(self:Localize(
            "RAID_PLAN_NAME", self:GetRaid().name))
    end
end

function Raid:RefreshRaidIdentityHeader()
    if not self.assignmentRaidTitle
        or not self.assignmentRaidIcon
    then
        return
    end
    local raid = self:GetRaid()
    self.assignmentRaidTitle:SetText(
        raid and raid.name:upper() or self.L.NO_RAID_SELECTED)
    self.assignmentRaidIcon:SetTexture(
        raid and raid.icon
            or "Interface\\Icons\\INV_BannerPVP_02")
end

function Raid:RedrawWorkspace()
    if not self.frame or not self.assignmentPanel then return end
    if self.settingsView and self.settingsView:IsShown() then
        self:SetRaidWorkspaceVisible(false)
        self:RefreshSettingsView()
        self:UpdateWindowLayout()
        return
    end
    self:RefreshWorkspaceNavigation()
    if self.workspaceMode == "ASSIGNMENTS"
        and not self.raidPickerActive
        and self.rosterPanel and self.rosterPanel:IsShown()
    then
        self:RefreshRoster()
    end
    self:UpdateWindowLayout()
    self:RefreshAssignments()
    self:UpdateWindowLayout()
    local settledRowWidth = self.assignmentRowWidth

    self.workspaceRedrawToken = (self.workspaceRedrawToken or 0) + 1
    local token = self.workspaceRedrawToken
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if token ~= Raid.workspaceRedrawToken
                or not Raid.frame or not Raid.frame:IsShown()
                or Raid.settingsView
                    and Raid.settingsView:IsShown()
            then
                return
            end
            Raid:UpdateWindowLayout()
            if math.abs(
                (Raid.assignmentRowWidth or 0)
                    - (settledRowWidth or 0)) > .5
            then
                if Raid.workspaceMode == "ASSIGNMENTS"
                    and not Raid.raidPickerActive
                    and Raid.rosterPanel and Raid.rosterPanel:IsShown()
                then
                    Raid:RefreshRoster()
                end
                Raid:RefreshAssignments()
                Raid:UpdateWindowLayout()
            end
        end)
    end
end

function Raid:RefreshAll()
    if self.settingsView and self.settingsView:IsShown() then
        self:SetRaidWorkspaceVisible(false)
        if self.newRaidWizard then self.newRaidWizard:Hide() end
        self:RefreshSettingsView()
        self:UpdateWindowLayout()
        return
    end
    if self.raidPickerActive then
        self:SetRaidPickerMode(true)
        self:RefreshWorkspaceNavigation()
        if self.frame and self.frame.Title then
            self.frame.Title:SetText("LUNA RAIDS")
            if self.frame.Subtitle then
                self.frame.Subtitle:SetText(
                    "CREATE OR LOAD A RAID PLAN")
            end
        end
        return
    end
    local canEdit = self:IsLocalRaidEditor()
    for _, button in ipairs(self.editorActionButtons or {}) do
        if canEdit then button:Show() else button:Hide() end
    end
    if not canEdit then
        self.selectedPlayer = nil
        self.dragPlayer = nil
        self:HideDragGhost()
        if self.roleMenu then self.roleMenu:Hide() end
        if self.bossSettingsPanel then self.bossSettingsPanel:Hide() end
    end
    self:RefreshBossRail()
    self:RefreshRaidIdentityHeader()
    self:RedrawWorkspace()
    if self.newRaidWizard and self.newRaidWizard:IsShown()
        and self.frame and self.frame.Title
    then
        self.frame.Title:SetText("LUNA RAIDS")
        if self.frame.Subtitle then
            self.frame.Subtitle:SetText(L.CREATE_OR_LOAD_RAID_PLAN)
        end
    end
end

function Raid:ApplyPixelSnapping()
    if not self.frame then return end
    SnapTree(self.frame, {})
end

function Raid:UI_SCALE_CHANGED()
    self:ApplyInterfaceScale()
    if self.frame and self.frame:IsShown() then
        self:RedrawWorkspace()
    end
    if self.readyCheckWindow then
        self.readyCheckWindow:SetScale(self:GetHUDScale())
    end
    if self.quickActionBar then
        self.quickActionBar:SetScale(self:GetHUDScale())
    end
    self:ApplyPixelSnapping()
end

function Raid:GetAutomaticInterfaceScale()
    local effectiveScale = UIParent and UIParent:GetEffectiveScale() or 1
    if not effectiveScale or effectiveScale <= 0 then return 1 end
    return math.min(1, .768 / effectiveScale)
end

function Raid:GetHUDScale()
    return (tonumber(self.db.hudScale) or 1)
        * self:GetAutomaticInterfaceScale()
end

function Raid:ApplyInterfaceScale()
    local hudScale = math.max(
        .25, math.min(1.25, tonumber(self.db.hudScale) or 1))
    self.db.hudScale = hudScale
    hudScale = hudScale * self:GetAutomaticInterfaceScale()
    if self.frame then self.frame:SetScale(1) end
    if self.personalAssignmentFrame then
        self.personalAssignmentFrame:SetScale(hudScale)
    end
    if self.readyCheckWindow then
        self.readyCheckWindow:SetScale(hudScale)
    end
    if self.quickActionBar then
        self.quickActionBar:SetScale(hudScale)
    end
    if self.RefreshRaidCooldowns then
        self:RefreshRaidCooldowns()
    end
    if self.RefreshMechanicsHUD then self:RefreshMechanicsHUD() end
end

function Raid:UpdateWindowLayout()
    if not self.frame or not self.assignmentPanel then return end
    local rowWidth = PixelForRegion(
        self.assignmentPanel,
        math.max(520, self.assignmentPanel:GetWidth() - 12))
    self.assignmentRowWidth = rowWidth
    self.assignmentContent:SetWidth(rowWidth)
    for _, slot in ipairs(self.assignmentSlots or {}) do
        slot:SetWidth(rowWidth)
    end
    for _, row in ipairs(self.markerRows or {}) do
        row:SetWidth(rowWidth)
    end
    for _, line in ipairs(self.mechanicLines or {}) do
        line:SetWidth(rowWidth)
        line.Text:SetWidth(rowWidth - 56)
    end
    if self.assignmentPanel.ProgressTrack then
        local oldWidth =
            math.max(1, self.assignmentPanel.ProgressTrack:GetWidth())
        local progress = math.min(
            1, self.assignmentPanel.ProgressFill:GetWidth() / oldWidth)
        self.assignmentPanel.ProgressTrack:SetWidth(rowWidth)
        self.assignmentPanel.ProgressFill:SetWidth(
            math.max(1, rowWidth * progress))
    end
    local tabCount = 0
    for _ in pairs(self.bossTabs or {}) do
        tabCount = tabCount + 1
    end
    local panelWidth = math.max(
        1, (self.frame:GetWidth() or FRAME_WIDTH) - ROSTER_WIDTH - 2)
    local tabWidth = PixelForRegion(
        self.assignmentPanel,
        math.max(
            1,
            (panelWidth - 10
                - (math.max(1, tabCount) - 1) * 6)
                / math.max(1, tabCount)))
    for _, tab in pairs(self.bossTabs or {}) do
        tab:SetWidth(tabWidth)
    end
    if self.newRaidWizard then
        self:LayoutNewRaidWizardButtons()
    end
    if self.settingsView and self.settingsView.Content then
        self.settingsView.Content:SetWidth(math.max(
            1, self.settingsView:GetWidth() - 28))
        if self.settingsView.Scroll.UpdateScrollbar then
            self.settingsView.Scroll:UpdateScrollbar()
        end
    end
    if self.rosterScroll and self.rosterScroll.UpdateScrollbar then
        self.rosterScroll:UpdateScrollbar()
    end
    if self.assignmentScroll
        and self.assignmentScroll.UpdateScrollbar
    then
        self.assignmentScroll:UpdateScrollbar()
    end
    if self.workspaceMode == "ASSIGNMENTS"
        and self.db.raidLocked
        and not self.raidPickerActive
    then
        self:RefreshBossRail()
    end
end

function Raid:CreateUI()
    if self.frame then return end
    local frame = BackdropFrame(
        "Frame", "LunaRaidsLeaderFrame", UIParent)
    UISpecialFrames = UISpecialFrames or {}
    local registered
    for _, frameName in ipairs(UISpecialFrames) do
        if frameName == "LunaRaidsLeaderFrame" then
            registered = true
            break
        end
    end
    if not registered then
        UISpecialFrames[#UISpecialFrames + 1] =
            "LunaRaidsLeaderFrame"
    end
    frame:SetSize(
        math.max(860, self.db.window.width or FRAME_WIDTH),
        math.max(520, self.db.window.height or FRAME_HEIGHT))
    frame:SetPoint(
        self.db.window.point or "CENTER", UIParent,
        self.db.window.point or "CENTER",
        self.db.window.x or 0, self.db.window.y or 0)
    frame:SetScale(1)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(100)
    frame:SetClampedToScreen(false)
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(860, 520, 1600, 1200)
    else
        frame:SetMinResize(860, 520)
        frame:SetMaxResize(1600, 1200)
    end
    frame:EnableMouse(true)
    frame.OpenAnimation = frame:CreateAnimationGroup()
    local openFade = frame.OpenAnimation:CreateAnimation("Alpha")
    openFade:SetFromAlpha(0)
    openFade:SetToAlpha(1)
    openFade:SetDuration(.18)
    openFade:SetSmoothing("OUT")
    frame.OpenAnimation:SetScript("OnPlay", function()
        frame:SetAlpha(0)
    end)
    frame.OpenAnimation:SetScript("OnFinished", function()
        frame:SetAlpha(1)
    end)
    frame:SetScript("OnShow", function()
        frame.OpenAnimation:Stop()
        frame.OpenAnimation:Play()
        Raid:UpdateRoster()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if frame:IsShown() then
                    Raid:RedrawWorkspace()
                end
            end)
        else
            Raid:RedrawWorkspace()
        end
    end)
    frame:SetScript("OnHide", function()
        frame:StopMovingOrSizing()
        Raid:HideDragGhost()
        Raid.dragPlayer = nil
        if Raid.roleMenu then Raid.roleMenu:Hide() end
        if Raid.raidPlayerMenu then Raid.raidPlayerMenu:Hide() end
        ResetCursor()
    end)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint(1)
        Raid.db.window.point = point
        Raid.db.window.x, Raid.db.window.y = x, y
    end)
    if C_Timer and C_Timer.NewTicker then
        local function StartGearScoreTicker(self)
            if self.gearScoreTicker then return end
            self.gearScoreTicker = C_Timer.NewTicker(10, function()
                if self:IsShown() then Raid:UpdateGearScores() end
            end)
        end
        frame:HookScript("OnShow", StartGearScoreTicker)
        frame:HookScript("OnHide", function(self)
            if self.gearScoreTicker then
                self.gearScoreTicker:Cancel()
                self.gearScoreTicker = nil
            end
        end)
        if frame:IsShown() then StartGearScoreTicker(frame) end
    else
        frame:SetScript("OnUpdate", function(self, elapsed)
            self.gearScoreElapsed =
                (self.gearScoreElapsed or 0) + elapsed
            if self.gearScoreElapsed >= 10 then
                self.gearScoreElapsed = 0
                Raid:UpdateGearScores()
            end
        end)
    end
    frame.BrandIcon = frame:CreateTexture(nil, "OVERLAY")
    frame.BrandIcon:SetTexture("Interface\\Icons\\INV_BannerPVP_02")
    PixelSetSize(frame.BrandIcon, 30, 30)
    frame.BrandIcon:SetPoint("TOPLEFT", 12, -7)
    frame.Title = Font(frame, 15, "text", L.LUNA_RAID_LEADER)
    frame.Title:SetPoint("LEFT", frame.BrandIcon, "RIGHT", 10, 4)
    frame.Subtitle = Font(frame, 9, "muted", L.TACTICAL_RAID_PLANNER)
    frame.Subtitle:SetPoint("TOPLEFT", frame.Title, "BOTTOMLEFT", 0, -1)
    frame.WindowBg = frame:CreateTexture(nil, "BACKGROUND")
    frame.WindowBg:SetTexture(WHITE)
    frame.WindowBg:SetAllPoints()
    frame.WindowBg:SetVertexColor(.018, .028, .04, .98)
    frame.TitleBarBg = frame:CreateTexture(nil, "ARTWORK")
    frame.TitleBarBg:SetTexture(WHITE)
    frame.TitleBarBg:SetPoint("TOPLEFT", 1, -1)
    frame.TitleBarBg:SetPoint("TOPRIGHT", -1, -1)
    frame.TitleBarBg:SetHeight(45)
    frame.TitleBarBg:SetVertexColor(.022, .082, .118, .99)
    frame.TitleAccent = frame:CreateTexture(nil, "OVERLAY")
    frame.TitleAccent:SetTexture(WHITE)
    frame.TitleAccent:SetPoint("TOPLEFT", 1, -44)
    frame.TitleAccent:SetPoint("TOPRIGHT", -1, -44)
    SetPixelHeight(frame.TitleAccent, 2)
    frame.TitleAccent:SetVertexColor(unpack(ACCENT))
    frame.DarkInset = frame:CreateTexture(nil, "BORDER")
    frame.DarkInset:SetTexture(WHITE)
    frame.DarkInset:SetPoint("TOPLEFT", 1, -46)
    frame.DarkInset:SetPoint("BOTTOMRIGHT", -1, 58)
    frame.DarkInset:SetVertexColor(.008, .015, .024, .88)
    frame.StatusBg = frame:CreateTexture(nil, "ARTWORK")
    frame.StatusBg:SetTexture(WHITE)
    frame.StatusBg:SetPoint("TOPLEFT", frame.DarkInset, "BOTTOMLEFT")
    frame.StatusBg:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.StatusBg:SetVertexColor(.018, .068, .092, .99)
    frame.OuterBorder = BackdropFrame("Frame", nil, frame)
    frame.OuterBorder:SetAllPoints()
    frame.OuterBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = Pixel(12),
    })
    frame.OuterBorder:SetBackdropBorderColor(.22, .22, .22, 1)
    frame.OuterBorder:EnableMouse(false)
    frame.Title:SetDrawLayer("OVERLAY", 3)

    frame.CloseButton = Button(frame, "X", 28, 28)
    frame.CloseButton:SetPoint("TOPRIGHT", -7, -8)
    frame.CloseButton.Text:SetFontObject(
        Raid.UI.GetFontObject(12, "MONOCHROMEOUTLINE"))
    frame.CloseButton.Text:SetTextColor(.72, .79, .84)
    frame.CloseButton:SetScript("OnClick", function() frame:Hide() end)
    frame.CloseButton:HookScript("OnEnter", function(self)
        self:SetBackdropColor(.22, .045, .055, .98)
        self:SetBackdropBorderColor(.92, .22, .28, 1)
        self.Text:SetTextColor(1, .82, .84)
    end)
    frame.CloseButton:HookScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(self.baseColor))
        self:SetBackdropBorderColor(unpack(self.baseBorder))
        self.Text:SetTextColor(.72, .79, .84)
    end)
    AddButtonTooltip(
        frame.CloseButton, "Close LunaRaids",
        "Hide the LunaRaids window. Your active raid remains open.")
    self.frame = frame

    self.workspaceMode = self.workspaceMode or "GROUPS"
    self.workspaceRail = Panel(frame)
    self.workspaceRail:SetPoint(
        "TOPRIGHT", frame, "TOPLEFT", 1, -45)
    self.workspaceRail:SetWidth(NAV_RAIL_WIDTH)
    self.workspaceRail:SetHeight(266)
    self.workspaceRail:SetFrameLevel(frame:GetFrameLevel() + 3)
    self.workspaceButtons = {}
    local workspaceEntries = {
        {
            key = "ASSIGNMENTS",
            title = L.RAID_ASSIGNMENTS,
            description = L.WORKSPACE_ASSIGNMENTS_DESC,
            icon = "Interface\\Icons\\INV_Misc_Note_05",
        },
        {
            key = "GROUPS",
            title = L.RAID_GROUPS_TITLE,
            description = L.WORKSPACE_GROUPS_DESC,
            icon = "Interface\\Icons\\INV_Misc_GroupLooking",
        },
        {
            key = "STATUS",
            title = L.RAID_STATUS_TITLE,
            description = L.WORKSPACE_STATUS_DESC,
            icon = "Interface\\RaidFrame\\ReadyCheck-Ready",
        },
        {
            key = "GEAR",
            title = L.GEAR_INSPECT_TITLE,
            description = L.WORKSPACE_GEAR_DESC,
            icon = "Interface\\Icons\\INV_Chest_Plate04",
        },
        {
            key = "SETTINGS",
            title = L.LUNARAIDS_SETTINGS,
            description = L.WORKSPACE_SETTINGS_DESC,
            icon = "Interface\\Buttons\\UI-OptionsButton",
        },
        {
            key = "ABOUT",
            title = L.ABOUT_LUNARAIDS_TITLE,
            description = L.WORKSPACE_ABOUT_DESC,
            icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        },
    }
    for index, entry in ipairs(workspaceEntries) do
        local workspaceKey = entry.key
        local button = Button(self.workspaceRail, "", 38, 38)
        button:SetPoint("TOPLEFT", 5, -5 - ((index - 1) * 43))
        button.Icon = button:CreateTexture(nil, "ARTWORK")
        button.Icon:SetTexture(entry.icon)
        PixelSetSize(button.Icon, 24, 24)
        button.Icon:SetPoint("CENTER")
        button.Text:Hide()
        button.ActiveBar = button:CreateTexture(nil, "OVERLAY")
        button.ActiveBar:SetTexture(WHITE)
        button.ActiveBar:SetPoint("TOPRIGHT", -1, -1)
        button.ActiveBar:SetPoint("BOTTOMRIGHT", -1, 1)
        SetPixelWidth(button.ActiveBar, 3)
        button.ActiveBar:SetVertexColor(unpack(ACCENT))
        button:SetScript("OnClick", function()
            Raid:SetWorkspaceMode(workspaceKey)
        end)
        AddButtonTooltip(button, entry.title, entry.description)
        self.workspaceButtons[workspaceKey] = button
    end

    self.bossRail = Panel(frame)
    self.bossRail:SetPoint(
        "TOPLEFT", frame, "TOPRIGHT", -1, -45)
    self.bossRail:SetWidth(BOSS_RAIL_WIDTH)
    self.bossRail:SetFrameLevel(frame:GetFrameLevel() + 3)
    local rosterPanel = Panel(frame)
    self.rosterPanel = rosterPanel
    rosterPanel:SetPoint("TOPLEFT", 12, -59)
    rosterPanel:SetPoint("BOTTOMLEFT", 12, 68)
    rosterPanel:SetWidth(ROSTER_WIDTH)
    rosterPanel.Divider = rosterPanel:CreateTexture(nil, "OVERLAY")
    rosterPanel.Divider:SetTexture(WHITE)
    rosterPanel.Divider:SetPoint("TOPRIGHT", 0, 0)
    rosterPanel.Divider:SetPoint("BOTTOMRIGHT", 0, 0)
    SetPixelWidth(rosterPanel.Divider, 1)
    rosterPanel.Divider:SetVertexColor(.13, .27, .35, .9)
    local rosterIcon = rosterPanel:CreateTexture(nil, "ARTWORK")
    rosterIcon:SetTexture("Interface\\Icons\\INV_Misc_GroupLooking")
    PixelSetSize(rosterIcon, 22, 22)
    rosterIcon:SetPoint("TOPLEFT", 10, -9)
    local rosterTitle = Font(rosterPanel, 12, "accent", L.RAID_ROSTER)
    rosterTitle:SetPoint("LEFT", rosterIcon, "RIGHT", 7, 0)
    self.rosterCount = Font(rosterPanel, 9, "muted", "0 players")
    self.rosterCount:SetPoint("TOPRIGHT", -42, -13)
    local addPlanned = Button(rosterPanel, "+", 27, 27)
    addPlanned:SetPoint("TOPRIGHT", -8, -7)
    StyleButton(addPlanned, "primary")
    addPlanned:SetScript(
        "OnClick", function() Raid:ShowManualPlayerPanel() end)
    addPlanned:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.ADD_PLANNED_PLAYER)
        GameTooltip:AddLine(
            "Add someone before they join the live raid.",
            MUTED[1], MUTED[2], MUTED[3], true)
        GameTooltip:Show()
    end)
    addPlanned:HookScript("OnLeave", function() GameTooltip:Hide() end)
    self.rosterScroll, self.rosterContent =
        CreateScrollArea(rosterPanel)
    self.rosterScroll:SetPoint("TOPLEFT", 6, -40)
    self.rosterScroll:SetPoint("BOTTOMRIGHT", -6, 8)
    self.rosterContent:SetWidth(ROSTER_ROW_WIDTH)

    local assignmentPanel = Panel(frame)
    self.assignmentPanel = assignmentPanel
    assignmentPanel:SetPoint("TOPLEFT", rosterPanel, "TOPRIGHT", 10, 0)
    assignmentPanel:SetPoint("BOTTOMRIGHT", -12, 68)
    self.bossRail:SetParent(assignmentPanel)
    self.bossRail:ClearAllPoints()
    self.bossRail:SetPoint("TOPLEFT", 8, -42)
    self.bossRail:SetPoint("TOPRIGHT", -8, -42)
    self.bossRail:SetHeight(
        BOSS_BUTTON_SIZE + (BOSS_RAIL_GAP * 2))
    self.bossRail:SetFrameLevel(assignmentPanel:GetFrameLevel() + 3)
    self.bossRail:SetBackdropColor(.018, .045, .062, .88)
    self.bossRail:SetBackdropBorderColor(0, 0, 0, 0)
    if self.bossRail.InnerGlow then self.bossRail.InnerGlow:Hide() end
    if self.bossRail.TopLine then self.bossRail.TopLine:Hide() end
    self.bossRail.BottomLine =
        self.bossRail:CreateTexture(nil, "ARTWORK")
    self.bossRail.BottomLine:SetTexture(WHITE)
    self.bossRail.BottomLine:SetPoint("BOTTOMLEFT", 0, 0)
    self.bossRail.BottomLine:SetPoint("BOTTOMRIGHT", 0, 0)
    SetPixelHeight(self.bossRail.BottomLine, 1)
    self.bossRail.BottomLine:SetVertexColor(.12, .28, .38, .9)
    assignmentPanel.Watermark =
        assignmentPanel:CreateTexture(nil, "BACKGROUND")
    assignmentPanel.Watermark:SetTexture(
        "Interface\\Icons\\INV_BannerPVP_02")
    PixelSetSize(assignmentPanel.Watermark, 260, 260)
    assignmentPanel.Watermark:SetPoint("CENTER", 0, -10)
    assignmentPanel.Watermark:SetAlpha(.035)
    self.assignmentRaidIcon =
        assignmentPanel:CreateTexture(nil, "ARTWORK")
    self.assignmentRaidIcon:SetTexture(
        "Interface\\Icons\\INV_BannerPVP_02")
    PixelSetSize(self.assignmentRaidIcon, 28, 28)
    self.assignmentRaidIcon:SetPoint("TOPLEFT", 9, -7)
    self.assignmentRaidTitle =
        Font(assignmentPanel, 12, "accent", L.NO_RAID_SELECTED)
    self.assignmentRaidTitle:SetPoint(
        "TOPLEFT", self.assignmentRaidIcon, "TOPRIGHT", 8, -1)
    self.assignmentTitle =
        Font(assignmentPanel, 9, "muted", L.ASSIGNMENTS)
    self.assignmentTitle:SetPoint(
        "TOPLEFT", self.assignmentRaidTitle, "BOTTOMLEFT", 0, -1)
    self.bossSettingsButton = Button(assignmentPanel, "", 29, 29)
    self.bossSettingsButton:SetPoint("TOPRIGHT", -8, -7)
    self.bossSettingsButton.Cog =
        self.bossSettingsButton:CreateTexture(nil, "OVERLAY")
    self.bossSettingsButton.Cog:SetTexture(
        "Interface\\Buttons\\UI-OptionsButton")
    PixelSetSize(self.bossSettingsButton.Cog, 18, 18)
    self.bossSettingsButton.Cog:SetPoint("CENTER")
    self.bossSettingsButton:SetScript(
        "OnClick", function() Raid:ToggleBossSettings() end)
    self.bossSettingsButton:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.BOSS_ASSIGNMENT_SETUP)
        GameTooltip:AddLine(
            "Change assignment counts for this boss only.",
            MUTED[1], MUTED[2], MUTED[3], true)
        GameTooltip:Show()
    end)
    self.bossSettingsButton:HookScript(
        "OnLeave", function() GameTooltip:Hide() end)
    self.setCurrentBossButton =
        Button(assignmentPanel, L.SET_CURRENT_BOSS, 142, 29)
    self.setCurrentBossButton:SetPoint(
        "RIGHT", self.bossSettingsButton, "LEFT", -6, 0)
    self.setCurrentBossButton:SetScript("OnClick", function()
        Raid:SetCurrentBoss(Raid.db.activeEncounter)
    end)
    AddButtonTooltip(
        self.setCurrentBossButton, L.SET_CURRENT_BOSS_TITLE,
        L.SET_CURRENT_BOSS_DESC)
    self.activeBossTab = self.activeBossTab or "ASSIGNMENTS"
    self.bossTabs = {}
    local tabEntries = {
        { key = "MARKERS", label = L.MARKERS,
            icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8" },
        { key = "ASSIGNMENTS", label = L.ASSIGNMENTS,
            icon = "Interface\\Icons\\INV_Misc_Note_05" },
        { key = "MECHANICS", label = L.MECHANICS,
            icon = "Interface\\Icons\\INV_Misc_Book_09" },
    }
    local previousTab
    for _, entry in ipairs(tabEntries) do
        local tab = Button(assignmentPanel, entry.label, 214, 32)
        if previousTab then
            tab:SetPoint("TOPLEFT", previousTab, "TOPRIGHT", 6, 0)
        else
            tab:SetPoint("TOPLEFT", 8, -45)
        end
        AddButtonIcon(tab, entry.icon)
        PixelSetSize(tab.ActionIcon, 15, 15)
        tab.Text:ClearAllPoints()
        tab.Text:SetPoint("LEFT", 31, 0)
        tab.Text:SetPoint("RIGHT", -6, 0)
        tab.Text:SetJustifyH("LEFT")
        tab.ActiveLine = tab:CreateTexture(nil, "OVERLAY")
        tab.ActiveLine:SetTexture(WHITE)
        tab.ActiveLine:SetPoint("BOTTOMLEFT", 1, 0)
        tab.ActiveLine:SetPoint("BOTTOMRIGHT", -1, 0)
        SetPixelHeight(tab.ActiveLine, 2)
        tab.ActiveLine:SetVertexColor(unpack(ACCENT))
        tab.tabKey = entry.key
        tab:SetScript("OnClick", function(self)
            Raid:SetBossTab(self.tabKey)
        end)
        tab:HookScript("OnEnter", function() Raid:RefreshBossTabs() end)
        tab:HookScript("OnLeave", function() Raid:RefreshBossTabs() end)
        self.bossTabs[entry.key] = tab
        previousTab = tab
    end
    assignmentPanel.ProgressTrack =
        assignmentPanel:CreateTexture(nil, "ARTWORK")
    assignmentPanel.ProgressTrack:SetTexture(WHITE)
    assignmentPanel.ProgressTrack:SetPoint("TOPLEFT", 8, -80)
    PixelSetSize(
        assignmentPanel.ProgressTrack, ASSIGNMENT_ROW_WIDTH, 2)
    SetPixelHeight(assignmentPanel.ProgressTrack, 2)
    assignmentPanel.ProgressTrack:SetVertexColor(.10, .16, .20, 1)
    assignmentPanel.ProgressFill =
        assignmentPanel:CreateTexture(nil, "OVERLAY")
    assignmentPanel.ProgressFill:SetTexture(WHITE)
    assignmentPanel.ProgressFill:SetPoint(
        "LEFT", assignmentPanel.ProgressTrack, "LEFT", 0, 0)
    SetPixelHeight(assignmentPanel.ProgressFill, 2)
    assignmentPanel.ProgressFill:SetVertexColor(unpack(ACCENT))
    self.assignmentScroll, self.assignmentContent =
        CreateScrollArea(assignmentPanel)
    self.assignmentScroll:SetPoint("TOPLEFT", 6, -84)
    self.assignmentScroll:SetPoint("BOTTOMRIGHT", -6, 8)
    self.assignmentContent:SetWidth(ASSIGNMENT_ROW_WIDTH)

    local newRaid = Button(frame, L.NEW_RAID, 100, 30)
    newRaid:SetPoint("BOTTOMLEFT", 12, 14)
    AddButtonIcon(
        newRaid, "Interface\\Icons\\INV_Misc_GroupLooking", 16)
    newRaid:SetScript("OnClick", function()
        Raid:RequestNewRaid()
    end)
    AddButtonTooltip(
        newRaid, "New Raid",
        "Open raid setup to create a new plan or load a saved raid.")
    local clear = Button(frame, L.CLEAR_BOSS, 104, 30)
    clear:SetPoint("LEFT", newRaid, "RIGHT", 5, 0)
    AddButtonIcon(
        clear, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", 16)
    clear:SetScript("OnClick", function() Raid:ClearPlan() end)
    AddButtonTooltip(
        clear, "Clear Boss",
        "Remove every player, healing target, and marker assignment from the current boss.")
    local saveRaid = Button(frame, L.SAVE_RAID, 110, 30)
    saveRaid:SetPoint("LEFT", clear, "RIGHT", 5, 0)
    AddButtonIcon(
        saveRaid, "Interface\\Icons\\INV_Misc_Note_01", 16)
    saveRaid:SetScript("OnClick", function() Raid:PromptSaveRaid() end)
    AddButtonTooltip(
        saveRaid, "Save Raid",
        "Save the complete raid plan so it can be loaded before a future raid.")
    local whisper = Button(frame, L.WHISPER, 114, 30)
    whisper:SetPoint("BOTTOMRIGHT", -163, 14)
    StyleButton(whisper, "positive")
    AddButtonIcon(whisper, "Interface\\Icons\\INV_Letter_15", 16)
    whisper:SetScript("OnClick", function() Raid:WhisperAssignments() end)
    AddButtonTooltip(
        whisper, "Whisper Roles",
        "Whisper each selected player their assignments for the current boss.")
    local announce = Button(frame, L.ANNOUNCE, 134, 30)
    announce:SetPoint("BOTTOMRIGHT", -24, 14)
    StyleButton(announce, "primary")
    AddButtonIcon(
        announce, "Interface\\Icons\\Ability_Warrior_BattleShout", 16)
    announce:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    announce:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            Raid:ShowAnnouncementChannelMenu(self)
        else
            Raid:AnnounceAssignments()
        end
    end)
    AddButtonTooltip(
        announce, "Announce Assignments",
        L.ANNOUNCE_ASSIGNMENTS_DESC .. L.ANNOUNCE_CHANNEL_PICKER_DESC)
    self.workspaceFrames = {
        self.bossRail, rosterPanel, assignmentPanel,
    }
    self.raidActionButtons = {
        newRaid, clear, saveRaid, whisper, announce,
    }
    self.editorActionButtons = {
        addPlanned, self.bossSettingsButton,
        newRaid, clear, saveRaid, whisper, announce,
    }
    self.assignmentActionButtons = {
        clear, whisper, announce,
    }
    self.generalFooterActionButtons = {
        newRaid, saveRaid,
    }
    self.footerActionButtons = {
        newRaid, clear, saveRaid, whisper, announce,
    }
    self.footerLeftButtons = {
        newRaid, clear, saveRaid,
    }
    self.footerRightButtons = {
        announce, whisper,
    }
    self:RefreshWorkspaceNavigation()

    frame.ResizeGrip = CreateFrame("Button", nil, frame)
    PixelSetSize(frame.ResizeGrip, 20, 20)
    frame.ResizeGrip:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.ResizeGrip:SetFrameLevel(frame:GetFrameLevel() + 20)
    frame.ResizeGrip:SetNormalTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame.ResizeGrip:SetHighlightTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    frame.ResizeGrip:SetPushedTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    frame.ResizeGrip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            frame.isUserResizing = true
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    frame.ResizeGrip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        frame.isUserResizing = nil
        local snappedWidth =
            PixelForRegion(frame, frame:GetWidth())
        local snappedHeight =
            PixelForRegion(frame, frame:GetHeight())
        frame.pixelResizeGuard = true
        frame:SetSize(snappedWidth, snappedHeight)
        frame.pixelResizeGuard = nil
        Raid.db.window.width =
            math.floor(frame:GetWidth() + .5)
        Raid.db.window.height =
            math.floor(frame:GetHeight() + .5)
        Raid:UpdateWindowLayout()
        Raid:RefreshAssignments()
        Raid:ApplyPixelSnapping()
    end)
    AddButtonTooltip(
        frame.ResizeGrip, "Resize",
        "Drag to resize the LunaRaids window.")
    frame:SetScript("OnSizeChanged", function(_, width, height)
        if frame.isUserResizing then
            Raid.db.window.width = width
            Raid.db.window.height = height
            return
        end
        if not frame.pixelResizeGuard then
            local snappedWidth = PixelForRegion(frame, width)
            local snappedHeight = PixelForRegion(frame, height)
            if math.abs(snappedWidth - width) > .0001
                or math.abs(snappedHeight - height) > .0001
            then
                frame.pixelResizeGuard = true
                frame:SetSize(snappedWidth, snappedHeight)
                frame.pixelResizeGuard = nil
                return
            end
        end
        Raid.db.window.width = math.floor(width + .5)
        Raid.db.window.height = math.floor(height + .5)
        Raid:UpdateWindowLayout()
    end)
    self:UpdateWindowLayout()
    self:UpdateRoster()
    frame:Hide()
end

function Raid:Toggle()
    self:CreateUI()
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
        if not self.db.raidLocked then
            if self:CanStartRaid() then
                self:ShowNewRaidWizard()
            else
                self.frame:Hide()
                self:Print(
                    "No active raid. Waiting for the raid leader to start one.")
            end
        else
            self:UpdateRoster()
            self:RefreshAll()
        end
    end
end

function Raid:RefreshMinimapButton()
    if not self.dbIcon then return end
    if self.db.minimap.hide then
        self.dbIcon:Hide("LunaRaids")
    else
        self.dbIcon:Show("LunaRaids")
    end
end

function Raid:InitializeDataBroker()
    if self.dataBroker then return end
    if not LibStub then
        self:Print(self.L.MINIMAP_LIB_UNAVAILABLE)
        return
    end
    local dataBroker = LibStub:GetLibrary(
        "LibDataBroker-1.1", true)
    local dbIcon = LibStub:GetLibrary("LibDBIcon-1.0", true)
    if not dataBroker or not dbIcon then
        self:Print(
            "LibDataBroker or LibDBIcon is unavailable; minimap launcher disabled.")
        return
    end
    self.dataBroker = dataBroker:NewDataObject("LunaRaids", {
        type = "launcher",
        label = "LunaRaids",
        icon = "Interface\\Icons\\INV_BannerPVP_02",
        OnClick = function(_, button)
            if button == "RightButton" then
                Raid:OpenSettings()
            else
                Raid:Toggle()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("LunaRaids", 1, 1, 1)
            tooltip:AddLine(
                "Left-click to open raid assignments.",
                .82, .82, .82)
            tooltip:AddLine(
                "Right-click to open settings.",
                .82, .82, .82)
            tooltip:AddLine(
                "Drag to reposition.", .62, .62, .62)
            tooltip:AddLine(
                "/lr minimap to hide or restore.",
                .35, .72, 1)
        end,
    })
    self.dbIcon = dbIcon
    if not dbIcon:IsRegistered("LunaRaids") then
        dbIcon:Register(
            "LunaRaids", self.dataBroker, self.db.minimap)
    end
    self:RefreshMinimapButton()
end
