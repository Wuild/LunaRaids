local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\mogushan_vaults"

Raid:RegisterRaid({
    expansion = "MOP",
    key = "mogushan_vaults", name = "Mogu'shan Vaults", size = 25,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("The Stone Guard", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Guardian Tank 1",
                "Guardian Tank 2",
                "Guardian Tank 3",
                "Jasper Chain Pair 1",
                "Jasper Chain Pair 2",
                "Tile Painter",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\mogushan_vaults__thestoneguard",
            mechanics = {
                Mechanic("Assign three guardian tanks and crystal-soak groups; swap guardians to control petrification while keeping overloaded pairs separated."),
            },
        }),
        Encounter("Feng the Accursed", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Nullification Barrier Tank",
                "Shroud of Reversal Tank",
                "Wildfire Position Caller",
                "Arcane Resonance Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\mogushan_vaults__fengtheaccursed",
            mechanics = {
                Mechanic("Tanks assign Nullification Barrier and Shroud of Reversal uses for each weapon phase; stack/spread and place Wildfire safely."),
            },
        }),
        Encounter("Gara'jal the Spiritbinder", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Spirit Group 1",
                "Spirit Group 2",
                "Spirit Group 3",
                "Spirit Healer 1",
                "Spirit Healer 2",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\mogushan_vaults__garajalthespiritbinder",
            mechanics = {
                Mechanic("Preassign Spirit Totem groups with a healer, rotate Voodoo Doll tanks, and send empowered players to kill spirit adds before enrage."),
            },
        }),
        Encounter("The Spirit Kings", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Flanking Orders Caller",
                "Volley Interrupt 1",
                "Volley Interrupt 2",
                "Undying Shadow Team",
                "Maddening Shout Break Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\mogushan_vaults__thespiritkings",
            mechanics = {
                Mechanic("Rotate interrupts and control by active king: stack for Qiang, spread for Subetai, kill Undying Shadows, and stop damage during Maddening Shout."),
            },
        }),
        Encounter("Elegon", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Charge Lane 1",
                "Charge Lane 2",
                "Charge Lane 3",
                "Charge Lane 4",
                "Charge Lane 5",
                "Charge Lane 6",
                "Pillar Kill Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\mogushan_vaults__elegon",
            mechanics = {
                Mechanic("Assign Energy Charge lanes, reset Overcharged stacks outside the ring, kill protectors at the edge, and split pillar teams evenly."),
            },
        }),
        Encounter("Will of the Emperor", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Jan-xi Tank",
                "Qin-xi Tank",
                "Emperor's Courage Control",
                "Emperor's Rage Control 1",
                "Emperor's Rage Control 2",
                "Titan Gas Cooldown Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\mogushan_vaults__willoftheemperor",
            mechanics = {
                Mechanic("One tank holds each boss and performs the Devastating Combo dance; control Rage, Courage, and Strength adds by strict priority."),
            },
        }),
    },
})
