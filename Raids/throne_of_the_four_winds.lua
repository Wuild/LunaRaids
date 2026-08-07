local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_the_four_winds"

Raid:RegisterRaid({
    expansion = "CATA",
    key = "throne_of_the_four_winds", name = "Throne of the Four Winds", size = 25, instanceID = 754,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Conclave of Wind", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Anshal Platform Lead",
                "Nezir Platform Lead",
                "Rohash Platform Lead",
                "Platform Swap Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_the_four_winds__conclaveofwind",
            mechanics = {
                Mechanic("Split three balanced platform teams, keep one player with each boss, coordinate jumps before full energy, and kill all bosses together."),
            },
        }),
        Encounter("Al'Akir", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Squall Line Caller",
                "Stormling Tank",
                "Lightning Cloud Height Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\throne_of_the_four_winds__alakir",
            mechanics = {
                Mechanic("Spread around the platform, move through Wind Burst and Squall gaps, stack Acid Rain for phase two, then form controlled vertical lightning positions."),
            },
        }),
    },
})
