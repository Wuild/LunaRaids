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
    expansion = "TBC",
    key = "black_temple", name = "Black Temple", size = 25, instanceID = 564,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple",
    guides = {
        ["High Warlord Naj'entus"] = {
            Mechanic("Remove Impaling Spine immediately and loot it; heal the raid to full before using a spine to break Tidal Shield."),
            Mechanic("Spread to reduce Needle Spine splash and use defensive or healing cooldowns for every shield burst."),
        },
        ["Supremus"] = {
            Mechanic("Tank phase: two tanks maintain the top threat positions and melee avoid Molten Flame and frontal damage."),
            Mechanic("Kite phase: fixated players run away without crossing the raid while everyone avoids volcano eruptions."),
        },
        ["Shade of Akama"] = {
            Mechanic("Assigned teams kill channelers and sorcerers evenly while tanks collect defenders and elementals."),
            Mechanic("When Akama engages, finish remaining adds and burn the Shade before Akama's health is exhausted."),
        },
        ["Teron Gorefiend"] = {
            Mechanic("Shadow of Death targets move to the assigned location and use ghost abilities to kill constructs before they reach the raid."),
            Mechanic("Dispel Incinerate, spread for Crushing Shadows, and keep threat stable through rapid damage windows."),
        },
        ["Gurtogg Bloodboil"] = {
            Mechanic("Three groups rotate through Bloodboil at maximum range so each group receives only its assigned stacks."),
            Mechanic("During Fel Rage, the target uses mitigation while healers focus them; tanks reset threat and debuffs before phase return."),
        },
        ["Reliquary of Souls"] = {
            Mechanic("Essence of Suffering: healing is disabled, tanks rotate Fixate, and players manage health and threat carefully."),
            Mechanic("Essence of Desire: interrupt Spirit Shock and stop attacks into Deaden or reflected damage; dispel Rune Shield."),
            Mechanic("Essence of Anger: tanks swap around Soul Scream resources and the raid burns before stacking raid damage wins."),
        },
        ["Mother Shahraz"] = {
            Mechanic("Wear the required shadow resistance and spread in assigned positions so Saber Lash remains split by the tanks."),
            Mechanic("Fatal Attraction targets move together to the designated safe area, then separate only after all explosions finish."),
        },
        ["The Illidari Council"] = {
            Mechanic("Keep all four council members separated; interrupt Malande's heals and reflect or interrupt Divine Wrath."),
            Mechanic("A mage tanks Zerevor and spellsteals Dampen Magic; the raid moves from Flamestrike, Blizzard, and Consecration."),
        },
        ["Illidan Stormrage"] = {
            Mechanic("Shear must be blocked or avoided by the active tank; parasites are moved out and killed before they duplicate."),
            Mechanic("Flame tanks hold both Flames of Azzinoth near their glaives without crossing beams or allowing enraged separation."),
            Mechanic("The fire-resistance warlock tanks demon form at range; spread for Shadow Blast and use cages during the final enrage."),
        },
    },
    recommendations = {
        Rec("shadow resistance", { "PRIEST", "PALADIN" }, { "Shadow", "Discipline", "Holy" }, Reuse),
        Rec("interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
        Rec("dispel", { "PRIEST", "PALADIN", "SHAMAN" }, { "Discipline", "Holy", "Restoration" }, Reuse),
        Rec("reflect", { "MAGE" }, { "Fire", "Frost", "Arcane" }),
        Rec("zerevor tank", { "MAGE" }, { "Fire", "Frost", "Arcane" }),
        Rec("zerevor spellsteal", { "MAGE" }, { "Arcane", "Frost", "Fire" }),
        Rec("blessing dispel", { "PRIEST", "SHAMAN" }, { "Discipline", "Shadow", "Restoration" }, Reuse),
        Rec("demon tank", { "WARLOCK" }, { "Destruction", "Demonology" }),
        Rec("shear backup", { "WARRIOR", "ROGUE" }, { "Protection", "Combat" }),
    },
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A.TANK.THIRD }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Interrupt Lead", "Dispel Lead", "Shadow Resistance Lead" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple",
        }),
        Encounter("High Warlord Naj'entus", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Spine Caller", "Shield Break Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple__highwarlordnajentus",
            spellIcon = 39872,
            mechanics = {
                Mechanic("Spread around Naj'entus and heal Impaling Spine targets before another spike lands."),
                Mechanic("Remove a spine, loot it, and throw it only when the Tidal Shield caller is ready."),
                Mechanic("Top the raid before breaking every shield because Tidal Burst hits everyone."),
            },
        }),
        Encounter("Supremus", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Kite Phase Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple__supremus",
            spellIcon = 41976,
            mechanics = {
                Mechanic("During tank phase, two tanks manage Hateful Strikes while the raid avoids Molten Flame."),
                Mechanic("During chase phase, spread widely, kite the fixate, and move away from volcanoes."),
                Mechanic("Regroup behind the boss before each return to tank phase."),
            },
        }),
        Encounter("Shade of Akama", {
            Group("Tanks", { "Left Door Tank", "Right Door Tank" }),
            Group("Teams", { "Left Door Lead", "Right Door Lead", "Channeler Kill Lead" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple__shadeofakama",
            spellIcon = 216726,
            mechanics = {
                Mechanic("Split tanks and damage between both doors to control the incoming add waves."),
                Mechanic("Kill or interrupt Sorcerers and focus Channelers to release Akama."),
                Mechanic("The Shade is not tanked; burn it once Akama engages while tanks hold remaining adds."),
            },
        }),
        Encounter("Teron Gorefiend", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Shadow of Death Caller",
                "Construct Practice Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple__terongorefiend",
            spellIcon = 40243,
            mechanics = {
                Mechanic("Stack behind Teron, move Incinerate and Crushing Shadows away, and dispel quickly."),
                Mechanic("Shadow of Death targets move to the designated area before becoming ghosts."),
                Mechanic("As a ghost, use Spirit Lance, Chains, and Volley to kill every Shadowy Construct."),
            },
        }),
        Encounter("Gurtogg Bloodboil", {
            Group("Tanks", { "Tank 1", "Tank 2", "Tank 3" }),
            Group("Bloodboil Groups", { "Group 1 Lead", "Group 2 Lead", "Group 3 Lead" }),
            Group("Healing", A:Healers(7)),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple__gurtoggbloodboil",
            spellIcon = 40508,
            mechanics = {
                Mechanic("Three tanks rotate threat and Acidic Wound while assigned groups soak Bloodboil."),
                Mechanic("During Fel Rage, stop tanking and pour healing into the selected player."),
                Mechanic("Spread after Fel Rage, manage threat resets, and keep Fel-Acid Breath away from the raid."),
            },
        }),
        Encounter("Reliquary of Souls", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Interrupt Rotation", { "Interrupt 1", "Interrupt 2", "Interrupt 3", "Interrupt 4" }),
            Group("Utility", { "Dispel Lead", "Reflect Lead" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple__reliquaryofsouls",
            spellIcon = 41294,
            mechanics = {
                Mechanic("Essence of Suffering: rotate tanks carefully and stop attacks before Fixate changes."),
                Mechanic("Essence of Desire: interrupt Spirit Shock and dispel Rune Shield without killing yourself to reflected damage."),
                Mechanic("Essence of Anger: interrupt Soul Scream, manage threat, and burn before Seethe overwhelms the tank."),
            },
        }),
        Encounter("Mother Shahraz", {
            Group("Tanks", { A.TANK.MAIN, "Off Tank 1", "Off Tank 2" }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Fatal Attraction Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple__mothershahraz",
            spellIcon = 41001,
            mechanics = {
                Mechanic("Use the required shadow resistance and keep three tanks stacked in front of Shahraz."),
                Mechanic("Fatal Attraction targets move to the assigned side and separate from one another immediately."),
                Mechanic("Spread the remaining raid and react to beams without breaking tank positioning."),
            },
        }),
        Encounter("The Illidari Council", {
            Group("Tanks", {
                "Gathios Tank",
                "Veras Tank",
                "Malande Tank",
                A:Utility("zerevor_tank", "Zerevor Tank"),
            }),
            Group("Interrupts", { "Malande Interrupt 1", "Malande Interrupt 2", "Malande Interrupt 3" }),
            Group("Utility", { "Zerevor Spellsteal", "Blessing Dispel" }),
        }, {
            "Gathios the Shatterer", "Veras Darkshadow",
            "Lady Malande", "High Nethermancer Zerevor",
        }, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple__theillidaricouncil",
            spellIcon = 41485,
            mechanics = {
                Mechanic("Keep all four council members separated and maintain their specialized tanks."),
                Mechanic("Interrupt Malande heals, Spellsteal Zerevor's Dampen Magic, and dispel Gathios's blessings."),
                Mechanic("Avoid Blizzard, Flamestrike, Consecration, and Vanish poison while damaging the shared health pool."),
            },
        }),
        Encounter("Illidan Stormrage", {
            Group("Tanks", {
                "Illidan Tank",
                "Flame Tank 1",
                "Flame Tank 2",
                A:Utility("illidan_demon_tank", "Demon Tank"),
            }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Shear Backup", "Parasite Lead", "Cage Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple",
            spellIcon = 41917,
            mechanics = {
                Mechanic("The main tank handles Shear while the raid avoids Flame Crash and controls Parasites."),
                Mechanic("Two fire-resistance tanks separate the Flames of Azzinoth without stretching their beams."),
                Mechanic("A shadow-resistant ranged tank handles demon form; use Maiev's traps and avoid Eye Blast."),
            },
        }),
    },
})
