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
function Raid:CreateReadyCheckWindow()
    if self.readyCheckWindow then return self.readyCheckWindow end
    local saved = self.db.readyCheck
    local frame = Panel(UIParent)
    PixelSetSize(frame, 730, 120)
    frame:SetPoint(
        saved.point or "CENTER", UIParent,
        saved.point or "CENTER", saved.x or 0, saved.y or 120)
    frame:SetFrameStrata("HIGH")
    frame:SetScale(self:GetHUDScale())
    frame:SetFrameLevel(200)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint(1)
        Raid.db.readyCheck.point = point
        Raid.db.readyCheck.x, Raid.db.readyCheck.y = x, y
    end)
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then self:Hide() end
    end)

    frame.Header = frame:CreateTexture(nil, "ARTWORK")
    frame.Header:SetTexture(WHITE)
    frame.Header:SetPoint("TOPLEFT", 1, -1)
    frame.Header:SetPoint("TOPRIGHT", -1, -1)
    frame.Header:SetHeight(34)
    frame.Header:SetVertexColor(.025, .075, .105, .99)
    frame.Icon = frame:CreateTexture(nil, "OVERLAY")
    frame.Icon:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
    PixelSetSize(frame.Icon, 21, 21)
    frame.Icon:SetPoint("TOPLEFT", 10, -7)
    frame.Title = Font(frame, 12, "text", L.READY_CHECK_TITLE)
    frame.Title:SetPoint("LEFT", frame.Icon, "RIGHT", 7, 0)
    frame.Timer = Font(frame, 10, "accent", "")
    frame.Timer:SetPoint("LEFT", frame.Title, "RIGHT", 7, 0)
    frame.Close = CreateFrame(
        "Button", nil, frame, "UIPanelCloseButton")
    frame.Close:SetPoint("TOPRIGHT", -2, -2)
    frame.Close:SetScript("OnClick", function() frame:Hide() end)
    frame.FadeOut = frame:CreateAnimationGroup()
    local fade = frame.FadeOut:CreateAnimation("Alpha")
    fade:SetFromAlpha(1)
    fade:SetToAlpha(0)
    fade:SetDuration(1.8)
    fade:SetSmoothing("OUT")
    frame.FadeOut:SetScript("OnFinished", function()
        frame.dismissPending = nil
        frame.dismissHovered = nil
        frame:Hide()
        frame:SetAlpha(1)
    end)

    frame.Summary = Font(frame, 10, "muted", "")
    frame.Summary:SetPoint("TOPRIGHT", -48, -12)
    frame.Summary:SetJustifyH("RIGHT")
    frame.Hint = Font(frame, 9, "muted", L.RIGHT_CLICK_DISMISS)
    frame.Hint:Hide()
    frame.HeaderY = -37
    frame.HeaderGridOffset = 7
    frame.HeaderBackground =
        frame:CreateTexture(nil, "BACKGROUND")
    frame.HeaderBackground:SetTexture(WHITE)
    frame.HeaderBackground:SetPoint("TOPLEFT", 7, -36)
    frame.HeaderBackground:SetPoint("TOPRIGHT", -7, -36)
    frame.HeaderBackground:SetHeight(24)
    frame.HeaderBackground:SetVertexColor(.035, .105, .145, .98)
    frame.HeaderLabel = Font(frame, 9, "accent", L.PLAYER_STATUS)
    frame.HeaderLabel:SetPoint("TOPLEFT", 14, -43)
    frame.Headers = {}
    for index, column in ipairs(READY_CHECK_COLUMNS) do
        local header = CreateFrame("Frame", nil, frame)
        PixelSetSize(header, 28, 22)
        header:SetPoint(
            "TOPLEFT",
            READY_CHECK_GRID_START
                + ((index - 1) * READY_CHECK_COLUMN_WIDTH),
            frame.HeaderY)
        header.Background = header:CreateTexture(nil, "BACKGROUND")
        header.Background:SetAllPoints()
        header.Background:SetTexture(WHITE)
        header.Background:SetVertexColor(
            index % 2 == 0 and .045 or .055,
            index % 2 == 0 and .14 or .16,
            index % 2 == 0 and .19 or .215, 1)
        header.Icon = header:CreateTexture(nil, "ARTWORK")
        header.Icon:SetTexture(column.icon)
        PixelSetSize(header.Icon, 17, 17)
        header.Icon:SetPoint("CENTER")
        header:EnableMouse(true)
        header:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(column.label)
            GameTooltip:Show()
        end)
        header:SetScript(
            "OnLeave", function() GameTooltip:Hide() end)
        frame.Headers[index] = header
    end
    frame.Scroll, frame.Content = CreateScrollArea(frame)
    frame.Scroll:SetPoint("TOPLEFT", 7, -61)
    frame.Scroll:SetPoint("BOTTOMRIGHT", -7, 7)
    frame.Content:SetWidth(714)
    frame.Rows = {}
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.auraRefreshElapsed =
            (self.auraRefreshElapsed or 0) + elapsed
        self.timerElapsed = (self.timerElapsed or 0) + elapsed
        if self.timerElapsed < .25 then return end
        self.timerElapsed = self.timerElapsed - .25
        if self.auraRefreshElapsed >= 5 then
            self.auraRefreshElapsed = 0
            Raid:RefreshReadyCheckWindow()
        end
        if self.dismissPending then
            local hovering = self:IsMouseOver()
            if hovering then
                if not self.dismissHovered then
                    self.dismissHovered = true
                    self.FadeOut:Stop()
                    self:SetAlpha(1)
                end
            elseif self.dismissHovered then
                self.dismissHovered = nil
                self.dismissAt = GetTime()
                    + (Raid.db.readyCheck.holdDuration or 15)
            elseif GetTime() >= (self.dismissAt or 0)
                and not self.FadeOut:IsPlaying()
            then
                self.FadeOut:Play()
            end
        end
        if self.endTime then
            local remaining = math.max(
                0, math.ceil(self.endTime - GetTime()))
            self.Timer:SetText(("· %ds"):format(remaining))
        else
            self.Timer:SetText("")
        end
    end)
    frame:Hide()
    self.readyCheckWindow = frame
    return frame
end

function Raid:CreateReadyCheckRow(index, frame)
    frame = frame or self:CreateReadyCheckWindow()
    local row = BackdropFrame("Frame", nil, frame.Content)
    PixelSetSize(row, 714, 20)
    row:SetBackdrop({
        bgFile = WHITE,
    })
    row:SetBackdropColor(.035, .055, .072, .97)
    row.Status = row:CreateTexture(nil, "ARTWORK")
    PixelSetSize(row.Status, 16, 16)
    row.Status:SetPoint("LEFT", 6, 0)
    row.Name = Font(row, 10, "text", "")
    if frame.Embedded then
        row.Status:Hide()
        row.Name:SetPoint("LEFT", 8, 0)
        row.Name:SetWidth(152)
    else
        row.Name:SetPoint("LEFT", row.Status, "RIGHT", 6, 0)
        row.Name:SetWidth(126)
    end
    row.Name:SetJustifyH("LEFT")
    row.Role = row:CreateTexture(nil, "ARTWORK")
    row.Role:SetTexture(ROLE_TEXTURE)
    PixelSetSize(row.Role, 15, 15)
    row.Role:SetPoint("LEFT", 172, 0)
    row.Checks = {}
    for columnIndex, column in ipairs(READY_CHECK_COLUMNS) do
        local cell = CreateFrame("Frame", nil, row)
        PixelSetSize(cell, 27, 18)
        cell:SetPoint(
            "LEFT",
            READY_CHECK_GRID_START
                + ((columnIndex - 1) * READY_CHECK_COLUMN_WIDTH),
            0)
        cell:EnableMouse(true)
        cell.Icons = {}
        cell.Value = Font(cell, 9, "text", "")
        cell.Value:SetPoint("CENTER")
        cell.Value:Hide()
        cell.Column = column
        cell:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.Column.label)
            if self.Column.key == "durability"
                and self.DurabilityPercent
            then
                GameTooltip:AddLine(
                    Raid:Localize(
                        "DURABILITY_AVERAGE", self.DurabilityPercent),
                    .90, .90, .90)
                if self.BrokenItems and self.BrokenItems > 0 then
                    GameTooltip:AddLine(
                        Raid:Localize(
                            self.BrokenItems == 1 and "BROKEN_ITEM"
                                or "BROKEN_ITEMS",
                            self.BrokenItems),
                        1, .28, .28)
                end
            elseif self.Column.key == "durability" then
                GameTooltip:AddLine(
                    L.NO_DURABILITY_DATA,
                    MUTED[1], MUTED[2], MUTED[3], true)
            elseif self.Details and #self.Details > 0 then
                for _, detail in ipairs(self.Details) do
                    local name = detail.name
                    if type(name) ~= "string"
                        or issecretvalue and issecretvalue(name)
                    then
                        name = L.DETECTED_BUFF
                    end
                    GameTooltip:AddLine(name, .90, .90, .90)
                end
            elseif self.Present then
                GameTooltip:AddLine(
                    L.REPORTED_BY_PEER, unpack(MUTED))
            else
                GameTooltip:AddLine(L.NOT_DETECTED, 1, .35, .35)
            end
            GameTooltip:Show()
        end)
        cell:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row.Checks[columnIndex] = cell
    end
    frame.Rows[index] = row
    return row
end

function Raid:RefreshReadyCheckWindow(frame)
    frame = frame or self.readyCheckWindow
    if not frame or not frame:IsShown() then return end
    local pending, declined, ready, waiting = {}, 0, 0, 0
    for _, player in ipairs(self.roster or {}) do
        local status = self.readyCheckStatus
            and self.readyCheckStatus[player.name]
        local checks = self:GetReadyCheckAuras(player.unit)
        local peerChecks = self.readyCheckPeerData
            and (
                self.readyCheckPeerData[player.name]
                or self.readyCheckPeerData[
                    player.name:match("^[^-]+") or player.name])
        if peerChecks then
            checks = checks or { details = {} }
            checks.details = checks.details or {}
            for _, column in ipairs(READY_CHECK_COLUMNS) do
                if peerChecks[column.key] then
                    checks[column.key] = true
                end
            end
            for key, details in pairs(peerChecks.details or {}) do
                if not checks.details[key]
                    or #checks.details[key] == 0
                then
                    checks.details[key] = details
                end
            end
            if peerChecks.durabilityPercent then
                checks.durabilityPercent =
                    peerChecks.durabilityPercent
                checks.durabilitySource =
                    peerChecks.durabilitySource
                checks.brokenItems = peerChecks.brokenItems
            end
        end
        local consumablesOkay = checks
            and checks.food and checks.flask
        if status == true then
            ready = ready + 1
        elseif status == nil then
            waiting = waiting + 1
        end
        if status == false then declined = declined + 1 end
        pending[#pending + 1] = {
            player = player,
            declined = status == false,
            ready = status == true,
            checks = checks,
            missingConsumables =
                checks and not consumablesOkay or false,
        }
    end
    table.sort(pending, function(left, right)
        if left.declined ~= right.declined then
            return left.declined
        end
        return left.player.name < right.player.name
    end)
    local columnWidths = {}
    local gridWidth = 0
    for columnIndex, column in ipairs(READY_CHECK_COLUMNS) do
        local largest = 1
        for _, entry in ipairs(pending) do
            local details = entry.checks and entry.checks.details
                and entry.checks.details[column.key]
            largest = math.max(largest, details and #details or 0)
        end
        local minimumWidth =
            column.key == "durability" and 38
            or READY_CHECK_COLUMN_WIDTH
        columnWidths[columnIndex] = math.max(
            minimumWidth, 6 + (largest * 18))
        gridWidth = gridWidth + columnWidths[columnIndex]
    end
    local windowWidth = math.max(
        730,
        frame.Embedded and frame:GetWidth() or 0,
        READY_CHECK_GRID_START + gridWidth + 12)
    local gridStart = frame.Embedded
        and math.max(
            READY_CHECK_GRID_START,
            windowWidth - gridWidth - 24)
        or READY_CHECK_GRID_START
    local layoutSignature =
        windowWidth .. ":" .. gridStart .. ":"
            .. table.concat(columnWidths, ",")
    if frame.LayoutSignature ~= layoutSignature then
        frame.LayoutSignature = layoutSignature
        if not frame.Embedded then frame:SetWidth(windowWidth) end
        frame.Content:SetWidth(windowWidth - 16)
        local headerX = gridStart + (frame.HeaderGridOffset or 0)
        for columnIndex, header in ipairs(frame.Headers) do
            header:ClearAllPoints()
            header:SetPoint(
                "TOPLEFT", headerX, frame.HeaderY or -57)
            header:SetWidth(columnWidths[columnIndex])
            headerX = headerX + columnWidths[columnIndex]
        end
    end
    if frame.Embedded then
        frame.Summary:SetText("")
        frame.Summary:Hide()
    else
        frame.Summary:SetText(
            Raid:Localize("READY_SUMMARY", ready, waiting, declined))
        frame.Summary:Show()
    end
    if frame.Hint then
        frame.Hint:Show()
    end
    local rowHeight = 21
    local availableHeight = math.max(1, frame.Scroll:GetHeight() or 1)
    if frame.Embedded and #pending > 0 then
        rowHeight = math.max(
            21, math.min(44, availableHeight / #pending))
    end
    for index, entry in ipairs(pending) do
        local row = frame.Rows[index]
            or self:CreateReadyCheckRow(index, frame)
        row:ClearAllPoints()
        row:SetHeight(rowHeight)
        row:SetPoint("TOPLEFT", 0, -((index - 1) * rowHeight))
        if row.LayoutSignature ~= layoutSignature then
            row.LayoutSignature = layoutSignature
            row:SetWidth(windowWidth - 16)
        end
        SetClassText(
            row.Name, entry.player.name, entry.player.class)
        row:SetBackdropColor(
            GetClassRowColor(entry.player.class, index % 2 == 0))
        row.Status:SetTexture(
            entry.declined
                and "Interface\\RaidFrame\\ReadyCheck-NotReady"
                or entry.ready
                    and "Interface\\RaidFrame\\ReadyCheck-Ready"
                or "Interface\\RaidFrame\\ReadyCheck-Waiting")
        local role = ROLE_COORDS[entry.player.role]
        if role then
            row.Role:SetTexCoord(unpack(role))
            row.Role:Show()
        else
            row.Role:Hide()
        end
        row:SetAlpha(entry.player.online == false and .35 or 1)
        local cellX = gridStart
        for columnIndex, column in ipairs(READY_CHECK_COLUMNS) do
            local present = entry.checks
                and entry.checks[column.key]
            local cell = row.Checks[columnIndex]
            local details = entry.checks and entry.checks.details
                and entry.checks.details[column.key]
            cell.Present, cell.Details = present, details
            if cell.LayoutSignature ~= layoutSignature then
                cell.LayoutSignature = layoutSignature
                cell:ClearAllPoints()
                cell:SetPoint("LEFT", cellX, 0)
                cell:SetWidth(columnWidths[columnIndex])
            end
            if column.key == "durability" then
                local percent = entry.checks
                    and entry.checks.durabilityPercent
                cell.DurabilityPercent = percent
                cell.DurabilitySource = entry.checks
                    and entry.checks.durabilitySource
                cell.BrokenItems = entry.checks
                    and entry.checks.brokenItems
                for _, iconFrame in ipairs(cell.Icons) do
                    iconFrame:Hide()
                end
                cell.Value:SetText(
                    percent and ("%d%%"):format(percent) or "?")
                if not percent then
                    cell.Value:SetTextColor(unpack(MUTED))
                elseif percent < 30 then
                    cell.Value:SetTextColor(1, .24, .24, 1)
                elseif percent < 60 then
                    cell.Value:SetTextColor(1, .72, .20, 1)
                else
                    cell.Value:SetTextColor(.34, .86, .48, 1)
                end
                cell.Value:Show()
            else
                cell.DurabilityPercent = nil
                cell.DurabilitySource = nil
                cell.BrokenItems = nil
                cell.Value:Hide()
                local iconCount = details and #details or 0
                local visibleIcons = math.max(1, iconCount)
                local iconGroupWidth =
                    (visibleIcons * 15)
                        + (math.max(0, visibleIcons - 1) * 3)
                local iconStart =
                    (columnWidths[columnIndex] - iconGroupWidth) / 2
                for iconIndex = 1, visibleIcons do
                local iconFrame = cell.Icons[iconIndex]
                if not iconFrame then
                    iconFrame = CreateFrame("Frame", nil, cell)
                    PixelSetSize(iconFrame, 15, 15)
                    iconFrame:EnableMouse(true)
                    iconFrame.Texture =
                        iconFrame:CreateTexture(nil, "ARTWORK")
                    iconFrame.Texture:SetAllPoints()
                    iconFrame:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_TOP")
                        local detail = self.Detail
                        local shown
                        if detail and detail.inventoryUnit
                            and detail.inventorySlot
                            and GameTooltip.SetInventoryItem
                        then
                            shown = pcall(
                                GameTooltip.SetInventoryItem,
                                GameTooltip,
                                detail.inventoryUnit,
                                detail.inventorySlot)
                        elseif detail and detail.unit and detail.auraIndex
                            and GameTooltip.SetUnitBuff
                        then
                            local currentIndex = detail.auraIndex
                            if detail.spellID and C_UnitAuras
                                and C_UnitAuras.GetAuraDataByIndex
                            then
                                for auraIndex = 1, 60 do
                                    local aura =
                                        C_UnitAuras.GetAuraDataByIndex(
                                            detail.unit, auraIndex,
                                            detail.filter or "HELPFUL")
                                    if not aura then break end
                                    if aura.spellId == detail.spellID then
                                        currentIndex = auraIndex
                                        break
                                    end
                                end
                            end
                            shown = pcall(
                                GameTooltip.SetUnitBuff, GameTooltip,
                                detail.unit, currentIndex,
                                detail.filter or "HELPFUL")
                        end
                        if not shown and detail and detail.spellID
                            and GameTooltip.SetSpellByID
                        then
                            shown = pcall(
                                GameTooltip.SetSpellByID,
                                GameTooltip, detail.spellID)
                        end
                        if not shown then
                            GameTooltip:SetText(self.Column.label)
                            if detail and detail.name then
                                GameTooltip:AddLine(
                                    detail.name, .90, .90, .90)
                            else
                                GameTooltip:AddLine(
                                    self.Present and L.DETECTED
                                        or L.NOT_DETECTED,
                                    self.Present and .35 or 1,
                                    self.Present and .85 or .35,
                                    self.Present and .45 or .35)
                            end
                        end
                        GameTooltip:Show()
                    end)
                    iconFrame:SetScript(
                        "OnLeave", function() GameTooltip:Hide() end)
                    cell.Icons[iconIndex] = iconFrame
                end
                iconFrame:ClearAllPoints()
                iconFrame:SetPoint(
                    "LEFT",
                    iconStart + ((iconIndex - 1) * 18), 0)
                iconFrame.Detail = iconCount > 0
                    and details[iconIndex] or nil
                iconFrame.Column = column
                iconFrame.Present = present
                iconFrame.Texture:SetTexture(
                    iconCount > 0 and details[iconIndex].icon
                        or not entry.checks
                            and "Interface\\RaidFrame\\ReadyCheck-Waiting"
                        or present
                            and column.icon
                            or "Interface\\RaidFrame\\ReadyCheck-NotReady")
                iconFrame.Texture:SetAlpha(present and 1 or .68)
                iconFrame:Show()
                end
                for iconIndex = visibleIcons + 1, #cell.Icons do
                    cell.Icons[iconIndex]:Hide()
                end
            end
            cellX = cellX + columnWidths[columnIndex]
        end
        row:Show()
    end
    for index = #pending + 1, #frame.Rows do
        frame.Rows[index]:Hide()
    end
    frame.Content:SetHeight(math.max(
        availableHeight, #pending * rowHeight))
    if not frame.Embedded then
        frame:SetHeight(
            math.min(560, math.max(92, 71 + (#pending * 21))))
        frame:SetScale(self:GetHUDScale())
    end
    frame.Scroll:Show()
    for _, header in ipairs(frame.Headers) do header:Show() end
    if frame.Scroll.UpdateScrollbar then
        frame.Scroll:UpdateScrollbar()
    end
end

function Raid:CreateRaidStatusView()
    if self.raidStatusView then return self.raidStatusView end
    local frame = CreateFrame("Frame", nil, self.assignmentPanel)
    frame:SetPoint("TOPLEFT", 0, 0)
    frame:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.Embedded = true
    frame.HeaderY = -1
    frame.Summary = Font(frame, 10, "muted", "")
    frame.Summary:SetPoint("TOPLEFT", 4, -5)
    frame.ActionBar = CreateFrame("Frame", nil, self.frame)
    frame.ActionBar:SetPoint("BOTTOMLEFT", 12, 8)
    frame.ActionBar:SetPoint("BOTTOMRIGHT", -24, 8)
    frame.ActionBar:SetHeight(40)
    frame.ActionBar:SetFrameLevel(self.frame:GetFrameLevel() + 8)
    frame.Actions = {}
    local actionEntries = {
        {
            label = L.ACTION_READY_CHECK,
            icon = "Interface\\RaidFrame\\ReadyCheck-Ready",
            title = L.READY_CHECK,
            detail = L.READY_CHECK_DESC,
            run = function() Raid:StartReadyCheck() end,
            rightRun = function()
                Raid:ShowPinnedReadyCheckWindow()
            end,
        },
        {
            label = L.ACTION_ROLE_CHECK,
            icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
            title = L.ROLE_CHECK,
            detail = L.ROLE_CHECK_DESC,
            run = function() Raid:StartRoleCheck() end,
        },
        {
            label = L.ACTION_PULL_10,
            icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
            title = L.PULL_TIMER,
            detail = L.PULL_TIMER_DESC,
            run = function() Raid:StartPullCountdown(10) end,
        },
        {
            label = L.ACTION_BREAK_5,
            icon = "Interface\\Icons\\INV_Drink_05",
            title = L.BREAK_TIMER,
            detail = L.BREAK_TIMER_DESC,
            run = function() Raid:StartBreakTimer(5) end,
            rightRun = function(button)
                ShowSelectionMenu(
                    button,
                    {
                        { 5, L.MINUTES_5 },
                        { 10, L.MINUTES_10 },
                        { 15, L.MINUTES_15 },
                    },
                    5,
                    function(minutes)
                        Raid:StartBreakTimer(minutes)
                    end,
                    156)
            end,
            rightDetail = L.RIGHT_CLICK_BREAK,
        },
    }
    local previous
    for index, entry in ipairs(actionEntries) do
        local run, rightRun = entry.run, entry.rightRun
        local button = Button(frame.ActionBar, entry.label, 126, 28)
        if previous then
            button:SetPoint("LEFT", previous, "RIGHT", 5, 0)
        else
            button:SetPoint("LEFT", 0, 0)
        end
        AddButtonIcon(button, entry.icon, 16)
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:SetScript("OnClick", function(_, mouseButton)
            if mouseButton == "RightButton" and rightRun then
                rightRun(button)
            else
                run()
            end
        end)
        AddButtonTooltip(
            button, entry.title,
            entry.detail .. (rightRun
                and (entry.rightDetail
                    or L.RIGHT_CLICK_PIN_RESULTS_SHORT)
                or ""))
        if index == 1 then StyleButton(button, "primary") end
        frame.Actions[index] = button
        previous = button
    end
    self.statusFooterActionButtons = frame.Actions
    for _, button in ipairs(frame.Actions) do
        self.footerActionButtons[#self.footerActionButtons + 1] = button
    end
    frame.ActionBar:Hide()
    frame.HeaderBackground =
        frame:CreateTexture(nil, "BACKGROUND")
    frame.HeaderBackground:SetTexture(WHITE)
    frame.HeaderBackground:SetPoint("TOPLEFT", 0, 0)
    frame.HeaderBackground:SetPoint("TOPRIGHT", 0, 0)
    frame.HeaderBackground:SetHeight(24)
    frame.HeaderBackground:SetVertexColor(.035, .105, .145, .98)
    frame.HeaderLabel = Font(frame, 9, "accent", L.PLAYER)
    frame.HeaderLabel:SetPoint("TOPLEFT", 7, -7)
    frame.Headers = {}
    for index, column in ipairs(READY_CHECK_COLUMNS) do
        local header = CreateFrame("Frame", nil, frame)
        PixelSetSize(header, 28, 22)
        header:SetPoint(
            "TOPLEFT",
            READY_CHECK_GRID_START
                + ((index - 1) * READY_CHECK_COLUMN_WIDTH),
            frame.HeaderY)
        header.Background = header:CreateTexture(nil, "BACKGROUND")
        header.Background:SetAllPoints()
        header.Background:SetTexture(WHITE)
        header.Background:SetVertexColor(
            index % 2 == 0 and .045 or .055,
            index % 2 == 0 and .14 or .16,
            index % 2 == 0 and .19 or .215, 1)
        header.Icon = header:CreateTexture(nil, "ARTWORK")
        header.Icon:SetTexture(column.icon)
        PixelSetSize(header.Icon, 17, 17)
        header.Icon:SetPoint("CENTER")
        header:EnableMouse(true)
        header:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(column.label)
            GameTooltip:Show()
        end)
        header:SetScript(
            "OnLeave", function() GameTooltip:Hide() end)
        frame.Headers[index] = header
    end
    frame.Scroll, frame.Content = CreateScrollArea(frame)
    frame.Scroll:SetPoint("TOPLEFT", 0, -24)
    frame.Scroll:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.Content:SetWidth(714)
    frame.Rows = {}
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.refreshElapsed = (self.refreshElapsed or 0) + elapsed
        if self.refreshElapsed >= 5 then
            self.refreshElapsed = 0
            Raid:RefreshReadyCheckWindow(self)
        end
    end)
    frame:Hide()
    self.raidStatusView = frame
    return frame
end

function Raid:RefreshRaidStatusView()
    local frame = self:CreateRaidStatusView()
    self.readyCheckStatus = self.readyCheckStatus or {}
    self.readyCheckPeerData = self.readyCheckPeerData or {}
    self.readyCheckAuraCache = self.readyCheckAuraCache or {}
    frame:Show()
    frame.ActionBar:Show()
    local canEdit = self:IsLocalRaidEditor()
    for _, button in ipairs(frame.Actions or {}) do
        button:SetEnabled(canEdit)
        button:SetAlpha(canEdit and 1 or .4)
    end
    self.assignmentTitle:SetText(L.RAID_STATUS)
    self:RefreshWorkspaceNavigation()
    self:BroadcastReadyCheckStatus()
    self:RequestGroupDurability()
    self:RefreshReadyCheckWindow(frame)
end

function Raid:ShowReadyCheckWindow(timeout, simulated, caller)
    if self.db.readyCheck.showWindow == false then return end
    self:UpdateRoster()
    local frame = self:CreateReadyCheckWindow()
    self.readyCheckSequence = (self.readyCheckSequence or 0) + 1
    self.readyCheckStatus = {}
    self.readyCheckPeerData = {}
    self.readyCheckAuraCache = {}
    self:RequestGroupDurability()
    frame.endTime = GetTime() + (tonumber(timeout) or 35)
    local callerName = caller
    if not callerName or callerName == "" then
        callerName = simulated and (
            GetUnitName("player", true) or UnitName("player"))
            or nil
    end
    if callerName then
        local callerShort =
            callerName:match("^[^-]+") or callerName
        for _, player in ipairs(self.roster or {}) do
            local playerShort =
                player.name:match("^[^-]+") or player.name
            if player.name == callerName or playerShort == callerShort then
                self.readyCheckStatus[player.name] = true
                break
            end
        end
    end
    frame.Title:SetText(
        simulated and L.READY_CHECK_SIMULATION
            or callerName and Raid:Localize("READY_CHECK_CALLER", callerName)
            or L.READY_CHECK_TITLE)
    frame.FadeOut:Stop()
    frame.dismissPinned = nil
    frame.dismissPending = nil
    frame.dismissHovered = nil
    frame.dismissAt = nil
    frame:SetAlpha(1)
    frame:Show()
    self:BroadcastReadyCheckStatus()
    self:RefreshReadyCheckWindow()
end

function Raid:ShowPinnedReadyCheckWindow()
    self:UpdateRoster()
    local frame = self:CreateReadyCheckWindow()
    frame.FadeOut:Stop()
    frame:SetAlpha(1)
    frame.dismissPinned = true
    frame.dismissPending = nil
    frame.dismissHovered = nil
    frame.dismissAt = nil
    frame.endTime = nil
    if not self.readyCheckStatus then
        self.readyCheckStatus = {}
        self.readyCheckPeerData = {}
        frame.Title:SetText(L.READY_CHECK_RESULTS)
    end
    frame:Show()
    self:RefreshReadyCheckWindow()
end

function Raid:RaiseBlizzardReadyCheckDialog()
    local dialog = _G.ReadyCheckFrame or _G.ReadyCheckListenerFrame
    if not dialog then return end
    if dialog.SetFrameStrata then
        pcall(dialog.SetFrameStrata, dialog, "FULLSCREEN_DIALOG")
    end
    if dialog.SetFrameLevel then
        pcall(dialog.SetFrameLevel, dialog, 500)
    end
    if dialog.Raise then
        pcall(dialog.Raise, dialog)
    end
end

