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
    key = "naxxramas", name = "Naxxramas", size = 40,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas",
    guides = {
        ["Anub'Rekhan"] = {
            Mechanic("Tank Anub'Rekhan near the outer wall and kite the perimeter during Locust Swarm without crossing the raid."),
            Mechanic("Off-tanks collect Crypt Guards; kill and control corpses or scarabs while ranged avoid Impale lines."),
        },
        ["Grand Widow Faerlina"] = {
            Mechanic("Off-tanks hold the worshippers away from Faerlina while the raid burns or controls followers."),
            Mechanic("Use a worshipper at each Frenzy to remove it; dispel poison and spread for Rain of Fire."),
        },
        ["Maexxna"] = {
            Mechanic("Assign ranged players to destroy Web Wraps immediately and cleanse poison from the tank."),
            Mechanic("Top everyone before Web Spray; save tank cooldowns and burst healing for the enrage below 30%."),
        },
        ["Noth the Plaguebringer"] = {
            Mechanic("Decurse Curse of the Plaguebringer immediately and tank adds away from Noth."),
            Mechanic("During balcony phases, group and kill Plagued Warriors, then re-establish boss threat on return."),
        },
        ["Heigan the Unclean"] = {
            Mechanic("Melee and the tank follow the safe platform pattern while ranged and healers avoid mana burns on the platform."),
            Mechanic("During the dance phase everyone follows the eruption zones together; cleanse disease promptly afterward."),
        },
        ["Loatheb"] = {
            Mechanic("Set a strict healer rotation around the healing lockout and time large heals immediately when each window opens."),
            Mechanic("Groups rotate through spores without killing them early; use consumables and personal mitigation between heals."),
        },
        ["Instructor Razuvious"] = {
            Mechanic("Priests mind-control Understudies and rotate Bone Barrier while using Taunt to tank Razuvious."),
            Mechanic("Backups control loose Understudies; healers keep the active controlled add alive through Unbalancing Strike."),
        },
        ["Gothik the Harvester"] = {
            Mechanic("Split the raid between living and dead sides and balance kills so neither side is overwhelmed."),
            Mechanic("Control dangerous trainees and riders, then regroup and tank Gothik after the gate opens."),
        },
        ["The Four Horsemen"] = {
            Mechanic("Four corner teams rotate or swap before marks stack too high; never drag a horseman toward another corner."),
            Mechanic("Back corners maintain ranged threat and healing while the front pair execute the planned tank rotation."),
        },
        ["Patchwerk"] = {
            Mechanic("Main and Hateful Strike tanks establish the top threat positions and remain stacked in melee range."),
            Mechanic("Dedicated healers spam assigned tanks; DPS delay briefly for threat, then burn before the enrage."),
        },
        ["Grobbulus"] = {
            Mechanic("Kite Grobbulus slowly around the room and keep the raid behind him to control Slime Spray adds."),
            Mechanic("Mutating Injection targets move to the outer wall before dispel or expiration and leave clouds behind the group."),
        },
        ["Gluth"] = {
            Mechanic("Tanks swap before Mortal Wound becomes unhealable while hunters keep Tranquilizing Shot ready."),
            Mechanic("Kiting teams slow Zombie Chow around the room; burn them during Decimate before they reach Gluth."),
        },
        ["Thaddius"] = {
            Mechanic("Split evenly for Feugen and Stalagg and kill both within seconds while tanks handle platform swaps."),
            Mechanic("After the jump, move instantly to the correct polarity side and switch sides without crossing through others."),
        },
        ["Sapphiron"] = {
            Mechanic("Spread around Sapphiron's sides, avoid Blizzard, and decurse Life Drain while sustaining frost aura damage."),
            Mechanic("During air phases spread for Icebolt, then hide behind an ice block before Frost Breath."),
        },
        ["Kel'Thuzad"] = {
            Mechanic("Phase 1 groups control incoming undead without entering the center; save cooldowns for Kel'Thuzad."),
            Mechanic("Spread for Frost Blast and mana detonation, interrupt Frostbolt, and free mind-controlled players safely."),
            Mechanic("Off-tanks pick up both Guardians in the final phase while damage remains focused on the boss."),
        },
    },
    recommendations = {
        Rec("mind control", { "PRIEST" }, { "Shadow", "Discipline", "Holy" }, Reuse),
        Rec("understudy controller", { "PRIEST" }, { "Shadow", "Discipline", "Holy" }, Reuse),
        Rec("zombie chow kiter", { "HUNTER", "MAGE", "WARLOCK" }, { "Marksmanship", "Frost", "Affliction" }),
        Rec("crowd control", { "MAGE", "WARLOCK", "HUNTER", "PRIEST" }, { "Frost", "Affliction", "Survival", "Shadow" }),
        Rec("decurse", { "MAGE", "DRUID" }, { "Arcane", "Frost", "Restoration", "Balance" }, Reuse),
        Rec("dispel", { "PRIEST", "PALADIN", "SHAMAN" }, { "Discipline", "Holy", "Restoration" }, Reuse),
        Rec("interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
    },
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
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\naxxramas__kelthuzad",
        }),
    },
})
