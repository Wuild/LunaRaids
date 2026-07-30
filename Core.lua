local ADDON, Raid = ...

Raid.name = ADDON
Raid.version = "0.1.0"
Raid.roster = {}
Raid.messageQueue = {}
Raid.simulation = { enabled = false, size = 0 }
Raid.markers = {
    { name = "Skull", icon = 8 },
    { name = "Cross", icon = 7 },
    { name = "Square", icon = 6 },
    { name = "Moon", icon = 5 },
    { name = "Triangle", icon = 4 },
    { name = "Diamond", icon = 3 },
    { name = "Circle", icon = 2 },
    { name = "Star", icon = 1 },
}

local simulatedNames = {
    "Aelwyn", "Brannoc", "Caelia", "Dorn", "Elowen",
    "Fenric", "Gavri", "Helja", "Isolde", "Jorund",
    "Kaelen", "Liora", "Marek", "Nyssa", "Orin",
    "Pyrra", "Quint", "Runa", "Soren", "Talia",
    "Ulric", "Veyra", "Wulfric", "Xara", "Yorik",
    "Zinnia", "Arthus", "Brynja", "Corvin", "Delia",
    "Eirik", "Freya", "Garran", "Hilda", "Ivar",
    "Jaina", "Korr", "Lyra", "Magnus", "Neria",
}

local simulatedCharacters = {
    { "WARRIOR", "Human", "TANK" },
    { "WARRIOR", "Orc", "TANK" },
    { "DRUID", "Night Elf", "TANK" },
    { "PALADIN", "Draenei", "HEALER" },
    { "PRIEST", "Dwarf", "HEALER" },
    { "SHAMAN", "Tauren", "HEALER" },
    { "DRUID", "Tauren", "HEALER" },
    { "PRIEST", "Blood Elf", "HEALER" },
    { "PALADIN", "Human", "HEALER" },
    { "SHAMAN", "Draenei", "HEALER" },
    { "MAGE", "Gnome", "DAMAGER" },
    { "MAGE", "Undead", "DAMAGER" },
    { "WARLOCK", "Orc", "DAMAGER" },
    { "WARLOCK", "Gnome", "DAMAGER" },
    { "ROGUE", "Human", "DAMAGER" },
    { "ROGUE", "Troll", "DAMAGER" },
    { "HUNTER", "Night Elf", "DAMAGER" },
    { "HUNTER", "Orc", "DAMAGER" },
    { "HUNTER", "Dwarf", "DAMAGER" },
    { "SHAMAN", "Troll", "DAMAGER" },
    { "PALADIN", "Blood Elf", "DAMAGER" },
    { "DRUID", "Night Elf", "DAMAGER" },
    { "PRIEST", "Undead", "DAMAGER" },
}

local simulatedByRole = {
    TANK = {}, HEALER = {}, DAMAGER = {},
}
for _, character in ipairs(simulatedCharacters) do
    simulatedByRole[character[3]][
        #simulatedByRole[character[3]] + 1] = character
end

local classNames = {
    WARRIOR = "Warrior", PALADIN = "Paladin",
    HUNTER = "Hunter", ROGUE = "Rogue",
    PRIEST = "Priest", SHAMAN = "Shaman",
    MAGE = "Mage", WARLOCK = "Warlock", DRUID = "Druid",
}

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = Copy(child) end
    return result
end

local function Merge(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = Copy(value)
        elseif type(value) == "table" and type(target[key]) == "table" then
            Merge(target[key], value)
        end
    end
end

local defaults = {
    schemaVersion = 1,
    activeExpansion = "TBC",
    activeRaid = "karazhan",
    activeEncounter = 1,
    currentBossByRaid = {},
    lastRaidByExpansion = {},
    lastEncounterByRaid = {},
    roleOverrides = {},
    raidCompositions = {},
    bossOverrides = {},
    bossPresets = {},
    characterIntel = {},
    savedRaids = {},
    manualPlayers = {},
    raidLocked = false,
    newRaidExpansion = "TBC",
    plans = {},
    window = {
        point = "CENTER", x = 0, y = 0,
        width = 980, height = 760,
    },
    quickBar = {
        point = "CENTER", x = 0, y = 0, hide = false,
        iconOnly = false, visibility = "GROUP",
        hideInCombat = true,
    },
    readyCheck = {
        point = "CENTER", x = 0, y = 120,
        holdDuration = 15,
        showWindow = true,
    },
    assignmentInfo = {
        point = "CENTER", x = 300, y = 40,
        width = 360,
        hide = false,
    },
    raidCooldowns = {
        enabled = true,
        point = "CENTER", x = -330, y = 20,
        style = "MINIMAL",
        spells = {},
        active = {},
        expanded = {},
        layout = "ROWS",
        sortMode = "SPELL",
        classColors = true,
        readyColor = { .18, .9, .55 },
        cooldownColor = { 1, .32, .24 },
        scale = 1,
        hudOpacity = .82,
        locked = false,
        showAbilityName = true,
        showAbilityTotal = true,
        visibility = "GROUP",
    },
    raidAdmin = {
        autoInvite = false,
        inviteKeywords = "inv, invite",
        autoPromote = false,
        promoteNames = "",
        promoteGuildRanks = {},
        manageLoot = false,
        lootMethod = "group",
        lootThreshold = 2,
        masterLooter = "",
    },
    minimap = { minimapPos = 225, hide = false },
    announcementChannel = "AUTO",
    messageDelay = .45,
}

function Raid:Print(message)
    print("|cff33b8ffLunaRaids|r  " .. tostring(message))
end

function Raid:RequireRaidEditor()
    if self.IsLocalRaidEditor and self:IsLocalRaidEditor() then
        return true
    end
    self:Print(
        "This raid is view only. Only the raid leader and assistants can edit it.")
    return false
end

function Raid:CanEditRaidGroups()
    if IsInRaid and IsInRaid() then
        return UnitIsGroupLeader
                and UnitIsGroupLeader("player")
            or UnitIsGroupAssistant
                and UnitIsGroupAssistant("player")
            or IsRaidLeader and IsRaidLeader()
            or IsRaidOfficer and IsRaidOfficer()
            or false
    end
    return self.simulation and self.simulation.enabled or false
end

function Raid:RequireRaidGroupEditor()
    if self:CanEditRaidGroups() then return true end
    self:Print(
        "Only the raid leader and assistants can change raid groups.")
    return false
end

function Raid:IsActualRaidLeader()
    return IsInRaid and IsInRaid()
        and ((UnitIsGroupLeader and UnitIsGroupLeader("player"))
            or (IsRaidLeader and IsRaidLeader())
            or false)
end

function Raid:IsRosterPlayerSelf(player)
    if not player then return false end
    if player.unit == "player" then return true end
    return UnitIsUnit and player.unit
        and UnitIsUnit(player.unit, "player") or false
end

function Raid:PromoteRosterPlayer(player)
    if not self:IsActualRaidLeader() or not player or player.manual
        or player.simulated or self:IsRosterPlayerSelf(player)
    then
        self:Print("Only the raid leader can promote live raid members.")
        return
    end
    if type(PromoteToAssistant) ~= "function"
        or not pcall(PromoteToAssistant, player.name, true)
    then
        self:Print("The client rejected the assistant promotion.")
    end
end

function Raid:DemoteRosterPlayer(player)
    if not self:IsActualRaidLeader() or not player or player.manual
        or player.simulated or self:IsRosterPlayerSelf(player)
    then
        self:Print("Only the raid leader can demote live raid members.")
        return
    end
    if type(DemoteAssistant) ~= "function"
        or not pcall(DemoteAssistant, player.name)
    then
        self:Print("The client rejected the assistant demotion.")
    end
end

function Raid:TransferRaidLeader(player)
    if not self:IsActualRaidLeader() or not player or player.manual
        or player.simulated or self:IsRosterPlayerSelf(player)
    then
        self:Print("Only the raid leader can transfer raid leadership.")
        return
    end
    if type(PromoteToLeader) ~= "function"
        or not pcall(PromoteToLeader, player.name)
    then
        self:Print("The client rejected the raid leader transfer.")
    end
end

function Raid:RemoveRosterPlayer(player)
    if not player then return end
    if player.manual then
        self:RemoveManualPlayer(player.name)
        return
    end
    if not self:CanEditRaidGroups() or player.simulated
        or self:IsRosterPlayerSelf(player)
    then
        self:Print("Only raid leadership can remove live raid members.")
        return
    end
    local uninvite = C_PartyInfo and C_PartyInfo.UninviteUnit
        or UninviteUnit
    if type(uninvite) ~= "function"
        or not pcall(uninvite, player.name)
    then
        self:Print("The client rejected removing that raid member.")
    end
end

function Raid:GetPopupEditBox(popup)
    if not popup then return nil end
    if popup.editBox then return popup.editBox end
    if popup.EditBox then return popup.EditBox end
    if type(popup.GetEditBox) == "function" then
        local ok, editBox = pcall(popup.GetEditBox, popup)
        if ok and editBox then return editBox end
    end
    if popup.GetChildren then
        for _, child in ipairs({ popup:GetChildren() }) do
            if child.GetObjectType
                and child:GetObjectType() == "EditBox"
            then
                return child
            end
        end
    end
    return nil
end

function Raid:PrepareDatabase(database)
    if rawget(database, "schemaVersion") ~= defaults.schemaVersion then
        for key in pairs(database) do
            database[key] = nil
        end
    end
    Merge(database, defaults)
    database.schemaVersion = defaults.schemaVersion
end

function Raid:InitializeDatabase()
    self.database = LibStub("AceDB-3.0"):New(
        "LunaRaidsDB", { global = defaults }, true)
    self.db = self.database.global
    self:PrepareDatabase(self.db)
    self:NormalizeDatabase()
end

function Raid:ResetAllSettings()
    local keys = {
        "window", "quickBar", "readyCheck", "assignmentInfo",
        "raidCooldowns", "raidAdmin", "minimap",
        "announcementChannel", "messageDelay",
    }
    for _, key in ipairs(keys) do
        local source = defaults[key]
        if type(source) == "table" then
            self.db[key] = self.db[key] or {}
            for child in pairs(self.db[key]) do
                self.db[key][child] = nil
            end
            for child, value in pairs(source) do
                self.db[key][child] = Copy(value)
            end
        else
            self.db[key] = Copy(source)
        end
    end
    local function Position(frame, saved)
        if not frame or not saved then return end
        frame:ClearAllPoints()
        frame:SetPoint(
            saved.point or "CENTER", UIParent,
            saved.point or "CENTER", saved.x or 0, saved.y or 0)
    end
    if self.frame then
        Position(self.frame, self.db.window)
        self.frame:SetSize(
            self.db.window.width, self.db.window.height)
    end
    Position(self.quickActionBar, self.db.quickBar)
    Position(self.readyCheckWindow, self.db.readyCheck)
    Position(self.personalAssignmentFrame, self.db.assignmentInfo)
    if self.personalAssignmentFrame then
        self.personalAssignmentFrame:SetWidth(
            self.db.assignmentInfo.width)
    end
    Position(self.raidCooldownFrame, self.db.raidCooldowns)
    self.raidCooldownState = self.db.raidCooldowns.active
    self.localRaidCooldownWire = {}
    if self.dbIcon and self.dbIcon.Refresh then
        self.dbIcon:Refresh("LunaRaids", self.db.minimap)
    end
    if self.RefreshMinimapButton then self:RefreshMinimapButton() end
    if self.RefreshQuickActionBar then self:RefreshQuickActionBar() end
    if self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
    if self.RefreshRaidCooldowns then self:RefreshRaidCooldowns() end
    if self.UpdateWindowLayout then self:UpdateWindowLayout() end
    if self.RefreshSettingsView then self:RefreshSettingsView() end
    self:Print("All addon settings and window positions were reset.")
end

function Raid:NormalizeDatabase()
    local restore = self.db.simulationRestore
    if type(restore) == "table" then
        self.db.activeExpansion =
            restore.activeExpansion or self.db.activeExpansion
        self.db.activeRaid =
            restore.activeRaid or self.db.activeRaid
        self.db.activeEncounter =
            restore.activeEncounter or self.db.activeEncounter
        self.db.lastRaidByExpansion =
            restore.lastRaidByExpansion
                or self.db.lastRaidByExpansion
        self.db.lastEncounterByRaid =
            restore.lastEncounterByRaid
                or self.db.lastEncounterByRaid
        self.db.simulationRestore = nil
    end
    if not self.raidByKey[self.db.activeRaid] then
        self.db.activeRaid = defaults.activeRaid
    end
    local activeRaid = self.raidByKey[self.db.activeRaid]
    self.db.activeExpansion =
        activeRaid and activeRaid.expansion
        or self.db.activeExpansion or defaults.activeExpansion
    self.db.lastRaidByExpansion[self.db.activeExpansion] =
        self.db.activeRaid
    self.db.activeEncounter = math.max(
        1, math.min(
            tonumber(self.db.activeEncounter) or 1,
            #activeRaid.encounters))
    self.db.lastEncounterByRaid[self.db.activeRaid] =
        self.db.activeEncounter
    if self.db.minimap.angle then
        self.db.minimap.minimapPos = self.db.minimap.angle
        self.db.minimap.angle = nil
    end
end

function Raid:GetRaid()
    local raid = self.raidByKey[self.db.activeRaid]
    if raid and raid.expansion == self.db.activeExpansion then
        self:ApplyRaidComposition(raid)
        return raid
    end
    local available = self:GetRaidsForExpansion()
    raid = available[1] or self.raids[1]
    self.db.activeRaid = raid.key
    self:ApplyRaidComposition(raid)
    return raid
end

local function SlotLabel(slot)
    return type(slot) == "table" and slot.label or tostring(slot or "")
end

local function CompositionSlots(self, label, count, defaultSlots, role)
    local slots = {}
    for index = 1, count do
        if defaultSlots and defaultSlots[index] then
            slots[index] = defaultSlots[index]
        elseif label == "Tank" then
            slots[index] = index == 1 and self.Assignment.TANK.MAIN
                or index == 2 and self.Assignment.TANK.OFF
                or self.Assignment:Tank(
                    tostring(index), ("Tank %d"):format(index), index)
        else
            slots[index] = self.DataSlot(
                label:lower() .. "." .. index,
                ("%s %d"):format(label, index),
                role, role == self.Role.HEALER
                    and self.AssignmentType.HEALER
                    or self.AssignmentType.DAMAGE,
                role == self.Role.HEALER
                    and self.AssignmentTarget.RAID or nil,
                index)
        end
    end
    return slots
end

function Raid:GetDefaultRaidComposition(raid)
    raid = raid or self.raidByKey[self.db.activeRaid]
    if not raid then return { tanks = 0, healers = 0, damage = 0 } end
    if raid.defaultComposition and raid.defaultRoleSlots then
        return raid.defaultComposition
    end
    local tanks, healers = 0, 0
    raid.defaultRoleSlots = {
        Tanks = {},
        Healing = {},
    }
    local overview = raid.encounters and raid.encounters[1]
    for _, group in ipairs(overview and overview.groups or {}) do
        if group.name == "Tanks" then
            tanks = #group.slots
            for index, label in ipairs(group.slots) do
                raid.defaultRoleSlots.Tanks[index] = label
            end
        elseif group.name == "Healing" then
            healers = #group.slots
            for index, label in ipairs(group.slots) do
                raid.defaultRoleSlots.Healing[index] = label
            end
        end
    end
    raid.defaultComposition = {
        tanks = tanks,
        healers = healers,
        damage = math.max(0, raid.size - tanks - healers),
    }
    return raid.defaultComposition
end

function Raid:GetRaidComposition(raidKey)
    local raid = self.raidByKey[raidKey or self.db.activeRaid]
    local defaultsForRaid = self:GetDefaultRaidComposition(raid)
    local override = self.db.raidCompositions[raid.key] or {}
    return {
        tanks = tonumber(override.tanks) or defaultsForRaid.tanks,
        healers = tonumber(override.healers) or defaultsForRaid.healers,
        damage = tonumber(override.damage) or defaultsForRaid.damage,
    }
end

function Raid:SetRaidCompositionCount(raidKey, role, value)
    if not self:RequireRaidEditor() then return end
    local raid = self.raidByKey[raidKey]
    if not raid then return end
    self.db.raidCompositions[raidKey] =
        self.db.raidCompositions[raidKey] or {}
    self.db.raidCompositions[raidKey][role] =
        math.max(0, math.min(raid.size, math.floor(value or 0)))
    self:ApplyRaidComposition(raid)
    if self.QueueSync and self:IsLocalRaidEditor() then
        self:QueueSync("COMP", {
            raidKey, role, self.db.raidCompositions[raidKey][role],
        })
    end
    if self.frame and raidKey == self.db.activeRaid then
        self:RefreshAssignments()
    end
end

function Raid:ResetRaidComposition(raidKey)
    if not self:RequireRaidEditor() then return end
    local raid = self.raidByKey[raidKey]
    if not raid then return end
    self.db.raidCompositions[raidKey] = nil
    self:ApplyRaidComposition(raid)
    if self.QueueSync and self:IsLocalRaidEditor() then
        local composition = self:GetRaidComposition(raidKey)
        for _, role in ipairs({ "tanks", "healers" }) do
            self:QueueSync("COMP", {
                raidKey, role, composition[role],
            })
        end
    end
    if self.frame and raidKey == self.db.activeRaid then
        self:RefreshAssignments()
    end
end

function Raid:ApplyRaidComposition(raid)
    if not raid or not raid.encounters or not raid.encounters[1] then return end
    local composition = self:GetRaidComposition(raid.key)
    local defaultsForRaid = raid.defaultRoleSlots
    local overview = raid.encounters[1]
    for _, group in ipairs(overview.groups) do
        if group.name == "Tanks" then
            group.slots = CompositionSlots(
                self, "Tank", composition.tanks,
                defaultsForRaid.Tanks, self.Role.TANK)
        elseif group.name == "Healing" then
            group.slots = CompositionSlots(
                self, "Healer", composition.healers,
                defaultsForRaid.Healing, self.Role.HEALER)
        end
    end
end

function Raid:GetRaidsForExpansion()
    local result = {}
    for _, raid in ipairs(self.raids) do
        if raid.expansion == self.db.activeExpansion then
            result[#result + 1] = raid
        end
    end
    return result
end

function Raid:GetEncounter()
    local raid = self:GetRaid()
    local index = math.max(1, math.min(
        tonumber(self.db.activeEncounter) or 1, #raid.encounters))
    self.db.activeEncounter = index
    self.db.lastEncounterByRaid[raid.key] = index
    return raid.encounters[index], index
end

function Raid:GetBossOverride(create, raidKey, encounterIndex)
    local raid = self.raidByKey[raidKey or self.db.activeRaid]
    if not raid then return nil end
    encounterIndex = tonumber(encounterIndex) or self.db.activeEncounter
    if create then
        self.db.bossOverrides[raid.key] =
            self.db.bossOverrides[raid.key] or {}
        self.db.bossOverrides[raid.key][encounterIndex] =
            self.db.bossOverrides[raid.key][encounterIndex]
            or { groups = {} }
        local result = self.db.bossOverrides[raid.key][encounterIndex]
        result.groups = result.groups or {}
        return result
    end
    return self.db.bossOverrides[raid.key]
        and self.db.bossOverrides[raid.key][encounterIndex]
end

function Raid:GetEncounterGroupSlots(
    groupIndex, encounter, raidKey, encounterIndex)
    encounter = encounter or self:GetEncounter()
    local group = encounter.groups[groupIndex]
    if not group then return {} end
    local override = self:GetBossOverride(
        false, raidKey, encounterIndex)
    local count = override and override.groups
        and tonumber(override.groups[groupIndex]) or #group.slots
    count = math.max(0, math.floor(count or #group.slots))
    local result = {}
    local singular = group.name:gsub("s$", "")
    for index = 1, count do
        result[index] = group.slots[index]
            or self.DataSlot(
                group.name:lower() .. "." .. index,
                singular .. " " .. index,
                group.role or self.Role.DAMAGE,
                group.type or self.AssignmentType.UTILITY,
                nil, index)
    end
    return result
end

function Raid:SetBossGroupCount(groupIndex, count)
    if not self:RequireRaidEditor() then return end
    local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
    local encounter = raid.encounters[encounterIndex]
    if not encounter.groups[groupIndex] then return end
    local override = self:GetBossOverride(true)
    override.groups[groupIndex] = math.max(
        0, math.min(raid.size, math.floor(tonumber(count) or 0)))
    if self.QueueSync and self:IsLocalRaidEditor() then
        self:QueueSync("BOSSSET", {
            raid.key, encounterIndex, "G:" .. groupIndex,
            override.groups[groupIndex],
        })
    end
    if self.RefreshAssignments then self:RefreshAssignments() end
end

function Raid:SetBossHealerCount(count)
    if not self:RequireRaidEditor() then return end
    local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
    local override = self:GetBossOverride(true)
    override.healers = math.max(
        0, math.min(raid.size, math.floor(tonumber(count) or 0)))
    if self.QueueSync and self:IsLocalRaidEditor() then
        self:QueueSync("BOSSSET", {
            raid.key, encounterIndex, "HEALERS", override.healers,
        })
    end
    if self.RefreshAssignments then self:RefreshAssignments() end
end

function Raid:ResetBossOverride()
    if not self:RequireRaidEditor() then return end
    local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
    if self.db.bossOverrides[raid.key] then
        self.db.bossOverrides[raid.key][encounterIndex] = nil
    end
    if self.QueueSync and self:IsLocalRaidEditor() then
        self:QueueSync("BOSSRESET", { raid.key, encounterIndex })
    end
    if self.RefreshAssignments then self:RefreshAssignments() end
end

function Raid:GetBossPresetCollection(create)
    local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
    if create then
        self.db.bossPresets[raid.key] =
            self.db.bossPresets[raid.key] or {}
        local collection = self.db.bossPresets[raid.key][encounterIndex]
        if type(collection) ~= "table"
            or type(collection.items) ~= "table"
        then
            collection = { items = {} }
            self.db.bossPresets[raid.key][encounterIndex] = collection
        end
        return collection
    end
    local collection = self.db.bossPresets[raid.key]
        and self.db.bossPresets[raid.key][encounterIndex]
    return type(collection) == "table"
        and type(collection.items) == "table" and collection or nil
end

function Raid:GetBossPresets()
    local collection = self:GetBossPresetCollection(false)
    local presets = {}
    for _, preset in pairs(collection and collection.items or {}) do
        if type(preset) == "table" and preset.id and preset.name
            and type(preset.settings) == "table"
        then
            presets[#presets + 1] = preset
        end
    end
    table.sort(presets, function(left, right)
        if (left.savedAt or 0) ~= (right.savedAt or 0) then
            return (left.savedAt or 0) > (right.savedAt or 0)
        end
        return left.name:lower() < right.name:lower()
    end)
    return presets
end

function Raid:GetSelectedBossPreset()
    local collection = self:GetBossPresetCollection(false)
    if not collection then return nil end
    local selected = collection.selected
        and collection.items[collection.selected]
    if selected then return selected end
    local presets = self:GetBossPresets()
    if presets[1] then
        collection.selected = presets[1].id
        return presets[1]
    end
end

function Raid:GetBossPreset()
    local preset = self:GetSelectedBossPreset()
    return preset and preset.settings or nil
end

function Raid:SelectBossPreset(presetID)
    local collection = self:GetBossPresetCollection(false)
    if not collection or not collection.items[presetID] then return false end
    collection.selected = presetID
    if self.RefreshBossSettingsPanel then
        self:RefreshBossSettingsPanel()
    end
    return true
end

function Raid:CycleBossPreset(delta)
    local presets = self:GetBossPresets()
    if #presets == 0 then return end
    local selected = self:GetSelectedBossPreset()
    local index = 1
    for presetIndex, preset in ipairs(presets) do
        if selected and preset.id == selected.id then
            index = presetIndex
            break
        end
    end
    index = ((index - 1 + (delta or 1)) % #presets) + 1
    self:SelectBossPreset(presets[index].id)
end

function Raid:SyncBossSettings(kind, settings)
    if not self.QueueSync or not self:IsLocalRaidEditor() then return end
    local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
    self:QueueSync(kind .. "RESET", { raid.key, encounterIndex })
    if settings and tonumber(settings.healers) then
        self:QueueSync(kind .. "SET", {
            raid.key, encounterIndex, "HEALERS", settings.healers,
        })
    end
    for groupIndex, count in pairs(settings and settings.groups or {}) do
        self:QueueSync(kind .. "SET", {
            raid.key, encounterIndex, "G:" .. groupIndex, count,
        })
    end
end

function Raid:SaveBossPreset(name)
    if not self:RequireRaidEditor() then return false end
    name = strtrim(name or "")
    if name == "" then
        self:Print("Enter a name for the boss assignment preset.")
        return false
    end
    local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
    local override = self:GetBossOverride(false)
    local settings = override and Copy(override) or { groups = {} }
    local collection = self:GetBossPresetCollection(true)
    local preset
    for _, candidate in pairs(collection.items) do
        if candidate.name and candidate.name:lower() == name:lower() then
            preset = candidate
            break
        end
    end
    if not preset then
        local stamp = GetServerTime and GetServerTime() or time()
        local id
        repeat
            self.bossPresetSequence = (self.bossPresetSequence or 0) + 1
            id = tostring(stamp) .. "-" .. self.bossPresetSequence
        until not collection.items[id]
        preset = { id = id }
        collection.items[id] = preset
    end
    preset.name = name
    preset.settings = settings
    preset.savedAt = GetServerTime and GetServerTime() or time()
    collection.selected = preset.id
    if self.RefreshBossSettingsPanel then self:RefreshBossSettingsPanel() end
    self:Print("Saved \"" .. name .. "\" for "
        .. self:GetEncounter().name .. ".")
    return true
end

function Raid:LoadBossPreset(presetID)
    if not self:RequireRaidEditor() then return false end
    local raid, encounterIndex = self:GetRaid(), select(2, self:GetEncounter())
    if presetID then self:SelectBossPreset(presetID) end
    local selected = self:GetSelectedBossPreset()
    local preset = selected and selected.settings
    if not preset then
        self:Print("No custom assignment setup has been saved for this boss.")
        return false
    end
    self.db.bossOverrides[raid.key] =
        self.db.bossOverrides[raid.key] or {}
    self.db.bossOverrides[raid.key][encounterIndex] = Copy(preset)
    self:SyncBossSettings("BOSS", preset)
    if self.RefreshAssignments then self:RefreshAssignments() end
    self:Print("Applied \"" .. selected.name .. "\" to "
        .. self:GetEncounter().name .. ".")
    return true
end

function Raid:DeleteBossPreset(presetID)
    if not self:RequireRaidEditor() then return false end
    local collection = self:GetBossPresetCollection(false)
    presetID = presetID
        or collection and collection.selected
    local preset = collection and collection.items[presetID]
    if not preset then return false end
    collection.items[presetID] = nil
    if collection.selected == presetID then collection.selected = nil end
    self:GetSelectedBossPreset()
    if self.RefreshBossSettingsPanel then self:RefreshBossSettingsPanel() end
    self:Print("Deleted \"" .. preset.name .. "\" from "
        .. self:GetEncounter().name .. ".")
    return true
end

function Raid:GetPlan(create)
    local raid = self:GetRaid()
    local _, encounterIndex = self:GetEncounter()
    local plans = self.simulation.enabled
        and self.simulation.plans or self.db.plans
    if create then
        plans[raid.key] = plans[raid.key] or {}
        plans[raid.key][encounterIndex] =
            plans[raid.key][encounterIndex] or {}
    end
    return plans[raid.key]
        and plans[raid.key][encounterIndex] or nil
end

function Raid:SlotKey(groupIndex, slotIndex)
    local encounter = self:GetEncounter()
    local slots = self:GetEncounterGroupSlots(groupIndex, encounter)
    local slot = slots[slotIndex]
    if slot and slot.id then
        return "S:" .. slot.id
    end
    return ("S:group.%d.slot.%d"):format(groupIndex, slotIndex)
end

function Raid:GetAssignment(groupIndex, slotIndex)
    local plan = self:GetPlan(false)
    return plan and plan[self:SlotKey(groupIndex, slotIndex)] or nil
end

function Raid:SetAssignment(groupIndex, slotIndex, player)
    if not self:RequireRaidEditor() then return false end
    local plan = self:GetPlan(true)
    local key = self:SlotKey(groupIndex, slotIndex)
    plan[key] = player and {
        name = player.name,
        class = player.class,
    } or nil
    if self.BroadcastPlanValue then
        self:BroadcastPlanValue(key, plan[key])
    end
    if self.db.activeEncounter == 1 and player then
        self:PropagateOverviewAssignments()
    end
    if self.RefreshAssignments then self:RefreshAssignments() end
    return true
end

local function SemanticSlotKey(slot, groupIndex, slotIndex)
    return slot and slot.id and ("S:" .. slot.id)
        or ("S:group.%d.slot.%d"):format(groupIndex, slotIndex)
end

function Raid:PropagateOverviewAssignments()
    local raid = self:GetRaid()
    local plans = self.simulation.enabled
        and self.simulation.plans or self.db.plans
    local raidPlans = plans[raid.key]
    local overviewPlan = raidPlans and raidPlans[1]
    if not overviewPlan then return 0 end

    local pools = {
        [self.Role.TANK] = {},
        [self.Role.HEALER] = {},
        [self.Role.DAMAGE] = {},
    }
    local overviewByID = {}
    local overview = raid.encounters[1]
    for groupIndex, group in ipairs(overview.groups or {}) do
        for slotIndex, slot in ipairs(group.slots or {}) do
            local assignment = overviewPlan[
                SemanticSlotKey(slot, groupIndex, slotIndex)]
            if assignment then
                local role = slot.role or group.role or self.Role.DAMAGE
                pools[role] = pools[role] or {}
                pools[role][#pools[role] + 1] = assignment
                overviewByID[slot.id] = assignment
            end
        end
    end

    local propagated = 0
    for encounterIndex = 2, #raid.encounters do
        local encounter = raid.encounters[encounterIndex]
        raidPlans[encounterIndex] = raidPlans[encounterIndex] or {}
        local plan = raidPlans[encounterIndex]
        for key, assignment in pairs(plan) do
            if type(assignment) == "table" and assignment.propagated then
                plan[key] = nil
            end
        end
        for groupIndex, group in ipairs(encounter.groups or {}) do
            local slots = self:GetEncounterGroupSlots(
                groupIndex, encounter, raid.key, encounterIndex)
            for slotIndex, slot in ipairs(slots) do
                local key =
                    SemanticSlotKey(slot, groupIndex, slotIndex)
                local assignment = plan[key]
                if assignment and slot.allowedClasses
                    and not slot.allowedClasses[assignment.class]
                then
                    plan[key] = nil
                end
            end
        end
        local used = {}
        for _, assignment in pairs(plan) do
            if type(assignment) == "table" and assignment.name then
                used[assignment.name:lower()] = true
            end
        end
        local cursors = {
            [self.Role.TANK] = 1,
            [self.Role.HEALER] = 1,
            [self.Role.DAMAGE] = 1,
        }
        local function IsCompatible(player, role, slot)
            if not player or not player.name then return false end
            if used[player.name:lower()] then return false end
            if type(slot) == "table" and slot.allowedClasses then
                return slot.allowedClasses[player.class] == true
            end
            return true
        end
        local function NextPlayer(role, preferred, slot)
            if preferred and preferred.name
                and IsCompatible(preferred, role, slot)
            then
                return preferred
            end
            -- Overview utility slots describe the raid roster, not arbitrary
            -- boss jobs. Only carry damage/utility assignments when a boss
            -- deliberately reuses the same semantic slot ID; encounter-
            -- specific jobs are left for that boss's auto assign.
            if role == self.Role.DAMAGE then return nil end
            local pool = pools[role] or {}
            if type(slot) == "table" and slot.allowedClasses then
                for _, player in ipairs(pool) do
                    if IsCompatible(player, role, slot) then
                        return player
                    end
                end
                return nil
            end
            local cursor = cursors[role] or 1
            while pool[cursor]
                and used[pool[cursor].name:lower()]
            do
                cursor = cursor + 1
            end
            cursors[role] = cursor + 1
            return pool[cursor]
        end
        local function Assign(key, role, preferred, slot)
            if plan[key] then return end
            local player = NextPlayer(role, preferred, slot)
            if not player then return end
            plan[key] = {
                name = player.name,
                class = player.class,
                propagated = true,
            }
            used[player.name:lower()] = true
            propagated = propagated + 1
        end
        for groupIndex, group in ipairs(encounter.groups or {}) do
            if group.name ~= "Healing" then
                local slots = self:GetEncounterGroupSlots(
                    groupIndex, encounter, raid.key, encounterIndex)
                for slotIndex, slot in ipairs(slots) do
                    Assign(
                        SemanticSlotKey(slot, groupIndex, slotIndex),
                        slot.role or group.role or self.Role.DAMAGE,
                        overviewByID[slot.id],
                        slot)
                end
            end
        end
        local override = self:GetBossOverride(
            false, raid.key, encounterIndex)
        local healerCount = override and tonumber(override.healers)
        if not healerCount then
            for _, group in ipairs(encounter.groups or {}) do
                if group.role == self.Role.HEALER then
                    healerCount = #group.slots
                    break
                end
            end
        end
        healerCount = healerCount
            or self:GetRaidComposition(raid.key).healers
        for healerIndex = 1, healerCount do
            Assign(
                "S:healer.raid." .. healerIndex,
                self.Role.HEALER)
        end
    end
    return propagated
end

local function AssignmentRole(group, slot, healingSlot)
    if healingSlot then return Raid.Role.HEALER end
    return type(slot) == "table" and slot.role
        or group and group.role or Raid.Role.DAMAGE
end

local function AssignmentClassBonus(class, text)
    text = text:lower()
    local bonus = 0
    local function Has(word) return text:find(word, 1, true) end
    if Has("interrupt") then
        bonus = bonus + (({
            ROGUE = 9000, SHAMAN = 8500, MAGE = 7000,
            WARRIOR = 6500, PALADIN = 4000,
        })[class] or 0)
    end
    if Has("kiter") or Has("kite") or Has("range tank") then
        bonus = bonus + (({
            HUNTER = 9000, MAGE = 8000, WARLOCK = 7500,
        })[class] or 0)
    end
    if Has("enslave") then bonus = bonus + (class == "WARLOCK" and 20000 or 0) end
    if Has("felhunter") then bonus = bonus + (class == "WARLOCK" and 20000 or 0) end
    if Has("spellsteal") or Has("mage tank") then
        bonus = bonus + (class == "MAGE" and 20000 or 0)
    end
    if Has("polymorph") then bonus = bonus + (class == "MAGE" and 20000 or 0) end
    if Has("mind control") then bonus = bonus + (class == "PRIEST" and 20000 or 0) end
    if Has("tranq") then bonus = bonus + (class == "HUNTER" and 20000 or 0) end
    if Has("blessing") then bonus = bonus + (class == "PALADIN" and 18000 or 0) end
    if Has("fear ward") then bonus = bonus + (class == "PRIEST" and 16000 or 0) end
    if Has("purge") then bonus = bonus + (class == "SHAMAN" and 18000 or 0) end
    if Has("decurse") or Has("curse dispel") then
        bonus = bonus + (({
            MAGE = 12000, DRUID = 12000,
        })[class] or 0)
    end
    if Has("poison") then
        bonus = bonus + (({
            SHAMAN = 10000, DRUID = 10000, PALADIN = 9000,
        })[class] or 0)
    end
    if Has("disease") then
        bonus = bonus + (({
            PRIEST = 10000, PALADIN = 10000, SHAMAN = 9000,
        })[class] or 0)
    end
    if Has("dispel") then
        bonus = bonus + (({
            PRIEST = 8000, PALADIN = 7000, SHAMAN = 6500,
        })[class] or 0)
    end
    if Has("crowd control") or Has(" cc") then
        bonus = bonus + (({
            MAGE = 8000, HUNTER = 7000, WARLOCK = 6500,
            ROGUE = 6000,
        })[class] or 0)
    end
    if Has("aoe") then
        bonus = bonus + (({
            MAGE = 7000, WARLOCK = 6500, PALADIN = 5000,
        })[class] or 0)
    end
    return bonus
end

function Raid:GetAssignedPlayerNames()
    local used, plan = {}, self:GetPlan(false) or {}
    for _, assignment in pairs(plan) do
        if type(assignment) == "table" and assignment.name then
            used[assignment.name:lower()] = true
        end
    end
    local encounter = self:GetEncounter()
    for groupIndex, group in ipairs(encounter.groups or {}) do
        for slotIndex = 1, #self:GetEncounterGroupSlots(
            groupIndex, encounter) do
            local assignment = plan[self:SlotKey(groupIndex, slotIndex)]
            if assignment and assignment.name then
                used[assignment.name:lower()] = true
            end
        end
    end
    for slotIndex = 1, self:GetHealingSlotCount() do
        local assignment = plan[self:HealingPlayerKey(slotIndex)]
        if assignment and assignment.name then
            used[assignment.name:lower()] = true
        end
    end
    return used
end

function Raid:SuggestPlayer(group, slot, used, healingSlot)
    local wantedRole = AssignmentRole(group, slot, healingSlot)
    local text = (group and group.name or "") .. " " .. SlotLabel(slot)
    local bestPlayer, bestScore
    for rosterIndex, player in ipairs(self.roster or {}) do
        local playerRole = player.role or player.reportedRole or "NONE"
        local classAllowed = type(slot) ~= "table"
            or not slot.allowedClasses
            or slot.allowedClasses[player.class]
        if player.name and playerRole == wantedRole
            and classAllowed
            and not used[player.name:lower()]
        then
            local score = AssignmentClassBonus(player.class, text)
                + (tonumber(player.gearScore) or 0)
                - (rosterIndex / 1000)
            if not bestScore or score > bestScore then
                bestPlayer, bestScore = player, score
            end
        end
    end
    return bestPlayer
end

function Raid:SuggestAssignment(groupIndex, slotIndex, healingSlotIndex)
    if not self:RequireRaidEditor() then return end
    local encounter = self:GetEncounter()
    local used = self:GetAssignedPlayerNames()
    local player
    if healingSlotIndex then
        player = self:SuggestPlayer(
            { name = "Healing", role = self.Role.HEALER },
            self.Assignment:Healer(
                self.AssignmentTarget.RAID, healingSlotIndex, "Healer"),
            used, true)
        if player then self:SetHealingAssignment(healingSlotIndex, player) end
    else
        local group = encounter.groups[groupIndex]
        local slots = group
            and self:GetEncounterGroupSlots(groupIndex, encounter)
        local label = slots and slots[slotIndex]
        player = group and self:SuggestPlayer(
            group, label, used, false)
        if player then self:SetAssignment(groupIndex, slotIndex, player) end
    end
    if not player then self:Print("No unused raid member is available.") end
    return player
end

function Raid:AutoAssignEncounter()
    if not self:RequireRaidEditor() then return end
    local encounter = self:GetEncounter()
    local plan = self:GetPlan(true)
    local used = self:GetAssignedPlayerNames()
    local assigned = 0
    for groupIndex, group in ipairs(encounter.groups or {}) do
        local include = encounter.name == "Raid Overview"
            or group.name ~= "Healing"
        if include then
            for slotIndex, label in ipairs(
                self:GetEncounterGroupSlots(groupIndex, encounter)) do
                local key = self:SlotKey(groupIndex, slotIndex)
                local current = plan[key]
                if current and type(label) == "table"
                    and label.allowedClasses
                    and not label.allowedClasses[current.class]
                then
                    if current.name then
                        used[current.name:lower()] = nil
                    end
                    plan[key] = nil
                end
                if not plan[key] then
                    local player = self:SuggestPlayer(
                        group, label, used, false)
                    if player then
                        plan[key] = {
                            name = player.name, class = player.class,
                        }
                        used[player.name:lower()] = true
                        assigned = assigned + 1
                    end
                end
            end
        end
    end
    if encounter.name ~= "Raid Overview" then
        for slotIndex = 1, self:GetHealingSlotCount() do
            local key = self:HealingPlayerKey(slotIndex)
            if not plan[key] then
                local player = self:SuggestPlayer(
                    { name = "Healing", role = self.Role.HEALER },
                    self.Assignment:Healer(
                        self.AssignmentTarget.RAID, slotIndex, "Healer"),
                    used, true)
                if player then
                    plan[key] = {
                        name = player.name, class = player.class,
                    }
                    used[player.name:lower()] = true
                    assigned = assigned + 1
                end
            end
        end
    end
    if encounter.name == "Raid Overview" and assigned > 0 then
        self:PropagateOverviewAssignments()
    end
    if self.SendPlanSnapshot and assigned > 0 then
        self:SendPlanSnapshot()
    end
    if self.RefreshAssignments then self:RefreshAssignments() end
    self:Print(("Auto assigned %d player%s."):format(
        assigned, assigned == 1 and "" or "s"))
end

function Raid:GetHealingTargets()
    local encounter = self:GetEncounter()
    local targets = {}
    for groupIndex, group in ipairs(encounter.groups) do
        if group.name == "Tanks" then
            for slotIndex, slot in ipairs(
                self:GetEncounterGroupSlots(groupIndex, encounter)) do
                targets[#targets + 1] = {
                    name = SlotLabel(slot),
                    id = slot.id,
                    groupIndex = groupIndex,
                    slotIndex = slotIndex,
                }
            end
            break
        end
    end
    targets[#targets + 1] = {
        name = "Raid",
    }
    return targets
end

function Raid:GetHealingSlotCount()
    local encounter = self:GetEncounter()
    if encounter.name ~= "Raid Overview" then
        local override = self:GetBossOverride(false)
        if override and tonumber(override.healers) then
            return math.max(0, math.floor(override.healers))
        end
        for _, group in ipairs(encounter.groups or {}) do
            if group.role == self.Role.HEALER then
                return #group.slots
            end
        end
    end
    return self:GetRaidComposition(self:GetRaid().key).healers
end

function Raid:GetHealingTargetLabel(target)
    if not target then return "Unknown target" end
    if target.groupIndex and target.slotIndex then
        local tank = self:GetAssignment(
            target.groupIndex, target.slotIndex)
        if tank and tank.name then
            return ("%s (%s)"):format(target.name, tank.name)
        end
    end
    return target.name
end

function Raid:HealingPlayerKey(slotIndex)
    return "S:healer.raid." .. tostring(slotIndex)
end

function Raid:HealingTargetKey(slotIndex)
    return "T:healer.raid." .. tostring(slotIndex)
end

function Raid:GetHealingAssignment(slotIndex)
    local plan = self:GetPlan(false)
    return plan
        and plan[self:HealingPlayerKey(slotIndex)] or nil
end

function Raid:SetHealingAssignment(slotIndex, player)
    if not self:RequireRaidEditor() then return false end
    local plan = self:GetPlan(true)
    plan[self:HealingPlayerKey(slotIndex)] =
        player and {
            name = player.name,
            class = player.class,
        } or nil
    if self.BroadcastPlanValue then
        self:BroadcastPlanValue(
            self:HealingPlayerKey(slotIndex),
            plan[self:HealingPlayerKey(slotIndex)])
    end
    if self.RefreshAssignments then self:RefreshAssignments() end
    return true
end

function Raid:GetHealingTargetIndex(slotIndex)
    local targets = self:GetHealingTargets()
    local plan = self:GetPlan(false)
    local index = plan
        and tonumber(plan[self:HealingTargetKey(slotIndex)])
    return math.max(1, math.min(index or #targets, #targets))
end

function Raid:CycleHealingTarget(slotIndex)
    if not self:RequireRaidEditor() then return end
    local targets = self:GetHealingTargets()
    local index = self:GetHealingTargetIndex(slotIndex) + 1
    if index > #targets then index = 1 end
    self:GetPlan(true)[self:HealingTargetKey(slotIndex)] = index
    if self.BroadcastPlanValue then
        self:BroadcastPlanValue(self:HealingTargetKey(slotIndex), index)
    end
    if self.RefreshAssignments then self:RefreshAssignments() end
end

function Raid:GetEncounterTargets()
    local encounter = self:GetEncounter()
    if encounter.targets and #encounter.targets > 0 then
        return encounter.targets
    end
    if encounter.name == "Raid Overview" then return {} end
    return { encounter.name }
end

function Raid:GetDefaultMarkerAssignment(targetIndex, encounter)
    encounter = encounter or self:GetEncounter()
    local configured = encounter.defaultMarkers
        and encounter.defaultMarkers[targetIndex]
    if configured == false or configured == 0 then return nil end
    configured = tonumber(configured)
    if configured and self.markers[configured] then
        return configured
    end
    return targetIndex <= #self.markers and targetIndex or nil
end

function Raid:GetMarkerAssignment(targetIndex, plan, encounter)
    if plan == nil then plan = self:GetPlan(false) end
    local key = "M:" .. targetIndex
    if plan and plan[key] ~= nil then
        if plan[key] == false or plan[key] == 0 then return nil end
        return tonumber(plan[key])
    end
    return self:GetDefaultMarkerAssignment(targetIndex, encounter)
end

function Raid:GetMarkerChatToken(markerIndex)
    local marker = self.markers[tonumber(markerIndex)]
    return marker and ("{rt" .. marker.icon .. "}") or ""
end

function Raid:FormatMarkerTokensForLocalDisplay(text)
    return tostring(text or ""):gsub("{rt([1-8])}", function(icon)
        return ("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:0|t")
            :format(icon)
    end)
end

function Raid:GetMarkedTargetEntries()
    local entries = {}
    for targetIndex, targetName in ipairs(self:GetEncounterTargets()) do
        local markerIndex = self:GetMarkerAssignment(targetIndex)
        if markerIndex and self.markers[markerIndex] then
            entries[#entries + 1] =
                self:GetMarkerChatToken(markerIndex) .. " " .. targetName
        end
    end
    return entries
end

function Raid:GetMarkerTokenForText(text, allowSingleTargetFallback)
    text = tostring(text or ""):lower()
    local wordsInText = {}
    for word in text:gmatch("[%a']+") do
        wordsInText[word] = true
    end
    local ignoredWords = {
        the = true, high = true, grand = true, lord = true,
        lady = true, king = true, tank = true, healer = true,
    }
    local targets = self:GetEncounterTargets()
    for targetIndex, targetName in ipairs(targets) do
        local markerIndex = self:GetMarkerAssignment(targetIndex)
        if markerIndex then
            for word in targetName:lower():gmatch("[%a']+") do
                if #word >= 3 and not ignoredWords[word]
                    and wordsInText[word]
                then
                    return self:GetMarkerChatToken(markerIndex)
                end
            end
        end
    end
    if #targets == 1 and allowSingleTargetFallback ~= false then
        return self:GetMarkerChatToken(
            self:GetMarkerAssignment(1))
    end
    return ""
end

function Raid:SetMarkerAssignment(targetIndex, markerIndex)
    if not self:RequireRaidEditor() then return false end
    local plan = self:GetPlan(true)
    if markerIndex then
        for index = 1, #self:GetEncounterTargets() do
            if index ~= targetIndex
                and self:GetMarkerAssignment(index) == markerIndex
            then
                return false
            end
        end
    end
    local storedValue = markerIndex
    if not markerIndex
        and self:GetDefaultMarkerAssignment(targetIndex)
    then
        storedValue = false
    end
    plan["M:" .. targetIndex] = storedValue
    if self.BroadcastPlanValue then
        self:BroadcastPlanValue("M:" .. targetIndex, storedValue)
    end
    if self.RefreshAssignments then self:RefreshAssignments() end
    self:ApplyAutoMarkers()
    return true
end

function Raid:CycleMarkerAssignment(targetIndex)
    local current = self:GetMarkerAssignment(targetIndex) or 0
    for offset = 1, #self.markers do
        local markerIndex =
            ((current + offset - 1) % #self.markers) + 1
        local available = true
        for index = 1, #self:GetEncounterTargets() do
            if index ~= targetIndex
                and self:GetMarkerAssignment(index) == markerIndex
            then
                available = false
                break
            end
        end
        if available then
            self:SetMarkerAssignment(targetIndex, markerIndex)
            return
        end
    end
end

function Raid:AutoAssignMarkers()
    if not self:RequireRaidEditor() then return end
    local targets = self:GetEncounterTargets()
    if #targets == 0 then return end
    local plan = self:GetPlan(true)
    for index = 1, #targets do
        plan["M:" .. index] =
            self:GetDefaultMarkerAssignment(index)
    end
    if self.SendPlanSnapshot then self:SendPlanSnapshot() end
    if self.RefreshAssignments then self:RefreshAssignments() end
end

function Raid:IsAutoMarkerEnabled()
    local plan = self:GetPlan(false)
    return plan and plan.AUTO_MARK == true or false
end

function Raid:ToggleAutoMarker()
    if not self:RequireRaidEditor() then return end
    local plan = self:GetPlan(true)
    plan.AUTO_MARK = not plan.AUTO_MARK
    if plan.AUTO_MARK then
        local targets = self:GetEncounterTargets()
        for index = 1, #targets do
            plan["M:" .. index] =
                self:GetDefaultMarkerAssignment(index)
        end
        self:ApplyAutoMarkers()
    end
    if self.BroadcastPlanValue then
        self:BroadcastPlanValue("AUTO_MARK", plan.AUTO_MARK)
        self:SendPlanSnapshot()
    end
    if self.RefreshAssignments then self:RefreshAssignments() end
end

function Raid:ApplyAutoMarkers()
    if self.simulation.enabled or not self:IsAutoMarkerEnabled()
        or type(SetRaidTarget) ~= "function"
    then
        return
    end
    local targets = self:GetEncounterTargets()
    local byName = {}
    for index, name in ipairs(targets) do
        byName[name] = index
    end
    local units = {
        "target", "focus", "mouseover",
        "boss1", "boss2", "boss3", "boss4", "boss5",
        "boss6", "boss7", "boss8", "boss9", "boss10",
    }
    for _, unit in ipairs(units) do
        if UnitExists(unit) and not UnitIsFriend("player", unit) then
            local name = UnitName(unit)
            local targetIndex = name and byName[name]
            local markerIndex =
                targetIndex and self:GetMarkerAssignment(targetIndex)
            local marker = markerIndex and self.markers[markerIndex]
            if marker and (
                not GetRaidTargetIndex
                or GetRaidTargetIndex(unit) ~= marker.icon
            ) then
                pcall(SetRaidTarget, unit, marker.icon)
            elseif not marker and GetRaidTargetIndex
                and GetRaidTargetIndex(unit)
            then
                pcall(SetRaidTarget, unit, 0)
            end
        end
    end
end

function Raid:ClearPlan()
    if not self:RequireRaidEditor() then return end
    local raid = self:GetRaid()
    local _, encounterIndex = self:GetEncounter()
    local plans = self.simulation.enabled
        and self.simulation.plans or self.db.plans
    if plans[raid.key] then
        plans[raid.key][encounterIndex] = nil
    end
    if self.QueueSync and self:IsLocalRaidEditor() then
        self:QueueSync("SNAP_BEGIN", { raid.key, encounterIndex })
        self:QueueSync("SNAP_END", { raid.key, encounterIndex })
    end
    if self.RefreshAssignments then self:RefreshAssignments() end
end

function Raid:CanStartRaid()
    if IsInRaid and IsInRaid() then
        return self:IsActualRaidLeader()
    end
    if self.simulation.enabled then return true end
    return true
end

function Raid:CompleteRaid()
    if not self.db.raidLocked then
        self:Print("There is no active raid to complete.")
        return false
    end
    if not self:CanStartRaid() then
        self:Print("Only the raid leader can complete the active raid.")
        return false
    end
    local raid = self:GetRaid()
    if self.QueueSync and self:IsLocalRaidEditor() then
        self:QueueSync("CLOSE", { raid.key })
    end
    self.db.raidLocked = false
    self.db.activeSavedRaid = nil
    self.selectedPlayer = nil
    self.dragPlayer = nil
    if self.HideDragGhost then self:HideDragGhost() end
    if self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
    if self.RefreshQuickActionBar then
        self:RefreshQuickActionBar()
    end
    if self.ShowNewRaidWizard then self:ShowNewRaidWizard() end
    self:Print(raid.name .. " raid completed.")
    return true
end

function Raid:ClearCurrentRaidSession()
    local raid = self:GetRaid()
    if self.db.raidLocked and self.QueueSync
        and self:IsLocalRaidEditor()
    then
        self:QueueSync("CLOSE", { raid.key })
    end
    self.db.plans[raid.key] = nil
    self.db.bossOverrides[raid.key] = nil
    self.db.raidCompositions[raid.key] = nil
    self.db.manualPlayers[raid.key] = nil
    if self.simulation and self.simulation.plans then
        self.simulation.plans[raid.key] = nil
    end
    self.db.raidLocked = false
    self.db.activeSavedRaid = nil
    self.selectedPlayer = nil
    self.dragPlayer = nil
    self.roster = {}
    self.remoteSimulationRoster = nil
    wipe(self.messageQueue)
    if self.messageFrame then self.messageFrame:Hide() end
    if self.HideDragGhost then self:HideDragGhost() end
    if self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
    if self.RefreshQuickActionBar then
        self:RefreshQuickActionBar()
    end
end

function Raid:BeginRaid(raidKey)
    if not self:CanStartRaid() then
        self:Print("Only the raid leader can start a raid plan.")
        return false
    end
    local raid = self.raidByKey[raidKey]
    if not raid then return false end
    self.raidSelectionUnlocked = true
    self.db.activeRaid = raid.key
    self.db.activeExpansion = raid.expansion
    self.raidSelectionUnlocked = nil
    local plans = self.simulation.enabled
        and self.simulation.plans or self.db.plans
    plans[raid.key] = {}
    self.db.bossOverrides[raid.key] = {}
    self.db.manualPlayers[raid.key] = {}
    local firstBoss = #raid.encounters >= 2 and 2 or 1
    self.db.currentBossByRaid[raid.key] =
        firstBoss >= 2 and firstBoss or nil
    if self.QueueSync and self:IsLocalRaidEditor() then
        self:QueueSync("RESET", { raid.key })
    end
    self.db.activeEncounter = firstBoss
    self.db.raidLocked = true
    self.db.activeSavedRaid = nil
    self.db.lastRaidByExpansion[raid.expansion] = raid.key
    self.db.lastEncounterByRaid[raid.key] = firstBoss
    self.selectedPlayer = nil
    self.dragPlayer = nil
    if self.assignmentScroll then
        self.assignmentScroll:SetVerticalScroll(0)
    end
    if self.RefreshAll then self:RefreshAll() end
    if self.RefreshQuickActionBar then
        self:RefreshQuickActionBar()
    end
    if self.BroadcastSelection then self:BroadcastSelection() end
    if self.SendPlanSnapshot then self:SendPlanSnapshot() end
    self:Print(raid.name .. " plan started.")
    return true
end

function Raid:StartNewRaid()
    self:BeginRaid(self.db.activeRaid)
end

function Raid:ConfirmNewRaid()
    if self.ShowNewRaidWizard then self:ShowNewRaidWizard() end
end

function Raid:SaveCurrentRaid(name)
    local raid = self:GetRaid()
    name = strtrim(name or "")
    if name == "" then
        name = raid.name .. " Plan"
    end
    local id = self.db.activeSavedRaid
    if not id or not self.db.savedRaids[id] then
        self.savedRaidSequence = (self.savedRaidSequence or 0) + 1
        local stamp = GetServerTime and GetServerTime()
            or time and time() or 0
        id = tostring(stamp)
            .. "-" .. self.savedRaidSequence
    end
    local plans = self.simulation.enabled
        and self.simulation.plans or self.db.plans
    local savedPlayers =
        Copy(self.db.manualPlayers[raid.key] or {})
    if self.simulation.enabled then
        for _, player in ipairs(self.roster or {}) do
            if player.name and player.name ~= "" then
                local role = player.role
                if role ~= "TANK" and role ~= "HEALER"
                    and role ~= "DAMAGER"
                then
                    role = "DAMAGER"
                end
                savedPlayers[player.name:lower()] = {
                    name = player.name,
                    class = player.class or "WARRIOR",
                    className = player.className
                        or classNames[player.class] or "Warrior",
                    role = role,
                    reportedRole = role,
                    spec = player.spec or "",
                    race = player.race or "Planned",
                    subgroup = tonumber(player.subgroup) or 1,
                    manual = true,
                    simulated = nil,
                }
            end
        end
    end
    self.db.savedRaids[id] = {
        id = id,
        name = name,
        raidKey = raid.key,
        expansion = raid.expansion,
        savedAt = GetServerTime and GetServerTime()
            or time and time() or 0,
        activeEncounter = self.db.activeEncounter,
        currentBoss = self:GetCurrentBossIndex(raid),
        plans = Copy(plans[raid.key] or {}),
        bossOverrides = Copy(self.db.bossOverrides[raid.key] or {}),
        bossPresets = Copy(self.db.bossPresets[raid.key] or {}),
        raidComposition = Copy(self.db.raidCompositions[raid.key] or {}),
        manualPlayers = savedPlayers,
    }
    self.db.activeSavedRaid = id
    self:Print("Saved raid plan: " .. name .. ".")
    if self.RefreshNewRaidWizard then self:RefreshNewRaidWizard() end
end

function Raid:LoadSavedRaid(id)
    if not self:CanStartRaid() then
        self:Print("Only the raid leader can load and start a saved raid.")
        return false
    end
    local saved = self.db.savedRaids[id]
    local raid = saved and self.raidByKey[saved.raidKey]
    if not raid then return false end
    self.db.plans[raid.key] = Copy(saved.plans or {})
    if self.simulation.enabled then
        self.simulation.plans = self.simulation.plans or {}
        self.simulation.plans[raid.key] = Copy(saved.plans or {})
    end
    self.db.bossOverrides[raid.key] = Copy(saved.bossOverrides or {})
    self.db.bossPresets[raid.key] = Copy(saved.bossPresets or {})
    self.db.raidCompositions[raid.key] =
        Copy(saved.raidComposition or {})
    self.db.manualPlayers[raid.key] = Copy(saved.manualPlayers or {})
    self.db.activeRaid = raid.key
    self.db.activeExpansion = raid.expansion
    self.db.activeEncounter = math.max(1, math.min(
        tonumber(saved.activeEncounter) or 1, #raid.encounters))
    local savedCurrentBoss = tonumber(saved.currentBoss)
    self.db.currentBossByRaid[raid.key] =
        savedCurrentBoss and savedCurrentBoss >= 2
            and savedCurrentBoss <= #raid.encounters
            and savedCurrentBoss or nil
    self.db.raidLocked = true
    self.db.activeSavedRaid = id
    self.db.lastRaidByExpansion[raid.expansion] = raid.key
    self.db.lastEncounterByRaid[raid.key] = self.db.activeEncounter
    self:ApplyRaidComposition(raid)
    self:UpdateRoster()
    if self.RefreshAll then self:RefreshAll() end
    if self.RefreshQuickActionBar then
        self:RefreshQuickActionBar()
    end
    if self.BroadcastSelection then self:BroadcastSelection() end
    if self.SendPlanSnapshot then self:SendPlanSnapshot() end
    self:Print("Loaded saved raid plan: " .. saved.name .. ".")
    return true
end

function Raid:DeleteSavedRaid(id)
    local saved = id and self.db.savedRaids[id]
    if not saved then return false end
    local name = saved.name or "Saved Raid"
    self.db.savedRaids[id] = nil
    if self.db.activeSavedRaid == id then
        self.db.activeSavedRaid = nil
    end
    if self.RefreshNewRaidWizard then
        self:RefreshNewRaidWizard()
    end
    self:Print("Deleted saved raid plan: " .. name .. ".")
    return true
end

function Raid:SetRaid(key)
    if self.db.raidLocked and not self.raidSelectionUnlocked then
        self:Print("Use New Raid to change raids.")
        return
    end
    if not self.raidByKey[key] then return end
    self.db.activeRaid = key
    self.db.activeExpansion = self.raidByKey[key].expansion
    self.db.lastRaidByExpansion[self.db.activeExpansion] = key
    self.db.activeEncounter =
        self.db.lastEncounterByRaid[key] or 1
    if self.assignmentScroll then
        self.assignmentScroll:SetVerticalScroll(0)
    end
    if self.RefreshAll then self:RefreshAll() end
end

function Raid:SetExpansion(key)
    if self.db.raidLocked and not self.raidSelectionUnlocked then
        self:Print("Use New Raid to change expansions.")
        return
    end
    local valid
    for _, expansion in ipairs(self.expansions) do
        if expansion.key == key then valid = true break end
    end
    if not valid then return end
    self.db.activeExpansion = key
    local raids = self:GetRaidsForExpansion()
    if #raids == 0 then return end
    local remembered = self.db.lastRaidByExpansion[key]
    local rememberedRaid = remembered and self.raidByKey[remembered]
    if not rememberedRaid or rememberedRaid.expansion ~= key then
        rememberedRaid = raids[1]
    end
    self.db.activeRaid = rememberedRaid.key
    self.db.lastRaidByExpansion[key] = rememberedRaid.key
    self.db.activeEncounter =
        self.db.lastEncounterByRaid[rememberedRaid.key] or 1
    if self.assignmentScroll then
        self.assignmentScroll:SetVerticalScroll(0)
    end
    if self.RefreshAll then self:RefreshAll() end
end

function Raid:SetEncounter(index)
    local raid = self:GetRaid()
    self.db.activeEncounter =
        math.max(1, math.min(tonumber(index) or 1, #raid.encounters))
    self.db.lastEncounterByRaid[raid.key] =
        self.db.activeEncounter
    if self.assignmentScroll then
        self.assignmentScroll:SetVerticalScroll(0)
    end
    if self.RefreshAll then self:RefreshAll() end
end

function Raid:GetCurrentBossIndex(raid)
    raid = raid or self:GetRaid()
    local index = tonumber(
        self.db.currentBossByRaid
            and self.db.currentBossByRaid[raid.key])
    if not index or index < 2 or index > #raid.encounters then
        return nil
    end
    return index
end

function Raid:SetCurrentBoss(index, fromSync)
    local raid = self:GetRaid()
    index = math.floor(tonumber(index) or 0)
    if index < 2 or index > #raid.encounters then return false end
    if not fromSync and not self:RequireRaidEditor() then return false end
    self.db.currentBossByRaid = self.db.currentBossByRaid or {}
    self.db.currentBossByRaid[raid.key] = index
    if not fromSync and self.QueueSync then
        self:QueueSync("CURRENT", { raid.key, index })
    end
    if self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
    if self.RefreshBossRail then self:RefreshBossRail() end
    if self.RefreshQuickActionBar then
        self:RefreshQuickActionBar()
    end
    return true
end

function Raid:NavigateBoss(direction)
    if not self.db.raidLocked or not self:RequireRaidEditor() then
        return false
    end
    local raid = self:GetRaid()
    local bossCount = #raid.encounters - 1
    if bossCount < 1 then return false end
    -- Boss navigation advances raid progression, not whichever encounter is
    -- currently open for planning. Raid leaders can therefore edit another
    -- boss without making the quick-action arrows jump from that selection.
    local current = self:GetCurrentBossIndex(raid)
        or tonumber(self.db.activeEncounter) or 2
    if current < 2 or current > #raid.encounters then current = 2 end
    local viewedEncounter = tonumber(self.db.activeEncounter)
    local viewingCurrentBoss = viewedEncounter == current
    direction = tonumber(direction) or 1
    local nextBoss = math.max(
        2, math.min(#raid.encounters, current + direction))
    if nextBoss == current then return false end
    self:SetCurrentBoss(nextBoss)
    if viewingCurrentBoss then
        self:SetEncounter(nextBoss)
    end
    return true
end

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
        self:Print("Enter a character name.")
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
            self:Print("The client rejected the Blizzard role change.")
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
            self:Print("Live raid groups can only be changed while in a raid.")
            return
        end
        if (sourceIndex and targetIndex
            and type(SwapRaidSubgroup) ~= "function")
            or (not (sourceIndex and targetIndex)
                and type(SetRaidSubgroup) ~= "function")
        then
            self:Print("This client does not support raid group editing.")
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
            self:Print("The client rejected the raid group change.")
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
        self:Print("You must be raid leader or assistant to start a role check.")
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
        self:Print("[SIM] Role check requested.")
        return
    end
    local rolePoll = C_PartyInfo
        and C_PartyInfo.InitiateRolePoll or InitiateRolePoll
    if type(rolePoll) ~= "function" then
        self:Print("This client does not support Blizzard role checks.")
        return
    end
    local ok = pcall(rolePoll)
    if not ok then
        self:Print("The client rejected the role check.")
    end
end

function Raid:StartReadyCheck()
    if not self:IsLocalRaidEditor() then
        self:Print(
            "You must be raid leader or assistant to start a ready check.")
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
        self:Print("This client does not support ready checks.")
        return
    end
    self.pendingReadyCheckCaller =
        GetUnitName("player", true) or UnitName("player")
    local ok = pcall(readyCheck)
    if not ok then
        self:Print("The client rejected the ready check.")
    end
end

function Raid:StartPullCountdown(seconds)
    seconds = math.max(1, math.min(30, tonumber(seconds) or 10))
    if not self:IsLocalRaidEditor() then
        self:Print(
            "You must be raid leader or assistant to start a pull timer.")
        return
    end
    if _G.DBM and type(_G.DBM.CreatePullTimer) == "function" then
        local ok = pcall(_G.DBM.CreatePullTimer, _G.DBM, seconds)
        if ok then
            if self.simulation.enabled then
                self:Print(("[SIM] DBM pull timer: %d seconds."):format(
                    seconds))
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
    self:Print("The client rejected the pull timer.")
end

function Raid:StartBreakTimer(minutes)
    minutes = math.max(1, math.min(
        60, math.floor(tonumber(minutes) or 5)))
    if not self:IsLocalRaidEditor() then
        self:Print(
            "You must be raid leader or assistant to start a break timer.")
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
        self:Print(("[SIM] Break timer: %d minutes."):format(minutes))
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
            if StoreResult(asyncResult) and Raid.RefreshRoster then
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
        -- TipTac's API may start inspection and item-data requests. Never call
        -- it for the entire raid during roster construction; only query the
        -- local player here. Remote players are collected from INSPECT_READY.
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
    if changed and self.RefreshRoster then
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
        self:Print(
            "Usage: /lr sim 10, /lr sim 25, /lr sim 40, or /lr sim clear")
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
    self:Print(
        ("Simulation enabled: %d-player target; added %d simulated players."):format(
            size, #self.simulation.roster))
end

function Raid:StopSimulation(silent)
    if not self.simulation.enabled then
        if self.ClearSimulatedRaidCooldowns then
            self:ClearSimulatedRaidCooldowns()
        end
        self.remoteSimulationRoster = nil
        if self.BroadcastSimulationClear then
            self:BroadcastSimulationClear()
        end
        self:UpdateRoster()
        if not silent then
            self:Print("Simulated players cleared; live roster retained.")
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
    self.selectedPlayer = nil
    self:UpdateRoster()
    if self.RefreshRaidCooldowns then
        self:RefreshRaidCooldowns()
    end
    if self.frame then self:RefreshAll() end
    if not silent then
        self:Print("Simulation cleared; live roster restored.")
    end
end

function Raid:UpdateRoster()
    if self.simulation.enabled then
        self.roster, self.simulation.roster =
            self:BuildSimulatedRoster(self.simulation.size)
        if self.BroadcastSimulationRoster then
            self:BroadcastSimulationRoster()
        end
        if self.RefreshRoster then self:RefreshRoster() end
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
    if self.RefreshRoster then self:RefreshRoster() end
end

function Raid:RefreshLoginRoster()
    self.rosterBootstrapGeneration =
        (self.rosterBootstrapGeneration or 0) + 1
    local generation = self.rosterBootstrapGeneration
    local attempts = 0
    local function Refresh()
        if generation ~= Raid.rosterBootstrapGeneration then return end
        Raid:UpdateRoster()
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
    if self.simulation.enabled then return "RAID_WARNING" end
    local configured = self.db.announcementChannel or "AUTO"
    if configured ~= "AUTO" then
        if configured == "RAID_WARNING"
            and not (IsInRaid and IsInRaid())
        then
            return "PARTY"
        elseif configured == "RAID_WARNING"
            and not self:IsLocalRaidEditor()
        then
            return "RAID"
        end
        return configured
    end
    if IsInRaid and IsInRaid() then
        return self:IsLocalRaidEditor() and "RAID_WARNING" or "RAID"
    elseif IsInGroup and IsInGroup()
        or GetNumPartyMembers and GetNumPartyMembers() > 0
    then
        return "PARTY"
    end
    return "SAY"
end

function Raid:AnnounceAssignments()
    if not self:RequireRaidEditor() then return end
    wipe(self.messageQueue)
    local encounter = self:GetEncounter()
    local plan = self:GetPlan(false) or {}
    local count = 0
    for groupIndex, group in ipairs(encounter.groups) do
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
        self:QueueEntryLines(
            self:GetGroupChannel(), nil, prefix, entries)
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
            self:GetGroupChannel(), nil,
            "Healing: ", healingEntries)
    end
    if count == 0 then
        wipe(self.messageQueue)
        self:Print("Assign at least one player before announcing.")
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
    for groupIndex, group in ipairs(encounter.groups) do
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
        self:Print("Assign at least one player before whispering.")
        return
    end
    self:StartMessageQueue()
end

function Raid:OnInitialize()
    self:InitializeDatabase()
    StaticPopupDialogs.LUNARAIDS_RESET_ALL_SETTINGS = {
        text = "Reset every LunaRaids setting and window position?\n\n"
            .. "Saved raids and assignments will not be deleted.",
        button1 = "Reset All",
        button2 = CANCEL,
        OnAccept = function() Raid:ResetAllSettings() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopupDialogs.LUNARAID_NEW_RAID = {
        text = "Start a new %s plan?\n\nAll saved assignments for this raid will be cleared.",
        button1 = "Start New Raid",
        button2 = CANCEL,
        OnAccept = function() Raid:StartNewRaid() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopupDialogs.LUNARAIDS_SAVE_RAID = {
        text = "Save the current raid plan as:",
        button1 = "Save Raid",
        button2 = CANCEL,
        hasEditBox = true,
        OnAccept = function(dialog)
            local editBox = Raid:GetPopupEditBox(dialog)
            Raid:SaveCurrentRaid(editBox and editBox:GetText() or "")
        end,
        EditBoxOnEnterPressed = function(editBox)
            Raid:SaveCurrentRaid(editBox:GetText())
            editBox:GetParent():Hide()
        end,
        EditBoxOnEscapePressed = function(editBox)
            editBox:GetParent():Hide()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopupDialogs.LUNARAIDS_DELETE_SAVED_RAID = {
        text = "Delete the saved raid plan \"%s\"?\n\nThis cannot be undone.",
        button1 = "Delete",
        button2 = CANCEL,
        OnAccept = function(_, data)
            Raid:DeleteSavedRaid(
                data or Raid.pendingDeleteSavedRaidID)
            Raid.pendingDeleteSavedRaidID = nil
        end,
        OnCancel = function()
            Raid.pendingDeleteSavedRaidID = nil
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopupDialogs.LUNARAIDS_SAVE_BOSS_PRESET = {
        text = "Save the current boss assignment setup as:",
        button1 = "Save Preset",
        button2 = CANCEL,
        hasEditBox = true,
        OnAccept = function(dialog)
            local editBox = Raid:GetPopupEditBox(dialog)
            Raid:SaveBossPreset(editBox and editBox:GetText() or "")
        end,
        EditBoxOnEnterPressed = function(editBox)
            if Raid:SaveBossPreset(editBox:GetText()) then
                editBox:GetParent():Hide()
            end
        end,
        EditBoxOnEscapePressed = function(editBox)
            editBox:GetParent():Hide()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopupDialogs.LUNARAIDS_DELETE_BOSS_PRESET = {
        text = "Delete the boss preset \"%s\"?\n\nThis cannot be undone.",
        button1 = "Delete",
        button2 = CANCEL,
        OnAccept = function(_, data)
            Raid:DeleteBossPreset(
                data or Raid.pendingDeleteBossPresetID)
            Raid.pendingDeleteBossPresetID = nil
        end,
        OnCancel = function()
            Raid.pendingDeleteBossPresetID = nil
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopupDialogs.LUNARAIDS_REMOVE_RAID_PLAYER = {
        text = "Remove %s from the raid?",
        button1 = "Remove",
        button2 = CANCEL,
        OnAccept = function(_, data)
            Raid:RemoveRosterPlayer(data)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopupDialogs.LUNARAIDS_NEW_RAID_SAVE = {
        text = "Save the current %s raid before creating a new one?",
        button1 = "Save & New",
        button2 = "Don't Save",
        button3 = CANCEL,
        hasEditBox = true,
        OnAccept = function(dialog)
            local editBox = Raid:GetPopupEditBox(dialog)
            Raid:FinishOpeningNewRaid(
                true, editBox and editBox:GetText() or "")
        end,
        OnCancel = function()
            Raid:FinishOpeningNewRaid(false)
        end,
        OnAlt = function() end,
        EditBoxOnEnterPressed = function(editBox)
            Raid:FinishOpeningNewRaid(true, editBox:GetText())
            editBox:GetParent():Hide()
        end,
        EditBoxOnEscapePressed = function() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3,
    }
    self.messageFrame = CreateFrame("Frame")
    self.messageFrame:Hide()
    self.messageFrame.elapsed = 0
    self.messageFrame:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = frame.elapsed + elapsed
        if frame.elapsed < (Raid.db.messageDelay or .45) then return end
        frame.elapsed = 0
        local message = table.remove(Raid.messageQueue, 1)
        if not message then
            frame:Hide()
            return
        end
        if Raid.simulation.enabled then
            local destination = message.channel
            local displayText =
                Raid:FormatMarkerTokensForLocalDisplay(message.text)
            if message.target then
                destination =
                    destination .. " -> " .. message.target
            end
            if message.channel == "RAID_WARNING"
                and RaidNotice_AddMessage and RaidWarningFrame
            then
                local color = ChatTypeInfo
                    and ChatTypeInfo.RAID_WARNING
                    or { r = 1, g = .28, b = 0 }
                RaidNotice_AddMessage(
                    RaidWarningFrame, displayText, color)
            end
            Raid:Print(
                ("[SIM %s] %s"):format(
                    destination, displayText))
        else
            local ok = pcall(
                SendChatMessage,
                message.text, message.channel, nil, message.target)
            if not ok then
                local fallback = message.text:gsub(
                    "{rt(%d)}", function(icon)
                        icon = tonumber(icon)
                        for _, marker in ipairs(Raid.markers) do
                            if marker.icon == icon then
                                return "[" .. marker.name .. "]"
                            end
                        end
                        return "[Marker]"
                    end)
                fallback = fallback:gsub("|", "/")
                pcall(
                    SendChatMessage,
                    fallback, message.channel, nil, message.target)
            end
        end
    end)

    self:InitializeCommunication()
    self:InitializeCharacterIntel()
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "HandleGroupRosterUpdate")
    self:RegisterEvent("CHAT_MSG_WHISPER", "HandleAutoInviteWhisper")
    self:RegisterEvent(
        "PLAYER_ENTERING_WORLD", "HandlePlayerEnteringWorld")
    self:RegisterEvent(
        "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "ApplyAutoMarkers")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "ApplyAutoMarkers")
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "ApplyAutoMarkers")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", "ApplyAutoMarkers")
    self:RegisterEvent("READY_CHECK", "HandleReadyCheckStarted")
    self:RegisterEvent("READY_CHECK_CONFIRM", "HandleReadyCheckConfirm")
    self:RegisterEvent("READY_CHECK_FINISHED", "HandleReadyCheckFinished")
    self:RegisterEvent("UNIT_AURA", "HandleReadyCheckAuraUpdate")
    self:RegisterEvent(
        "UNIT_INVENTORY_CHANGED", "HandleReadyCheckAuraUpdate")
    self:RegisterEvent("INSPECT_READY", "HandleGearInspectReady")
    self:RegisterEvent(
        "PLAYER_EQUIPMENT_CHANGED", "HandlePlayerEquipmentChanged")
    self:RegisterEvent(
        "UPDATE_INVENTORY_DURABILITY", "HandleDurabilityChanged")
    self:RegisterEvent("MERCHANT_CLOSED", "HandleDurabilityChanged")
    self:RegisterEvent(
        "PLAYER_REGEN_DISABLED", "HandleCombatStateChanged")
    self:RegisterEvent(
        "PLAYER_REGEN_ENABLED", "HandleCombatStateChanged")
    self:RegisterEvent("UI_SCALE_CHANGED")
    self:RegisterEvent("DISPLAY_SIZE_CHANGED", "UI_SCALE_CHANGED")
    self:RegisterChatCommand("lunaraids", "HandleSlashCommand")
    self:RegisterChatCommand("lunaraid", "HandleSlashCommand")
    self:RegisterChatCommand("lr", "HandleSlashCommand")
    self:InitializeDataBroker()
    self:InitializeSettings()
    if self.InitializeLibDurability then
        self:InitializeLibDurability()
    end
end

function Raid:HandleSlashCommand(input)
    input = strtrim(input or ""):lower()
    local simulationSize = input:match("^sim%s+(%d+)$")
    if simulationSize then
        self:StartSimulation(tonumber(simulationSize))
    elseif input == "sim off" or input == "sim stop"
        or input == "sim clear"
    then
        self:StopSimulation()
    elseif input == "sim" then
        self:Print(
            "Usage: /lr sim 10, /lr sim 25, /lr sim 40, or /lr sim clear")
    elseif input == "reset" then
        self:ClearPlan()
        self:Print("Current encounter assignments cleared.")
    elseif input == "sync" then
        if self.RequestPeerSync then
            self:RequestPeerSync()
            self:Print("Requested the current LunaRaids plan.")
        end
    elseif input == "minimap" then
        self.db.minimap.hide = not self.db.minimap.hide
        self:RefreshMinimapButton()
        self:Print(
            self.db.minimap.hide
                and "Minimap button hidden. Type /lr minimap to restore it."
                or "Minimap button shown.")
    elseif input == "cooldowns" or input == "cds" then
        self:ToggleRaidCooldowns()
    elseif input == "config" or input == "settings" then
        self:OpenSettings()
    else
        self:Toggle()
    end
end

function Raid:OnEnable()
    self:InitializeCommunication()
    self:RefreshLoginRoster()
    if self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
    if self.CreateQuickActionBar then
        self:CreateQuickActionBar()
        self:RefreshQuickActionBar()
    end
    if self.InitializeRaidCooldowns then
        self:InitializeRaidCooldowns()
    end
    if self.RequestPeerSync then self:RequestPeerSync() end
end
