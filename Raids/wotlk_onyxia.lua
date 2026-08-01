local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_onyxia"

Raid:RegisterRaid({
    expansion = "WOTLK",
    key = "wotlk_onyxia", name = "Onyxia's Lair", size = 25,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Onyxia", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Whelp Tank 1",
                "Whelp Tank 2",
                "Whelp AoE Lead",
                "Deep Breath Caller",
                "Fear Ward",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\wotlk_onyxia__onyxia",
            mechanics = {
                Mechanic("Tank away from the raid, assign whelp tanks and AoE, spread during air phase, dodge Deep Breath, then manage fears and threat on landing."),
            },
        }),
    },
})
