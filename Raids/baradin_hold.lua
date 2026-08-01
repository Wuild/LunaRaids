local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\baradin_hold"

Raid:RegisterRaid({
    expansion = "CATA",
    key = "baradin_hold", name = "Baradin Hold", size = 25,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Argaloth", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Group 1 Dispel",
                "Group 2 Dispel",
                "Meteor Slash Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\baradin_hold__argaloth",
            mechanics = {
                Mechanic("Split into two groups behind the boss, tanks swap on Meteor Slash, and assigned dispellers remove Consuming Darkness before Fel Firestorm."),
            },
        }),
        Encounter("Occu'thar", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Left Eye AoE Lead",
                "Right Eye AoE Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\baradin_hold__occuthar",
            mechanics = {
                Mechanic("Two groups alternate behind the boss, tanks swap for Searing Shadows, and each group instantly AoEs its Eyes before detonation."),
            },
        }),
        Encounter("Alizabal", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Seething Hate Caller",
                "Blade Dance Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\baradin_hold__alizabal",
            mechanics = {
                Mechanic("Tanks swap after Skewer, spread before Seething Hate, then collapse center and avoid the rotating Blade Dance path."),
            },
        }),
    },
})
