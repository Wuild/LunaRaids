local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "VANILLA",
    key = "onyxia", name = "Onyxia's Lair", size = 40,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\onyxia",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, "Whelp Tank 1", "Whelp Tank 2" }),
            Group("Healing", A:Healers(10)),
            Group("Utility", { "Fear Ward", "Whelp AoE Lead" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\onyxia",
        }),
        Boss("Onyxia", {
            A.TANK.MAIN, "Whelp Tank 1", "Whelp Tank 2",
        }, {
            "Fear Ward", "Deep Breath Caller",
            "Whelp AoE Lead", "Phase 3 Position Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\onyxia",
            spellIcon = 18392,
        }),
    },
})
