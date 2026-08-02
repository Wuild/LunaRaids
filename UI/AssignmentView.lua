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
local ROW_SEPARATOR = { .085, .105, .12, 1 }
local FILLED_ROW_SEPARATOR = { .09, .18, .16, 1 }
local SetMarkerTexture = UI.SetMarkerTexture

function Raid:RefreshAssignments()
    if self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
    if self.raidPickerActive then return end
    if self.RefreshRaidIdentityHeader then
        self:RefreshRaidIdentityHeader()
    end
    if not self.assignmentContent then return end
    local encounter = self:GetEncounter()
    local activeTab = self.workspaceMode == "STATUS"
        and "STATUS"
        or self.workspaceMode == "GEAR" and "GEAR"
        or self.workspaceMode == "GROUPS" and "GROUPS"
        or self.workspaceMode == "ABOUT" and "ABOUT"
        or self.activeBossTab or "ASSIGNMENTS"
    if self.bossSettingsButton then
        self.bossSettingsButton:SetShown(
            activeTab ~= "GROUPS"
                and activeTab ~= "STATUS"
                and activeTab ~= "GEAR"
                and activeTab ~= "ABOUT")
        if (activeTab == "GROUPS"
            or activeTab == "STATUS"
            or activeTab == "GEAR"
            or activeTab == "ABOUT")
            and self.bossSettingsPanel
        then
            self.bossSettingsPanel:Hide()
        elseif self.bossSettingsPanel
            and self.bossSettingsPanel:IsShown()
        then
            self:RefreshBossSettingsPanel()
        end
    end
    self.assignmentSlots = self.assignmentSlots or {}
    self.groupHeaders = self.groupHeaders or {}
    self.markerRows = self.markerRows or {}
    self:RefreshBossTabs()
    if self.mechanicLines then
        for _, line in ipairs(self.mechanicLines) do line:Hide() end
    end
    if activeTab ~= "GROUPS" then
        if self.raidGroupQuickActions then
            self.raidGroupQuickActions:Hide()
        end
        if self.raidGroupsEmptyState then
            self.raidGroupsEmptyState:Hide()
        end
        for _, group in ipairs(self.raidGroupFrames or {}) do
            group:Hide()
        end
    end
    if activeTab ~= "STATUS" and self.raidStatusView then
        self.raidStatusView:Hide()
    end
    if activeTab ~= "GEAR" and self.gearInspectView then
        self.gearInspectView:Hide()
    end
    if activeTab ~= "ABOUT" and self.aboutView then
        self.aboutView:Hide()
    end
    if activeTab == "ABOUT" then
        for _, slot in ipairs(self.assignmentSlots) do slot:Hide() end
        for _, header in ipairs(self.groupHeaders) do header:Hide() end
        for _, row in ipairs(self.markerRows) do row:Hide() end
        if self.autoAssignButton then self.autoAssignButton:Hide() end
        if self.assignmentPanel
            and self.assignmentPanel.ProgressTrack
        then
            self.assignmentPanel.ProgressTrack:Hide()
            self.assignmentPanel.ProgressFill:Hide()
        end
        self:RefreshAboutView()
        return
    end
    if activeTab == "GEAR" then
        for _, slot in ipairs(self.assignmentSlots) do slot:Hide() end
        for _, header in ipairs(self.groupHeaders) do header:Hide() end
        for _, row in ipairs(self.markerRows) do row:Hide() end
        if self.autoAssignButton then self.autoAssignButton:Hide() end
        if self.assignmentPanel
            and self.assignmentPanel.ProgressTrack
        then
            self.assignmentPanel.ProgressTrack:Hide()
            self.assignmentPanel.ProgressFill:Hide()
        end
        self:RefreshGearInspectView()
        return
    end
    if activeTab == "STATUS" then
        for _, slot in ipairs(self.assignmentSlots) do slot:Hide() end
        for _, header in ipairs(self.groupHeaders) do header:Hide() end
        for _, row in ipairs(self.markerRows) do row:Hide() end
        if self.autoAssignButton then self.autoAssignButton:Hide() end
        if self.assignmentPanel
            and self.assignmentPanel.ProgressTrack
        then
            self.assignmentPanel.ProgressTrack:Hide()
            self.assignmentPanel.ProgressFill:Hide()
        end
        self:RefreshRaidStatusView()
        return
    end
    if activeTab == "GROUPS" then
        for _, slot in ipairs(self.assignmentSlots) do slot:Hide() end
        for _, header in ipairs(self.groupHeaders) do header:Hide() end
        for _, row in ipairs(self.markerRows) do row:Hide() end
        if self.autoAssignButton then self.autoAssignButton:Hide() end
        if self.assignmentPanel
            and self.assignmentPanel.ProgressTrack
        then
            self.assignmentPanel.ProgressTrack:Hide()
            self.assignmentPanel.ProgressFill:Hide()
        end
        self:RefreshRaidGroups()
        return
    end
    if activeTab == "MECHANICS" then
        for _, slot in ipairs(self.assignmentSlots) do slot:Hide() end
        for _, header in ipairs(self.groupHeaders) do header:Hide() end
        for _, row in ipairs(self.markerRows) do row:Hide() end
        if self.autoAssignButton then self.autoAssignButton:Hide() end
        if self.assignmentPanel
            and self.assignmentPanel.ProgressTrack
        then
            self.assignmentPanel.ProgressTrack:Hide()
            self.assignmentPanel.ProgressFill:Hide()
        end
        self:RefreshMechanics()
        return
    end
    local slotNumber, groupNumber, y = 0, 0, 0
    local filledSlots, totalSlots = 0, 0
    local encounterTargets = self:GetEncounterTargets()
    if activeTab == "ASSIGNMENTS" then
        if not self.autoAssignButton then
            self.autoAssignButton =
                Button(self.assignmentContent, L.AUTO_ASSIGN, 132, 25)
            AddButtonIcon(
                self.autoAssignButton,
                "Interface\\Icons\\Spell_Holy_MindVision")
            self.autoAssignButton:SetScript(
                "OnClick", function() Raid:AutoAssignEncounter() end)
            StyleButton(self.autoAssignButton, "default")
            self.autoAssignButton:HookScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L.SMART_AUTO_ASSIGN)
                GameTooltip:AddLine(
                    "Fills empty slots using raid roles, class utility, "
                    .. "and GearScore. Existing assignments are kept.",
                    MUTED[1], MUTED[2], MUTED[3], true)
                GameTooltip:Show()
            end)
            self.autoAssignButton:HookScript(
                "OnLeave", function() GameTooltip:Hide() end)
        end
        self.autoAssignButton:ClearAllPoints()
        self.autoAssignButton:SetPoint("TOPRIGHT", -8, -y - 2)
        if self:IsLocalRaidEditor() then
            self.autoAssignButton:Show()
            y = y + 34
        else
            self.autoAssignButton:Hide()
        end
    elseif self.autoAssignButton then
        self.autoAssignButton:Hide()
    end
    if activeTab == "MARKERS" and #encounterTargets > 0 then
        groupNumber = groupNumber + 1
        local markerHeader = self.groupHeaders[groupNumber]
        if not markerHeader then
            markerHeader = Font(
                self.assignmentContent, 10, "accent", "")
            self.groupHeaders[groupNumber] = markerHeader
        end
        markerHeader:ClearAllPoints()
        markerHeader:SetPoint("TOPLEFT", 2, -y)
        markerHeader:SetText(
            encounter.name == "Raid Overview"
                and "TRASH MARKING ROLES" or L.BOSSES_ADDS)
        markerHeader:Show()
        y = y + 29
        for targetIndex, targetName in ipairs(encounterTargets) do
            local row = self.markerRows[targetIndex]
            if not row then
                row = self:CreateMarkerRow(targetIndex)
                self.markerRows[targetIndex] = row
            end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, -y)
            row.targetIndex = targetIndex
            row.Label:SetText(targetName)
            local markerIndex =
                self:GetMarkerAssignment(targetIndex)
            local marker = markerIndex and self.markers[markerIndex]
            SetMarkerTexture(row.MarkerIcon, markerIndex)
            row.MarkerText:SetText(
                marker and marker.name or "No marker")
            if marker then
                row.MarkerText:SetTextColor(1, 1, 1, 1)
            else
                row.MarkerText:SetTextColor(unpack(MUTED))
            end
            row:Show()
            y = y + row:GetHeight()
        end
        y = y + 12
    end
    for index = #encounterTargets + 1, #self.markerRows do
        self.markerRows[index]:Hide()
    end
    if activeTab ~= "MARKERS" then
        for _, row in ipairs(self.markerRows) do row:Hide() end
    end
    local visibleGroups = {}
    for groupIndex, group in ipairs(self:GetEncounterGroups(encounter)) do
        if encounter.name == "Raid Overview"
            or group.name ~= "Healing"
        then
            visibleGroups[#visibleGroups + 1] = {
                index = groupIndex, group = group,
            }
        end
    end
    if encounter.name == "Raid Overview" then
        local groupOrder = {
            Tanks = 1, Healing = 2, Damage = 3,
        }
        table.sort(visibleGroups, function(left, right)
            local leftOrder = groupOrder[left.group.name] or 10
            local rightOrder = groupOrder[right.group.name] or 10
            if leftOrder ~= rightOrder then
                return leftOrder < rightOrder
            end
            return left.index < right.index
        end)
    end
    if activeTab == "ASSIGNMENTS" then
    for _, entry in ipairs(visibleGroups) do
        local groupIndex, group = entry.index, entry.group
        groupNumber = groupNumber + 1
        local header = self.groupHeaders[groupNumber]
        if not header then
            header = Font(self.assignmentContent, 11, "text", "")
            self.groupHeaders[groupNumber] = header
        end
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", 4, -y)
        header:SetText(group.name:upper())
        header:SetTextColor(.72, .78, .82, 1)
        header:Show()
        y = y + 29
        for slotIndex, assignmentSlot in ipairs(
            self:GetEncounterGroupSlots(groupIndex, encounter)) do
            slotNumber = slotNumber + 1
            local slot = self.assignmentSlots[slotNumber]
            if not slot then
                slot = self:CreateAssignmentSlot(slotNumber)
                self.assignmentSlots[slotNumber] = slot
            end
            slot:ClearAllPoints()
            slot:SetPoint("TOPLEFT", 0, -y)
            slot.groupIndex, slot.slotIndex = groupIndex, slotIndex
            slot.healingSlotIndex = nil
            slot.assignmentDefinition = assignmentSlot
            slot.HealingTarget:Hide()
            slot.Label:Show()
            local assignmentLabel = self:GetSlotLabel(assignmentSlot)
            local assignmentRole =
                assignmentSlot.role or group.role
            local markerToken = self:GetMarkerTokenForText(
                assignmentLabel, assignmentRole == self.Role.TANK)
            if markerToken ~= "" then
                assignmentLabel = assignmentLabel .. " "
                    .. self:FormatMarkerTokensForLocalDisplay(markerToken)
            end
            slot.Label:SetText(assignmentLabel)
            local roleCoords = ROLE_COORDS[
                assignmentSlot.role or group.role]
            if roleCoords then
                slot.RoleIcon:SetTexCoord(unpack(roleCoords))
                slot.RoleIcon:Show()
            else
                slot.RoleIcon:Hide()
            end
            local assignment = self:GetAssignment(groupIndex, slotIndex)
            totalSlots = totalSlots + 1
            if assignment then
                filledSlots = filledSlots + 1
                SetClassText(slot.Player, assignment.name, assignment.class)
                slot.FilledBar:Show()
                slot.baseColor = { .035, .105, .095, .98 }
                slot.baseBorder = { unpack(FILLED_ROW_SEPARATOR) }
            else
                slot.Player:SetText(L.DROP_OR_CLICK_SUGGEST)
                slot.Player:SetTextColor(unpack(MUTED))
                slot.FilledBar:Hide()
                slot.baseColor = { .038, .055, .075, .96 }
                slot.baseBorder = { unpack(ROW_SEPARATOR) }
            end
            slot:SetBackdropColor(unpack(slot.baseColor))
            slot:SetBackdropBorderColor(unpack(slot.baseBorder))
            slot.HealingTarget.baseColor = slot.baseColor
            slot.HealingTarget:SetBackdropColor(
                unpack(slot.baseColor))
            slot:Show()
            y = y + slot:GetHeight()
        end
        y = y + 12
    end
    if encounter.name ~= "Raid Overview" then
        groupNumber = groupNumber + 1
        local healingHeader = self.groupHeaders[groupNumber]
        if not healingHeader then
            healingHeader = Font(
                self.assignmentContent, 11, "text", "")
            self.groupHeaders[groupNumber] = healingHeader
        end
        healingHeader:ClearAllPoints()
        healingHeader:SetPoint("TOPLEFT", 4, -y)
        healingHeader:SetText(L.HEALER_ASSIGNMENTS)
        healingHeader:SetTextColor(.72, .78, .82, 1)
        healingHeader:Show()
        y = y + 29
        local healingTargets = self:GetHealingTargets()
        for healerIndex = 1, self:GetHealingSlotCount() do
            slotNumber = slotNumber + 1
            local slot = self.assignmentSlots[slotNumber]
            if not slot then
                slot = self:CreateAssignmentSlot(slotNumber)
                self.assignmentSlots[slotNumber] = slot
            end
            slot:ClearAllPoints()
            slot:SetPoint("TOPLEFT", 0, -y)
            slot.groupIndex = nil
            slot.slotIndex = healerIndex
            slot.healingSlotIndex = healerIndex
            local healingDefinition =
                self:GetHealingSlotDefinition(healerIndex)
            slot.assignmentDefinition = healingDefinition
            slot.Label:Hide()
            slot.HealingTarget:Show()
            slot.RoleIcon:SetTexCoord(unpack(ROLE_COORDS.HEALER))
            slot.RoleIcon:Show()
            local target = healingTargets[
                self:GetHealingTargetIndex(healerIndex)]
            local healingTargetLabel =
                self:GetHealingTargetLabel(target)
            local healingMarkerToken = healingTargetLabel ~= "Raid"
                and self:GetMarkerTokenForText(healingTargetLabel)
                or ""
            if healingMarkerToken ~= "" then
                healingTargetLabel = healingTargetLabel .. " "
                    .. self:FormatMarkerTokensForLocalDisplay(
                        healingMarkerToken)
            end
            slot.HealingTarget.Text:SetText(
                ("%s -> %s"):format(
                    healingDefinition and healingDefinition.label
                        or ("Healer " .. healerIndex),
                    healingTargetLabel))
            local assignment = self:GetHealingAssignment(healerIndex)
            totalSlots = totalSlots + 1
            if assignment then
                filledSlots = filledSlots + 1
                SetClassText(
                    slot.Player, assignment.name, assignment.class)
                slot.FilledBar:Show()
                slot.baseColor = { .035, .105, .095, .98 }
                slot.baseBorder = { unpack(FILLED_ROW_SEPARATOR) }
            else
                slot.Player:SetText(L.DROP_OR_CLICK_SUGGEST)
                slot.Player:SetTextColor(unpack(MUTED))
                slot.FilledBar:Hide()
                slot.baseColor = { .038, .055, .075, .96 }
                slot.baseBorder = { unpack(ROW_SEPARATOR) }
            end
            slot:SetBackdropColor(unpack(slot.baseColor))
            slot:SetBackdropBorderColor(unpack(slot.baseBorder))
            slot.HealingTarget.baseColor = slot.baseColor
            slot.HealingTarget:SetBackdropColor(
                unpack(slot.baseColor))
            slot:Show()
            y = y + slot:GetHeight()
        end
        y = y + 12
    end
    end

    if activeTab == "MARKERS" and #encounterTargets == 0 then
        groupNumber = groupNumber + 1
        local empty = self.groupHeaders[groupNumber]
        if not empty then
            empty = Font(self.assignmentContent, 10, "muted", "")
            self.groupHeaders[groupNumber] = empty
        end
        empty:ClearAllPoints()
        empty:SetPoint("TOPLEFT", 8, -12)
        empty:SetText(L.SELECT_BOSS_MARKERS)
        empty:Show()
        y = 42
    end

    for index = slotNumber + 1, #self.assignmentSlots do
        self.assignmentSlots[index]:Hide()
    end
    for index = groupNumber + 1, #self.groupHeaders do
        self.groupHeaders[index]:Hide()
    end
    self.assignmentContent:SetHeight(math.max(1, y))
    if self.assignmentTitle then
        if activeTab == "MARKERS" then
            self.assignmentTitle:SetText(
                encounter.name == "Raid Overview"
                    and "RAID-WIDE TRASH MARKERS"
                    or L.BOSS_ADD_MARKERS)
        else
            self.assignmentTitle:SetText(
                ("ASSIGNMENTS  %d/%d"):format(
                    filledSlots, totalSlots))
        end
    end
    if self.assignmentPanel
        and self.assignmentPanel.ProgressTrack
    then
        local showProgress =
            activeTab == "ASSIGNMENTS" and totalSlots > 0
        self.assignmentPanel.ProgressTrack:SetShown(showProgress)
        self.assignmentPanel.ProgressFill:SetShown(showProgress)
        if showProgress then
            self.assignmentPanel.ProgressFill:SetWidth(
                math.max(
                    1,
                    (self.assignmentRowWidth or ASSIGNMENT_ROW_WIDTH)
                        * filledSlots / totalSlots))
        end
    end
end

function Raid:CreateBossRailButton(index)
    local button = Button(
        self.bossRail, "", BOSS_BUTTON_SIZE, BOSS_BUTTON_SIZE)
    button.Icon = button:CreateTexture(nil, "ARTWORK")
    button.Icon:SetTexture("Interface\\Icons\\INV_Sword_27")
    button.Icon:SetPoint("TOPLEFT", 4, -4)
    button.Icon:SetPoint("BOTTOMRIGHT", -4, 4)
    button.Icon:SetTexCoord(.08, .92, .08, .92)
    button.ActiveBar = button:CreateTexture(nil, "OVERLAY")
    button.ActiveBar:SetTexture(WHITE)
    button.ActiveBar:SetPoint("TOPLEFT", 1, -1)
    button.ActiveBar:SetPoint("BOTTOMLEFT", 1, 1)
    SetPixelWidth(button.ActiveBar, 4)
    button.ActiveBar:SetVertexColor(unpack(ACCENT))
    button.SelectionGlow = button:CreateTexture(nil, "OVERLAY")
    button.SelectionGlow:SetTexture(WHITE)
    button.SelectionGlow:SetPoint("TOPLEFT", 2, -2)
    button.SelectionGlow:SetPoint("BOTTOMRIGHT", -2, 2)
    button.SelectionGlow:SetVertexColor(.30, .34, .38, .10)
    button.SelectionGlow:Hide()
    button.CurrentDot = button:CreateTexture(nil, "OVERLAY")
    button.CurrentDot:SetTexture(WHITE)
    PixelSetSize(button.CurrentDot, 7, 7)
    button.CurrentDot:SetPoint("TOPRIGHT", -3, -3)
    button.CurrentDot:SetVertexColor(.22, .9, .55, 1)
    button.CurrentDot:Hide()
    button.Text:Hide()
    button:SetScript("OnClick", function(self)
        Raid:SetEncounter(self.encounterIndex)
    end)
    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(.07, .08, .09, .98)
        self:SetBackdropBorderColor(
            self.selected and .18 or .22,
            self.selected and .70 or .48,
            self.selected and 1 or .64, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.encounterName or L.BOSS)
        if self.currentBoss then
            GameTooltip:AddLine(
                "Current boss", .22, .9, .55)
        end
        GameTooltip:AddLine(L.CLICK_OPEN_BOSS_PLAN, unpack(MUTED))
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(self.baseColor))
        if self.selected then
            self:SetBackdropBorderColor(unpack(ACCENT))
        else
            self:SetBackdropBorderColor(unpack(BORDER))
        end
        GameTooltip:Hide()
    end)
    return button
end

function Raid:LayoutAssignmentToolbar()
    if not self.bossRail or not self.assignmentPanel then return end
    local railHeight = math.max(
        BOSS_BUTTON_SIZE + (BOSS_RAIL_GAP * 2),
        self.bossRail:GetHeight() or 0)
    local tabTop = 42 + railHeight + 6
    local firstTab = self.bossTabs
        and (
            self.bossTabs.MARKERS
            or self.bossTabs.ASSIGNMENTS
            or self.bossTabs.MECHANICS)
    if firstTab then
        firstTab:ClearAllPoints()
        firstTab:SetPoint("TOPLEFT", 8, -tabTop)
    end
    if self.assignmentPanel.ProgressTrack then
        self.assignmentPanel.ProgressTrack:ClearAllPoints()
        self.assignmentPanel.ProgressTrack:SetPoint(
            "TOPLEFT", 8, -(tabTop + 35))
    end
    if self.assignmentScroll then
        self.assignmentScroll:ClearAllPoints()
        self.assignmentScroll:SetPoint(
            "TOPLEFT", 6, -(tabTop + 39))
        self.assignmentScroll:SetPoint("BOTTOMRIGHT", -6, 8)
    end
end

function Raid:RefreshBossRail()
    if not self.bossRail then return end
    if self.raidPickerActive or not self.db.raidLocked then
        for _, button in ipairs(self.bossButtons or {}) do
            button:Hide()
        end
        self.bossRail:Hide()
        return
    end
    local raid = self:GetRaid()
    local currentBossIndex = self:GetCurrentBossIndex(raid)
    if self.clearPlanButton then
        self.clearPlanButton.Text:SetText(
            self.db.activeEncounter == 1 and "CLEAR PAGE" or L.CLEAR_BOSS)
    end
    if self.setCurrentBossButton then
        local isOverview = self.db.activeEncounter == 1
        local isCurrent = self.db.activeEncounter == currentBossIndex
        self.setCurrentBossButton:SetEnabled(
            not isOverview and self:IsLocalRaidEditor())
        self.setCurrentBossButton.Text:SetText(
            isCurrent and "CURRENT BOSS" or "SET CURRENT BOSS")
        StyleButton(
            self.setCurrentBossButton,
            isCurrent and "positive" or "default")
    end
    if self.frame and self.frame.Title then
        self.frame.Title:SetText("LUNA RAIDS")
        if self.frame.Subtitle then
            self.frame.Subtitle:SetText(
                raid.name:upper() .. "  ·  " .. self.L.ACTIVE_PLAN)
        end
    end
    self.bossButtons = self.bossButtons or {}
    local availableWidth = math.max(
        BOSS_BUTTON_SIZE + (BOSS_RAIL_GAP * 2),
        self.bossRail:GetWidth() or 0)
    local columns = math.max(
        1,
        math.floor(
            (availableWidth - BOSS_RAIL_GAP)
                / (BOSS_BUTTON_SIZE + BOSS_RAIL_GAP)))
    for index, encounter in ipairs(raid.encounters) do
        local button = self.bossButtons[index]
        if not button then
            button = self:CreateBossRailButton(index)
            self.bossButtons[index] = button
        end
        button:ClearAllPoints()
        local gridIndex = index - 1
        local column = gridIndex % columns
        local row = math.floor(gridIndex / columns)
        button:SetPoint(
            "TOPLEFT", self.bossRail, "TOPLEFT",
            BOSS_RAIL_GAP
                + (column * (BOSS_BUTTON_SIZE + BOSS_RAIL_GAP)),
            -BOSS_RAIL_GAP
                - (row * (BOSS_BUTTON_SIZE + BOSS_RAIL_GAP)))
        button.encounterIndex = index
        button.encounterName = encounter.name == "Raid Overview"
            and "Raid-Wide Plan" or encounter.name
        button.selected = index == self.db.activeEncounter
        button.currentBoss = index == currentBossIndex
        button.CurrentDot:SetShown(button.currentBoss)
        local icon = encounter.icon or raid.icon
        button.Icon:SetTexture(
            icon or "Interface\\Icons\\INV_Sword_27")
        button.Icon:SetDesaturated(not button.selected)
        button.Icon:SetAlpha(button.selected and 1 or .62)
        if button.selected then
            button.baseColor = { .060, .070, .080, .98 }
            button.baseBorder = { unpack(ACCENT) }
            button:SetBackdropColor(unpack(button.baseColor))
            button:SetBackdropBorderColor(unpack(button.baseBorder))
            button.ActiveBar:Hide()
            button.SelectionGlow:Show()
        else
            button.baseColor = { .035, .043, .052, .98 }
            button.baseBorder = { unpack(BORDER) }
            button:SetBackdropColor(unpack(button.baseColor))
            button:SetBackdropBorderColor(unpack(button.baseBorder))
            button.ActiveBar:Hide()
            button.SelectionGlow:Hide()
        end
        button:Show()
    end
    for index = #raid.encounters + 1, #self.bossButtons do
        self.bossButtons[index]:Hide()
    end
    local rows = math.ceil(#raid.encounters / columns)
    self.bossRail:SetHeight(
        BOSS_RAIL_GAP
            + (rows * (BOSS_BUTTON_SIZE + BOSS_RAIL_GAP)))
    self:LayoutAssignmentToolbar()
end

