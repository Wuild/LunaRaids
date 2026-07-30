local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "VANILLA",
    key = "molten_core", name = "Molten Core", size = 40,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", {
                A.TANK.MAIN, A.TANK.OFF, "Add Tank 1",
                "Add Tank 2", "Add Tank 3",
            }),
            Group("Healing", A:Healers(12)),
            Group("Utility", {
                "Decurse Lead", "Dispel Lead",
                "Tranq Shot 1", "Tranq Shot 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core",
        }),
        Boss("Lucifron", {
            "Lucifron Tank", "Protector Tank 1", "Protector Tank 2",
        }, {
            "Magic Dispel Lead", "Curse Dispel Lead",
            "Protector Interrupt 1", "Protector Interrupt 2",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core__lucifron",
            spellIcon = 19702,
        }),
        Boss("Magmadar", { A.TANK.MAIN }, {
            "Tranq Shot 1", "Tranq Shot 2", "Fear Ward",
            "Fear Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core__magmadar",
            spellIcon = 19408,
        }),
        Boss("Gehennas", {
            "Gehennas Tank", "Flamewaker Tank 1", "Flamewaker Tank 2",
        }, {
            "Curse Dispel Lead", "Rain of Fire Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core__gehennas",
            spellIcon = 19716,
        }),
        Boss("Garr", {
            "Garr Tank", "Add Tank 1", "Add Tank 2",
            "Add Tank 3", "Add Tank 4",
        }, {
            "Banish 1", "Banish 2", "Banish 3", "Banish 4",
            "Add Kill Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core__garr",
            spellIcon = 15732,
        }),
        Boss("Baron Geddon", { A.TANK.MAIN }, {
            "Living Bomb Caller", "Inferno Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core__barongeddon",
            spellIcon = 19659,
        }),
        Boss("Shazzrah", { A.TANK.MAIN }, {
            "Curse Dispel Lead", "Purge Lead", "Blink Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core__shazzrah",
            spellIcon = 19713,
        }),
        Boss("Sulfuron Harbinger", {
            "Sulfuron Tank", "Priest Tank 1", "Priest Tank 2",
            "Priest Tank 3", "Priest Tank 4",
        }, {
            "Priest Interrupt 1", "Priest Interrupt 2",
            "Priest Interrupt 3", "Priest Interrupt 4",
            "Kill Order Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core__sulfuronharbinger",
            spellIcon = 19776,
        }),
        Boss("Golemagg the Incinerator", {
            "Golemagg Tank", "Core Rager Tank 1",
            "Core Rager Tank 2",
        }, {
            "Rager Position Lead", "Execute Phase Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core__golemaggtheincinerator",
            spellIcon = 461463,
        }),
        Boss("Majordomo Executus", {
            "Majordomo Tank", "Elite Tank 1", "Elite Tank 2",
            "Elite Tank 3", "Elite Tank 4",
        }, {
            "Healer Polymorph 1", "Healer Polymorph 2",
            "Healer Polymorph 3", "Healer Polymorph 4",
            "Kill Order Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core__majordomoexecutus",
            spellIcon = 20534,
        }),
        Boss("Ragnaros", {
            "Ragnaros Tank", "Backup Tank",
            "Son Tank 1", "Son Tank 2",
        }, {
            "Melee Knockback Caller", "Sons Banish 1",
            "Sons Banish 2", "Sons Kill Lead",
        }, 12, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core",
            spellIcon = 20566,
        }),
    },
})
