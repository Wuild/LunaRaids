local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar"

Raid:RegisterRaid({
    expansion = "MOP",
    key = "siege_of_orgrimmar", name = "Siege of Orgrimmar", size = 25, instanceID = 1136,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Immerseus", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Healing Sector 1",
                "Healing Sector 2",
                "Damage Sector 1",
                "Damage Sector 2",
                "Puddle Slow Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__immerseus",
            mechanics = {
                Mechanic("Split the room into healing and damage sectors for puddles, interrupt hostile Sha Bolts, and use movement tools to reach every reform add."),
            },
        }),
        Encounter("The Fallen Protectors", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Bane Interrupt",
                "Bane Dispel",
                "Gloom Interrupt",
                "Mark Transfer 1",
                "Mark Transfer 2",
                "Measures Kill Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__thefallenprotectors",
            mechanics = {
                Mechanic("Set Desperate Measures order, interrupt Shadow Word: Bane and Gloom, dispel Bane carefully, and group Mark of Anguish transfers."),
            },
        }),
        Encounter("Norushen", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Trial Group 1",
                "Trial Group 2",
                "Trial Group 3",
                "Residual Orb Soaker 1",
                "Residual Orb Soaker 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__norushen",
            mechanics = {
                Mechanic("Preassign trial order for tanks, healers, and DPS; purified players focus manifestations and everyone intercepts Residual Corruption orbs."),
            },
        }),
        Encounter("Sha of Pride", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Prison Pair 1",
                "Prison Pair 2",
                "Prison Pair 3",
                "Gift Dispel 1",
                "Manifestation Interrupt",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__shaofpride",
            mechanics = {
                Mechanic("Assign prison pairs, dispel Mark of Arrogance only with Gift, spread for Swelling Pride by pride level, and kill Manifestations promptly."),
            },
        }),
        Encounter("Galakras", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Tower Team 1",
                "Tower Team 2",
                "Ground Tank",
                "Shaman Interrupt",
                "Bonecrusher Stun",
                "Cannon Operator 1",
                "Cannon Operator 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__galakras",
            mechanics = {
                Mechanic("Split tower and ground teams, interrupt Bonecrushers and Shamans, operate tower cannons together, then rotate Flames of Galakrond soaks."),
            },
        }),
        Encounter("Iron Juggernaut", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Crawler Mine Soaker 1",
                "Crawler Mine Soaker 2",
                "Crawler Mine Soaker 3",
                "Siege Cooldown 1",
                "Siege Cooldown 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__ironjuggernaut",
            mechanics = {
                Mechanic("Tanks swap Flame Vents, assign crawler-mine soakers, spread for laser/mortar, and anchor knockbacks during Siege Mode with cooldowns."),
            },
        }),
        Encounter("Kor'kron Dark Shaman", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Haromm Tank",
                "Kardris Tank",
                "Haromm Team Lead",
                "Kardris Team Lead",
                "Toxic Storm Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__korkrondarkshaman",
            mechanics = {
                Mechanic("Use separate boss teams when possible, place toxic storms and slimes at edges, kite Iron Tomb lines, and avoid overlapping Ashen Wall."),
            },
        }),
        Encounter("General Nazgrim", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Add Kill Caller",
                "Arcweaver Interrupt",
                "Warshaman Interrupt",
                "Earth Shield Dispel",
                "Assassin Stun",
                "Defensive Stance Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__generalnazgrim",
            mechanics = {
                Mechanic("Stop damage in Defensive Stance, set add priority, interrupt Arcweavers and Warshamans, dispel Earth Shield, and control Assassins."),
            },
        }),
        Encounter("Malkorok", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Implosion Sector 1",
                "Implosion Sector 2",
                "Implosion Sector 3",
                "Implosion Sector 4",
                "Blood Rage Cooldown 1",
                "Blood Rage Cooldown 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__malkorok",
            mechanics = {
                Mechanic("Assign room sectors to soak Imploding Energy, spread for Seismic Slam, track Ancient Barrier health, and stack Blood Rage with planned cooldowns."),
            },
        }),
        Encounter("Spoils of Pandaria", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Mogu Room Tank",
                "Mantid Room Tank",
                "Mogu Room Lead",
                "Mantid Room Lead",
                "Lever Sync Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__spoilsofpandaria",
            mechanics = {
                Mechanic("Split two balanced tank/healer/DPS teams between Mogu and Mantid rooms, set crate pace, interrupt dangerous adds, and pull levers together."),
            },
        }),
        Encounter("Thok the Bloodthirsty", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Cooldown 1",
                "Cooldown 2",
                "Cooldown 3",
                "Jailer Interrupt",
                "Key Carrier",
                "Kite Route Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__thokthebloodthirsty",
            mechanics = {
                Mechanic("Set stack points and Devotion/raid cooldown rotation, preassign jailers and prisoner order, and kite Thok along a clear route."),
            },
        }),
        Encounter("Siegecrafter Blackfuse", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Belt Team 1",
                "Belt Team 2",
                "Belt Team 3",
                "Weapon Kill Caller",
                "Shredder Tank",
                "Mine Control Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__siegecrafterblackfuse",
            mechanics = {
                Mechanic("Preassign every conveyor-belt team and weapon kill order, place sawblades/mines at edges, and rotate tank debuffs between boss and shredder."),
            },
        }),
        Encounter("Paragons of the Klaxxi", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Kill Order Caller",
                "Aim Soak Group",
                "Mesmerize Break Team",
                "Bloodletting Kill Lead",
                "Strong Legs User",
                "Interrupt 1",
                "Interrupt 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__paragonsoftheklaxxi",
            mechanics = {
                Mechanic("Fix the nine-boss kill order, assign interrupts and Aim soaks, pass Strong Legs/other buffs deliberately, and swap tanks on each active pair."),
            },
        }),
        Encounter("Garrosh Hellscream", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Engineer Team Left",
                "Engineer Team Right",
                "Warbringer Stun 1",
                "Intermission Group 1",
                "Intermission Group 2",
                "Malice Soak Group",
                "Iron Star Kite Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\siege_of_orgrimmar__garroshhellscream",
            mechanics = {
                Mechanic("Assign engineers and warbringer control, split intermission packs, rotate empowered whirling cooldowns, handle Malice soaks, and kite Iron Stars."),
            },
        }),
    },
})
