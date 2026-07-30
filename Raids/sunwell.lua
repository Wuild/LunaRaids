local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "TBC",
    key = "sunwell", name = "Sunwell Plateau", size = 25,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A.TANK.THIRD }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Dispel Lead", "Interrupt Lead", "Dragon Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell",
        }),
        Encounter("Kalecgos", {
            Group("Tanks", {
                "Portal Tank 1", "Portal Tank 2", "Portal Tank 3",
            }),
            Group("Portal Groups", { "Portal Group 1 Lead", "Portal Group 2 Lead", "Portal Group 3 Lead" }),
            Group("Utility", { "Curse Dispel 1", "Curse Dispel 2", "Portal Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell__kalecgos",
            spellIcon = 45018,
            mechanics = {
                Mechanic("Rotate portal groups so tanks, healers, decursers, and damage enter the spectral realm together."),
                Mechanic("Swap tanks before Arcane Buffet grows dangerous and decurse in both realms."),
                Mechanic("Balance Kalecgos and Sathrovarr health, then finish both within the encounter window."),
            },
        }),
        Encounter("Brutallus", {
            Group("Tanks", { "Tank 1", "Tank 2" }),
            Group("Healing", { "Tank 1 Healer 1", "Tank 1 Healer 2", "Tank 2 Healer 1", "Tank 2 Healer 2", "Burn Healer 1", "Burn Healer 2", A.HEALER.RAID }),
            Group("Utility", { "Burn Caller", "Meteor Slash Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell__brutallus",
            spellIcon = 45150,
            mechanics = {
                Mechanic("Two tanks swap after three Meteor Slashes while two raid groups split each cone."),
                Mechanic("Burn targets leave their group without touching anyone and receive dedicated healing."),
                Mechanic("Maintain exact positioning and use all damage cooldowns to beat the enrage."),
            },
        }),
        Encounter("Felmyst", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", A:Healers(7)),
            Group("Encapsulate", { "North Healer", "South Healer" }),
            Group("Utility", { "Vapor Caller", "Mass Dispel 1", "Mass Dispel 2" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell__felmyst",
            spellIcon = 45665,
            mechanics = {
                Mechanic("Spread for Encapsulate, mass-dispel Gas Nova, and keep the tank clear of the raid."),
                Mechanic("During flight, follow Demonic Vapor paths and kill skeletons without crossing the trails."),
                Mechanic("Watch Felmyst's direction and move out of each green fog lane before she breathes."),
            },
        }),
        Encounter("Eredar Twins", {
            Group("Tanks", { "Sacrolash Tank" }),
            Group("Ranged Tank", {
                A:Utility("alythess_tank", "Alythess Ranged Tank"),
            }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Conflagration Caller", "Shadow Image Lead" }),
        }, { "Lady Sacrolash", "Grand Warlock Alythess" }, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell__eredartwins",
            spellIcon = 45248,
            mechanics = {
                Mechanic("A physical tank holds Sacrolash while a ranged tank controls Alythess."),
                Mechanic("Move Conflagration and Shadow Nova away and kill Shadow Images quickly."),
                Mechanic("Balance Fire and Shadow debuffs, then stabilize after the first twin dies."),
            },
        }),
        Encounter("M'uru", {
            Group("Tanks", { "Sentinel Tank", "Left Humanoid Tank", "Right Humanoid Tank", "Void Spawn Tank" }),
            Group("Teams", { "Left Side Lead", "Right Side Lead", "Portal Lead" }),
            Group("Interrupts", { "Left Interrupt 1", "Left Interrupt 2", "Right Interrupt 1", "Right Interrupt 2" }),
        }, {
            "M'uru", "Entropius", "Void Sentinel",
            "Shadowsword Berserker", "Shadowsword Fury Mage",
        }, {
            4, -- M'uru: Moon, cleave target after active adds
            5, -- Entropius: Triangle, phase two
            1, -- Void Sentinel: Skull, ranged priority
            3, -- Berserker: Square
            2, -- Fury Mage: Cross, melee priority
        }, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell__muru",
            spellIcon = 45996,
            mechanics = {
                Mechanic("Split teams left and right to tank and interrupt Berserkers and Fury Mages."),
                Mechanic("Tank Void Sentinels away, then control and AoE their Void Spawns."),
                Mechanic("Enter Entropius with adds cleared; spread, avoid Darkness, and burn through escalating damage."),
            },
        }),
        Encounter("Kil'jaeden", {
            Group("Tanks", { "Sinister Reflection Tank" }),
            Group("Healing", A:Healers(8)),
            Group("Dragon Rotation", { "Dragon 1", "Dragon 2", "Dragon 3", "Dragon 4" }),
            Group("Utility", { "Shield Orb Lead", "Armageddon Caller", "Darkness Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell",
            spellIcon = 45641,
            mechanics = {
                Mechanic("Stack and spread as called, kill Shield Orbs, and control Sinister Reflections."),
                Mechanic("Assigned players use the dragon orbs for Haste, shield, and healing at the planned times."),
                Mechanic("Group under Shield of the Blue for Darkness and move from Armageddon impacts."),
            },
        }),
    },
})
