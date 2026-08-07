local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\trial_of_the_crusader"

Raid:RegisterRaid({
    expansion = "WOTLK",
    key = "trial_of_the_crusader", name = "Trial of the Crusader", size = 25, instanceID = 649,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("The Northrend Beasts", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Snobold Kill Lead",
                "Dreadscale Tank",
                "Acidmaw Tank",
                "Bile-Toxin Pair Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\trial_of_the_crusader__thenorthrendbeasts",
            mechanics = {
                Mechanic("Assign Snobold kills, tank worms apart and cleanse Burning Bile/Paralytic Toxin by pairing targets, then spread for Icehowl."),
            },
        }),
        Encounter("Lord Jaraxxus", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Fel Fireball Interrupt 1",
                "Fel Fireball Interrupt 2",
                "Nether Power Dispel",
                "Mistress Tank",
                "Legion Flame Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\trial_of_the_crusader__lordjaraxxus",
            mechanics = {
                Mechanic("Interrupt Fel Fireball, dispel Nether Power, have the off-tank collect portals/volcano adds, and spread Legion Flame to the edge."),
            },
        }),
        Encounter("Faction Champions", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Kill Target Caller",
                "Healer Interrupt 1",
                "Healer Interrupt 2",
                "Offensive Dispel 1",
                "Defensive Dispel 1",
                "Crowd Control 1",
                "Crowd Control 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\trial_of_the_crusader__factionchampions",
            mechanics = {
                Mechanic("Assign crowd-control and dispel teams by enemy role, purge defensive buffs, and coordinate focused swaps and interrupts."),
            },
        }),
        Encounter("The Twin Val'kyr", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Light Orb Team",
                "Dark Orb Team",
                "Twin's Pact Interrupt",
                "Shield Swap Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\trial_of_the_crusader__thetwinvalkyr",
            mechanics = {
                Mechanic("Split light and dark essence groups, intercept matching orbs, swap to the shielded twin, and interrupt Twin's Pact."),
            },
        }),
        Encounter("Anub'arak", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Burrower Tank 1",
                "Burrower Tank 2",
                "Frost Sphere Team",
                "Penetrating Cold Healer 1",
                "Penetrating Cold Healer 2",
                "Penetrating Cold Healer 3",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\trial_of_the_crusader__anubarak",
            mechanics = {
                Mechanic("Off-tanks position Burrowers on permafrost, ranged create and preserve frost patches, and phase-three healers use strict Penetrating Cold assignments."),
            },
        }),
    },
})
