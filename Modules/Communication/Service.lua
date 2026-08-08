local _, Raid = ...

local PREFIX = "LunaRaids"
-- Legacy messages include this first field. Compact-capable peers omit it;
-- DecodeFields restores the placeholder to preserve all internal offsets.
local WIRE_HEADER = "8"

local KIND_TO_WIRE = {
    HELLO = "H", PROFILE = "P", INTEL = "I", CHECK = "k",
    SELECT = "S", CURRENT = "c", PLAN = "A", PLANBATCH = "a", NAMES = "N",
    VALUE = "V", CLEAR = "C",
    PLANRESET = "n", TX_BEGIN = "h", TX_END = "s",
    SNAP_BEGIN = "B", SNAP_END = "E", FULL_BEGIN = "t", FULL_END = "T",
    COMP = "O",
    MANUAL = "M", MANUALBATCH = "m", MANUALDEL = "D", BOSSSET = "b",
    BOSSCUSTOM = "u", BOSSCUSTOMDEL = "v",
    BOSSRESET = "r", PRESETSET = "p", PRESETRESET = "q",
    PRESETCLEAR = "x", PRESETCUSTOM = "w", RESET = "R", CLOSE = "X",
    SIM_BEGIN = "Y", SIM_PLAYER = "Z", SIMBATCH = "z", SIM_END = "y",
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

local function CompactSessionID(value)
    local hash = 5381
    value = tostring(value or "")
    for index = 1, #value do
        hash = (hash * 33 + value:byte(index)) % 2147483647
    end
    return "#" .. Base36(hash)
end

local function EstimatedMessageSize(owner, raidKey, extra, compact)
    local sessionID = owner.db and owner.db.activeRaidSessionID or ""
    local envelopeSize = compact
        and (20 + #CompactSessionID(sessionID))
        or (24 + #tostring(raidKey or "") + #tostring(sessionID))
    return envelopeSize + (tonumber(extra) or 0)
end

local function EncodeWireMessage(fields, compact)
    -- Compact-capable peers omit the legacy version/header field. DecodeFields
    -- restores that placeholder so all downstream field offsets stay stable.
    return compact
        and table.concat(fields, "\t", 2, #fields)
        or table.concat(fields, "\t")
end

local function FromBase36(value)
    if value == nil or value == "" then return nil end
    return tonumber(value, 36) or 0
end

local function DecodeBase36(value)
    local decoded = FromBase36(value)
    return decoded and tostring(decoded) or ""
end

local ENCOUNTER_SECOND = {
    SELECT = true, CURRENT = true, PLAN = true, PLANBATCH = true, NAMES = true,
    VALUE = true, CLEAR = true,
    PLANRESET = true,
    SNAP_BEGIN = true, SNAP_END = true, BOSSSET = true,
    BOSSCUSTOM = true, BOSSCUSTOMDEL = true,
    BOSSRESET = true, PRESETSET = true, PRESETRESET = true,
    PRESETCLEAR = true, PRESETCUSTOM = true,
}

local RAID_DOCUMENT_KIND = {
    CURRENT = true, PLAN = true, PLANBATCH = true, NAMES = true,
    VALUE = true, CLEAR = true,
    PLANRESET = true, TX_BEGIN = true, TX_END = true,
    SNAP_BEGIN = true, SNAP_END = true, FULL_BEGIN = true, FULL_END = true,
    COMP = true,
    MANUAL = true, MANUALBATCH = true, MANUALDEL = true, GROUP = true,
    BOSSSET = true, BOSSCUSTOM = true, BOSSCUSTOMDEL = true,
    BOSSRESET = true, PRESETSET = true, PRESETRESET = true,
    PRESETCLEAR = true, PRESETCUSTOM = true, RESET = true,
    SIM_BEGIN = true, SIM_PLAYER = true, SIMBATCH = true, SIM_END = true,
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
    -- Keep raid keys unchanged: registration order can differ between builds.
    if ENCOUNTER_SECOND[kind] then values[2] = Base36(values[2]) end
    if kind == "PLAN" then
        values[3] = EncodePlanKey(values[3])
    elseif kind == "VALUE" then
        for index = 3, #values, 2 do
            values[index] = EncodePlanKey(values[index])
        end
    elseif kind == "CLEAR" then
        for index = 3, #values do
            values[index] = EncodePlanKey(values[index])
        end
    end
    if kind == "PLAN" then
        values[5] = CLASS_TO_WIRE[values[5]] or values[5]
    elseif kind == "PLANBATCH" then
        for index = 3, #values, 3 do
            values[index] = EncodePlanKey(values[index])
            values[index + 2] = CLASS_TO_WIRE[values[index + 2]]
                or values[index + 2]
        end
    elseif kind == "NAMES" then
        for index = 4, #values, 2 do
            values[index] = CLASS_TO_WIRE[values[index]] or values[index]
        end
    elseif kind == "MANUAL" then
        values[3] = CLASS_TO_WIRE[values[3]] or values[3]
        values[4] = ROLE_TO_WIRE[values[4]] or values[4]
        values[6] = Base36(values[6])
    elseif kind == "MANUALBATCH" then
        for index = 2, #values, 5 do
            values[index + 1] = CLASS_TO_WIRE[values[index + 1]]
                or values[index + 1]
            values[index + 2] = ROLE_TO_WIRE[values[index + 2]]
                or values[index + 2]
            values[index + 4] = Base36(values[index + 4])
        end
    elseif kind == "SIM_PLAYER" then
        values[3] = CLASS_TO_WIRE[values[3]] or values[3]
        values[4] = ROLE_TO_WIRE[values[4]] or values[4]
        values[6] = Base36(values[6])
    elseif kind == "SIMBATCH" then
        for index = 2, #values, 6 do
            values[index + 1] = CLASS_TO_WIRE[values[index + 1]]
                or values[index + 1]
            values[index + 2] = ROLE_TO_WIRE[values[index + 2]]
                or values[index + 2]
            values[index + 4] = Base36(values[index + 4])
        end
    elseif kind == "GROUP" then
        for index = 3, #values, 2 do
            values[index] = Base36(values[index])
        end
    elseif kind == "GEAR" then
        for index = 1, #values, 2 do
            values[index] = Base36(values[index])
        end
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
        for index = 2, #values, 2 do
            values[index] = ({
                tanks = "T", healers = "H", damage = "D",
            })[values[index]] or values[index]
            values[index + 1] = Base36(values[index + 1])
        end
    elseif kind == "BOSSSET" then
        for index = 3, #values, 2 do
            values[index] = EncodeSettingKey(values[index])
            values[index + 1] = Base36(values[index + 1])
        end
    elseif kind == "PRESETSET" then
        for index = 4, #values, 2 do
            values[index] = EncodeSettingKey(values[index])
            values[index + 1] = Base36(values[index + 1])
        end
    end
    return values
end

local function DecodeFields(fields)
    if WIRE_TO_KIND[fields[1]] then
        table.insert(fields, 1, WIRE_HEADER)
    end
    local kind = WIRE_TO_KIND[fields[2]]
    if not kind then return nil end
    fields[2] = kind
    fields[3] = DecodeBase36(fields[3])
    if ENCOUNTER_SECOND[kind] then
        fields[5] = DecodeBase36(fields[5])
    end
    if kind == "PLAN" then
        fields[6] = DecodePlanKey(fields[6])
    elseif kind == "VALUE" then
        for index = 6, #fields, 2 do
            fields[index] = DecodePlanKey(fields[index])
        end
    elseif kind == "CLEAR" then
        for index = 6, #fields do
            fields[index] = DecodePlanKey(fields[index])
        end
    end
    if kind == "PLAN" then
        fields[8] = WIRE_TO_CLASS[fields[8]] or fields[8]
    elseif kind == "PLANBATCH" then
        for index = 6, #fields, 3 do
            fields[index] = DecodePlanKey(fields[index])
            fields[index + 2] = WIRE_TO_CLASS[fields[index + 2]]
                or fields[index + 2]
        end
    elseif kind == "NAMES" then
        for index = 7, #fields, 2 do
            fields[index] = WIRE_TO_CLASS[fields[index]] or fields[index]
        end
    elseif kind == "MANUAL" then
        fields[6] = WIRE_TO_CLASS[fields[6]] or fields[6]
        fields[7] = WIRE_TO_ROLE[fields[7]] or fields[7]
        fields[9] = DecodeBase36(fields[9])
    elseif kind == "MANUALBATCH" then
        for index = 5, #fields, 5 do
            fields[index + 1] = WIRE_TO_CLASS[fields[index + 1]]
                or fields[index + 1]
            fields[index + 2] = WIRE_TO_ROLE[fields[index + 2]]
                or fields[index + 2]
            fields[index + 4] = DecodeBase36(fields[index + 4])
        end
    elseif kind == "SIM_PLAYER" then
        fields[6] = WIRE_TO_CLASS[fields[6]] or fields[6]
        fields[7] = WIRE_TO_ROLE[fields[7]] or fields[7]
        fields[9] = DecodeBase36(fields[9])
    elseif kind == "SIMBATCH" then
        for index = 5, #fields, 6 do
            fields[index + 1] = WIRE_TO_CLASS[fields[index + 1]]
                or fields[index + 1]
            fields[index + 2] = WIRE_TO_ROLE[fields[index + 2]]
                or fields[index + 2]
            fields[index + 4] = DecodeBase36(fields[index + 4])
        end
    elseif kind == "GROUP" then
        for index = 6, #fields, 2 do
            fields[index] = DecodeBase36(fields[index])
        end
    elseif kind == "GEAR" then
        for index = 4, #fields, 2 do
            fields[index] = DecodeBase36(fields[index])
        end
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
        for index = 5, #fields, 2 do
            fields[index] = ({
                T = "tanks", H = "healers", D = "damage",
            })[fields[index]] or fields[index]
            fields[index + 1] = DecodeBase36(fields[index + 1])
        end
    elseif kind == "BOSSSET" then
        for index = 6, #fields, 2 do
            fields[index] = DecodeSettingKey(fields[index])
            fields[index + 1] = DecodeBase36(fields[index + 1])
        end
    elseif kind == "PRESETSET" then
        for index = 7, #fields, 2 do
            fields[index] = DecodeSettingKey(fields[index])
            fields[index + 1] = DecodeBase36(fields[index + 1])
        end
    end
    return kind
end

local function PlayerName(name)
    if not name then return "" end
    if Ambiguate then return Ambiguate(name, "short") end
    return name:match("^[^-]+") or name
end

local function DecodePlanScalar(value)
    return value == "true" and true
        or value == "false" and false
        or tonumber(value) or value
end

local function PlayerKey(name)
    return tostring(name or ""):gsub("%s+", ""):lower()
end

local function SamePlayer(left, right)
    local leftKey, rightKey = PlayerKey(left), PlayerKey(right)
    if leftKey == "" or rightKey == "" then return false end
    if leftKey:find("-", 1, true)
        and rightKey:find("-", 1, true)
    then
        return leftKey == rightKey
    end
    return PlayerName(left):lower() == PlayerName(right):lower()
end

local function AssignmentLabel(raid, encounterIndex, key)
    if not raid or not key then return "Unknown Assignment" end
    local healerIndex = key:match("^S:healer%.raid%.(%d+)$")
    if healerIndex then return "Healer " .. healerIndex end
    local encounter = raid.encounters
        and raid.encounters[encounterIndex]
    if not encounter then return key end
    for groupIndex in ipairs(Raid:GetEncounterGroups(
        encounter, raid.key, encounterIndex)) do
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
    if self:IsRaidReadOnly() then return false end
    if self:IsSimulating() then return true end
    if not self:IsInLiveRaid() then return true end
    return (UnitIsGroupLeader and UnitIsGroupLeader("player"))
        or self:IsGroupAssistant()
        or false
end

local function CachePeerFlag(cache, name)
    if not name or name == "" then return end
    cache[PlayerKey(name)] = true
    cache[PlayerName(name):lower()] = true
end

local function HasPeerFlag(cache, name)
    return cache and (
        cache[PlayerKey(name)]
        or cache[PlayerName(name):lower()]) or false
end

local function UsesCompactWire(owner, target)
    return target and (
        target == "LunaSyncSimulation"
        or HasPeerFlag(owner.compactSyncPeers, target)) or false
end

function Raid:RebuildPeerAuthorityCache()
    local authorized, leaders = {}, {}
    local function AddUnit(unit)
        if UnitExists and not UnitExists(unit) then return end
        local name = GetUnitName and GetUnitName(unit, true)
            or UnitName and UnitName(unit)
        if not name or name == "" then return end
        local leader = UnitIsGroupLeader and UnitIsGroupLeader(unit) or false
        if leader then CachePeerFlag(leaders, name) end
        if leader or self:IsUnitGroupAssistant(unit) then
            CachePeerFlag(authorized, name)
        end
    end
    if self:IsInLiveRaid() then
        for index = 1, self:GetLiveRaidMemberCount() do
            AddUnit("raid" .. index)
        end
    elseif self:IsInLiveParty() then
        AddUnit("player")
        for index = 1, self:GetLivePartyMemberCount() do
            AddUnit("party" .. index)
        end
    end
    self.authorizedPeerCache = authorized
    self.leaderPeerCache = leaders
end

function Raid:IsAuthorizedPeer(sender)
    if not self.authorizedPeerCache then
        self:RebuildPeerAuthorityCache()
    end
    return HasPeerFlag(self.authorizedPeerCache, sender)
end

function Raid:IsPeerLeader(sender)
    if not self.leaderPeerCache then
        self:RebuildPeerAuthorityCache()
    end
    return HasPeerFlag(self.leaderPeerCache, sender)
end

function Raid:IsRaidSyncActive()
    return self.db and self.db.raidLocked
        and (not self.db.raidReadOnly or self.fullSyncReadOnly ~= nil)
        or false
end

function Raid:BeginFullSyncReadOnly(sender, raidKey, raidSessionID)
    local state = self.fullSyncReadOnly
    if not state then
        state = {}
        self.fullSyncReadOnly = state
    end
    state.sender = sender
    state.raidKey = raidKey
    state.raidSessionID = raidSessionID
    self.selectedPlayer = nil
    self.dragPlayer = nil
    if self.HideDragGhost then self:HideDragGhost() end
    if self.RefreshQuickActionBar then self:RefreshQuickActionBar() end
    if self.RefreshFooterLayout then self:RefreshFooterLayout() end
    if self.RefreshBossRail then self:RefreshBossRail() end
end

function Raid:EndFullSyncReadOnly(sender)
    local state = self.fullSyncReadOnly
    if not state then return end
    if sender and state.sender and not SamePlayer(sender, state.sender) then
        return
    end
    self.fullSyncReadOnly = nil
    if self.RefreshQuickActionBar then self:RefreshQuickActionBar() end
    if self.RefreshFooterLayout then self:RefreshFooterLayout() end
    if self.RefreshBossRail then self:RefreshBossRail() end
end

function Raid:IsLocalRaidSessionOwner()
    local ownName = GetUnitName and GetUnitName("player", true)
        or UnitName and UnitName("player")
    if self.activeRaidLeader and self.activeRaidLeader ~= "" then
        return SamePlayer(self.activeRaidLeader, ownName)
    end
    return self.IsActualRaidLeader and self:IsActualRaidLeader() or false
end

local RAID_MUTATION_FIELDS = {
    PLAN = 5, PLANBATCH = -1, VALUE = -1, CLEAR = -1, PLANRESET = 2,
    TX_BEGIN = 1, TX_END = 1,
    COMP = -1, MANUAL = 6, MANUALBATCH = -1, MANUALDEL = 2, GROUP = -1,
    CURRENT = 2,
    BOSSSET = -1, BOSSCUSTOM = -1, BOSSCUSTOMDEL = 3,
    BOSSRESET = 2,
    PRESETSET = -1, PRESETRESET = 6, PRESETCLEAR = 3,
    PRESETCUSTOM = -1,
}

function Raid:QueueRaidMutation(kind, values)
    if not RAID_MUTATION_FIELDS[kind] or not self:IsLocalRaidEditor() then
        return false
    end
    local target = self.db.raidLocked
        and not self:IsLocalRaidSessionOwner()
        and self.activeRaidLeader or nil
    -- Keep transaction frames and their payload on one throttle lane. Mixing
    -- NORMAL framing with ALERT assignments allows the throttle to reorder
    -- the payload ahead of TX_BEGIN.
    self:QueueSync(
        kind, values, target and "WHISPER" or nil, target, "ALERT")
    return true
end

function Raid:BeginRaidMutationTransaction(raidKey)
    if not self:IsLocalRaidEditor() then return false end
    self.outgoingRaidTransactionDepth =
        (self.outgoingRaidTransactionDepth or 0) + 1
    if self.outgoingRaidTransactionDepth == 1 then
        self.outgoingRaidTransactionKey = raidKey or self.db.activeRaid
        self:QueueRaidMutation(
            "TX_BEGIN", { self.outgoingRaidTransactionKey })
    end
    return true
end

function Raid:EndRaidMutationTransaction()
    local depth = tonumber(self.outgoingRaidTransactionDepth) or 0
    if depth <= 0 then return false end
    depth = depth - 1
    self.outgoingRaidTransactionDepth = depth
    if depth == 0 then
        local raidKey = self.outgoingRaidTransactionKey or self.db.activeRaid
        self.outgoingRaidTransactionKey = nil
        self:QueueRaidMutation("TX_END", { raidKey })
    end
    return true
end

function Raid:RelayRaidMutation(kind, fields)
    local count = RAID_MUTATION_FIELDS[kind]
    if not count or not self:IsLocalRaidSessionOwner() then return false end
    if count < 0 then count = #fields - 3 end
    if (kind == "PLANBATCH" or kind == "CLEAR") and count <= 2 then
        return false
    elseif kind == "VALUE" and (count < 4 or count % 2 ~= 0) then
        return false
    end
    local values = {}
    for index = 1, count do values[index] = fields[index + 3] or "" end
    self:QueueSync(kind, values, nil, nil, "ALERT")
    return true
end

function Raid:IsCurrentRaidPlayerName(name)
    if not name or name == "" then return false end
    for _, player in ipairs(self.roster or {}) do
        if SamePlayer(player.name, name) then return true end
    end
    return false
end

function Raid:IsCurrentRosterAuthoritative()
    if self:IsSimulating() then return #(self.roster or {}) > 0 end
    if not self:IsInLiveGroup() then return true end
    local liveCount = self:IsInLiveRaid()
        and self:GetLiveRaidMemberCount()
        or self:GetLivePartyMemberCount()
    return liveCount > 0 and #(self.roster or {}) >= liveCount
end

function Raid:QueueRaidClearMutations(raidKey, pendingClears)
    local queued = 0
    for encounterIndex, keys in pairs(pendingClears or {}) do
        local batch = { raidKey, encounterIndex }
        local estimatedSize = EstimatedMessageSize(self, raidKey)
        local function FlushBatch()
            if #batch <= 2 then return end
            self:QueueRaidMutation("CLEAR", batch)
            queued = queued + 1
            batch = { raidKey, encounterIndex }
            estimatedSize = EstimatedMessageSize(self, raidKey)
        end
        for _, assignmentKey in ipairs(keys) do
            local entrySize = #EncodePlanKey(assignmentKey) + 1
            if #batch > 2 and estimatedSize + entrySize > 235 then
                FlushBatch()
            end
            batch[#batch + 1] = assignmentKey
            estimatedSize = estimatedSize + entrySize
        end
        FlushBatch()
    end
    return queued
end

function Raid:PruneAssignmentsToCurrentRoster(broadcast)
    local raid = self:GetRaid()
    if not raid then return 0 end
    if not self:IsCurrentRosterAuthoritative() then return 0 end
    local plans = self.simulation.enabled
        and self.simulation.plans or self.db.plans
    local removed = 0
    local pendingClears = {}
    local rosterNames = {}
    for _, player in ipairs(self.roster or {}) do
        CachePeerFlag(rosterNames, player.name)
    end
    for encounterIndex, plan in pairs(plans[raid.key] or {}) do
        for assignmentKey, assignment in pairs(plan) do
            if type(assignment) == "table" and assignment.name
                and not HasPeerFlag(rosterNames, assignment.name)
            then
                plan[assignmentKey] = nil
                removed = removed + 1
                if broadcast then
                    pendingClears[encounterIndex] =
                        pendingClears[encounterIndex] or {}
                    pendingClears[encounterIndex][
                        #pendingClears[encounterIndex] + 1] = assignmentKey
                end
            end
        end
    end
    if next(pendingClears) ~= nil then
        self:BeginRaidMutationTransaction(raid.key)
        self:QueueRaidClearMutations(raid.key, pendingClears)
        self:EndRaidMutationTransaction()
    end
    return removed
end

local function QueuePlanEntries(
    owner, raidKey, encounterIndex, plan, compact, nameReferences, QueueEntry)
    local planBatch = { raidKey, encounterIndex }
    local planSize = EstimatedMessageSize(owner, raidKey, nil, compact)
    local valueBatch = { raidKey, encounterIndex }
    local valueSize = planSize
    local function FlushPlanBatch()
        if #planBatch <= 2 then return end
        QueueEntry("PLANBATCH", planBatch)
        planBatch = { raidKey, encounterIndex }
        planSize = EstimatedMessageSize(owner, raidKey, nil, compact)
    end
    local function FlushValueBatch()
        if #valueBatch <= 2 then return end
        QueueEntry("VALUE", valueBatch)
        valueBatch = { raidKey, encounterIndex }
        valueSize = EstimatedMessageSize(owner, raidKey, nil, compact)
    end
    for key, value in pairs(plan) do
        if type(value) == "table" then
            local name, class = value.name or "", value.class or ""
            if name ~= "" then
                local reference = nameReferences
                    and nameReferences[PlayerKey(name)]
                local wireName = reference and ("~" .. Base36(reference))
                    or name
                local wireClass = reference and "" or class
                local encodedClass = CLASS_TO_WIRE[wireClass] or wireClass
                local entrySize = #EncodePlanKey(key) + #tostring(wireName)
                    + #tostring(encodedClass) + 3
                if #planBatch > 2 and planSize + entrySize > 235 then
                    FlushPlanBatch()
                end
                planBatch[#planBatch + 1] = key
                planBatch[#planBatch + 1] = wireName
                planBatch[#planBatch + 1] = wireClass
                planSize = planSize + entrySize
            end
        elseif value ~= "" then
            local encodedValue = tostring(value)
            local entrySize = #EncodePlanKey(key) + #encodedValue + 2
            if #valueBatch > 2 and valueSize + entrySize > 235 then
                FlushValueBatch()
            end
            valueBatch[#valueBatch + 1] = key
            valueBatch[#valueBatch + 1] = encodedValue
            valueSize = valueSize + entrySize
        end
    end
    FlushPlanBatch()
    FlushValueBatch()
end

local function BuildSnapshotNameDictionary(raidPlans, encounterCount)
    local candidates = {}
    for encounterIndex = 1, tonumber(encounterCount) or 0 do
        local plan = raidPlans and raidPlans[encounterIndex] or {}
        for _, assignment in pairs(plan or {}) do
            if type(assignment) == "table"
                and assignment.name and assignment.name ~= ""
            then
                local key = PlayerKey(assignment.name)
                local candidate = candidates[key]
                if candidate then
                    candidate.count = candidate.count + 1
                    if candidate.class == "" and assignment.class then
                        candidate.class = assignment.class
                    end
                else
                    candidates[key] = {
                        name = assignment.name,
                        class = assignment.class or "",
                        count = 1,
                    }
                end
            end
        end
    end
    local entries = {}
    for _, candidate in pairs(candidates) do
        -- The dictionary entry has its own cost. Three uses is a conservative
        -- break-even point even for short character names.
        if candidate.count >= 3 then entries[#entries + 1] = candidate end
    end
    table.sort(entries, function(left, right)
        return PlayerKey(left.name) < PlayerKey(right.name)
    end)
    local dictionaryBytes, assignmentBytesSaved = 0, 0
    for index, entry in ipairs(entries) do
        local class = CLASS_TO_WIRE[entry.class] or entry.class
        local originalSize = #tostring(entry.name) + #tostring(class)
        local referenceSize = 1 + #Base36(index)
        dictionaryBytes = dictionaryBytes
            + #tostring(entry.name) + #tostring(class) + 2
        assignmentBytesSaved = assignmentBytesSaved
            + entry.count * (originalSize - referenceSize)
    end
    -- Do not add a dictionary packet unless the repeated-name savings also
    -- repay its framing cost. This keeps small snapshots smaller too.
    local dictionaryEnvelope = 32
        + math.floor(dictionaryBytes / 190) * 28
    if assignmentBytesSaved <= dictionaryBytes + dictionaryEnvelope then
        return {}, {}
    end
    local references = {}
    for index, entry in ipairs(entries) do
        references[PlayerKey(entry.name)] = index
    end
    return entries, references
end

local function QueueSnapshotNameDictionary(
    owner, raidKey, entries, distribution, target, priority)
    if not entries or #entries == 0 then return end
    local compact = UsesCompactWire(owner, target)
    local batch, nextIndex = { raidKey, 1 }, 1
    local estimatedSize = EstimatedMessageSize(owner, raidKey, nil, compact)
    local function FlushBatch()
        if #batch <= 2 then return end
        owner:QueueSync("NAMES", batch, distribution, target, priority)
        batch = { raidKey, nextIndex }
        estimatedSize = EstimatedMessageSize(owner, raidKey, nil, compact)
    end
    for index, entry in ipairs(entries) do
        local encodedClass = CLASS_TO_WIRE[entry.class] or entry.class
        local entrySize = #tostring(entry.name) + #tostring(encodedClass) + 2
        if #batch > 2 and estimatedSize + entrySize > 235 then
            FlushBatch()
        end
        if #batch == 2 then batch[2] = index end
        batch[#batch + 1] = entry.name
        batch[#batch + 1] = entry.class
        estimatedSize = estimatedSize + entrySize
        nextIndex = index + 1
    end
    FlushBatch()
end

local function PlanHasSyncState(plan)
    for _, value in pairs(plan or {}) do
        if type(value) == "table" then
            if value.name and value.name ~= "" then return true end
        elseif value ~= nil and value ~= "" then
            return true
        end
    end
    return false
end

local function QueueSettingEntries(
    owner, kind, raidKey, encounterIndex, presetID, settings, compact, QueueEntry)
    local prefix = { raidKey, encounterIndex }
    if kind == "PRESETSET" then prefix[#prefix + 1] = presetID end
    local batch = {}
    for index, value in ipairs(prefix) do batch[index] = value end
    local prefixCount = #prefix
    local estimatedSize = EstimatedMessageSize(
        owner, raidKey, #tostring(presetID or ""), compact)
    local function FlushBatch()
        if #batch <= prefixCount then return end
        QueueEntry(kind, batch)
        batch = {}
        for index, value in ipairs(prefix) do batch[index] = value end
        estimatedSize = EstimatedMessageSize(
            owner, raidKey, #tostring(presetID or ""), compact)
    end
    local function Add(key, value)
        if value == nil then return end
        local entrySize = #EncodeSettingKey(key) + #Base36(value) + 2
        if #batch > prefixCount and estimatedSize + entrySize > 235 then
            FlushBatch()
        end
        batch[#batch + 1] = key
        batch[#batch + 1] = value
        estimatedSize = estimatedSize + entrySize
    end
    if settings and tonumber(settings.healers) then
        Add("HEALERS", settings.healers)
    end
    local groupIndices = {}
    for groupIndex in pairs(settings and settings.groups or {}) do
        groupIndices[#groupIndices + 1] = groupIndex
    end
    table.sort(groupIndices, function(left, right)
        return (tonumber(left) or 0) < (tonumber(right) or 0)
    end)
    for _, groupIndex in ipairs(groupIndices) do
        Add("G:" .. groupIndex, settings.groups[groupIndex])
    end
    FlushBatch()
end

function Raid:QueueRaidSettingMutations(
    kind, raidKey, encounterIndex, presetID, settings)
    QueueSettingEntries(
        self, kind, raidKey, encounterIndex, presetID, settings, false,
        function(messageKind, values)
            self:QueueRaidMutation(messageKind, values)
        end)
end

local function QueueCustomEntries(
    owner, kind, raidKey, encounterIndex, presetID, customGroups, compact,
    QueueEntry)
    local prefix = { raidKey, encounterIndex }
    if kind == "PRESETCUSTOM" then prefix[#prefix + 1] = presetID end
    local batch = {}
    for index, value in ipairs(prefix) do batch[index] = value end
    local prefixCount = #prefix
    local estimatedSize = EstimatedMessageSize(
        owner, raidKey, #tostring(presetID or ""), compact)
    local function FlushBatch()
        if #batch <= prefixCount then return end
        QueueEntry(kind, batch)
        batch = {}
        for index, value in ipairs(prefix) do batch[index] = value end
        estimatedSize = EstimatedMessageSize(
            owner, raidKey, #tostring(presetID or ""), compact)
    end
    for _, custom in ipairs(customGroups or {}) do
        local id, name = custom.id or "", custom.name or ""
        if id ~= "" and name ~= "" then
            local count = custom.count or 1
            local entrySize = #tostring(id) + #tostring(name)
                + #tostring(count) + 3
            if #batch > prefixCount
                and estimatedSize + entrySize > 235
            then
                FlushBatch()
            end
            batch[#batch + 1] = id
            batch[#batch + 1] = name
            batch[#batch + 1] = count
            estimatedSize = estimatedSize + entrySize
        end
    end
    FlushBatch()
end

function Raid:QueueRaidCustomMutations(
    kind, raidKey, encounterIndex, presetID, customGroups)
    QueueCustomEntries(
        self, kind, raidKey, encounterIndex, presetID, customGroups, false,
        function(messageKind, values)
            self:QueueRaidMutation(messageKind, values)
        end)
end

function Raid:BroadcastEncounterPlanMutations(encounterIndex, transactionOpen)
    local raid = self:GetRaid()
    encounterIndex = tonumber(encounterIndex)
    if not raid or not raid.encounters[encounterIndex] then return end
    local plans = self.simulation.enabled
        and self.simulation.plans or self.db.plans
    local plan = plans[raid.key] and plans[raid.key][encounterIndex] or {}
    if not transactionOpen then
        self:BeginRaidMutationTransaction(raid.key)
    end
    self:QueueRaidMutation("PLANRESET", { raid.key, encounterIndex })
    QueuePlanEntries(self, raid.key, encounterIndex, plan, false, nil,
        function(kind, values)
            self:QueueRaidMutation(kind, values)
        end)
    if not transactionOpen then
        self:EndRaidMutationTransaction()
    end
end

function Raid:BroadcastAllPlanMutations()
    local raid = self:GetRaid()
    if not raid then return end
    self:BeginRaidMutationTransaction(raid.key)
    for encounterIndex = 1, #raid.encounters do
        self:BroadcastEncounterPlanMutations(encounterIndex, true)
    end
    self:EndRaidMutationTransaction()
end

local function SyncQueueCoalesceKey(
    kind, values, distribution, target, assignmentGeneration)
    local recipient = tostring(distribution or "")
        .. ":" .. string.lower(tostring(target or ""))
    if kind == "PLAN" or kind == "VALUE" and #values == 4
        or kind == "CLEAR" and #values == 3
    then
        return table.concat({
            "ASSIGNMENT", tostring(values[1]), tostring(values[2]),
            tostring(values[3]), tostring(assignmentGeneration), recipient,
        }, "|")
    elseif kind == "SELECT" then
        return "SELECT|" .. recipient
    elseif kind == "CURRENT" then
        return table.concat({
            "CURRENT", tostring(values[1]),
            tostring(assignmentGeneration), recipient,
        }, "|")
    elseif kind == "COOLDOWN" then
        return "COOLDOWN|" .. tostring(values[1]) .. "|" .. recipient
    elseif kind == "PROFILE" then
        return "PROFILE|" .. recipient
    elseif kind == "CHECK" then
        return "CHECK|" .. recipient
    elseif kind == "INSPECT_CLAIM" then
        return "INSPECT_CLAIM|" .. tostring(values[1]) .. "|" .. recipient
    elseif kind == "HELLO" then
        return "HELLO|" .. tostring(values[2]) .. "|" .. recipient
    end
end

local function SyncQueueIndexKey(item)
    if not item or not item.coalesceKey then return nil end
    return item.coalesceKey .. "\029" .. tostring(item.raidSessionID or "")
end

local function FullSnapshotTargetKey(sessionID, target)
    if not sessionID or not target or target == "" then return nil end
    return tostring(sessionID) .. "\029" .. PlayerKey(target)
end

local function IsNonBulkQueueItem(item)
    return item and item.priority ~= "BULK" or false
end

local function IndexSyncQueueItem(owner, item, index)
    local key = SyncQueueIndexKey(item)
    if key then
        owner.syncQueueCoalesceIndex = owner.syncQueueCoalesceIndex or {}
        owner.syncQueueCoalesceIndex[key] = index
    end
    local snapshotKey = item and item.kind == "FULL_END"
        and FullSnapshotTargetKey(item.raidSessionID, item.target)
    if snapshotKey then
        owner.syncQueueFullSnapshotIndex =
            owner.syncQueueFullSnapshotIndex or {}
        owner.syncQueueFullSnapshotIndex[snapshotKey] = index
    end
end

local function RemoveIndexedSyncQueueItem(owner, item, index)
    local key = SyncQueueIndexKey(item)
    if key and owner.syncQueueCoalesceIndex
        and owner.syncQueueCoalesceIndex[key] == index
    then
        owner.syncQueueCoalesceIndex[key] = nil
    end
    local snapshotKey = item and item.kind == "FULL_END"
        and FullSnapshotTargetKey(item.raidSessionID, item.target)
    if snapshotKey and owner.syncQueueFullSnapshotIndex
        and owner.syncQueueFullSnapshotIndex[snapshotKey] == index
    then
        owner.syncQueueFullSnapshotIndex[snapshotKey] = nil
    end
end

local function RebuildSyncQueueIndexes(owner)
    owner.syncQueueCoalesceIndex = {}
    owner.syncQueueFullSnapshotIndex = {}
    owner.syncQueueNonBulkCount = 0
    for index = owner.syncQueueHead or 1, owner.syncQueueTail or 0 do
        local item = owner.syncQueue and owner.syncQueue[index]
        IndexSyncQueueItem(owner, item, index)
        if IsNonBulkQueueItem(item) then
            owner.syncQueueNonBulkCount = owner.syncQueueNonBulkCount + 1
        end
    end
end

function Raid:QueueSync(kind, values, distribution, target, priority)
    if self.receivingSync then return end
    -- There is no valid PARTY/RAID destination while solo. Avoid building a
    -- queue that can only fail or become stale before the next group is formed.
    if not self:IsInLiveGroup() and not self.syncSimulationCapture then return end
    local sessionless = kind == "HELLO" or kind == "COOLDOWN"
    -- Keep the entire raid document in one priority lane. This preserves wire
    -- order while allowing plan loads and live edits to pass profile/gear data.
    if not priority and RAID_DOCUMENT_KIND[kind] then priority = "ALERT" end
    if not sessionless and not self:IsRaidSyncActive() then return end
    if not self.syncQueue or not self.syncFrame then
        self:InitializeCommunication()
    end
    if not self.syncQueue or not self.syncFrame then return end
    if not self.syncQueueCoalesceIndex
        or not self.syncQueueFullSnapshotIndex
        or self.syncQueueNonBulkCount == nil
    then
        RebuildSyncQueueIndexes(self)
    end
    self.syncSequence = (self.syncSequence or 0) + 1
    local compactWire = UsesCompactWire(self, target)
    local fields = {
        WIRE_HEADER,
        KIND_TO_WIRE[kind] or kind,
        Base36(self.syncSequence),
    }
    local encodedValues = EncodeValues(kind, values)
    if compactWire and RAID_DOCUMENT_KIND[kind]
        and encodedValues[1] == tostring(self.db.activeRaid or "")
    then
        -- SELECT establishes the active raid, so document messages can use
        -- that context instead of repeating the raid key in every packet.
        encodedValues[1] = ""
    end
    for _, value in ipairs(encodedValues) do
        fields[#fields + 1] = value
    end
    local raidSessionID = not sessionless
        and self.db.activeRaidSessionID or nil
    if not sessionless and not raidSessionID then return end
    if kind == "TX_BEGIN" or kind == "PLANRESET"
        or kind == "FULL_BEGIN" or kind == "SNAP_BEGIN"
        or kind == "RESET"
    then
        self.assignmentCoalesceGeneration =
            (self.assignmentCoalesceGeneration or 0) + 1
    end
    if raidSessionID then
        local wireSessionID = (not compactWire
            or kind == "SELECT" or kind == "CLOSE")
            and tostring(raidSessionID)
            or CompactSessionID(raidSessionID)
        fields[#fields + 1] = "@" .. wireSessionID
    end
    local encodedMessage = EncodeWireMessage(fields, compactWire)
    if #encodedMessage > 255 then
        self.syncPayloadWarnings = self.syncPayloadWarnings or {}
        if not self.syncPayloadWarnings[kind] then
            self.syncPayloadWarnings[kind] = true
            self:Print(self:Localize(
                "SYNC_MESSAGE_TOO_LARGE", tostring(kind)))
        end
        return
    end
    local resolvedDistribution = distribution or (
        self:IsInLiveRaid() and "RAID" or "PARTY")
    local item = {
        kind = kind,
        message = encodedMessage,
        sequence = self.syncSequence,
        distribution = resolvedDistribution,
        target = target,
        priority = priority,
        compactWire = compactWire,
        raidSessionID = raidSessionID,
        coalesceKey = SyncQueueCoalesceKey(
            kind, values, resolvedDistribution, target,
            self.assignmentCoalesceGeneration or 0),
    }
    if item.coalesceKey then
        if not self.syncQueueCoalesceIndex then
            RebuildSyncQueueIndexes(self)
        end
        local queueKey = SyncQueueIndexKey(item)
        local index = self.syncQueueCoalesceIndex[queueKey]
        local pending = index and self.syncQueue[index]
        if pending and pending.coalesceKey == item.coalesceKey
            and pending.raidSessionID == item.raidSessionID
        then
            -- Keep the queued packet's original sequence because it will
            -- retain its position ahead of later packets.
            item.sequence = pending.sequence
            fields[3] = Base36(item.sequence)
            item.message = EncodeWireMessage(fields, item.compactWire)
            if IsNonBulkQueueItem(pending) ~= IsNonBulkQueueItem(item) then
                self.syncQueueNonBulkCount =
                    (self.syncQueueNonBulkCount or 0)
                    + (IsNonBulkQueueItem(item) and 1 or -1)
            end
            self.syncQueue[index] = item
            self.syncQueueCoalesceIndex[queueKey] = index
            self.syncFrame:Show()
            return item, fields
        elseif index then
            self.syncQueueCoalesceIndex[queueKey] = nil
        end
    end
    self.syncQueueTail = (self.syncQueueTail or 0) + 1
    self.syncQueue[self.syncQueueTail] = item
    IndexSyncQueueItem(self, item, self.syncQueueTail)
    if IsNonBulkQueueItem(item) then
        self.syncQueueNonBulkCount =
            (self.syncQueueNonBulkCount or 0) + 1
    end
    self.syncFrame:Show()
    return item, fields
end

local function IsCurrentGroupMember(name)
    if not name or name == "" then return false end
    local ownName = GetUnitName and GetUnitName("player", true)
        or UnitName("player")
    if SamePlayer(name, ownName) then return true end
    local prefix = Raid:IsInLiveRaid() and "raid" or "party"
    local count = Raid:IsInLiveRaid()
        and Raid:GetLiveRaidMemberCount()
        or Raid:GetLivePartyMemberCount()
    for index = 1, count do
        local unitName = GetUnitName
            and GetUnitName(prefix .. index, true)
            or UnitName(prefix .. index)
        if SamePlayer(name, unitName) then return true end
    end
    return false
end

function Raid:PruneDepartedSyncTargets()
    if not self.syncQueue then return end
    local retained = {}
    for index = self.syncQueueHead or 1, self.syncQueueTail or 0 do
        local item = self.syncQueue[index]
        if item and (item.distribution ~= "WHISPER"
            or IsCurrentGroupMember(item.target))
        then
            retained[#retained + 1] = item
        end
    end
    self.syncQueue = retained
    self.syncQueueHead = 1
    self.syncQueueTail = #retained
    RebuildSyncQueueIndexes(self)
    if #retained == 0 and self.syncFrame then self.syncFrame:Hide() end
end

function Raid:DiscardPendingSync()
    self.syncQueue = {}
    self.syncQueueHead = 1
    self.syncQueueTail = 0
    self.syncQueueCoalesceIndex = {}
    self.syncQueueFullSnapshotIndex = {}
    self.syncQueueNonBulkCount = 0
    self.fullSnapshotQueuedAt = {}
    self.outgoingRaidTransactionDepth = 0
    self.outgoingRaidTransactionKey = nil
    self.assignmentCoalesceGeneration =
        (self.assignmentCoalesceGeneration or 0) + 1
    if self.syncFrame then self.syncFrame:Hide() end
end

function Raid:CancelRaidCommunication()
    self:EndFullSyncReadOnly()
    self:DiscardPendingSync()
    if self.CancelRaidSyncProgress then self:CancelRaidSyncProgress() end
    if self.messageQueue then wipe(self.messageQueue) end
    if self.messageFrame then self.messageFrame:Hide() end
    self.receivingSnapshots = nil
    self.receivingFullSnapshots = nil
    self.fullSnapshotNames = nil
    self.fullSnapshotLastActivity = nil
    self.receivingRaidTransactions = nil
    self.raidTransactionTokens = nil
    self.pendingRaidConfigurationTransactions = nil
    self.pendingRaidRosterTransactions = nil
    self.pendingRemoteSimulationRoster = nil
    self.receivingSimulation = nil
    self.simulationReceiveTokens = nil
    self.sentSimulationFingerprints = nil
    self.snapshotFinalizeGeneration =
        (self.snapshotFinalizeGeneration or 0) + 1
end

function Raid:BroadcastPlanValue(key, value)
    if not self:IsLocalRaidEditor() then return end
    local raid = self:GetRaid()
    local _, encounterIndex = self:GetEncounter()
    if type(value) == "table" then
        self:QueueRaidMutation("PLAN", {
            raid.key, encounterIndex, key,
            value.name or "", value.class or "",
        })
    elseif value == nil then
        self:QueueRaidMutation("CLEAR", {
            raid.key, encounterIndex, key,
        })
    else
        self:QueueRaidMutation("VALUE", {
            raid.key, encounterIndex, key, tostring(value),
        })
    end
    -- Assignment persistence belongs to the shared mutation path. Some UI
    -- controls only broadcast their changed value, so relying on every caller
    -- to autosave can leave the history entry with an older/empty plan.
    if self.db.raidLocked and self.db.activeSavedRaid then
        if not self.db.savedRaids[self.db.activeSavedRaid]
            and self.SaveCurrentRaid
        then
            self:SaveCurrentRaid(nil, true)
        elseif self.AutoSaveActiveRaid then
            self:AutoSaveActiveRaid()
        end
    end
end

function Raid:BroadcastSelection(target, priority)
    if not self:IsLocalRaidEditor() then return end
    self:QueueSync("SELECT", {
        self.db.activeRaid, self.db.activeEncounter,
    }, target and "WHISPER" or nil, target, priority)
end

function Raid:BroadcastRaidAvailability()
    if not self:IsInLiveGroup()
        or not self:IsRaidSyncActive()
        or not self:IsLocalRaidSessionOwner()
        or not self.db.activeRaid
        or not self.db.activeRaidSessionID
    then
        return
    end
    self:BroadcastSelection()
end

function Raid:InitializeRaidAvailabilityBroadcast()
    if self.raidAvailabilityTicker or self.raidAvailabilityFrame then return end
    if C_Timer and C_Timer.NewTicker then
        self.raidAvailabilityTicker = C_Timer.NewTicker(5, function()
            Raid:BroadcastRaidAvailability()
        end)
        return
    end
    local frame = CreateFrame("Frame")
    frame.elapsed = 0
    frame:SetScript("OnUpdate", function(owner, elapsed)
        owner.elapsed = owner.elapsed + elapsed
        if owner.elapsed < 5 then return end
        owner.elapsed = 0
        Raid:BroadcastRaidAvailability()
    end)
    self.raidAvailabilityFrame = frame
end

function Raid:BroadcastCurrentBoss(target, priority)
    local raid = self:GetRaid()
    local index = self:GetCurrentBossIndex(raid)
    if not index or not self:IsLocalRaidEditor() then return end
    self:QueueSync(
        "CURRENT", { raid.key, index },
        target and "WHISPER" or nil, target, priority)
end

local function RosterStateFingerprint(roster)
    local parts = {}
    for _, player in ipairs(roster or {}) do
        parts[#parts + 1] = table.concat({
            tostring(player.name or ""), tostring(player.class or ""),
            tostring(player.role or player.reportedRole or ""),
            tostring(player.race or ""), tostring(player.subgroup or 1),
            tostring(player.spec or ""), tostring(player.online ~= false),
        }, "\031")
    end
    return table.concat(parts, "\030")
end

local function ShouldSendSimulationState(owner, target, fingerprint, force)
    local cacheKey = tostring(owner.db.activeRaidSessionID or "")
        .. "|" .. string.lower(tostring(target or "*"))
    owner.sentSimulationFingerprints =
        owner.sentSimulationFingerprints or {}
    if not force
        and owner.sentSimulationFingerprints[cacheKey] == fingerprint
    then
        return false
    end
    owner.sentSimulationFingerprints[cacheKey] = fingerprint
    return true
end

function Raid:BroadcastSimulationClear(target, priority, omitFraming)
    if not self:IsLocalRaidEditor()
        or not self:IsInLiveGroup() and not self.syncSimulationCapture
    then
        return
    end
    if self.db.raidLocked and not self:IsLocalRaidSessionOwner() then return end
    if not ShouldSendSimulationState(
        self, target, "CLEAR", priority ~= nil)
    then
        return
    end
    -- FULL_BEGIN already clears the remote roster and FULL_END commits it.
    if omitFraming then return end
    self:QueueSync(
        "SIM_BEGIN", { self.db.activeRaid },
        target and "WHISPER" or nil, target, priority)
    self:QueueSync(
        "SIM_END", { self.db.activeRaid },
        target and "WHISPER" or nil, target, priority)
end

function Raid:BroadcastSimulationRoster(target, priority, omitFraming)
    if not self:IsLocalRaidEditor()
        or not self:IsInLiveGroup() and not self.syncSimulationCapture
    then
        return
    end
    if self.db.raidLocked and not self:IsLocalRaidSessionOwner() then return end
    local fingerprint = RosterStateFingerprint(self.simulation.roster)
    if not ShouldSendSimulationState(
        self, target, fingerprint, priority ~= nil)
    then
        return
    end
    local distribution = target and "WHISPER" or nil
    local compactWire = UsesCompactWire(self, target)
    if not omitFraming then
        self:QueueSync(
            "SIM_BEGIN", { self.db.activeRaid }, distribution, target, priority)
    end
    local raidKey = self.db.activeRaid
    local batch = { raidKey }
    local estimatedSize = EstimatedMessageSize(
        self, raidKey, nil, compactWire)
    local function FlushBatch()
        if #batch <= 1 then return end
        self:QueueSync(
            "SIMBATCH", batch, distribution, target, priority)
        batch = { raidKey }
        estimatedSize = EstimatedMessageSize(
            self, raidKey, nil, compactWire)
    end
    for _, player in ipairs(self.simulation.roster or {}) do
        local name = player.name or ""
        local class = player.class or ""
        local role = player.role or player.reportedRole or "DAMAGER"
        local race = player.race or ""
        local subgroup = player.subgroup or 1
        local spec = player.spec or ""
        local entrySize = #tostring(name)
            + #tostring(CLASS_TO_WIRE[class] or class)
            + #tostring(ROLE_TO_WIRE[role] or role)
            + #tostring(race) + #Base36(subgroup)
            + #tostring(spec) + 6
        if #batch > 1 and estimatedSize + entrySize > 235 then
            FlushBatch()
        end
        batch[#batch + 1] = name
        batch[#batch + 1] = class
        batch[#batch + 1] = role
        batch[#batch + 1] = race
        batch[#batch + 1] = subgroup
        batch[#batch + 1] = spec
        estimatedSize = estimatedSize + entrySize
    end
    FlushBatch()
    if not omitFraming then
        self:QueueSync(
            "SIM_END", { self.db.activeRaid }, distribution, target, priority)
    end
end

local function SyncFingerprint(value, seen)
    local valueType = type(value)
    if valueType ~= "table" then
        return valueType .. ":" .. tostring(value)
    end
    seen = seen or {}
    if seen[value] then return "cycle" end
    seen[value] = true
    local keys = {}
    for key in pairs(value) do keys[#keys + 1] = key end
    table.sort(keys, function(left, right)
        return tostring(left) < tostring(right)
    end)
    local parts = { "{" }
    for _, key in ipairs(keys) do
        parts[#parts + 1] = SyncFingerprint(key, seen)
        parts[#parts + 1] = "="
        parts[#parts + 1] = SyncFingerprint(value[key], seen)
        parts[#parts + 1] = ";"
    end
    parts[#parts + 1] = "}"
    seen[value] = nil
    return table.concat(parts)
end

local function SyncRecipientKey(target)
    return target and string.lower(target) or "*"
end

function Raid:ClearSentSyncFingerprints(target)
    local recipient = SyncRecipientKey(target)
    for _, field in ipairs({
        "sentGearFingerprints",
        "sentProfileFingerprints",
        "sentSimulationFingerprints",
    }) do
        local cache = self[field]
        if cache then
            for key in pairs(cache) do
                if key == recipient
                    or key:find("|" .. recipient .. "|", 1, true)
                    or key:sub(-#recipient - 1) == "|" .. recipient
                then
                    cache[key] = nil
                end
            end
        end
    end
end

function Raid:SendPlanSnapshot(
    target, requestedEncounterIndex, includeSharedRaidState, fullHeaderState,
    nameReferences)
    if not self:IsLocalRaidEditor() then return end
    local raid = self:GetRaid()
    local encounterIndex = tonumber(requestedEncounterIndex)
        or select(2, self:GetEncounter())
    if not raid.encounters[encounterIndex] then return end
    local distribution = target and "WHISPER" or nil
    local compactWire = UsesCompactWire(self, target)
    local priority = "ALERT"
    if includeSharedRaidState == nil then includeSharedRaidState = true end
    local plans = self.simulation.enabled
        and self.simulation.plans or self.db.plans
    local plan = plans[raid.key]
        and plans[raid.key][encounterIndex] or {}
    local bossOverride = self:GetBossOverride(
        false, raid.key, encounterIndex)
    local presetCollection = self.db.bossPresets[raid.key]
        and self.db.bossPresets[raid.key][encounterIndex]
    if includeSharedRaidState and not fullHeaderState then
        self:BroadcastCurrentBoss(target, priority)
    end
    QueuePlanEntries(
        self, raid.key, encounterIndex, plan, compactWire, nameReferences,
        function(kind, values)
            self:QueueSync(kind, values, distribution, target, priority)
        end)
    if includeSharedRaidState then
        local composition = self:GetRaidComposition(raid.key)
        if not fullHeaderState then
            self:QueueSync("COMP", {
                raid.key,
                "tanks", composition.tanks,
                "healers", composition.healers,
            }, distribution, target, priority)
        end
        local manualBatch = { raid.key }
        local manualSize = EstimatedMessageSize(
            self, raid.key, nil, compactWire)
        local function FlushManualBatch()
            if #manualBatch <= 1 then return end
            self:QueueSync("MANUALBATCH", manualBatch,
                distribution, target, priority)
            manualBatch = { raid.key }
            manualSize = EstimatedMessageSize(
                self, raid.key, nil, compactWire)
        end
        for _, player in pairs(self.db.manualPlayers[raid.key] or {}) do
            local name = player.name or ""
            local class = player.class or ""
            local role = player.role or player.reportedRole or "DAMAGER"
            local spec = player.spec or ""
            local subgroup = player.subgroup or 1
            local entrySize = #tostring(name)
                + #tostring(CLASS_TO_WIRE[class] or class)
                + #tostring(ROLE_TO_WIRE[role] or role)
                + #tostring(spec) + #Base36(subgroup) + 5
            if #manualBatch > 1 and manualSize + entrySize > 235 then
                FlushManualBatch()
            end
            manualBatch[#manualBatch + 1] = name
            manualBatch[#manualBatch + 1] = class
            manualBatch[#manualBatch + 1] = role
            manualBatch[#manualBatch + 1] = spec
            manualBatch[#manualBatch + 1] = subgroup
            manualSize = manualSize + entrySize
        end
        FlushManualBatch()
        if self:IsSimulating() then
            self:BroadcastSimulationRoster(
                target, priority, fullHeaderState)
        elseif self:IsLocalRaidSessionOwner() then
            self:BroadcastSimulationClear(
                target, priority, fullHeaderState)
        end
    end
    if bossOverride then
        QueueCustomEntries(
            self, "BOSSCUSTOM", raid.key, encounterIndex, nil,
            bossOverride.customGroups, compactWire, function(kind, values)
                self:QueueSync(
                    kind, values, distribution, target, priority)
            end)
        QueueSettingEntries(
            self, "BOSSSET", raid.key, encounterIndex, nil, bossOverride,
            compactWire,
            function(kind, values)
                self:QueueSync(
                    kind, values, distribution, target, priority)
            end)
    end
    if presetCollection and type(presetCollection.items) == "table" then
        for presetID, preset in pairs(presetCollection.items) do
            if type(preset) == "table" and type(preset.settings) == "table" then
                self:QueueSync("PRESETRESET", {
                    raid.key, encounterIndex, presetID,
                    preset.name or "", preset.savedAt or 0,
                    presetCollection.selected == presetID and "1" or "0",
                }, distribution, target, priority)
                local settings = preset.settings
                QueueCustomEntries(
                    self, "PRESETCUSTOM", raid.key, encounterIndex,
                    presetID, settings.customGroups, compactWire,
                    function(kind, values)
                        self:QueueSync(
                            kind, values, distribution, target, priority)
                    end)
                QueueSettingEntries(
                    self, "PRESETSET", raid.key, encounterIndex,
                    presetID, settings, compactWire, function(kind, values)
                        self:QueueSync(
                            kind, values, distribution, target, priority)
                    end)
            end
        end
    end
end

function Raid:BroadcastOwnGear(target)
    if not self:IsRaidSyncActive()
        or not self:IsInLiveGroup()
    then
        return
    end
    local gear = {}
    for slotID = 1, 19 do
        gear[slotID] = GetInventoryItemLink
            and GetInventoryItemLink("player", slotID) or false
    end
    local cacheKey = table.concat({
        tostring(self.db.activeRaidSessionID or ""),
        SyncRecipientKey(target),
    }, "|")
    local fingerprint = SyncFingerprint(gear)
    self.sentGearFingerprints = self.sentGearFingerprints or {}
    if self.sentGearFingerprints[cacheKey] == fingerprint then return end
    self.sentGearFingerprints[cacheKey] = fingerprint
    local distribution = target and "WHISPER" or nil
    local compactWire = UsesCompactWire(self, target)
    self:QueueSync("GEAR_BEGIN", {}, distribution, target, "BULK")
    local batch = {}
    local estimatedSize = EstimatedMessageSize(self, nil, nil, compactWire)
    local function FlushGearBatch()
        if #batch == 0 then return end
        self:QueueSync("GEAR", batch, distribution, target, "BULK")
        batch = {}
        estimatedSize = EstimatedMessageSize(self, nil, nil, compactWire)
    end
    for slotID = 1, 19 do
        local link = gear[slotID]
        if link then
            local entrySize = #Base36(slotID) + #tostring(link) + 2
            if #batch > 0 and estimatedSize + entrySize > 235 then
                FlushGearBatch()
            end
            batch[#batch + 1] = slotID
            batch[#batch + 1] = link
            estimatedSize = estimatedSize + entrySize
        end
    end
    FlushGearBatch()
    self:QueueSync("GEAR_END", {}, distribution, target, "BULK")
end

function Raid:BroadcastOwnCooldown(definitionIndex, remaining, target)
    if not self:IsInLiveGroup() then return end
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

function Raid:RequestPeerSync(force)
    if not self:IsInLiveGroup() then return end
    if self.db.raidLocked and self:IsLocalRaidSessionOwner() then return end
    if self.receivingFullSnapshots
        and next(self.receivingFullSnapshots) ~= nil
    then
        return
    end
    local now = GetTime and GetTime() or 0
    if not force and now > 0 and self.lastPeerSyncRequestAt
        and now - self.lastPeerSyncRequestAt < 3
    then
        return
    end
    self.lastPeerSyncRequestAt = now
    self:QueueSync("HELLO", {
        self.syncVersion or self.version or "unknown", "Q", "C",
    })
end

function Raid:ApplyPeerSelection(
    raidKey, encounterIndex, replaceOpenRaid, leader, raidSessionID)
    local raid = self.raidByKey[raidKey]
    if not raid then return end
    local sameSession = self.db.raidLocked
        and self.db.activeRaid == raid.key
        and raidSessionID and raidSessionID ~= ""
        and self.db.activeRaidSessionID == raidSessionID
    if sameSession and (
        not self.db.raidReadOnly or self.fullSyncReadOnly)
    then
        if leader then self.activeRaidLeader = leader end
        return
    end
    local continuingCurrentRaid = sameSession or (
        not replaceOpenRaid
        and self.db.raidLocked and self.db.activeRaid == raid.key)
    if replaceOpenRaid and not sameSession then
        self:EndFullSyncReadOnly()
        if self.DiscardPendingSync then self:DiscardPendingSync() end
        -- A leader selection starts a new shared session. Detach assistants
        -- from their previous open plan without deleting the saved plan.
        self.db.raidLocked = false
        self.db.activeSavedRaid = nil
        self.selectedPlayer = nil
        self.dragPlayer = nil
        self.remoteSimulationRoster = nil
        self.pendingRemoteSimulationRoster = nil
        self.receivingSimulation = nil
        self.simulationReceiveTokens = nil
        self.sentSimulationFingerprints = nil
        self.receivingSnapshots = nil
        self.receivingFullSnapshots = nil
        self.fullSnapshotNames = nil
        self.fullSnapshotLastActivity = nil
        self.receivingRaidTransactions = nil
        self.raidTransactionTokens = nil
        self.pendingRaidConfigurationTransactions = nil
        self.pendingRaidRosterTransactions = nil
        self.snapshotFinalizeGeneration =
            (self.snapshotFinalizeGeneration or 0) + 1
        wipe(self.messageQueue)
        if self.messageFrame then self.messageFrame:Hide() end
        if self.HideDragGhost then self:HideDragGhost() end
        local plans = self.simulation.enabled
            and self.simulation.plans or self.db.plans
        plans[raid.key] = {}
        self.db.bossOverrides[raid.key] = {}
        self.db.bossPresets[raid.key] = {}
        self.db.manualPlayers[raid.key] = {}
    end
    self.db.activeExpansion = raid.expansion
    self.db.activeRaid = raid.key
    if not sameSession then
        self.db.activeEncounter = math.max(
            1, math.min(tonumber(encounterIndex) or 1, #raid.encounters))
    end
    self.db.lastRaidByExpansion[raid.expansion] = raid.key
    self.db.lastEncounterByRaid[raid.key] = self.db.activeEncounter
    self.db.raidLocked = true
    self.db.raidReadOnly = false
	self.db.activeRaidSessionID = raidSessionID
		or self.db.activeRaidSessionID
	self.db.activeSavedRaid = self.db.activeRaidSessionID
	if not continuingCurrentRaid then
		local saved = self.db.activeSavedRaid
			and self.db.savedRaids[self.db.activeSavedRaid]
		self.db.activeBossKills = {}
		for index, kill in pairs(saved and saved.bossKills or {}) do
			self.db.activeBossKills[index] = kill
		end
    end
    if leader then self.activeRaidLeader = leader end
    if leader and not continuingCurrentRaid then
        self:BeginFullSyncReadOnly(leader, raid.key, raidSessionID)
        if self.BeginRaidSyncProgress then
            self:BeginRaidSyncProgress(nil, raid.name)
        end
    end
    self:ApplyRaidComposition(raid)
    local isAssistant = self:IsGroupAssistant()
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

function Raid:OfferLeaderRaid(sender, raidKey, encounterIndex, raidSessionID)
    local raid = self.raidByKey[raidKey]
    if not raid or not raidSessionID or raidSessionID == "" then return end
    if self.activeRaidLeader and SamePlayer(self.activeRaidLeader, sender)
        and self.db.raidLocked and self.db.activeRaid == raidKey
        and self.db.activeRaidSessionID == raidSessionID
        and not self.db.raidReadOnly
    then
        self:ApplyPeerSelection(
            raidKey, encounterIndex, false, sender, raidSessionID)
        return
    end
    local currentOffer = self.availableLeaderRaid
    if currentOffer and SamePlayer(currentOffer.sender, sender)
        and currentOffer.raidKey == raidKey
        and currentOffer.raidSessionID == raidSessionID
    then
        currentOffer.encounterIndex = tonumber(encounterIndex) or 1
        return
    end
    self.availableLeaderRaid = {
        sender = sender,
        raidKey = raidKey,
        encounterIndex = tonumber(encounterIndex) or 1,
        raidSessionID = raidSessionID,
    }
    if self.RefreshLeaderRaidToast then self:RefreshLeaderRaidToast() end
    if self.RefreshFooterLayout then self:RefreshFooterLayout() end
end

function Raid:DismissLeaderRaidOffer()
    if not self.availableLeaderRaid then return end
    -- Keep the offer as a dismissed sync barrier so snapshots already queued
    -- behind SELECT cannot silently activate the raid.
    self.availableLeaderRaid.dismissed = true
    if self.RefreshLeaderRaidToast then self:RefreshLeaderRaidToast() end
end

function Raid:AcceptLeaderRaidOffer()
    local offer = self.availableLeaderRaid
    if not offer or not self:IsAuthorizedPeer(offer.sender) then
        self.availableLeaderRaid = nil
        if self.RefreshLeaderRaidToast then self:RefreshLeaderRaidToast() end
        if self.RefreshFooterLayout then self:RefreshFooterLayout() end
        return false
    end
    self.availableLeaderRaid = nil
    self.manuallyLeftSharedRaid = nil
    self.activeRaidLeader = offer.sender
    self:ApplyPeerSelection(
        offer.raidKey, offer.encounterIndex, true, offer.sender,
        offer.raidSessionID)
    if self.RequestPeerSync then self:RequestPeerSync(true) end
    if self.RefreshLeaderRaidToast then self:RefreshLeaderRaidToast() end
    if self.RefreshFooterLayout then self:RefreshFooterLayout() end
    return true
end

function Raid:FinalizeReceivedSnapshot()
    if self.receivingSnapshots
        and next(self.receivingSnapshots) ~= nil
    then
        return false
    end
    self:UpdateRoster(true)
    if self.frame and self.frame:IsShown() and self.RefreshAll then
        self:RefreshAll()
    elseif self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
    if self.db.raidLocked and self.db.activeSavedRaid then
        if not self.db.savedRaids[self.db.activeSavedRaid]
            and self.SaveCurrentRaid
        then
            self:SaveCurrentRaid(nil, true)
        elseif self.AutoSaveActiveRaid then
            self:AutoSaveActiveRaid()
        end
    end
    return true
end

function Raid:IsReceivingRaidTransaction()
    return self.receivingSnapshots
        and next(self.receivingSnapshots) ~= nil
        or self.receivingRaidTransactions
        and next(self.receivingRaidTransactions) ~= nil
        or self.receivingSimulation ~= nil
        or false
end

function Raid:FinalizeReceivedRaidMutation()
    if self:IsReceivingRaidTransaction() then return false end
    if self.db.raidLocked and self.db.activeSavedRaid
        and self.AutoSaveActiveRaid
    then
        if not self.db.savedRaids[self.db.activeSavedRaid]
            and self.SaveCurrentRaid
        then
            self:SaveCurrentRaid(nil, true)
        else
            self:AutoSaveActiveRaid()
        end
    end
    if self.RefreshMechanicsHUD then self:RefreshMechanicsHUD() end
    if self.frame and self.frame:IsShown() and self.RefreshAll then
        self:RefreshAll()
    elseif self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
    return true
end

function Raid:CloseRaidFromPeer()
    self.pendingRemoteRaidClose = nil
    self.manuallyLeftSharedRaid = nil
    self:CancelRaidCommunication()
    self.db.raidLocked = false
    self.db.activeSavedRaid = nil
    self.db.activeRaidSessionID = nil
    self.activeRaidLeader = nil
    self.selectedPlayer = nil
    self.dragPlayer = nil
    self.remoteSimulationRoster = nil
    self.pendingRemoteSimulationRoster = nil
    self.receivingSimulation = nil
    self.receivingSnapshots = nil
    self.receivingFullSnapshots = nil
    self.fullSnapshotLastActivity = nil
    self.snapshotFinalizeGeneration =
        (self.snapshotFinalizeGeneration or 0) + 1
    wipe(self.messageQueue)
    if self.messageFrame then self.messageFrame:Hide() end
    if self.HideDragGhost then self:HideDragGhost() end
    if self.RefreshPersonalAssignments then self:RefreshPersonalAssignments() end
    if self.RefreshMechanicsHUD then self:RefreshMechanicsHUD() end
    if self.RefreshQuickActionBar then self:RefreshQuickActionBar() end
    if self.frame then self.frame:Hide() end
    self:Print(self.L.LEADER_COMPLETED_RAID)
end

function Raid:KeepRaidAfterPeerClose()
    self.pendingRemoteRaidClose = nil
    self:CancelRaidCommunication()
    if self.AutoSaveActiveRaid then self:AutoSaveActiveRaid() end
    self.activeRaidLeader = nil
    self.db.raidReadOnly = true
    self.selectedPlayer = nil
    self.dragPlayer = nil
    if self.HideDragGhost then self:HideDragGhost() end
    if self.RefreshMechanicsHUD then self:RefreshMechanicsHUD() end
    if self.RefreshQuickActionBar then self:RefreshQuickActionBar() end
    if self.frame and self.frame:IsShown() and self.RefreshAll then
        self:RefreshAll()
    elseif self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
end

function Raid:CHAT_MSG_ADDON(_, prefix, message, _, sender)
    if prefix ~= PREFIX then return end
    local ownName = GetUnitName and GetUnitName("player", true)
        or UnitName("player")
    if SamePlayer(sender, ownName) then return end
    local fields = Fields(message)
    local raidSessionID
    local last = fields[#fields]
    if last and last:sub(1, 1) == "@" then
        raidSessionID = last:sub(2)
        fields[#fields] = nil
    end
    local kind = DecodeFields(fields)
    if not kind then return end
    if raidSessionID and raidSessionID:sub(1, 1) == "#" then
        local activeSessionID = self.db.activeRaidSessionID
        if activeSessionID
            and CompactSessionID(activeSessionID) == raidSessionID
        then
            raidSessionID = activeSessionID
        end
    end
    if RAID_DOCUMENT_KIND[kind] and fields[4] == "" then
        fields[4] = self.db.activeRaid or ""
    end
    local sequence = tonumber(fields[3]) or 0
    if kind == "HELLO" then
        self:RebuildPeerAuthorityCache()
        self.peerHelloSequences = self.peerHelloSequences or {}
        -- A handshake starts a fresh synchronization opportunity. Always
        -- invalidate recipient caches: a prior transmission may have been
        -- dropped or rejected, and an empty authoritative snapshot must still
        -- clear stale assignments and manual players on the peer.
        self:ClearSentSyncFingerprints(sender)
        self.peerHelloSequences[sender] = sequence
        self.compatiblePeers = self.compatiblePeers or {}
        -- A successful HELLO establishes the peer. Display versions and the
        -- legacy wire-header value are informational only.
        self.compatiblePeers[sender] = true
        self.compactSyncPeers = self.compactSyncPeers or {}
        if fields[6] == "C" then
            CachePeerFlag(self.compactSyncPeers, sender)
        else
            self.compactSyncPeers[PlayerKey(sender)] = nil
            self.compactSyncPeers[PlayerName(sender):lower()] = nil
        end
        self.peerSequences = self.peerSequences or {}
        self.peerSequences[sender] = 0
        self.profileSequences = self.profileSequences or {}
        self.profileSequences[sender] = 0
        local snapshotAuthority = self.db.raidLocked
            and self:IsLocalRaidEditor()
            and (not self:IsInLiveRaid()
                or self:IsLocalRaidSessionOwner())
        if fields[5] ~= "R" then
            self:QueueSync("HELLO", {
                self.syncVersion or self.version or "unknown", "R", "C",
            }, "WHISPER", sender, "ALERT")
            if snapshotAuthority then
                self:BroadcastSelection(sender, "ALERT")
                self:SendRaidPlanSnapshots(sender)
            end
            if self.BroadcastCharacterProfile then
                self:BroadcastCharacterProfile(sender)
            end
            self:BroadcastOwnGear(sender)
        end
        return
    end
    -- Session-aware calls retain their stale-session protection. Calls from
    -- older clients without a session suffix continue through the legacy
    -- authority and sequence checks below.
    local offeredClose = kind == "CLOSE" and self.availableLeaderRaid
        and SamePlayer(self.availableLeaderRaid.sender, sender)
        and self.availableLeaderRaid.raidSessionID == raidSessionID
    if raidSessionID and kind ~= "SELECT" and kind ~= "COOLDOWN"
        and not offeredClose and not self:IsRaidSyncActive()
    then
        return
    end
    if raidSessionID and kind ~= "SELECT" and kind ~= "COOLDOWN"
        and not offeredClose
        and raidSessionID ~= self.db.activeRaidSessionID
    then
        return
    end
    -- A session is one shared raid document. Never apply an otherwise valid
    -- editor call to a different locally selected raid.
    if raidSessionID and RAID_DOCUMENT_KIND[kind]
        and fields[4] and self.db.activeRaid
        and fields[4] ~= self.db.activeRaid
    then
        return
    end
    if kind == "GEAR_BEGIN" then
        self.peerGearSnapshots = self.peerGearSnapshots or {}
        self.peerGearSnapshots[PlayerKey(sender)] = {}
        return
    elseif kind == "GEAR" then
        self.peerGearSnapshots = self.peerGearSnapshots or {}
        local snapshot = self.peerGearSnapshots[PlayerKey(sender)]
        if snapshot then
            for index = 4, #fields, 2 do
                local slotID = tonumber(fields[index])
                local link = fields[index + 1]
                if slotID and link and link ~= "" then
                    snapshot[slotID] = link
                end
            end
        end
        return
    elseif kind == "GEAR_END" then
        local senderKey = PlayerKey(sender)
        local snapshot = self.peerGearSnapshots
            and self.peerGearSnapshots[senderKey]
        if snapshot and self.StorePeerGearSnapshot then
            self:StorePeerGearSnapshot(sender, snapshot)
        end
        if self.peerGearSnapshots then
            self.peerGearSnapshots[senderKey] = nil
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
    if not self:IsAuthorizedPeer(sender) then return end
    self.peerSequences = self.peerSequences or {}
    local receivingFullSnapshot = self.receivingFullSnapshots
        and self.receivingFullSnapshots[sender]
        and raidSessionID == self.db.activeRaidSessionID
    local startingFullSnapshot = kind == "FULL_BEGIN"
        and raidSessionID == self.db.activeRaidSessionID
        and (not self.activeRaidLeader
            or SamePlayer(sender, self.activeRaidLeader))
    -- The throttle may interleave a later raid heartbeat with a whispered full
    -- snapshot. Do not let that unrelated higher sequence discard FULL_BEGIN
    -- or the rest of an active snapshot; the session and FULL framing guard it.
    if not receivingFullSnapshot and not startingFullSnapshot
        and sequence <= (self.peerSequences[sender] or 0)
    then
        return
    end
    self.peerSequences[sender] = math.max(
        self.peerSequences[sender] or 0, sequence)
    if kind == "SELECT" then
        if raidSessionID and raidSessionID ~= "" then
            if self:CanUseRaidControls() and not self.manuallyLeftSharedRaid then
                self.availableLeaderRaid = nil
                self:ApplyPeerSelection(
                    fields[4], tonumber(fields[5]), true,
                    sender, raidSessionID)
            else
                self:OfferLeaderRaid(
                    sender, fields[4], tonumber(fields[5]), raidSessionID)
            end
        else
            self:ApplyPeerSelection(
                fields[4], tonumber(fields[5]), true, sender)
        end
        return
    end
    if (kind == "SIM_BEGIN" or kind == "SIM_PLAYER"
        or kind == "SIMBATCH" or kind == "SIM_END"
        or kind == "FULL_BEGIN" or kind == "FULL_END")
        and self.activeRaidLeader
        and not SamePlayer(sender, self.activeRaidLeader)
    then
        return
    end
    local offer = self.availableLeaderRaid
    if offer and SamePlayer(offer.sender, sender) then
        if kind == "CLOSE" then
            self.availableLeaderRaid = nil
            if self.RefreshLeaderRaidToast then
                self:RefreshLeaderRaidToast()
            end
            if self.RefreshFooterLayout then self:RefreshFooterLayout() end
        end
        return
    end
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
    if kind ~= "FULL_BEGIN" and kind ~= "FULL_END"
        and self.receivingFullSnapshots
        and self.receivingFullSnapshots[sender]
    then
        self.fullSnapshotLastActivity = self.fullSnapshotLastActivity or {}
        self.fullSnapshotLastActivity[sender] =
            GetTime and GetTime() or 0
        if self.AdvanceRaidSyncProgress then
            self:AdvanceRaidSyncProgress()
        end
    end
    if kind == "MANUAL" then
        local raidKey, name = fields[4], fields[5]
        local applyingSnapshot = self.receivingSnapshots
            and self.receivingSnapshots[sender]
        local applyingTransaction = self.receivingRaidTransactions
            and self.receivingRaidTransactions[sender]
        local deferFinalize = applyingSnapshot or applyingTransaction
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
            if not deferFinalize then self:UpdateRoster() end
        end
        if applyingTransaction then
            self.pendingRaidRosterTransactions =
                self.pendingRaidRosterTransactions or {}
            self.pendingRaidRosterTransactions[sender] = raidKey
        end
        self:RelayRaidMutation(kind, fields)
        if not deferFinalize and self.AutoSaveActiveRaid then
            self:AutoSaveActiveRaid()
        end
        return
    elseif kind == "MANUALBATCH" then
        local raidKey = fields[4]
        local applyingSnapshot = self.receivingSnapshots
            and self.receivingSnapshots[sender]
        local applyingTransaction = self.receivingRaidTransactions
            and self.receivingRaidTransactions[sender]
        local deferFinalize = applyingSnapshot or applyingTransaction
        if self.raidByKey[raidKey] then
            self.db.manualPlayers[raidKey] =
                self.db.manualPlayers[raidKey] or {}
            for index = 5, #fields, 5 do
                local name = fields[index]
                if name and name ~= "" then
                    local class = fields[index + 1]
                    local role = fields[index + 2]
                    self.db.manualPlayers[raidKey][name:lower()] = {
                        name = name,
                        class = class,
                        className = LOCALIZED_CLASS_NAMES_MALE
                            and LOCALIZED_CLASS_NAMES_MALE[class] or class,
                        role = role,
                        reportedRole = role,
                        spec = fields[index + 3] or "",
                        race = "Planned",
                        subgroup = tonumber(fields[index + 4]) or 1,
                        manual = true,
                    }
                end
            end
            if not deferFinalize then self:UpdateRoster() end
        end
        if applyingTransaction then
            self.pendingRaidRosterTransactions =
                self.pendingRaidRosterTransactions or {}
            self.pendingRaidRosterTransactions[sender] = raidKey
        end
        self:RelayRaidMutation(kind, fields)
        if not deferFinalize and self.AutoSaveActiveRaid then
            self:AutoSaveActiveRaid()
        end
        return
    elseif kind == "MANUALDEL" then
        local raidKey, name = fields[4], fields[5]
        local applyingSnapshot = self.receivingSnapshots
            and self.receivingSnapshots[sender]
        local applyingTransaction = self.receivingRaidTransactions
            and self.receivingRaidTransactions[sender]
        local deferFinalize = applyingSnapshot or applyingTransaction
        if name and self.db.manualPlayers[raidKey] then
            self.db.manualPlayers[raidKey][name:lower()] = nil
            if not deferFinalize then self:UpdateRoster() end
        end
        if applyingTransaction then
            self.pendingRaidRosterTransactions =
                self.pendingRaidRosterTransactions or {}
            self.pendingRaidRosterTransactions[sender] = raidKey
        end
        self:RelayRaidMutation(kind, fields)
        if not deferFinalize and self.AutoSaveActiveRaid then
            self:AutoSaveActiveRaid()
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
    if kind == "TX_BEGIN" then
        self.raidTransactionTokens = self.raidTransactionTokens or {}
        local token = (self.raidTransactionTokens[sender] or 0) + 1
        self.raidTransactionTokens[sender] = token
        self.receivingRaidTransactions =
            self.receivingRaidTransactions or {}
        local state = self.receivingRaidTransactions[sender]
            or { depth = 0 }
        state.depth = (state.depth or 0) + 1
        state.token = token
        self.receivingRaidTransactions[sender] = state
        if C_Timer and C_Timer.After then
            C_Timer.After(15, function()
                if not Raid.receivingRaidTransactions
                    or not Raid.receivingRaidTransactions[sender]
                    or Raid.receivingRaidTransactions[sender].token ~= token
                then
                    return
                end
                Raid.receivingRaidTransactions[sender] = nil
                local pendingRaid = Raid.pendingRaidConfigurationTransactions
                    and Raid.pendingRaidConfigurationTransactions[sender]
                if Raid.pendingRaidConfigurationTransactions then
                    Raid.pendingRaidConfigurationTransactions[sender] = nil
                end
                local pendingRoster = Raid.pendingRaidRosterTransactions
                    and Raid.pendingRaidRosterTransactions[sender]
                if Raid.pendingRaidRosterTransactions then
                    Raid.pendingRaidRosterTransactions[sender] = nil
                end
                if pendingRaid and Raid.PersistRaidConfiguration then
                    Raid:PersistRaidConfiguration(pendingRaid)
                end
                if pendingRoster then Raid:UpdateRoster(true) end
                Raid:FinalizeReceivedRaidMutation()
            end)
        end
    elseif kind == "TX_END" then
        local state = self.receivingRaidTransactions
            and self.receivingRaidTransactions[sender]
        if state and (state.depth or 1) > 1 then
            state.depth = state.depth - 1
        else
            if self.receivingRaidTransactions then
                self.receivingRaidTransactions[sender] = nil
            end
            if self.raidTransactionTokens then
                self.raidTransactionTokens[sender] =
                    (self.raidTransactionTokens[sender] or 0) + 1
            end
            local pendingRaid = self.pendingRaidConfigurationTransactions
                and self.pendingRaidConfigurationTransactions[sender]
            if self.pendingRaidConfigurationTransactions then
                self.pendingRaidConfigurationTransactions[sender] = nil
            end
            local pendingRoster = self.pendingRaidRosterTransactions
                and self.pendingRaidRosterTransactions[sender]
            if self.pendingRaidRosterTransactions then
                self.pendingRaidRosterTransactions[sender] = nil
            end
            if pendingRaid and self.PersistRaidConfiguration then
                self:PersistRaidConfiguration(pendingRaid)
            end
            if pendingRoster then self:UpdateRoster(true) end
        end
    elseif kind == "CURRENT" then
        local raid = self.raidByKey[raidKey]
        if raid and encounterIndex and encounterIndex >= 2
            and encounterIndex <= #raid.encounters
        then
            self.db.currentBossByRaid =
                self.db.currentBossByRaid or {}
            self.db.currentBossByRaid[raidKey] = encounterIndex
        end
    elseif kind == "SIM_BEGIN" then
        self.receivingSimulation = sender
        self.pendingRemoteSimulationRoster = {}
        self.simulationReceiveTokens = self.simulationReceiveTokens or {}
        local token = (self.simulationReceiveTokens[sender] or 0) + 1
        self.simulationReceiveTokens[sender] = token
        if C_Timer and C_Timer.After then
            C_Timer.After(8, function()
                if Raid.receivingSimulation ~= sender
                    or not Raid.simulationReceiveTokens
                    or Raid.simulationReceiveTokens[sender] ~= token
                then
                    return
                end
                Raid.pendingRemoteSimulationRoster = nil
                Raid.receivingSimulation = nil
                Raid:FinalizeReceivedRaidMutation()
                if not Raid:IsLocalRaidSessionOwner()
                    and Raid.RequestPeerSync
                then
                    Raid:RequestPeerSync()
                end
            end)
        end
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
                spec = fields[10] or "",
                simulated = true,
            }
        end
    elseif kind == "SIMBATCH" then
        if self.receivingSimulation == sender then
            for index = 5, #fields, 6 do
                local name = fields[index]
                if name and name ~= "" then
                    self.pendingRemoteSimulationRoster[
                        #self.pendingRemoteSimulationRoster + 1] = {
                        name = name,
                        class = fields[index + 1],
                        className = LOCALIZED_CLASS_NAMES_MALE
                            and LOCALIZED_CLASS_NAMES_MALE[fields[index + 1]]
                            or fields[index + 1],
                        role = fields[index + 2],
                        reportedRole = fields[index + 2],
                        race = fields[index + 3] ~= ""
                            and fields[index + 3] or "Simulated",
                        subgroup = tonumber(fields[index + 4]) or 1,
                        spec = fields[index + 5] or "",
                        simulated = true,
                    }
                end
            end
        end
    elseif kind == "SIM_END" then
        if self.receivingSimulation == sender then
            self.remoteSimulationRoster =
                self.pendingRemoteSimulationRoster or {}
            self.pendingRemoteSimulationRoster = nil
            self.receivingSimulation = nil
            if self.simulationReceiveTokens then
                self.simulationReceiveTokens[sender] =
                    (self.simulationReceiveTokens[sender] or 0) + 1
            end
            local applyingSnapshot = self.receivingSnapshots
                and self.receivingSnapshots[sender]
            if not applyingSnapshot then self:UpdateRoster() end
        end
    elseif kind == "GROUP" then
        local changed = false
        for index = 5, #fields, 2 do
            local name, subgroup = fields[index], tonumber(fields[index + 1])
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
                changed = true
            end
        end
        if changed then self:UpdateRoster(true) end
    elseif kind == "CLOSE" then
        self.receivingSync = false
        if self:IsGroupAssistant() and StaticPopup_Show then
            self.pendingRemoteRaidClose = {
                sender = sender,
                raidKey = raidKey,
                raidSessionID = raidSessionID,
            }
            StaticPopup_Show(
                "LUNARAIDS_REMOTE_CLOSE_RAID", PlayerName(sender))
        else
            self:CloseRaidFromPeer()
        end
        return
    elseif kind == "FULL_BEGIN" then
        local raid = self.raidByKey[raidKey]
        if raid then
            self:BeginFullSyncReadOnly(sender, raidKey, raidSessionID)
            if self.BeginRaidSyncProgress then
                self:BeginRaidSyncProgress(tonumber(fields[5]), raid.name)
            end
            self.fullSnapshotTokens = self.fullSnapshotTokens or {}
            local fullToken = (self.fullSnapshotTokens[sender] or 0) + 1
            self.fullSnapshotTokens[sender] = fullToken
            self.receivingFullSnapshots = self.receivingFullSnapshots or {}
            self.receivingFullSnapshots[sender] = raidKey
            self.fullSnapshotNames = self.fullSnapshotNames or {}
            self.fullSnapshotNames[sender] = {}
            self.fullSnapshotLastActivity =
                self.fullSnapshotLastActivity or {}
            self.fullSnapshotLastActivity[sender] =
                GetTime and GetTime() or 0
            self.receivingSnapshots = self.receivingSnapshots or {}
            self.receivingSnapshots[sender] = true
            self.receivingRaidTransactions = nil
            self.raidTransactionTokens = nil
            self.pendingRaidConfigurationTransactions = nil
            self.pendingRaidRosterTransactions = nil
            local plans = self.simulation.enabled
                and self.simulation.plans or self.db.plans
            plans[raidKey] = {}
            self.db.bossOverrides[raidKey] = {}
            self.db.bossPresets[raidKey] = {}
            self.db.manualPlayers[raidKey] = {}
            local tanks = tonumber(fields[6])
            local healers = tonumber(fields[7])
            if tanks or healers then
                self.db.raidCompositions[raidKey] =
                    self.db.raidCompositions[raidKey] or {}
                local composition = self.db.raidCompositions[raidKey]
                if tanks then composition.tanks = tanks end
                if healers then composition.healers = healers end
                self:ApplyRaidComposition(raid)
            end
            local currentBoss = tonumber(fields[8])
            if currentBoss and currentBoss >= 2
                and currentBoss <= #raid.encounters
            then
                self.db.currentBossByRaid = self.db.currentBossByRaid or {}
                self.db.currentBossByRaid[raidKey] = currentBoss
            end
            self.remoteSimulationRoster = nil
            self.pendingRemoteSimulationRoster = {}
            self.receivingSimulation = sender
            if C_Timer and C_Timer.After then
                local function CheckFullSnapshotTimeout()
                    if not Raid.receivingFullSnapshots
                        or not Raid.receivingFullSnapshots[sender]
                        or not Raid.fullSnapshotTokens
                        or Raid.fullSnapshotTokens[sender] ~= fullToken
                    then
                        return
                    end
                    local now = GetTime and GetTime() or 0
                    local lastActivity = Raid.fullSnapshotLastActivity
                        and Raid.fullSnapshotLastActivity[sender] or 0
                    local idle = now > 0 and lastActivity > 0
                        and now - lastActivity or 20
                    if idle < 20 then
                        C_Timer.After(
                            math.max(.25, 20 - idle),
                            CheckFullSnapshotTimeout)
                        return
                    end
                    Raid.receivingFullSnapshots[sender] = nil
                    if Raid.fullSnapshotNames then
                        Raid.fullSnapshotNames[sender] = nil
                    end
                    if Raid.fullSnapshotLastActivity then
                        Raid.fullSnapshotLastActivity[sender] = nil
                    end
                    if Raid.receivingSnapshots then
                        Raid.receivingSnapshots[sender] = nil
                    end
                    if Raid.receivingSimulation == sender then
                        Raid.pendingRemoteSimulationRoster = nil
                        Raid.receivingSimulation = nil
                    end
                    if Raid.BeginRaidSyncProgress then
                        Raid:BeginRaidSyncProgress(nil, raid.name)
                    end
                    if not Raid:IsLocalRaidSessionOwner()
                        and Raid.RequestPeerSync
                    then
                        Raid:RequestPeerSync()
                    end
                end
                C_Timer.After(20, CheckFullSnapshotTimeout)
            end
        end
    elseif kind == "FULL_END" then
        -- Finalized after receivingSync is released below.
    elseif kind == "SNAP_BEGIN" then
        local snapshotRaid = self.raidByKey[raidKey]
        if snapshotRaid and self.BeginRaidSyncProgress
            and not (self.receivingFullSnapshots
                and self.receivingFullSnapshots[sender])
        then
            self:BeginRaidSyncProgress(nil, snapshotRaid.name)
        end
        self.snapshotFinalizeGeneration =
            (self.snapshotFinalizeGeneration or 0) + 1
        self.snapshotReceiveTokens = self.snapshotReceiveTokens or {}
        local receiveToken =
            (self.snapshotReceiveTokens[sender] or 0) + 1
        self.snapshotReceiveTokens[sender] = receiveToken
        self.receivingSnapshots = self.receivingSnapshots or {}
        self.receivingSnapshots[sender] = true
        if C_Timer and C_Timer.After then
            C_Timer.After(15, function()
                if not Raid.receivingSnapshots
                    or not Raid.receivingSnapshots[sender]
                    or Raid.receivingFullSnapshots
                        and Raid.receivingFullSnapshots[sender]
                    or not Raid.snapshotReceiveTokens
                    or Raid.snapshotReceiveTokens[sender] ~= receiveToken
                then
                    return
                end
                Raid.receivingSnapshots[sender] = nil
                Raid.snapshotFinalizeGeneration =
                    (Raid.snapshotFinalizeGeneration or 0) + 1
                if Raid.CancelRaidSyncProgress then
                    Raid:CancelRaidSyncProgress()
                end
                Raid:FinalizeReceivedSnapshot()
                if not Raid:IsLocalRaidSessionOwner()
                    and Raid.RequestPeerSync
                then
                    Raid:RequestPeerSync()
                end
            end)
        end
        if self:IsPeerLeader(sender) and (
            not self.db.raidLocked or self.db.activeRaid ~= raidKey)
        then
            self:ApplyPeerSelection(raidKey, encounterIndex)
        end
        local plans = self.simulation.enabled
            and self.simulation.plans or self.db.plans
        plans[raidKey] = plans[raidKey] or {}
        plans[raidKey][encounterIndex] = {}
        if encounterIndex == 1 then
            self.db.manualPlayers[raidKey] = {}
        end
        if self.db.bossOverrides[raidKey] then
            self.db.bossOverrides[raidKey][encounterIndex] = nil
        end
    elseif kind == "NAMES" then
        if self.receivingFullSnapshots
            and self.receivingFullSnapshots[sender]
        then
            self.fullSnapshotNames = self.fullSnapshotNames or {}
            local dictionary = self.fullSnapshotNames[sender] or {}
            self.fullSnapshotNames[sender] = dictionary
            local dictionaryIndex = tonumber(fields[5]) or 1
            for index = 6, #fields, 2 do
                local name = fields[index]
                if name and name ~= "" then
                    dictionary[dictionaryIndex] = {
                        name = name,
                        class = fields[index + 1] or "",
                    }
                end
                dictionaryIndex = dictionaryIndex + 1
            end
        end
    elseif kind == "PLANRESET" then
        local raid = self.raidByKey[raidKey]
        if raid and raid.encounters[encounterIndex] then
            local plans = self.simulation.enabled
                and self.simulation.plans or self.db.plans
            plans[raidKey] = plans[raidKey] or {}
            plans[raidKey][encounterIndex] = {}
        end
    elseif kind == "PLANBATCH" then
        local raid = self.raidByKey[raidKey]
        if raid and raid.encounters[encounterIndex] then
            local plans = self.simulation.enabled
                and self.simulation.plans or self.db.plans
            plans[raidKey] = plans[raidKey] or {}
            plans[raidKey][encounterIndex] =
                plans[raidKey][encounterIndex] or {}
            local plan = plans[raidKey][encounterIndex]
            local snapshot = self.receivingSnapshots
                and self.receivingSnapshots[sender]
            local validateRoster = self:IsLocalRaidSessionOwner()
                and not snapshot
                and self:IsCurrentRosterAuthoritative()
            local rosterNames
            if validateRoster then
                rosterNames = {}
                for _, player in ipairs(self.roster or {}) do
                    CachePeerFlag(rosterNames, player.name)
                end
            end
            -- Rebuild the packet as we apply it. When an assistant submits a
            -- batch, this lets the session owner discard stale players before
            -- relaying the authoritative result to the rest of the raid.
            local accepted = {
                fields[1], fields[2], fields[3], fields[4], fields[5],
            }
            for index = 6, #fields, 3 do
                local key, name, class =
                    fields[index], fields[index + 1], fields[index + 2]
                local reference = name and name:match("^~([0-9a-z]+)$")
                if reference then
                    local dictionary = self.fullSnapshotNames
                        and self.fullSnapshotNames[sender]
                    local entry = dictionary
                        and dictionary[FromBase36(reference)]
                    name = entry and entry.name or nil
                    class = entry and entry.class or ""
                end
                if key and name and name ~= "" and (
                    not validateRoster
                    or HasPeerFlag(rosterNames, name))
                then
                    plan[key] = { name = name, class = class or "" }
                    accepted[#accepted + 1] = key
                    accepted[#accepted + 1] = name
                    accepted[#accepted + 1] = class or ""
                end
            end
            fields = accepted
        end
    elseif kind == "VALUE" and #fields > 7 then
        local raid = self.raidByKey[raidKey]
        if raid and raid.encounters[encounterIndex] then
            local plans = self.simulation.enabled
                and self.simulation.plans or self.db.plans
            plans[raidKey] = plans[raidKey] or {}
            plans[raidKey][encounterIndex] =
                plans[raidKey][encounterIndex] or {}
            local plan = plans[raidKey][encounterIndex]
            for index = 6, #fields, 2 do
                local key, value = fields[index], fields[index + 1]
                if key and value ~= nil then
                    plan[key] = DecodePlanScalar(value)
                end
            end
        end
    elseif kind == "CLEAR" and #fields > 6 then
        local raid = self.raidByKey[raidKey]
        if raid and raid.encounters[encounterIndex] then
            local plans = self.simulation.enabled
                and self.simulation.plans or self.db.plans
            plans[raidKey] = plans[raidKey] or {}
            plans[raidKey][encounterIndex] =
                plans[raidKey][encounterIndex] or {}
            local plan = plans[raidKey][encounterIndex]
            for index = 6, #fields do
                if fields[index] and fields[index] ~= "" then
                    plan[fields[index]] = nil
                end
            end
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
            local snapshot = self.receivingSnapshots
                and self.receivingSnapshots[sender]
            if kind == "PLAN" and self:IsLocalRaidSessionOwner()
                and not snapshot
                and self:IsCurrentRosterAuthoritative()
                and not self:IsCurrentRaidPlayerName(fields[7])
            then
                kind = "CLEAR"
            end
            if kind == "PLAN" and (not fields[7] or fields[7] == "") then
                kind = "CLEAR"
            end
            if kind == "PLAN" then
                plan[key] = { name = fields[7], class = fields[8] }
            elseif kind == "CLEAR" then
                plan[key] = nil
            else
                plan[key] = DecodePlanScalar(fields[7])
            end
            if not snapshot and (kind == "PLAN" or kind == "CLEAR")
                and key and key:match("^S:")
            then
                local editor = PlayerName(sender)
                local label = AssignmentLabel(
                    raid, encounterIndex, key)
                if kind == "PLAN" and fields[7] and fields[7] ~= "" then
                    self:Print(self:Localize("PLAYER_ASSIGNED",
                        editor, PlayerName(fields[7]), label))
                elseif kind == "CLEAR" and previous and previous.name then
                    self:Print(self:Localize("PLAYER_REMOVED",
                        editor, PlayerName(previous.name), label))
                end
            end
        end
    elseif kind == "COMP" then
        local raid = self.raidByKey[raidKey]
        if raid then
            self.db.raidCompositions[raidKey] =
                self.db.raidCompositions[raidKey] or {}
            for index = 5, #fields, 2 do
                local role, value = fields[index], tonumber(fields[index + 1])
                if value and (role == "tanks" or role == "healers") then
                    self.db.raidCompositions[raidKey][role] = value
                end
            end
            self:ApplyRaidComposition(raid)
        end
    elseif kind == "BOSSSET" then
        local raid = self.raidByKey[raidKey]
        if raid and raid.encounters[encounterIndex] then
            self.db.bossOverrides[raidKey] =
                self.db.bossOverrides[raidKey] or {}
            local override =
                self.db.bossOverrides[raidKey][encounterIndex]
                or { groups = {} }
            override.groups = override.groups or {}
            self.db.bossOverrides[raidKey][encounterIndex] = override
            for index = 6, #fields, 2 do
                local key, value = fields[index], tonumber(fields[index + 1])
                if key and value then
                    if key == "HEALERS" then
                        override.healers = value
                    else
                        local groupIndex = tonumber(key:match("^G:(%d+)$"))
                        if groupIndex then override.groups[groupIndex] = value end
                    end
                end
            end
        end
    elseif kind == "BOSSCUSTOM" then
        local raid = self.raidByKey[raidKey]
        if raid and raid.encounters[encounterIndex] then
            self.db.bossOverrides[raidKey] =
                self.db.bossOverrides[raidKey] or {}
            local override = self.db.bossOverrides[raidKey][encounterIndex]
                or { groups = {} }
            override.groups = override.groups or {}
            override.customGroups = override.customGroups or {}
            self.db.bossOverrides[raidKey][encounterIndex] = override
            local customIndices = {}
            for index, custom in ipairs(override.customGroups) do
                if custom.id then customIndices[custom.id] = index end
            end
            local baseGroupCount = #raid.encounters[encounterIndex].groups
            for index = 6, #fields, 3 do
                local id, name = fields[index], fields[index + 1]
                local count = tonumber(fields[index + 2]) or 1
                if id and id ~= "" and name and name ~= "" then
                    local customIndex = customIndices[id]
                    if customIndex then
                        local custom = override.customGroups[customIndex]
                        custom.name, custom.count = name, count
                    else
                        customIndex = #override.customGroups + 1
                        override.customGroups[customIndex] = {
                            id = id, name = name, count = count,
                        }
                        customIndices[id] = customIndex
                    end
                    override.groups[baseGroupCount + customIndex] = count
                end
            end
        end
    elseif kind == "BOSSCUSTOMDEL" then
        local override = self.db.bossOverrides[raidKey]
            and self.db.bossOverrides[raidKey][encounterIndex]
        if override and override.customGroups then
            for index, custom in ipairs(override.customGroups) do
                if custom.id == fields[6] then
                    local groupIndex = #self.raidByKey[raidKey]
                        .encounters[encounterIndex].groups + index
                    table.remove(override.customGroups, index)
                    local rebuilt = {}
                    for oldIndex, value in pairs(override.groups or {}) do
                        if oldIndex < groupIndex then rebuilt[oldIndex] = value
                        elseif oldIndex > groupIndex then
                            rebuilt[oldIndex - 1] = value
                        end
                    end
                    override.groups = rebuilt
                    break
                end
            end
        end
    elseif kind == "BOSSRESET" then
        if self.db.bossOverrides[raidKey] then
            self.db.bossOverrides[raidKey][encounterIndex] = nil
        end
    elseif kind == "PRESETRESET" then
        local raid, presetID = self.raidByKey[raidKey], fields[6]
        if raid and raid.encounters[encounterIndex]
            and presetID and presetID ~= ""
        then
            self.db.bossPresets[raidKey] =
                self.db.bossPresets[raidKey] or {}
            local collection = self.db.bossPresets[raidKey][encounterIndex]
            if type(collection) ~= "table" or type(collection.items) ~= "table" then
                collection = { items = {} }
                self.db.bossPresets[raidKey][encounterIndex] = collection
            end
            collection.items[presetID] = {
                id = presetID, name = fields[7] or "",
                savedAt = tonumber(fields[8]) or 0,
                settings = { groups = {}, customGroups = {} },
            }
            if fields[9] == "1" then collection.selected = presetID end
        end
    elseif kind == "PRESETSET" then
        local collection = self.db.bossPresets[raidKey]
            and self.db.bossPresets[raidKey][encounterIndex]
        local preset = collection and collection.items
            and collection.items[fields[6]]
        if preset then
            for index = 7, #fields, 2 do
                local key, value = fields[index], tonumber(fields[index + 1])
                if key and value then
                    if key == "HEALERS" then
                        preset.settings.healers = value
                    else
                        local groupIndex = tonumber(key:match("^G:(%d+)$"))
                        if groupIndex then
                            preset.settings.groups[groupIndex] = value
                        end
                    end
                end
            end
        end
    elseif kind == "PRESETCUSTOM" then
        local collection = self.db.bossPresets[raidKey]
            and self.db.bossPresets[raidKey][encounterIndex]
        local preset = collection and collection.items
            and collection.items[fields[6]]
        if preset then
            local customGroups = preset.settings.customGroups
            for index = 7, #fields, 3 do
                local id, name = fields[index], fields[index + 1]
                local count = tonumber(fields[index + 2]) or 1
                if id and id ~= "" and name and name ~= "" then
                    customGroups[#customGroups + 1] = {
                        id = id, name = name, count = count,
                    }
                end
            end
        end
    elseif kind == "PRESETCLEAR" then
        local presets = self.db.bossPresets[raidKey]
        local collection = presets and presets[encounterIndex]
        local presetID = fields[6]
        if presetID == "*" then
            if presets then presets[encounterIndex] = nil end
        elseif collection and collection.items then
            collection.items[presetID] = nil
            if collection.selected == presetID then collection.selected = nil end
        end
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
    local configurationMutation = kind == "BOSSSET" or kind == "BOSSRESET"
        or kind == "BOSSCUSTOM" or kind == "BOSSCUSTOMDEL"
        or kind == "PRESETSET" or kind == "PRESETRESET"
        or kind == "PRESETCLEAR" or kind == "PRESETCUSTOM"
    if configurationMutation and self.PersistRaidConfiguration then
        if self.receivingRaidTransactions
            and self.receivingRaidTransactions[sender]
        then
            self.pendingRaidConfigurationTransactions =
                self.pendingRaidConfigurationTransactions or {}
            self.pendingRaidConfigurationTransactions[sender] = raidKey
        elseif not (self.receivingSnapshots
            and self.receivingSnapshots[sender])
        then
            self:PersistRaidConfiguration(raidKey)
        end
    end
    self.receivingSync = false
    self:RelayRaidMutation(kind, fields)
    if kind == "SNAP_END" then
        if self.receivingFullSnapshots
            and self.receivingFullSnapshots[sender]
        then
            return
        end
        if self.receivingSnapshots then
            self.receivingSnapshots[sender] = nil
        end
        if self.snapshotReceiveTokens then
            self.snapshotReceiveTokens[sender] =
                (self.snapshotReceiveTokens[sender] or 0) + 1
        end
        if self.PersistRaidConfiguration then
            self:PersistRaidConfiguration(raidKey)
        end
        self.snapshotFinalizeGeneration =
            (self.snapshotFinalizeGeneration or 0) + 1
        local generation = self.snapshotFinalizeGeneration
        local function FinalizeSnapshot()
            if generation ~= Raid.snapshotFinalizeGeneration then return end
            Raid:FinalizeReceivedSnapshot()
        end
        if C_Timer and C_Timer.After then
            C_Timer.After(.25, FinalizeSnapshot)
        else
            FinalizeSnapshot()
        end
        if self.CompleteRaidSyncProgress then
            self:CompleteRaidSyncProgress()
        end
        return
    end
    if kind == "FULL_END" then
        if self.fullSnapshotNames then
            self.fullSnapshotNames[sender] = nil
        end
        if self.receivingSimulation == sender then
            local simulatedRoster = self.pendingRemoteSimulationRoster or {}
            self.remoteSimulationRoster = #simulatedRoster > 0
                and simulatedRoster or nil
            self.pendingRemoteSimulationRoster = nil
            self.receivingSimulation = nil
            if self.simulationReceiveTokens then
                self.simulationReceiveTokens[sender] =
                    (self.simulationReceiveTokens[sender] or 0) + 1
            end
        end
        if self.fullSnapshotTokens then
            self.fullSnapshotTokens[sender] =
                (self.fullSnapshotTokens[sender] or 0) + 1
        end
        if self.receivingFullSnapshots then
            self.receivingFullSnapshots[sender] = nil
        end
        if self.fullSnapshotLastActivity then
            self.fullSnapshotLastActivity[sender] = nil
        end
        if self.receivingSnapshots then
            self.receivingSnapshots[sender] = nil
        end
        self:EndFullSyncReadOnly(sender)
        if self.snapshotReceiveTokens then
            self.snapshotReceiveTokens[sender] =
                (self.snapshotReceiveTokens[sender] or 0) + 1
        end
        if self.PersistRaidConfiguration then
            self:PersistRaidConfiguration(raidKey)
        end
        self.snapshotFinalizeGeneration =
            (self.snapshotFinalizeGeneration or 0) + 1
        self:FinalizeReceivedSnapshot()
        if self.CompleteRaidSyncProgress then
            self:CompleteRaidSyncProgress()
        end
        return
    end
    self:FinalizeReceivedRaidMutation()
end

function Raid:HandleGroupRosterUpdate()
    if self.rosterUpdatePending then return end
    self.rosterUpdatePending = true
    local function Refresh()
        Raid.rosterUpdatePending = nil
        Raid:RebuildPeerAuthorityCache()
        local inGroup = Raid:IsInLiveGroup()
        local leftGroup = Raid.communicationWasInGroup == true
            and not inGroup
        local joinedGroup = inGroup
            and Raid.communicationWasInGroup == false
        local joinedWithActiveRaid = joinedGroup
            and Raid.db.raidLocked
            and not Raid.db.raidReadOnly
        local isAssistant = Raid:IsGroupAssistant()
        local isLeader = UnitIsGroupLeader
            and UnitIsGroupLeader("player") or false
        local becameAssistant = inGroup and isAssistant and not isLeader
            and Raid.communicationWasAssistant == false
        Raid.communicationWasInGroup = inGroup
        Raid.communicationWasAssistant = isAssistant
        Raid:PruneDepartedSyncTargets()
        if Raid.availableLeaderRaid
            and not Raid:IsAuthorizedPeer(Raid.availableLeaderRaid.sender)
        then
            Raid.availableLeaderRaid = nil
            if Raid.RefreshLeaderRaidToast then
                Raid:RefreshLeaderRaidToast()
            end
            if Raid.RefreshFooterLayout then Raid:RefreshFooterLayout() end
        end
        -- RefreshAll below redraws the visible roster.  Avoid doing that work
        -- twice for the same event burst (and skip hidden roster UI entirely).
        Raid:UpdateRoster(true)
        local rosterFingerprint = RosterStateFingerprint(Raid.roster)
        local rosterChanged = rosterFingerprint
            ~= Raid.lastCommunicationRosterFingerprint
        Raid.lastCommunicationRosterFingerprint = rosterFingerprint
        if rosterChanged and Raid:IsLocalRaidSessionOwner()
            and Raid.PruneAssignmentsToCurrentRoster
        then
            Raid:PruneAssignmentsToCurrentRoster(true)
        end
        if rosterChanged then Raid:AutoSaveActiveRaid() end
        if Raid.RefreshRaidCooldowns then
            Raid:RefreshRaidCooldowns()
        end
        if Raid.RefreshMechanicsHUD then Raid:RefreshMechanicsHUD() end
        if Raid.frame and Raid.frame:IsShown() and Raid.RefreshAll then
            Raid:RefreshAll()
        elseif Raid.RefreshPersonalAssignments then
            Raid:RefreshPersonalAssignments()
        end
        if Raid.RefreshQuickActionBar then
            Raid:RefreshQuickActionBar()
        end
        if Raid.ScheduleRaidAdministration then
            Raid:ScheduleRaidAdministration()
        elseif Raid.ApplyRaidAdministration then
            Raid:ApplyRaidAdministration()
        end
        if (joinedGroup or becameAssistant) and not joinedWithActiveRaid then
            Raid:RequestPeerSync()
        end
        if joinedWithActiveRaid and StaticPopup_Show then
            StaticPopup_Show("LUNARAIDS_JOINED_GROUP_CLOSE_RAID")
        end
        if leftGroup and Raid.db.raidLocked
            and not Raid.db.raidReadOnly
            and StaticPopup_Show
        then
            StaticPopup_Show("LUNARAIDS_LEFT_GROUP_CLOSE_RAID")
        end
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(.1, Refresh)
    else
        Refresh()
    end
end

function Raid:SendRaidPlanSnapshots(target, rosterReady, skipPrune)
    if not self:IsLocalRaidEditor()
        or not self:IsInLiveGroup() and not self.syncSimulationCapture
    then
        return
    end
    local raid = self:GetRaid()
    local snapshotKey
    if target then
        if not self.syncQueueFullSnapshotIndex then
            RebuildSyncQueueIndexes(self)
        end
        snapshotKey = FullSnapshotTargetKey(
            self.db.activeRaidSessionID, target)
        local now = GetTime and GetTime() or 0
        local lastQueued = self.fullSnapshotQueuedAt
            and self.fullSnapshotQueuedAt[snapshotKey]
        if not self.syncSimulationCapture and now > 0 and lastQueued
            and now - lastQueued < 10
        then
            return
        end
        local pendingIndex = snapshotKey
            and self.syncQueueFullSnapshotIndex[snapshotKey]
        local pending = pendingIndex and self.syncQueue[pendingIndex]
        if pending and pending.kind == "FULL_END"
            and pending.raidSessionID == self.db.activeRaidSessionID
            and SamePlayer(pending.target, target)
        then
            return
        elseif pendingIndex then
            self.syncQueueFullSnapshotIndex[snapshotKey] = nil
        end
    end
    -- Rebuild a live roster before validating assignments. A simulated roster
    -- is already authoritative; rebuilding it here would broadcast a duplicate
    -- roster before the targeted full snapshot.
    if not self:IsSimulating() and not rosterReady then self:UpdateRoster(true) end
    if not skipPrune then self:PruneAssignmentsToCurrentRoster(false) end
    local distribution = target and "WHISPER" or nil
    local priority = "ALERT"
    local compactFull = UsesCompactWire(self, target)
    local beginValues = { raid.key, 0 }
    if compactFull then
        local composition = self:GetRaidComposition(raid.key)
        beginValues[3] = composition.tanks
        beginValues[4] = composition.healers
        beginValues[5] = self:GetCurrentBossIndex(raid) or ""
    end
    local beginItem, beginFields = self:QueueSync(
        "FULL_BEGIN", beginValues, distribution, target, priority)
    local payloadQueueStart = self.syncQueueTail or 0
    -- FULL_BEGIN already clears the remote raid document atomically. Only send
    -- encounters that contain state; empty encounters need no per-boss reset
    -- or framing packets.
    local plans = self.simulation.enabled
        and self.simulation.plans or self.db.plans
    local raidPlans = plans[raid.key] or {}
    local snapshotNames, nameReferences
    if compactFull then
        snapshotNames, nameReferences = BuildSnapshotNameDictionary(
            raidPlans, #raid.encounters)
        QueueSnapshotNameDictionary(
            self, raid.key, snapshotNames, distribution, target, priority)
    end
    local overrides = self.db.bossOverrides[raid.key] or {}
    local presets = self.db.bossPresets[raid.key] or {}
    for encounterIndex = 1, #raid.encounters do
        local hasPlan = PlanHasSyncState(raidPlans[encounterIndex])
        local hasOverride = overrides[encounterIndex]
            and next(overrides[encounterIndex]) ~= nil
        local collection = presets[encounterIndex]
        local hasPresets = collection and collection.items
            and next(collection.items) ~= nil
        if encounterIndex == 1 or hasPlan or hasOverride or hasPresets then
            self:SendPlanSnapshot(
                target, encounterIndex, encounterIndex == 1, compactFull,
                nameReferences)
        end
    end
    if beginItem and beginFields then
        local payloadCount = math.max(
            0, (self.syncQueueTail or payloadQueueStart) - payloadQueueStart)
        beginFields[5] = tostring(payloadCount)
        beginItem.message = EncodeWireMessage(
            beginFields, beginItem.compactWire)
    end
    local endItem = self:QueueSync("FULL_END", {
        raid.key,
    }, distribution, target, priority)
    if endItem and snapshotKey and not self.syncSimulationCapture then
        self.fullSnapshotQueuedAt = self.fullSnapshotQueuedAt or {}
        self.fullSnapshotQueuedAt[snapshotKey] =
            GetTime and GetTime() or 0
    end
end

function Raid:RunSynchronizationSimulation()
    if self:IsReceivingRaidTransaction() then
        self:Print("Wait for the active synchronization to finish before testing.")
        return false
    end
    if not self.db.raidLocked or self:IsRaidReadOnly() then
        self:Print("Start or join an editable raid before running /lr syncsim.")
        return false
    end
    if not self:IsLocalRaidEditor() then
        self:Print("Only a raid leader or assistant can build a sync test.")
        return false
    end

    local originalQueue = self.syncQueue
    local originalHead = self.syncQueueHead
    local originalTail = self.syncQueueTail
    local originalCoalesceIndex = self.syncQueueCoalesceIndex
    local originalFullSnapshotIndex = self.syncQueueFullSnapshotIndex
    local originalNonBulkCount = self.syncQueueNonBulkCount
    local originalSequence = self.syncSequence
    local originalGeneration = self.assignmentCoalesceGeneration
    local originalSimulationFingerprints = self.sentSimulationFingerprints
    local frameWasShown = self.syncFrame and self.syncFrame:IsShown()

    self.syncQueue = {}
    self.syncQueueHead = 1
    self.syncQueueTail = 0
    self.syncQueueCoalesceIndex = {}
    self.syncQueueFullSnapshotIndex = {}
    self.syncQueueNonBulkCount = 0
    self.syncSimulationCapture = true
    self.sentSimulationFingerprints = {}
    local ok, failure = pcall(
        self.SendRaidPlanSnapshots, self,
        "LunaSyncSimulation", true, true)
    local captured = {}
    local queueInvariantErrors = {}
    local expectedNonBulkCount = 0
    for index = self.syncQueueHead or 1, self.syncQueueTail or 0 do
        local item = self.syncQueue[index]
        if item then
            captured[#captured + 1] = item
            if IsNonBulkQueueItem(item) then
                expectedNonBulkCount = expectedNonBulkCount + 1
            end
            local queueKey = SyncQueueIndexKey(item)
            if queueKey
                and self.syncQueueCoalesceIndex[queueKey] ~= index
            then
                queueInvariantErrors[#queueInvariantErrors + 1] =
                    "coalescing index mismatch"
            end
        end
    end
    if self.syncQueueNonBulkCount ~= expectedNonBulkCount then
        queueInvariantErrors[#queueInvariantErrors + 1] =
            "priority counter mismatch"
    end
    local snapshotKey = FullSnapshotTargetKey(
        self.db.activeRaidSessionID, "LunaSyncSimulation")
    local snapshotIndex = snapshotKey
        and self.syncQueueFullSnapshotIndex[snapshotKey]
    local snapshotMarker = snapshotIndex and self.syncQueue[snapshotIndex]
    if not snapshotMarker or snapshotMarker.kind ~= "FULL_END" then
        queueInvariantErrors[#queueInvariantErrors + 1] =
            "full-snapshot index mismatch"
    end

    self.syncSimulationCapture = nil
    self.syncQueue = originalQueue or {}
    self.syncQueueHead = originalHead or 1
    self.syncQueueTail = originalTail or 0
    self.syncQueueCoalesceIndex = originalCoalesceIndex
    self.syncQueueFullSnapshotIndex = originalFullSnapshotIndex
    self.syncQueueNonBulkCount = originalNonBulkCount
    if not self.syncQueueCoalesceIndex
        or not self.syncQueueFullSnapshotIndex
        or self.syncQueueNonBulkCount == nil
    then
        RebuildSyncQueueIndexes(self)
    end
    self.syncSequence = originalSequence or 0
    self.assignmentCoalesceGeneration = originalGeneration or 0
    self.sentSimulationFingerprints = originalSimulationFingerprints
    if self.syncFrame then
        if frameWasShown then self.syncFrame:Show() else self.syncFrame:Hide() end
    end
    if not ok then
        self:Print("Sync simulation failed while building the snapshot: "
            .. tostring(failure))
        return false
    end

    local payload, bytes, declaredTotal = {}, 0
    local errors, previousSequence = {}, nil
    local simulatedNames = {}
    local dictionaryEntries, nameReferences = 0, 0
    for _, queueError in ipairs(queueInvariantErrors) do
        errors[#errors + 1] = queueError
    end
    local firstKind, lastKind
    for _, item in ipairs(captured) do
        bytes = bytes + #(item.message or "")
        local fields = Fields(item.message or "")
        if not WIRE_TO_KIND[fields[1]] then
            errors[#errors + 1] = "snapshot used a legacy envelope"
        end
        if #(item.message or "") > 255 then
            errors[#errors + 1] = "packet exceeded 255 bytes"
        end
        local last = fields[#fields]
        if last and last:sub(1, 1) == "@" then fields[#fields] = nil end
        local kind = DecodeFields(fields)
        firstKind = firstKind or kind
        lastKind = kind or lastKind
        if not kind then
            errors[#errors + 1] = "unknown message kind"
        else
            local sequence = tonumber(fields[3])
            if previousSequence and sequence
                and sequence <= previousSequence
            then
                errors[#errors + 1] = "non-increasing sequence"
            end
            previousSequence = sequence or previousSequence
            if kind == "FULL_BEGIN" then
                declaredTotal = tonumber(fields[5])
                if not tonumber(fields[6]) or not tonumber(fields[7]) then
                    errors[#errors + 1] = "full header omitted composition"
                end
            elseif kind ~= "FULL_END" then
                payload[#payload + 1] = item
            end
            if kind == "CURRENT" or kind == "COMP"
                or kind == "SIM_BEGIN" or kind == "SIM_END"
            then
                errors[#errors + 1] = "redundant compact framing: " .. kind
            elseif kind == "NAMES" then
                local dictionaryIndex = tonumber(fields[5]) or 1
                for index = 6, #fields, 2 do
                    simulatedNames[dictionaryIndex] = fields[index]
                    dictionaryEntries = dictionaryEntries + 1
                    dictionaryIndex = dictionaryIndex + 1
                end
            end
            if kind == "PLAN" and (not fields[7] or fields[7] == "") then
                errors[#errors + 1] = "empty PLAN assignment"
            elseif kind == "PLANBATCH" then
                for index = 6, #fields, 3 do
                    if not fields[index + 1] or fields[index + 1] == "" then
                        errors[#errors + 1] = "empty PLANBATCH assignment"
                        break
                    end
                    local reference = fields[index + 1]
                        and fields[index + 1]:match("^~([0-9a-z]+)$")
                    if reference then
                        nameReferences = nameReferences + 1
                        if not simulatedNames[FromBase36(reference)] then
                            errors[#errors + 1] =
                                "PLANBATCH used an unknown name reference"
                            break
                        end
                    end
                end
            end
        end
    end
    if firstKind ~= "FULL_BEGIN" then
        errors[#errors + 1] = "snapshot does not start with FULL_BEGIN"
    end
    if lastKind ~= "FULL_END" then
        errors[#errors + 1] = "snapshot does not end with FULL_END"
    end
    if declaredTotal ~= #payload then
        errors[#errors + 1] = ("declared %s packets but captured %d"):format(
            tostring(declaredTotal), #payload)
    end

    local interval = math.max(.04, math.min(.15, 3 / math.max(1, #payload)))
    local estimatedQueueTime = #payload * (
        ChatThrottleLib and ChatThrottleLib.SendAddonMessage and .03 or .15)
    self:Print(("Sync simulation: %d data packets, %d bytes, "
        .. "about %.1fs in the current queue mode."):format(
            #payload, bytes, estimatedQueueTime))
    if dictionaryEntries > 0 then
        self:Print((
            "Compact name table: %d players, %d assignment references."
        ):format(dictionaryEntries, nameReferences))
    end
    if #errors > 0 then
        self:Print("Sync validation failed: " .. table.concat(errors, "; "))
    else
        self:Print("Sync validation passed: framing, ordering, totals, "
            .. "queue indexes, decoding, and empty-assignment checks are clean.")
    end

    self.syncSimulationPlaybackToken =
        (self.syncSimulationPlaybackToken or 0) + 1
    local token = self.syncSimulationPlaybackToken
    local raid = self:GetRaid()
    if self.BeginRaidSyncProgress then
        self:BeginRaidSyncProgress(
            #payload, (raid and raid.name or "Raid") .. " · LOCAL SYNC TEST")
    end
    local index = 0
    local function Advance()
        if Raid.syncSimulationPlaybackToken ~= token then return end
        index = index + 1
        if index <= #payload then
            if Raid.AdvanceRaidSyncProgress then
                Raid:AdvanceRaidSyncProgress()
            end
            if C_Timer and C_Timer.After then
                C_Timer.After(interval, Advance)
            else
                Advance()
            end
            return
        end
        if Raid.CompleteRaidSyncProgress then
            Raid:CompleteRaidSyncProgress()
        end
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(.2, Advance)
    else
        Advance()
    end
    return #errors == 0
end

function Raid:InitializeCommunication()
    self.syncQueue = self.syncQueue or {}
    self.syncQueueHead = self.syncQueueHead or 1
    self.syncQueueTail = self.syncQueueTail or 0
    if not self.syncQueueCoalesceIndex
        or not self.syncQueueFullSnapshotIndex
        or self.syncQueueNonBulkCount == nil
    then
        RebuildSyncQueueIndexes(self)
    end
    self.syncSequence = self.syncSequence or 0
    self:InitializeRaidAvailabilityBroadcast()
    self:RebuildPeerAuthorityCache()
    if self.communicationWasInGroup == nil then
        self.communicationWasInGroup = self:IsInLiveGroup()
    end
    if self.communicationWasAssistant == nil then
        self.communicationWasAssistant = self:IsGroupAssistant()
    end
    if self.syncFrame then return end
    self.syncFrame = CreateFrame("Frame")
    self.syncFrame:Hide()
    self.syncFrame.elapsed = 0
    self.syncFrame:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = frame.elapsed + elapsed
        local hasThrottle = ChatThrottleLib
            and ChatThrottleLib.SendAddonMessage
        local interval = hasThrottle and .03 or .15
        if frame.elapsed < interval then return end
        frame.elapsed = 0
        -- ChatThrottleLib owns the actual bandwidth limit, so hand it a small
        -- group of queued calls at once. The direct API fallback remains at one
        -- live packet per interval. Either path discards stale-session packets
        -- immediately instead of letting each one consume a throttle interval.
        local sendLimit = hasThrottle and 20 or 1
        local sent = 0
        while sent < sendLimit do
            local head = Raid.syncQueueHead or 1
            local item = Raid.syncQueue and Raid.syncQueue[head]
            if item and item.priority == "BULK"
                and (Raid.syncQueueNonBulkCount or 0) > 0
            then
                for index = head + 1, Raid.syncQueueTail or head do
                    local candidate = Raid.syncQueue[index]
                    if candidate and candidate.priority ~= "BULK" then
                        Raid.syncQueue[head], Raid.syncQueue[index] =
                            candidate, item
                        IndexSyncQueueItem(Raid, candidate, head)
                        IndexSyncQueueItem(Raid, item, index)
                        item = candidate
                        break
                    end
                end
            end
            if not item then
                Raid.syncQueue = {}
                Raid.syncQueueHead = 1
                Raid.syncQueueTail = 0
                Raid.syncQueueCoalesceIndex = {}
                Raid.syncQueueFullSnapshotIndex = {}
                Raid.syncQueueNonBulkCount = 0
                frame:Hide()
                return
            end
            RemoveIndexedSyncQueueItem(Raid, item, head)
            if IsNonBulkQueueItem(item) then
                Raid.syncQueueNonBulkCount = math.max(
                    0, (Raid.syncQueueNonBulkCount or 0) - 1)
            end
            Raid.syncQueue[head] = nil
            Raid.syncQueueHead = head + 1
            local stale = item.kind ~= "HELLO" and item.kind ~= "COOLDOWN"
                and item.kind ~= "CLOSE"
                and (not Raid:IsRaidSyncActive()
                    or item.raidSessionID ~= Raid.db.activeRaidSessionID)
            if not stale then
                local ok = true
                if hasThrottle then
                    local priority = item.priority
                        or (item.kind == "CHECK" and "ALERT" or "NORMAL")
                    ok = pcall(
                        ChatThrottleLib.SendAddonMessage, ChatThrottleLib,
                        priority, PREFIX, item.message,
                        item.distribution, item.target)
                elseif C_ChatInfo and C_ChatInfo.SendAddonMessage then
                    ok = pcall(
                        C_ChatInfo.SendAddonMessage,
                        PREFIX, item.message,
                        item.distribution, item.target)
                elseif SendAddonMessage then
                    ok = pcall(
                        SendAddonMessage,
                        PREFIX, item.message,
                        item.distribution, item.target)
                end
                sent = sent + 1
                if not ok and not Raid.syncSendFailureWarned then
                    Raid.syncSendFailureWarned = true
                    Raid:Print(Raid.L.SYNC_SEND_FAILED)
                end
            end
        end
    end)
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    elseif RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(PREFIX)
    end
    self:RegisterEvent("CHAT_MSG_ADDON")
end
