local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic
local Rec = Raid.Recommendation
local Reuse = { roles = { Raid.Role.HEALER, Raid.Role.DAMAGE }, allowReuse = true }

Raid:RegisterRaid({
    expansion = "VANILLA",
    key = "molten_core", name = "Molten Core", size = 40, instanceID = 409,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\molten_core",
    guides = {
        ["Lucifron"] = {
            Mechanic("Off-tanks separate both Flamewaker Protectors; interrupt and kill them before Lucifron."),
            Mechanic("Decurse Lucifron's Curse immediately and dispel Impending Doom while mana users conserve resources."),
        },
        ["Magmadar"] = {
            Mechanic("Face Magmadar away from the raid; ranged and healers spread outside his frontal cone."),
            Mechanic("Hunters rotate Tranquilizing Shot on Frenzy, and everyone moves out of fire patches."),
        },
        ["Gehennas"] = {
            Mechanic("Pull and tank Gehennas away from his guards; interrupt and focus the guards first."),
            Mechanic("Decurse Gehennas' Curse quickly and move out of Rain of Fire without dragging the boss."),
        },
        ["Garr"] = {
            Mechanic("Assign tanks or banishes to every Firesworn and keep them separated from Garr."),
            Mechanic("Kill or release adds in a controlled order; dispel Garr's slowing effect and avoid chained eruptions."),
        },
        ["Baron Geddon"] = {
            Mechanic("Spread around the room, move away during Inferno, and keep the tank in healer range."),
            Mechanic("Living Bomb targets immediately run to the assigned safe area before exploding."),
        },
        ["Shazzrah"] = {
            Mechanic("Spread casters around the tank and stop damage briefly after each teleport while threat stabilizes."),
            Mechanic("Decurse Shazzrah's Curse continuously and purge or dispel his self-buff to reduce damage."),
        },
        ["Sulfuron Harbinger"] = {
            Mechanic("Separate Sulfuron from the four priests and focus one add at a time."),
            Mechanic("Maintain an interrupt rotation on Dark Mending and dispel Shadow Word: Pain from the raid."),
        },
        ["Golemagg the Incinerator"] = {
            Mechanic("Tank Golemagg away from both Core Ragers; off-tanks hold the dogs without trying to kill them early."),
            Mechanic("Melee watch stacking Magma Splash, and healers prepare for heavy damage below 10%."),
        },
        ["Majordomo Executus"] = {
            Mechanic("Control healers with polymorph where possible and kill the elite adds in the assigned order."),
            Mechanic("Interrupt or purge add healing, stop attacks into Magic Reflection, and never damage Majordomo directly."),
        },
        ["Ragnaros"] = {
            Mechanic("The main tank holds Ragnaros at the edge while melee avoid knockbacks and ranged spread."),
            Mechanic("During submerge, collapse into assigned groups, control every Son of Flame, and kill them before emergence."),
        },
    },
    recommendations = {
        Rec("decurse", { "MAGE", "DRUID" }, { "Arcane", "Frost", "Restoration", "Balance" }, Reuse),
        Rec("tranq", { "HUNTER" }, { "Marksmanship", "Beast Mastery", "Survival" }),
        Rec("banish", { "WARLOCK" }, { "Affliction", "Demonology" }),
        Rec("interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
    },
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
