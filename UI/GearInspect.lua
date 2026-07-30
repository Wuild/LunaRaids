local _, Raid = ...
local UI = Raid.UI
local GearInspect = Raid:NewModule("GearInspect", "AceEvent-3.0")

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
local ShortPlayerName = UI.ShortPlayerName

local function GetGearItemLevel(link)
    if not link then return nil end
    if C_Item and C_Item.GetDetailedItemLevelInfo then
        local ok, level = pcall(
            C_Item.GetDetailedItemLevelInfo, link)
        if ok then return tonumber(level) end
    end
    if GetDetailedItemLevelInfo then
        local ok, level = pcall(GetDetailedItemLevelInfo, link)
        if ok then return tonumber(level) end
    end
    return nil
end

local function GetGearItemQuality(link)
    if not link then return nil end
    if GetItemInfo then
        local quality = select(3, GetItemInfo(link))
        if quality ~= nil then return quality end
    end
    if C_Item and C_Item.GetItemQualityByID and GetItemInfoInstant then
        local itemID = GetItemInfoInstant(link)
        if itemID then
            local ok, quality = pcall(C_Item.GetItemQualityByID, itemID)
            if ok then return quality end
        end
    end
    return nil
end

function Raid:CaptureGearInspectUnit(player)
    if not player or not player.unit or not UnitExists(player.unit) then
        return
    end
    self.gearInspectCache = self.gearInspectCache or {}
    local key = player.guid or player.name
    local data = {
        items = {},
        updated = GetTime(),
    }
    local totalLevel, levelCount = 0, 0
    for _, definition in ipairs(GEAR_INSPECT_SLOTS) do
        local link = GetInventoryItemLink
            and GetInventoryItemLink(player.unit, definition.id)
        local texture = GetInventoryItemTexture
            and GetInventoryItemTexture(player.unit, definition.id)
        local level = GetGearItemLevel(link)
        local quality = GetInventoryItemQuality
            and GetInventoryItemQuality(player.unit, definition.id)
            or GetGearItemQuality(link)
        data.items[definition.id] = {
            link = link,
            texture = texture,
            level = level,
            quality = quality,
        }
        if level then
            totalLevel = totalLevel + level
            levelCount = levelCount + 1
        end
    end
    data.averageLevel = levelCount > 0
        and math.floor((totalLevel / levelCount) + .5) or nil
    data.complete = levelCount >= 12
    self.gearInspectCache[key] = data
    if self.UpdateGearScoreFromTipTac then
        self:UpdateGearScoreFromTipTac(player)
    end
end

function Raid:StorePeerGearSnapshot(sender, links)
    local wanted = ShortPlayerName(sender)
    local player
    for _, candidate in ipairs(self.roster or {}) do
        if ShortPlayerName(candidate.name) == wanted then
            player = candidate
            break
        end
    end
    if not player then return end
    self.gearInspectCache = self.gearInspectCache or {}
    local data = {
        items = {},
        updated = GetTime(),
        source = "ADDON",
    }
    local totalLevel, levelCount = 0, 0
    for _, definition in ipairs(GEAR_INSPECT_SLOTS) do
        local link = links and links[definition.id]
        local texture, quality
        if link and GetItemInfo then
            quality = GetGearItemQuality(link)
            texture = select(10, GetItemInfo(link))
        end
        if link and not texture and GetItemIcon then
            texture = GetItemIcon(link)
        elseif link and not texture
            and C_Item and C_Item.GetItemIconByID
            and GetItemInfoInstant
        then
            local itemID = GetItemInfoInstant(link)
            if itemID then texture = C_Item.GetItemIconByID(itemID) end
        end
        local level = GetGearItemLevel(link)
        data.items[definition.id] = {
            link = link,
            texture = texture,
            level = level,
            quality = quality,
        }
        if level then
            totalLevel = totalLevel + level
            levelCount = levelCount + 1
        end
    end
    data.averageLevel = levelCount > 0
        and math.floor((totalLevel / levelCount) + .5) or nil
    data.complete = true
    self.gearInspectCache[player.guid or player.name] = data
    if self.gearPeerWait then
        self.gearPeerWait[player.guid or player.name] = nil
    end
    if self.gearInspectView and self.gearInspectView:IsShown() then
        self:RefreshGearInspectView(false)
    end
end

function Raid:QueueGearInspections()
    self.gearInspectQueue = {}
    self.gearInspectQueued = {}
    self.gearPeerWait = self.gearPeerWait or {}
    local now = GetTime()
    for _, player in ipairs(self.roster or {}) do
        local unit = player.unit
        if unit and UnitExists(unit)
            and player.online ~= false
            and not player.manual
            and not player.simulated
        then
            if UnitIsUnit and UnitIsUnit(unit, "player") then
                self:CaptureGearInspectUnit(player)
            else
                local key = player.guid or player.name
                local cached = self.gearInspectCache
                    and self.gearInspectCache[key]
                local freshCache = cached and cached.complete
                    and now - (cached.updated or 0) < 300
                local compatiblePeer
                for sender, compatible in pairs(
                    self.compatiblePeers or {})
                do
                    if compatible
                        and ShortPlayerName(sender)
                            == ShortPlayerName(player.name)
                    then
                        compatiblePeer = true
                        break
                    end
                end
                if compatiblePeer and not cached then
                    self.gearPeerWait[key] =
                        self.gearPeerWait[key] or now
                end
                local waitingForPeer = compatiblePeer
                    and not cached
                    and now - (self.gearPeerWait[key] or now) < 8
                if not freshCache and not waitingForPeer
                    and not self.gearInspectQueued[key]
                then
                    self.gearInspectQueued[key] = true
                    self.gearInspectQueue[
                        #self.gearInspectQueue + 1] = player
                end
            end
        end
    end
end

function Raid:ProcessGearInspectQueue()
    local now = GetTime()
    if self.gearInspectPending then
        if now - (self.gearInspectPendingAt or 0) < 4 then
            return
        end
        self.gearInspectPending = nil
    end
    if self.pendingInspect then return end
    if InCombatLockdown and InCombatLockdown() then return end
    if _G.InspectFrame and InspectFrame:IsShown() then return end
    if now - (self.lastGlobalInspectAt or 0) < 5 then return end
    while self.gearInspectQueue and #self.gearInspectQueue > 0 do
        local player = table.remove(self.gearInspectQueue, 1)
        local unit = player and player.unit
        local inspectKey = player and (player.guid or player.name)
        if unit and UnitExists(unit)
            and CanInspect and CanInspect(unit, false)
            and NotifyInspect
            and (not self.IsPeerInspectReserved
                or not self:IsPeerInspectReserved(inspectKey))
        then
            if self.BroadcastInspectClaim then
                self:BroadcastInspectClaim(inspectKey, 10)
            end
            local ok = pcall(NotifyInspect, unit)
            if ok then
                self.gearInspectPending = player.guid or player.name
                self.gearInspectPendingAt = GetTime()
                return
            end
        end
    end
end

function Raid:HandleGearInspectReady(event, guid)
    if self.INSPECT_READY then
        self:INSPECT_READY(event, guid)
    end
    local pending = self.gearInspectPending
    if not pending then return end
    if guid and pending ~= guid then return end
    for _, player in ipairs(self.roster or {}) do
        if player.guid == guid
            or (not guid and (player.guid or player.name) == pending)
        then
            self:CaptureGearInspectUnit(player)
            break
        end
    end
    self.gearInspectPending = nil
    self.lastGlobalInspectAt = GetTime()
    if self.gearInspectView and self.gearInspectView:IsShown() then
        self:RefreshGearInspectView(false)
    end
end

function Raid:CreateGearInspectView()
    if self.gearInspectView then return self.gearInspectView end
    local view = CreateFrame("Frame", nil, self.assignmentPanel)
    view:SetPoint("TOPLEFT", 6, -8)
    view:SetPoint("BOTTOMRIGHT", -6, 8)
    view.HeaderBackground =
        view:CreateTexture(nil, "BACKGROUND")
    view.HeaderBackground:SetTexture(WHITE)
    view.HeaderBackground:SetPoint("TOPLEFT", 0, 0)
    view.HeaderBackground:SetPoint("TOPRIGHT", 0, 0)
    view.HeaderBackground:SetHeight(30)
    view.HeaderBackground:SetVertexColor(.035, .105, .145, .98)
    view.Summary = Font(view, 9, "accent", "")
    view.Summary:SetPoint("TOPLEFT", 7, -10)
    view.Summary:SetWidth(130)
    view.Summary:SetJustifyH("LEFT")
    view.GearScoreHeader = Font(view, 8, "accent", "GS")
    view.GearScoreHeader:SetPoint("TOPLEFT", 142, -10)
    view.GearScoreHeader:SetWidth(38)
    view.GearScoreHeader:SetJustifyH("RIGHT")
    view.ItemLevelHeader = Font(view, 8, "accent", "ILVL")
    view.ItemLevelHeader:SetPoint("TOPLEFT", 184, -10)
    view.ItemLevelHeader:SetWidth(31)
    view.ItemLevelHeader:SetJustifyH("RIGHT")
    view.Headers = {}
    for index, definition in ipairs(GEAR_INSPECT_SLOTS) do
        local slotLabel = definition.label
        local header = CreateFrame("Frame", nil, view)
        PixelSetSize(header, 31, 28)
        header:SetPoint(
            "TOPRIGHT",
            -((#GEAR_INSPECT_SLOTS - index) * 33), -1)
        header.Background = header:CreateTexture(nil, "BACKGROUND")
        header.Background:SetAllPoints()
        header.Background:SetTexture(WHITE)
        header.Background:SetVertexColor(
            index % 2 == 0 and .045 or .055,
            index % 2 == 0 and .14 or .16,
            index % 2 == 0 and .19 or .215, 1)
        header.Icon = header:CreateTexture(nil, "ARTWORK")
        local texture
        if GetInventorySlotInfo then
            local _, slotTexture =
                GetInventorySlotInfo(definition.token)
            texture = slotTexture
        end
        header.Icon:SetTexture(
            texture or "Interface\\Icons\\INV_Misc_QuestionMark")
        PixelSetSize(header.Icon, 20, 20)
        header.Icon:SetPoint("CENTER")
        header.Icon:SetDesaturated(true)
        header.Icon:SetAlpha(.62)
        header:EnableMouse(true)
        header:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(slotLabel)
            GameTooltip:Show()
        end)
        header:SetScript("OnLeave", function() GameTooltip:Hide() end)
        view.Headers[index] = header
    end
    view.Scroll, view.Content = CreateScrollArea(view)
    view.Scroll:SetPoint("TOPLEFT", 0, -32)
    view.Scroll:SetPoint("BOTTOMRIGHT", 0, 0)
    view.Content:SetWidth(790)
    view.Rows = {}
    view:SetScript("OnUpdate", function(self, elapsed)
        self.inspectElapsed = (self.inspectElapsed or 0) + elapsed
        self.rescanElapsed = (self.rescanElapsed or 0) + elapsed
        if self.inspectElapsed >= 2 then
            self.inspectElapsed = 0
            Raid:ProcessGearInspectQueue()
        end
        if self.rescanElapsed >= 60 then
            self.rescanElapsed = 0
            Raid:QueueGearInspections()
        end
    end)
    view:Hide()
    self.gearInspectView = view
    return view
end

function Raid:CreateGearInspectRow(index, view)
    local row = CreateFrame("Frame", nil, view.Content)
    row:SetHeight(34)
    row.Bg = row:CreateTexture(nil, "BACKGROUND")
    row.Bg:SetAllPoints()
    row.Bg:SetTexture(WHITE)
    row.Bg:SetVertexColor(
        index % 2 == 0 and .025 or .035,
        index % 2 == 0 and .045 or .06,
        index % 2 == 0 and .06 or .075, .92)
    row.Name = Font(row, 10, "text", "")
    row.Name:SetPoint("LEFT", 7, 0)
    row.Name:SetWidth(132)
    row.Name:SetJustifyH("LEFT")
    row.GearScore = Font(row, 9, "muted", "")
    row.GearScore:SetPoint("LEFT", 142, 0)
    row.GearScore:SetWidth(38)
    row.GearScore:SetJustifyH("RIGHT")
    row.ItemLevel = Font(row, 9, "accent", "")
    row.ItemLevel:SetPoint("LEFT", 184, 0)
    row.ItemLevel:SetWidth(31)
    row.ItemLevel:SetJustifyH("RIGHT")
    row.Cells = {}
    for slotIndex, definition in ipairs(GEAR_INSPECT_SLOTS) do
        local cell = BackdropFrame("Button", nil, row)
        PixelSetSize(cell, 30, 30)
        cell:SetPoint(
            "RIGHT",
            -((#GEAR_INSPECT_SLOTS - slotIndex) * 33), 0)
        cell:SetBackdrop({
            bgFile = WHITE,
            edgeFile = WHITE,
            edgeSize = Pixel(1),
        })
        InstallPixelBorder(cell)
        cell:SetBackdropColor(.008, .014, .019, .76)
        cell:SetBackdropBorderColor(.12, .16, .19, .75)
        cell.Icon = cell:CreateTexture(nil, "ARTWORK")
        cell.Icon:SetAllPoints()
        cell.Icon:SetTexture(
            "Interface\\Icons\\INV_Misc_QuestionMark")
        cell.Icon:SetAlpha(.18)
        cell.Level = Font(cell, 8, "text", "")
        cell.Level:SetPoint("BOTTOMRIGHT", -1, 1)
        cell.Level:SetShadowColor(0, 0, 0, 1)
        cell:SetScript("OnEnter", function(self)
            if not self.link then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        end)
        cell:SetScript("OnLeave", function() GameTooltip:Hide() end)
        cell.slotID = definition.id
        row.Cells[slotIndex] = cell
    end
    view.Rows[index] = row
    return row
end

function Raid:RefreshGearInspectView(queueScan)
    local view = self:CreateGearInspectView()
    view:Show()
    view.Content:SetWidth(math.max(
        1, (view.Scroll:GetWidth() or view:GetWidth() or 790) - 2))
    if queueScan ~= false
        and (not self.gearInspectQueue
            or #self.gearInspectQueue == 0)
    then
        self:QueueGearInspections()
    end
    self.gearInspectCache = self.gearInspectCache or {}
    local inspected, addonReported, locallyInspected = 0, 0, 0
    for index, player in ipairs(self.roster or {}) do
        local row = view.Rows[index]
            or self:CreateGearInspectRow(index, view)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -((index - 1) * 35))
        row:SetPoint("TOPRIGHT", 0, -((index - 1) * 35))
        SetClassText(row.Name, player.name, player.class)
        row.Bg:SetVertexColor(
            GetClassRowColor(player.class, index % 2 == 0))
        row:SetAlpha(player.online == false and .35 or 1)
        row.GearScore:SetText(
            player.gearScore and tostring(player.gearScore) or "—")
        local data =
            self.gearInspectCache[player.guid or player.name]
        row.ItemLevel:SetText(
            data and data.averageLevel
                and tostring(data.averageLevel) or "—")
        if data then
            inspected = inspected + 1
            if data.source == "ADDON" then
                addonReported = addonReported + 1
            else
                locallyInspected = locallyInspected + 1
            end
        end
        for slotIndex, definition in ipairs(GEAR_INSPECT_SLOTS) do
            local cell = row.Cells[slotIndex]
            local item = data and data.items[definition.id]
            cell.link = item and item.link
            cell.Icon:SetTexture(
                item and item.texture
                    or "Interface\\Icons\\INV_Misc_QuestionMark")
            cell.Icon:SetAlpha(item and item.link and 1 or .14)
            cell.Level:SetText(
                item and item.level and tostring(item.level) or "")
            local qualityColor = item and item.quality
                and ITEM_QUALITY_COLORS
                and ITEM_QUALITY_COLORS[item.quality]
            cell:SetBackdropBorderColor(
                qualityColor and qualityColor.r or .12,
                qualityColor and qualityColor.g or .16,
                qualityColor and qualityColor.b or .19,
                qualityColor and .95 or .55)
            cell.Level:SetTextColor(
                qualityColor and qualityColor.r or MUTED[1],
                qualityColor and qualityColor.g or MUTED[2],
                qualityColor and qualityColor.b or MUTED[3],
                1)
        end
        row:Show()
    end
    for index = #(self.roster or {}) + 1, #view.Rows do
        view.Rows[index]:Hide()
    end
    view.Content:SetHeight(math.max(
        1, #(self.roster or {}) * 35))
    view.Summary:SetText(
        ("%d/%d · %d ADDON · %d INSPECT")
            :format(
                inspected, #(self.roster or {}),
                addonReported, locallyInspected))
    self.assignmentTitle:SetText("GEAR INSPECT")
end

function Raid:CreateAboutView()
    if self.aboutView then return self.aboutView end
    local view = CreateFrame("Frame", nil, self.assignmentPanel)
    view:SetPoint("TOPLEFT", 22, -24)
    view:SetPoint("BOTTOMRIGHT", -22, 24)

    view.Icon = view:CreateTexture(nil, "ARTWORK")
    view.Icon:SetTexture("Interface\\Icons\\INV_BannerPVP_02")
    PixelSetSize(view.Icon, 64, 64)
    view.Icon:SetPoint("TOPLEFT")

    view.Name = Font(view, 20, "accent", "LUNARAIDS")
    view.Name:SetPoint("TOPLEFT", view.Icon, "TOPRIGHT", 16, -4)
    local metadata = C_AddOns and C_AddOns.GetAddOnMetadata
        or GetAddOnMetadata
    local version = metadata
        and metadata("LunaRaids", "Version") or "0.1.0"
    view.Version = Font(
        view, 9, "muted", "Version " .. (version or "0.1.0"))
    view.Version:SetPoint("TOPLEFT", view.Name, "BOTTOMLEFT", 1, -6)

    view.Credit = Font(
        view, 11, "text",
        "Developed by Wuild together with the guild Voracious "
            .. "on Thunderstrike.")
    view.Credit:SetPoint("TOPLEFT", 0, -92)
    view.Credit:SetPoint("RIGHT", -10, 0)
    view.Credit:SetJustifyH("LEFT")

    view.Description = Font(
        view, 10, "muted",
        "A collaborative raid-planning and assignment tool built for "
            .. "Vanilla and The Burning Crusade.")
    view.Description:SetPoint("TOPLEFT", 0, -122)
    view.Description:SetPoint("RIGHT", -10, 0)
    view.Description:SetJustifyH("LEFT")

    view.Divider = view:CreateTexture(nil, "ARTWORK")
    view.Divider:SetTexture(WHITE)
    view.Divider:SetPoint("TOPLEFT", 0, -164)
    view.Divider:SetPoint("TOPRIGHT", 0, -164)
    SetPixelHeight(view.Divider, 1)
    view.Divider:SetVertexColor(.12, .28, .38, .9)

    view.GitHubLabel = Font(view, 9, "muted", "SOURCE CODE")
    view.GitHubLabel:SetPoint("TOPLEFT", 0, -192)
    view.GitHub = EditField(
        view, 520, "https://github.com/Wuild/LunaRaids")
    view.GitHub:SetPoint("TOPLEFT", 0, -210)
    view.GitHub:SetPoint("TOPRIGHT", 0, -210)
    view.GitHub:SetText("https://github.com/Wuild/LunaRaids")
    view.GitHub:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)

    view.PatreonLabel = Font(view, 9, "muted", "SUPPORT DEVELOPMENT")
    view.PatreonLabel:SetPoint("TOPLEFT", 0, -264)
    view.Patreon = EditField(
        view, 520, "https://www.patreon.com/wuild")
    view.Patreon:SetPoint("TOPLEFT", 0, -282)
    view.Patreon:SetPoint("TOPRIGHT", 0, -282)
    view.Patreon:SetText("https://www.patreon.com/wuild")
    view.Patreon:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)

    view.CopyHint = Font(
        view, 9, "muted",
        "Click a link, then press Ctrl+C to copy it.")
    view.CopyHint:SetPoint("TOPLEFT", 1, -324)
    view:Hide()
    self.aboutView = view
    return view
end

function Raid:RefreshAboutView()
    self:CreateAboutView():Show()
end

function GearInspect:OnEnable()
    self:RegisterEvent("INSPECT_READY", function(event, ...)
        Raid:HandleGearInspectReady(event, ...)
    end)
end

function GearInspect:OnDisable()
    self:UnregisterAllEvents()
end

