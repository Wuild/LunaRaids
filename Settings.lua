local _, Raid = ...

local function Trim(value)
    return strtrim(tostring(value or ""))
end

local function ShortName(value)
    return Trim(value):match("^[^-]+") or ""
end

local function IsListed(list, name)
    local full = Trim(name):lower()
    local short = ShortName(name):lower()
    -- Character names cannot contain whitespace or punctuation (apart from
    -- the realm separator), so treat every other character as a delimiter.
    -- This accepts spaces, commas, semicolons, slashes, newlines, and mixed
    -- separators without requiring a particular list format.
    for entry in tostring(list or ""):gmatch(
        "[A-Za-z\128-\255][A-Za-z\128-\255%-]*")
    do
        entry = entry:lower()
        if entry == full or entry == short then return true end
    end
    return false
end

local function ListedNames(list)
    local names, seen = {}, {}
    for entry in tostring(list or ""):gmatch(
        "[A-Za-z\128-\255][A-Za-z\128-\255%-]*")
    do
        local key = entry:lower()
        if not seen[key] then
            seen[key] = true
            names[#names + 1] = entry
        end
    end
    return names
end

local function FindRaidMember(name)
    local wantedFull = Trim(name):lower()
    local wantedShort = ShortName(name):lower()
    if wantedFull == "" then return nil end
    -- Classic can briefly report a zero group count while raidN roster data
    -- is already available, so inspect the complete raid range directly.
    for index = 1, 40 do
        local unit = "raid" .. index
        local memberName = GetUnitName and GetUnitName(unit, true)
            or UnitName and UnitName(unit)
        if not memberName and GetRaidRosterInfo then
            memberName = GetRaidRosterInfo(index)
        end
        if memberName then
            local full = Trim(memberName):lower()
            local short = ShortName(memberName):lower()
            local connected = not UnitIsConnected
                or UnitIsConnected(unit) ~= false
            if connected
                and (full == wantedFull or short == wantedShort)
            then
                return unit, memberName
            end
        end
    end
    return nil
end

local function CanInvite()
    return UnitIsGroupLeader("player")
        or UnitIsGroupAssistant("player")
        or not IsInGroup()
end

function Raid:HandleAutoInviteWhisper(_, message, sender)
    local settings = self.db and self.db.raidAdmin
    if not settings or not settings.autoInvite or not CanInvite() then
        return
    end
    local wanted = Trim(message):lower()
    local matched = false
    for keyword in tostring(settings.inviteKeywords or ""):gmatch("[^,;]+") do
        if wanted == Trim(keyword):lower() then
            matched = true
            break
        end
    end
    if not matched or sender == "" then return end

    self.inviteCooldowns = self.inviteCooldowns or {}
    local key = sender:lower()
    local now = GetTime and GetTime() or 0
    if now - (self.inviteCooldowns[key] or -30) < 10 then return end
    self.inviteCooldowns[key] = now

    local invite = C_PartyInfo and C_PartyInfo.InviteUnit or InviteUnit
    if invite then
        local ok = pcall(invite, sender)
        if ok then
            self:Print(
                "Invite requested for " .. sender
                    .. " from keyword whisper.")
        end
    end
end

function Raid:ApplyAutoPromote()
    local settings = self.db and self.db.raidAdmin
    if not settings or not settings.autoPromote
        or not IsInRaid() or not UnitIsGroupLeader("player")
    then
        return
    end
    local promote = C_PartyInfo
        and C_PartyInfo.PromoteToAssistant or PromoteToAssistant
    if not promote then return end
    local selectedRanks = settings.promoteGuildRanks or {}
    local playerGuild = GetGuildInfo and GetGuildInfo("player")
    for index = 1, 40 do
        local unit = "raid" .. index
        local name = GetUnitName(unit, true) or UnitName(unit)
        if not name and GetRaidRosterInfo then
            name = GetRaidRosterInfo(index)
        end
        local guildName, guildRank
        if GetGuildInfo then
            guildName, _, guildRank = GetGuildInfo(unit)
        end
        local rankIndex = tonumber(guildRank)
        local listedByRank = playerGuild and guildName == playerGuild
            and rankIndex ~= nil and selectedRanks[rankIndex] == true
        if name and not UnitIsUnit(unit, "player")
            and not UnitIsGroupAssistant(unit)
            and (
                IsListed(settings.promoteNames, name)
                or listedByRank)
        then
            pcall(promote, unit)
        end
    end
end

function Raid:ApplyLootRules(force, replaceMaster)
    local settings = self.db and self.db.raidAdmin
    if not settings or not settings.manageLoot then
        if force then self:Print("Enable loot rules before applying them.") end
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        if force then
            self:Print("Loot rules will be checked again after combat.")
        end
        return false
    end
    if not IsInRaid() or not UnitIsGroupLeader("player") then
        if force then
            self:Print(
                "Loot rules require an active raid and raid leadership.")
        end
        return false
    end
    local method = settings.lootMethod or "group"
    local methodIDs = {
        freeforall = 0,
        roundrobin = 1,
        master = 2,
        group = 3,
        needbeforegreed = 4,
    }
    local methodID = methodIDs[method] or methodIDs.group
    local threshold = math.max(
        0, math.min(4, tonumber(settings.lootThreshold) or 2))
    local setMethod = C_PartyInfo
        and C_PartyInfo.SetLootMethod or SetLootMethod
    local setThreshold = C_PartyInfo
        and C_PartyInfo.SetLootThreshold or SetLootThreshold
    local getThreshold = C_PartyInfo
        and C_PartyInfo.GetLootThreshold or GetLootThreshold
    if not setMethod then return false end

    local getMethod = C_PartyInfo
        and C_PartyInfo.GetLootMethod or GetLootMethod
    local currentMethod, partyMaster, raidMaster
    if getMethod then
        currentMethod, partyMaster, raidMaster = getMethod()
    end
    local currentMethodID = type(currentMethod) == "number"
        and currentMethod or methodIDs[currentMethod]
    -- A periodic audit must not undo a master looter selected through
    -- Blizzard's UI. Explicit LunaRaids changes pass replaceMaster=true.
    if not replaceMaster and currentMethodID == methodIDs.master then
        method = "master"
        methodID = methodIDs.master
    end
    local ok = currentMethodID == methodID and method ~= "master"
    if method == "master" then
        local masterUnit = raidMaster and raidMaster > 0
            and ("raid" .. raidMaster)
            or partyMaster ~= nil and (
                partyMaster == 0 and "player"
                or "party" .. partyMaster)
        local currentMaster = masterUnit
            and (GetUnitName(masterUnit, true) or UnitName(masterUnit))
        -- Never replace a valid master looter during the periodic settings
        -- audit. This allows a raid leader to make a temporary manual choice.
        if not replaceMaster and currentMethodID == methodID
            and currentMaster and FindRaidMember(currentMaster)
        then
            ok = true
        else
            local candidates = ListedNames(settings.masterLooter)
            if #candidates == 0 then
                candidates[1] =
                    GetUnitName("player", true) or UnitName("player")
            end
            local configuredMasterUnit, configuredMaster
            for _, candidate in ipairs(candidates) do
                configuredMasterUnit, configuredMaster =
                    FindRaidMember(candidate)
                if configuredMasterUnit then break end
            end
            if configuredMasterUnit then
                ok = pcall(setMethod, methodID, configuredMaster)
            end
        end
        if not ok then
            if force then
                self:Print(
                    "None of the configured master looters are currently "
                        .. "in the raid; master looter was not changed.")
            end
            return false
        end
    elseif currentMethodID ~= methodID then
        ok = pcall(setMethod, methodID)
    end
    if setThreshold then
        local applyThreshold = function()
            local current = getThreshold and getThreshold()
            if current ~= threshold then pcall(setThreshold, threshold) end
        end
        applyThreshold()
        if C_Timer and C_Timer.After then
            -- Classic can reject the threshold until the loot-method roster
            -- update has completed, so retry after Blizzard settles it.
            C_Timer.After(.5, applyThreshold)
            C_Timer.After(2, applyThreshold)
        end
    end
    if force and ok then self:Print("Loot rules applied.") end
    return ok
end

function Raid:SetMasterLooterPlayer(player)
    local settings = self.db and self.db.raidAdmin
    if not settings or not player or not player.name then return false end
    settings.manageLoot = true
    settings.lootMethod = "master"
    local names = { player.name }
    for _, name in ipairs(ListedNames(settings.masterLooter)) do
        if ShortName(name):lower() ~= ShortName(player.name):lower() then
            names[#names + 1] = name
        end
    end
    settings.masterLooter = table.concat(names, ", ")
    if self.RefreshSettingsView then self:RefreshSettingsView() end
    return self:ApplyLootRules(true, true)
end

function Raid:InsertConfiguredPlayerName(name)
    local editBox = self.playerNameInsertBox
    local settingKey = self.playerNameInsertKey
    if not editBox or not editBox:IsShown() then return false end
    if settingKey ~= "masterLooter" and settingKey ~= "promoteNames" then
        return false
    end
    name = Trim(name):match("^[^:|%]]+")
    if not name or name == "" then return false end
    local settings = self.db and self.db.raidAdmin
    if not settings then return false end
    local current = editBox:GetText() or ""
    if not IsListed(current, name) then
        current = current ~= "" and (current .. ", " .. name) or name
        editBox:SetText(current)
        editBox:SetCursorPosition(#current)
        settings[settingKey] = current
    end
    editBox:SetFocus()
    return true
end

function Raid:HandleConfiguredPlayerLink(link)
    if not IsShiftKeyDown or not IsShiftKeyDown() then return end
    local name = tostring(link or ""):match("|Hplayer:([^:|]+)")
        or tostring(link or ""):match("^player:([^:|]+)")
    if not name then return end
    local now = GetTime and GetTime() or 0
    local linkKey = tostring(self.playerNameInsertKey) .. ":" .. name
    if self.lastConfiguredPlayerLink == linkKey
        and now - (self.lastConfiguredPlayerLinkTime or 0) < .1
    then
        return
    end
    if self:InsertConfiguredPlayerName(name) then
        self.lastConfiguredPlayerLink = linkKey
        self.lastConfiguredPlayerLinkTime = now
    end
end

function Raid:ApplyRaidAdministration(force)
    local now = GetTime and GetTime() or 0
    if not force
        and now - (self.lastRaidAdminApply or -10) < 1
    then
        return
    end
    self.lastRaidAdminApply = now
    self:ApplyAutoPromote()
    self:ApplyLootRules(false)
end

function Raid:ScheduleRaidAdministration()
    self.raidAdminRosterGeneration =
        (self.raidAdminRosterGeneration or 0) + 1
    local generation = self.raidAdminRosterGeneration
    self:ApplyRaidAdministration()
    if C_Timer and C_Timer.After then
        C_Timer.After(.75, function()
            if generation == Raid.raidAdminRosterGeneration then
                Raid:ApplyRaidAdministration(true)
            end
        end)
    end
end

function Raid:AuditLootRules()
    if self.RefreshQuickActionBar then
        self:RefreshQuickActionBar()
    end
    if InCombatLockdown and InCombatLockdown() then return end
    if self.restoreMainWindowAfterCombat then
        self.restoreMainWindowAfterCombat = nil
        if self.frame and not self.frame:IsShown() then
            self.frame:Show()
        end
    end
    self:ApplyLootRules(false)
end

function Raid:HandleCombatStarted()
    if self.frame and self.frame:IsShown() then
        self.restoreMainWindowAfterCombat = true
        self.frame:Hide()
    else
        self.restoreMainWindowAfterCombat = nil
    end
    if self.RefreshQuickActionBar then
        self:RefreshQuickActionBar()
    end
end

function Raid:ResetWindowPosition()
    self.db.window.point = "CENTER"
    self.db.window.x = 0
    self.db.window.y = 0
    if self.frame then
        self.frame:ClearAllPoints()
        self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

function Raid:InitializeSettings()
    -- Settings are rendered inside the main LunaRaids window. AceDB remains
    -- the account-wide backing store; no Blizzard/AceConfig category is
    -- registered.
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "AuditLootRules")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "HandleCombatStarted")
    if not self.lootRuleTicker and C_Timer and C_Timer.NewTicker then
        self.lootRuleTicker = C_Timer.NewTicker(10, function()
            Raid:AuditLootRules()
        end)
    end
    if not self.masterLooterLinkHooks then
        self.masterLooterLinkHooks = true
        if hooksecurefunc and ChatEdit_InsertLink then
            hooksecurefunc("ChatEdit_InsertLink", function(link)
                Raid:HandleConfiguredPlayerLink(link)
            end)
        end
        if hooksecurefunc and SetItemRef then
            hooksecurefunc("SetItemRef", function(link)
                Raid:HandleConfiguredPlayerLink(link)
            end)
        end
    end
end

function Raid:OpenSettings()
    self:ShowSettingsView()
end
