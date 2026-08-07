local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_descent"

Raid:RegisterRaid({
    expansion = "CATA",
    key = "blackwing_descent", name = "Blackwing Descent", size = 25, instanceID = 669,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Magmaw", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Chain User 1",
                "Chain User 2",
                "Parasite Kite Lead",
                "Mangle Cooldown",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_descent__magmaw",
            mechanics = {
                Mechanic("Tank Magmaw away from the raid, assign chain users after Mangle, and have ranged control parasites without letting them reach players."),
            },
        }),
        Encounter("Omnotron Defense System", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Arcane Annihilator Interrupt 1",
                "Arcane Annihilator Interrupt 2",
                "Poison Bomb Control",
                "Shield Swap Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_descent__omnotrondefensesystem",
            mechanics = {
                Mechanic("Swap damage as each golem shields, interrupt Arcanotron, purge Poison Protocol targets, and move Power Generators clear of bosses."),
            },
        }),
        Encounter("Maloriak", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Release Interrupt 1",
                "Release Interrupt 2",
                "Remedy Dispel",
                "Aberration Tank",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_descent__maloriak",
            mechanics = {
                Mechanic("Interrupt Release Aberrations on a fixed schedule, dispel Remedy, stack/spread by vial, then tank and burn all remaining adds in green phase."),
            },
        }),
        Encounter("Atramedes", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Ground Gong 1",
                "Ground Gong 2",
                "Air Gong 1",
                "Air Gong 2",
                "Air Kite Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_descent__atramedes",
            mechanics = {
                Mechanic("Assign gong users for Searing Flame and air pursuit, spread to limit sound, and kite tracking flames without crossing the raid."),
            },
        }),
        Encounter("Chimaeron", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Double Attack Tank",
                "Group 1 Healer",
                "Group 2 Healer",
                "Group 3 Healer",
                "Group 4 Healer",
                "Group 5 Healer",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_descent__chimaeron",
            mechanics = {
                Mechanic("Healers divide raid targets to keep everyone above 10k, stack during Feud, and tanks use Break/Double Attack assignments."),
            },
        }),
        Encounter("Nefarian", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Onyxia Tank",
                "Pillar Interrupt 1",
                "Pillar Interrupt 2",
                "Pillar Interrupt 3",
                "Bone Kite Tank",
                "Electrocute Cooldown 1",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_descent__nefarian",
            mechanics = {
                Mechanic("Tank Nefarian and Onyxia apart, interrupt every Blast Nova on three pillars, manage Electrocute cooldowns, then kite animated bones."),
            },
        }),
    },
})
