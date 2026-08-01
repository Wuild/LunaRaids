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
    key = "blackwing_lair", name = "Blackwing Lair", size = 40,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair",
    guides = {
        ["Razorgore the Untamed"] = {
            Mechanic("Orb controllers destroy eggs methodically while four teams control spawning dragonkin and orcs."),
            Mechanic("After the last egg, tanks establish threat, face Razorgore away, and the raid avoids his frontal attacks."),
        },
        ["Vaelastrasz the Corrupt"] = {
            Mechanic("Tanks stand in a fixed threat order; the active tank faces Vaelastrasz away from the raid."),
            Mechanic("Burn Essence of the Red resources aggressively; Burning Adrenaline targets leave the group before exploding."),
        },
        ["Broodlord Lashlayer"] = {
            Mechanic("Tank Broodlord in the corner with the raid behind him and rotate tanks as Mortal Strike pressure rises."),
            Mechanic("Melee manage threat around Knock Away, while healers keep the current tank stable through Blast Wave."),
        },
        ["Firemaw"] = {
            Mechanic("Use line of sight to drop Flame Buffet stacks; only the active tank remains exposed continuously."),
            Mechanic("Tanks taunt through Wing Buffet and ranged step out to reset stacks before they become lethal."),
        },
        ["Ebonroc"] = {
            Mechanic("Tanks rotate taunts so the tank afflicted by Shadow of Ebonroc is not being hit."),
            Mechanic("Stay out of the frontal cone and keep the boss positioned consistently through Wing Buffet swaps."),
        },
        ["Flamegor"] = {
            Mechanic("Tanks handle Wing Buffet swaps while keeping Flamegor faced away from the raid."),
            Mechanic("Hunters maintain a Tranquilizing Shot rotation on Frenzy and healers anticipate missed shots."),
        },
        ["Chromaggus"] = {
            Mechanic("Use line of sight for every breath and assign dispellers to remove each class-removable affliction."),
            Mechanic("Hunters tranquilize Frenzy; anyone reaching multiple Brood Afflictions calls it before transformation."),
        },
        ["Nefarian"] = {
            Mechanic("Phase 1 teams control and kill drakonids by color while conserving enough resources for Nefarian."),
            Mechanic("Face Nefarian away, react to class calls, decurse or dispel quickly, and prepare AoE for skeletons at 20%."),
        },
    },
    recommendations = {
        Rec("tranq", { "HUNTER" }, { "Marksmanship", "Beast Mastery", "Survival" }),
        Rec("decurse", { "MAGE", "DRUID" }, { "Arcane", "Frost", "Restoration", "Balance" }, Reuse),
        Rec("dispel", { "PRIEST", "PALADIN", "SHAMAN" }, { "Discipline", "Holy", "Restoration" }, Reuse),
        Rec("kite", { "HUNTER", "MAGE", "WARLOCK" }, { "Marksmanship", "Frost", "Affliction" }),
        Rec("orb", { "ROGUE", "HUNTER", "MAGE" }, { "Combat", "Marksmanship", "Frost" }),
    },
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", {
                A.TANK.MAIN, A.TANK.OFF, A.TANK.THIRD,
                "Add Tank 1", "Add Tank 2",
            }),
            Group("Healing", A:Healers(12)),
            Group("Utility", {
                "Tranq Shot 1", "Tranq Shot 2",
                "Dispel Lead", "Suppression Room Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair",
        }),
        Boss("Razorgore the Untamed", {
            "Razorgore Tank", "East Add Tank 1", "East Add Tank 2",
            "West Add Tank 1", "West Add Tank 2",
        }, {
            "Orb Controller 1", "Orb Controller 2",
            "East Kiter", "West Kiter", "Egg Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__razorgoretheuntamed",
            spellIcon = 22425,
        }),
        Boss("Vaelastrasz the Corrupt", {
            "Tank 1", "Tank 2", "Tank 3", "Tank 4",
        }, {
            "Tank Rotation Caller", "Burning Adrenaline Caller",
        }, 12, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__vaelastraszthecorrupt",
            spellIcon = 23461,
        }),
        Boss("Broodlord Lashlayer", {
            A.TANK.MAIN, A.TANK.OFF,
        }, {
            "Mortal Strike Caller", "Suppression Room Lead",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__broodlordlashlayer",
            spellIcon = 23331,
        }),
        Boss("Firemaw", {
            A.TANK.MAIN, "Wing Buffet Tank",
        }, {
            "Taunt Caller", "Stack Reset Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__firemaw",
            spellIcon = 23339,
        }),
        Boss("Ebonroc", {
            A.TANK.MAIN, "Wing Buffet Tank", "Shadow Tank",
        }, {
            "Shadow of Ebonroc Caller", "Taunt Rotation Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__ebonroc",
            spellIcon = 23339,
        }),
        Boss("Flamegor", {
            A.TANK.MAIN, "Wing Buffet Tank",
        }, {
            "Tranq Shot 1", "Tranq Shot 2", "Taunt Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__flamegor",
            spellIcon = 23339,
        }),
        Encounter("Chromaggus", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(12)),
            Group("Dispels", {
                "Magic Dispel Lead", "Curse Dispel Lead",
                "Poison Dispel Lead", "Disease Dispel Lead",
            }),
            Group("Utility", {
                "Time Lapse Caller", "Frenzy Tranq 1",
                "Frenzy Tranq 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair__chromaggus",
            spellIcon = 23155,
        }),
        Encounter("Nefarian", {
            Group("Tanks", {
                "Nefarian Tank", "Left Add Tank", "Right Add Tank",
            }),
            Group("Healing", A:Healers(12)),
            Group("Sides", { "Left Side Lead", "Right Side Lead" }),
            Group("Utility", {
                "Class Call Caller", "Fear Ward",
                "Skeleton AoE Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\blackwing_lair",
            spellIcon = 22539,
        }),
    },
})
