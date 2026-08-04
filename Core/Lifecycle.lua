local _, Raid = ...
local Core = Raid.Core
local Copy = Core.Copy
local classNames = Core.classNames
local simulatedNames = Core.simulatedNames
local simulatedByRole = Core.simulatedByRole
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
    StaticPopupDialogs.LUNARAIDS_ADD_BOSS_CATEGORY = {
        text = "Add a custom assignment category:\n\nFor trash duties, include the marker and action (for example: Moon Polymorph).",
        button1 = "Add Category", button2 = CANCEL, hasEditBox = true,
        OnAccept = function(dialog)
            local editBox = Raid:GetPopupEditBox(dialog)
            Raid:AddBossCustomGroup(editBox and editBox:GetText() or "")
        end,
        EditBoxOnEnterPressed = function(editBox)
            if Raid:AddBossCustomGroup(editBox:GetText()) then
                editBox:GetParent():Hide()
            end
        end,
        EditBoxOnEscapePressed = function(editBox)
            editBox:GetParent():Hide()
        end,
        timeout = 0, whileDead = true, hideOnEscape = true,
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
    self:RegisterEvent(
        "PARTY_LOOT_METHOD_CHANGED", "HandleGroupRosterUpdate")
    self:RegisterEvent("CHAT_MSG_WHISPER", "HandleAutoInviteWhisper")
    self:RegisterEvent(
        "PLAYER_ENTERING_WORLD", "HandlePlayerEnteringWorld")
    self:RegisterEvent(
        "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "ApplyAutoMarkers")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "ApplyAutoMarkers")
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "ApplyAutoMarkers")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", "ApplyAutoMarkers")
    self:RegisterEvent(
        "PLAYER_EQUIPMENT_CHANGED", "HandlePlayerEquipmentChanged")
    self:RegisterEvent(
        "PLAYER_REGEN_DISABLED", "HandleCombatStateChanged")
    self:RegisterEvent(
        "PLAYER_REGEN_ENABLED", "HandleCombatStateChanged")
    self:RegisterEvent("ENCOUNTER_START", "HandleEncounterStarted")
    self:RegisterEvent("ENCOUNTER_END", "HandleEncounterEnded")
    self:RegisterEvent("BOSS_KILL", "HandleBossKill")
    self:RegisterEvent("UI_SCALE_CHANGED")
    self:RegisterEvent("DISPLAY_SIZE_CHANGED", "UI_SCALE_CHANGED")
    self:RegisterChatCommand("lunaraids", "HandleSlashCommand")
    self:RegisterChatCommand("lunaraid", "HandleSlashCommand")
    self:RegisterChatCommand("lr", "HandleSlashCommand")
    self:InitializeDataBroker()
    self:InitializeSettings()
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
        self:Print(self.L.ENCOUNTER_ASSIGNMENTS_CLEARED)
    elseif input == "sync" then
        if self.RequestPeerSync then
            self:RequestPeerSync()
            self:Print(self.L.CURRENT_PLAN_REQUESTED)
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
    self:RestoreSimulationSession()
    self:RefreshLoginRoster()
    if self.RefreshPersonalAssignments then
        self:RefreshPersonalAssignments()
    end
    if self.CreateQuickActionBar then
        self:CreateQuickActionBar()
        self:RefreshQuickActionBar()
    end
    if self.RefreshMechanicsHUD then self:RefreshMechanicsHUD() end
    if self.RequestPeerSync then self:RequestPeerSync() end
end
