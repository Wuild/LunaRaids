local _, Raid = ...
local UI = Raid.UI
local ReadyCheck = Raid:NewModule("ReadyCheck", "AceEvent-3.0")

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
local function WeaponEnchantTooltipName(unit, slot, fallback)
    if C_TooltipInfo and C_TooltipInfo.GetInventoryItem then
        local tooltip = C_TooltipInfo.GetInventoryItem(unit, slot)
        for index, line in ipairs(tooltip and tooltip.lines or {}) do
            local text = line.leftText
            local color = line.leftColor
            if index > 1 and text and text ~= ""
                and color and color.g and color.r and color.b
                and color.g > color.r * 1.25
                and color.g > color.b * 1.15
            then
                return text
            end
        end
    end
    return fallback
end

local function AddWeaponEnchantDetail(
    found, unit, slot, enchantID, handLabel)
    local enchantName = WeaponEnchantTooltipName(
        unit, slot, handLabel .. " weapon enhancement")
    local normalizedName = enchantName and enchantName:lower() or ""
    local isWeaponConsumable =
        normalizedName:find(" oil", 1, true)
        or normalizedName:find("sharpening stone", 1, true)
        or normalizedName:find("weightstone", 1, true)
        or normalizedName:find("weapon coating", 1, true)
        or (
            normalizedName:find("windfury", 1, true)
            and not normalizedName:find("totem", 1, true))
    if not isWeaponConsumable then
        return false
    end
    local details = found.details.weapon or {}
    found.details.weapon = details
    details[#details + 1] = {
        enchantID = enchantID,
        icon = GetInventoryItemTexture
            and GetInventoryItemTexture(unit, slot)
            or READY_CHECK_COLUMNS[#READY_CHECK_COLUMNS - 1].icon,
        name = enchantName,
        hand = slot == 16 and "MAIN" or "OFF",
        inventoryUnit = unit,
        inventorySlot = slot,
    }
    return true
end

local function ScanReadyCheckAuras(unit)
    if not unit or not UnitExists(unit) then return nil end
    local found = { details = {} }
    for index = 1, 60 do
        local spellID, icon, auraName
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local aura =
                C_UnitAuras.GetAuraDataByIndex(unit, index, "HELPFUL")
            if not aura then break end
            spellID, icon, auraName = aura.spellId, aura.icon, aura.name
        elseif UnitBuff then
            local name, texture, _, _, _, _, _, _, _, id =
                UnitBuff(unit, index)
            if not name then break end
            spellID, icon, auraName = id, texture, name
        end
        if spellID
            and (not issecretvalue or not issecretvalue(spellID))
        then
            local matches = READY_CHECK_BY_SPELL[spellID]
            if not matches and icon == 136000 then
                matches = READY_CHECK_FOOD_MATCHES
            end
            for _, column in ipairs(matches or {}) do
                found[column.key] = true
                local details = found.details[column.key] or {}
                found.details[column.key] = details
                local duplicate
                for _, detail in ipairs(details) do
                    if detail.spellID == spellID then
                        duplicate = true
                        break
                    end
                end
                if not duplicate then
                    details[#details + 1] = {
                        spellID = spellID,
                        icon = icon or column.icon,
                        name = auraName or column.label,
                        unit = unit,
                        auraIndex = index,
                        filter = "HELPFUL",
                    }
                end
            end
        end
    end
    if UnitIsUnit and UnitIsUnit(unit, "player") then
        if GetWeaponEnchantInfo then
            local mainHand, _, _, mainHandID,
                offHand, _, _, offHandID =
                GetWeaponEnchantInfo()
            local weaponConsumable
            if mainHand then
                weaponConsumable =
                    AddWeaponEnchantDetail(
                        found, unit, 16, mainHandID, "Main-hand")
                    or weaponConsumable
            end
            if offHand then
                weaponConsumable =
                    AddWeaponEnchantDetail(
                        found, unit, 17, offHandID, "Off-hand")
                    or weaponConsumable
            end
            found.weapon = weaponConsumable or false
        end
    end
    return found
end

function Raid:GetReadyCheckAuras(unit, force)
    if not unit then return nil end
    self.readyCheckAuraCache = self.readyCheckAuraCache or {}
    local now = GetTime and GetTime() or 0
    local cached = self.readyCheckAuraCache[unit]
    if not force and cached and now - cached.updatedAt < 5 then
        return cached.checks
    end
    local checks = ScanReadyCheckAuras(unit)
    self.readyCheckAuraCache[unit] = {
        checks = checks,
        updatedAt = now,
    }
    return checks
end

function Raid:BroadcastReadyCheckStatus()
    if not self.QueueSync or not self:IsInLiveGroup() then return end
    local checks = self:GetReadyCheckAuras("player", true)
    if not checks then return end
    local mask = 0
    for index, column in ipairs(READY_CHECK_COLUMNS) do
        if checks[column.key] then
            mask = mask + (2 ^ (index - 1))
        end
    end
    local weaponDetails = checks.details
        and checks.details.weapon or {}
    local mainHand, offHand
    for _, detail in ipairs(weaponDetails) do
        if detail.hand == "MAIN" then
            mainHand = detail
        elseif detail.hand == "OFF" then
            offHand = detail
        end
    end
    self:QueueSync("CHECK", {
        UnitName("player") or "", mask,
        mainHand and mainHand.name or "",
        mainHand and mainHand.icon or "",
        offHand and offHand.name or "",
        offHand and offHand.icon or "",
    })
end

function Raid:ReceiveReadyCheckStatus(
    name, mask, mainHandName, mainHandIcon, offHandName, offHandIcon)
    if not name or name == "" then return end
    mask = tonumber(mask) or 0
    self.readyCheckPeerData = self.readyCheckPeerData or {}
    local shortName = name:match("^[^-]+") or name
    local checks = self.readyCheckPeerData[name]
        or self.readyCheckPeerData[shortName]
        or { details = {} }
    checks.details = checks.details or {}
    for index, column in ipairs(READY_CHECK_COLUMNS) do
        if column.key ~= "durability" then
            checks[column.key] =
                math.floor(mask / (2 ^ (index - 1))) % 2 == 1
        end
    end
    if checks.weapon then
        local weaponDetails = {}
        local function AddPeerWeapon(enchantName, icon, handLabel)
            if not enchantName or enchantName == "" then return end
            weaponDetails[#weaponDetails + 1] = {
                name = enchantName,
                icon = tonumber(icon)
                    or READY_CHECK_COLUMNS[
                        #READY_CHECK_COLUMNS - 1].icon,
                handLabel = handLabel,
            }
        end
        AddPeerWeapon(mainHandName, mainHandIcon, "Main-hand")
        AddPeerWeapon(offHandName, offHandIcon, "Off-hand")
        if #weaponDetails > 0 then
            checks.details.weapon = weaponDetails
        end
    end
    self.readyCheckPeerData[name] = checks
    self.readyCheckPeerData[shortName] = checks
    self:ScheduleReadyCheckRefresh()
end

function Raid:ReceiveLibDurability(percent, broken, sender)
    if not sender or sender == "" then return end
    percent = math.max(
        0, math.min(100, math.floor((tonumber(percent) or 0) + .5)))
    self.readyCheckPeerData = self.readyCheckPeerData or {}
    local shortName = sender:match("^[^-]+") or sender
    local checks = self.readyCheckPeerData[sender]
        or self.readyCheckPeerData[shortName]
        or { details = {} }
    checks.details = checks.details or {}
    checks.durabilityPercent = percent
    checks.durability = percent >= 30
    checks.brokenItems = math.max(0, tonumber(broken) or 0)
    checks.durabilitySource = "LIB"
    self.readyCheckPeerData[sender] = checks
    self.readyCheckPeerData[shortName] = checks
    self:ScheduleReadyCheckRefresh()
end

function Raid:InitializeLibDurability()
    if self.libDurability then return end
    local library = LibStub
        and LibStub:GetLibrary("LibDurability", true)
    if not library then return end
    self.libDurability = library
    library:Register(self, "ReceiveLibDurability")
end

function Raid:RequestGroupDurability()
    self:InitializeLibDurability()
    if self.libDurability then
        self.libDurability:RequestDurability()
    end
end

function Raid:ScheduleReadyCheckRefresh()
    if self.readyCheckRefreshPending then return end
    local popupShown = self.readyCheckWindow
        and self.readyCheckWindow:IsShown()
    local embeddedShown = self.raidStatusView
        and self.raidStatusView:IsShown()
    if not popupShown and not embeddedShown then return end
    self.readyCheckRefreshPending = true
    if C_Timer and C_Timer.After then
        C_Timer.After(.10, function()
            Raid.readyCheckRefreshPending = nil
            if Raid.readyCheckWindow
                and Raid.readyCheckWindow:IsShown() then
                Raid:RefreshReadyCheckWindow()
            end
            if Raid.raidStatusView
                and Raid.raidStatusView:IsShown() then
                Raid:RefreshReadyCheckWindow(Raid.raidStatusView)
            end
        end)
    else
        self.readyCheckRefreshPending = nil
        if popupShown then self:RefreshReadyCheckWindow() end
        if embeddedShown then
            self:RefreshReadyCheckWindow(self.raidStatusView)
        end
    end
end

