local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "VANILLA",
    key = "naxxramas", name = "Naxxramas", size = 40,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", {
                A.TANK.MAIN, A.TANK.OFF, A.TANK.THIRD,
                "Add Tank 1", "Add Tank 2",
            }),
            Group("Healing", A:Healers(12)),
            Group("Utility", {
                "Decurse Lead", "Disease Dispel Lead",
                "Poison Dispel Lead", "Frost Resistance Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas",
        }),
        Boss("Anub'Rekhan", {
            "Anub'Rekhan Tank", "Crypt Guard Tank",
        }, {
            "Locust Swarm Caller", "Crypt Guard Kill Lead",
            "Corpse Scarab AoE Lead",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__anubrekhan",
        }),
        Boss("Grand Widow Faerlina", {
            "Faerlina Tank", "Worshipper Tank", "Follower Tank",
        }, {
            "Worshipper Silence 1", "Worshipper Silence 2",
            "Enrage Dispel Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__grandwidowfaerlina",
        }),
        Boss("Maexxna", { A.TANK.MAIN }, {
            "Web Wrap Left", "Web Wrap Right",
            "Poison Dispel Lead", "Web Spray Cooldown Caller",
        }, 12, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__maexxna",
            spellIcon = 19134,
        }),
        Boss("Noth the Plaguebringer", {
            "Noth Tank", "Add Tank 1", "Add Tank 2",
        }, {
            "Curse Dispel Lead", "Blink Caller",
            "Add Kill Lead",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__noththeplaguebringer",
        }),
        Boss("Heigan the Unclean", { A.TANK.MAIN }, {
            "Dance Caller", "Disease Dispel Lead",
            "Platform Group Lead",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__heigantheunclean",
        }),
        Boss("Loatheb", { A.TANK.MAIN }, {
            "Heal Rotation 1", "Heal Rotation 2",
            "Heal Rotation 3", "Heal Rotation 4",
            "Spore Group 1", "Spore Group 2", "Spore Group 3",
        }, 12, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__loatheb",
        }),
        Encounter("Instructor Razuvious", {
            Group("Healing", A:Healers(10)),
            Group("Mind Control", {
                A:Utility("understudy_controller", "Understudy Controller", 1),
                A:Utility("understudy_controller", "Understudy Controller", 2),
                A:Utility("mind_control_backup", "Mind Control Backup", 1),
                A:Utility("mind_control_backup", "Mind Control Backup", 2),
            }),
            Group("Utility", {
                "Taunt Rotation Caller", "Understudy Healing Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__instructorrazuvious",
        }),
        Boss("Gothik the Harvester", {
            "Live Side Tank 1", "Live Side Tank 2",
            "Dead Side Tank 1", "Dead Side Tank 2",
        }, {
            "Live Side Lead", "Dead Side Lead",
            "Gate Open Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__gothiktheharvester",
        }),
        Encounter("The Four Horsemen", {
            Group("Tanks", {
                "Mograine Tank 1", "Mograine Tank 2",
                "Thane Tank 1", "Thane Tank 2",
                "Blaumeux Tank 1", "Blaumeux Tank 2",
                "Zeliek Tank 1", "Zeliek Tank 2",
            }),
            Group("Healing", A:Healers(12)),
            Group("Utility", {
                "Front Rotation Caller", "Back Rotation Caller",
            }),
        }, {
            "Highlord Mograine", "Thane Korth'azz",
            "Lady Blaumeux", "Sir Zeliek",
        }, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__thefourhorsemen",
        }),
        Boss("Patchwerk", {
            A.TANK.MAIN, "Hateful Tank 1",
            "Hateful Tank 2", "Hateful Tank 3",
        }, {
            "Hateful Tank Caller", "Enrage Cooldown Caller",
        }, 12, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__patchwerk",
        }),
        Boss("Grobbulus", {
            "Grobbulus Tank", "Slime Tank",
        }, {
            "Injection Caller", "Cloud Position Caller",
            "Slime Kill Lead",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__grobbulus",
        }),
        Encounter("Gluth", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(10)),
            Group("Kiting", {
                A:Utility("zombie_kiter", "Zombie Chow Kiter", 1),
                A:Utility("zombie_kiter", "Zombie Chow Kiter", 2),
            }),
            Group("Utility", {
                "Decimate Caller", "Zombie Slow 1",
                "Zombie Slow 2", "Enrage Dispel",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__gluth",
        }),
        Encounter("Thaddius", {
            Group("Tanks", {
                "Stalagg Tank", "Feugen Tank", "Thaddius Tank",
            }),
            Group("Healing", A:Healers(10)),
            Group("Utility", {
                "Stalagg Side Lead", "Feugen Side Lead",
                "Positive Side Lead", "Negative Side Lead",
                "Polarity Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__thaddius",
            spellIcon = 1219235,
        }),
        Boss("Sapphiron", { A.TANK.MAIN }, {
            "Decurse Lead", "Ice Block Caller",
            "Frost Aura Cooldown Lead",
        }, 12, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__sapphiron",
        }),
        Encounter("Kel'Thuzad", {
            Group("Tanks", {
                "Kel'Thuzad Tank", "Guardian Tank 1",
                "Guardian Tank 2",
            }),
            Group("Healing", A:Healers(12)),
            Group("Crowd Control", {
                "Mind Control CC 1", "Mind Control CC 2",
                "Mind Control CC 3",
            }),
            Group("Utility", {
                "Frost Blast Healer 1", "Frost Blast Healer 2",
                "Interrupt 1", "Interrupt 2", "Interrupt 3",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas",
        }),
    },
})
