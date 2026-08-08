local _, Raid = ...
local UI = Raid.UI
local THEME = UI.THEME
local WHITE = UI.WHITE

local function LootEntries()
    local id = Raid.db.activeSavedRaid
    local saved = id and Raid.db.savedRaids[id]
    return saved and saved.lootHistory or {}
end

function Raid:HideLootHistory()
    if self.lootHistoryHeader then self.lootHistoryHeader:Hide() end
    if self.lootHistoryEmpty then self.lootHistoryEmpty:Hide() end
    for _, row in ipairs(self.lootHistoryRows or {}) do row:Hide() end
end

function Raid:CreateLootHistoryRow()
    local row = UI.MakeCard(self.assignmentContent)
    row:SetHeight(38)
    row:EnableMouse(true)
    row:SetBackdropBorderColor(0, 0, 0, 0)
    if row.InnerGlow then row.InnerGlow:Hide() end
    if row.TopLine then row.TopLine:Hide() end
    row.Icon = row:CreateTexture(nil, "ARTWORK")
    row.Icon:SetSize(30, 30)
    row.Icon:SetPoint("LEFT", 5, 0)
    row.Player = UI.Font(row, 10, "accent", "")
    row.Player:SetPoint("LEFT", row.Icon, "RIGHT", 9, 0)
    row.Player:SetWidth(132)
    row.Player:SetJustifyH("LEFT")
    row.Item = UI.Font(row, 10, "text", "")
    row.Item:SetPoint("LEFT", row.Player, "RIGHT", 7, 0)
    row.Item:SetPoint("RIGHT", row, "RIGHT", -294, 0)
    row.Item:SetJustifyH("LEFT")
    row.Rolls = UI.Font(row, 9, "accent", "")
    row.Rolls:SetPoint("RIGHT", row, "RIGHT", -190, 0)
    row.Rolls:SetWidth(98)
    row.Rolls:SetJustifyH("RIGHT")
    row.Boss = UI.Font(row, 9, "muted", "")
    row.Boss:SetPoint("RIGHT", row, "RIGHT", -58, 0)
    row.Boss:SetWidth(126)
    row.Boss:SetJustifyH("RIGHT")
    row.Time = UI.Font(row, 9, "muted", "")
    row.Time:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    row.Time:SetWidth(44)
    row.Time:SetJustifyH("RIGHT")
    row:SetScript("OnEnter", function(self)
        if not self.itemLink then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.itemLink)
        if self.lootedBy
            and self.lootedBy ~= ""
            and self.lootedBy ~= self.player
        then
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(
                "Initially looted by", self.lootedBy,
                .72, .75, .78, .90, .92, .95)
            GameTooltip:AddDoubleLine(
                "Awarded to", self.player or "Unknown",
                .72, .75, .78, .35, 1, .55)
        end
        if self.lootReserve then
            local reserve = self.lootReserve
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("LootReserve", .35, .80, 1)
            if reserve.available == false then
                GameTooltip:AddLine(
                    "Reservation details are hidden by the session.",
                    .72, .75, .78, true)
            elseif (reserve.totalReserves or 0) == 0 then
                GameTooltip:AddLine("Not reserved", .72, .75, .78)
            else
                local winnerText = reserve.winnerReserved
                    and "Winner reserved this item"
                    or "Winner did not reserve this item"
                GameTooltip:AddLine(
                    winnerText,
                    reserve.winnerReserved and .35 or 1,
                    reserve.winnerReserved and 1 or .45,
                    reserve.winnerReserved and .45 or .35)
                GameTooltip:AddLine(
                    (reserve.totalReserves or 0) .. " reserves by "
                        .. (reserve.uniqueReservers or 0) .. " players",
                    .72, .75, .78)
                for _, reserver in ipairs(reserve.reservers or {}) do
                    GameTooltip:AddDoubleLine(
                        reserver.player or "Unknown",
                        (reserver.count or 1) > 1
                            and ("x" .. reserver.count) or "Reserved",
                        .90, .92, .95, .90, .92, .95)
                end
            end
        end
        if self.winningRollType and self.winningRollType ~= "" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(
                "Winning category", self.winningRollType,
                .72, .75, .78, 1, .82, .28)
        end
        if self.rolls and #self.rolls > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Rolls (" .. #self.rolls .. ")", 1, .82, .28)
            for index, roll in ipairs(self.rolls) do
                if index > 20 then
                    GameTooltip:AddLine(
                        "+" .. (#self.rolls - 20) .. " more", .65, .68, .72)
                    break
                end
                local detail = tostring(roll.amount or "-")
                if roll.classification and roll.classification ~= "" then
                    detail = detail .. "  " .. roll.classification
                end
                if roll.plusOneState then
                    detail = detail .. "  +" .. roll.plusOneState
                end
                GameTooltip:AddDoubleLine(
                    roll.player or "Unknown", detail,
                    .90, .92, .95, .90, .92, .95)
            end
        end
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and IsShiftKeyDown()
            and self.itemLink and ChatEdit_InsertLink
        then
            ChatEdit_InsertLink(self.itemLink)
        end
    end)
    return row
end

function Raid:RefreshLootHistory()
    if not self.assignmentContent then return end
    self.lootHistoryRows = self.lootHistoryRows or {}
    if not self.lootHistoryHeader then
        local header = CreateFrame("Frame", nil, self.assignmentContent)
        header:SetHeight(28)
        header.Background = header:CreateTexture(nil, "BACKGROUND")
        header.Background:SetTexture(WHITE)
        header.Background:SetAllPoints()
        header.Background:SetVertexColor(unpack(THEME.tableHeader))
        header.Title = UI.Font(header, 10, "accent", "LOOT HISTORY")
        header.Title:SetPoint("LEFT", 9, 0)
        header.Help = UI.Font(
            header, 9, "muted", "Actual items received during this raid")
        header.Help:SetPoint("RIGHT", -9, 0)
        self.lootHistoryHeader = header
        self.lootHistoryEmpty = UI.Font(
            self.assignmentContent, 11, "muted",
            "No loot has been received during this raid yet.")
        self.lootHistoryEmpty:SetJustifyH("CENTER")
    end
    local width = math.max(1, self.assignmentContent:GetWidth())
    self.lootHistoryHeader:ClearAllPoints()
    self.lootHistoryHeader:SetPoint("TOPLEFT", 0, 0)
    self.lootHistoryHeader:SetWidth(width)
    self.lootHistoryHeader:Show()
    local entries = LootEntries()
    self.lootHistoryEmpty:ClearAllPoints()
    self.lootHistoryEmpty:SetPoint("TOP", 0, -70)
    self.lootHistoryEmpty:SetWidth(width - 24)
    self.lootHistoryEmpty:SetShown(#entries == 0)
    for displayIndex = 1, #entries do
        local entry = entries[#entries - displayIndex + 1]
        local row = self.lootHistoryRows[displayIndex]
        if not row then
            row = self:CreateLootHistoryRow()
            self.lootHistoryRows[displayIndex] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -(31 + ((displayIndex - 1) * 41)))
        row:SetWidth(width)
        row.itemLink = entry.itemLink
        row.player = entry.player
        row.lootedBy = entry.lootedBy
        row.rolls = entry.rolls
        row.winningRollType = entry.winningRollType
        row.lootReserve = entry.lootReserve
        local icon = entry.itemID and GetItemIcon
            and GetItemIcon(entry.itemID)
        if not icon and GetItemInfo then
            icon = select(10, GetItemInfo(entry.itemLink))
        end
        row.Icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        row.Player:SetText(entry.player or "Unknown")
        row.Item:SetText(
            (entry.itemLink or "Unknown item")
                .. ((entry.quantity or 1) > 1
                    and " x" .. entry.quantity or ""))
        local rollCount = tonumber(entry.rollCount)
            or type(entry.rolls) == "table" and #entry.rolls or 0
        local reserveCount = entry.lootReserve
            and entry.lootReserve.available ~= false
            and tonumber(entry.lootReserve.totalReserves) or 0
        local details = {}
        if reserveCount > 0 then
            details[#details + 1] = reserveCount .. " res"
        end
        if rollCount > 0 then
            details[#details + 1] = rollCount .. " rolls"
        end
        row.Rolls:SetText(table.concat(details, " · "))
        row.Boss:SetText(entry.encounterName or "Raid")
        row.Time:SetText(date and date("%H:%M", entry.receivedAt or 0) or "")
        row:Show()
    end
    for index = #entries + 1, #self.lootHistoryRows do
        self.lootHistoryRows[index]:Hide()
    end
    self.assignmentContent:SetHeight(
        math.max(120, 34 + (#entries * 41)))
    if self.assignmentScroll.UpdateScrollbar then
        self.assignmentScroll:UpdateScrollbar()
    end
end
