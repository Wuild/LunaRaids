local _, Raid = ...

local SPEC_ROLE = {
    Protection = "TANK", Guardian = "TANK",
    Restoration = "HEALER", Holy = "HEALER", Discipline = "HEALER",
    Mistweaver = "HEALER",
}

local function ShortName(name)
    if not name then return "" end
    if Ambiguate then return Ambiguate(name, "short") end
    return name:match("^[^-]+") or name
end

local function TalentTabDetails(inspect, index)
    local results = {
        pcall(GetTalentTabInfo, index, inspect, false),
    }
    if not results[1] then
        results = { pcall(GetTalentTabInfo, index) }
    end
    if not results[1] then return nil, 0 end

    if type(results[2]) == "string" then
        return results[2], tonumber(results[4]) or 0
    end
    if type(results[3]) == "string" then
        return results[3], tonumber(results[6])
            or tonumber(results[5]) or 0
    end
    return nil, 0
end

local function NormalizeSpecialization(spec)
    if type(spec) == "number"
        or type(spec) == "string" and spec:match("^%d+$")
    then
        local specID = tonumber(spec)
        if specID and GetSpecializationInfoByID then
            local _, name = GetSpecializationInfoByID(specID)
            if type(name) == "string" and name ~= "" then
                return name
            end
        end
        return nil
    end
    return type(spec) == "string" and spec ~= "" and spec or nil
end

local function IsSelfReported(data)
    return data and type(data.source) == "string"
        and data.source:match("^Addon") ~= nil
end

local function IsKnownSpec(spec)
    return type(spec) == "string"
        and spec ~= "" and spec ~= "Unknown"
end

local function DetectSpecialization(inspect, unit)
    if GetNumTalentTabs and GetTalentTabInfo then
        local ok, count = pcall(GetNumTalentTabs, inspect, false)
        if not ok then ok, count = pcall(GetNumTalentTabs) end
        count = ok and tonumber(count) or 0
        local bestName, bestPoints
        for index = 1, count do
            local name, points = TalentTabDetails(inspect, index)
            if name and (not bestPoints or points > bestPoints) then
                bestName, bestPoints = name, points
            end
        end
        if bestName and (bestPoints or 0) > 0 then
            return bestName, bestPoints
        end
    end
    if not inspect and GetSpecialization and GetSpecializationInfo then
        local index = GetSpecialization()
        if index then
            local _, name = GetSpecializationInfo(index)
            if name and name ~= "" then return name, 0 end
        end
    end
    if inspect and GetInspectSpecialization and GetSpecializationInfoByID then
        local specID = GetInspectSpecialization(unit)
        if specID and specID > 0 then
            local _, name = GetSpecializationInfoByID(specID)
            if name and name ~= "" then return name, 0 end
        end
    end
    return nil, 0
end

local function ResolveRole(reportedRole, spec)
    local inferred = spec and SPEC_ROLE[spec]
    if inferred and (
        not reportedRole or reportedRole == "NONE"
            or reportedRole == "DAMAGER"
    ) then
        return inferred
    end
    return reportedRole and reportedRole ~= "NONE"
        and reportedRole or inferred or "DAMAGER"
end

function Raid:GetCharacterIntel(player)
    if not player or not self.db.characterIntel then return nil end
    return player.guid and self.db.characterIntel[player.guid]
        or self.db.characterIntel[player.name]
end

function Raid:StoreCharacterIntel(data)
    if not data or not data.name then return end
    data.spec = NormalizeSpecialization(data.spec) or "Unknown"
    local incomingSpecKnown = IsKnownSpec(data.spec)
    self.db.characterIntel = self.db.characterIntel or {}
    data.updated = tonumber(data.updated)
        or (GetServerTime and GetServerTime()
            or time and time() or 0)
    local existing = data.guid and data.guid ~= ""
        and self.db.characterIntel[data.guid]
        or self.db.characterIntel[data.name]
    if existing then
        if not IsKnownSpec(data.spec) and IsKnownSpec(existing.spec) then
            data.spec = existing.spec
        end
        if (existing.role == "TANK" or existing.role == "HEALER")
            and (not data.role or data.role == "NONE"
                or data.role == "DAMAGER")
            and (not incomingSpecKnown or data.spec == existing.spec)
        then
            data.role = existing.role
        end
        local existingUpdated = tonumber(existing.updated) or 0
        local incomingIsSelf = IsSelfReported(data)
        local existingIsSelf = IsSelfReported(existing)
        if existingIsSelf and not incomingIsSelf then
            if not IsKnownSpec(existing.spec) and IsKnownSpec(data.spec) then
                existing.spec = data.spec
                existing.points = data.points
                existing.localUpdated = data.localUpdated
                if (not existing.role or existing.role == "NONE"
                    or existing.role == "DAMAGER")
                    and (data.role == "TANK" or data.role == "HEALER")
                then
                    existing.role = data.role
                end
                data = existing
            else
                return
            end
        end
        if existingUpdated > data.updated
            and not (incomingIsSelf and not existingIsSelf)
        then
            return
        end
    end
    if data.guid and data.guid ~= "" then
        self.db.characterIntel[data.guid] = data
    end
    self.db.characterIntel[data.name] = data
    for _, player in ipairs(self.roster or {}) do
        if player.name == data.name
            or data.guid and player.guid == data.guid
        then
            if IsKnownSpec(data.spec)
                or not IsKnownSpec(player.spec)
            then
                player.spec = data.spec
            end
            player.intelSource = data.source
            player.race = data.race ~= "" and data.race or player.race
            player.gearScore = tonumber(data.gearScore) or player.gearScore
            player.itemLevel = tonumber(data.itemLevel) or player.itemLevel
            if (not player.role or player.role == "NONE"
                or player.role == "DAMAGER"
                    and (data.role == "TANK" or data.role == "HEALER"))
                and data.role and data.role ~= "NONE"
            then
                player.role = data.role
            end
        end
    end
    if self.RefreshRoster then self:RefreshRoster() end
end

function Raid:BuildOwnCharacterIntel()
    local name = UnitName("player")
    if not name then return nil end
    local _, class = UnitClass("player")
    local race = UnitRace("player")
    local rosterPlayer = self.FindPlayer and self:FindPlayer(name)
    local spec, points = DetectSpecialization(false, "player")
    local role = UnitGroupRolesAssigned
        and UnitGroupRolesAssigned("player") or "NONE"
    role = ResolveRole(role, spec)
    return {
        name = name,
        guid = UnitGUID and UnitGUID("player") or "",
        class = class or "",
        role = role or "NONE",
        spec = spec or "Unknown",
        points = points or 0,
        source = "Addon",
        race = race or "",
        gearScore = rosterPlayer and rosterPlayer.gearScore or "",
        itemLevel = rosterPlayer and rosterPlayer.itemLevel or "",
        updated = GetServerTime and GetServerTime()
            or time and time() or 0,
    }
end

function Raid:BroadcastCharacterProfile()
    if not self.QueueSync or not IsInGroup or not IsInGroup() then return end
    local data = self:BuildOwnCharacterIntel()
    if not data then return end
    self:StoreCharacterIntel(data)
    self:QueueSync("PROFILE", {
        data.name, data.guid, data.class, data.role,
        data.spec, data.points, data.updated, data.race,
        data.gearScore, data.itemLevel,
    })
end

function Raid:BroadcastInspectedIntel(data)
    if not self.QueueSync or not self:IsLocalRaidEditor() then return end
    self:QueueSync("INTEL", {
        data.name, data.guid, data.class, data.role,
        data.spec, data.points, data.updated, data.race,
        data.gearScore, data.itemLevel,
    })
end

function Raid:ReceiveCharacterProfile(fields, sender, inspected)
    local data = {
        name = fields[4],
        guid = fields[5],
        class = fields[6],
        role = fields[7],
        spec = fields[8],
        points = tonumber(fields[9]) or 0,
        updated = tonumber(fields[10]),
        race = fields[11] or "",
        gearScore = tonumber(fields[12]),
        itemLevel = tonumber(fields[13]),
        source = inspected and ("Inspect: " .. ShortName(sender))
            or ("Addon: " .. ShortName(sender)),
        localUpdated = inspected and (GetTime and GetTime() or 0) or nil,
    }
    if not inspected and ShortName(data.name) ~= ShortName(sender) then
        return
    end
    self:StoreCharacterIntel(data)
end

function Raid:FindInspectableUnit()
    local now = GetTime and GetTime() or 0
    local serverNow = GetServerTime and GetServerTime()
        or time and time() or 0
    for _, player in ipairs(self.roster or {}) do
        local unit = player.unit
        local cached = self:GetCharacterIntel(player)
        local inspectKey = player.guid or player.name
        local stale
        if not cached then
            stale = true
        elseif IsSelfReported(cached) then
            stale = serverNow - (tonumber(cached.updated) or 0) > 300
        else
            stale = now - (cached.localUpdated or 0) > 300
        end
        if unit and stale and UnitExists(unit) and UnitIsPlayer(unit)
            and not UnitIsUnit(unit, "player")
            and (not UnitIsConnected or UnitIsConnected(unit))
            and (not UnitIsVisible or UnitIsVisible(unit))
            and (not UnitIsDeadOrGhost or not UnitIsDeadOrGhost(unit))
            and (not CheckInteractDistance
                or CheckInteractDistance(unit, 1))
            and (not CanInspect or CanInspect(unit, false))
            and (not self.IsPeerInspectReserved
                or not self:IsPeerInspectReserved(inspectKey))
        then
            return unit
        end
    end
end

function Raid:TryInspectNext()
    local now = GetTime and GetTime() or 0
    if self.pendingInspect then
        if now - (self.pendingInspect.started or now) > 6 then
            self.pendingInspect = nil
        else
            return
        end
    end
    if self.gearInspectPending then return end
    if not NotifyInspect then return end
    if not self:IsLocalRaidEditor() then return end
    if InCombatLockdown and InCombatLockdown() then return end
    if _G.InspectFrame and InspectFrame:IsShown() then return end
    if now - (self.lastGlobalInspectAt or 0) < 5 then return end
    if now - (self.lastInspectAt or 0) < 5 then return end
    local unit = self:FindInspectableUnit()
    if not unit then return end
    self.pendingInspect = {
        unit = unit,
        guid = UnitGUID(unit),
        name = UnitName(unit),
        started = now,
    }
    self.lastInspectAt = now
    if self.BroadcastInspectClaim then
        self:BroadcastInspectClaim(
            self.pendingInspect.guid or self.pendingInspect.name, 10)
    end
    NotifyInspect(unit)
end

function Raid:INSPECT_READY(_, guid)
    local pending = self.pendingInspect
    if not pending or pending.guid ~= guid then return end
    local unit = pending.unit
    local spec, points = DetectSpecialization(true, unit)
    local _, class = UnitClass(unit)
    local race = UnitRace(unit)
    local rosterPlayer
    for _, player in ipairs(self.roster or {}) do
        if player.guid == guid or player.name == pending.name then
            rosterPlayer = player
            break
        end
    end
    local role = UnitGroupRolesAssigned
        and UnitGroupRolesAssigned(unit) or "NONE"
    role = ResolveRole(role, spec)
    local data = {
        name = pending.name,
        guid = guid,
        class = class or "",
        role = role or "NONE",
        spec = spec or "Unknown",
        points = points or 0,
        source = "Inspect",
        race = race or "",
        gearScore = rosterPlayer and rosterPlayer.gearScore or "",
        itemLevel = rosterPlayer and rosterPlayer.itemLevel or "",
        updated = GetServerTime and GetServerTime()
            or time and time() or 0,
        localUpdated = GetTime and GetTime() or 0,
    }
    self.pendingInspect = nil
    self.lastGlobalInspectAt = GetTime and GetTime() or 0
    self:StoreCharacterIntel(data)
    self:BroadcastInspectedIntel(data)
end

function Raid:PLAYER_TALENT_UPDATE()
    self:BroadcastCharacterProfile()
end

function Raid:InitializeCharacterIntel()
    for _, data in pairs(self.db.characterIntel or {}) do
        if type(data) == "table" then
            data.localUpdated = 0
            data.spec = NormalizeSpecialization(data.spec) or "Unknown"
        end
    end
    self:RegisterEvent("INSPECT_READY")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    if hooksecurefunc and NotifyInspect and not self.inspectHookInstalled then
        self.inspectHookInstalled = true
        hooksecurefunc("NotifyInspect", function()
            Raid.lastGlobalInspectAt = GetTime and GetTime() or 0
        end)
    end
    self.inspectFrame = CreateFrame("Frame")
    self.inspectFrame.elapsed = 0
    self.inspectFrame:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = frame.elapsed + elapsed
        if frame.elapsed < 2 then return end
        frame.elapsed = 0
        Raid:TryInspectNext()
    end)
end
