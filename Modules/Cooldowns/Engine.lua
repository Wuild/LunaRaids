local _, Raid = ...
local Cooldowns = Raid:NewModule("Cooldowns", "AceEvent-3.0")

local WHITE = "Interface\\Buttons\\WHITE8X8"
local THEME = Raid.UI.THEME
local ACCENT = Raid.UI.ACCENT
local MUTED = Raid.UI.MUTED

local DEFINITIONS = Raid.CooldownDefinitions

local BY_SPELL = {}
for _, definition in ipairs(DEFINITIONS) do
    for _, spellID in ipairs(definition[6]) do
        BY_SPELL[spellID] = definition
    end
end

function Raid:GetRaidCooldownDefinitions()
    return DEFINITIONS
end

local function Frame(parent, frameType)
    local template = BackdropTemplateMixin and "BackdropTemplate" or nil
    local frame = CreateFrame(frameType or "Frame", nil, parent, template)
    frame:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    frame:SetBackdropColor(unpack(THEME.window))
    frame:SetBackdropBorderColor(unpack(THEME.border))
    return frame
end

local function Label(parent, size, text, color)
    local label = parent:CreateFontString(
        nil, "OVERLAY", size <= 9 and "GameFontHighlightSmall"
            or "GameFontHighlight")
    label:SetFontObject(
        Raid.UI.GetFontObject(size, "MONOCHROMEOUTLINE"))
    label:SetText(text or "")
    label:SetTextColor(unpack(color or { .9, .9, .9, 1 }))
    return label
end

local function ShortName(name)
    return tostring(name or ""):match("^[^-]+") or ""
end

local function CompactName(name, length)
    name = ShortName(name)
    length = length or 6
    local position, characters = 1, 0
    while position <= #name and characters < length do
        local byte = name:byte(position)
        local bytes = byte and byte >= 240 and 4
            or byte and byte >= 224 and 3
            or byte and byte >= 192 and 2
            or 1
        if position + bytes - 1 > #name then break end
        position = position + bytes
        characters = characters + 1
    end
    return position <= #name and name:sub(1, position - 1) or name
end

local function TimeText(seconds)
    if seconds >= 60 then
        return ("%d:%02d"):format(
            math.floor(seconds / 60), math.floor(seconds % 60))
    end
    return seconds >= 10 and tostring(math.ceil(seconds))
        or ("%.1f"):format(math.max(0, seconds))
end

local function CooldownLength(seconds)
    if seconds >= 60 then
        local minutes = math.floor((seconds / 60) + .5)
        return minutes .. "m"
    end
    return tostring(seconds) .. "s"
end

local function CurrentTime()
    if GetServerTime then return GetServerTime() end
    if time then return time() end
    return 0
end

function Raid:GetRaidCooldownSettings()
    self.db.raidCooldowns = self.db.raidCooldowns or {}
    local settings = self.db.raidCooldowns
    if settings.enabled == nil then settings.enabled = true end
    settings.style = settings.style or "CARDS"
    if not settings.minimalRedesign then
        settings.style = "MINIMAL"
        settings.minimalRedesign = true
    end
    settings.spells = settings.spells or {}
    settings.active = settings.active or {}
    settings.effects = settings.effects or {}
    settings.expanded = settings.expanded or {}
    settings.page = math.max(1, tonumber(settings.page) or 1)
    settings.layout = settings.layout or "CATEGORIES"
    settings.sortMode = settings.sortMode or "SPELL"
    if settings.classColors == nil then settings.classColors = true end
    settings.readyColor = settings.readyColor or { .18, .9, .55 }
    settings.cooldownColor =
        settings.cooldownColor or { 1, .32, .24 }
    settings.scale = tonumber(settings.scale) or 1
    settings.hudOpacity = tonumber(settings.hudOpacity) or .82
    settings.textSize = math.max(
        6, math.min(14, math.floor(tonumber(settings.textSize) or 8)))
    settings.rowSpacing = math.max(
        0, math.min(12, math.floor(tonumber(settings.rowSpacing) or 1)))
    settings.columnSpacing = math.max(
        0, math.min(12, math.floor(
            tonumber(settings.columnSpacing) or 1)))
    if settings.locked == nil then settings.locked = false end
    if settings.showAbilityName == nil then
        settings.showAbilityName = true
    end
    if settings.showAbilityTotal == nil then
        settings.showAbilityTotal = true
    end
    if settings.whisperEnabled == nil then
        settings.whisperEnabled = false
    end
    if settings.visibility ~= "ALWAYS"
        and settings.visibility ~= "RAID"
    then
        settings.visibility = "GROUP"
    end
    for _, definition in ipairs(DEFINITIONS) do
        if settings.spells[definition[1]] == nil then
            settings.spells[definition[1]] = definition[7]
        end
    end
    return settings
end

function Raid:IsRaidCooldownPlayerEligible(player, definition)
    if not player or player.class ~= definition[3] then
        return false
    end
    local specs = definition[8]
    if not specs then return true end
    local spec = tostring(player.spec or "")
    if spec == "" or spec == "Unknown" or tonumber(spec) then return true end
    if specs[spec] then return true end
    for wanted in pairs(specs) do
        if spec:lower():find(wanted:lower(), 1, true) then return true end
    end
    return false
end

function Raid:GetRaidCooldownRoster(includeSolo)
    if self:IsSimulating() then
        return self.roster or {}
    end
    if not self:IsInLiveGroup() and not includeSolo then
        return {}
    end
    local live = self.BuildLiveRoster and self:BuildLiveRoster() or {}
    local result = {}
    for _, player in ipairs(live or {}) do
        if player.unit and (not UnitExists or UnitExists(player.unit)) then
            result[#result + 1] = player
        end
    end
    return result
end

function Raid:PrintRaidCooldownDebug()
    local settings = self:GetRaidCooldownSettings()
    local roster = self:GetRaidCooldownRoster(true)
    local eligibleRows = 0
    for _, definition in ipairs(DEFINITIONS) do
        if settings.spells[definition[1]] ~= false then
            for _, player in ipairs(roster) do
                if self:IsRaidCooldownPlayerEligible(player, definition) then
                    eligibleRows = eligibleRows + 1
                    break
                end
            end
        end
    end
    local refreshed, refreshError = pcall(self.RefreshRaidCooldowns, self)
    local frame = self.raidCooldownFrame
    self:Print((
        "CDDEBUG context=%s liveRaid=%d liveParty=%d enabled=%s "
            .. "visibility=%s roster=%d rows=%d frame=%s refresh=%s%s"
    ):format(
        self:GetGroupContext(), self:GetLiveRaidMemberCount(),
        self:GetLivePartyMemberCount(), tostring(settings.enabled),
        tostring(settings.visibility), #roster, eligibleRows,
        frame and tostring(frame:IsShown()) or "missing",
        tostring(refreshed),
        refreshed and "" or " error=" .. tostring(refreshError)))
end

function Raid:HandleRaidCooldownCombatLog()
    local _, event, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _,
        spellID = CombatLogGetCurrentEventInfo()
    local definition = BY_SPELL[tonumber(spellID)]
    if not definition or not sourceName then return end
    local belongs = false
    for _, player in ipairs(self:GetRaidCooldownRoster(true)) do
        if player.guid and sourceGUID and player.guid == sourceGUID
            or ShortName(player.name):lower()
                == ShortName(sourceName):lower()
        then
            belongs = true
            break
        end
    end
    if not belongs then return end
    local effectDuration = tonumber(definition[9])
    if effectDuration and (event == "SPELL_AURA_APPLIED"
        or event == "SPELL_AURA_REFRESH"
        or event == "SPELL_AURA_REMOVED")
    then
        local settings = self:GetRaidCooldownSettings()
        local effects = settings.effects[definition[1]] or {}
        settings.effects[definition[1]] = effects
        local owner = sourceGUID or ShortName(sourceName):lower()
        if event == "SPELL_AURA_REMOVED" then
            effects[owner] = nil
        else
            effects[owner] = {
                guid = sourceGUID,
                name = sourceName,
                targetGUID = destGUID,
                targetName = destName,
                duration = effectDuration,
                expires = CurrentTime() + effectDuration,
            }
        end
        self:RefreshRaidCooldowns()
        return
    end
    if event ~= "SPELL_CAST_SUCCESS" then return end
    self.raidCooldownState = self:GetRaidCooldownSettings().active
    local key = definition[1]
    self.raidCooldownState[key] = self.raidCooldownState[key] or {}
    self.raidCooldownState[key][sourceGUID or sourceName] = {
        guid = sourceGUID, name = sourceName,
        expires = CurrentTime() + definition[5],
    }
    self:RefreshRaidCooldowns()
end

function Raid:GetRaidCooldownEffect(definition, player)
    -- This runs in the renderer's player-by-player inner loop.  Settings are
    -- initialized before the cooldown frame is built, so avoid normalizing
    -- every definition again for every displayed player.
    local settings = self.db and self.db.raidCooldowns
        or self:GetRaidCooldownSettings()
    local effects = settings.effects[definition[1]] or {}
    local now = CurrentTime()
    for owner, effect in pairs(effects) do
        if not tonumber(effect.expires) or effect.expires <= now then
            effects[owner] = nil
        elseif effect.guid and player.guid and effect.guid == player.guid
            or ShortName(effect.name):lower()
                == ShortName(player.name):lower()
        then
            return effect
        end
    end
end

function Raid:GetRaidCooldownState(definition, player)
    local states = self.raidCooldownState
        and self.raidCooldownState[definition[1]] or {}
    local now = CurrentTime()
    local fallback
    for owner, state in pairs(states) do
        if not tonumber(state.expires) or state.expires <= now then
            states[owner] = nil
        elseif state.guid and player.guid and state.guid == player.guid
            or ShortName(state.name):lower()
                == ShortName(player.name):lower()
        then
            if state.exact then return state end
            fallback = state
        end
    end
    return fallback
end

function Raid:GetLocalRaidCooldownRemaining(definition)
    if not GetSpellCooldown then return nil end
    local _, playerClass = UnitClass("player")
    if playerClass ~= definition[3] then return nil end
    local available, bestRemaining = false, 0
    for _, spellID in ipairs(definition[6]) do
        local known = not IsSpellKnown or IsSpellKnown(spellID)
        if known then
            available = true
            local start, duration, enabled = GetSpellCooldown(spellID)
            start, duration = tonumber(start) or 0, tonumber(duration) or 0
            if enabled ~= 0 and duration > 2 then
                bestRemaining = math.max(
                    bestRemaining,
                    start + duration - (GetTime and GetTime() or 0))
            end
        end
    end
    if not available then return nil end
    return math.max(0, math.ceil(bestRemaining))
end

function Raid:StoreExactRaidCooldown(name, definitionIndex, remaining)
    local definition = DEFINITIONS[tonumber(definitionIndex)]
    if not definition or not name then return end
    local settings = self:GetRaidCooldownSettings()
    self.raidCooldownState = settings.active
    local states = self.raidCooldownState[definition[1]] or {}
    self.raidCooldownState[definition[1]] = states
    local shortName = ShortName(name)
    for owner, state in pairs(states) do
        if ShortName(state.name):lower() == shortName:lower() then
            states[owner] = nil
        end
    end
    remaining = math.max(
        0, math.min(tonumber(remaining) or 0, definition[5] + 5))
    if remaining > 0 then
        states["EXACT:" .. shortName:lower()] = {
            name = shortName,
            exact = true,
            expires = CurrentTime() + remaining,
        }
    end
end

function Raid:ReceiveRaidCooldownState(sender, definitionIndex, remaining)
    local senderName = ShortName(sender)
    local rosterPlayer
    for _, player in ipairs(self:GetRaidCooldownRoster(true)) do
        if ShortName(player.name):lower() == senderName:lower() then
            rosterPlayer = player
            break
        end
    end
    local definition = DEFINITIONS[tonumber(definitionIndex)]
    if not rosterPlayer or not definition
        or rosterPlayer.class ~= definition[3]
    then
        return
    end
    self:StoreExactRaidCooldown(
        rosterPlayer.name, definitionIndex, remaining)
    self:RefreshRaidCooldowns()
end

function Raid:BroadcastLocalRaidCooldowns(target, force)
    if not self:IsInLiveGroup() then return end
    self.localRaidCooldownWire = self.localRaidCooldownWire or {}
    local changed = false
    local playerName = GetUnitName
        and GetUnitName("player", true) or UnitName("player")
    for index, definition in ipairs(DEFINITIONS) do
        local remaining = self:GetLocalRaidCooldownRemaining(definition)
        if remaining ~= nil then
            local previous = self.localRaidCooldownWire[index]
            if force or previous == nil
                or math.abs(previous - remaining) > 1
                or (previous > 0) ~= (remaining > 0)
            then
                changed = true
                self:StoreExactRaidCooldown(playerName, index, remaining)
                self.localRaidCooldownWire[index] = remaining
                if self.BroadcastOwnCooldown then
                    self:BroadcastOwnCooldown(index, remaining, target)
                end
            end
        end
    end
    if changed then self:RefreshRaidCooldowns() end
end

function Raid:HandleLocalRaidCooldownUpdate()
    if self.localRaidCooldownUpdatePending then return end
    self.localRaidCooldownUpdatePending = true
    local function Update()
        Raid.localRaidCooldownUpdatePending = nil
        Raid:BroadcastLocalRaidCooldowns()
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(.15, Update)
    else
        Update()
    end
end

Cooldowns.View = {
    definitions = DEFINITIONS,
    Frame = Frame,
    Label = Label,
    ShortName = ShortName,
    CompactName = CompactName,
    TimeText = TimeText,
    CooldownLength = CooldownLength,
    CurrentTime = CurrentTime,
}
