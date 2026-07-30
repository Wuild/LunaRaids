local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "VANILLA",
    key = "aq20", name = "Ruins of Ahn'Qiraj", size = 20,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq20",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, "Add Tank" }),
            Group("Healing", A:Healers(4)),
            Group("Utility", {
                "Poison Dispel", "Disease Dispel",
                "Primary Interrupt",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq20",
        }),
        Boss("Kurinnaxx", { A.TANK.MAIN, A.TANK.OFF }, {
            "Tank Swap Caller", "Sand Trap Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq20__kurinnaxx",
            spellIcon = 25646,
        }),
        Encounter("General Rajaxx", {
            Group("Tanks", {
                "Rajaxx Tank", "Wave Tank 1", "Wave Tank 2",
            }),
            Group("Healing", A:Healers(5)),
            Group("Utility", {
                "Wave Kill Caller", "Andorov Healer",
                "Thundercrash Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq20__generalrajaxx",
            spellIcon = 25471,
        }),
        Boss("Moam", { A.TANK.MAIN, "Mana Fiend Tank" }, {
            "Mana Drain 1", "Mana Drain 2",
            "Mana Fiend Banish 1", "Mana Fiend Banish 2",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq20__moam",
            spellIcon = 25685,
        }),
        Boss("Buru the Gorger", {
            "Buru Kiter", "Hatchling Tank",
        }, {
            "Egg 1 Lead", "Egg 2 Lead", "Egg 3 Lead",
            "Final Phase Dispel",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq20__buruthegorger",
        }),
        Boss("Ayamiss the Hunter", {
            "Ayamiss Tank", "Larva Tank",
        }, {
            "Sacrifice Platform Lead", "Larva Kill Lead",
            "Poison Dispel",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq20__ayamissthehunter",
            spellIcon = 25725,
        }),
        Boss("Ossirian the Unscarred", { A.TANK.MAIN, A.TANK.OFF }, {
            "Crystal Runner 1", "Crystal Runner 2",
            "Weakness Caller", "Tornado Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq20",
            spellIcon = 25176,
        }),
    },
})
