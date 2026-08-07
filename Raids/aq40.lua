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
    key = "aq40", name = "Temple of Ahn'Qiraj", size = 40, instanceID = 531,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq40",
    guides = {
        ["The Prophet Skeram"] = {
            Mechanic("Split tanks and damage across all platforms before each image phase; interrupt Arcane Explosion with Earth Shock."),
            Mechanic("Crowd-control mind-controlled players without killing them and identify the real Skeram quickly after splits."),
        },
        ["The Bug Trio"] = {
            Mechanic("Separate all three bosses and follow the chosen kill order; each death fully heals the survivors."),
            Mechanic("Interrupt Yauj's heals, dispel Kri's poison, control spawned bugs, and keep Vem away from other groups."),
        },
        ["Battleguard Sartura"] = {
            Mechanic("Tanks and stun teams control Sartura and her guards separately while the raid focuses guards first."),
            Mechanic("Spread during Whirlwind, avoid chasing through other groups, and re-establish tank control when spinning ends."),
        },
        ["Fankriss the Unyielding"] = {
            Mechanic("Tanks rotate for Mortal Wound while the raid stays positioned to avoid frontal damage."),
            Mechanic("Root and immediately kill Spawn of Fankriss; assigned players watch tunnel exits for new adds."),
        },
        ["Viscidus"] = {
            Mechanic("Apply many frost hits to freeze Viscidus, then switch to rapid melee hits to shatter him."),
            Mechanic("Use poison-cleansing rotations throughout and destroy globules with coordinated AoE before they reform."),
        },
        ["Princess Huhuran"] = {
            Mechanic("Hunters rotate Tranquilizing Shot and tanks manage Wyvern Sting or threat without facing Huhuran into the raid."),
            Mechanic("At 30%, assigned nature-resistant soakers move in and healers use cooldowns through the enrage burn."),
        },
        ["The Twin Emperors"] = {
            Mechanic("A physical tank holds Vek'nilash while a warlock tanks Vek'lor; everyone clears the center before teleports."),
            Mechanic("Rebuild threat instantly after each swap, control exploding bugs, and keep both emperors separated to prevent healing."),
        },
        ["Ouro"] = {
            Mechanic("Tanks maintain the rotation around Sweep and Sand Blast while ranged manage threat from maximum range."),
            Mechanic("During submerge, avoid moving mounds and regroup quickly; below 20%, spread and finish during the stationary phase."),
        },
        ["C'Thun"] = {
            Mechanic("Phase 1: maintain strict spacing around the room, turn away from Eye Beam chains, and interrupt Giant Eyes."),
            Mechanic("Inside the stomach, kill tentacles and exit before stacks become lethal; outside teams control all adds."),
            Mechanic("When weakened, everyone burns C'Thun, then immediately resumes positions if another cycle is needed."),
        },
    },
    recommendations = {
        Rec("warlock tank", { "WARLOCK" }, { "Destruction", "Demonology" }),
        Rec("freeze", { "MAGE" }, { "Frost" }),
        Rec("interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
        Rec("poison", { "SHAMAN", "DRUID", "PALADIN" }, { "Restoration", "Balance", "Holy" }, Reuse),
        Rec("stomach", { "ROGUE", "WARRIOR", "MAGE" }, { "Combat", "Fury", "Fire", "Frost" }),
        Rec("nature resistance", { "HUNTER", "SHAMAN" }, { "Survival", "Restoration", "Elemental" }, Reuse),
    },
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", {
                A.TANK.MAIN, A.TANK.OFF, A.TANK.THIRD,
                "Add Tank 1", "Add Tank 2",
            }),
            Group("Healing", A:Healers(12)),
            Group("Utility", {
                "Nature Resistance Lead", "Poison Dispel Lead",
                "Interrupt Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq40",
        }),
        Boss("The Prophet Skeram", {
            "Skeram Tank", "Image Tank 1", "Image Tank 2",
        }, {
            "Earth Shock 1", "Earth Shock 2",
            "Mind Control CC 1", "Mind Control CC 2",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq40__theprophetskeram",
            spellIcon = 20449,
        }),
        Encounter("The Bug Trio", {
            Group("Tanks", {
                "Kri Tank", "Vem Tank", "Yauj Tank",
            }),
            Group("Healing", A:Healers(10)),
            Group("Utility", {
                "Kill Order Caller", "Yauj Interrupt",
                "Poison Dispel Lead", "Spawn AoE Lead",
            }),
        }, {
            "Lord Kri", "Vem", "Princess Yauj",
        }, {
            1, -- Kri: Skull, first
            3, -- Vem: Square, last
            2, -- Yauj: Cross, second
        }, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq40__thebugtrio",
            spellIcon = 26580,
        }),
        Boss("Battleguard Sartura", {
            "Sartura Tank", "Guard Tank 1", "Guard Tank 2",
            "Guard Tank 3",
        }, {
            "Guard Stun Lead 1", "Guard Stun Lead 2",
            "Whirlwind Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq40__battleguardsartura",
            spellIcon = 8269,
        }),
        Boss("Fankriss the Unyielding", {
            "Fankriss Tank", "Spawn Tank 1", "Spawn Tank 2",
        }, {
            "Spawn Root 1", "Spawn Root 2",
            "Mortal Wound Swap Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq40__fankrisstheunyielding",
            spellIcon = 25646,
        }),
        Encounter("Viscidus", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", A:Healers(12)),
            Group("Freeze", {
                "Frost Hit Lead", "Melee Shatter Lead",
                "Engineering AoE Lead",
            }),
            Group("Utility", {
                "Poison Cleanse 1", "Poison Cleanse 2",
                "Poison Cleanse 3",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq40__viscidus",
            spellIcon = 25991,
        }),
        Boss("Princess Huhuran", { A.TANK.MAIN, A.TANK.OFF }, {
            "Tranq Shot 1", "Tranq Shot 2",
            "Poison Dispel Lead", "Soaker Group Lead",
        }, 12, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq40__princesshuhuran",
            spellIcon = 26180,
        }),
        Encounter("The Twin Emperors", {
            Group("Tanks", {
                A:Tank("veknilash", "Vek'nilash Tank"),
                "Bug Tank 1", "Bug Tank 2",
            }),
            Group("Ranged Tank", {
                A:Utility("veklor_tank", "Vek'lor Warlock Tank"),
                A:Utility("veklor_tank_backup", "Vek'lor Tank Backup"),
            }),
            Group("Healing", {
                "Vek'nilash Healer 1", "Vek'nilash Healer 2",
                "Vek'lor Healer 1", "Vek'lor Healer 2",
                A:Healer(A.Target.RAID, 1), A:Healer(A.Target.RAID, 2),
            }),
            Group("Utility", {
                "Teleport Caller", "Blizzard Caller",
            }),
        }, { "Emperor Vek'nilash", "Emperor Vek'lor" }, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq40__thetwinemperors",
            spellIcon = 26613,
        }),
        Boss("Ouro", {
            A.TANK.MAIN, A.TANK.OFF, "Sweep Tank",
        }, {
            "Submerge Caller", "Mound Caller",
            "Tank Rotation Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq40__ouro",
            spellIcon = 26103,
        }),
        Encounter("C'Thun", {
            Group("Tanks", {
                A:Tank("giant_claw", "Giant Claw Tank", 1),
                A:Tank("giant_claw", "Giant Claw Tank", 2),
            }),
            Group("Healing", A:Healers(12)),
            Group("Stomach", {
                A:Utility("stomach_group_lead", "Stomach Group Lead", 1),
                A:Utility("stomach_group_lead", "Stomach Group Lead", 2),
            }),
            Group("Utility", {
                "Eye Beam Position Caller", "Giant Eye Interrupt 1",
                "Giant Eye Interrupt 2", "Weakened Phase Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\aq40",
            spellIcon = 26029,
        }),
    },
})
