local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder"

Raid:RegisterRaid({
    expansion = "MOP",
    key = "throne_of_thunder", name = "Throne of Thunder", size = 25,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Jin'rokh the Breaker", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Pool Position Caller",
                "Focused Lightning Caller",
                "Lightning Storm Cooldown 1",
                "Lightning Storm Cooldown 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__jinrokhthebreaker",
            mechanics = {
                Mechanic("Place each Conductive Water pool in order, spread Focused Lightning fissures outside pools, and rotate cooldowns during Lightning Storm."),
            },
        }),
        Encounter("Horridon", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Gate 1 Interrupt",
                "Gate 2 Poison Dispel",
                "Gate 3 Disease Dispel",
                "Gate 4 Interrupt",
                "Dinomancer Kill Lead",
                "Add Tank",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__horridon",
            mechanics = {
                Mechanic("Assign interrupt/dispels per gate, off-tank all tribes, use Dinomancer orb promptly, and swap boss tanks as Triple Puncture grows."),
            },
        }),
        Encounter("Council of Elders", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Sand Bolt Interrupt",
                "Wrath Interrupt",
                "Loa Spirit Stun 1",
                "Loa Spirit Stun 2",
                "Possession Swap Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__councilofelders",
            mechanics = {
                Mechanic("Assign one tank to Frost King and one to the other elders, interrupt Sand Bolt/Wrath, break Loa Spirits, and focus the possessed target."),
            },
        }),
        Encounter("Tortos", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Shell Kicker 1",
                "Shell Kicker 2",
                "Shell Kicker 3",
                "Bat Tank",
                "Bat AoE Lead",
                "Crystal Shield Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__tortos",
            mechanics = {
                Mechanic("Assign shell kickers for each Furious Stone Breath, a bat tank and AoE team, and crystal-shield maintenance on heroic."),
            },
        }),
        Encounter("Megaera", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Head Kill Caller",
                "Cinders Dispel",
                "Torrent of Ice Caller",
                "Nether Wyrm Interrupt 1",
                "Rampage Cooldown 1",
                "Rampage Cooldown 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__megaera",
            mechanics = {
                Mechanic("Set head-kill order, spread Cinders safely, group Arcane Ice movement, interrupt Nether Wyrms on heroic, and rotate Rampage cooldowns."),
            },
        }),
        Encounter("Ji-Kun", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Nest Team 1",
                "Nest Team 2",
                "Nest Team 3",
                "Feed Pool Soaker 1",
                "Feed Pool Soaker 2",
                "Nest Cycle Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__jikun",
            mechanics = {
                Mechanic("Preassign nest teams and feather users by platform cycle, intercept Feed Young pools, and use defensives for Quills and Down Draft."),
            },
        }),
        Encounter("Durumu the Forgotten", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Red Beam Lead",
                "Blue Beam Lead",
                "Yellow Beam Lead",
                "Life Drain Soaker 1",
                "Life Drain Soaker 2",
                "Maze Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__durumutheforgotten",
            mechanics = {
                Mechanic("Assign red/blue/yellow beam teams, find and kill Crimson Fogs, spread Life Drain intercept rotations, and call maze safe lanes."),
            },
        }),
        Encounter("Primordius", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Mutation Group 1",
                "Mutation Group 2",
                "Living Fluid Control",
                "Evolution Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__primordius",
            mechanics = {
                Mechanic("Assign players to collect five beneficial mutations without taking bad pools, interrupt/avoid evolved abilities, and keep living fluids from the boss."),
            },
        }),
        Encounter("Dark Animus", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Anima Map Caller",
                "Massive Golem Tank 1",
                "Massive Golem Tank 2",
                "Interrupting Jolt Cooldown",
                "Anima Ring Partner",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__darkanimus",
            mechanics = {
                Mechanic("Map every player to a small golem, transfer anima in a fixed sequence, interrupt Jolt, and keep empowered golems separated."),
            },
        }),
        Encounter("Iron Qon", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Unleashed Flame Group 1",
                "Unleashed Flame Group 2",
                "Spear Position Caller",
                "Wind Storm Exit Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__ironqon",
            mechanics = {
                Mechanic("Tanks swap Impale, spread spear lines, use fixed groups for Unleashed Flame, clear ice safely, and stack the final quilen for cooldowns."),
            },
        }),
        Encounter("Twin Consorts", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Crane Celestial",
                "Tiger Celestial",
                "Ox Celestial",
                "Serpent Celestial",
                "Nuclear Inferno Cooldown",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__twinconsorts",
            mechanics = {
                Mechanic("Tank each twin in her active phase, assign celestial drawing users, spread for Inferno/Comet mechanics, and rotate nuclear cooldowns."),
            },
        }),
        Encounter("Lei Shen", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "North Quadrant Lead",
                "East Quadrant Lead",
                "South Quadrant Lead",
                "West Quadrant Lead",
                "Static Shock Soak Group",
                "Ball Lightning Stun 1",
                "Transition Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__leishen",
            mechanics = {
                Mechanic("Preassign quadrant groups and conduit order, soak Static Shock, split Diffusion Chain targets, stun Ball Lightning, and call transition positions."),
            },
        }),
        Encounter("Ra-den", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Orb Kill Caller",
                "Vita Bounce 1",
                "Vita Bounce 2",
                "Vita Bounce 3",
                "Anima Healer",
                "Phase 2 Cooldown Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_thunder__raden",
            mechanics = {
                Mechanic("Set Vita/Anima orb kill order, assign Unstable Vita bounce positions and Anima heal-absorb coverage, then chain phase-two cooldowns."),
            },
        }),
    },
})
