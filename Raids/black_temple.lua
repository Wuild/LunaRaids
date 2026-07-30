local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "TBC",
    key = "black_temple", name = "Black Temple", size = 25,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\black_temple",
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
