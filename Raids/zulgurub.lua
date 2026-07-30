local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "VANILLA",
    key = "zulgurub", name = "Zul'Gurub", size = 20,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, "Add Tank" }),
            Group("Healing", A:Healers(4)),
            Group("Utility", {
                "Poison Dispel", "Curse Dispel",
                "Primary Interrupt", "Crowd Control",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub",
        }),
        Boss("High Priestess Jeklik", {
            "Jeklik Tank", "Bat Tank",
        }, {
            "Heal Interrupt 1", "Heal Interrupt 2",
            "Bat AoE Lead", "Bomb Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__highpriestessjeklik",
            spellIcon = 23918,
        }),
        Boss("High Priest Venoxis", {
            "Venoxis Tank", "Cobra Tank",
        }, {
            "Holy Wrath Interrupt", "Poison Dispel Lead",
            "Snake Kill Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__highpriestvenoxis",
            spellIcon = 23865,
        }),
        Boss("High Priestess Mar'li", {
            "Mar'li Tank", "Spider Tank",
        }, {
            "Lifedrain Interrupt", "Spider AoE Lead",
            "Web Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__highpriestessmarli",
            spellIcon = 24083,
        }),
        Boss("Bloodlord Mandokir", {
            "Mandokir Tank", "Ohgan Tank",
        }, {
            "Ohgan Kill Lead", "Gaze Caller",
            "Spirits Position Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__bloodlordmandokir",
            spellIcon = 24318,
        }),
        Boss("Edge of Madness: Gri'lek", { A.TANK.MAIN }, {
            "Avatar Kite Lead", "Root Rotation Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__edgeofmadnessgrilek",
            spellIcon = 24728,
        }),
        Boss("Edge of Madness: Hazza'rah", { A.TANK.MAIN }, {
            "Illusion Kill Lead", "Sleep Dispel Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__edgeofmadnesshazzarah",
            spellIcon = 24728,
        }),
        Boss("Edge of Madness: Renataki", { A.TANK.MAIN }, {
            "Vanish Caller", "Ambush Target Healer",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__edgeofmadnessrenataki",
            spellIcon = 24728,
        }),
        Boss("Edge of Madness: Wushoolay", { A.TANK.MAIN }, {
            "Lightning Cloud Caller", "Purge Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__edgeofmadnesswushoolay",
            spellIcon = 24728,
        }),
        Boss("Gahz'ranka", { A.TANK.MAIN }, {
            "Geyser Caller", "Frost Dispel Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__gahzranka",
            spellIcon = 16099,
        }),
        Boss("High Priest Thekal", {
            "Thekal Tank", "Zath Tank", "Lor'Khan Tank",
        }, {
            "Zath Interrupt", "Lor'Khan Interrupt",
            "Tiger AoE Lead", "Simultaneous Kill Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__highpriestthekal",
            spellIcon = 21060,
        }),
        Boss("High Priestess Arlokk", {
            "Arlokk Tank", "Panther Tank 1", "Panther Tank 2",
        }, {
            "Marked Player Healer", "Panther AoE Lead",
            "Vanish Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__highpriestessarlokk",
            spellIcon = 24210,
        }),
        Boss("Jin'do the Hexxer", {
            "Jin'do Tank", "Shade Tank",
        }, {
            "Healing Ward Lead", "Mind Control Totem Lead",
            "Hex Dispel", "Shade Kill Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__jindothehexxer",
            spellIcon = 24306,
        }),
        Encounter("Hakkar", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Sons", {
                "Son Puller 1", "Son Puller 2",
                "Son Kill Caller",
            }),
            Group("Utility", {
                "Mind Control CC 1", "Mind Control CC 2",
                "Corrupted Blood Spread Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub",
            spellIcon = 24324,
        }),
    },
})
