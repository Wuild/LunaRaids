local ADDON, Raid = ...

Raid = LibStub("AceAddon-3.0"):NewAddon(
    Raid, ADDON, "AceConsole-3.0", "AceEvent-3.0")

Raid.Role = {
    TANK = "TANK",
    HEALER = "HEALER",
    DAMAGE = "DAMAGER",
}

Raid.AssignmentType = {
    TANK = "TANK",
    HEALER = "HEALER",
    DAMAGE = "DAMAGE",
    UTILITY = "UTILITY",
}

Raid.AssignmentTarget = {
    MAIN_TANK = "MAIN_TANK",
    OFF_TANK = "OFF_TANK",
    TANKS = "TANKS",
    RAID = "RAID",
}

local function Slug(value)
    return value:lower():gsub("[^%w]+", "_"):gsub("^_+", ""):gsub("_+$", "")
end

local function Slot(id, label, role, assignmentType, target, index)
    return {
        id = id,
        label = label,
        role = role,
        type = assignmentType,
        target = target,
        index = index,
    }
end

function Raid:GetSlotLabel(slot)
    return type(slot) == "table" and slot.label or tostring(slot or "")
end

local groupRoles = {
    Tanks = Raid.Role.TANK,
    Healing = Raid.Role.HEALER,
    Damage = Raid.Role.DAMAGE,
}

local function Slots(label, count, role, assignmentType, target)
    local result = {}
    for index = 1, count do
        local display = count == 1 and label or (label .. " " .. index)
        result[index] = Slot(
            Slug(label) .. "." .. index,
            display,
            role or Raid.Role.DAMAGE,
            assignmentType or Raid.AssignmentType.UTILITY,
            target,
            index)
    end
    return result
end

local function Mechanic(description)
    if type(description) ~= "string" or description == "" then
        error("Mechanic requires a non-empty description.", 2)
    end
    return description
end

local function Encounter(name, groups, targets, defaultMarkers, details)
    details = details or {}
    local populated = {}
    for _, group in ipairs(groups or {}) do
        if group.slots and #group.slots > 0 then
            populated[#populated + 1] = group
        end
    end
    return {
        name = name,
        groups = populated,
        targets = targets,
        defaultMarkers = defaultMarkers,
        mechanics = details.mechanics,
        icon = details.icon,
        spellIcon = details.spellIcon,
        encounterNames = details.encounterNames,
    }
end

local function Group(name, slots)
    local role = groupRoles[name] or Raid.Role.DAMAGE
    local assignmentType = name == "Tanks" and Raid.AssignmentType.TANK
        or name == "Healing" and Raid.AssignmentType.HEALER
        or name == "Damage" and Raid.AssignmentType.DAMAGE
        or Raid.AssignmentType.UTILITY
    local normalized = {}
    for _, value in ipairs(slots or {}) do
        local label = type(value) == "table"
            and value.label or tostring(value)
        if not (
            assignmentType == Raid.AssignmentType.UTILITY
            and label:lower():find("caller", 1, true)
        ) then
            local index = #normalized + 1
            if type(value) == "table" and value.id and value.label then
                normalized[index] = {}
                for key, field in pairs(value) do
                    normalized[index][key] = field
                end
                normalized[index].id = Slug(name) .. "." .. value.id
            else
                normalized[index] = Slot(
                    Slug(name) .. "." .. Slug(label) .. "." .. index,
                    label, role, assignmentType, nil, index)
            end
        end
    end
    return {
        name = name,
        role = role,
        type = assignmentType,
        slots = normalized,
    }
end

local function Boss(
    name, tanks, utility, healerCount, targets, defaultMarkers, details)
    local groups = {
        Group("Tanks", tanks or { Raid.Assignment.TANK.MAIN }),
        Group("Healing", Raid.Assignment:Healers(healerCount or 8)),
    }
    if utility and #utility > 0 then
        groups[#groups + 1] = Group("Utility", utility)
    end
    return Encounter(name, groups, targets, defaultMarkers, details)
end

Raid.expansions = {
    { key = "TBC", name = "The Burning Crusade" },
    { key = "VANILLA", name = "Vanilla" },
}

Raid.DataSlots = Slots
Raid.DataSlot = Slot
Raid.DataMechanic = Mechanic
Raid.DataEncounter = Encounter
Raid.DataGroup = Group
Raid.DataBoss = Boss

Raid.Assignment = {
    Role = Raid.Role,
    Type = Raid.AssignmentType,
    Target = Raid.AssignmentTarget,
}

local Assignment = Raid.Assignment
Assignment.TANK = {
    MAIN = Slot(
        "tank.main", "Main Tank", Raid.Role.TANK,
        Raid.AssignmentType.TANK, Raid.AssignmentTarget.MAIN_TANK),
    OFF = Slot(
        "tank.off", "Off Tank", Raid.Role.TANK,
        Raid.AssignmentType.TANK, Raid.AssignmentTarget.OFF_TANK),
    THIRD = Slot(
        "tank.third", "Third Tank", Raid.Role.TANK,
        Raid.AssignmentType.TANK, Raid.AssignmentTarget.TANKS, 3),
}
Assignment.HEALER = {
    TANK = Slot(
        "healer.tanks", "Tank Healer", Raid.Role.HEALER,
        Raid.AssignmentType.HEALER, Raid.AssignmentTarget.TANKS),
    MAIN_TANK = Slot(
        "healer.main_tank", "Main Tank Healer", Raid.Role.HEALER,
        Raid.AssignmentType.HEALER, Raid.AssignmentTarget.MAIN_TANK),
    OFF_TANK = Slot(
        "healer.off_tank", "Off Tank Healer", Raid.Role.HEALER,
        Raid.AssignmentType.HEALER, Raid.AssignmentTarget.OFF_TANK),
    RAID = Slot(
        "healer.raid", "Raid Healer", Raid.Role.HEALER,
        Raid.AssignmentType.HEALER, Raid.AssignmentTarget.RAID),
}

function Assignment:Tank(id, label, index)
    return Slot(
        "tank." .. id .. (index and ("." .. index) or ""),
        label, Raid.Role.TANK, Raid.AssignmentType.TANK,
        Raid.AssignmentTarget.TANKS, index)
end

function Assignment:Healer(target, index, label)
    target = target or Raid.AssignmentTarget.RAID
    local targetID = target:lower()
    label = label
        or target == Raid.AssignmentTarget.MAIN_TANK and "Main Tank Healer"
        or target == Raid.AssignmentTarget.OFF_TANK and "Off Tank Healer"
        or target == Raid.AssignmentTarget.RAID and "Raid Healer"
        or "Tank Healer"
    local suffix = index and ("." .. index) or ""
    local display = index and (label .. " " .. index) or label
    return Slot(
        "healer." .. targetID .. "." .. Slug(label) .. suffix,
        display, Raid.Role.HEALER, Raid.AssignmentType.HEALER,
        target, index)
end

function Assignment:Healers(count, target, label)
    local result = {}
    for index = 1, count do
        result[index] = self:Healer(target, index, label or "Healer")
    end
    return result
end

function Assignment:Utility(id, label, index)
    return Slot(
        "utility." .. id .. (index and ("." .. index) or ""),
        label, Raid.Role.DAMAGE, Raid.AssignmentType.UTILITY,
        nil, index)
end

function Assignment:ClassUtility(id, label, classes, index)
    local slot = self:Utility(id, label, index)
    slot.allowedClasses = {}
    for _, class in ipairs(classes or {}) do
        slot.allowedClasses[class] = true
    end
    return slot
end

Raid.raids = {}
Raid.raidByKey = {}

function Raid:RegisterRaid(definition)
    if type(definition) ~= "table" then
        error("RegisterRaid requires a raid definition table.", 2)
    end
    if type(definition.key) ~= "string" or definition.key == "" then
        error("RegisterRaid requires a non-empty raid key.", 2)
    end
    if self.raidByKey[definition.key] then
        error("Duplicate LunaRaids raid key: " .. definition.key, 2)
    end
    if type(definition.name) ~= "string"
        or type(definition.expansion) ~= "string"
        or type(definition.encounters) ~= "table"
    then
        error("Invalid LunaRaids raid definition: " .. definition.key, 2)
    end
    for encounterIndex, encounter in ipairs(definition.encounters) do
        encounter.icon = encounter.icon or definition.icon
        local slotIDs = {}
        for _, group in ipairs(encounter.groups or {}) do
            for _, assignment in ipairs(group.slots or {}) do
                if type(assignment) ~= "table"
                    or not assignment.id or not assignment.label
                    or not assignment.role or not assignment.type
                then
                    error(("Invalid assignment in %s encounter %d."):format(
                        definition.key, encounterIndex), 2)
                end
                if slotIDs[assignment.id] then
                    error(("Duplicate assignment id '%s' in %s / %s."):format(
                        assignment.id, definition.key,
                        encounter.name or encounterIndex), 2)
                end
                slotIDs[assignment.id] = true
            end
        end
    end
    self.raids[#self.raids + 1] = definition
    self.raidByKey[definition.key] = definition
    return definition
end
