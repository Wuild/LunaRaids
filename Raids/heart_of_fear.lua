local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\heart_of_fear"

Raid:RegisterRaid({
    expansion = "MOP",
    key = "heart_of_fear", name = "Heart of Fear", size = 25, instanceID = 1009,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Imperial Vizier Zor'lok", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Exhale Interceptor 1",
                "Exhale Interceptor 2",
                "Attenuation Caller",
                "Convert Break Team",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\heart_of_fear__imperialvizierzorlok",
            mechanics = {
                Mechanic("Assign platform positions, interrupt Exhale by crossing its beam, use attenuation movement lanes, and mind-control break groups in phase two."),
            },
        }),
        Encounter("Blade Lord Ta'yak", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Wind Step Group 1",
                "Wind Step Group 2",
                "Unseen Strike Stack Caller",
                "Tornado Lane Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\heart_of_fear__bladelordtayak",
            mechanics = {
                Mechanic("Tanks swap Overwhelming Assault, ranged form Wind Step groups, stack Unseen Strike, and use assigned tornado lanes in the gauntlet."),
            },
        }),
        Encounter("Garalon", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Pheromone Kiter 1",
                "Pheromone Kiter 2",
                "Pheromone Kiter 3",
                "Pheromone Kiter 4",
                "Leg Kill Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\heart_of_fear__garalon",
            mechanics = {
                Mechanic("Preassign a Pheromone kiting rotation around the edge while melee destroy legs and the raid avoids standing beneath the boss."),
            },
        }),
        Encounter("Wind Lord Mel'jarak", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Mender Interrupt 1",
                "Mender Interrupt 2",
                "Quickening Dispel",
                "Battle-Mender CC",
                "Amber-Trapper CC",
                "Blademaster CC",
                "Prison Breaker 1",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\heart_of_fear__windlordmeljarak",
            mechanics = {
                Mechanic("Plan limited crowd control across add types, interrupt Menders, dispel Quickening, and break Amber Prisons without reusing helpers."),
            },
        }),
        Encounter("Amber-Shaper Un'sok", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Construct Interrupt 1",
                "Construct Interrupt 2",
                "Amber Scalpel Kite Lead",
                "Monstrosity Tank",
                "Amber Globule Pair Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\heart_of_fear__ambershaperunsok",
            mechanics = {
                Mechanic("Assign interrupt order for transformed players, burn Mutated Constructs before willpower expires, and have Monstrosity tanks alternate Massive Stomp."),
            },
        }),
        Encounter("Grand Empress Shek'zeer", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Dissonance Field Healer",
                "Windblade Tank",
                "Reaver Tank",
                "Dispatch Interrupt 1",
                "Dispatch Interrupt 2",
                "Cry of Terror Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\heart_of_fear__grandempressshekzeer",
            mechanics = {
                Mechanic("Tanks swap Eyes of the Empress, place Dissonance Fields apart, split phase-two add control, and coordinate Cry of Terror positioning."),
            },
        }),
    },
})
