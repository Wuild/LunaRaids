local _, Raid = ...

local PREFIX = "LunaRaids"
local PROTOCOL = "8"

local KIND_TO_WIRE = {
    HELLO = "H", PROFILE = "P", INTEL = "I", CHECK = "k",
    SELECT = "S", CURRENT = "c", PLAN = "A", VALUE = "V", CLEAR = "C",
    SNAP_BEGIN = "B", SNAP_END = "E", COMP = "O",
    MANUAL = "M", MANUALDEL = "D", BOSSSET = "b",
    BOSSRESET = "r", PRESETSET = "p", PRESETRESET = "q",
    PRESETCLEAR = "x", RESET = "R", CLOSE = "X",
    SIM_BEGIN = "Y", SIM_PLAYER = "Z", SIM_END = "y",
    GROUP = "g", GEAR_BEGIN = "j", GEAR = "e", GEAR_END = "f",
    INSPECT_CLAIM = "l", COOLDOWN = "d",
}
local WIRE_TO_KIND = {}
for kind, wire in pairs(KIND_TO_WIRE) do WIRE_TO_KIND[wire] = kind end

local CLASS_TO_WIRE = {
    WARRIOR = "0", PALADIN = "1", HUNTER = "2", ROGUE = "3",
    PRIEST = "4", SHAMAN = "5", MAGE = "6", WARLOCK = "7",
    DRUID = "8",
}
local WIRE_TO_CLASS = {}
for class, wire in pairs(CLASS_TO_WIRE) do WIRE_TO_CLASS[wire] = class end

local ROLE_TO_WIRE = {
    TANK = "T", HEALER = "H", DAMAGER = "D", NONE = "N",
}
local WIRE_TO_ROLE = {}
for role, wire in pairs(ROLE_TO_WIRE) do WIRE_TO_ROLE[wire] = role end

local function Base36(value)
    if value == nil or value == "" then return "" end
    value = math.max(0, math.floor(tonumber(value) or 0))
    if value == 0 then return "0" end
    local digits, result = "0123456789abcdefghijklmnopqrstuvwxyz", ""
    while value > 0 do
        local remainder = value % 36
        result = digits:sub(remainder + 1, remainder + 1) .. result
        value = math.floor(value / 36)
    end
    return result
end

local function FromBase36(value)
    if value == nil or value == "" then return nil end
    return tonumber(value, 36) or 0
end

local function DecodeBase36(value)
    local decoded = FromBase36(value)
    return decoded and tostring(decoded) or ""
end

local function RaidWireMaps()
    if Raid.raidToWire then return Raid.raidToWire, Raid.wireToRaid end
    Raid.raidToWire, Raid.wireToRaid = {}, {}
    local alphabet =
        "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    for index, raid in ipairs(Raid.raids or {}) do
        local wire = alphabet:sub(index, index)
        Raid.raidToWire[raid.key] = wire
        Raid.wireToRaid[wire] = raid.key
    end
    return Raid.raidToWire, Raid.wireToRaid
end

local RAID_FIRST = {
    SELECT = true, CURRENT = true, PLAN = true, VALUE = true, CLEAR = true,
    SNAP_BEGIN = true, SNAP_END = true, COMP = true,
    MANUAL = true, MANUALDEL = true, BOSSSET = true,
    BOSSRESET = true, PRESETSET = true, PRESETRESET = true,
    PRESETCLEAR = true, RESET = true, CLOSE = true,
    SIM_BEGIN = true, SIM_PLAYER = true, SIM_END = true,
    GROUP = true,
}

local ENCOUNTER_SECOND = {
    SELECT = true, CURRENT = true, PLAN = true, VALUE = true, CLEAR = true,
    SNAP_BEGIN = true, SNAP_END = true, BOSSSET = true,
    BOSSRESET = true, PRESETSET = true, PRESETRESET = true,
    PRESETCLEAR = true,
}

local function EncodePlanKey(key)
    if key == "AUTO_MARK" then return "a" end
    local healer = key:match("^S:healer%.raid%.(%d+)$")
    if healer then return "h" .. Base36(healer) end
    local target = key:match("^T:healer%.raid%.(%d+)$")
    if target then return "t" .. Base36(target) end
    local marker = key:match("^M:(%d+)$")
    if marker then return "m" .. Base36(marker) end
    local assignment = key:match("^S:(.+)$")
    if assignment then return "s" .. assignment end
    return key
end

local function DecodePlanKey(key)
    if key == "a" then return "AUTO_MARK" end
    local prefix, value = key:match("^([htm])([0-9a-z]+)$")
    if prefix and value then
        local index = DecodeBase36(value)
        if prefix == "h" then return "S:healer.raid." .. index end
        if prefix == "t" then return "T:healer.raid." .. index end
        return "M:" .. index
    end
    if key:sub(1, 1) == "s" then return "S:" .. key:sub(2) end
    return key
end

local function EncodeSettingKey(key)
    if key == "HEALERS" then return "H" end
    local group = key:match("^G:(%d+)$")
    return group and ("G" .. Base36(group)) or key
end

local function DecodeSettingKey(key)
    if key == "H" then return "HEALERS" end
    local group = key:match("^G([0-9a-z]+)$")
    return group and ("G:" .. DecodeBase36(group)) or key
end

local function EncodeValues(kind, source)
    local values = {}
    for index, value in ipairs(source or {}) do values[index] = tostring(value) end
    local raidToWire = RaidWireMaps()
    if RAID_FIRST[kind] then values[1] = raidToWire[values[1]] or values[1] end
    if ENCOUNTER_SECOND[kind] then values[2] = Base36(values[2]) end
    if kind == "PLAN" or kind == "VALUE" or kind == "CLEAR" then
        values[3] = EncodePlanKey(values[3])
    end
    if kind == "PLAN" then
        values[5] = CLASS_TO_WIRE[values[5]] or values[5]
    elseif kind == "MANUAL" then
        values[3] = CLASS_TO_WIRE[values[3]] or values[3]
        values[4] = ROLE_TO_WIRE[values[4]] or values[4]
        values[6] = Base36(values[6])
    elseif kind == "SIM_PLAYER" then
        values[3] = CLASS_TO_WIRE[values[3]] or values[3]
        values[4] = ROLE_TO_WIRE[values[4]] or values[4]
        values[6] = Base36(values[6])
    elseif kind == "GROUP" then
        values[3] = Base36(values[3])
    elseif kind == "GEAR" then
        values[1] = Base36(values[1])
    elseif kind == "CHECK" then
        values[2] = Base36(values[2])
    elseif kind == "INSPECT_CLAIM" then
        values[2] = Base36(values[2])
    elseif kind == "COOLDOWN" then
        values[1] = Base36(values[1])
        values[2] = Base36(values[2])
    elseif kind == "PROFILE" or kind == "INTEL" then
        values[3] = CLASS_TO_WIRE[values[3]] or values[3]
        values[4] = ROLE_TO_WIRE[values[4]] or values[4]
        for _, index in ipairs({ 6, 7, 9, 10 }) do
            values[index] = Base36(values[index])
        end
    elseif kind == "COMP" then
        values[2] = ({ tanks = "T", healers = "H", damage = "D" })[
            values[2]] or values[2]
        values[3] = Base36(values[3])
    elseif kind == "BOSSSET" or kind == "PRESETSET" then
        values[3] = EncodeSettingKey(values[3])
        values[4] = Base36(values[4])
    end
    return values
end

local function DecodeFields(fields)
    local kind = WIRE_TO_KIND[fields[2]]
    if not kind then return nil end
    fields[2] = kind
    fields[3] = DecodeBase36(fields[3])
    local _, wireToRaid = RaidWireMaps()
    if RAID_FIRST[kind] then fields[4] = wireToRaid[fields[4]] or fields[4] end
    if ENCOUNTER_SECOND[kind] then
        fields[5] = DecodeBase36(fields[5])
    end
    if kind == "PLAN" or kind == "VALUE" or kind == "CLEAR" then
        fields[6] = DecodePlanKey(fields[6])
    end
    if kind == "PLAN" then
        fields[8] = WIRE_TO_CLASS[fields[8]] or fields[8]
    elseif kind == "MANUAL" then
        fields[6] = WIRE_TO_CLASS[fields[6]] or fields[6]
        fields[7] = WIRE_TO_ROLE[fields[7]] or fields[7]
        fields[9] = DecodeBase36(fields[9])
    elseif kind == "SIM_PLAYER" then
        fields[6] = WIRE_TO_CLASS[fields[6]] or fields[6]
        fields[7] = WIRE_TO_ROLE[fields[7]] or fields[7]
        fields[9] = DecodeBase36(fields[9])
    elseif kind == "GROUP" then
        fields[6] = DecodeBase36(fields[6])
    elseif kind == "GEAR" then
        fields[4] = DecodeBase36(fields[4])
    elseif kind == "CHECK" then
        fields[5] = DecodeBase36(fields[5])
    elseif kind == "INSPECT_CLAIM" then
        fields[5] = DecodeBase36(fields[5])
    elseif kind == "COOLDOWN" then
        fields[4] = DecodeBase36(fields[4])
        fields[5] = DecodeBase36(fields[5])
    elseif kind == "PROFILE" or kind == "INTEL" then
        fields[6] = WIRE_TO_CLASS[fields[6]] or fields[6]
        fields[7] = WIRE_TO_ROLE[fields[7]] or fields[7]
        for _, index in ipairs({ 9, 10, 12, 13 }) do
            fields[index] = DecodeBase36(fields[index])
        end
    elseif kind == "COMP" then
        fields[5] = ({ T = "tanks", H = "healers", D = "damage" })[
            fields[5]] or fields[5]
        fields[6] = DecodeBase36(fields[6])
    elseif kind == "BOSSSET" or kind == "PRESETSET" then
        fields[6] = DecodeSettingKey(fields[6])
        fields[7] = DecodeBase36(fields[7])
    end
    return kind
end

local function PlayerName(name)
    if not name then return "" end
    if Ambiguate then return Ambiguate(name, "short") end
    return name:match("^[^-]+") or name
end

local function CompareVersions(left, right)
    local leftParts, rightParts = {}, {}
    for value in tostring(left or ""):gmatch("%d+") do
        leftParts[#leftParts + 1] = tonumber(value)
    end
    for value in tostring(right or ""):gmatch("%d+") do
        rightParts[#rightParts + 1] = tonumber(value)
    end
    local count = math.max(#leftParts, #rightParts)
    for index = 1, count do
        local a, b = leftParts[index] or 0, rightParts[index] or 0
        if a ~= b then return a < b and -1 or 1 end
    end
    return 0
end

function Raid:WarnIncompatiblePeer(sender, version, protocol)
    self.incompatibleWarnings = self.incompatibleWarnings or {}
    local key = tostring(sender) .. ":" .. tostring(version or protocol)
    if self.incompatibleWarnings[key] then return end
    self.incompatibleWarnings[key] = true
    local localVersion = self.version or "unknown"
    local comparison = version
        and CompareVersions(version, localVersion)
        or (
            tonumber(protocol) and tonumber(PROTOCOL)
            and (
                tonumber(protocol) < tonumber(PROTOCOL) and -1
                or tonumber(protocol) > tonumber(PROTOCOL) and 1
                or 0)
            or 0)
    if comparison > 0 then
        if not self.updateAvailableNotified then
            self.updateAvailableNotified = true
            local available = version
                and ("version " .. version)
                or ("a newer protocol (" .. tostring(protocol) .. ")")
            self:Print(
                ("A LunaRaids update is available: %s "
                    .. "(you have %s).")
                    :format(available, localVersion))
        end
    else
        self:Print(
            ("%s is using an incompatible LunaRaids version (%s). "
                .. "Their messages were ignored.")
                :format(
                    PlayerName(sender),
                    version or ("protocol " .. tostring(protocol))))
    end
end

local function AssignmentLabel(raid, encounterIndex, key)
    if not raid or not key then return "Unknown Assignment" end
    local healerIndex = key:match("^S:healer%.raid%.(%d+)$")
    if healerIndex then return "Healer " .. healerIndex end
    local encounter = raid.encounters
        and raid.encounters[encounterIndex]
    if not encounter then return key end
    for groupIndex, group in ipairs(encounter.groups or {}) do
        local slots = Raid:GetEncounterGroupSlots(
            groupIndex, encounter, raid.key, encounterIndex)
        for slotIndex, slot in ipairs(slots) do
            local slotKey = slot.id and ("S:" .. slot.id)
                or ("S:group.%d.slot.%d"):format(
                    groupIndex, slotIndex)
            if slotKey == key then
                return Raid:GetSlotLabel(slot)
            end
        end
    end
    return key:gsub("^S:", ""):gsub("[._]", " ")
end

local function Fields(message)
    local result = {}
    for value in (message .. "\t"):gmatch("(.-)\t") do
        result[#result + 1] = value
    end
    return result
end

function Raid:IsLocalRaidEditor()
    if self.simulation.enabled then return true end
    if not (IsInRaid and IsInRaid()) then return true end
    return (UnitIsGroupLeader and UnitIsGroupLeader("player"))
        or (UnitIsGroupAssistant and UnitIsGroupAssistant("player"))
        or false
end

function Raid:IsAuthorizedPeer(sender)
    local shortName = PlayerName(sender)
    local count = IsInRaid and IsInRaid()
        and GetNumGroupMembers and GetNumGroupMembers() or 0
    for index = 1, count do
        local unit = "raid" .. index
        local unitName = GetUnitName and GetUnitName(unit, true)
            or UnitName(unit)
        if PlayerName(unitName) == shortName then
            return UnitIsGroupLeader(unit) or UnitIsGroupAssistant(unit)
        end
    end
    return false
end

function Raid:IsPeerLeader(sender)
    local shortName = PlayerName(sender)
    local count = IsInRaid and IsInRaid()
        and GetNumGroupMembers and GetNumGroupMembers() or 0
    for index = 1, count do
        local unit = "raid" .. index
        local unitName = GetUnitName and GetUnitName(unit, true)
            or UnitName(unit)
        if PlayerName(unitName) == shortName then
            return UnitIsGroupLeader and UnitIsGroupLeader(unit) or false
        end
    end
    return false
end

function Raid:QueueSync(kind, values, distribution, target)
    if self.receivingSync then return end
    if not self.syncQueue or not self.syncFrame then
        self:InitializeCommunication()
    end
    if not self.syncQueue or not self.syncFrame then return end
    self.syncSequence = (self.syncSequence or 0) + 1
    local fields = {
        PROTOCOL,
        KIND_TO_WIRE[kind] or kind,
        Base36(self.syncSequence),
    }
    for _, value in ipairs(EncodeValues(kind, values)) do
        fields[#fields + 1] = value
    end
    self.syncQueue[#self.syncQueue + 1] = {
        message = table.concat(fields, "\t"),
        distribution = distribution or (
            IsInRaid and IsInRaid() and "RAID" or "PARTY"),
        target = target,
    }
    self.syncFrame:Show()
end

function Raid:BroadcastPlanValue(key, value)
    if not self:IsLocalRaidEditor() then return end
    local raid = self:GetRaid()
    local _, encounterIndex = self:GetEncounter()
    if type(value) == "table" then
        self:QueueSync("PLAN", {
            raid.key, encounterIndex, key,
            value.name or "", value.class or "",
        })
    elseif value == nil then
        self:QueueSync("CLEAR", { raid.key, encounterIndex, key })
    else
        self:QueueSync("VALUE", {
            raid.key, encounterIndex, key, tostring(value),
        })
    end
end

function Raid:BroadcastSelection()
    if not self:IsLocalRaidEditor() then return end
    self:QueueSync("SELECT", {
        self.db.activeRaid, self.db.activeEncounter,
    })
end

function Raid:BroadcastCurrentBoss(target)
    local raid = self:GetRaid()
    local index = self:GetCurrentBossIndex(raid)
    if not index or not self:IsLocalRaidEditor() then return end
    self:QueueSync(
        "CURRENT", { raid.key, index },
        target and "WHISPER" or nil, target)
end

function Raid:BroadcastSimulationClear(target)
    if not self:IsLocalRaidEditor() then return end
    self:QueueSync(
        "SIM_BEGIN", { self.db.activeRaid },
        target and "WHISPER" or nil, target)
    self:QueueSync(
        "SIM_END", { self.db.activeRaid },
        target and "WHISPER" or nil, target)
end

function Raid:BroadcastSimulationRoster(target)
    if not self:IsLocalRaidEditor() then return end
    local distribution = target and "WHISPER" or nil
    self:QueueSync(
        "SIM_BEGIN", { self.db.activeRaid }, distribution, target)
    for _, player in ipairs(self.simulation.roster or {}) do
        self:QueueSync("SIM_PLAYER", {
            self.db.activeRaid,
            player.name or "",
            player.class or "",
            player.role or player.reportedRole or "DAMAGER",
            player.race or "",
            player.subgroup or 1,
        }, distribution, target)
    end
    self:QueueSync(
        "SIM_END", { self.db.activeRaid }, distribution, target)
end

function Raid:SendPlanSnapshot(target)
    if not self:IsLocalRaidEditor() then return end
    local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
    local distribution = target and "WHISPER" or nil
    self:QueueSync("SNAP_BEGIN", {
        raid.key, encounterIndex,
    }, distribution, target)
    self:BroadcastCurrentBoss(target)
    local plan = self:GetPlan(false) or {}
    for key, value in pairs(plan) do
        if type(value) == "table" then
            self:QueueSync("PLAN", {
                raid.key, encounterIndex, key,
                value.name or "", value.class or "",
            }, distribution, target)
        else
            self:QueueSync("VALUE", {
                raid.key, encounterIndex, key, tostring(value),
            }, distribution, target)
        end
    end
    local composition = self:GetRaidComposition(raid.key)
    for _, role in ipairs({ "tanks", "healers" }) do
        self:QueueSync("COMP", {
            raid.key, role, composition[role],
        }, distribution, target)
    end
    for _, player in pairs(self.db.manualPlayers[raid.key] or {}) do
        self:QueueSync("MANUAL", {
            raid.key, player.name, player.class,
            player.role, player.spec or "", player.subgroup or 1,
        }, distribution, target)
    end
    if self.simulation.enabled then
        self:BroadcastSimulationRoster(target)
    elseif self.IsActualRaidLeader and self:IsActualRaidLeader() then
        self:BroadcastSimulationClear(target)
    end
    local bossOverride = self:GetBossOverride(false)
    if bossOverride then
        if tonumber(bossOverride.healers) then
            self:QueueSync("BOSSSET", {
                raid.key, encounterIndex, "HEALERS",
                bossOverride.healers,
            }, distribution, target)
        end
        for groupIndex, count in pairs(bossOverride.groups or {}) do
            self:QueueSync("BOSSSET", {
                raid.key, encounterIndex, "G:" .. groupIndex, count,
            }, distribution, target)
        end
    end
    self:QueueSync("SNAP_END", {
        raid.key, encounterIndex,
    }, distribution, target)
end

function Raid:BroadcastOwnGear(target)
    if not IsInGroup or not IsInGroup() then return end
    local distribution = target and "WHISPER" or nil
    self:QueueSync("GEAR_BEGIN", {}, distribution, target)
    for slotID = 1, 19 do
        local link = GetInventoryItemLink
            and GetInventoryItemLink("player", slotID)
        if link then
            self:QueueSync(
                "GEAR", { slotID, link }, distribution, target)
        end
    end
    self:QueueSync("GEAR_END", {}, distribution, target)
end

function Raid:BroadcastOwnCooldown(definitionIndex, remaining, target)
    if not IsInGroup or not IsInGroup() then return end
    self:QueueSync(
        "COOLDOWN", { definitionIndex, remaining },
        target and "WHISPER" or nil, target)
end

function Raid:IsPeerInspectReserved(key)
    if not key or key == "" then return false end
    self.peerInspectClaims = self.peerInspectClaims or {}
    local claim = self.peerInspectClaims[key]
    if not claim then return false end
    if (claim.expires or 0) <= GetTime() then
        self.peerInspectClaims[key] = nil
        return false
    end
    return true
end

function Raid:BroadcastInspectClaim(key, seconds)
    if not key or key == "" or not self:IsLocalRaidEditor() then
        return
    end
    seconds = math.max(5, math.min(20, tonumber(seconds) or 10))
    self:QueueSync("INSPECT_CLAIM", { key, seconds })
end

function Raid:HandlePlayerEquipmentChanged()
    if self.gearBroadcastPending then return end
    self.gearBroadcastPending = true
    local function Send()
        Raid.gearBroadcastPending = nil
        Raid:BroadcastOwnGear()
        if Raid.RefreshGearInspectView
            and Raid.gearInspectView
            and Raid.gearInspectView:IsShown()
        then
            Raid:QueueGearInspections()
            Raid:RefreshGearInspectView(false)
        end
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(1, Send)
    else
        Send()
    end
end

function Raid:RequestPeerSync()
    if not IsInGroup or not IsInGroup() then return end
    self:QueueSync("HELLO", {
        self.version or "unknown", "Q",
    })
    if self.BroadcastCharacterProfile then
        self:BroadcastCharacterProfile()
    end
    self:BroadcastOwnGear()
    if self.BroadcastLocalRaidCooldowns then
        self:BroadcastLocalRaidCooldowns(nil, true)
    end
end

function Raid:ApplyPeerSelection(raidKey, encounterIndex)
    local raid = self.raidByKey[raidKey]
    if not raid then return end
    local continuingCurrentRaid =
        self.db.raidLocked and self.db.activeRaid == raid.key
    self.db.activeExpansion = raid.expansion
    self.db.activeRaid = raid.key
    self.db.activeEncounter = math.max(
        1, math.min(tonumber(encounterIndex) or 1, #raid.encounters))
    self.db.lastRaidByExpansion[raid.expansion] = raid.key
    self.db.lastEncounterByRaid[raid.key] = self.db.activeEncounter
    self.db.raidLocked = true
    self:ApplyRaidComposition(raid)
    local isAssistant = UnitIsGroupAssistant
        and UnitIsGroupAssistant("player")
    local inCombat = InCombatLockdown and InCombatLockdown()
    if isAssistant and not inCombat
        and not continuingCurrentRaid and self.EnterBossUI
    then
        self:EnterBossUI("ASSIGNMENTS")
    elseif self.frame and self.frame:IsShown()
        and not continuingCurrentRaid and self.EnterBossUI
        and not (
            self.settingsView and self.settingsView:IsShown())
    then
        self:EnterBossUI()
    elseif self.RefreshAll then
        self:RefreshAll()
    end
end

function Raid:CHAT_MSG_ADDON(_, prefix, message, _, sender)
    if prefix ~= PREFIX then return end
    local ownName = PlayerName(
        GetUnitName and GetUnitName("player", true) or UnitName("player"))
    if PlayerName(sender) == ownName then return end
    local fields = Fields(message)
    if fields[1] ~= PROTOCOL then
        self:WarnIncompatiblePeer(sender, nil, fields[1])
        return
    end
    local kind = DecodeFields(fields)
    if not kind then return end
    local sequence = tonumber(fields[3]) or 0
    if kind == "HELLO" then
        local peerVersion = fields[4] or "unknown"
        local compatible = peerVersion == (self.version or "unknown")
        self.compatiblePeers = self.compatiblePeers or {}
        self.compatiblePeers[sender] = compatible
        if not compatible then
            self:WarnIncompatiblePeer(sender, peerVersion, fields[1])
            return
        end
        self.peerSequences = self.peerSequences or {}
        self.peerSequences[sender] = 0
        self.profileSequences = self.profileSequences or {}
        self.profileSequences[sender] = 0
        if fields[5] ~= "R" then
            self:QueueSync("HELLO", {
                self.version or "unknown", "R",
            }, "WHISPER", sender)
            self:BroadcastOwnGear(sender)
            if self.BroadcastLocalRaidCooldowns then
                self:BroadcastLocalRaidCooldowns(sender, true)
            end
        end
        if fields[5] ~= "R" and self:IsLocalRaidEditor() then
            self:SendPlanSnapshot(sender)
        end
        return
    end
    if not (self.compatiblePeers and self.compatiblePeers[sender]) then
        return
    end
    if kind == "PROFILE" then
        self.profileSequences = self.profileSequences or {}
        if sequence > (self.profileSequences[sender] or 0) then
            self.profileSequences[sender] = sequence
            if self.ReceiveCharacterProfile then
                self:ReceiveCharacterProfile(fields, sender, false)
            end
        end
        return
    end
    if kind == "CHECK" then
        if self.ReceiveReadyCheckStatus then
            self:ReceiveReadyCheckStatus(
                PlayerName(sender), fields[5],
                fields[6], fields[7], fields[8], fields[9])
        end
        return
    end
    if kind == "COOLDOWN" then
        if self.ReceiveRaidCooldownState then
            self:ReceiveRaidCooldownState(
                sender, tonumber(fields[4]), tonumber(fields[5]))
        end
        return
    end
    if kind == "GEAR_BEGIN" then
        self.peerGearSnapshots = self.peerGearSnapshots or {}
        self.peerGearSnapshots[PlayerName(sender)] = {}
        return
    elseif kind == "GEAR" then
        self.peerGearSnapshots = self.peerGearSnapshots or {}
        local snapshot = self.peerGearSnapshots[PlayerName(sender)]
        local slotID = tonumber(fields[4])
        if snapshot and slotID and fields[5] and fields[5] ~= "" then
            snapshot[slotID] = fields[5]
        end
        return
    elseif kind == "GEAR_END" then
        local shortName = PlayerName(sender)
        local snapshot = self.peerGearSnapshots
            and self.peerGearSnapshots[shortName]
        if snapshot and self.StorePeerGearSnapshot then
            self:StorePeerGearSnapshot(shortName, snapshot)
        end
        if self.peerGearSnapshots then
            self.peerGearSnapshots[shortName] = nil
        end
        return
    end
    if not self:IsAuthorizedPeer(sender) then return end
    self.peerSequences = self.peerSequences or {}
    if sequence <= (self.peerSequences[sender] or 0) then return end
    self.peerSequences[sender] = sequence
    if kind == "INSPECT_CLAIM" then
        local key, duration = fields[4], tonumber(fields[5]) or 10
        if key and key ~= "" then
            self.peerInspectClaims = self.peerInspectClaims or {}
            self.peerInspectClaims[key] = {
                sender = sender,
                expires = GetTime()
                    + math.max(5, math.min(20, duration)),
            }
        end
        return
    elseif kind == "INTEL" then
        if self.ReceiveCharacterProfile then
            self:ReceiveCharacterProfile(fields, sender, true)
        end
        return
    end
    if kind == "MANUAL" then
        local raidKey, name = fields[4], fields[5]
        if self.raidByKey[raidKey] and name and name ~= "" then
            self.db.manualPlayers[raidKey] =
                self.db.manualPlayers[raidKey] or {}
            self.db.manualPlayers[raidKey][name:lower()] = {
                name = name,
                class = fields[6],
                className = LOCALIZED_CLASS_NAMES_MALE
                    and LOCALIZED_CLASS_NAMES_MALE[fields[6]]
                    or fields[6],
                role = fields[7],
                reportedRole = fields[7],
                spec = fields[8] or "",
                race = "Planned",
                subgroup = tonumber(fields[9]) or 1,
                manual = true,
            }
            self:UpdateRoster()
        end
        return
    elseif kind == "MANUALDEL" then
        local raidKey, name = fields[4], fields[5]
        if name and self.db.manualPlayers[raidKey] then
            self.db.manualPlayers[raidKey][name:lower()] = nil
            self:UpdateRoster()
        end
        return
    end
    if (kind == "SELECT" or kind == "RESET" or kind == "CLOSE")
        and not self:IsPeerLeader(sender)
    then
        return
    end
    self.receivingSync = true
    local raidKey, encounterIndex = fields[4], tonumber(fields[5])
    if kind == "SELECT" then
        self:ApplyPeerSelection(raidKey, encounterIndex)
    elseif kind == "CURRENT" then
        local raid = self.raidByKey[raidKey]
        if raid and encounterIndex and encounterIndex >= 2
            and encounterIndex <= #raid.encounters
        then
            self.db.currentBossByRaid =
                self.db.currentBossByRaid or {}
            self.db.currentBossByRaid[raidKey] = encounterIndex
            self.db.activeEncounter = encounterIndex
            self.db.lastEncounterByRaid[raidKey] = encounterIndex
        end
    elseif kind == "SIM_BEGIN" then
        self.receivingSimulation = sender
        self.pendingRemoteSimulationRoster = {}
    elseif kind == "SIM_PLAYER" then
        if self.receivingSimulation == sender
            and fields[5] and fields[5] ~= ""
        then
            self.pendingRemoteSimulationRoster[
                #self.pendingRemoteSimulationRoster + 1] = {
                name = fields[5],
                class = fields[6],
                className = LOCALIZED_CLASS_NAMES_MALE
                    and LOCALIZED_CLASS_NAMES_MALE[fields[6]]
                    or fields[6],
                role = fields[7],
                reportedRole = fields[7],
                race = fields[8] ~= "" and fields[8] or "Simulated",
                subgroup = tonumber(fields[9]) or 1,
                simulated = true,
            }
        end
    elseif kind == "SIM_END" then
        if self.receivingSimulation == sender then
            self.remoteSimulationRoster =
                self.pendingRemoteSimulationRoster or {}
            self.pendingRemoteSimulationRoster = nil
            self.receivingSimulation = nil
            self:UpdateRoster()
        end
    elseif kind == "GROUP" then
        local name, subgroup = fields[5], tonumber(fields[6])
        if name and subgroup and subgroup >= 1 and subgroup <= 8 then
            local manual = self.db.manualPlayers[raidKey]
                and self.db.manualPlayers[raidKey][name:lower()]
            if manual then manual.subgroup = subgroup end
            for _, roster in ipairs({
                self.simulation.roster,
                self.remoteSimulationRoster,
                self.roster,
            }) do
                for _, player in ipairs(roster or {}) do
                    if player.name and player.name:lower() == name:lower()
                        and (player.manual or player.simulated)
                    then
                        player.subgroup = subgroup
                    end
                end
            end
            self:UpdateRoster()
        end
    elseif kind == "CLOSE" then
        local closedWorkspace = self.workspaceMode
        self.db.raidLocked = false
        self.db.activeSavedRaid = nil
        self.selectedPlayer = nil
        self.dragPlayer = nil
        self.receivingSync = false
        if self.HideDragGhost then self:HideDragGhost() end
        if self.RefreshPersonalAssignments then
            self:RefreshPersonalAssignments()
        end
        if self.frame and self.frame:IsShown() then
            if self.settingsView and self.settingsView:IsShown() then
                self:RefreshSettingsView()
            elseif closedWorkspace == "ASSIGNMENTS" then
                self.workspaceMode = "ASSIGNMENTS"
                if self:CanStartRaid() then
                    self:ShowNewRaidWizard(false)
                else
                    self:SetRaidPickerMode(false)
                    self:SetRaidWorkspaceVisible(true)
                    self:RefreshAll()
                    self:Print(
                        "Only the raid leader can create a new raid plan.")
                end
            else
                self.workspaceMode = closedWorkspace or "GROUPS"
                self:SetRaidPickerMode(false)
                self:SetRaidWorkspaceVisible(true)
                self:RefreshAll()
            end
        end
        self:Print("The raid leader completed the active raid.")
        return
    elseif kind == "SNAP_BEGIN" then
        self.receivingSnapshots = self.receivingSnapshots or {}
        self.receivingSnapshots[sender] = true
        if self:IsPeerLeader(sender) then
            self:ApplyPeerSelection(raidKey, encounterIndex)
        end
        local plans = self.simulation.enabled
            and self.simulation.plans or self.db.plans
        plans[raidKey] = plans[raidKey] or {}
        plans[raidKey][encounterIndex] = {}
        self.db.manualPlayers[raidKey] = {}
        if self.db.bossOverrides[raidKey] then
            self.db.bossOverrides[raidKey][encounterIndex] = nil
        end
    elseif kind == "PLAN" or kind == "VALUE" or kind == "CLEAR" then
        local raid = self.raidByKey[raidKey]
        if raid and raid.encounters[encounterIndex] then
            local plans = self.simulation.enabled
                and self.simulation.plans or self.db.plans
            plans[raidKey] = plans[raidKey] or {}
            plans[raidKey][encounterIndex] =
                plans[raidKey][encounterIndex] or {}
            local plan, key = plans[raidKey][encounterIndex], fields[6]
            local previous = plan[key]
            if kind == "PLAN" then
                plan[key] = { name = fields[7], class = fields[8] }
            elseif kind == "CLEAR" then
                plan[key] = nil
            else
                local value = fields[7]
                plan[key] = value == "true" and true
                    or value == "false" and false
                    or tonumber(value) or value
            end
            local snapshot = self.receivingSnapshots
                and self.receivingSnapshots[sender]
            if not snapshot and (kind == "PLAN" or kind == "CLEAR")
                and key and key:match("^S:")
            then
                local editor = PlayerName(sender)
                local label = AssignmentLabel(
                    raid, encounterIndex, key)
                if kind == "PLAN" and fields[7] and fields[7] ~= "" then
                    self:Print(("%s assigned %s as %s."):format(
                        editor, PlayerName(fields[7]), label))
                elseif kind == "CLEAR" and previous and previous.name then
                    self:Print(("%s removed %s from %s."):format(
                        editor, PlayerName(previous.name), label))
                end
            end
        end
    elseif kind == "COMP" then
        local raid, role, value =
            self.raidByKey[raidKey], fields[5], tonumber(fields[6])
        if raid and value and (
            role == "tanks" or role == "healers")
        then
            self.db.raidCompositions[raidKey] =
                self.db.raidCompositions[raidKey] or {}
            self.db.raidCompositions[raidKey][role] = value
            self:ApplyRaidComposition(raid)
        end
    elseif kind == "BOSSSET" then
        local raid, key, value =
            self.raidByKey[raidKey], fields[6], tonumber(fields[7])
        if raid and raid.encounters[encounterIndex] and key and value then
            self.db.bossOverrides[raidKey] =
                self.db.bossOverrides[raidKey] or {}
            local override =
                self.db.bossOverrides[raidKey][encounterIndex]
                or { groups = {} }
            override.groups = override.groups or {}
            self.db.bossOverrides[raidKey][encounterIndex] = override
            if key == "HEALERS" then
                override.healers = value
            else
                local groupIndex = tonumber(key:match("^G:(%d+)$"))
                if groupIndex then override.groups[groupIndex] = value end
            end
        end
    elseif kind == "BOSSRESET" then
        if self.db.bossOverrides[raidKey] then
            self.db.bossOverrides[raidKey][encounterIndex] = nil
        end
    elseif kind == "PRESETSET" or kind == "PRESETRESET"
        or kind == "PRESETCLEAR"
    then
        do end
    elseif kind == "RESET" then
        local plans = self.simulation.enabled
            and self.simulation.plans or self.db.plans
        plans[raidKey] = nil
        self.db.bossOverrides[raidKey] = nil
        self.db.manualPlayers[raidKey] = nil
        if self.db.currentBossByRaid then
            self.db.currentBossByRaid[raidKey] = nil
        end
    end
    local receivingSnapshot = self.receivingSnapshots
        and self.receivingSnapshots[sender]
    if kind == "PLAN" and encounterIndex == 1
        and not receivingSnapshot
        and self.PropagateOverviewAssignments
    then
        self:PropagateOverviewAssignments()
    end
    self.receivingSync = false
    if kind == "SNAP_END" then
        if self.receivingSnapshots then
            self.receivingSnapshots[sender] = nil
        end
        if encounterIndex == 1 and self.PropagateOverviewAssignments then
            self:PropagateOverviewAssignments()
        end
        self:UpdateRoster()
    end
    local applyingSnapshot = self.receivingSnapshots
        and next(self.receivingSnapshots) ~= nil
    if not applyingSnapshot then
        if self.RefreshPersonalAssignments then
            self:RefreshPersonalAssignments()
        end
        if self.RefreshAll then self:RefreshAll() end
    end
end

function Raid:HandleGroupRosterUpdate()
    self:UpdateRoster()
    if self.RefreshRaidCooldowns then
        self:RefreshRaidCooldowns()
    end
    if self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
    if self.frame and self.frame:IsShown() and self.RefreshAll then
        self:RefreshAll()
    end
    if self.RefreshQuickActionBar then
        self:RefreshQuickActionBar()
    end
    if self.ScheduleRaidAdministration then
        self:ScheduleRaidAdministration()
    elseif self.ApplyRaidAdministration then
        self:ApplyRaidAdministration()
    end
    local now = GetTime and GetTime() or 0
    if now - (self.lastPeerHello or -10) >= 5 then
        self.lastPeerHello = now
        self:RequestPeerSync()
    end
end

function Raid:InitializeCommunication()
    self.syncQueue = self.syncQueue or {}
    self.syncSequence = self.syncSequence or 0
    if self.syncFrame then return end
    self.syncFrame = CreateFrame("Frame")
    self.syncFrame:Hide()
    self.syncFrame.elapsed = 0
    self.syncFrame:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = frame.elapsed + elapsed
        if frame.elapsed < .08 then return end
        frame.elapsed = 0
        local item = Raid.syncQueue
            and table.remove(Raid.syncQueue, 1)
        if not item then frame:Hide() return end
        if C_ChatInfo and C_ChatInfo.SendAddonMessage then
            C_ChatInfo.SendAddonMessage(
                PREFIX, item.message, item.distribution, item.target)
        elseif SendAddonMessage then
            SendAddonMessage(
                PREFIX, item.message, item.distribution, item.target)
        end
    end)
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    elseif RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(PREFIX)
    end
    self:RegisterEvent("CHAT_MSG_ADDON")
end
