local ADDON, Raid = ...

Raid = LibStub("AceAddon-3.0"):NewAddon(
    Raid, ADDON, "AceConsole-3.0", "AceEvent-3.0")

-- One structural colour for the complete addon UI.
-- Blue: { .20, .62, .82 }  Gold alternative: { .82, .64, .22 }
Raid.UIThemeAccent = { .20, .62, .82 }

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
        autoMarkerTargets = details.autoMarkerTargets,
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
    {
        key = "MOP", name = "Mists of Pandaria",
        logo = "Interface\\Glues\\Common\\Glues-WoW-MPLogo",
    },
    {
        key = "CATA", name = "Cataclysm",
        logo = "Interface\\AddOns\\LunaRaids\\Assets\\Expansions\\cataclysm",
    },
    {
        key = "WOTLK", name = "Wrath of the Lich King",
        logo = "Interface\\Glues\\Common\\Glues-WoW-WotLKLogo",
    },
    {
        key = "TBC", name = "The Burning Crusade",
        logo = "Interface\\Glues\\Common\\Glues-WoW-BCLogo",
    },
    {
        key = "VANILLA", name = "Vanilla",
        logo = "Interface\\Glues\\Common\\Glues-WoW-Logo",
    },
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

function Assignment:Healer(target, index, label, targetLabel)
    target = target or Raid.AssignmentTarget.RAID
    local targetID = target:lower()
    label = label
        or target == Raid.AssignmentTarget.MAIN_TANK and "Main Tank Healer"
        or target == Raid.AssignmentTarget.OFF_TANK and "Off Tank Healer"
        or target == Raid.AssignmentTarget.RAID and "Raid Healer"
        or "Tank Healer"
    local suffix = index and ("." .. index) or ""
    local display = index and (label .. " " .. index) or label
    local slot = Slot(
        "healer." .. targetID .. "." .. Slug(label) .. suffix,
        display, Raid.Role.HEALER, Raid.AssignmentType.HEALER,
        target, index)
    slot.targetLabel = targetLabel
    return slot
end

function Assignment:Healers(count, target, label, tankHealerCount)
    local result = {}
    local useDefaultCoverage = target == nil and label == nil
    if useDefaultCoverage then
        tankHealerCount = tonumber(tankHealerCount)
            or count >= 10 and 3
            or count >= 5 and 2
            or 1
        tankHealerCount = math.max(
            0, math.min(count, tankHealerCount))
    end
    for index = 1, count do
        local slot = self:Healer(target, index, label or "Healer")
        if useDefaultCoverage then
            if index <= tankHealerCount then
                slot.label = tankHealerCount == 1
                    and "Tank Healer"
                    or ("Tank Healer " .. index)
                slot.target = Raid.AssignmentTarget.TANKS
            else
                local raidIndex = index - tankHealerCount
                slot.label = "Raid Healer " .. raidIndex
                slot.target = Raid.AssignmentTarget.RAID
            end
        end
        result[index] = slot
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

local function RecommendationWeights(values, base, step, normalize)
    local result = {}
    if type(values) ~= "table" then return result end
    for index, value in ipairs(values) do
        local key = normalize and normalize(value) or value
        if key and key ~= "" then
            result[key] = math.max(1000, base - ((index - 1) * step))
        end
    end
    for key, value in pairs(values) do
        if type(key) == "string" and tonumber(value) then
            key = normalize and normalize(key) or key
            result[key] = tonumber(value)
        end
    end
    return result
end

function Assignment:Recommended(slot, recommendations)
    if type(slot) ~= "table" then return slot end
    local result = {}
    for key, value in pairs(slot) do
        if type(value) == "table" then
            result[key] = {}
            for child, childValue in pairs(value) do
                result[key][child] = childValue
            end
        else
            result[key] = value
        end
    end
    recommendations = recommendations or {}
    result.recommendedClasses = RecommendationWeights(
        recommendations.classes, 20000, 1500)
    result.recommendedSpecs = RecommendationWeights(
        recommendations.specs, 24000, 1500,
        function(value) return tostring(value or ""):lower() end)
    result.recommendedRoles = {}
    for _, role in ipairs(recommendations.roles or {}) do
        result.recommendedRoles[role] = true
    end
    result.allowReuse = recommendations.allowReuse == true
    return result
end

function Raid:ApplyAssignmentRecommendations(slot, recommendations)
    if type(slot) ~= "table" or type(recommendations) ~= "table" then
        return slot
    end
    local recommended = Assignment:Recommended(slot, recommendations)
    slot.recommendedClasses = recommended.recommendedClasses
    slot.recommendedSpecs = recommended.recommendedSpecs
    slot.recommendedRoles = recommended.recommendedRoles
    slot.allowReuse = recommended.allowReuse
    return slot
end

function Raid.Recommendation(match, classes, specs, options)
    options = options or {}
    return {
        match = match,
        classes = classes,
        specs = specs,
        roles = options.roles,
        allowReuse = options.allowReuse,
        encounter = options.encounter,
    }
end

local function ApplyRaidRecommendations(
    recommendations, encounterName, slot, group)
    if type(recommendations) ~= "table" or type(slot) ~= "table" then
        return
    end
    local text = ((group and group.name or "") .. " "
        .. tostring(slot.label or "")):lower()
    for _, rule in ipairs(recommendations) do
        local encounterMatches = not rule.encounter
            or rule.encounter == encounterName
        local ordinaryHealingSlot = slot.role == Raid.Role.HEALER
            and group and group.name == "Healing"
        if encounterMatches and not ordinaryHealingSlot
            and text:find(rule.match, 1, true)
        then
            Raid:ApplyAssignmentRecommendations(slot, rule)
            return
        end
    end
end

local function ApplyDefaultRecommendations(slot, group)
    if type(slot) ~= "table" then return end
    local text = ((group and group.name or "") .. " "
        .. tostring(slot.label or "")):lower()
    local classes, specs, roles
    local function Has(value) return text:find(value, 1, true) ~= nil end

    if slot.role == Raid.Role.HEALER then
        if Has("tank") then
            classes, specs = { "PALADIN", "PRIEST", "DRUID", "SHAMAN" },
                { "Holy", "Discipline", "Restoration" }
        else
            classes, specs = { "SHAMAN", "DRUID", "PRIEST", "PALADIN" },
                { "Restoration", "Holy", "Discipline" }
        end
    elseif Has("krosh") or Has("mage tank") then
        classes, specs, roles = { "MAGE" }, { "Fire", "Arcane" },
            { Raid.Role.DAMAGE }
    elseif Has("warlock tank") or Has("demon tank")
        or Has("alythess ranged tank")
    then
        classes, specs, roles = { "WARLOCK" },
            { "Destruction", "Demonology" }, { Raid.Role.DAMAGE }
    elseif Has("bow hunter tank") or Has("kiggler ranged tank") then
        classes, specs, roles = { "HUNTER" },
            { "Marksmanship", "Beast Mastery" }, { Raid.Role.DAMAGE }
    elseif Has("ranged tank") then
        classes, specs, roles = { "WARLOCK", "HUNTER", "MAGE" },
            { "Destruction", "Marksmanship", "Frost" },
            { Raid.Role.DAMAGE }
    elseif Has("enslave") or Has("felhunter") then
        classes, specs = { "WARLOCK" }, { "Demonology", "Affliction" }
    elseif Has("spellsteal") then
        classes, specs = { "MAGE" }, { "Arcane", "Fire", "Frost" }
    elseif Has("mind control") then
        classes, specs = { "PRIEST" }, { "Shadow", "Discipline", "Holy" }
    elseif Has("tranq") then
        classes, specs = { "HUNTER" },
            { "Marksmanship", "Beast Mastery", "Survival" }
    elseif Has("fear ward") then
        classes, specs = { "PRIEST" }, { "Discipline", "Holy", "Shadow" }
    elseif Has("mass dispel") then
        classes, specs = { "PRIEST" }, { "Discipline", "Holy", "Shadow" }
    elseif Has("decurse") or Has("curse dispel")
        or Has("curse cleanse")
    then
        classes, specs = { "MAGE", "DRUID" },
            { "Restoration", "Balance", "Feral", "Arcane" }
    elseif Has("poison") then
        classes, specs = { "SHAMAN", "DRUID", "PALADIN" },
            { "Restoration", "Holy", "Balance", "Protection" }
    elseif Has("disease") then
        classes, specs = { "PRIEST", "PALADIN", "SHAMAN" },
            { "Discipline", "Holy", "Restoration" }
    elseif Has("purge") then
        classes, specs = { "SHAMAN", "PRIEST" },
            { "Elemental", "Enhancement", "Shadow", "Discipline" }
    elseif Has("dispel") or Has("cleanse") then
        classes, specs = { "PRIEST", "PALADIN", "SHAMAN" },
            { "Discipline", "Holy", "Restoration", "Shadow" }
    elseif Has("interrupt") then
        classes, specs = { "ROGUE", "SHAMAN", "MAGE", "WARRIOR",
            "PALADIN" },
            { "Combat", "Enhancement", "Elemental", "Fury", "Arms" }
    elseif Has("banish") then
        classes, specs = { "WARLOCK" },
            { "Affliction", "Demonology", "Destruction" }
    elseif Has("polymorph") then
        classes, specs = { "MAGE" }, { "Frost", "Arcane", "Fire" }
    elseif Has("root") then
        classes, specs = { "DRUID", "MAGE" },
            { "Balance", "Restoration", "Frost" }
    elseif Has("stun") then
        classes, specs = { "ROGUE", "WARRIOR", "PALADIN" },
            { "Combat", "Arms", "Protection", "Retribution" }
    elseif Has("kiter") or Has("kite") then
        classes, specs = { "HUNTER", "MAGE", "WARLOCK" },
            { "Frost", "Marksmanship", "Affliction" }
    elseif Has("crowd control") or Has(" cc") or Has(" control") then
        classes, specs = { "MAGE", "HUNTER", "WARLOCK", "ROGUE",
            "PRIEST" },
            { "Frost", "Survival", "Affliction", "Shadow" }
    elseif Has("aoe") then
        classes, specs = { "MAGE", "WARLOCK", "PALADIN", "SHAMAN" },
            { "Fire", "Frost", "Destruction", "Protection", "Elemental" }
    end

    if next(slot.recommendedClasses or {}) == nil and classes then
        slot.recommendedClasses = RecommendationWeights(
            classes, 20000, 1500)
    end
    if next(slot.recommendedSpecs or {}) == nil and specs then
        slot.recommendedSpecs = RecommendationWeights(
            specs, 24000, 1500,
            function(value) return tostring(value or ""):lower() end)
    end
    if next(slot.recommendedRoles or {}) == nil and roles then
        slot.recommendedRoles = {}
        for _, role in ipairs(roles) do slot.recommendedRoles[role] = true end
    end
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
        local supplementalGuide = definition.guides
            and definition.guides[encounter.name]
        if supplementalGuide then
            encounter.mechanics = encounter.mechanics or {}
            for _, mechanic in ipairs(supplementalGuide) do
                encounter.mechanics[#encounter.mechanics + 1] = mechanic
            end
        end
        local slotIDs = {}
        for _, group in ipairs(encounter.groups or {}) do
            for _, assignment in ipairs(group.slots or {}) do
                ApplyRaidRecommendations(definition.recommendations,
                    encounter.name, assignment, group)
                ApplyDefaultRecommendations(assignment, group)
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
