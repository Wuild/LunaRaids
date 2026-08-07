local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\eye_of_eternity"

Raid:RegisterRaid({
    expansion = "WOTLK",
    key = "eye_of_eternity", name = "The Eye of Eternity", size = 25, instanceID = 616,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Malygos", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Power Spark Grip 1",
                "Power Spark Root 1",
                "Nexus Lord Tank",
                "Scion Kill Lead",
                "Drake Healing Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\eye_of_eternity__malygos",
            mechanics = {
                Mechanic("Rotate spark grips and roots into a stacked burn zone, split Nexus Lord/Scion control, then assign drake healers and a combo-point rotation."),
            },
        }),
    },
})
