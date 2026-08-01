local _, Raid = ...
local Core = Raid.Core
local Copy = Core.Copy
local classNames = Core.classNames
local simulatedNames = Core.simulatedNames
local simulatedByRole = Core.simulatedByRole
local function AddRosterPlayer(result, seen, unit)
    local unitExists = UnitExists and UnitExists(unit)
    local raidIndex = unit:match("^raid(%d+)$")
    local rosterName, rosterRank, rosterSubgroup
    local rosterClassName, rosterClass, rosterOnline
    local rosterLevel, rosterZone
    if raidIndex and GetRaidRosterInfo then
        rosterName, rosterRank, rosterSubgroup, rosterLevel,
            rosterClassName, rosterClass, rosterZone, rosterOnline =
            GetRaidRosterInfo(tonumber(raidIndex))
    end
    if not unitExists and not rosterName then return end
    local name = unitExists and UnitName(unit) or rosterName
    local normalizedName = name and name:lower()
    if not name or seen[normalizedName] then return end
    local className, class
    local raceName
    if unitExists then
        className, class = UnitClass(unit)
        raceName = UnitRace(unit)
    end
    className = className or rosterClassName
    class = class or rosterClass
    local groupRole =
        unitExists and UnitGroupRolesAssigned
            and UnitGroupRolesAssigned(unit) or "NONE"
    local reportedRole = groupRole
    local raidAssignment =
        unitExists and GetPartyAssignment
        and GetPartyAssignment("MAINTANK", unit, true)
        and "MAINTANK" or nil
    if not raidAssignment and unitExists and GetPartyAssignment
        and GetPartyAssignment("MAINASSIST", unit, true)
    then
        raidAssignment = "MAINASSIST"
    end
    if raidAssignment == "MAINTANK" then
        reportedRole = "TANK"
    end
    local guid = UnitGUID and UnitGUID(unit)
    local roleKey = guid or name
    local role = Raid.db and Raid.db.roleOverrides[roleKey]
        or reportedRole
    local subgroup
    if raidIndex then subgroup = rosterSubgroup end
    local leader = unitExists and UnitIsGroupLeader
        and UnitIsGroupLeader(unit) or false
    local assistant = unitExists and UnitIsGroupAssistant
        and UnitIsGroupAssistant(unit) or false
    if rosterRank == 2 then
        leader = true
    elseif rosterRank == 1 then
        assistant = true
    end
    if not leader and unit == "player" then
        leader = IsRaidLeader and IsRaidLeader() or false
    end
    seen[normalizedName] = true
    local online
    if rosterOnline ~= nil then
        online = rosterOnline
    elseif unitExists and UnitIsConnected then
        online = UnitIsConnected(unit) ~= false
    else
        online = true
    end
    local player = {
        name = name, class = class, role = role,
        reportedRole = reportedRole,
        groupRole = groupRole,
        raidAssignment = raidAssignment,
        className = className, race = raceName,
        subgroup = subgroup or 1, unit = unit,
        guid = guid,
        leader = leader,
        assistant = assistant,
        online = online,
    }
    local intel = Raid.GetCharacterIntel
        and Raid:GetCharacterIntel(player)
    if intel then
        player.spec = intel.spec
        player.intelSource = intel.source
        player.race = intel.race ~= "" and intel.race or player.race
        player.gearScore = tonumber(intel.gearScore)
            or player.gearScore
        player.itemLevel = tonumber(intel.itemLevel)
            or player.itemLevel
        if (not player.role or player.role == "NONE"
            or player.role == "DAMAGER"
                and (intel.role == "TANK" or intel.role == "HEALER"))
            and intel.role and intel.role ~= "NONE"
        then
            player.role = intel.role
        end
    end
    result[#result + 1] = player
end

function Raid:AddManualPlayer(name, class, role, spec, subgroup)
    if not self:RequireRaidEditor() then return end
    name = strtrim(name or "")
    name = name:match("^[^-]+") or name
    if name == "" then
        self:Print(self.L.ENTER_CHARACTER_NAME)
        return
    end
    class = classNames[class] and class or "WARRIOR"
    if role ~= "TANK" and role ~= "HEALER" and role ~= "DAMAGER" then
        role = "DAMAGER"
    end
    local raid = self:GetRaid()
    self.db.manualPlayers[raid.key] =
        self.db.manualPlayers[raid.key] or {}
    local existing = self.db.manualPlayers[raid.key][name:lower()]
    subgroup = math.max(
        1, math.min(8, tonumber(subgroup)
            or existing and existing.subgroup or 1))
    self.db.manualPlayers[raid.key][name:lower()] = {
        name = name,
        class = class,
        className = classNames[class],
        role = role,
        reportedRole = role,
        spec = strtrim(spec or ""),
        race = "Planned",
        subgroup = subgroup,
        online = false,
        manual = true,
    }
    if self.QueueSync and self:IsLocalRaidEditor() then
        self:QueueSync("MANUAL", {
            raid.key, name, class, role, strtrim(spec or ""), subgroup,
        })
    end
    self:UpdateRoster()
end

function Raid:RemoveManualPlayer(name)
    if not self:RequireRaidEditor() then return end
    local raid = self:GetRaid()
    local key = name and name:lower()
    if not key or not self.db.manualPlayers[raid.key] then return end
    self.db.manualPlayers[raid.key][key] = nil
    local plans = self.simulation.enabled
        and self.simulation.plans or self.db.plans
    for encounterIndex, plan in pairs(plans[raid.key] or {}) do
        for assignmentKey, assignment in pairs(plan) do
            if type(assignment) == "table"
                and assignment.name
                and assignment.name:lower() == key
            then
                plan[assignmentKey] = nil
                if self.QueueSync and self:IsLocalRaidEditor() then
                    self:QueueSync("CLEAR", {
                        raid.key, encounterIndex, assignmentKey,
                    })
                end
            end
        end
    end
    if self.selectedPlayer
        and self.selectedPlayer.name
        and self.selectedPlayer.name:lower() == key
    then
        self.selectedPlayer = nil
    end
    if self.QueueSync and self:IsLocalRaidEditor() then
        self:QueueSync("MANUALDEL", { raid.key, name })
    end
    self:UpdateRoster()
    if self.RefreshAssignments then self:RefreshAssignments() end
end

function Raid:SetPlayerRole(player, role)
    if not self:RequireRaidEditor() then return end
    if not player then return end
    if player.manual then
        self:AddManualPlayer(
            player.name, player.class,
            role == "AUTO" and "DAMAGER" or role,
            player.spec or "", player.subgroup)
        return
    end
    local key = player.guid or player.name
    if not key then return end
    local actualRole = role == "AUTO" and "NONE" or role
    local changedBlizzardRole = false
    if not self.simulation.enabled and player.unit
        and type(UnitSetRole) == "function"
    then
        local ok = pcall(UnitSetRole, player.unit, actualRole)
        if not ok then
            self:Print(self.L.ROLE_CHANGE_REJECTED)
            return
        end
        changedBlizzardRole = true
        player.groupRole = actualRole
        player.reportedRole = actualRole
    end
    if role == "AUTO" then
        self.db.roleOverrides[key] = nil
        player.role = changedBlizzardRole
            and "NONE" or player.reportedRole or "NONE"
    else
        self.db.roleOverrides[key] =
            changedBlizzardRole and nil or role
        player.role = role
    end
    self:RefreshRoster()
end

local function LiveRaidIndex(player)
    return player and player.unit
        and tonumber(player.unit:match("^raid(%d+)$"))
end

function Raid:SetVirtualPlayerGroup(player, subgroup)
    if not player then return end
    subgroup = math.max(1, math.min(8, tonumber(subgroup) or 1))
    player.subgroup = subgroup
    if player.simulated and self.db.simulationSession
        and player.name
    then
        self.db.simulationSession.groups =
            self.db.simulationSession.groups or {}
        self.db.simulationSession.groups[player.name:lower()] = subgroup
    end
    if player.manual then
        local raid = self:GetRaid()
        local saved = self.db.manualPlayers[raid.key]
            and self.db.manualPlayers[raid.key][player.name:lower()]
        if saved then saved.subgroup = subgroup end
    end
    for _, roster in ipairs({
        self.simulation.roster,
        self.remoteSimulationRoster,
        self.roster,
    }) do
        for _, candidate in ipairs(roster or {}) do
            if candidate.name and player.name
                and candidate.name:lower() == player.name:lower()
                and (candidate.manual or candidate.simulated)
            then
                candidate.subgroup = subgroup
            end
        end
    end
    if self.QueueSync then
        self:QueueSync("GROUP", {
            self.db.activeRaid, player.name, subgroup,
        })
    end
end

function Raid:MoveRosterPlayer(player, subgroup, target)
    if not self:RequireRaidGroupEditor() or not player then return end
    subgroup = math.max(1, math.min(8, tonumber(subgroup) or 1))
    local sourceIndex, targetIndex =
        LiveRaidIndex(player), LiveRaidIndex(target)
    local sourceGroup = player.subgroup or 1
    local targetGroup = target and target.subgroup or subgroup
    if sourceIndex or targetIndex then
        if not (IsInRaid and IsInRaid()) then
            self:Print(self.L.GROUP_EDIT_REQUIRES_RAID)
            return
        end
        if (sourceIndex and targetIndex
            and type(SwapRaidSubgroup) ~= "function")
            or (not (sourceIndex and targetIndex)
                and type(SetRaidSubgroup) ~= "function")
        then
            self:Print(self.L.GROUP_EDIT_UNSUPPORTED)
            return
        end
        local ok
        if sourceIndex and targetIndex then
            ok = pcall(SwapRaidSubgroup, sourceIndex, targetIndex)
        elseif sourceIndex then
            ok = pcall(SetRaidSubgroup, sourceIndex, targetGroup)
        else
            ok = pcall(SetRaidSubgroup, targetIndex, sourceGroup)
        end
        if not ok then
            self:Print(self.L.GROUP_CHANGE_REJECTED)
            return
        end
    end
    if not sourceIndex then
        self:SetVirtualPlayerGroup(player, targetGroup)
    end
    if target and not targetIndex then
        self:SetVirtualPlayerGroup(target, sourceGroup)
    end
    self.selectedPlayer = nil
    self.dragPlayer = nil
    self:UpdateRoster()
    if self.RefreshAssignments then self:RefreshAssignments() end
end

function Raid:StartRoleCheck()
    if not self:IsLocalRaidEditor() then
        self:Print(self.L.ROLE_CHECK_REQUIRES_LEADERSHIP)
        return
    end
    if self.simulation.enabled then
        if RaidNotice_AddMessage and RaidWarningFrame then
            RaidNotice_AddMessage(
                RaidWarningFrame,
                "[LunaRaids] Role check started",
                ChatTypeInfo and ChatTypeInfo.RAID_WARNING
                    or { r = 1, g = .2, b = .2 })
        end
        self:Print(self.L.SIM_ROLE_CHECK_REQUESTED)
        return
    end
    local rolePoll = C_PartyInfo
        and C_PartyInfo.InitiateRolePoll or InitiateRolePoll
    if type(rolePoll) ~= "function" then
        self:Print(self.L.ROLE_CHECK_UNSUPPORTED)
        return
    end
    local ok = pcall(rolePoll)
    if not ok then
        self:Print(self.L.ROLE_CHECK_REJECTED)
    end
end

function Raid:StartReadyCheck()
    if not self:IsLocalRaidEditor() then
        self:Print(self.L.READY_CHECK_REQUIRES_LEADERSHIP)
        return
    end
    if self.simulation.enabled then
        if self.ShowReadyCheckWindow then
            self:ShowReadyCheckWindow(
                35, true,
                GetUnitName("player", true) or UnitName("player"))
        end
        if RaidNotice_AddMessage and RaidWarningFrame then
            RaidNotice_AddMessage(
                RaidWarningFrame,
                "[LunaRaids] Ready check started",
                ChatTypeInfo and ChatTypeInfo.RAID_WARNING
                    or { r = 1, g = .2, b = .2 })
        end
        return
    end
    local readyCheck = C_PartyInfo
        and C_PartyInfo.DoReadyCheck or DoReadyCheck
    if type(readyCheck) ~= "function" then
        self:Print(self.L.READY_CHECK_UNSUPPORTED)
        return
    end
    self.pendingReadyCheckCaller =
        GetUnitName("player", true) or UnitName("player")
    local ok = pcall(readyCheck)
    if not ok then
        self:Print(self.L.READY_CHECK_REJECTED)
    end
end

function Raid:StartPullCountdown(seconds)
    seconds = math.max(1, math.min(30, tonumber(seconds) or 10))
    if not self:IsLocalRaidEditor() then
        self:Print(self.L.PULL_TIMER_REQUIRES_LEADERSHIP)
        return
    end
    if _G.DBM and type(_G.DBM.CreatePullTimer) == "function" then
        local ok = pcall(_G.DBM.CreatePullTimer, _G.DBM, seconds)
        if ok then
            if self.simulation.enabled then
                self:Print(self:Localize("SIM_PULL_TIMER", seconds))
            end
            return
        end
    end
    if self.simulation.enabled then
        if RaidNotice_AddMessage and RaidWarningFrame then
            RaidNotice_AddMessage(
                RaidWarningFrame,
                ("[LunaRaids] Pull in %d"):format(seconds),
                ChatTypeInfo and ChatTypeInfo.RAID_WARNING
                    or { r = 1, g = .2, b = .2 })
        end
        return
    end
    if C_PartyInfo
        and type(C_PartyInfo.DoCountdown) == "function"
    then
        local ok = pcall(C_PartyInfo.DoCountdown, seconds)
        if ok then return end
    end
    if type(SendChatMessage) == "function" then
        local ok = pcall(
            SendChatMessage,
            ("[LunaRaids] Pull in %d"):format(seconds),
            "RAID_WARNING")
        if ok then return end
    end
    self:Print(self.L.PULL_TIMER_REJECTED)
end

function Raid:StartBreakTimer(minutes)
    minutes = math.max(1, math.min(
        60, math.floor(tonumber(minutes) or 5)))
    if not self:IsLocalRaidEditor() then
        self:Print(self.L.BREAK_TIMER_REQUIRES_LEADERSHIP)
        return
    end
    local seconds = minutes * 60
    if _G.DBM and type(_G.DBM.CreatePizzaTimer) == "function" then
        pcall(
            _G.DBM.CreatePizzaTimer, _G.DBM,
            seconds, ("Break - %d minutes"):format(minutes), true)
    end
    local message =
        ("[LunaRaids] Break - %d minutes."):format(minutes)
    if self.simulation.enabled then
        if RaidNotice_AddMessage and RaidWarningFrame then
            RaidNotice_AddMessage(
                RaidWarningFrame, message,
                ChatTypeInfo and ChatTypeInfo.RAID_WARNING
                    or { r = 1, g = .28, b = 0 })
        end
        self:Print(self:Localize("SIM_BREAK_TIMER", minutes))
        return
    end
    local channel = IsInRaid and IsInRaid()
        and "RAID_WARNING" or "PARTY"
    if type(SendChatMessage) == "function" then
        pcall(SendChatMessage, message, channel)
    end
end

function Raid:UpdateGearScoreFromTipTac(player)
    if not player or not player.unit or not UnitExists(player.unit) then
        return false
    end
    local tipTac
    if LibStub and LibStub.GetLibrary then
        tipTac = LibStub:GetLibrary("LibFroznFunctions-1.0", true)
        if not tipTac
            or type(tipTac.GetAverageItemLevel) ~= "function"
        then
            tipTac = nil
        end
    end
    if not tipTac then return false end
    self.gearScores = self.gearScores or {}
    local function StoreResult(result)
        if type(result) ~= "table" then return false end
        local score = tonumber(
            result.TacoTipGearScore or result.TipTacGearScore)
        local itemLevel = tonumber(result.value)
        score = tonumber(score)
        if not score or score <= 0 then return false end
        score = math.floor(score)
        itemLevel = math.floor(itemLevel or 0)
        local key = player.guid or player.name
        local cached = self.gearScores[key]
        local updated = not cached or cached.score ~= score
            or cached.itemLevel ~= itemLevel
        if updated then
            self.gearScores[key] = {
                score = score,
                itemLevel = itemLevel,
            }
        end
        player.gearScore = score
        player.itemLevel = itemLevel
        for _, current in ipairs(self.roster or {}) do
            if current ~= player and (
                key and (current.guid or current.name) == key
                    or current.name == player.name
            ) then
                current.gearScore = score
                current.itemLevel = itemLevel
            end
        end
        return updated
    end
    local ok, result = pcall(
        tipTac.GetAverageItemLevel, tipTac, player.unit,
        function(asyncResult)
            if StoreResult(asyncResult) and Raid.RefreshRoster
                and Raid.rosterPanel and Raid.rosterPanel:IsShown()
            then
                Raid:RefreshRoster()
            end
        end)
    return ok and StoreResult(result) or false
end

function Raid:UpdateGearScores()
    if self.simulation.enabled then return end
    local tacoTip = _G.TT_GS
        and type(_G.TT_GS.GetScore) == "function"
        and _G.TT_GS or nil
    if not tacoTip and not (
        LibStub and LibStub.GetLibrary
            and LibStub:GetLibrary("LibFroznFunctions-1.0", true)
    ) then
        return
    end
    self.gearScores = self.gearScores or {}
    local changed = false

    for _, player in ipairs(self.roster or {}) do
        local found
        local identifier = player.guid or player.unit
        if tacoTip and identifier then
            local ok, score, itemLevel = pcall(
                tacoTip.GetScore, tacoTip, identifier, false)
            if ok and tonumber(score) and score > 0 then
                found = true
                score = math.floor(tonumber(score))
                itemLevel = math.floor(tonumber(itemLevel) or 0)
                local key = player.guid or player.name
                local cached = self.gearScores[key]
                if not cached or cached.score ~= score
                    or cached.itemLevel ~= itemLevel
                then
                    self.gearScores[key] = {
                        score = score,
                        itemLevel = itemLevel,
                    }
                    changed = true
                end
                player.gearScore = score
                player.itemLevel = itemLevel
            end
        end
        if not found and player.unit and UnitIsUnit
            and UnitIsUnit(player.unit, "player")
        then
            if self:UpdateGearScoreFromTipTac(player) then
                changed = true
                found = true
            end
        end
        if not found then
            local cached = self.gearScores[player.guid or player.name]
            if cached then
                player.gearScore = cached.score
                player.itemLevel = cached.itemLevel
            end
        end
    end
    if changed and self.RefreshRoster
        and self.rosterPanel and self.rosterPanel:IsShown()
    then
        self:RefreshRoster()
    end
end

local function GetLiveRaidCount()
    local modernCount = GetNumGroupMembers
        and tonumber(GetNumGroupMembers()) or 0
    local legacyCount = GetNumRaidMembers
        and tonumber(GetNumRaidMembers()) or 0
    local detectedCount = 0
    for index = 1, 40 do
        local unit = "raid" .. index
        local rosterName = GetRaidRosterInfo
            and GetRaidRosterInfo(index)
        if rosterName or UnitExists and UnitExists(unit) then
            detectedCount = index
        end
    end
    local explicitlyInRaid = IsInRaid and IsInRaid() or false
    local inRaid = explicitlyInRaid
        or legacyCount > 0 or detectedCount > 0
    return inRaid
        and math.max(modernCount, legacyCount, detectedCount) or 0,
        inRaid
end

function Raid:BuildLiveRoster()
    local result, seen = {}, {}
    local raidCount, inRaid = GetLiveRaidCount()
    if inRaid then
        for index = 1, raidCount do
            AddRosterPlayer(result, seen, "raid" .. index)
        end
    else
        AddRosterPlayer(result, seen, "player")
        local partyCount = GetNumSubgroupMembers and GetNumSubgroupMembers()
            or GetNumPartyMembers and GetNumPartyMembers() or 0
        for index = 1, partyCount do
            AddRosterPlayer(result, seen, "party" .. index)
        end
    end
    for _, player in pairs(
        self.db.manualPlayers[self.db.activeRaid] or {}) do
        local normalizedName = player.name and player.name:lower()
        if normalizedName and not seen[normalizedName] then
            seen[normalizedName] = true
            result[#result + 1] = Copy(player)
        end
    end
    return result, seen
end

function Raid:BuildSimulatedRoster(size)
    local result, seen = self:BuildLiveRoster()
    local simulated = {}
    local previousGroups = {}
    for _, player in ipairs(self.simulation.roster or {}) do
        if player.name then
            previousGroups[player.name:lower()] = player.subgroup
        end
    end
    local tankCount = size == 10 and 2
        or size == 25 and 3 or 5
    local healerCount = size == 10 and 3
        or size == 25 and 7 or 12
    local roleIndexes = {
        TANK = 0, HEALER = 0, DAMAGER = 0,
    }
    local roleCounts = {
        TANK = 0, HEALER = 0, DAMAGER = 0,
    }
    for _, player in ipairs(result) do
        local role = player.role or player.reportedRole or "DAMAGER"
        roleCounts[role] = (roleCounts[role] or 0) + 1
    end
    local needed = math.max(0, size - #result)
    for offset = 1, needed do
        local index = #result + 1
        local role = roleCounts.TANK < tankCount and "TANK"
            or roleCounts.HEALER < healerCount and "HEALER"
            or "DAMAGER"
        roleCounts[role] = roleCounts[role] + 1
        roleIndexes[role] = roleIndexes[role] + 1
        local pool = simulatedByRole[role]
        local character = pool[
            ((roleIndexes[role] - 1) % #pool) + 1]
        local nameIndex = offset
        local name = simulatedNames[nameIndex]
            or ("SimRaider" .. nameIndex)
        while seen[name:lower()] do
            nameIndex = nameIndex + 1
            name = simulatedNames[nameIndex]
                or ("SimRaider" .. nameIndex)
        end
        local player = {
            name = name,
            class = character[1],
            className = classNames[character[1]],
            race = character[2],
            role = role,
            reportedRole = role,
            spec = character[4],
            subgroup = previousGroups[name:lower()]
                or math.floor((index - 1) / 5) + 1,
            leader = false,
            simulated = true,
        }
        seen[name:lower()] = true
        result[#result + 1] = player
        simulated[#simulated + 1] = player
    end
    for _, player in ipairs(result) do
        player.reportedRole = player.reportedRole or player.role
        player.role = self.db.roleOverrides[player.guid or player.name]
            or player.reportedRole
    end
    return result, simulated
end

function Raid:StartSimulation(size)
    size = tonumber(size)
    if size ~= 10 and size ~= 25 and size ~= 40 then
        self:Print(self.L.SIM_USAGE)
        return
    end
    if not self.simulation.enabled then
        self.simulation.selection = {
            activeExpansion = self.db.activeExpansion,
            activeRaid = self.db.activeRaid,
            activeEncounter = self.db.activeEncounter,
            lastRaidByExpansion =
                Copy(self.db.lastRaidByExpansion),
            lastEncounterByRaid =
                Copy(self.db.lastEncounterByRaid),
        }
        self.db.simulationRestore =
            Copy(self.simulation.selection)
    end
    self.simulation.enabled = true
    self.simulation.size = size
    self.simulation.plans = {}
    wipe(self.messageQueue)
    if self.messageFrame then self.messageFrame:Hide() end
    self.roster, self.simulation.roster =
        self:BuildSimulatedRoster(size)
    local groups = {}
    for _, player in ipairs(self.simulation.roster or {}) do
        if player.name then
            groups[player.name:lower()] = player.subgroup
        end
    end
    self.db.simulationSession = {
        size = size,
        selection = Copy(self.simulation.selection),
        plans = self.simulation.plans,
        groups = groups,
    }
    if self.SeedSimulatedRaidCooldowns then
        self:SeedSimulatedRaidCooldowns()
    end
    self.selectedPlayer = nil
    self:RefreshRoster()
    self:CreateUI()
    self:RefreshAll()
    self.frame:Show()
    if self.BroadcastSimulationRoster then
        self:BroadcastSimulationRoster()
    end
    self:Print(self:Localize(
        "SIMULATION_ENABLED", size, #self.simulation.roster))
end

function Raid:StopSimulation(silent)
    if not self.simulation.enabled then
        self.db.simulationSession = nil
        self.db.simulationRestore = nil
        if self.ClearSimulatedRaidCooldowns then
            self:ClearSimulatedRaidCooldowns()
        end
        self.remoteSimulationRoster = nil
        if self.BroadcastSimulationClear then
            self:BroadcastSimulationClear()
        end
        self:UpdateRoster()
        if not silent then
            self:Print(self.L.SIM_PLAYERS_CLEARED)
        end
        return
    end
    if self.BroadcastSimulationClear then
        self:BroadcastSimulationClear()
    end
    self.simulation.enabled = false
    if self.ClearSimulatedRaidCooldowns then
        self:ClearSimulatedRaidCooldowns()
    end
    self.simulation.size = 0
    self.simulation.plans = nil
    self.simulation.roster = nil
    wipe(self.messageQueue)
    if self.messageFrame then self.messageFrame:Hide() end
    local selection = self.simulation.selection
        or self.db.simulationRestore
    if selection then
        self.db.activeExpansion = selection.activeExpansion
        self.db.activeRaid = selection.activeRaid
        self.db.activeEncounter = selection.activeEncounter
        self.db.lastRaidByExpansion =
            selection.lastRaidByExpansion
        self.db.lastEncounterByRaid =
            selection.lastEncounterByRaid
        self.simulation.selection = nil
    end
    self.db.simulationRestore = nil
    self.db.simulationSession = nil
    self.selectedPlayer = nil
    self:UpdateRoster()
    if self.RefreshRaidCooldowns then
        self:RefreshRaidCooldowns()
    end
    if self.frame then self:RefreshAll() end
    if not silent then
        self:Print(self.L.SIMULATION_CLEARED)
    end
end

function Raid:UpdateRoster(suppressRosterRefresh)
    if self.simulation.enabled then
        self.roster, self.simulation.roster =
            self:BuildSimulatedRoster(self.simulation.size)
        if self.BroadcastSimulationRoster then
            self:BroadcastSimulationRoster()
        end
        if not suppressRosterRefresh and self.RefreshRoster then
            self:RefreshRoster()
        end
        return
    end
    local result, seen = self:BuildLiveRoster()
    for _, player in ipairs(self.remoteSimulationRoster or {}) do
        local normalizedName = player.name and player.name:lower()
        if normalizedName and not seen[normalizedName] then
            seen[normalizedName] = true
            result[#result + 1] = Copy(player)
        end
    end
    table.sort(result, function(left, right)
        if left.subgroup ~= right.subgroup then
            return left.subgroup < right.subgroup
        end
        return left.name < right.name
    end)
    self.roster = result
    self:UpdateGearScores()
    if not suppressRosterRefresh and self.RefreshRoster then
        self:RefreshRoster()
    end
end

function Raid:RestoreSimulationSession()
    local session = self.db and self.db.simulationSession
    local size = session and tonumber(session.size)
    if size ~= 10 and size ~= 25 and size ~= 40 then
        if session then self.db.simulationSession = nil end
        return false
    end
    self.simulation.enabled = true
    self.simulation.size = size
    self.simulation.selection = Copy(
        session.selection or self.db.simulationRestore or {})
    self.simulation.plans = Copy(session.plans or {})
    self.simulation.roster = {}
    for name, subgroup in pairs(session.groups or {}) do
        self.simulation.roster[#self.simulation.roster + 1] = {
            name = name, subgroup = subgroup,
        }
    end
    self.roster, self.simulation.roster =
        self:BuildSimulatedRoster(size)
    session.plans = self.simulation.plans
    session.selection = Copy(self.simulation.selection)
    session.groups = {}
    for _, player in ipairs(self.simulation.roster or {}) do
        if player.name then
            session.groups[player.name:lower()] = player.subgroup
        end
    end
    if self.SeedSimulatedRaidCooldowns then
        self:SeedSimulatedRaidCooldowns()
    end
    return true
end

function Raid:RefreshLoginRoster()
    self.rosterBootstrapGeneration =
        (self.rosterBootstrapGeneration or 0) + 1
    local generation = self.rosterBootstrapGeneration
    local attempts = 0
    local function Refresh()
        if generation ~= Raid.rosterBootstrapGeneration then return end
        Raid:UpdateRoster()
        if Raid.RefreshPersonalAssignments then
            Raid:RefreshPersonalAssignments()
        end
        local expected, inRaid = GetLiveRaidCount()
        if not inRaid then return end
        local liveCount = 0
        for _, player in ipairs(Raid.roster or {}) do
            if player.unit and player.unit:match("^raid%d+$") then
                liveCount = liveCount + 1
            end
        end
        attempts = attempts + 1
        if (expected > liveCount or liveCount == 0) and attempts < 8
            and C_Timer and C_Timer.After
        then
            C_Timer.After(.5, Refresh)
        end
    end
    Refresh()
end

function Raid:HandlePlayerEnteringWorld()
    self:RefreshLoginRoster()
end

function Raid:FindPlayer(name)
    for _, player in ipairs(self.roster) do
        if player.name == name then return player end
    end
    return { name = name }
end

