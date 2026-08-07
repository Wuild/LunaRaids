local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\obsidian_sanctum"

Raid:RegisterRaid({
    expansion = "WOTLK",
    key = "obsidian_sanctum", name = "The Obsidian Sanctum", size = 25, instanceID = 615,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Sartharion", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Drake Tank",
                "Portal Team Lead",
                "Flame Wall Caller",
                "Breath Cooldown 1",
                "Breath Cooldown 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\obsidian_sanctum__sartharion",
            mechanics = {
                Mechanic("With drakes alive, assign portal teams, tank drakes away from Sartharion, cross flame-wall gaps, and rotate cooldowns through breaths."),
            },
        }),
    },
})
