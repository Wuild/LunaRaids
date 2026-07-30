local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "TBC",
    key = "ssc", name = "Serpentshrine Cavern", size = 25,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ssc",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A.TANK.THIRD }),
            Group("Healing", A:Healers(6)),
            Group("Utility", { "Nature Resistance", "Frost Resistance", "Interrupt Lead" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ssc",
        }),
        Encounter("Hydross the Unstable", {
            Group("Tanks", {
                "Frost Tank", "Nature Tank",
                "Add Tank 1", "Add Tank 2",
            }),
            Group("Healing", {
                A:Healer(A.Target.TANKS, nil, "Frost Tank Healer"),
                A:Healer(A.Target.TANKS, nil, "Nature Tank Healer"),
                A:Healer(A.Target.RAID, 1),
                A:Healer(A.Target.RAID, 2),
                A:Healer(A.Target.RAID, 3),
                A:Healer(A.Target.RAID, 4),
            }),
            Group("Utility", { "Transition Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ssc__hydrosstheunstable",
            spellIcon = 38235,
            mechanics = {
                Mechanic("Use separate Frost and Nature tanks and keep Hydross on the correct side of the boundary."),
                Mechanic("Call every transition clearly; crossing the line changes his form and summons four adds."),
                Mechanic("Kill the active-form adds together, then stop damage before the next planned transition."),
            },
        }),
        Encounter("The Lurker Below", {
            Group("Tanks", { A.TANK.MAIN, "Guardian Tank 1", "Guardian Tank 2" }),
            Group("Platforms", Slots("Platform Lead", 3)),
            Group("Utility", { "Spout Caller", "Ambusher CC Lead" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ssc__thelurkerbelow",
            spellIcon = 37363,
            mechanics = {
                Mechanic("Tank Lurker facing away and enter the water or rotate around him when Spout begins."),
                Mechanic("Spread ranged players to limit Geyser disruption and move out of Whirl."),
                Mechanic("During submerge, tanks collect Guardians while platform teams kill or control Ambushers."),
            },
        }),
        Encounter("Leotheras the Blind", {
            Group("Tanks", {
                "Humanoid Tank",
                A:Utility("leotheras_demon_tank", "Demon Tank"),
            }),
            Group("Interrupt Rotation", Slots("Interrupt", 3)),
            Group("Healing", {
                A:Healer(A.Target.TANKS, nil, "Humanoid Tank Healer"),
                A:Healer(A.Target.TANKS, nil, "Demon Tank Healer"),
                A:Healer(A.Target.RAID, 1),
                A:Healer(A.Target.RAID, 2),
                A:Healer(A.Target.RAID, 3),
                A:Healer(A.Target.RAID, 4),
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ssc__leotherastheblind",
            spellIcon = 37676,
            mechanics = {
                Mechanic("Kill the three Greyheart Spellbinders, then spread and stop threat before each Whirlwind ends."),
                Mechanic("A fire-resistant warlock tanks the demon form while the raid controls threat."),
                Mechanic("Players kill their Inner Demons; at 15%, separate and finish Leotheras and his demon."),
            },
        }),
        Encounter("Fathom-Lord Karathress", {
            Group("Tanks", { "Karathress Tank", "Sharkkis Tank", "Tidalvess Tank", "Caribdis Tank" }),
            Group("Interrupts", { "Caribdis Interrupt 1", "Caribdis Interrupt 2" }),
            Group("Utility", { "Spitfire Totem Lead", "Pet Control" }),
        }, {
            "Fathom-Lord Karathress",
            "Sharkkis", "Tidalvess", "Caribdis",
        }, {
            4, -- Karathress: Moon, last
            2, -- Sharkkis: Cross, second
            1, -- Tidalvess: Skull, first
            3, -- Caribdis: Square, third
        }, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ssc__fathomlordkarathress",
            spellIcon = 38451,
            mechanics = {
                Mechanic("Separate Karathress and all three advisers, then follow the announced kill order."),
                Mechanic("Interrupt Caribdis heals and destroy Tidalvess's Spitfire Totem immediately."),
                Mechanic("Each adviser death empowers Karathress, so tanks and healers prepare for the final burn."),
            },
        }),
        Encounter("Morogrim Tidewalker", {
            Group("Tanks", { A.TANK.MAIN, "Murloc Tank 1", "Murloc Tank 2" }),
            Group("Healing", {
                A:Healer(A.Target.MAIN_TANK, 1),
                A:Healer(A.Target.MAIN_TANK, 2),
                A:Healer(A.Target.TANKS, nil, "Murloc Healer"),
                A:Healer(A.Target.RAID, nil, "Watery Grave Healer"),
                A:Healer(A.Target.RAID, 1),
                A:Healer(A.Target.RAID, 2),
            }),
            Group("Utility", { "Murloc AoE Lead", "Grave Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ssc__morogrimtidewalker",
            spellIcon = 37730,
            mechanics = {
                Mechanic("Keep Morogrim stationary and maintain heavy healing through Tidal Wave and Earthquake."),
                Mechanic("After Earthquake, gather both post-nerf murloc packs on the AoE tank and burn them down."),
                Mechanic("Watery Grave targets recover quickly; below 25%, move away from Watery Globules."),
            },
        }),
        Encounter("Lady Vashj", {
            Group("Tanks", { "Vashj Tank", "Naga Tank" }),
            Group("Elemental Platforms", {
                "North Elemental",
                "East Elemental",
                "South Elemental",
                "West Elemental",
            }),
            Group("Core Team", {
                "Core Looter",
                "Core Relay 1",
                "Core Relay 2",
                "Generator Receiver",
            }),
            Group("Utility", {
                A:Utility("vashj_strider_kiter", "Strider Kiter"),
                "Strider Slow",
                "Tainted Elemental Caller",
                "Sporebat Kill Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ssc",
            spellIcon = 38280,
            mechanics = {
                Mechanic("Phase 1: spread for Static Charge and keep Vashj controlled in the center."),
                Mechanic("Phase 2: cover all four sides, kite Striders, tank Elites, and relay each Tainted Core to a generator."),
                Mechanic("Phase 3 has no mind control post-nerf; spread, avoid poison, and kill Sporebats when needed."),
            },
        }),
    },
})
