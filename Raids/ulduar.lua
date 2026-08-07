local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar"

Raid:RegisterRaid({
    expansion = "WOTLK",
    key = "ulduar", name = "Ulduar", size = 25, instanceID = 603,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Flame Leviathan", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Siege Driver 1",
                "Siege Driver 2",
                "Demolisher Driver 1",
                "Demolisher Driver 2",
                "Turret Passenger 1",
                "Turret Passenger 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__flameleviathan",
            mechanics = {
                Mechanic("Assign drivers and turret passengers, launch demolition passengers to shut down turrets, and coordinate pyrite pickups and Overload stuns."),
            },
        }),
        Encounter("Ignis the Furnace Master", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Construct Tank",
                "Shatter Team",
                "Slag Pot Healer",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__ignisthefurnacemaster",
            mechanics = {
                Mechanic("Off-tank cycles Constructs through scorch and water; assigned players shatter molten adds while healers cover Slag Pot targets."),
            },
        }),
        Encounter("Razorscale", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Harpoon Team 1",
                "Harpoon Team 2",
                "Sentinel Tank",
                "Add Interrupt 1",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__razorscale",
            mechanics = {
                Mechanic("Split harpoon teams, tank and kill adds by priority, then swap tanks for Fuse Armor after the permanent ground phase."),
            },
        }),
        Encounter("XT-002 Deconstructor", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Light Bomb Caller",
                "Gravity Bomb Caller",
                "Scrapbot Control 1",
                "Scrapbot Control 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__xt002deconstructor",
            mechanics = {
                Mechanic("Spread Light Bombs and Gravity Bombs to assigned edges; kill heart for hard mode and control Scrapbots before they heal XT."),
            },
        }),
        Encounter("The Assembly of Iron", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Steelbreaker Tank",
                "Molgeim Tank",
                "Brundir Tank",
                "Fusion Punch Dispel",
                "Chain Lightning Interrupt 1",
                "Chain Lightning Interrupt 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__theassemblyofiron",
            mechanics = {
                Mechanic("Assign one tank per council member, interrupt Fusion Punch and Chain Lightning, and move Steelbreaker from Rune of Power and Rune of Death."),
            },
        }),
        Encounter("Kologarn", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Right Arm Kill Lead",
                "Focused Eyebeam Caller",
                "Rubble Tank",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__kologarn",
            mechanics = {
                Mechanic("Tanks swap on Overhead Smash, focused DPS kills the Right Arm to free grips, and eyebeam targets kite along the back wall."),
            },
        }),
        Encounter("Auriaya", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Sentry Tank",
                "Sentinel Blast Interrupt 1",
                "Sentinel Blast Interrupt 2",
                "Defender Tank",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__auriaya",
            mechanics = {
                Mechanic("Pull and tank Sanctum Sentries safely, stack to split Sonic Screech, interrupt Sentinel Blast, and keep the Feral Defender out of void zones."),
            },
        }),
        Encounter("Hodir", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Mage Free Team",
                "Storm Cloud Carrier 1",
                "Storm Cloud Carrier 2",
                "Flash Freeze Kill Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__hodir",
            mechanics = {
                Mechanic("Assign NPC frees, stack Storm Power with the caster group, move through Toasty Fires and Starlight, and break Flash Freeze instantly."),
            },
        }),
        Encounter("Thorim", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Arena Tank",
                "Arena Kill Lead",
                "Gauntlet Tank",
                "Gauntlet Interrupt 1",
                "Gauntlet Interrupt 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__thorim",
            mechanics = {
                Mechanic("Split arena and gauntlet teams; arena controls add waves while the tunnel interrupts Runic Colossus and reaches Thorim before berserk."),
            },
        }),
        Encounter("Freya", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Ancient Water Spirit Interrupt",
                "Storm Lasher Interrupt",
                "Snaplasher Tank",
                "Lasher Kite Lead",
                "Eonar's Gift Kill Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__freya",
            mechanics = {
                Mechanic("Assign interrupts and roots for each add wave, kill the trio together, kite Detonating Lashers, and clear healing trees immediately."),
            },
        }),
        Encounter("Mimiron", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Assault Bot Tank",
                "Bomb Bot Control",
                "Rocket Caller",
                "Head Tank",
                "Emergency Fire Bot Team",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__mimiron",
            mechanics = {
                Mechanic("Use phase-specific tanks, spread for mines and rockets, assign Assault Bot control, and balance all three V-07-TR-0N sections to die together."),
            },
        }),
        Encounter("General Vezax", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Searing Flames Interrupt 1",
                "Searing Flames Interrupt 2",
                "Searing Flames Interrupt 3",
                "Shadow Crash Caller",
                "Animus Tank",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__generalvezax",
            mechanics = {
                Mechanic("Interrupt Searing Flames, rotate Shadow Crash caster groups, kite Surge of Darkness, and preserve healer mana; hard mode kills the Animus."),
            },
        }),
        Encounter("Yogg-Saron", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Portal Team 1",
                "Portal Team 2",
                "Crusher Tentacle Tank",
                "Brain Interrupt 1",
                "Brain Interrupt 2",
                "Sanity Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__yoggsaron",
            mechanics = {
                Mechanic("Assign portal teams and brain-room interrupts, face Guardians from Sara, manage sanity at wells, and interrupt Shadow Beacon healing."),
            },
        }),
        Encounter("Algalon the Observer", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Collapsing Star Killer 1",
                "Collapsing Star Killer 2",
                "Big Bang Soaker 1",
                "Big Bang Soaker 2",
                "Phase Punch Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\ulduar__algalontheobserver",
            mechanics = {
                Mechanic("Tanks swap for Phase Punch and use planned cooldowns for Quantum Strike; star killers stage Collapsing Stars and a player enters each Big Bang portal."),
            },
        }),
    },
})
