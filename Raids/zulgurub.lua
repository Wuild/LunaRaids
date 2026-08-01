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
    key = "zulgurub", name = "Zul'Gurub", size = 20,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub",
    guides = {
        ["High Priestess Jeklik"] = {
            Mechanic("Spread during the bat phase, interrupt heals, and destroy summoned bats before fire covers the area."),
            Mechanic("After transformation, keep interrupts on Great Heal and move away from fire bombs immediately."),
        },
        ["High Priest Venoxis"] = {
            Mechanic("Kill or control the snake adds, then spread around Venoxis to limit Holy Wrath chains."),
            Mechanic("In snake form, kite away from poison clouds and burn carefully through the low-health frenzy."),
        },
        ["High Priestess Mar'li"] = {
            Mechanic("Kill spawned spiders quickly and interrupt Drain Life whenever Mar'li is in troll form."),
            Mechanic("A second tank handles the charge and threat reset in spider form; ranged stay spread from webs."),
        },
        ["Bloodlord Mandokir"] = {
            Mechanic("Do not act while watched; stop attacks and movement until the gaze ends."),
            Mechanic("An off-tank controls Ohgan while the raid handles charges and escalating tank damage."),
        },
        ["Edge of Madness: Gri'lek"] = {
            Mechanic("Kite Gri'lek during Avatar and keep him away from his fixated target until the buff expires."),
            Mechanic("Dispel or avoid his root and resume controlled damage only when the tank has him positioned."),
        },
        ["Edge of Madness: Hazza'rah"] = {
            Mechanic("Destroy summoned illusions immediately before they reach and sleep their targets."),
            Mechanic("Healers recover the raid after Mana Burn and keep spread enough to identify incoming illusions."),
        },
        ["Edge of Madness: Renataki"] = {
            Mechanic("Stack near the tank before vanish so Renataki's ambush target can be healed immediately."),
            Mechanic("Re-establish threat after every vanish and use stuns or disarms where available during his flurry."),
        },
        ["Edge of Madness: Wushoolay"] = {
            Mechanic("Spread around Wushoolay and move out of Lightning Cloud as soon as it appears."),
            Mechanic("Avoid chaining lightning through the raid and use nature mitigation for burst damage."),
        },
        ["Gahz'ranka"] = {
            Mechanic("Tank Gahz'ranka facing away while ranged spread to reduce geyser disruption."),
            Mechanic("Return quickly after knockbacks, avoid the frontal Frost Breath, and stabilize before resuming damage."),
        },
        ["High Priest Thekal"] = {
            Mechanic("Separate Thekal, Zath, and Lor'Khan; interrupt heals and bring all three down together."),
            Mechanic("In tiger form, control summoned tigers, avoid charges, and burn through the final enrage."),
        },
        ["High Priestess Arlokk"] = {
            Mechanic("Marked players move to the assigned position while off-tanks and AoE control panther waves."),
            Mechanic("After vanish, regroup, protect healers from loose panthers, and let the tank regain threat."),
        },
        ["Jin'do the Hexxer"] = {
            Mechanic("Kill healing wards and shades immediately; cursed players help reveal and damage the shades."),
            Mechanic("Control mind-controlled players and return quickly after teleporting to the skeleton pit."),
        },
        ["Hakkar"] = {
            Mechanic("Pull a Son of Hakkar before each Blood Siphon and poison the raid so the siphon damages Hakkar."),
            Mechanic("Dispel Corrupted Blood, control mind-controlled players, and maintain tank swaps around threat effects."),
        },
    },
    recommendations = {
        Rec("poison", { "SHAMAN", "DRUID", "PALADIN" }, { "Restoration", "Balance", "Holy" }, Reuse),
        Rec("curse", { "MAGE", "DRUID" }, { "Arcane", "Frost", "Restoration", "Balance" }, Reuse),
        Rec("interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
        Rec("son", { "MAGE", "WARLOCK", "HUNTER" }, { "Frost", "Affliction", "Survival" }),
    },
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, "Add Tank" }),
            Group("Healing", A:Healers(4)),
            Group("Utility", {
                "Poison Dispel", "Curse Dispel",
                "Primary Interrupt", "Crowd Control",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub",
        }),
        Boss("High Priestess Jeklik", {
            "Jeklik Tank", "Bat Tank",
        }, {
            "Heal Interrupt 1", "Heal Interrupt 2",
            "Bat AoE Lead", "Bomb Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__highpriestessjeklik",
            spellIcon = 23918,
        }),
        Boss("High Priest Venoxis", {
            "Venoxis Tank", "Cobra Tank",
        }, {
            "Holy Wrath Interrupt", "Poison Dispel Lead",
            "Snake Kill Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__highpriestvenoxis",
            spellIcon = 23865,
        }),
        Boss("High Priestess Mar'li", {
            "Mar'li Tank", "Spider Tank",
        }, {
            "Lifedrain Interrupt", "Spider AoE Lead",
            "Web Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__highpriestessmarli",
            spellIcon = 24083,
        }),
        Boss("Bloodlord Mandokir", {
            "Mandokir Tank", "Ohgan Tank",
        }, {
            "Ohgan Kill Lead", "Gaze Caller",
            "Spirits Position Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__bloodlordmandokir",
            spellIcon = 24318,
        }),
        Boss("Edge of Madness: Gri'lek", { A.TANK.MAIN }, {
            "Avatar Kite Lead", "Root Rotation Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__edgeofmadnessgrilek",
            spellIcon = 24728,
        }),
        Boss("Edge of Madness: Hazza'rah", { A.TANK.MAIN }, {
            "Illusion Kill Lead", "Sleep Dispel Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__edgeofmadnesshazzarah",
            spellIcon = 24728,
        }),
        Boss("Edge of Madness: Renataki", { A.TANK.MAIN }, {
            "Vanish Caller", "Ambush Target Healer",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__edgeofmadnessrenataki",
            spellIcon = 24728,
        }),
        Boss("Edge of Madness: Wushoolay", { A.TANK.MAIN }, {
            "Lightning Cloud Caller", "Purge Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__edgeofmadnesswushoolay",
            spellIcon = 24728,
        }),
        Boss("Gahz'ranka", { A.TANK.MAIN }, {
            "Geyser Caller", "Frost Dispel Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__gahzranka",
            spellIcon = 16099,
        }),
        Boss("High Priest Thekal", {
            "Thekal Tank", "Zath Tank", "Lor'Khan Tank",
        }, {
            "Zath Interrupt", "Lor'Khan Interrupt",
            "Tiger AoE Lead", "Simultaneous Kill Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__highpriestthekal",
            spellIcon = 21060,
        }),
        Boss("High Priestess Arlokk", {
            "Arlokk Tank", "Panther Tank 1", "Panther Tank 2",
        }, {
            "Marked Player Healer", "Panther AoE Lead",
            "Vanish Caller",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__highpriestessarlokk",
            spellIcon = 24210,
        }),
        Boss("Jin'do the Hexxer", {
            "Jin'do Tank", "Shade Tank",
        }, {
            "Healing Ward Lead", "Mind Control Totem Lead",
            "Hex Dispel", "Shade Kill Lead",
        }, 5, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__jindothehexxer",
            spellIcon = 24306,
        }),
        Encounter("Hakkar", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Sons", {
                "Son Puller 1", "Son Puller 2",
                "Son Kill Caller",
            }),
            Group("Utility", {
                "Mind Control CC 1", "Mind Control CC 2",
                "Corrupted Blood Spread Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulgurub__hakkar",
            spellIcon = 24324,
        }),
    },
})
