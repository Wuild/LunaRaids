local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel"

Raid:RegisterRaid({
    expansion = "WOTLK",
    key = "icecrown_citadel", name = "Icecrown Citadel", size = 25,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Lord Marrowgar", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Bone Spike Kill Lead",
                "Bone Storm Position Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__lordmarrowgar",
            mechanics = {
                Mechanic("Tanks stack to split Saber Lash, ranged spread, kill Bone Spikes immediately, and avoid Coldflame during Bone Storm."),
            },
        }),
        Encounter("Lady Deathwhisper", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Left Add Lead",
                "Right Add Lead",
                "Frostbolt Interrupt 1",
                "Frostbolt Interrupt 2",
                "Curse Dispel",
                "Dominate Mind Control",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__ladydeathwhisper",
            mechanics = {
                Mechanic("Split add teams by side and armor type, interrupt Frostbolt, dispel shields/curses, and rotate tanks when phase-two threat resets."),
            },
        }),
        Encounter("Gunship Battle", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Cannon 1",
                "Cannon 2",
                "Cannon 3",
                "Cannon 4",
                "Boarding Tank",
                "Boarding Team Lead",
                "Battle-Mage Kill Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__gunshipbattle",
            mechanics = {
                Mechanic("Assign cannon operators, a boarding tank and strike team, and ranged defenders to kill axe throwers and the enemy battle-mage."),
            },
        }),
        Encounter("Deathbringer Saurfang", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Blood Beast Control 1",
                "Blood Beast Control 2",
                "Blood Beast Control 3",
                "Mark Healer 1",
                "Mark Healer 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__deathbringersaurfang",
            mechanics = {
                Mechanic("Ranged spread and snare Blood Beasts without being hit; healers own Mark targets and tanks swap on Rune of Blood."),
            },
        }),
        Encounter("Festergut", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Melee Spore",
                "Ranged Spore Left",
                "Ranged Spore Right",
                "Pungent Blight Cooldown 1",
                "Pungent Blight Cooldown 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__festergut",
            mechanics = {
                Mechanic("Tanks swap at nine Gastric Bloat stacks, ranged form three spore positions, and raid cooldowns cover unmitigated Pungent Blight."),
            },
        }),
        Encounter("Rotface", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Big Ooze Tank",
                "Infection Dispel",
                "Ooze Merge Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__rotface",
            mechanics = {
                Mechanic("The off-tank kites the Big Ooze around the room; infected players meet it at the edge and ranged avoid slime spray and floods."),
            },
        }),
        Encounter("Professor Putricide", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Abomination Driver",
                "Volatile Ooze Caller",
                "Gas Cloud Caller",
                "Plague Swap Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__professorputricide",
            mechanics = {
                Mechanic("Assign an Abomination driver, swap tanks on Mutated Plague, stack then move for Gas/Ooze targets, and control Malleable Goo lanes."),
            },
        }),
        Encounter("Blood Prince Council", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Valanar-Taldaram Tank",
                "Keleseth Ranged Tank",
                "Kinetic Bomb 1",
                "Kinetic Bomb 2",
                "Kinetic Bomb 3",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__bloodprincecouncil",
            mechanics = {
                Mechanic("Use physical tanks for Valanar/Taldaram and a ranged tank to gather Dark Nuclei on Keleseth; keep kinetic bombs airborne."),
            },
        }),
        Encounter("Blood-Queen Lana'thel", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Bite Chain 1",
                "Bite Chain 2",
                "Bite Chain 3",
                "Pact Caller",
                "Fear Ward",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__bloodqueenlanathel",
            mechanics = {
                Mechanic("Preassign the full bite chain, pair Pact targets at center, spread for air phase, and use fear protection before Bloodbolt Whirl."),
            },
        }),
        Encounter("Valithria Dreamwalker", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Portal Healer 1",
                "Portal Healer 2",
                "Portal Healer 3",
                "Frostbolt Volley Interrupt 1",
                "Suppressor Kill Lead",
                "Abomination Tank",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__valithriadreamwalker",
            mechanics = {
                Mechanic("Portal healers collect stacked clouds and heal Valithria; outside teams interrupt Frostbolt Volley and control suppressors and abominations."),
            },
        }),
        Encounter("Sindragosa", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Ice Tomb Position 1",
                "Ice Tomb Position 2",
                "Ice Tomb Position 3",
                "Mystic Buffet Reset Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__sindragosa",
            mechanics = {
                Mechanic("Tanks swap Mystic Buffet, casters and melee manage stacking debuffs, and marked Ice Tombs form assigned lines without trapping others."),
            },
        }),
        Encounter("The Lich King", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Horror Tank",
                "Enrage Dispel",
                "Val'kyr Stun 1",
                "Val'kyr Stun 2",
                "Defile Caller",
                "Soul Reaper Cooldown 1",
                "Soul Reaper Cooldown 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\icecrown_citadel__thelichking",
            mechanics = {
                Mechanic("Assign Shambling Horror enrage dispels, Val'kyr stuns, Defile positions, Harvest Soul teams, and coordinated cooldowns through Soul Reaper."),
            },
        }),
    },
})
