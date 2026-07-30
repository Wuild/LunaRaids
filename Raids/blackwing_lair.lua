local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "VANILLA",
    key = "blackwing_lair", name = "Blackwing Lair", size = 40,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", {
                A.TANK.MAIN, A.TANK.OFF, A.TANK.THIRD,
                "Add Tank 1", "Add Tank 2",
            }),
            Group("Healing", A:Healers(12)),
            Group("Utility", {
                "Tranq Shot 1", "Tranq Shot 2",
                "Dispel Lead", "Suppression Room Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair",
        }),
        Boss("Razorgore the Untamed", {
            "Razorgore Tank", "East Add Tank 1", "East Add Tank 2",
            "West Add Tank 1", "West Add Tank 2",
        }, {
            "Orb Controller 1", "Orb Controller 2",
            "East Kiter", "West Kiter", "Egg Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__razorgoretheuntamed",
            spellIcon = 22425,
        }),
        Boss("Vaelastrasz the Corrupt", {
            "Tank 1", "Tank 2", "Tank 3", "Tank 4",
        }, {
            "Tank Rotation Caller", "Burning Adrenaline Caller",
        }, 12, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__vaelastraszthecorrupt",
            spellIcon = 23461,
        }),
        Boss("Broodlord Lashlayer", {
            A.TANK.MAIN, A.TANK.OFF,
        }, {
            "Mortal Strike Caller", "Suppression Room Lead",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__broodlordlashlayer",
            spellIcon = 23331,
        }),
        Boss("Firemaw", {
            A.TANK.MAIN, "Wing Buffet Tank",
        }, {
            "Taunt Caller", "Stack Reset Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__firemaw",
            spellIcon = 23339,
        }),
        Boss("Ebonroc", {
            A.TANK.MAIN, "Wing Buffet Tank", "Shadow Tank",
        }, {
            "Shadow of Ebonroc Caller", "Taunt Rotation Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__ebonroc",
            spellIcon = 23339,
        }),
        Boss("Flamegor", {
            A.TANK.MAIN, "Wing Buffet Tank",
        }, {
            "Tranq Shot 1", "Tranq Shot 2", "Taunt Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__flamegor",
            spellIcon = 23339,
        }),
        Encounter("Chromaggus", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(12)),
            Group("Dispels", {
                "Magic Dispel Lead", "Curse Dispel Lead",
                "Poison Dispel Lead", "Disease Dispel Lead",
            }),
            Group("Utility", {
                "Time Lapse Caller", "Frenzy Tranq 1",
                "Frenzy Tranq 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__chromaggus",
            spellIcon = 23155,
        }),
        Encounter("Nefarian", {
            Group("Tanks", {
                "Nefarian Tank", "Left Add Tank", "Right Add Tank",
            }),
            Group("Healing", A:Healers(12)),
            Group("Sides", { "Left Side Lead", "Right Side Lead" }),
            Group("Utility", {
                "Class Call Caller", "Fear Ward",
                "Skeleton AoE Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair",
            spellIcon = 22539,
        }),
    },
})
