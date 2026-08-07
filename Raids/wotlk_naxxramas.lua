local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas"

Raid:RegisterRaid({
    expansion = "WOTLK",
    key = "wotlk_naxxramas", name = "Naxxramas", size = 25, instanceID = 533,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Anub'Rekhan", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Crypt Guard Tank",
                "Locust Swarm Kite Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__anubrekhan",
            mechanics = {
                Mechanic("Tank Anub by the door; the add tank collects Crypt Guards while the raid avoids Impale and the Locust Swarm kite path."),
            },
        }),
        Encounter("Grand Widow Faerlina", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Worshipper Control 1",
                "Worshipper Control 2",
                "Frenzy Dispel Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__grandwidowfaerlina",
            mechanics = {
                Mechanic("Keep Worshippers controlled and kill one near Faerlina to remove Frenzy; heroic priests rotate Widow's Embrace mind controls."),
            },
        }),
        Encounter("Maexxna", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Web Wrap Team",
                "Poison Cleanse 1",
                "Poison Cleanse 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__maexxna",
            mechanics = {
                Mechanic("Spread ranged, kill Web Wraps immediately, cleanse poisons, and pre-shield the tank before the final Web Spray enrage."),
            },
        }),
        Encounter("Noth the Plaguebringer", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Curse Dispel 1",
                "Curse Dispel 2",
                "Add Tank",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__noththeplaguebringer",
            mechanics = {
                Mechanic("Tanks swap after Blink threat resets; assigned cleansers remove Curse of the Plaguebringer before Cripple is dispelled."),
            },
        }),
        Encounter("Heigan the Unclean", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Disease Cleanse 1",
                "Disease Cleanse 2",
                "Dance Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__heigantheunclean",
            mechanics = {
                Mechanic("Split cleansing between diseases and position groups through the four safe zones during the eruption dance."),
            },
        }),
        Encounter("Loatheb", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(5)),
            Group("Utility", {
                "Healing Window Caller",
                "Spore Group 1",
                "Spore Group 2",
                "Spore Group 3",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__loatheb",
            mechanics = {
                Mechanic("Build a strict three-second healing rotation around Necrotic Aura gaps and assign spore groups without wasting the crit buff."),
            },
        }),
        Encounter("Instructor Razuvious", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Mind Control Priest 1",
                "Mind Control Priest 2",
                "Mind Control Backup",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__instructorrazuvious",
            mechanics = {
                Mechanic("Priests alternate Mind Control on Understudies, maintaining Bone Barrier and taunting Razuvious on schedule."),
            },
        }),
        Encounter("Gothik the Harvester", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Living Side Lead",
                "Dead Side Lead",
                "Gate Kill Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__gothiktheharvester",
            mechanics = {
                Mechanic("Balance living and dead-side teams, throttle add kills when needed, and tank Gothik centrally after the gate opens."),
            },
        }),
        Encounter("The Four Horsemen", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3), A:Tank("extra", "Extra Tank", 4) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Front Swap Caller",
                "Back Left Tank",
                "Back Right Tank",
                "Back Healer 1",
                "Back Healer 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__thefourhorsemen",
            mechanics = {
                Mechanic("Four tank pairs hold the corners and rotate before marks become lethal; ranged cover Zeliek and Blaumeux."),
            },
        }),
        Encounter("Patchwerk", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Hateful Strike Tank 1",
                "Hateful Strike Tank 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__patchwerk",
            mechanics = {
                Mechanic("Main tank establishes threat while two Hateful Strike tanks remain second and third on threat with the highest health."),
            },
        }),
        Encounter("Grobbulus", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Slime Tank",
                "Injection Position Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__grobbulus",
            mechanics = {
                Mechanic("Tank slowly around the wall; infected players drop clouds behind the raid and an off-tank controls Fallout Slimes."),
            },
        }),
        Encounter("Gluth", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Zombie Kiter 1",
                "Zombie Kiter 2",
                "Decimate AoE Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__gluth",
            mechanics = {
                Mechanic("Two kiters rotate Zombie Chow at the back; decurse Mortal Wound tanks and kill all zombies during Decimate."),
            },
        }),
        Encounter("Thaddius", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Feugen Platform Lead",
                "Stalagg Platform Lead",
                "Polarity Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__thaddius",
            mechanics = {
                Mechanic("Split teams evenly for Feugen and Stalagg, jump together, then stack by charge and cross through the boss on polarity changes."),
            },
        }),
        Encounter("Sapphiron", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Curse Dispel 1",
                "Curse Dispel 2",
                "Ice Block Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__sapphiron",
            mechanics = {
                Mechanic("Decursers remove Life Drain, healers cover frost aura, and players spread before hiding behind marked Ice Blocks."),
            },
        }),
        Encounter("Kel'Thuzad", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Frostbolt Interrupt 1",
                "Frostbolt Interrupt 2",
                "Frostbolt Interrupt 3",
                "Guardian Tank",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_naxxramas__kelthuzad",
            mechanics = {
                Mechanic("Spread six yards, interrupt Frostbolt, collapse only for Frost Blast, and have the off-tank collect Guardians without cleaving the raid."),
            },
        }),
    },
})
