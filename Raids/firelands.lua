local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\firelands"

Raid:RegisterRaid({
    expansion = "CATA",
    key = "firelands", name = "Firelands", size = 25, instanceID = 720,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Beth'tilac", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Web Tank",
                "Web Healer 1",
                "Web Healer 2",
                "Spinner Taunt 1",
                "Spiderling Slow Lead",
                "Drone Tank",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\firelands__bethtilac",
            mechanics = {
                Mechanic("Assign a web team with tank and healers upstairs; ground teams taunt Spinners, kill Spiderlings before Drones feed, then stack for phase two."),
            },
        }),
        Encounter("Lord Rhyolith", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Left Leg Lead",
                "Right Leg Lead",
                "Fragment Tank",
                "Spark Tank",
                "Steering Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\firelands__lordrhyolith",
            mechanics = {
                Mechanic("Split left/right leg steering teams, assign Fragments and Sparks to separate tanks, and move volcano activations while avoiding lava lines."),
            },
        }),
        Encounter("Alysrazor", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Flier 1",
                "Flier 2",
                "Hatchling Tank 1",
                "Hatchling Tank 2",
                "Initiate Interrupt 1",
                "Initiate Interrupt 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\firelands__alysrazor",
            mechanics = {
                Mechanic("Assign two fliers to ring paths, two hatchling tanks to worm lanes, interrupt Initiates, and pair ground teams for tornado movement."),
            },
        }),
        Encounter("Shannox", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Riplimb Tank",
                "Rageface Break Team",
                "Crystal Trap Caller",
                "Immolation Trap Clearer",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\firelands__shannox",
            mechanics = {
                Mechanic("Separate Shannox and Riplimb without breaking the spear link, trap Rageface, and reset Jagged Tear by controlling spear retrieval."),
            },
        }),
        Encounter("Baleroc", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Decimation Tank",
                "Shard Soaker 1",
                "Shard Soaker 2",
                "Shard Soaker 3",
                "Shard Soaker 4",
                "Tank Healer Rotation Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\firelands__baleroc",
            mechanics = {
                Mechanic("Tanks coordinate Blaze of Glory and Decimation Blade, while shard pairs build Tormented stacks and healers rotate Vital Spark assignments."),
            },
        }),
        Encounter("Majordomo Staghelm", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Form Change Caller",
                "Scythe Cooldown 1",
                "Scythe Cooldown 2",
                "Seed Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\firelands__majordomostaghelm",
            mechanics = {
                Mechanic("Use a planned scorpion/cat transformation count, rotate raid cooldowns for Flame Scythe, and spread seeds before they expire."),
            },
        }),
        Encounter("Ragnaros", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Magma Trap Trigger",
                "Son Stun 1",
                "Son Stun 2",
                "Son Knockback 1",
                "Meteor Kite 1",
                "Meteor Kite 2",
                "Dreadflame Team",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\firelands__ragnaros",
            mechanics = {
                Mechanic("Assign trap triggers, knockbacks and stuns for Sons, split seed collapse positions, control meteors, and cover heroic Dreadflame and roots."),
            },
        }),
    },
})
