local _, Raid = ...
local Core = Raid.Core
local Copy = Core.Copy
local classNames = Core.classNames
local simulatedNames = Core.simulatedNames
local simulatedByRole = Core.simulatedByRole
local SlotLabel = Core.SlotLabel

function Raid:QueueMessage(channel, target, text, allowHyperlinks)
    local prefix = "[LunaRaids]"
    text = tostring(text or "")
    if not allowHyperlinks then
        text = text:gsub("|", "/")
    end
    if text:sub(1, #prefix) ~= prefix then
        text = prefix .. " " .. text
    end
    self.messageQueue[#self.messageQueue + 1] = {
        channel = channel, target = target, text = text,
    }
end

function Raid:QueueEntryLines(channel, target, prefix, entries)
    local line = prefix
    for _, entry in ipairs(entries or {}) do
        local separator = line == prefix and "" or ", "
        if #line + #separator + #entry > 220 then
            self:QueueMessage(channel, target, line)
            line = prefix .. entry
        else
            line = line .. separator .. entry
        end
    end
    if line ~= prefix then
        self:QueueMessage(channel, target, line)
    end
end

function Raid:StartMessageQueue()
    if #self.messageQueue == 0 then return end
    self.messageFrame:Show()
end

function Raid:GetGroupChannel()
    if self:IsSimulating() then return "RAID_WARNING" end
    local configured = self.db.announcementChannel or "AUTO"
    if configured ~= "AUTO" then
        if configured == "RAID_WARNING"
            and not self:IsInLiveRaid()
        then
            return "PARTY"
        elseif configured == "RAID_WARNING"
            and not self:IsLocalRaidEditor()
        then
            return "RAID"
        end
        return configured
    end
    if self:IsInLiveRaid() then
        return self:CanUseRaidControls() and "RAID_WARNING" or "RAID"
    elseif self:IsInLiveGroup() then
        return "PARTY"
    end
    return "SAY"
end

function Raid:AnnounceAssignments(channelOverride)
    if not self:CanUseRaidControls() then return end
    wipe(self.messageQueue)
    local channel = channelOverride or self:GetGroupChannel()
    local encounter = self:GetEncounter()
    local plan = self:GetPlan(false) or {}
    local count = 0
    if encounter.name == "Raid Overview" then
        local markedTargets = self:GetMarkedTargetEntries()
        if #markedTargets > 0 then
            self:QueueEntryLines(
                channel, nil, "Trash Marks: ", markedTargets)
            count = count + #markedTargets
        end
    end
    for groupIndex, group in ipairs(self:GetEncounterGroups(encounter)) do
        local prefix = group.name .. ": "
        local entries = {}
        for slotIndex, slot in ipairs(
            self:GetEncounterGroupSlots(groupIndex, encounter)) do
            local assignment = plan[self:SlotKey(groupIndex, slotIndex)]
            if assignment and not (
                encounter.name ~= "Raid Overview"
                and group.name == "Healing")
            then
                local slotLabel = SlotLabel(slot)
                local markerToken =
                    self:GetMarkerTokenForText(slotLabel)
                entries[#entries + 1] =
                    (markerToken ~= "" and markerToken .. " " or "")
                    .. slotLabel .. "=" .. assignment.name
                count = count + 1
            end
        end
        self:QueueEntryLines(channel, nil, prefix, entries)
    end
    local healingTargets = self:GetHealingTargets()
    local healingEntries = {}
    for slotIndex = 1, self:GetHealingSlotCount() do
        local assignment = self:GetHealingAssignment(slotIndex)
        if assignment then
            local target = healingTargets[
                self:GetHealingTargetIndex(slotIndex)]
            local targetLabel = self:GetHealingTargetLabel(target)
            local markerToken =
                self:GetMarkerTokenForText(targetLabel)
            healingEntries[#healingEntries + 1] =
                assignment.name .. " -> "
                .. (markerToken ~= "" and markerToken .. " " or "")
                .. targetLabel
            count = count + 1
        end
    end
    if #healingEntries > 0 then
        self:QueueEntryLines(
            channel, nil, "Healing: ", healingEntries)
    end
    if count == 0 then
        wipe(self.messageQueue)
        self:Print(self.L.ASSIGN_BEFORE_ANNOUNCING)
        return
    end
    self:StartMessageQueue()
end

function Raid:WhisperAssignments()
    if not self:RequireRaidEditor() then return end
    wipe(self.messageQueue)
    local encounter = self:GetEncounter()
    local plan = self:GetPlan(false) or {}
    local byPlayer = {}
    for groupIndex, group in ipairs(self:GetEncounterGroups(encounter)) do
        for slotIndex, slot in ipairs(
            self:GetEncounterGroupSlots(groupIndex, encounter)) do
            local assignment = plan[self:SlotKey(groupIndex, slotIndex)]
            if assignment and not (
                encounter.name ~= "Raid Overview"
                and group.name == "Healing")
            then
                byPlayer[assignment.name] = byPlayer[assignment.name] or {}
                local role = SlotLabel(slot)
                local markerToken = self:GetMarkerTokenForText(role)
                byPlayer[assignment.name][#byPlayer[assignment.name] + 1] =
                    (markerToken ~= "" and markerToken .. " " or "") .. role
            end
        end
    end
    local healingTargets = self:GetHealingTargets()
    for slotIndex = 1, self:GetHealingSlotCount() do
        local assignment = self:GetHealingAssignment(slotIndex)
        if assignment then
            local target = healingTargets[
                self:GetHealingTargetIndex(slotIndex)]
            byPlayer[assignment.name] =
                byPlayer[assignment.name] or {}
            local role = "Heal " ..
                self:GetHealingTargetLabel(target)
            local markerToken = self:GetMarkerTokenForText(role)
            byPlayer[assignment.name][
                #byPlayer[assignment.name] + 1] =
                (markerToken ~= "" and markerToken .. " " or "") .. role
        end
    end
    local count = 0
    for name, roles in pairs(byPlayer) do
        self:QueueEntryLines("WHISPER", name, "", roles)
        count = count + 1
    end
    if count == 0 then
        self:Print(self.L.ASSIGN_BEFORE_WHISPERING)
        return
    end
    self:StartMessageQueue()
end

