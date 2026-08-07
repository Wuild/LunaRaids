local _, Raid = ...
local Cooldowns = Raid:GetModule("Cooldowns")
function Raid:InitializeRaidCooldowns()
    if self.raidCooldownsInitialized then return end
    self.raidCooldownsInitialized = true
    self.raidCooldownState = self:GetRaidCooldownSettings().active
    self:CreateRaidCooldownFrame()
    self:RefreshRaidCooldowns()
    if C_Timer and C_Timer.After then
        C_Timer.After(1, function()
            Raid:BroadcastLocalRaidCooldowns(nil, true)
        end)
    else
        self:BroadcastLocalRaidCooldowns(nil, true)
    end
end

function Cooldowns:OnEnable()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function()
        Raid:HandleRaidCooldownCombatLog()
    end)
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN", function()
        Raid:HandleLocalRaidCooldownUpdate()
    end)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", function()
        Raid:RefreshRaidCooldowns()
        Raid:BroadcastLocalRaidCooldowns(nil, true)
    end)
    Raid:InitializeRaidCooldowns()
end

function Cooldowns:OnDisable()
    self:UnregisterAllEvents()
    if Raid.raidCooldownFrame then
        Raid.raidCooldownFrame:Hide()
    end
end
