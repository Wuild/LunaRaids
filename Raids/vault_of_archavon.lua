local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\vault_of_archavon"

Raid:RegisterRaid({
    expansion = "WOTLK",
    key = "vault_of_archavon", name = "Vault of Archavon", size = 25, instanceID = 624,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Archavon the Stone Watcher", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Rock Shard Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\vault_of_archavon__archavonthestonewatcher",
            mechanics = {
                Mechanic("Tanks swap for Impale, spread for Rock Shards, and move away from Choking Cloud."),
            },
        }),
        Encounter("Emalon the Storm Watcher", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Minion Tank",
                "Overcharge Target Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\vault_of_archavon__emalonthestormwatcher",
            mechanics = {
                Mechanic("Off-tank holds all Tempest Minions; switch the whole raid to the Overcharged add and interrupt Lightning Nova by moving out."),
            },
        }),
        Encounter("Koralon the Flame Watcher", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Meteor Fists Cooldown 1",
                "Meteor Fists Cooldown 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\vault_of_archavon__koralontheflamewatcher",
            mechanics = {
                Mechanic("Tanks alternate Meteor Fists, ranged spread, and everyone moves promptly from Flaming Cinders."),
            },
        }),
        Encounter("Toravon the Ice Watcher", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Frozen Orb Team",
                "Frostbite Swap Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\vault_of_archavon__toravontheicewatcher",
            mechanics = {
                Mechanic("Tanks swap before Frostbite stacks grow, ranged kill Frozen Orbs, and the raid spreads during Whiteout."),
            },
        }),
    },
})
