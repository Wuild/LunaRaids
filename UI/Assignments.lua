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
local ROW_SEPARATOR = THEME.borderSoft

local function UseRowSeparator(frame)
    if not frame.PixelBorders then return end
    frame.PixelBorders[1]:Hide()
    frame.PixelBorders[3]:Hide()
    frame.PixelBorders[4]:Hide()
end

local function RecommendationText(values, classNames)
    local entries = {}
    for key, weight in pairs(values or {}) do
        entries[#entries + 1] = { key = key, weight = weight }
    end
    table.sort(entries, function(left, right)
        if left.weight ~= right.weight then
            return left.weight > right.weight
        end
        return left.key < right.key
    end)
    local labels = {}
    for _, entry in ipairs(entries) do
        labels[#labels + 1] = classNames
            and LOCALIZED_CLASS_NAMES_MALE
            and LOCALIZED_CLASS_NAMES_MALE[entry.key]
            or entry.key
    end
    return table.concat(labels, ", ")
end

function Raid:CreateAssignmentSlot(index)
    local slot = Button(
        self.assignmentContent, "",
        self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH, 34)
    UseRowSeparator(slot)
    slot.baseBorder = { unpack(ROW_SEPARATOR) }
    slot:SetBackdropBorderColor(unpack(slot.baseBorder))
    slot.RoleIcon = slot:CreateTexture(nil, "ARTWORK")
    slot.RoleIcon:SetTexture(ROLE_TEXTURE)
    PixelSetSize(slot.RoleIcon, 19, 19)
    slot.RoleIcon:SetPoint("LEFT", 10, 0)
    slot.Label = Font(slot, 10, "muted", "")
    slot.Label:SetPoint("LEFT", 38, 0)
    slot.Label:SetWidth(292)
    slot.Label:SetJustifyH("LEFT")
    slot.Player = Font(slot, 10, "text", "Drop player here")
    slot.Player:SetPoint("LEFT", 344, 0)
    slot.Player:SetPoint("RIGHT", -12, 0)
    slot.Player:SetJustifyH("LEFT")
    slot.HealingTarget = Button(slot, "", 296, 32)
    slot.HealingTarget:SetPoint("LEFT", 34, 0)
    for _, edge in ipairs(slot.HealingTarget.PixelBorders or {}) do
        edge:Hide()
    end
    slot.HealingTarget:SetBackdropBorderColor(0, 0, 0, 0)
    slot.HealingTarget.SetBackdropBorderColor = function() end
    slot.HealingTarget.Text:ClearAllPoints()
    slot.HealingTarget.Text:SetPoint("LEFT", 6, 0)
    slot.HealingTarget.Text:SetPoint("RIGHT", -5, 0)
    slot.HealingTarget.Text:SetJustifyH("LEFT")
    slot.HealingTarget:SetFrameLevel(slot:GetFrameLevel() + 2)
    slot.HealingTarget:SetScript("OnClick", function()
        if slot.healingSlotIndex then
            Raid:CycleHealingTarget(slot.healingSlotIndex)
        end
    end)
    slot.HealingTarget:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(THEME.surfaceHover))
        self:SetBackdropBorderColor(unpack(ACCENT))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(Raid.L.HEALING_TARGET)
        GameTooltip:AddLine(
            "Click to cycle between tanks and raid healing.",
            unpack(MUTED))
        GameTooltip:Show()
    end)
    slot.HealingTarget:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(self.baseColor))
        self:SetBackdropBorderColor(unpack(self.baseBorder))
        GameTooltip:Hide()
    end)
    slot.HealingTarget:Hide()
    slot.FilledBar = slot:CreateTexture(nil, "OVERLAY")
    slot.FilledBar:SetTexture(WHITE)
    slot.FilledBar:SetPoint("TOPLEFT", 1, -1)
    slot.FilledBar:SetPoint("BOTTOMLEFT", 1, 1)
    SetPixelWidth(slot.FilledBar, 4)
    slot.FilledBar:SetVertexColor(.25, .85, .45, .95)
    slot.FilledBar:Hide()
    slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    slot:RegisterForDrag("LeftButton")
    slot:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            if self.healingSlotIndex then
                Raid:SetHealingAssignment(
                    self.healingSlotIndex, nil)
            else
                Raid:SetAssignment(
                    self.groupIndex, self.slotIndex, nil)
            end
        elseif Raid.selectedPlayer then
            local selectedPlayer = Raid.selectedPlayer
            if self.healingSlotIndex then
                Raid:SetHealingAssignment(
                    self.healingSlotIndex, selectedPlayer)
            else
                Raid:SetAssignment(
                    self.groupIndex,
                    self.slotIndex, selectedPlayer)
            end
            Raid.selectedPlayer = nil
            Raid:RefreshRoster()
        else
            local assignment = self.healingSlotIndex
                and Raid:GetHealingAssignment(self.healingSlotIndex)
                or Raid:GetAssignment(self.groupIndex, self.slotIndex)
            if not assignment then
                Raid:SuggestAssignment(
                    self.groupIndex, self.slotIndex, self.healingSlotIndex)
            end
        end
    end)
    slot:SetScript("OnReceiveDrag", function(self)
        local player = Raid.dragPlayer or Raid.selectedPlayer
        if player then
            if self.healingSlotIndex then
                Raid:SetHealingAssignment(
                    self.healingSlotIndex, player)
            else
                Raid:SetAssignment(
                    self.groupIndex, self.slotIndex, player)
            end
        end
        ResetCursor()
        Raid:HideDragGhost()
        Raid.dragPlayer = nil
        Raid.selectedPlayer = nil
        Raid:RefreshRoster()
    end)
    slot:SetScript("OnEnter", function(self)
        if Raid.dragPlayer then
            self:SetBackdropBorderColor(unpack(ACCENT))
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(Raid.L.ASSIGN_PLAYER)
        GameTooltip:AddLine(
            "Drag a roster player here, or select a player and click.",
            unpack(MUTED))
        GameTooltip:AddLine(
            "With no player selected, click to choose the best role, "
                .. "encounter recommendation, and GearScore match.",
            .35, .72, 1, true)
        local definition = self.assignmentDefinition
        local classes = definition and RecommendationText(
            definition.recommendedClasses, true) or ""
        local specs = definition and RecommendationText(
            definition.recommendedSpecs, false) or ""
        if classes ~= "" then
            GameTooltip:AddLine(
                "Recommended classes: " .. classes,
                .45, .82, 1, true)
        end
        if specs ~= "" then
            GameTooltip:AddLine(
                "Recommended specs: " .. specs,
                .55, .90, .65, true)
        end
        GameTooltip:AddLine(Raid.L.RIGHT_CLICK_CLEAR_SLOT, unpack(MUTED))
        GameTooltip:Show()
    end)
    slot:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(self.baseBorder))
        GameTooltip:Hide()
    end)
    return slot
end

function Raid:CreateMarkerRow(index)
    local row = Button(
        self.assignmentContent, "",
        self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH, 27)
    UseRowSeparator(row)
    row.baseBorder = { unpack(ROW_SEPARATOR) }
    row:SetBackdropBorderColor(unpack(row.baseBorder))
    row.Label = Font(row, 10, "muted", "")
    row.Label:SetPoint("LEFT", 7, 0)
    row.Label:SetPoint("RIGHT", -145, 0)
    row.Label:SetJustifyH("LEFT")
    row.MarkerIcon = row:CreateTexture(nil, "ARTWORK")
    PixelSetSize(row.MarkerIcon, 18, 18)
    row.MarkerIcon:SetPoint("RIGHT", -105, 0)
    row.MarkerText = Font(row, 10, "text", "No marker")
    row.MarkerText:SetPoint("RIGHT", -9, 0)
    row.MarkerText:SetWidth(88)
    row.MarkerText:SetJustifyH("LEFT")
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            Raid:SetMarkerAssignment(self.targetIndex, nil)
        else
            Raid:CycleMarkerAssignment(self.targetIndex)
        end
    end)
    row:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(ACCENT))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(Raid.L.RAID_MARKER)
        GameTooltip:AddLine(
            "Left-click to choose the next unused marker. "
            .. "Right-click to clear.",
            unpack(MUTED))
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(self.baseBorder))
        GameTooltip:Hide()
    end)
    return row
end

local function SetMarkerTexture(texture, markerIndex)
    local marker = markerIndex and Raid.markers[markerIndex]
    if not marker then
        texture:Hide()
        return
    end
    texture:SetTexture(
        "Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    if SetRaidTargetIconTexture then
        SetRaidTargetIconTexture(texture, marker.icon)
    else
        local column = (marker.icon - 1) % 4
        local row = math.floor((marker.icon - 1) / 4)
        texture:SetTexCoord(
            column / 4, (column + 1) / 4,
            row / 2, (row + 1) / 2)
    end
    texture:Show()
end

UI.SetMarkerTexture = SetMarkerTexture

function Raid:SetBossTab(tab)
    if tab ~= "LOOT" then
        self.lastAssignmentBossTab = tab
    end
    self.activeBossTab = tab
    if self.assignmentScroll then
        self.assignmentScroll:SetVerticalScroll(0)
    end
    self:RedrawWorkspace()
    self:RefreshFooterLayout()
end

function Raid:SetWorkspaceMode(mode)
    if mode == "SETTINGS" then
        self:ShowSettingsView()
        return
    end
    if self.settingsView and self.settingsView:IsShown() then
        self.settingsView:Hide()
        self:SetRaidWorkspaceVisible(true)
    end
    if self.raidPickerActive or not self.db.raidLocked then
        if mode == "GROUPS" or mode == "STATUS" or mode == "GEAR"
            or mode == "ABOUT"
        then
            if self.newRaidWizard then
                self.newRaidWizard:Hide()
            end
            self:SetRaidPickerMode(false)
            self.workspaceMode = mode
            self.selectedPlayer = nil
            self.dragPlayer = nil
            self:HideDragGhost()
            self:RedrawWorkspace()
        else
            self.workspaceMode = "ASSIGNMENTS"
            self:SetRaidWorkspaceVisible(true)
            self:SetRaidPickerMode(true)
            local wizard = self:CreateNewRaidWizard()
            wizard.step = wizard.step or "EXPANSION"
            wizard:Show()
            self:RefreshNewRaidWizard()
            self.frame.Title:SetText("LUNA RAIDS")
            self.frame.Subtitle:SetText(self.L.CREATE_OR_LOAD_RAID_PLAN)
            self:RefreshWorkspaceNavigation()
            self:UpdateWindowLayout()
        end
        return
    end
    if self.newRaidWizard and self.newRaidWizard:IsShown() then
        self.newRaidWizard:Hide()
    end
    self.workspaceMode = mode == "GROUPS" and "GROUPS"
        or mode == "STATUS" and "STATUS"
        or mode == "GEAR" and "GEAR"
        or mode == "ABOUT" and "ABOUT"
        or "ASSIGNMENTS"
    self.selectedPlayer = nil
    self.dragPlayer = nil
    self:HideDragGhost()
    if self.bossSettingsPanel then self.bossSettingsPanel:Hide() end
    self:RedrawWorkspace()
end

function Raid:SetRaidPickerMode(enabled)
    enabled = enabled and true or false
    self.raidPickerActive = enabled
    if enabled then
        -- The raid picker does not pass through RefreshAssignments, so hide
        -- any standalone page (About, Gear, Status, Loot) at the transition.
        UI.ShowPage(self, nil)
    end
    if self.inactiveRaidNav then
        self.inactiveRaidNav:SetShown(enabled)
    end

    for _, button in ipairs(self.bossButtons or {}) do
        button:Hide()
    end

    if self.assignmentRaidIcon then
        self.assignmentRaidIcon:SetShown(not enabled)
    end
    if self.assignmentRaidTitle then
        self.assignmentRaidTitle:SetShown(not enabled)
    end
    if self.assignmentTitle then
        self.assignmentTitle:SetShown(not enabled)
    end
    if self.assignmentScroll then
        self.assignmentScroll:SetShown(not enabled)
    end
    if self.bossSettingsButton then
        self.bossSettingsButton:SetShown(not enabled)
    end
    if self.bossSettingsPanel then
        self.bossSettingsPanel:Hide()
    end
    for _, tab in pairs(self.bossTabs or {}) do
        tab:SetShown(not enabled)
    end
    if self.assignmentPanel and self.assignmentPanel.ProgressTrack then
        self.assignmentPanel.ProgressTrack:SetShown(not enabled)
        self.assignmentPanel.ProgressFill:SetShown(not enabled)
    end
    if self.bossRail then
        self.bossRail:Show()
    end
    if enabled then
        for _, button in ipairs(self.footerActionButtons or {}) do
            button:Hide()
        end
    end
end

function Raid:RefreshFooterLayout()
    if not self.frame or not self.rosterPanel
        or not self.assignmentPanel
    then
        return
    end
    local offer = self.availableLeaderRaid
    local offeredRaid = offer and self.raidByKey[offer.raidKey]
    local showInactiveBanner = not self.db.raidLocked
        and offeredRaid ~= nil
    if self.inactiveRaidBanner then
        self.inactiveRaidBanner:SetShown(showInactiveBanner)
        if showInactiveBanner then
            self.inactiveRaidBanner.Title:SetText(
                self.L.ACTIVE_RAID_AVAILABLE .. "  ·  "
                    .. offer.sender .. "  ·  " .. offeredRaid.name:upper())
            self.inactiveRaidBanner.Action.Text:SetText(self.L.JOIN_RAID)
            StyleButton(self.inactiveRaidBanner.Action, "positive")
        end
    end
    local showRaidToolbar = self.db.raidLocked
        and not self.raidPickerActive
        and self.workspaceMode == "ASSIGNMENTS"
    local readOnly = self:IsRaidReadOnly()
    if self.raidToolbar then
        self.raidToolbar:ClearAllPoints()
        self.raidToolbar:SetPoint(
            "TOPLEFT", self.frame, "TOPLEFT", 1,
            showInactiveBanner and -126 or -88)
        self.raidToolbar:SetPoint(
            "TOPRIGHT", self.frame, "TOPRIGHT", -1,
            showInactiveBanner and -126 or -88)
        self.raidToolbar:SetShown(showRaidToolbar or false)
        if showRaidToolbar and self.raidToolbar.Title then
            local raid = self:GetRaid()
            local saved = self.db.activeSavedRaid
                and self.db.savedRaids[self.db.activeSavedRaid]
            self.raidToolbar.Title:SetText(
                readOnly and (self.L.READ_ONLY .. "  ·  "
                    .. (saved and saved.name:upper()
                        or raid and raid.name:upper() or self.L.RAID))
                    or saved and saved.name:upper()
                    or raid and raid.name:upper() or self.L.RAID)
        end
    end
    local canEdit = self:IsLocalRaidEditor()
    for _, button in ipairs(self.raidToolbarEditorButtons or {}) do
        button:SetShown(showRaidToolbar and not readOnly and canEdit or false)
    end
    if self.raidToolbarCloseButton then
        self.raidToolbarCloseButton:SetShown(
            showRaidToolbar and not readOnly or false)
    end
    if self.raidToolbarHistoryButton then
        self.raidToolbarHistoryButton:SetShown(
            showRaidToolbar and self.db.raidReadOnly == true or false)
    end
    if self.raidToolbarLootButton then
        self.raidToolbarLootButton:SetShown(showRaidToolbar or false)
        StyleButton(self.raidToolbarLootButton,
            self.activeBossTab == "LOOT" and "primary" or "default")
    end
    if self.raidToolbarAssignmentsButton then
        self.raidToolbarAssignmentsButton:SetShown(showRaidToolbar or false)
        StyleButton(self.raidToolbarAssignmentsButton,
            self.activeBossTab ~= "LOOT" and "primary" or "default")
    end
    local contentTop = -88
        - (showInactiveBanner and 38 or 0)
        - (showRaidToolbar and 38 or 0)
    local showSyncProgress = self.raidSyncProgress
        and self.raidSyncProgress.active
        and showRaidToolbar
        and self.workspaceMode == "ASSIGNMENTS"
        and self.activeBossTab ~= "LOOT"
        and not self.raidPickerActive
        and not (self.settingsView and self.settingsView:IsShown())
        or false
    if self.raidSyncProgress then
        self.raidSyncProgress:ClearAllPoints()
        self.raidSyncProgress:SetPoint(
            "TOPLEFT", self.frame, "TOPLEFT", 1, contentTop)
        self.raidSyncProgress:SetPoint(
            "TOPRIGHT", self.frame, "TOPRIGHT", -1, contentTop)
        self.raidSyncProgress:SetShown(showSyncProgress)
    end
    if showSyncProgress then contentTop = contentTop - 24 end
    if self.settingsView then
        self.settingsView:ClearAllPoints()
        self.settingsView:SetPoint("TOPLEFT", 1, contentTop)
        self.settingsView:SetPoint("BOTTOMRIGHT", -1, 1)
    end
    local gearWorkspace = self.workspaceMode == "GEAR"
    if gearWorkspace then
        for _, button in ipairs(self.footerActionButtons or {}) do
            button:Hide()
        end
    end
    local previous
    for _, button in ipairs(self.footerLeftButtons or {}) do
        button:ClearAllPoints()
        if button:IsShown() then
            if previous then
                button:SetPoint("LEFT", previous, "RIGHT", 4, 0)
            else
                button:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 10, 14)
            end
            previous = button
        end
    end
    previous = nil
    for _, button in ipairs(self.footerRightButtons or {}) do
        button:ClearAllPoints()
        if button:IsShown() then
            if previous then
                button:SetPoint("RIGHT", previous, "LEFT", -4, 0)
            else
                button:SetPoint(
                    "BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -34, 14)
            end
            previous = button
        end
    end
    local hasFooter
    for _, button in ipairs(self.footerActionButtons or {}) do
        if button:IsShown() then
            hasFooter = true
            break
        end
    end
    if gearWorkspace then hasFooter = nil end
    local bottomInset = hasFooter and 58 or 1
    self.rosterPanel:ClearAllPoints()
    self.rosterPanel:SetPoint("TOPLEFT", 1, contentTop)
    self.rosterPanel:SetPoint("BOTTOMLEFT", 1, bottomInset)
    self.rosterPanel:SetWidth(self:GetRosterPanelWidth())

    local lootWorkspace = self.workspaceMode == "ASSIGNMENTS"
        and self.activeBossTab == "LOOT"
    local fullWidth = self.raidPickerActive
        or lootWorkspace
        or self.workspaceMode == "GROUPS"
        or self.workspaceMode == "STATUS"
        or self.workspaceMode == "GEAR"
        or self.workspaceMode == "ABOUT"
    self.assignmentPanel:ClearAllPoints()
    if fullWidth then
        self.assignmentPanel:SetPoint("TOPLEFT", 1, contentTop)
    else
        self.assignmentPanel:SetPoint(
            "TOPLEFT", self.rosterPanel, "TOPRIGHT", 0, 0)
    end
    self.assignmentPanel:SetPoint(
        "BOTTOMRIGHT", -1, bottomInset)
    self.assignmentPanel:SetBackdropColor(0, 0, 0, 0)
    self.assignmentPanel:SetBackdropBorderColor(0, 0, 0, 0)
    if self.assignmentPanel.InnerGlow then
        self.assignmentPanel.InnerGlow:Hide()
    end
    if self.assignmentPanel.TopLine then
        self.assignmentPanel.TopLine:Hide()
    end
    if self.assignmentPanel.Watermark then
        self.assignmentPanel.Watermark:Hide()
    end
    self.rosterPanel:SetBackdropColor(unpack(THEME.surface))
    self.rosterPanel:SetBackdropBorderColor(0, 0, 0, 0)
    if self.rosterPanel.InnerGlow then
        self.rosterPanel.InnerGlow:Hide()
    end
    if self.rosterPanel.TopLine then
        self.rosterPanel.TopLine:Hide()
    end
    if self.rosterPanel.Divider then
        self.rosterPanel.Divider:SetShown(not fullWidth)
    end

    if self.frame.DarkInset then
        self.frame.DarkInset:ClearAllPoints()
        self.frame.DarkInset:SetPoint("TOPLEFT", 1, contentTop)
        self.frame.DarkInset:SetPoint(
            "BOTTOMRIGHT", -1, hasFooter and 58 or 1)
    end
    if self.frame.StatusBg then
        self.frame.StatusBg:SetShown(hasFooter or false)
    end
end

function Raid:RefreshWorkspaceNavigation()
    local groups = self.workspaceMode == "GROUPS"
    local status = self.workspaceMode == "STATUS"
    local gear = self.workspaceMode == "GEAR"
    local about = self.workspaceMode == "ABOUT"
    local settings = self.workspaceMode == "SETTINGS"
    local picker = self.raidPickerActive
    local lootWorkspace = not picker
        and self.workspaceMode == "ASSIGNMENTS"
        and self.activeBossTab == "LOOT"
    local workspaceVisible = self.assignmentPanel
        and self.assignmentPanel:IsShown()
    local canEdit = self:IsLocalRaidEditor()
    local showRaidIdentity =
        not picker and not groups and not status and not gear
            and not about and not settings and not lootWorkspace
    if self.assignmentRaidIcon then
        self.assignmentRaidIcon:SetShown(showRaidIdentity)
    end
    if self.assignmentRaidTitle then
        self.assignmentRaidTitle:SetShown(showRaidIdentity)
    end
    if self.assignmentTitle then
        self.assignmentTitle:SetShown(showRaidIdentity)
    end
    if self.assignmentHint then
        self.assignmentHint:SetShown(showRaidIdentity)
    end
    if self.setCurrentBossButton then
        self.setCurrentBossButton:SetShown(
            showRaidIdentity and workspaceVisible and canEdit
                and self.db.activeEncounter > 1)
    end
    if not picker and self.frame and self.frame.Title then
        if groups then
            self.frame.Title:SetText(self.L.RAID_GROUPS)
            self.frame.Subtitle:SetText(
                self.L.ARRANGE_LIVE_RAID)
        elseif status then
            self.frame.Title:SetText(self.L.RAID_STATUS)
            self.frame.Subtitle:SetText(
                self.L.READINESS_BUFFS_CONSUMABLES)
        elseif gear then
            self.frame.Title:SetText(self.L.GEAR_INSPECT)
            self.frame.Subtitle:SetText(
                self.L.LIVE_RAID_EQUIPMENT)
        elseif about then
            self.frame.Title:SetText(self.L.ABOUT_LUNARAIDS)
            self.frame.Subtitle:SetText(
                self.L.PROJECT_CONTRIBUTORS_SUPPORT)
        elseif settings then
            self.frame.Title:SetText(self.L.SETTINGS)
            self.frame.Subtitle:SetText(
                self.L.INTERFACE_COMMUNICATION_ADMIN)
        else
            local raid = self:GetRaid()
            self.frame.Title:SetText("LUNA RAIDS")
            self.frame.Subtitle:SetText(
                raid.name:upper() .. "  ·  " .. self.L.ACTIVE_PLAN)
        end
    end
    for key, button in pairs(self.workspaceButtons or {}) do
        local selected = key == (
            status and "STATUS"
            or gear and "GEAR"
            or groups and "GROUPS"
            or about and "ABOUT"
            or settings and "SETTINGS"
            or "ASSIGNMENTS")
        button.baseColor = selected
            and { unpack(THEME.surfaceSelected) }
            or { unpack(THEME.content) }
        button.baseBorder = selected
            and { unpack(ACCENT) }
            or { 0, 0, 0, 0 }
        button:SetBackdropColor(unpack(button.baseColor))
        button:SetBackdropBorderColor(unpack(button.baseBorder))
        button.ActiveBar:Hide()
        button.Text:SetTextColor(
            selected and 1 or .70,
            selected and .86 or .67,
            selected and .40 or .57, 1)
        button.Icon:SetAlpha(selected and 1 or .72)
        button:SetEnabled(true)
        button:SetAlpha(1)
    end
    if self.bossRail then
        self.bossRail:SetShown(
            not picker and (not groups and not status and not gear
                and not about and not settings
                and not lootWorkspace
                and self.assignmentPanel
                and self.assignmentPanel:IsShown()))
    end
    for _, tab in pairs(self.bossTabs or {}) do
        tab:SetShown(
            not picker and not groups and not status and not gear
                and not about and not settings and not lootWorkspace)
    end
    for _, button in ipairs(self.assignmentActionButtons or {}) do
        button:SetShown(
            not picker
                and not groups and not status
                and not gear and not about and not settings
                and workspaceVisible
                and canEdit)
    end
    for index, button in ipairs(
        self.generalFooterActionButtons or {}) do
        button:SetShown(
            not picker
                and not groups
                and not status
                and not gear
                and not about
                and not settings
                and workspaceVisible
                and canEdit
                and (index ~= 1 or self:CanStartRaid()))
    end
    if self.raidGroupQuickActions then
        local hasGroupRoster = self:IsInGroupContext()
        self.raidGroupQuickActions:SetShown(
            not picker and groups and workspaceVisible
                and hasGroupRoster and not self:IsRaidReadOnly())
    end
    if self.raidStatusView and self.raidStatusView.ActionBar then
        local hasGroup = self:IsInGroupContext()
        self.raidStatusView.ActionBar:SetShown(
            not picker and status and workspaceVisible
                and hasGroup and not self:IsRaidReadOnly())
    end
    if self.assignmentScroll then
        local usesSharedScroll = not status and not gear and not about
        self.assignmentScroll:SetShown(
            usesSharedScroll and workspaceVisible and not picker)
        self.assignmentScroll:ClearAllPoints()
        self.assignmentScroll:SetPoint(
            "TOPLEFT", 6,
            (groups or lootWorkspace) and -8 or -84)
        self.assignmentScroll:SetPoint("BOTTOMRIGHT", -6, 8)
    end
    if self.raidStatusView then
        self.raidStatusView:ClearAllPoints()
        self.raidStatusView:SetPoint("TOPLEFT", 0, 0)
        self.raidStatusView:SetPoint("BOTTOMRIGHT", 0, 0)
    end
    if not picker and not groups and not status and not gear and not about
        and not lootWorkspace and self.LayoutAssignmentToolbar
    then
        self:LayoutAssignmentToolbar()
    end
    local showRoster =
        not picker and not groups and not status and not gear
            and not about and not settings and not lootWorkspace
            and workspaceVisible
    if self.rosterPanel then
        self.rosterPanel:SetShown(showRoster)
    end
    if self.rosterScroll then
        self.rosterScroll:SetShown(showRoster)
    end
    if self.RefreshRaidSyncProgressVisibility then
        self:RefreshRaidSyncProgressVisibility()
    end
    self:RefreshFooterLayout()
end

function Raid:CreateBossSettingsPanel()
    if self.bossSettingsPanel then return self.bossSettingsPanel end
    local panel = Panel(self.assignmentPanel)
    PixelSetSize(panel, 330, 180)
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(self.assignmentPanel:GetFrameLevel() + 20)
    panel:SetPoint(
        "TOPRIGHT", self.bossSettingsButton, "BOTTOMRIGHT", 0, -5)
    panel.Title = Font(panel, 11, "accent", L.BOSS_ASSIGNMENT_SETUP:upper())
    panel.Title:SetPoint("TOPLEFT", 10, -10)
    panel.AddCategory = Button(panel, "+ CATEGORY", 90, 23)
    panel.AddCategory:SetPoint("TOPRIGHT", -8, -6)
    panel.AddCategory:SetScript("OnClick", function()
        Raid:PromptAddBossCustomGroup()
    end)
    AddButtonTooltip(
        panel.AddCategory, "Add Assignment Category",
        "On the Raid-Wide Plan, include a marker name such as Moon, Star, Skull, or Cross to create a marked player duty.")
    panel.Rows = {}
    panel.PresetPrevious = Button(panel, "<", 27, 23)
    panel.PresetPrevious:SetPoint("TOPLEFT", 8, -31)
    panel.PresetPrevious:SetScript("OnClick", function()
        Raid:CycleBossPreset(-1)
    end)
    panel.PresetName = Button(panel, Raid.L.NO_SAVED_PRESETS, 252, 23)
    panel.PresetName:SetPoint(
        "LEFT", panel.PresetPrevious, "RIGHT", 4, 0)
    panel.PresetName:SetScript("OnClick", function()
        Raid:CycleBossPreset(1)
    end)
    panel.PresetNext = Button(panel, ">", 27, 23)
    panel.PresetNext:SetPoint("LEFT", panel.PresetName, "RIGHT", 4, 0)
    panel.PresetNext:SetScript("OnClick", function()
        Raid:CycleBossPreset(1)
    end)
    panel.Save = Button(panel, Raid.L.SAVE_NEW, 70, 24)
    StyleButton(panel.Save, "primary")
    panel.Save:SetPoint("BOTTOMLEFT", 8, 8)
    panel.Save:SetScript("OnClick", function()
        Raid:PromptSaveBossPreset()
    end)
    panel.Load = Button(panel, Raid.L.APPLY, 70, 24)
    StyleButton(panel.Load, "positive")
    panel.Load:SetPoint("LEFT", panel.Save, "RIGHT", 5, 0)
    panel.Load:SetScript("OnClick", function()
        Raid:LoadBossPreset()
        Raid:RefreshBossSettingsPanel()
    end)
    panel.Delete = Button(panel, Raid.L.DELETE, 70, 24)
    StyleButton(panel.Delete, "danger")
    panel.Delete:SetPoint("LEFT", panel.Load, "RIGHT", 5, 0)
    panel.Delete:SetScript("OnClick", function()
        Raid:PromptDeleteBossPreset()
    end)
    panel.Reset = Button(panel, Raid.L.DEFAULT, 82, 24)
    panel.Reset:SetPoint("LEFT", panel.Delete, "RIGHT", 5, 0)
    panel.Reset:SetScript("OnClick", function()
        Raid:ResetBossOverride()
        Raid:RefreshBossSettingsPanel()
    end)
    panel:Hide()
    self.bossSettingsPanel = panel
    return panel
end

function Raid:PromptSaveBossPreset()
    if StaticPopup_Show then
        local popup = StaticPopup_Show("LUNARAIDS_SAVE_BOSS_PRESET")
        local editBox = self:GetPopupEditBox(popup)
        if editBox then
            editBox:SetText(self:Localize(
                "ENCOUNTER_SETUP_NAME", self:GetEncounter().name))
            editBox:HighlightText()
        end
    else
        self:SaveBossPreset(self:GetEncounter().name .. " Setup")
    end
end

function Raid:PromptDeleteBossPreset()
    local preset = self:GetSelectedBossPreset()
    if not preset then return end
    self.pendingDeleteBossPresetID = preset.id
    if StaticPopup_Show then
        StaticPopup_Show(
            "LUNARAIDS_DELETE_BOSS_PRESET", preset.name, nil, preset.id)
    else
        self:DeleteBossPreset(preset.id)
    end
end

function Raid:PromptAddBossCustomGroup()
    if not StaticPopup_Show then return end
    local popup = StaticPopup_Show("LUNARAIDS_ADD_BOSS_CATEGORY")
    local editBox = self:GetPopupEditBox(popup)
    if editBox then editBox:SetText(""); editBox:SetFocus() end
end

function Raid:RefreshBossSettingsPanel()
    local panel = self:CreateBossSettingsPanel()
    if not panel:IsShown() then return end
    local raid, encounter = self:GetRaid(), self:GetEncounter()
    local presets = self:GetBossPresets()
    local selected = self:GetSelectedBossPreset()
    local hasPreset = selected ~= nil
    local setupTitle = encounter.name == "Raid Overview"
        and "RAID-WIDE ASSIGNMENT SETUP"
        or self.L.BOSS_ASSIGNMENT_SETUP:upper()
    panel.Title:SetText(setupTitle .. "  -  "
        .. #presets .. (#presets == 1 and " PRESET" or " PRESETS"))
    panel.PresetName.Text:SetText(
        selected and selected.name:upper() or self.L.NO_SAVED_PRESETS)
    panel.PresetPrevious:SetEnabled(#presets > 1)
    panel.PresetPrevious:SetAlpha(#presets > 1 and 1 or .42)
    panel.PresetNext:SetEnabled(#presets > 1)
    panel.PresetNext:SetAlpha(#presets > 1 and 1 or .42)
    panel.Load:SetEnabled(hasPreset)
    panel.Load:SetAlpha(hasPreset and 1 or .42)
    panel.Delete:SetEnabled(hasPreset)
    panel.Delete:SetAlpha(hasPreset and 1 or .42)
    local entries = {}
    if encounter.name ~= "Raid Overview" then
        entries[#entries + 1] = {
            label = self.L.HEALER_ASSIGNMENTS_TITLE,
            value = self:GetHealingSlotCount(),
            adjust = function(delta)
                Raid:SetBossHealerCount(
                    Raid:GetHealingSlotCount() + delta)
            end,
        }
    end
    for groupIndex, group in ipairs(self:GetEncounterGroups(encounter)) do
        if encounter.name == "Raid Overview" or group.name ~= "Healing" then
            local index = groupIndex
            entries[#entries + 1] = {
                label = group.name,
                value = #self:GetEncounterGroupSlots(index, encounter),
                adjust = function(delta)
                    Raid:SetBossGroupCount(
                        index,
                        #Raid:GetEncounterGroupSlots(index, encounter)
                            + delta)
                end,
                remove = group.custom and function()
                    Raid:RemoveBossCustomGroup(index)
                end or nil,
            }
        end
    end
    for index, entry in ipairs(entries) do
        local row = panel.Rows[index]
        if not row then
            row = CreateFrame("Frame", nil, panel)
            PixelSetSize(row, 310, 27)
            row.Label = Font(row, 10, "text", "")
            row.Label:SetPoint("LEFT", 3, 0)
            row.Label:SetWidth(185)
            row.Label:SetJustifyH("LEFT")
            row.Minus = Button(row, "-", 25, 23)
            row.Minus:SetPoint("RIGHT", -65, 0)
            row.Value = Font(row, 10, "accent", "0")
            row.Value:SetPoint("RIGHT", -34, 0)
            row.Value:SetWidth(28)
            row.Value:SetJustifyH("CENTER")
            row.Plus = Button(row, "+", 25, 23)
            row.Plus:SetPoint("RIGHT", -2, 0)
            row.Delete = Button(row, "x", 21, 21)
            row.Delete:SetPoint("RIGHT", row.Minus, "LEFT", -3, 0)
            panel.Rows[index] = row
        end
        row:SetPoint("TOPLEFT", 8, -65 - ((index - 1) * 29))
        row.Label:SetText(entry.label)
        row.Value:SetText(entry.value)
        row.adjust = entry.adjust
        row.Delete:SetShown(entry.remove ~= nil)
        row.Delete:SetScript("OnClick", entry.remove)
        row.Minus:SetScript("OnClick", function()
            row.adjust(-1)
            Raid:RefreshBossSettingsPanel()
        end)
        row.Plus:SetScript("OnClick", function()
            row.adjust(1)
            Raid:RefreshBossSettingsPanel()
        end)
        row:Show()
    end
    for index = #entries + 1, #panel.Rows do
        panel.Rows[index]:Hide()
    end
    panel:SetHeight(math.max(150, 105 + (#entries * 29)))
end

function Raid:ToggleBossSettings()
    local panel = self:CreateBossSettingsPanel()
    panel:SetShown(not panel:IsShown())
    self:RefreshBossSettingsPanel()
end

function Raid:RefreshBossTabs()
    if not self.bossTabs then return end
    local active = self.activeBossTab or "ASSIGNMENTS"
    for key, button in pairs(self.bossTabs) do
        local selected = key == active
        local hovered = not selected and button.IsMouseOver
            and button:IsMouseOver()
        local surface = selected and THEME.surfaceSelected
            or hovered and THEME.surfaceHover
            or THEME.surfaceAlt
        button:SetBackdropColor(
            unpack(surface))
        button.baseColor = { unpack(surface) }
        button.baseBorder = (selected or hovered)
            and { unpack(ACCENT) }
            or { 0, 0, 0, 0 }
        button:SetBackdropBorderColor(unpack(button.baseBorder))
        button.Text:SetTextColor(
            (selected or hovered) and ACCENT[1] or THEME.text[1],
            (selected or hovered) and ACCENT[2] or THEME.text[2],
            (selected or hovered) and ACCENT[3] or THEME.text[3], 1)
        button.ActiveLine:SetShown(selected)
    end
end

function Raid:GetMechanicsGuide()
    local encounter = self:GetEncounter()
    return encounter and encounter.mechanics
end

function Raid:RefreshMechanics()
    local encounter = self:GetEncounter()
    self.mechanicLines = self.mechanicLines or {}
    local guide = self:GetMechanicsGuide()
    local lines = {}
    if encounter.name == "Raid Overview" then
        lines = {
            "This page is shared across the whole raid, including trash and transitions.",
            "Use Markers to define standard trash kill, control, interrupt, and off-tank marks.",
            "Use Assignments for recurring duties; add custom categories from the setup cog.",
        }
    elseif guide then
        for _, line in ipairs(guide) do
            lines[#lines + 1] = line
        end
    else
        lines[#lines + 1] =
            "Confirm positioning, pull order, and phase transitions before the pull."
        for groupIndex, group in ipairs(self:GetEncounterGroups(encounter)) do
            if group.name ~= "Healing" then
                local labels = {}
                for _, slot in ipairs(
                    self:GetEncounterGroupSlots(groupIndex, encounter)) do
                    labels[#labels + 1] = self:GetSlotLabel(slot)
                end
                lines[#lines + 1] = group.name .. ": "
                    .. table.concat(labels, ", ") .. "."
            end
        end
        lines[#lines + 1] =
            "This encounter has assignment guidance; a detailed mechanic guide is still being authored."
    end
    local y = 4
    for index, text in ipairs(lines) do
        local line = self.mechanicLines[index]
        if not line then
            line = BackdropFrame("Frame", nil, self.assignmentContent)
            line:SetWidth(
                self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH)
            line:SetBackdrop({ bgFile = WHITE })
            line:SetBackdropColor(unpack(THEME.surface))
            line.Number = Font(line, 14, "accent", "")
            line.Number:SetPoint("TOPLEFT", 10, -10)
            line.Text = Font(line, 10, "text", "")
            line.Text:SetPoint("TOPLEFT", 42, -10)
            line.Text:SetPoint("RIGHT", -12, 0)
            line.Text:SetJustifyH("LEFT")
            line.Text:SetJustifyV("TOP")
            self.mechanicLines[index] = line
        end
        line:ClearAllPoints()
        line:SetPoint("TOPLEFT", 0, -y)
        line.Number:SetText(index)
        line.Text:SetText(text)
        line.Text:SetWidth(
            (self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH) - 56)
        local height = math.max(48, line.Text:GetStringHeight() + 22)
        line:SetHeight(height)
        line:Show()
        y = y + height + 7
    end
    for index = #lines + 1, #self.mechanicLines do
        self.mechanicLines[index]:Hide()
    end
    self.assignmentContent:SetHeight(math.max(1, y))
    self.assignmentTitle:SetText(
        (encounter.name == "Raid Overview"
            and "RAID-WIDE PLAN" or encounter.name:upper())
        .. "  " .. self.L.QUICK_GUIDE)
end

function Raid:CreateRaidGroupFrame(groupIndex)
    self.raidGroupFrames = self.raidGroupFrames or {}
    local group = BackdropFrame("Frame", nil, self.assignmentContent)
    group:SetBackdrop({
        bgFile = WHITE,
        edgeFile = WHITE,
        edgeSize = Pixel(1),
    })
    InstallPixelBorder(group)
    group:SetBackdropColor(unpack(THEME.content))
    group:SetBackdropBorderColor(0, 0, 0, 0)
    group.GroupIndex = groupIndex
    group.HeaderBg = group:CreateTexture(nil, "BACKGROUND")
    group.HeaderBg:SetTexture(WHITE)
    group.HeaderBg:SetPoint("TOPLEFT", 0, 0)
    group.HeaderBg:SetPoint("TOPRIGHT", 0, 0)
    group.HeaderBg:SetHeight(28)
    group.HeaderBg:SetVertexColor(unpack(THEME.header))
    group.Accent = group:CreateTexture(nil, "ARTWORK")
    group.Accent:SetTexture(WHITE)
    group.Accent:SetPoint("TOPLEFT", 0, 0)
    group.Accent:SetPoint("BOTTOMLEFT", group.HeaderBg, "BOTTOMLEFT", 0, 0)
    SetPixelWidth(group.Accent, 2)
    group.Accent:SetVertexColor(unpack(THEME.accent))
    group.HeaderLine = group:CreateTexture(nil, "ARTWORK")
    group.HeaderLine:SetTexture(WHITE)
    group.HeaderLine:SetPoint(
        "BOTTOMLEFT", group.HeaderBg, "BOTTOMLEFT", 0, 0)
    group.HeaderLine:SetPoint(
        "BOTTOMRIGHT", group.HeaderBg, "BOTTOMRIGHT", 0, 0)
    SetPixelHeight(group.HeaderLine, 1)
    group.HeaderLine:SetVertexColor(unpack(THEME.divider))
    group.Divider = group:CreateTexture(nil, "BACKGROUND")
    group.Divider:SetTexture(WHITE)
    group.Divider:SetPoint("TOPRIGHT", 0, 0)
    group.Divider:SetPoint("BOTTOMRIGHT", 0, 0)
    SetPixelWidth(group.Divider, 1)
    group.Divider:SetVertexColor(unpack(THEME.borderSoft))
    group.Title = Font(group, 10, "text",
        Raid:Localize("GROUP_NUMBER", groupIndex))
    group.Title:SetPoint("LEFT", group.HeaderBg, "LEFT", 10, 0)
    group.Count = Font(group, 9, "muted", "0/5")
    group.Count:SetPoint("RIGHT", group.HeaderBg, "RIGHT", -9, 0)
    group.Slots = {}
    local slotY = 28
    for slotIndex = 1, 5 do
        local slot = Button(group, "", 140, 29)
        UseRowSeparator(slot)
        slot.baseBorder = { unpack(ROW_SEPARATOR) }
        slot:SetBackdropBorderColor(unpack(slot.baseBorder))
        slot:SetPoint("TOPLEFT", 0, -slotY)
        slot:SetPoint("TOPRIGHT", 0, -slotY)
        slotY = slotY + slot:GetHeight()
        slot.Text:ClearAllPoints()
        slot.Text:SetPoint("LEFT", 17, 0)
        slot.Text:SetPoint("RIGHT", -76, 0)
        slot.Text:SetJustifyH("LEFT")
        slot.Status = Font(slot, 8, "muted", "")
        slot.Status:SetPoint("RIGHT", -28, 0)
        slot.Status:SetWidth(48)
        slot.Status:SetJustifyH("RIGHT")
        slot.ClassDot = slot:CreateTexture(nil, "OVERLAY")
        slot.ClassDot:SetTexture(WHITE)
        PixelSetSize(slot.ClassDot, 3, 17)
        slot.ClassDot:SetPoint("LEFT", 7, 0)
        slot.Role = slot:CreateTexture(nil, "ARTWORK")
        slot.Role:SetTexture(ROLE_TEXTURE)
        PixelSetSize(slot.Role, 16, 16)
        slot.Role:SetPoint("RIGHT", -7, 0)
        slot.Leader = slot:CreateTexture(nil, "ARTWORK")
        slot.Leader:SetTexture(
            "Interface\\GroupFrame\\UI-Group-LeaderIcon")
        PixelSetSize(slot.Leader, 14, 14)
        slot.Assistant = slot:CreateTexture(nil, "ARTWORK")
        slot.Assistant:SetTexture(
            "Interface\\GroupFrame\\UI-Group-AssistantIcon")
        PixelSetSize(slot.Assistant, 14, 14)
        slot.MasterLooter = slot:CreateTexture(nil, "ARTWORK")
        slot.MasterLooter:SetTexture(
            "Interface\\GroupFrame\\UI-Group-MasterLooter")
        PixelSetSize(slot.MasterLooter, 14, 14)
        slot.MainTank = slot:CreateTexture(nil, "ARTWORK")
        slot.MainTank:SetTexture(
            "Interface\\GroupFrame\\UI-Group-MainTankIcon")
        PixelSetSize(slot.MainTank, 14, 14)
        slot.MainAssist = slot:CreateTexture(nil, "ARTWORK")
        slot.MainAssist:SetTexture(
            "Interface\\GroupFrame\\UI-Group-MainAssistIcon")
        PixelSetSize(slot.MainAssist, 14, 14)
        slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slot:RegisterForDrag("LeftButton")
        slot:SetScript("OnClick", function(self, mouseButton)
            if mouseButton == "RightButton" and self.player then
                Raid:ShowRaidPlayerMenu(self.player, self)
                return
            end
            if not Raid:CanEditRaidGroups() then return end
            if Raid.selectedPlayer
                and Raid.selectedPlayer ~= self.player
            then
                Raid:MoveRosterPlayer(
                    Raid.selectedPlayer, groupIndex, self.player)
            elseif self.player then
                Raid.selectedPlayer = self.player
                Raid:RefreshRoster()
                Raid:RefreshAssignments()
            end
        end)
        slot:SetScript("OnDragStart", function(self)
            if not Raid:CanEditRaidGroups() or not self.player then return end
            Raid.dragPlayer = self.player
            Raid.selectedPlayer = self.player
            Raid:ShowDragGhost(self.player)
        end)
        slot:SetScript("OnReceiveDrag", function(self)
            local player = Raid.dragPlayer or Raid.selectedPlayer
            if player and player ~= self.player then
                Raid:MoveRosterPlayer(player, groupIndex, self.player)
            end
            Raid:HideDragGhost()
            Raid.dragPlayer = nil
            ResetCursor()
        end)
        slot:SetScript("OnDragStop", function()
            Raid:HideDragGhost()
            Raid.dragPlayer = nil
            ResetCursor()
        end)
        slot:SetScript("OnEnter", function(self)
            self:SetBackdropColor(unpack(THEME.surfaceHover))
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self.player then
                GameTooltip:SetText(self.player.name)
                if self.player.leader then
                    GameTooltip:AddLine(Raid.L.RAID_LEADER, .95, .78, .25)
                elseif self.player.assistant then
                    GameTooltip:AddLine(
                        Raid.L.RAID_ASSISTANT,
                        ACCENT[1], ACCENT[2], ACCENT[3])
                end
                if self.player.masterLooter then
                    GameTooltip:AddLine(
                        MASTER_LOOTER or "Master Looter",
                        ACCENT[1], ACCENT[2], ACCENT[3])
                end
                if self.player.raidAssignment == "MAINTANK" then
                    GameTooltip:AddLine(Raid.L.MAIN_TANK, .35, .75, 1)
                elseif self.player.raidAssignment == "MAINASSIST" then
                    GameTooltip:AddLine(Raid.L.MAIN_ASSIST, .35, .75, 1)
                end
                GameTooltip:AddLine(
                    "Drag onto another player to swap groups.",
                    MUTED[1], MUTED[2], MUTED[3], true)
                GameTooltip:AddLine(
                    "Right-click for player actions.",
                    MUTED[1], MUTED[2], MUTED[3], true)
            else
                GameTooltip:SetText(Raid.L.EMPTY_GROUP_POSITION)
                GameTooltip:AddLine(
                    "Drop a player here to move them into this group.",
                    MUTED[1], MUTED[2], MUTED[3], true)
            end
            GameTooltip:Show()
        end)
        slot:SetScript("OnLeave", function(self)
            self:SetBackdropColor(unpack(self.baseColor))
            GameTooltip:Hide()
        end)
        group.Slots[slotIndex] = slot
    end
    PixelSetSize(group, 160, slotY)
    group.Outline = BackdropFrame("Frame", nil, group)
    group.Outline:SetAllPoints()
    group.Outline:SetBackdrop({
        edgeFile = WHITE,
        edgeSize = Pixel(1),
    })
    InstallPixelBorder(group.Outline)
    group.Outline:SetBackdropBorderColor(unpack(THEME.divider))
    group.Outline:SetFrameLevel(group:GetFrameLevel() + 50)
    group.Outline:EnableMouse(false)
    self.raidGroupFrames[groupIndex] = group
    return group
end

function Raid:CreateRaidGroupQuickActions()
    if self.raidGroupQuickActions then
        return self.raidGroupQuickActions
    end
    local panel = CreateFrame("Frame", nil, self.frame)
    panel:SetPoint("BOTTOMLEFT", 12, 8)
    panel:SetPoint("BOTTOMRIGHT", -24, 8)
    panel:SetHeight(40)
    panel:SetFrameLevel(self.frame:GetFrameLevel() + 8)
    local actions = {
        {
            label = self.L.ACTION_READY_CHECK,
            icon = ICONS.READY,
            title = self.L.READY_CHECK,
            detail = self.L.READY_CHECK_DESC,
            action = function() Raid:StartReadyCheck() end,
            rightAction = function()
                Raid:ShowPinnedReadyCheckWindow()
            end,
        },
        {
            label = self.L.ACTION_ROLE_CHECK,
            icon = ICONS.ROLES,
            title = self.L.ROLE_CHECK,
            detail = self.L.ROLE_CHECK_DESC,
            action = function() Raid:StartRoleCheck() end,
        },
        {
            label = self.L.ACTION_PULL_10,
            icon = ICONS.COOLDOWNS,
            title = self.L.PULL_TIMER,
            detail = self.L.PULL_TIMER_DESC,
            action = function() Raid:StartPullCountdown(10) end,
        },
        {
            label = self.L.ACTION_BREAK_5,
            icon = ICONS.BREAK,
            title = self.L.BREAK_TIMER,
            detail = self.L.BREAK_TIMER_DESC,
            action = function() Raid:StartBreakTimer(5) end,
            rightAction = function(button)
                ShowSelectionMenu(
                    button,
                    {
                        { 5, self.L.MINUTES_5 },
                        { 10, self.L.MINUTES_10 },
                        { 15, self.L.MINUTES_15 },
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
    }
    panel.Actions = {}
    local previous
    for index, entry in ipairs(actions) do
        local action, rightAction = entry.action, entry.rightAction
        local button = Button(panel, entry.label, 126, 28)
        if previous then
            button:SetPoint("LEFT", previous, "RIGHT", 5, 0)
        else
            button:SetPoint("LEFT", 0, 0)
        end
        AddButtonIcon(button, entry.icon, 16)
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:SetScript("OnClick", function(_, mouseButton)
            if not Raid:IsLocalRaidEditor() then return end
            if mouseButton == "RightButton" and rightAction then
                rightAction(button)
            else
                action()
            end
        end)
        AddButtonTooltip(
            button, entry.title,
            entry.detail .. (rightAction
                and (entry.rightDetail
                    or "\nRight-click to pin the latest results.")
                or ""))
        StyleButton(button, "default")
        panel.Actions[index] = button
        previous = button
    end
    for _, button in ipairs(panel.Actions) do
        self.footerActionButtons[#self.footerActionButtons + 1] = button
    end
    panel:Hide()
    self.raidGroupQuickActions = panel
    return panel
end

function Raid:RefreshRaidGroups()
    self.raidGroupFrames = self.raidGroupFrames or {}
    local quickActions = self:CreateRaidGroupQuickActions()
    if not self:IsInGroupContext() then
        quickActions:Hide()
        for _, group in ipairs(self.raidGroupFrames) do
            group:Hide()
        end
        if not self.raidGroupsEmptyState then
            self.raidGroupsEmptyState = Font(
                self.assignmentContent, 15, "muted",
                "Not in a raid group")
            self.raidGroupsEmptyState:SetPoint(
                "TOP", self.assignmentContent, "TOP", 0, -145)
        end
        self.raidGroupsEmptyState:Show()
        self.assignmentContent:SetHeight(330)
        self.assignmentTitle:SetText(self.L.RAID_GROUPS)
        self:RefreshFooterLayout()
        return
    end
    if self.raidGroupsEmptyState then
        self.raidGroupsEmptyState:Hide()
    end
    local grouped = {}
    for groupIndex = 1, 8 do grouped[groupIndex] = {} end
    for _, player in ipairs(self.roster or {}) do
        local groupIndex = math.max(
            1, math.min(8, tonumber(player.subgroup) or 1))
        grouped[groupIndex][#grouped[groupIndex] + 1] = player
    end
    local rowWidth = self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH
    local canEdit = self:IsLocalRaidEditor()
    for _, button in ipairs(quickActions.Actions) do
        button:SetEnabled(canEdit)
        button:SetAlpha(canEdit and 1 or .4)
    end
    quickActions:Show()
    local gap = 8
    local cardWidth = math.floor((rowWidth - (gap * 3)) / 4)
    for groupIndex = 1, 8 do
        local group = self.raidGroupFrames[groupIndex]
            or self:CreateRaidGroupFrame(groupIndex)
        local column = (groupIndex - 1) % 4
        local row = math.floor((groupIndex - 1) / 4)
        group:ClearAllPoints()
        local groupStride = group:GetHeight() + gap
        group:SetPoint(
            "TOPLEFT",
            column * (cardWidth + gap),
            -(row * groupStride))
        group:SetWidth(cardWidth)
        group.Count:SetText(
            ("%d/5"):format(#grouped[groupIndex]))
        for slotIndex, slot in ipairs(group.Slots) do
            local player = grouped[groupIndex][slotIndex]
            slot.player = player
            if player then
                SetClassText(slot.Text, player.name, player.class)
                local unavailable = player.online == false
                slot.Status:SetText(
                    unavailable
                        and (player.manual and "PLANNED" or "OFFLINE")
                        or "")
                slot.Status:SetTextColor(
                    unavailable and 1 or MUTED[1],
                    unavailable and .32 or MUTED[2],
                    unavailable and .32 or MUTED[3],
                    1)
                local color = player.class and RAID_CLASS_COLORS
                    and RAID_CLASS_COLORS[player.class]
                slot.ClassDot:SetVertexColor(
                    color and color.r or .55,
                    color and color.g or .62,
                    color and color.b or .69, 1)
                slot.ClassDot:Show()
                local roleCoords = ROLE_COORDS[player.role]
                if roleCoords then
                    slot.Role:SetTexCoord(unpack(roleCoords))
                    slot.Role:Show()
                else
                    slot.Role:Hide()
                end
                slot.Leader:SetShown(player.leader or false)
                slot.Assistant:SetShown(
                    not player.leader and player.assistant or false)
                slot.MasterLooter:SetShown(player.masterLooter or false)
                slot.MainTank:SetShown(
                    player.raidAssignment == "MAINTANK")
                slot.MainAssist:SetShown(
                    player.raidAssignment == "MAINASSIST")
                local rightOffset = -7
                for _, icon in ipairs({
                    slot.Role, slot.MainTank, slot.MainAssist,
                    slot.Leader, slot.Assistant, slot.MasterLooter,
                }) do
                    icon:ClearAllPoints()
                    if icon:IsShown() then
                        icon:SetPoint("RIGHT", slot, "RIGHT", rightOffset, 0)
                        rightOffset = rightOffset - 22
                    end
                end
                slot.Status:ClearAllPoints()
                slot.Status:SetShown(unavailable)
                if unavailable then
                    slot.Status:SetPoint(
                        "RIGHT", slot, "RIGHT", rightOffset, 0)
                    rightOffset = rightOffset - 58
                end
                slot.Text:ClearAllPoints()
                slot.Text:SetPoint("LEFT", 17, 0)
                slot.Text:SetPoint(
                    "RIGHT", slot, "RIGHT", rightOffset - 5, 0)
                slot.baseColor = { unpack(THEME.surfaceAlt) }
                slot:SetAlpha(
                    unavailable and (player.manual and .72 or .48) or 1)
            else
                slot.Text:SetText(self.L.EMPTY)
                slot.Text:SetTextColor(unpack(MUTED))
                slot.ClassDot:Hide()
                slot.Role:Hide()
                slot.Leader:Hide()
                slot.Assistant:Hide()
                slot.MasterLooter:Hide()
                slot.MainTank:Hide()
                slot.MainAssist:Hide()
                slot.Status:SetText("")
                slot.Status:Hide()
                slot.Text:ClearAllPoints()
                slot.Text:SetPoint("LEFT", 17, 0)
                slot.Text:SetPoint("RIGHT", -7, 0)
                slot.baseColor = { unpack(THEME.content) }
                slot:SetAlpha(1)
            end
            slot.baseBorder = { unpack(ROW_SEPARATOR) }
            slot:SetBackdropColor(unpack(slot.baseColor))
            slot:SetBackdropBorderColor(unpack(slot.baseBorder))
        end
        group:Show()
    end
    local groupHeight = self.raidGroupFrames[1]
        and self.raidGroupFrames[1]:GetHeight() or 0
    self.assignmentContent:SetHeight(math.max(
        1, (groupHeight * 2) + gap))
    self.assignmentTitle:SetText(self.L.RAID_GROUP_EDITOR)
    self:RefreshFooterLayout()
end

