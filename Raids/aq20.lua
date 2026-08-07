local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic
local Rec = Raid.Recommendation
local Reuse = { roles = { Raid.Role.HEALER, Raid.Role.DAMAGE }, allowReuse = true }

local raid = Raid:RegisterRaid({
    expansion = "VANILLA",
    key = "aq20", name = "Ruins of Ahn'Qiraj", size = 20, instanceID = 509,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq20",
    guides = {
        ["Kurinnaxx"] = {
            Mechanic("Tanks swap as Mortal Wounds stack and keep Kurinnaxx facing away from the raid."),
            Mechanic("Spread to reduce Sand Trap hits, move immediately when one forms, and burn through the final frenzy."),
        },
        ["General Rajaxx"] = {
            Mechanic("Keep Lieutenant General Andorov alive and fight each incoming wave at the established position."),
            Mechanic("Mark and focus dangerous officers, control loose adds, and save cooldowns for General Rajaxx."),
        },
        ["Moam"] = {
            Mechanic("Drain Moam's mana continuously and burn before he reaches full mana and casts Arcane Eruption."),
            Mechanic("When Mana Fiends spawn, tank and banish or focus them quickly while staying spread for their attacks."),
        },
        ["Buru the Gorger"] = {
            Mechanic("Kite Buru over weakened eggs and destroy each egg only when he is positioned on top of it."),
            Mechanic("In the final phase, stop kiting, dispel Creeping Plague where possible, and burn through raid damage."),
        },
        ["Ayamiss the Hunter"] = {
            Mechanic("Ranged damage Ayamiss during the air phase while assigned players kill larvae before they reach sacrifices."),
            Mechanic("At 70%, tanks pick up the grounded boss; melee join and the raid continues controlling larvae and poison."),
        },
        ["Ossirian the Unscarred"] = {
            Mechanic("A scout locates active crystals; move Ossirian to each crystal to apply a vulnerability before his buff returns."),
            Mechanic("Tanks rotate through knockbacks, ranged stay spread, and DPS switch elements to match the active weakness."),
        },
    },
    recommendations = {
        Rec("interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
        Rec("dispel", { "PRIEST", "PALADIN", "SHAMAN" }, { "Discipline", "Holy", "Restoration" }, Reuse),
        Rec("kite", { "HUNTER", "MAGE", "WARLOCK" }, { "Marksmanship", "Frost", "Affliction" }),
    },
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
