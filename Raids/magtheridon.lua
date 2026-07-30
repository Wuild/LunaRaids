local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "TBC",
    key = "magtheridon", name = "Magtheridon's Lair", size = 25,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\magtheridon",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", {
                A.TANK.MAIN,
                "Channeler Tank 1",
                "Channeler Tank 2",
            }),
            Group("Healing", A:Healers(5)),
            Group("Utility", {
                "Click Team Lead",
                "Interrupt Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\magtheridon",
        }),
        Encounter("Magtheridon", {
            Group("Tanks", {
                A:Tank("magtheridon", "Magtheridon / Channeler Tank"),
                A:Tank("channeler", "Channeler Tank", 2),
                A:Tank("channeler", "Channeler Tank", 3),
            }),
            Group("Click Team", Slots("Clicker", 5)),
            Group("Interrupts", { "Channeler 1 Interrupt", "Channeler 2 Interrupt", "Channeler 3 Interrupt", "Channeler 4 Interrupt", "Channeler 5 Interrupt" }),
            Group("Utility", {
                "Abyssal Banish Lead",
                "Click Caller",
                "Collapse Caller",
            }),
        }, {
            "Magtheridon", "Hellfire Channeler",
        }, {
            2, -- Magtheridon: Cross, after the Channelers
            1, -- Current Channeler: Skull
        }, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\magtheridon",
            spellIcon = 30528,
            mechanics = {
                Mechanic("Tank and interrupt each Channeler; focus them down in the assigned order."),
                Mechanic("The same five assigned players can click the cubes for every Blast Nova in the post-nerf encounter."),
                Mechanic("At 30%, stabilize after the ceiling collapse, then continue clicks and avoid fire."),
            },
        }),
    },
})
