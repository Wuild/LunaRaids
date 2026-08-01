local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\bastion_of_twilight"

Raid:RegisterRaid({
    expansion = "CATA",
    key = "bastion_of_twilight", name = "The Bastion of Twilight", size = 25,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Halfus Wyrmbreaker", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Drake Tank 1",
                "Drake Tank 2",
                "Shadow Nova Interrupt 1",
                "Shadow Nova Interrupt 2",
                "Roar Cooldown",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\bastion_of_twilight__halfuswyrmbreaker",
            mechanics = {
                Mechanic("Choose drake releases before pull, assign tanks to Halfus and active drakes, interrupt Shadow Nova, and rotate cooldowns through Furious Roar."),
            },
        }),
        Encounter("Valiona and Theralion", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Blackout Dispel",
                "Engulfing Magic Caller",
                "Twilight Realm Team 1",
                "Twilight Realm Team 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\bastion_of_twilight__valionaandtheralion",
            mechanics = {
                Mechanic("Split ranged and melee positioning, dispel Blackout in a stack, place Engulfing Magic safely, and assign twilight-realm add killers."),
            },
        }),
        Encounter("Ascendant Council", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Hydrolance Interrupt",
                "Rising Flames Interrupt",
                "Lightning Rod Caller",
                "Gravity-Fire Pair Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\bastion_of_twilight__ascendantcouncil",
            mechanics = {
                Mechanic("Assign interrupts and debuff pairings in phases one/two, spread lightning conductors, and collapse tightly before Elementium Monstrosity."),
            },
        }),
        Encounter("Cho'gall", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Adherent Tank",
                "Worship Interrupt 1",
                "Worship Interrupt 2",
                "Depravity Interrupt",
                "Tentacle Kill Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\bastion_of_twilight__chogall",
            mechanics = {
                Mechanic("Off-tank collects Corrupting Adherents at the edge, interrupt Worship and Depravity, avoid corruption sources, then focus tentacles."),
            },
        }),
        Encounter("Sinestra", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Wrack Dispel 1",
                "Wrack Dispel 2",
                "Whelp Tank",
                "Orb Lane Caller",
                "Calen Healer",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\bastion_of_twilight__sinestra",
            mechanics = {
                Mechanic("Assign Wrack dispel timings, whelp tanks and orb lanes; protect Calen in phase two and rotate cooldowns as Twilight Extinction approaches."),
            },
        }),
    },
})
