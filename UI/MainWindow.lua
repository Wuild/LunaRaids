local _, Raid = ...
local UI = Raid.UI
local ICONS = UI.ICONS
local L = Raid.L
local THEME = UI.THEME

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
local TOP_NAV_HEIGHT = 42
local CONTENT_TOP = 46 + TOP_NAV_HEIGHT

function Raid:CreateLeaderRaidToast()
    if self.leaderRaidToast then return self.leaderRaidToast end
    local toast = Panel(UIParent)
    PixelSetSize(toast, 440, 58)
    toast:SetPoint("TOP", UIParent, "TOP", 0, -105)
    toast:SetFrameStrata("DIALOG")
    toast:SetFrameLevel(120)
    toast:SetBackdropColor(unpack(THEME.surfaceRaised))
    toast:SetBackdropBorderColor(unpack(THEME.positiveBorder))
    toast:EnableMouse(true)
    toast.Icon = toast:CreateTexture(nil, "ARTWORK")
    toast.Icon:SetTexture(ICONS.GROUPS)
    PixelSetSize(toast.Icon, 30, 30)
    toast.Icon:SetPoint("LEFT", 12, 0)
    toast.Title = Font(toast, 10, "accent", L.ACTIVE_RAID_AVAILABLE)
    toast.Title:SetPoint("TOPLEFT", toast.Icon, "TOPRIGHT", 10, -1)
    toast.Detail = Font(toast, 10, "text", "")
    toast.Detail:SetPoint("TOPLEFT", toast.Title, "BOTTOMLEFT", 0, -4)
    toast.Hint = Font(toast, 9, "accent", L.JOIN_RAID)
    toast.Hint:SetPoint("RIGHT", -40, 0)
    toast.Close = Button(toast, "X", 24, 24)
    toast.Close:SetPoint("TOPRIGHT", -5, -5)
    toast.Close:SetScript(
        "OnClick", function() Raid:DismissLeaderRaidOffer() end)
    toast:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then Raid:AcceptLeaderRaidOffer() end
    end)
    toast:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(UI.ACCENT))
    end)
    toast:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(THEME.positiveBorder))
    end)
    toast:Hide()
    self.leaderRaidToast = toast
    return toast
end

function Raid:RefreshLeaderRaidToast()
    local offer = self.availableLeaderRaid
    local raid = offer and self.raidByKey[offer.raidKey]
    if not offer or not raid or offer.dismissed then
        if self.leaderRaidToast then self.leaderRaidToast:Hide() end
        return
    end
    local toast = self:CreateLeaderRaidToast()
    toast:SetScale(tonumber(self.db.hudScale) or 1)
    toast:SetAlpha(tonumber(self.db.hudOpacity) or .92)
    toast.Title:SetText(L.ACTIVE_RAID_AVAILABLE)
    toast.Detail:SetText(offer.sender .. "  ·  " .. raid.name)
    toast:Show()
    self.leaderRaidToastToken = (self.leaderRaidToastToken or 0) + 1
    local token = self.leaderRaidToastToken
    if C_Timer and C_Timer.After then
        C_Timer.After(8, function()
            if Raid.leaderRaidToastToken == token
                and Raid.leaderRaidToast
            then
                Raid.leaderRaidToast:Hide()
            end
        end)
    end
end

local function RaidSyncProgressLabel(frame, status)
    if frame.readOnly then
        status = "READ ONLY  ·  " .. status
    end
    local raidName = tostring(frame.raidName or "")
    if raidName ~= "" then
        return raidName:upper() .. "  ·  " .. status
    end
    return status
end

function Raid:CreateRaidSyncProgress()
    if self.raidSyncProgress then return self.raidSyncProgress end
    self:CreateUI()
    local parent = self.frame
    local frame = Panel(parent)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 1, -126)
    frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -1, -126)
    SetPixelHeight(frame, 20)
    frame:SetFrameLevel(parent:GetFrameLevel() + 15)
    frame:SetBackdropColor(unpack(THEME.content))
    frame:SetBackdropBorderColor(unpack(THEME.positiveBorder))

    frame.Track = frame:CreateTexture(nil, "BACKGROUND")
    frame.Track:SetTexture(WHITE)
    frame.Track:SetPoint("TOPLEFT", 1, -1)
    frame.Track:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.Track:SetVertexColor(
        THEME.borderSoft[1], THEME.borderSoft[2], THEME.borderSoft[3], .8)

    frame.Bar = CreateFrame("StatusBar", nil, frame)
    frame.Bar:SetPoint("TOPLEFT", frame.Track, "TOPLEFT", 1, -1)
    frame.Bar:SetPoint("BOTTOMRIGHT", frame.Track, "BOTTOMRIGHT", -1, 1)
    frame.Bar:SetStatusBarTexture(WHITE)
    frame.Bar:SetStatusBarColor(unpack(THEME.accent))
    frame.Bar:SetMinMaxValues(0, 1)
    frame.Bar:SetValue(0)
    frame.Status = Font(frame.Bar, 8, "text", "REQUESTING RAID DATA...")
    frame.Status:SetPoint("CENTER", 0, 0)
    frame:Hide()
    self.raidSyncProgress = frame
    return frame
end

function Raid:RefreshRaidSyncProgressVisibility()
    local frame = self.raidSyncProgress
    if not frame then return end
    local raidPageVisible = self.frame and self.frame:IsShown()
        and self.assignmentPanel and self.assignmentPanel:IsShown()
        and self.workspaceMode == "ASSIGNMENTS"
        and self.activeBossTab ~= "LOOT"
        and not self.raidPickerActive
        and not (self.settingsView and self.settingsView:IsShown())
    frame:SetShown(frame.active and raidPageVisible or false)
end

function Raid:BeginRaidSyncProgress(total, raidName)
    local frame = self:CreateRaidSyncProgress()
    total = tonumber(total)
    frame.total = total and total > 0 and total or nil
    frame.current = 0
    frame.raidName = raidName or ""
    frame.readOnly = self.fullSyncReadOnly ~= nil
    frame.Status:SetText(RaidSyncProgressLabel(
        frame, frame.total and "RECEIVING RAID DATA... 0%"
            or "REQUESTING RAID DATA..."))
    frame.Bar:SetValue(frame.total and 0 or .06)
    frame.active = true
    frame.lastActivity = GetTime and GetTime() or 0
    if self.leaderRaidToast then self.leaderRaidToast:Hide() end
    if self.RefreshFooterLayout then
        self:RefreshFooterLayout()
    else
        self:RefreshRaidSyncProgressVisibility()
    end
    self.raidSyncProgressToken = (self.raidSyncProgressToken or 0) + 1
    local token = self.raidSyncProgressToken
    if C_Timer and C_Timer.After then
        local function CheckTimeout()
            if Raid.raidSyncProgressToken ~= token
                or not Raid.raidSyncProgress
                or not Raid.raidSyncProgress.active
            then
                return
            end
            local now = GetTime and GetTime() or 0
            local lastActivity = Raid.raidSyncProgress.lastActivity or 0
            local idle = now > 0 and lastActivity > 0
                and now - lastActivity or 25
            if idle < 25 then
                C_Timer.After(math.max(.25, 25 - idle), CheckTimeout)
            elseif Raid.fullSyncReadOnly and Raid.RequestPeerSync then
                -- Keep one continuous read-only join state if FULL_BEGIN was
                -- delayed or dropped. The next request resumes this same bar.
                Raid.raidSyncProgress.lastActivity = now
                Raid.raidSyncProgress.Status:SetText(
                    RaidSyncProgressLabel(
                        Raid.raidSyncProgress,
                        "WAITING FOR RAID DATA..."))
                Raid:RequestPeerSync(true)
                C_Timer.After(25, CheckTimeout)
            else
                Raid:CancelRaidSyncProgress()
            end
        end
        C_Timer.After(25, CheckTimeout)
    end
end

function Raid:AdvanceRaidSyncProgress(amount)
    local frame = self.raidSyncProgress
    if not frame or not frame.active then return end
    frame.lastActivity = GetTime and GetTime() or 0
    frame.current = (frame.current or 0) + (tonumber(amount) or 1)
    if frame.total then
        local progress = math.min(.95, frame.current / frame.total)
        frame.Bar:SetValue(progress)
        frame.Status:SetText(RaidSyncProgressLabel(frame,
            ("RECEIVING RAID DATA... %d%%"):format(
                math.min(95, math.floor(progress * 100 + .5)))))
    else
        frame.Bar:SetValue(math.min(.85, .06 + frame.current * .035))
        frame.Status:SetText(RaidSyncProgressLabel(
            frame, "RECEIVING RAID DATA..."))
    end
end

function Raid:CompleteRaidSyncProgress()
    local frame = self.raidSyncProgress
    if not frame then return end
    self.raidSyncProgressToken = (self.raidSyncProgressToken or 0) + 1
    local token = self.raidSyncProgressToken
    frame.readOnly = self.fullSyncReadOnly ~= nil
    frame.Bar:SetValue(1)
    frame.Status:SetText(RaidSyncProgressLabel(
        frame, "RAID DATA RECEIVED"))
    if C_Timer and C_Timer.After then
        C_Timer.After(.5, function()
            if Raid.raidSyncProgressToken == token
                and Raid.raidSyncProgress
            then
                Raid.raidSyncProgress.active = false
                if Raid.RefreshFooterLayout then
                    Raid:RefreshFooterLayout()
                else
                    Raid:RefreshRaidSyncProgressVisibility()
                end
            end
        end)
    else
        frame.active = false
        if self.RefreshFooterLayout then
            self:RefreshFooterLayout()
        else
            self:RefreshRaidSyncProgressVisibility()
        end
    end
end

function Raid:CancelRaidSyncProgress()
    self.raidSyncProgressToken = (self.raidSyncProgressToken or 0) + 1
    if self.raidSyncProgress then self.raidSyncProgress.active = false end
    if self.RefreshFooterLayout then
        self:RefreshFooterLayout()
    else
        self:RefreshRaidSyncProgressVisibility()
    end
end

function Raid:GetRosterPanelWidth(width)
    local frameWidth = self.frame and self.frame:GetWidth() or FRAME_WIDTH
    local maximum = math.max(280, math.min(460, frameWidth - 540))
    return PixelForRegion(
        self.rosterPanel or self.frame,
        math.max(240, math.min(maximum,
            tonumber(width or self.db.window.rosterWidth) or 300)))
end

function Raid:ApplyRosterPanelWidth(width)
    if not self.rosterPanel then return end
    width = self:GetRosterPanelWidth(width)
    self.rosterPanel:SetWidth(width)
    if self.rosterContent then
        local contentWidth = math.max(1, width - 12)
        self.rosterContent:SetWidth(contentWidth)
        for _, button in ipairs(self.rosterButtons or {}) do
            button:SetWidth(contentWidth)
        end
    end
    return width
end

function Raid:EnterBossUI(initialWorkspace, rosterReady)
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
    if not self:IsRaidReadOnly() and not rosterReady then self:UpdateRoster() end
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
            or ICONS.BRAND)
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

function Raid:IsMainWindowCompletelyOffScreen()
    local frame = self.frame
    if not frame or not UIParent then return false end
    local left, right = frame:GetLeft(), frame:GetRight()
    local top, bottom = frame:GetTop(), frame:GetBottom()
    local parentLeft, parentRight = UIParent:GetLeft(), UIParent:GetRight()
    local parentTop, parentBottom = UIParent:GetTop(), UIParent:GetBottom()
    if not left or not right or not top or not bottom
        or not parentLeft or not parentRight
        or not parentTop or not parentBottom
    then
        return false
    end
    return right <= parentLeft
        or left >= parentRight
        or top <= parentBottom
        or bottom >= parentTop
end

function Raid:ResetWindowPosition()
    if not self.frame or not UIParent then return end
    local usableWidth = math.max(320, UIParent:GetWidth() - 16)
    local usableHeight = math.max(320, UIParent:GetHeight() - 16)
    local width = math.min(FRAME_WIDTH, usableWidth)
    local height = math.min(FRAME_HEIGHT, usableHeight)
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.frame:SetSize(width, height)
    self.db.window.point = "CENTER"
    self.db.window.x, self.db.window.y = 0, 0
    self.db.window.width, self.db.window.height = width, height
    self:UpdateWindowLayout()
    self:ApplyPixelSnapping()
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

function Raid:GetHUDOpacity()
    return math.max(.35, math.min(1,
        tonumber(self.db.hudOpacity) or .92))
end

function Raid:ApplyHUDOpacity()
    self.db.hudOpacity = self:GetHUDOpacity()
    if self.quickActionBar then
        self.quickActionBar:SetAlpha(self.db.hudOpacity)
    end
    if self.personalAssignmentFrame then
        self.personalAssignmentFrame:SetAlpha(self.db.hudOpacity)
    end
    if self.RefreshMechanicsHUD then self:RefreshMechanicsHUD() end
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
    self:ApplyRosterPanelWidth()
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
        1, self.assignmentPanel:GetWidth() or
            ((self.frame:GetWidth() or FRAME_WIDTH) - ROSTER_WIDTH - 2))
    local tabWidth = PixelForRegion(
        self.assignmentPanel,
        math.max(
            1,
            (panelWidth - 16
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
    local workspaceCount = 0
    for _ in pairs(self.workspaceButtons or {}) do
        workspaceCount = workspaceCount + 1
    end
    if workspaceCount > 0 and self.workspaceRail then
        local available = math.max(
            1, (self.workspaceRail:GetWidth() or 1) - 10
                - ((workspaceCount - 1) * 5))
        local workspaceWidth = PixelForRegion(
            self.workspaceRail, available / workspaceCount)
        for _, button in pairs(self.workspaceButtons) do
            button:SetWidth(workspaceWidth)
        end
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
    local savedPoint = self.db.window.point or "CENTER"
    local savedX, savedY = self.db.window.x or 0, self.db.window.y or 0
    local migrateResizeAnchor = savedPoint == "TOPLEFT" and savedY > 0
    frame:SetPoint(
        savedPoint, UIParent,
        migrateResizeAnchor and "BOTTOMLEFT" or savedPoint,
        savedX, savedY)
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
    local function SaveWindowCenterPosition()
        local centerX, centerY = frame:GetCenter()
        local parentX, parentY = UIParent:GetCenter()
        if not centerX or not centerY or not parentX or not parentY then
            return
        end
        local x, y = centerX - parentX, centerY - parentY
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
        Raid.db.window.point = "CENTER"
        Raid.db.window.x, Raid.db.window.y = x, y
    end
    if migrateResizeAnchor then SaveWindowCenterPosition() end
    frame:SetScript("OnShow", function()
        if Raid:IsMainWindowCompletelyOffScreen() then
            Raid:ResetWindowPosition()
        end
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
        SaveWindowCenterPosition()
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
    frame.BrandIcon:SetTexture(ICONS.BRAND)
    PixelSetSize(frame.BrandIcon, 30, 30)
    frame.BrandIcon:SetPoint("TOPLEFT", 12, -7)
    frame.Title = Font(frame, 15, "text", L.LUNA_RAID_LEADER)
    frame.Title:SetPoint("LEFT", frame.BrandIcon, "RIGHT", 10, 4)
    frame.Subtitle = Font(frame, 9, "muted", L.TACTICAL_RAID_PLANNER)
    frame.Subtitle:SetPoint("TOPLEFT", frame.Title, "BOTTOMLEFT", 0, -1)
    frame.WindowBg = frame:CreateTexture(nil, "BACKGROUND")
    frame.WindowBg:SetTexture(WHITE)
    frame.WindowBg:SetAllPoints()
    frame.WindowBg:SetVertexColor(unpack(THEME.window))
    frame.TitleBarBg = frame:CreateTexture(nil, "ARTWORK")
    frame.TitleBarBg:SetTexture(WHITE)
    frame.TitleBarBg:SetPoint("TOPLEFT", 1, -1)
    frame.TitleBarBg:SetPoint("TOPRIGHT", -1, -1)
    frame.TitleBarBg:SetHeight(45)
    frame.TitleBarBg:SetVertexColor(unpack(THEME.footer))
    frame.TitleAccent = frame:CreateTexture(nil, "OVERLAY")
    frame.TitleAccent:SetTexture(WHITE)
    frame.TitleAccent:SetPoint("TOPLEFT", 1, -44)
    frame.TitleAccent:SetPoint("TOPRIGHT", -1, -44)
    SetPixelHeight(frame.TitleAccent, 1)
    frame.TitleAccent:SetVertexColor(unpack(THEME.dividerStrong))
    frame.DarkInset = frame:CreateTexture(nil, "BORDER")
    frame.DarkInset:SetTexture(WHITE)
    frame.DarkInset:SetPoint("TOPLEFT", 1, -CONTENT_TOP)
    frame.DarkInset:SetPoint("BOTTOMRIGHT", -1, 58)
    frame.DarkInset:SetVertexColor(unpack(THEME.content))
    frame.StatusBg = UI.MakeFooter(frame, 58)
    frame.StatusBg:SetPoint("TOPLEFT", frame.DarkInset, "BOTTOMLEFT")
    frame.StatusBg:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.StatusBg:SetFrameLevel(frame:GetFrameLevel())
    frame.OuterBorder = BackdropFrame("Frame", nil, frame)
    frame.OuterBorder:SetAllPoints()
    frame.OuterBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = Pixel(12),
    })
    frame.OuterBorder:SetBackdropBorderColor(unpack(THEME.border))
    frame.OuterBorder:EnableMouse(false)
    frame.Title:SetDrawLayer("OVERLAY", 3)

    frame.CloseButton = Button(frame, "X", 28, 28)
    frame.CloseButton:SetPoint("TOPRIGHT", -7, -8)
    frame.CloseButton.Text:SetFontObject(
        Raid.UI.GetFontObject(13, "OUTLINE"))
    frame.CloseButton.Text:SetTextColor(unpack(THEME.muted))
    frame.CloseButton:SetScript("OnClick", function() frame:Hide() end)
    frame.CloseButton:HookScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(THEME.danger))
        self:SetBackdropBorderColor(unpack(THEME.dangerBorder))
        self.Text:SetTextColor(unpack(THEME.text))
    end)
    frame.CloseButton:HookScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(self.baseColor))
        self:SetBackdropBorderColor(unpack(self.baseBorder))
        self.Text:SetTextColor(unpack(THEME.muted))
    end)
    AddButtonTooltip(
        frame.CloseButton, "Close LunaRaids",
        "Hide the LunaRaids window. Your active raid remains open.")
    self.frame = frame

    self.workspaceMode = self.workspaceMode or "GROUPS"
    self.workspaceRail = CreateFrame("Frame", nil, frame)
    self.workspaceRail:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -47)
    self.workspaceRail:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -47)
    self.workspaceRail:SetHeight(TOP_NAV_HEIGHT - 4)
    self.workspaceRail:SetFrameLevel(frame:GetFrameLevel() + 3)
    self.workspaceRail.Background =
        self.workspaceRail:CreateTexture(nil, "BACKGROUND")
    self.workspaceRail.Background:SetTexture(WHITE)
    self.workspaceRail.Background:SetPoint("TOPLEFT", -7, 1)
    self.workspaceRail.Background:SetPoint("BOTTOMRIGHT", 7, -1)
    self.workspaceRail.Background:SetVertexColor(unpack(THEME.content))
    self.workspaceRail.BottomLine =
        self.workspaceRail:CreateTexture(nil, "ARTWORK")
    self.workspaceRail.BottomLine:SetTexture(WHITE)
    self.workspaceRail.BottomLine:SetPoint("BOTTOMLEFT", -7, -1)
    self.workspaceRail.BottomLine:SetPoint("BOTTOMRIGHT", 7, -1)
    SetPixelHeight(self.workspaceRail.BottomLine, 1)
    self.workspaceRail.BottomLine:SetVertexColor(
        THEME.divider[1], THEME.divider[2], THEME.divider[3], .8)
    self.workspaceButtons = {}
    local workspaceEntries = {
        {
            key = "ASSIGNMENTS",
            label = L.RAID,
            title = L.RAID_ASSIGNMENTS,
            description = L.WORKSPACE_ASSIGNMENTS_DESC,
            icon = ICONS.ASSIGNMENTS,
        },
        {
            key = "GROUPS",
            title = L.RAID_GROUPS_TITLE,
            description = L.WORKSPACE_GROUPS_DESC,
            icon = ICONS.GROUPS,
        },
        {
            key = "STATUS",
            title = L.RAID_STATUS_TITLE,
            description = L.WORKSPACE_STATUS_DESC,
            icon = ICONS.STATUS,
        },
        {
            key = "GEAR",
            title = L.GEAR_INSPECT_TITLE,
            description = L.WORKSPACE_GEAR_DESC,
            icon = ICONS.GEAR,
        },
        {
            key = "SETTINGS",
            label = L.SETTINGS,
            title = L.LUNARAIDS_SETTINGS,
            description = L.WORKSPACE_SETTINGS_DESC,
            icon = ICONS.SETTINGS,
        },
        {
            key = "ABOUT",
            label = "ABOUT",
            title = L.ABOUT_LUNARAIDS_TITLE,
            description = L.WORKSPACE_ABOUT_DESC,
            icon = ICONS.ABOUT,
        },
    }
    local previousWorkspaceButton
    for index, entry in ipairs(workspaceEntries) do
        local workspaceKey = entry.key
        local button = UI.MakeButton(
            self.workspaceRail, entry.label or entry.title, 128, 28)
        if index == 1 then
            button:SetPoint("LEFT", self.workspaceRail, "LEFT", 5, 0)
        else
            button:SetPoint("LEFT", previousWorkspaceButton, "RIGHT", 5, 0)
        end
        button.Icon = button:CreateTexture(nil, "ARTWORK")
        button.Icon:SetTexture(entry.icon)
        PixelSetSize(button.Icon, 18, 18)
        button.Icon:SetPoint("LEFT", 8, 0)
        button.Text:ClearAllPoints()
        button.Text:SetPoint("LEFT", button.Icon, "RIGHT", 7, 0)
        button.Text:SetPoint("RIGHT", -8, 0)
        button.Text:SetJustifyH("LEFT")
        button.ActiveBar = button:CreateTexture(nil, "OVERLAY")
        button.ActiveBar:SetTexture(WHITE)
        button.ActiveBar:SetPoint("BOTTOMLEFT", 1, 0)
        button.ActiveBar:SetPoint("BOTTOMRIGHT", -1, 0)
        SetPixelHeight(button.ActiveBar, 2)
        button.ActiveBar:SetVertexColor(unpack(ACCENT))
        button:SetScript("OnClick", function()
            Raid:SetWorkspaceMode(workspaceKey)
        end)
        AddButtonTooltip(button, entry.title, entry.description)
        self.workspaceButtons[workspaceKey] = button
        previousWorkspaceButton = button
    end

    self.raidToolbar = CreateFrame("Frame", nil, frame)
    self.raidToolbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -88)
    self.raidToolbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -88)
    self.raidToolbar:SetHeight(38)
    self.raidToolbar:SetFrameLevel(frame:GetFrameLevel() + 3)
    self.raidToolbar.Background =
        self.raidToolbar:CreateTexture(nil, "BACKGROUND")
    self.raidToolbar.Background:SetTexture(WHITE)
    self.raidToolbar.Background:SetAllPoints()
    self.raidToolbar.Background:SetVertexColor(unpack(THEME.surfaceAlt))
    self.raidToolbar.BottomLine =
        self.raidToolbar:CreateTexture(nil, "ARTWORK")
    self.raidToolbar.BottomLine:SetTexture(WHITE)
    self.raidToolbar.BottomLine:SetPoint("BOTTOMLEFT")
    self.raidToolbar.BottomLine:SetPoint("BOTTOMRIGHT")
    SetPixelHeight(self.raidToolbar.BottomLine, 1)
    self.raidToolbar.BottomLine:SetVertexColor(unpack(THEME.dividerStrong))
    self.raidToolbar.Icon = self.raidToolbar:CreateTexture(nil, "ARTWORK")
    self.raidToolbar.Icon:SetTexture(ICONS.PLAN)
    PixelSetSize(self.raidToolbar.Icon, 17, 17)
    self.raidToolbar.Icon:SetPoint("LEFT", 12, 0)
    self.raidToolbar.Title = Font(self.raidToolbar, 10, "accent", "")
    self.raidToolbar.Title:SetPoint(
        "LEFT", self.raidToolbar.Icon, "RIGHT", 7, 0)
    self.raidToolbar.Title:SetWidth(180)
    self.raidToolbar.Title:SetJustifyH("LEFT")

    self.inactiveRaidBanner = CreateFrame("Frame", nil, frame)
    self.inactiveRaidBanner:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -88)
    self.inactiveRaidBanner:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -88)
    self.inactiveRaidBanner:SetHeight(38)
    self.inactiveRaidBanner:SetFrameLevel(frame:GetFrameLevel() + 3)
    self.inactiveRaidBanner.Background =
        self.inactiveRaidBanner:CreateTexture(nil, "BACKGROUND")
    self.inactiveRaidBanner.Background:SetTexture(WHITE)
    self.inactiveRaidBanner.Background:SetAllPoints()
    self.inactiveRaidBanner.Background:SetVertexColor(unpack(THEME.surfaceAlt))
    self.inactiveRaidBanner.BottomLine =
        self.inactiveRaidBanner:CreateTexture(nil, "ARTWORK")
    self.inactiveRaidBanner.BottomLine:SetTexture(WHITE)
    self.inactiveRaidBanner.BottomLine:SetPoint("BOTTOMLEFT")
    self.inactiveRaidBanner.BottomLine:SetPoint("BOTTOMRIGHT")
    SetPixelHeight(self.inactiveRaidBanner.BottomLine, 1)
    self.inactiveRaidBanner.BottomLine:SetVertexColor(
        unpack(THEME.dividerStrong))
    self.inactiveRaidBanner.Icon =
        self.inactiveRaidBanner:CreateTexture(nil, "ARTWORK")
    self.inactiveRaidBanner.Icon:SetTexture(ICONS.GROUPS)
    PixelSetSize(self.inactiveRaidBanner.Icon, 18, 18)
    self.inactiveRaidBanner.Icon:SetPoint("LEFT", 12, 0)
    self.inactiveRaidBanner.Title = Font(
        self.inactiveRaidBanner, 10, "accent", L.NO_ACTIVE_RAID_JOINED)
    self.inactiveRaidBanner.Title:SetPoint(
        "LEFT", self.inactiveRaidBanner.Icon, "RIGHT", 8, 0)
    self.inactiveRaidBanner.Action = Button(
        self.inactiveRaidBanner, L.SELECT_RAID, 120, 26)
    self.inactiveRaidBanner.Action:SetPoint("RIGHT", -8, 0)
    StyleButton(self.inactiveRaidBanner.Action, "primary")
    self.inactiveRaidBanner.Action:SetScript("OnClick", function()
        if Raid.availableLeaderRaid then
            Raid:AcceptLeaderRaidOffer()
        else
            Raid:ShowNewRaidWizard(false)
        end
    end)
    self.inactiveRaidBanner:Hide()

    self.bossRail = Panel(frame)
    self.bossRail:SetPoint(
        "TOPLEFT", frame, "TOPRIGHT", -1, -45)
    self.bossRail:SetWidth(BOSS_RAIL_WIDTH)
    self.bossRail:SetFrameLevel(frame:GetFrameLevel() + 3)
    local rosterPanel = Panel(frame)
    self.rosterPanel = rosterPanel
    rosterPanel:SetPoint("TOPLEFT", 12, -59)
    rosterPanel:SetPoint("BOTTOMLEFT", 12, 68)
    rosterPanel:SetWidth(self:GetRosterPanelWidth())
    rosterPanel.Divider = rosterPanel:CreateTexture(nil, "OVERLAY")
    rosterPanel.Divider:SetTexture(WHITE)
    rosterPanel.Divider:SetPoint("TOPRIGHT", 0, 0)
    rosterPanel.Divider:SetPoint("BOTTOMRIGHT", 0, 0)
    SetPixelWidth(rosterPanel.Divider, 1)
    rosterPanel.Divider:SetVertexColor(unpack(THEME.divider))
    rosterPanel.ResizeHandle = CreateFrame("Button", nil, rosterPanel)
    rosterPanel.ResizeHandle:SetPoint("TOPRIGHT", 5, 0)
    rosterPanel.ResizeHandle:SetPoint("BOTTOMRIGHT", 5, 0)
    rosterPanel.ResizeHandle:SetWidth(10)
    rosterPanel.ResizeHandle:SetFrameLevel(rosterPanel:GetFrameLevel() + 20)
    rosterPanel.ResizeHandle:RegisterForDrag("LeftButton")
    rosterPanel.ResizeHandle:SetScript("OnDragStart", function(self)
        local cursorX = GetCursorPosition()
        self.dragStartX = cursorX / rosterPanel:GetEffectiveScale()
        self.dragStartWidth = rosterPanel:GetWidth()
        self:SetScript("OnUpdate", function(handle)
            local currentX = GetCursorPosition()
            currentX = currentX / rosterPanel:GetEffectiveScale()
            local width = handle.dragStartWidth
                + (currentX - handle.dragStartX)
            Raid.db.window.rosterWidth = Raid:GetRosterPanelWidth(width)
            Raid:RefreshFooterLayout()
            Raid:UpdateWindowLayout()
        end)
    end)
    rosterPanel.ResizeHandle:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        self.dragStartX, self.dragStartWidth = nil, nil
        rosterPanel.Divider:SetVertexColor(unpack(THEME.divider))
        Raid.db.window.rosterWidth = math.floor(
            Raid:GetRosterPanelWidth() + .5)
        Raid:RefreshRoster()
    end)
    rosterPanel.ResizeHandle:SetScript("OnEnter", function()
        rosterPanel.Divider:SetVertexColor(unpack(ACCENT))
    end)
    rosterPanel.ResizeHandle:SetScript("OnLeave", function(self)
        if not self.dragStartWidth then
            rosterPanel.Divider:SetVertexColor(unpack(THEME.divider))
        end
    end)
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
    self.rosterContent:SetWidth(
        math.max(1, self:GetRosterPanelWidth() - 12))

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
    self.bossRail:SetBackdropColor(unpack(THEME.surfaceAlt))
    self.bossRail:SetBackdropBorderColor(0, 0, 0, 0)
    if self.bossRail.InnerGlow then self.bossRail.InnerGlow:Hide() end
    if self.bossRail.TopLine then self.bossRail.TopLine:Hide() end
    self.bossRail.BottomLine =
        self.bossRail:CreateTexture(nil, "ARTWORK")
    self.bossRail.BottomLine:SetTexture(WHITE)
    self.bossRail.BottomLine:SetPoint("BOTTOMLEFT", 0, 0)
    self.bossRail.BottomLine:SetPoint("BOTTOMRIGHT", 0, 0)
    SetPixelHeight(self.bossRail.BottomLine, 1)
    self.bossRail.BottomLine:SetVertexColor(unpack(THEME.dividerStrong))
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
        ICONS.SETTINGS)
    PixelSetSize(self.bossSettingsButton.Cog, 18, 18)
    self.bossSettingsButton.Cog:SetPoint("CENTER")
    self.bossSettingsButton:SetScript(
        "OnClick", function() Raid:ToggleBossSettings() end)
    self.bossSettingsButton:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local overview = Raid.db.activeEncounter == 1
        GameTooltip:SetText(
            overview and "Raid-Wide Assignment Setup"
                or L.BOSS_ASSIGNMENT_SETUP)
        GameTooltip:AddLine(
            overview
                and "Add categories and change counts for the raid-wide plan."
                or "Change assignment counts for this boss only.",
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
        { key = "MARKERS", label = L.MARKERS, icon = ICONS.MARKERS },
        { key = "ASSIGNMENTS", label = L.ASSIGNMENTS,
            icon = ICONS.ASSIGNMENTS },
        { key = "MECHANICS", label = L.MECHANICS,
            icon = ICONS.MECHANICS },
        { key = "STATS", label = "STATS", icon = ICONS.COOLDOWNS },
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
    assignmentPanel.ProgressTrack:SetVertexColor(unpack(THEME.track))
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

    local closeRaid = Button(
        self.raidToolbar, L.CLOSE_RAID, 104, 26)
    closeRaid:SetPoint("RIGHT", self.raidToolbar, "RIGHT", -8, 0)
    StyleButton(closeRaid, "danger")
    closeRaid:SetScript("OnClick", function() Raid:CompleteRaid() end)
    AddButtonTooltip(
        closeRaid, "Close Active Raid",
        "Return to raid selection. Leaders close the shared session; other players only close their local view.")
    local backToHistory = Button(
        self.raidToolbar, L.BACK_TO_HISTORY, 142, 26)
    backToHistory:SetPoint("RIGHT", self.raidToolbar, "RIGHT", -8, 0)
    StyleButton(backToHistory, "default")
    backToHistory:SetScript(
        "OnClick", function() Raid:ExitRaidHistory() end)
    AddButtonTooltip(
        backToHistory, "Back to Raid History",
        "Close this read-only view and return to saved raids.")
    local saveRaid = Button(self.raidToolbar, L.SAVE_RAID, 104, 26)
    saveRaid:SetPoint("RIGHT", closeRaid, "LEFT", -5, 0)
    StyleButton(saveRaid, "default")
    AddButtonIcon(saveRaid, ICONS.SAVE, 15)
    saveRaid:SetScript("OnClick", function() Raid:PromptSaveRaid() end)
    AddButtonTooltip(
        saveRaid, "Save Raid",
        "Save the current raid plan, roster, and assignments.")
    local announce = Button(self.raidToolbar, L.ANNOUNCE, 116, 26)
    announce:SetPoint("RIGHT", saveRaid, "LEFT", -5, 0)
    StyleButton(announce, "primary")
    AddButtonIcon(announce, ICONS.ANNOUNCE, 15)
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
    local whisper = Button(self.raidToolbar, L.WHISPER, 104, 26)
    whisper:SetPoint("RIGHT", announce, "LEFT", -5, 0)
    StyleButton(whisper, "default")
    AddButtonIcon(whisper, ICONS.WHISPER, 15)
    whisper:SetScript("OnClick", function() Raid:WhisperAssignments() end)
    AddButtonTooltip(
        whisper, "Whisper Roles",
        "Whisper each selected player their assignments for the current boss.")
    local assignments = Button(
        self.raidToolbar, L.ASSIGNMENTS, 122, 26)
    assignments:SetPoint("LEFT", self.raidToolbar, "LEFT", 228, 0)
    StyleButton(assignments, "primary")
    AddButtonIcon(assignments, ICONS.ASSIGNMENTS, 15)
    assignments:SetScript("OnClick", function()
        Raid:SetBossTab(Raid.lastAssignmentBossTab or "ASSIGNMENTS")
    end)
    AddButtonTooltip(
        assignments, L.ASSIGNMENTS,
        "Open the boss plans, assignments, markers, and raid roster.")
    local loot = Button(self.raidToolbar, L.LOOT, 92, 26)
    loot:SetPoint("LEFT", assignments, "RIGHT", 5, 0)
    StyleButton(loot, "default")
    AddButtonIcon(loot, ICONS.LOOT, 15)
    loot:SetScript("OnClick", function() Raid:SetBossTab("LOOT") end)
    AddButtonTooltip(
        loot, L.LOOT, "View items received during this raid session.")
    self.workspaceFrames = {
        self.bossRail, rosterPanel, assignmentPanel,
    }
    self.raidToolbarButtons = {
        assignments, loot, whisper, announce, saveRaid, closeRaid,
    }
    self.raidToolbarEditorButtons = {
        whisper, announce, saveRaid,
    }
    self.raidToolbarCloseButton = closeRaid
    self.raidToolbarHistoryButton = backToHistory
    self.raidToolbarLootButton = loot
    self.raidToolbarAssignmentsButton = assignments
    self.raidActionButtons = {}
    self.editorActionButtons = {
        addPlanned, self.bossSettingsButton,
    }
    self.assignmentActionButtons = {}
    self.generalFooterActionButtons = {}
    self.footerActionButtons = {}
    self.footerLeftButtons = {}
    self.footerRightButtons = {}
    self:RefreshWorkspaceNavigation()

    -- The resize handle belongs to the window chrome, not the optional footer.
    frame.ResizeGrip = CreateFrame("Button", nil, frame)
    PixelSetSize(frame.ResizeGrip, 20, 20)
    frame.ResizeGrip:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    frame.ResizeGrip:SetFrameLevel(frame:GetFrameLevel() + 100)
    frame.ResizeGrip:SetNormalTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame.ResizeGrip:SetHighlightTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    frame.ResizeGrip:SetPushedTexture(
        "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    frame.ResizeGrip:SetScript("OnMouseDown", function(grip, button)
        if button == "LeftButton" then
            frame.isUserResizing = true
            local cursorX, cursorY = GetCursorPosition()
            local scale = frame:GetEffectiveScale()
            grip.resizeStartX = cursorX / scale
            grip.resizeStartY = cursorY / scale
            grip.resizeStartWidth = frame:GetWidth()
            grip.resizeStartHeight = frame:GetHeight()

            -- Keep the opposite corner fixed. Explicit cursor-space sizing
            -- avoids StartSizing mixing physical and scaled UI coordinates.
            local left, top = frame:GetLeft(), frame:GetTop()
            frame:ClearAllPoints()
            frame:SetPoint(
                "TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
            grip:SetScript("OnUpdate", function(self)
                local currentX, currentY = GetCursorPosition()
                currentX, currentY = currentX / scale, currentY / scale
                local width = math.max(860, math.min(1600,
                    self.resizeStartWidth
                        + currentX - self.resizeStartX))
                local height = math.max(520, math.min(1200,
                    self.resizeStartHeight
                        + self.resizeStartY - currentY))
                frame:SetSize(width, height)
            end)
        end
    end)
    frame.ResizeGrip:SetScript("OnMouseUp", function(grip)
        grip:SetScript("OnUpdate", nil)
        grip.resizeStartX, grip.resizeStartY = nil, nil
        grip.resizeStartWidth, grip.resizeStartHeight = nil, nil
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
        SaveWindowCenterPosition()
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
            self:ShowNewRaidWizard()
        else
            self:UpdateRoster(true)
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
        icon = ICONS.BRAND,
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
