local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ruby_sanctum"

Raid:RegisterRaid({
    expansion = "WOTLK",
    key = "ruby_sanctum", name = "The Ruby Sanctum", size = 25, instanceID = 724,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Baltharus the Warborn", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Clone Tank 1",
                "Clone Tank 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ruby_sanctum__baltharusthewarborn",
            mechanics = {
                Mechanic("Tanks collect split copies away from the raid while players spread for Enervating Brand and avoid Blade Tempest."),
            },
        }),
        Encounter("Saviana Ragefire", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Enrage Dispel",
                "Conflagration Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ruby_sanctum__savianaragefire",
            mechanics = {
                Mechanic("Tanks swap for stacking flame breath, dispel Enrage, and spread Conflagration targets away before they detonate."),
            },
        }),
        Encounter("General Zarithrian", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Flamecaller Tank",
                "Flamecaller Interrupt 1",
                "Flamecaller Interrupt 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ruby_sanctum__generalzarithrian",
            mechanics = {
                Mechanic("Tanks swap at armor stacks, interrupt every Intimidating Roar heal lockout, and off-tank/interrupt Flamecaller adds."),
            },
        }),
        Encounter("Halion", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Physical Realm Lead",
                "Twilight Realm Lead",
                "Combustion Dispel",
                "Consumption Dispel",
                "Cutter Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ruby_sanctum__halion",
            mechanics = {
                Mechanic("Split physical and twilight teams evenly, rotate cutters safely, dispel Combustion/Consumption at the edge, and balance corporeality near 50%."),
            },
        }),
    },
})
