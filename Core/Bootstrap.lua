local ADDON, Raid = ...

Raid.name = ADDON
local GetMetadata = C_AddOns and C_AddOns.GetAddOnMetadata
    or GetAddOnMetadata
local addonVersion = GetMetadata and GetMetadata(ADDON, "Version")
local developmentVersion = not addonVersion or addonVersion == ""
    or addonVersion:find("@project%-version@") ~= nil
if developmentVersion then
    addonVersion = "dev"
end
Raid.version = addonVersion
-- Older protocol-8 builds compare this field literally against their
-- hard-coded 0.1.0 value. Keep the handshake identity stable; the actual TOC
-- version is informational, while PROTOCOL determines wire compatibility.
Raid.syncVersion = "0.1.0"
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
    { "WARRIOR", "Human", "TANK", "Protection" },
    { "DRUID", "Night Elf", "TANK", "Feral" },
    { "WARRIOR", "Orc", "TANK", "Protection" },
    { "PALADIN", "Draenei", "HEALER", "Holy" },
    { "PRIEST", "Dwarf", "HEALER", "Discipline" },
    { "SHAMAN", "Tauren", "HEALER", "Restoration" },
    { "DRUID", "Tauren", "HEALER", "Restoration" },
    { "PRIEST", "Blood Elf", "HEALER", "Holy" },
    { "PALADIN", "Human", "HEALER", "Holy" },
    { "SHAMAN", "Draenei", "HEALER", "Restoration" },
    { "MAGE", "Gnome", "DAMAGER", "Fire" },
    { "WARLOCK", "Orc", "DAMAGER", "Destruction" },
    { "ROGUE", "Human", "DAMAGER", "Combat" },
    { "HUNTER", "Night Elf", "DAMAGER", "Marksmanship" },
    { "SHAMAN", "Troll", "DAMAGER", "Enhancement" },
    { "MAGE", "Undead", "DAMAGER", "Frost" },
    { "WARLOCK", "Gnome", "DAMAGER", "Affliction" },
    { "HUNTER", "Orc", "DAMAGER", "Beast Mastery" },
    { "PALADIN", "Blood Elf", "DAMAGER", "Retribution" },
    { "DRUID", "Night Elf", "DAMAGER", "Balance" },
    { "PRIEST", "Undead", "DAMAGER", "Shadow" },
    { "ROGUE", "Troll", "DAMAGER", "Assassination" },
    { "HUNTER", "Dwarf", "DAMAGER", "Survival" },
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
    raidConfigurationDefaults = {},
    characterIntel = {},
    savedRaids = {},
    manualPlayers = {},
    raidLocked = false,
    newRaidExpansion = "TBC",
    plans = {},
    window = {
        point = "CENTER", x = 0, y = 0,
        width = 900, height = 650,
    },
    hudScale = 1,
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
    mechanicsHUD = {
        enabled = true,
        point = "CENTER", x = 330, y = 120,
        width = 430,
        visibility = "GROUP",
        combatOnly = false,
        locked = false,
        showTitle = true,
        maxLines = 6,
        opacity = .92,
    },
    raidCooldowns = {
        enabled = true,
        point = "CENTER", x = -330, y = 20,
        style = "MINIMAL",
        spells = {},
        active = {},
        effects = {},
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
        whisperEnabled = false,
        textSize = 8,
        rowSpacing = 1,
        columnSpacing = 1,
        visibility = "GROUP",
    },
    raidAdmin = {
        autoInvite = false,
        inviteKeywords = "inv, invite",
        inviteScope = "EVERYONE",
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
        "This raid is view only. Only the raid leader can edit it.")
    return false
end

function Raid:CanEditRaidGroups()
    if IsInRaid and IsInRaid() then
        return UnitIsGroupLeader
                and UnitIsGroupLeader("player")
            or IsRaidLeader and IsRaidLeader()
            or false
    end
    return self.simulation and self.simulation.enabled or false
end

function Raid:RequireRaidGroupEditor()
    if self:CanEditRaidGroups() then return true end
    self:Print(
        "Only the raid leader can change raid groups.")
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
        self:Print(self.L.ONLY_LEADER_PROMOTE)
        return
    end
    if type(PromoteToAssistant) ~= "function"
        or not pcall(PromoteToAssistant, player.name, true)
    then
        self:Print(self.L.PROMOTION_REJECTED)
    end
end

function Raid:DemoteRosterPlayer(player)
    if not self:IsActualRaidLeader() or not player or player.manual
        or player.simulated or self:IsRosterPlayerSelf(player)
    then
        self:Print(self.L.ONLY_LEADER_DEMOTE)
        return
    end
    if type(DemoteAssistant) ~= "function"
        or not pcall(DemoteAssistant, player.name)
    then
        self:Print(self.L.DEMOTION_REJECTED)
    end
end

function Raid:TransferRaidLeader(player)
    if not self:IsActualRaidLeader() or not player or player.manual
        or player.simulated or self:IsRosterPlayerSelf(player)
    then
        self:Print(self.L.ONLY_LEADER_TRANSFER)
        return
    end
    if type(PromoteToLeader) ~= "function"
        or not pcall(PromoteToLeader, player.name)
    then
        self:Print(self.L.TRANSFER_REJECTED)
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
        self:Print(self.L.ONLY_LEADERSHIP_REMOVE)
        return
    end
    local uninvite = C_PartyInfo and C_PartyInfo.UninviteUnit
        or UninviteUnit
    if type(uninvite) ~= "function"
        or not pcall(uninvite, player.name)
    then
        self:Print(self.L.REMOVE_MEMBER_REJECTED)
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
    local migrateWindowSize =
        rawget(database, "windowSizeVersion") ~= 2
    Merge(database, defaults)
    if migrateWindowSize then
        database.window.width = defaults.window.width
        database.window.height = defaults.window.height
    end
    database.windowSizeVersion = 2
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
        "window", "quickBar", "readyCheck", "assignmentInfo", "mechanicsHUD",
        "raidCooldowns", "raidAdmin", "minimap",
        "announcementChannel", "messageDelay", "hudScale",
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
    Position(self.mechanicsHUDFrame, self.db.mechanicsHUD)
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
    if self.ApplyInterfaceScale then self:ApplyInterfaceScale() end
    if self.UpdateWindowLayout then self:UpdateWindowLayout() end
    if self.RefreshSettingsView then self:RefreshSettingsView() end
    self:Print(self.L.ALL_SETTINGS_RESET)
end

function Raid:NormalizeDatabase()
    local restore = self.db.simulationRestore
    if type(restore) == "table"
        and type(self.db.simulationSession) ~= "table"
    then
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

Raid.Core = {
    Copy = Copy,
    classNames = classNames,
    simulatedNames = simulatedNames,
    simulatedByRole = simulatedByRole,
}
