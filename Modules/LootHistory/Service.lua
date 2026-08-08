local _, Raid = ...

local SELF_LOOT_FORMATS = {
    LOOT_ITEM_SELF,
    LOOT_ITEM_MULTIPLE_SELF,
}

local OTHER_LOOT_FORMATS = {
    LOOT_ITEM,
    LOOT_ITEM_MULTIPLE,
}

local function NormalizeFormat(format)
    if type(format) ~= "string" then return end
    return format:gsub("%%(%d+)%$s", "%%s")
        :gsub("%%(%d+)%$d", "%%d")
end

local function IsSelfLootMessage(message, itemLink)
    local linkStart = message:find(itemLink, 1, true)
    if not linkStart then return false end
    for _, rawFormat in ipairs(SELF_LOOT_FORMATS) do
        local format = NormalizeFormat(rawFormat)
        local prefix = format and format:match("^(.-)%%s")
        if prefix and message:sub(1, #prefix) == prefix
            and linkStart == #prefix + 1
        then
            return true
        end
    end
    return false
end

local function CleanPlayerName(value)
    if not value then return end
    local linked = value:match("|h%[([^%]]+)%]|h")
    value = linked or value
    value = value:gsub("|c%x%x%x%x%x%x%x%x", "")
        :gsub("|r", "")
    value = strtrim(value)
    return value ~= "" and value or nil
end

local function FindLootRecipient(message, itemLink)
    if IsSelfLootMessage(message, itemLink) then
        return GetUnitName and GetUnitName("player", true)
            or UnitName("player")
    end
    local linkStart = message:find(itemLink, 1, true)
    if not linkStart then return end
    local beforeItem = message:sub(1, linkStart - 1)
    for _, rawFormat in ipairs(OTHER_LOOT_FORMATS) do
        local format = NormalizeFormat(rawFormat)
        local middle = format and format:match("^%%s(.-)%%s")
        if middle and #beforeItem >= #middle
            and beforeItem:sub(-#middle) == middle
        then
            return CleanPlayerName(
                beforeItem:sub(1, #beforeItem - #middle))
        end
    end
end

local function FindItemLink(message)
    return message and message:match(
        "(|c%x+|Hitem:.-|h%[.-%]|h|r)")
        or message and message:match("(|Hitem:.-|h%[.-%]|h)")
end

local function ShortName(name)
    return tostring(name or ""):match("^[^-]+") or ""
end

local function SameRecipient(left, right)
    return ShortName(left):lower() == ShortName(right):lower()
end

local TRACKED_ITEM_COLORS = {
    ["0070dd"] = 3, -- Rare
    ["a335ee"] = 4, -- Epic
    ["ff8000"] = 5, -- Legendary
}

local function IsTrackedLoot(itemLink, itemID)
    local color = type(itemLink) == "string"
        and itemLink:match("^|cff(%x%x%x%x%x%x)")
    local quality = color and TRACKED_ITEM_COLORS[color:lower()]
    if not quality and GetItemInfo then
        quality = select(3, GetItemInfo(itemLink or itemID))
    end
    quality = tonumber(quality)
    return quality and quality >= 3 and quality <= 5
end

function Raid:IsRaidLootRecordingActive()
    if not self.db or not self.db.raidLocked or self:IsRaidReadOnly() then
        return false
    end
    local instanceRaid = self.FindRaidForCurrentInstance
        and self:FindRaidForCurrentInstance()
    return instanceRaid ~= nil
        and instanceRaid.key == self.db.activeRaid
end

function Raid:GetLootReserveSnapshot(itemID, winner)
    local lootReserve = _G.LootReserve
    itemID = tonumber(itemID)
    if not lootReserve or not itemID then return end
    local reserveItemID = lootReserve.Data
        and lootReserve.Data.GetToken
        and lootReserve.Data:GetToken(itemID) or itemID
    reserveItemID = tonumber(reserveItemID) or itemID
    local players, blind, sessionServer
    local server = lootReserve.Server
    local serverSession = server and server.CurrentSession
    if serverSession then
        local reserve = serverSession.ItemReserves
            and serverSession.ItemReserves[reserveItemID]
        players = reserve and reserve.Players or {}
        blind = serverSession.Settings and serverSession.Settings.Blind == true
        sessionServer = GetUnitName and GetUnitName("player", true)
            or UnitName("player")
    elseif lootReserve.Client and lootReserve.Client.SessionServer then
        local client = lootReserve.Client
        players = client.GetItemReservers
            and client:GetItemReservers(reserveItemID) or {}
        blind = client.Blind == true
        sessionServer = client.SessionServer
    else
        return
    end
    if blind and not serverSession and #players == 0 then
        return {
            itemID = reserveItemID, blind = true, available = false,
            sessionServer = sessionServer, reservers = {},
            totalReserves = 0, uniqueReservers = 0,
        }
    end
    local counts, names = {}, {}
    for _, player in ipairs(players or {}) do
        local key = ShortName(player):lower()
        if key ~= "" then
            if not counts[key] then
                counts[key] = { player = player, count = 0 }
                names[#names + 1] = key
            end
            counts[key].count = counts[key].count + 1
        end
    end
    table.sort(names)
    local reservers, total = {}, 0
    for _, key in ipairs(names) do
        reservers[#reservers + 1] = counts[key]
        total = total + counts[key].count
    end
    local winnerReserved = false
    if winner then
        winnerReserved = counts[ShortName(winner):lower()] ~= nil
    end
    return {
        itemID = reserveItemID, blind = blind, available = true,
        sessionServer = sessionServer, reservers = reservers,
        totalReserves = total, uniqueReservers = #reservers,
        winnerReserved = winnerReserved,
    }
end

function Raid:ApplyLootReserveSnapshot(entry)
    if not entry then return end
    local snapshot = self:GetLootReserveSnapshot(entry.itemID, entry.player)
    if snapshot then entry.lootReserve = snapshot end
end

local function CopyGargulRolls(source)
    local rolls = {}
    for _, roll in ipairs(type(source) == "table" and source or {}) do
        rolls[#rolls + 1] = {
            player = roll.player,
            class = roll.class,
            amount = tonumber(roll.amount),
            classification = roll.classification,
            priority = tonumber(roll.priority),
            plusOneState = tonumber(roll.plusOneState),
            time = tonumber(roll.time),
        }
    end
    table.sort(rolls, function(left, right)
        if (left.priority or 0) ~= (right.priority or 0) then
            return (left.priority or 0) > (right.priority or 0)
        end
        if (left.amount or 0) ~= (right.amount or 0) then
            return (left.amount or 0) > (right.amount or 0)
        end
        return (left.time or 0) < (right.time or 0)
    end)
    return rolls
end

local GROUP_ROLL_TYPES = {
    [0] = "PASS",
    [1] = "NEED",
    [2] = "GREED",
    [3] = "DISENCHANT",
    [4] = "TRANSMOG",
}

local function GroupRollTypeName(value)
    if Enum and Enum.LootRollType then
        for name, enumValue in pairs(Enum.LootRollType) do
            if enumValue == value then return name:upper() end
        end
    end
    return GROUP_ROLL_TYPES[tonumber(value)]
        or tostring(value or "ROLL")
end

local function FormatCaptures(message, format)
    if type(message) ~= "string" or type(format) ~= "string" then return end
    format = NormalizeFormat(format)
    local tokens = {}
    format = format:gsub("%%[sd]", function(token)
        tokens[#tokens + 1] = token
        return "\1" .. #tokens .. "\2"
    end)
    format = format:gsub("([%(%)%.%+%-%*%?%[%]%^%$%%])", "%%%1")
    for index, token in ipairs(tokens) do
        local capture = token == "%d" and "(%d+)" or "(.-)"
        format = format:gsub("\1" .. index .. "\2", capture)
    end
    return message:match("^" .. format .. "$")
end

local function GroupLootChatFormats()
    return {
        { NEED, LOOT_ROLL_ROLLED_NEED },
        { NEED, LOOT_ROLL_NEED },
        { GREED, LOOT_ROLL_ROLLED_GREED },
        { GREED, LOOT_ROLL_GREED },
        { DISENCHANT, LOOT_ROLL_ROLLED_DE },
        { DISENCHANT, LOOT_ROLL_DISENCHANT },
        { PASS, LOOT_ROLL_PASSED },
    }
end

function Raid:EnsureGroupLootEntry(rollID, itemLink)
    if not itemLink then return end
    if not self:IsRaidLootRecordingActive() then return end
    if not IsTrackedLoot(itemLink) then return end
    if not self.db.activeSavedRaid
        or not self.db.savedRaids[self.db.activeSavedRaid]
    then
        self:SaveCurrentRaid("", true)
    end
    local saved = self.db.activeSavedRaid
        and self.db.savedRaids[self.db.activeSavedRaid]
    if not saved then return end
    saved.lootHistory = saved.lootHistory or {}
    for _, entry in ipairs(saved.lootHistory) do
        if entry.groupLootRollID == rollID then return entry end
    end
    local raid, encounter = self:GetRaid(), self:GetEncounter()
    local entry = {
        source = "GROUP_LOOT",
        groupLootRollID = rollID,
        itemLink = itemLink,
        itemID = tonumber(itemLink:match("item:(%d+)")),
        quantity = 1,
        receivedAt = GetServerTime and GetServerTime()
            or time and time() or 0,
        encounterIndex = self.db.activeEncounter,
        encounterName = encounter and encounter.name,
        raidKey = raid and raid.key,
        received = false,
        rolls = {},
        rollCount = 0,
    }
    saved.lootHistory[#saved.lootHistory + 1] = entry
    self:ApplyLootReserveSnapshot(entry)
    return entry
end

function Raid:FindPendingGroupLootEntry(itemLink)
    local saved = self.db.activeSavedRaid
        and self.db.savedRaids[self.db.activeSavedRaid]
    local itemID = itemLink and tonumber(itemLink:match("item:(%d+)"))
    for index = #(saved and saved.lootHistory or {}), 1, -1 do
        local entry = saved.lootHistory[index]
        if entry.groupLootRollID and entry.itemID == itemID
            and not entry.lootConfirmed
        then
            return entry
        end
    end
end

function Raid:HandleClassicGroupLootMessage(message, itemLink)
    local entry = self:FindPendingGroupLootEntry(itemLink)
    if not entry then return false end
    for _, definition in ipairs(GroupLootChatFormats()) do
        local classification, format = definition[1], definition[2]
        if format then
            local first, second, third = FormatCaptures(message, format)
            if first then
                local values = { first, second, third }
                local player, amount
                for _, value in ipairs(values) do
                    if type(value) == "string" then
                        if value:find("|Hitem:", 1, true) then
                            -- Item capture; the roll is already associated.
                        elseif tonumber(value) then
                            amount = tonumber(value)
                        elseif value ~= "" then
                            player = CleanPlayerName(value)
                        end
                    end
                end
                player = player or (GetUnitName
                    and GetUnitName("player", true) or UnitName("player"))
                local existing
                for _, roll in ipairs(entry.rolls or {}) do
                    if SameRecipient(roll.player, player) then
                        existing = roll
                        break
                    end
                end
                local roll = existing or { player = player }
                roll.classification = classification
                roll.amount = amount or roll.amount
                if not existing then
                    entry.rolls[#entry.rolls + 1] = roll
                end
                entry.rollCount = #entry.rolls
                return true
            end
        end
    end
    for _, definition in ipairs({
        { LOOT_ROLL_YOU_WON, true },
        { LOOT_ROLL_WON, false },
    }) do
        local format, selfWon = definition[1], definition[2]
        if format then
            local first, second = FormatCaptures(message, format)
            if first then
                local player = selfWon and (GetUnitName
                    and GetUnitName("player", true) or UnitName("player"))
                if not player then
                    player = first and not first:find("|Hitem:", 1, true)
                        and CleanPlayerName(first)
                        or second and not second:find("|Hitem:", 1, true)
                            and CleanPlayerName(second)
                end
                entry.player = player or entry.player
                entry.rollComplete = true
                self:ApplyLootReserveSnapshot(entry)
                return true
            end
        end
    end
    return false
end

function Raid:InitializeGroupLootIntegration()
    if self.groupLootIntegrationInitialized then return end
    self.groupLootIntegrationInitialized = true
    self:RegisterEvent("START_LOOT_ROLL", "HandleGroupLootStarted")
    if C_LootHistory and C_LootHistory.GetNumItems then
        for _, event in ipairs({
            "LOOT_HISTORY_FULL_UPDATE",
            "LOOT_HISTORY_ROLL_CHANGED",
            "LOOT_HISTORY_ROLL_COMPLETE",
        }) do
            pcall(function()
                self:RegisterEvent(event, "HandleGroupLootHistoryUpdate")
            end)
        end
    end
end

function Raid:HandleGroupLootStarted(_, rollID)
    if not self:IsRaidLootRecordingActive() then return end
    self.pendingGroupLootRolls = self.pendingGroupLootRolls or {}
    local itemLink = GetLootRollItemLink and GetLootRollItemLink(rollID)
    if itemLink then
        self.pendingGroupLootRolls[rollID] = itemLink
        self:EnsureGroupLootEntry(rollID, itemLink)
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            Raid:HandleGroupLootHistoryUpdate()
        end)
    else
        self:HandleGroupLootHistoryUpdate()
    end
end

function Raid:HandleGroupLootHistoryUpdate()
    if not self:IsRaidLootRecordingActive()
        or not C_LootHistory or not C_LootHistory.GetNumItems
    then
        return
    end
    if not self.db.activeSavedRaid
        or not self.db.savedRaids[self.db.activeSavedRaid]
    then
        self:SaveCurrentRaid("", true)
    end
    local saved = self.db.activeSavedRaid
        and self.db.savedRaids[self.db.activeSavedRaid]
    if not saved then return end
    saved.lootHistory = saved.lootHistory or {}
    local count = tonumber(C_LootHistory.GetNumItems()) or 0
    for itemIndex = 1, count do
        local rollID, itemLink, playerCount, isDone, winnerIndex =
            C_LootHistory.GetItem(itemIndex)
        if rollID and itemLink and IsTrackedLoot(itemLink) then
            local entry
            for _, candidate in ipairs(saved.lootHistory) do
                if candidate.groupLootRollID == rollID then
                    entry = candidate
                    break
                end
            end
            local raid, encounter = self:GetRaid(), self:GetEncounter()
            if not entry then
                local itemID = tonumber(itemLink:match("item:(%d+)"))
                for historyIndex = #saved.lootHistory, 1, -1 do
                    local candidate = saved.lootHistory[historyIndex]
                    if candidate.gargulChecksum
                        and not candidate.groupLootRollID
                        and candidate.itemID == itemID
                        and math.abs((candidate.receivedAt or 0)
                            - (GetServerTime and GetServerTime()
                                or time and time() or 0)) <= 300
                    then
                        entry = candidate
                        entry.groupLootRollID = rollID
                        entry.source = "GARGUL_GROUP_LOOT"
                        break
                    end
                end
            end
            if not entry then
                entry = {
                    source = "GROUP_LOOT",
                    groupLootRollID = rollID,
                    itemLink = itemLink,
                    itemID = tonumber(itemLink:match("item:(%d+)")),
                    quantity = 1,
                    receivedAt = GetServerTime and GetServerTime()
                        or time and time() or 0,
                    encounterIndex = self.db.activeEncounter,
                    encounterName = encounter and encounter.name,
                    raidKey = raid and raid.key,
                    received = false,
                }
                saved.lootHistory[#saved.lootHistory + 1] = entry
                self:ApplyLootReserveSnapshot(entry)
            end
            local rolls, winner
            rolls = {}
            for playerIndex = 1, tonumber(playerCount) or 0 do
                local name, class, rollType, amount, isWinner =
                    C_LootHistory.GetPlayerInfo(itemIndex, playerIndex)
                if name then
                    local roll = {
                        player = name,
                        class = class,
                        amount = tonumber(amount),
                        classification = GroupRollTypeName(rollType),
                        rollType = tonumber(rollType),
                        isWinner = isWinner == true,
                    }
                    rolls[#rolls + 1] = roll
                    if isWinner or winnerIndex == playerIndex then
                        winner = name
                        entry.winningRollType = roll.classification
                    end
                end
            end
            table.sort(rolls, function(left, right)
                if left.isWinner ~= right.isWinner then return left.isWinner end
                if (left.amount or -1) ~= (right.amount or -1) then
                    return (left.amount or -1) > (right.amount or -1)
                end
                return tostring(left.player) < tostring(right.player)
            end)
            entry.rolls = rolls
            entry.rollCount = #rolls
            entry.player = winner or entry.player
            entry.rollComplete = isDone == true
            self:ApplyLootReserveSnapshot(entry)
        end
    end
    saved.savedAt = GetServerTime and GetServerTime()
        or time and time() or saved.savedAt
    if self.activeBossTab == "LOOT" and self.RefreshLootHistory then
        self:RefreshLootHistory()
    end
end

function Raid:InitializeGargulLootIntegration()
    if self.gargulLootIntegrationInitialized then return true end
    local gargul = _G.Gargul
    if not gargul or not gargul.Events
        or type(gargul.Events.register) ~= "function"
    then
        return false
    end
    local registered = gargul.Events:register(
        "LunaRaidsGargulItemAwarded", "GL.ITEM_AWARDED",
        function(_, award)
            Raid:HandleGargulItemAwarded(award)
        end)
    self.gargulLootIntegrationInitialized = registered == true
    return self.gargulLootIntegrationInitialized
end

function Raid:HandleLootAddonLoaded(_, addonName)
    if addonName == "Gargul" then
        self:InitializeGargulLootIntegration()
    elseif addonName == "LootReserve" and self.activeBossTab == "LOOT"
        and self.RefreshLootHistory
    then
        self:RefreshLootHistory()
    end
end

function Raid:HandleGargulItemAwarded(award)
    if not self:IsRaidLootRecordingActive()
        or type(award) ~= "table" or not award.itemLink
        or not award.awardedTo
    then
        return
    end
    if not IsTrackedLoot(award.itemLink, award.itemID) then return end
    if not self.db.activeSavedRaid
        or not self.db.savedRaids[self.db.activeSavedRaid]
    then
        self:SaveCurrentRaid("", true)
    end
    local saved = self.db.activeSavedRaid
        and self.db.savedRaids[self.db.activeSavedRaid]
    if not saved then return end
    saved.lootHistory = saved.lootHistory or {}
    local awardedItemID = tonumber(award.itemID)
        or tonumber(award.itemLink:match("item:(%d+)"))
    local awardedAt = tonumber(award.timestamp)
        or GetServerTime and GetServerTime() or time()
    local entry
    for _, candidate in ipairs(saved.lootHistory) do
        if award.checksum and candidate.gargulChecksum == award.checksum then
            entry = candidate
            break
        end
    end
    if not entry then
        for index = #saved.lootHistory, 1, -1 do
            local candidate = saved.lootHistory[index]
            if candidate.itemID == awardedItemID
                and SameRecipient(candidate.player, award.awardedTo)
                and math.abs((candidate.receivedAt or 0)
                    - awardedAt) <= 300
            then
                entry = candidate
                break
            end
        end
    end
    -- With master loot, CHAT_MSG_LOOT records the temporary holder before
    -- Gargul runs the roll. Reuse the oldest unallocated copy of that item
    -- instead of creating a second record owned by the master looter.
    if not entry then
        for index = 1, #saved.lootHistory do
            local candidate = saved.lootHistory[index]
            if candidate.itemID == awardedItemID
                and not candidate.gargulChecksum
                and not candidate.groupLootRollID
                and candidate.lootConfirmed
                and math.abs((candidate.receivedAt or 0) - awardedAt) <= 7200
            then
                entry = candidate
                break
            end
        end
    end
    local raid, encounter = self:GetRaid(), self:GetEncounter()
    if not entry then
        entry = {
            player = award.awardedTo,
            itemLink = award.itemLink,
            itemID = awardedItemID,
            quantity = 1,
            receivedAt = tonumber(award.timestamp)
                or GetServerTime and GetServerTime() or time(),
            encounterIndex = self.db.activeEncounter,
            encounterName = encounter and encounter.name,
            raidKey = raid and raid.key,
        }
        saved.lootHistory[#saved.lootHistory + 1] = entry
    end
    local reassigned = not SameRecipient(entry.player, award.awardedTo)
    if reassigned and entry.player then
        entry.lootedBy = entry.player
        entry.initiallyLootedAt = entry.receivedAt
    end
    entry.player = award.awardedTo
    entry.source = "GARGUL"
    entry.gargulChecksum = award.checksum
    entry.awardedBy = award.awardedBy
    entry.awardedAt = awardedAt
    if reassigned then
        entry.received = award.received == true
        entry.lootConfirmed = award.received == true
    else
        entry.received = award.received == true or entry.received
    end
    entry.winningRollType = award.winningRollType
    entry.rolls = CopyGargulRolls(award.Rolls)
    entry.rollCount = #entry.rolls
    entry.softReserved = award.SR == true
    entry.offspec = award.OS == true
    entry.wishlisted = award.WL == true
    entry.prioritized = award.PL == true
    entry.boostedRollCost = tonumber(award.BRCost)
    entry.gdkpCost = tonumber(award.GDKPCost)
    self:ApplyLootReserveSnapshot(entry)
    saved.savedAt = GetServerTime and GetServerTime()
        or time and time() or saved.savedAt
    if self.activeBossTab == "LOOT" and self.RefreshLootHistory then
        self:RefreshLootHistory()
    end
end

function Raid:HandleRaidLootMessage(_, message, ...)
    if not self:IsRaidLootRecordingActive()
        or type(message) ~= "string"
    then
        return
    end
    local itemLink = FindItemLink(message)
    if not itemLink then return end
    if not IsTrackedLoot(itemLink) then return end
    if self:HandleClassicGroupLootMessage(message, itemLink) then
        if self.activeBossTab == "LOOT" and self.RefreshLootHistory then
            self:RefreshLootHistory()
        end
        return
    end
    local recipient = FindLootRecipient(message, itemLink)
    if not recipient then return end

    local args = { ... }
    local lineID = args[10]
    self.raidLootLineIDs = self.raidLootLineIDs or {}
    if lineID and self.raidLootLineIDs[lineID] then return end
    if lineID then self.raidLootLineIDs[lineID] = true end

    if not self.db.activeSavedRaid
        or not self.db.savedRaids[self.db.activeSavedRaid]
    then
        self:SaveCurrentRaid("", true)
    end
    local saved = self.db.activeSavedRaid
        and self.db.savedRaids[self.db.activeSavedRaid]
    if not saved then return end
    saved.lootHistory = saved.lootHistory or {}
    local raid = self:GetRaid()
    local encounter = self:GetEncounter()
    local suffix = message:sub(
        (message:find(itemLink, 1, true) or #message) + #itemLink)
    local quantity = tonumber(suffix:match("[xX](%d+)")) or 1
    local existing
    for index = #saved.lootHistory, 1, -1 do
        local candidate = saved.lootHistory[index]
        if (candidate.gargulChecksum or candidate.groupLootRollID)
            and not candidate.lootConfirmed
            and candidate.itemID == tonumber(itemLink:match("item:(%d+)"))
            and SameRecipient(candidate.player, recipient)
            and math.abs((candidate.receivedAt or 0)
                - (GetServerTime and GetServerTime() or time())) <= 300
        then
            existing = candidate
            break
        end
    end
    local lootEntry = existing or {
        player = recipient,
        itemLink = itemLink,
        itemID = tonumber(itemLink:match("item:(%d+)")),
        quantity = quantity,
        receivedAt = GetServerTime and GetServerTime()
            or time and time() or 0,
        encounterIndex = self.db.activeEncounter,
        encounterName = encounter and encounter.name,
        raidKey = raid and raid.key,
    }
    lootEntry.received = true
    lootEntry.lootConfirmed = true
    lootEntry.quantity = quantity
    self:ApplyLootReserveSnapshot(lootEntry)
    if not existing then
        saved.lootHistory[#saved.lootHistory + 1] = lootEntry
    end
    saved.savedAt = GetServerTime and GetServerTime()
        or time and time() or saved.savedAt
    if self.workspaceMode == "ASSIGNMENTS"
        and self.activeBossTab == "LOOT"
        and self.RefreshLootHistory
    then
        self:RefreshLootHistory()
    end
end
