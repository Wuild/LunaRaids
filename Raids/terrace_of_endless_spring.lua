local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\terrace_of_endless_spring"

Raid:RegisterRaid({
    expansion = "MOP",
    key = "terrace_of_endless_spring", name = "Terrace of Endless Spring", size = 25, instanceID = 996,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Protectors of the Endless", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Water Bolt Interrupt 1",
                "Water Bolt Interrupt 2",
                "Cleansing Waters Interrupt",
                "Lightning Prison Dispel",
                "Essence Carrier",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\terrace_of_endless_spring__protectorsoftheendless",
            mechanics = {
                Mechanic("Choose kill order before pull, interrupt Water Bolt and Cleansing Waters, dispel Lightning Prison, and assign Corrupted Essence carriers."),
            },
        }),
        Encounter("Tsulong", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Dark of Night Soaker 1",
                "Dark of Night Soaker 2",
                "Terrorize Dispel 1",
                "Terrorize Dispel 2",
                "Day Healing Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\terrace_of_endless_spring__tsulong",
            mechanics = {
                Mechanic("Night teams soak and kill Dark of Night while avoiding Dread Shadows; day healers dispel Terrorize and maximize healing through Sun Breath."),
            },
        }),
        Encounter("Lei Shi", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Hide AoE Lead",
                "Protector CC 1",
                "Protector CC 2",
                "Protector Kill Lead",
                "Get Away Cooldown",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\terrace_of_endless_spring__leishi",
            mechanics = {
                Mechanic("Tanks swap Spray stacks, assigned AoE reveals Hide, Protect add CC leaves one target for focus, and Get Away cooldowns prevent knock-offs."),
            },
        }),
        Encounter("Sha of Fear", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A:Tank("extra", "Extra Tank", 3) }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Platform Team 1",
                "Platform Team 2",
                "Platform Team 3",
                "Terror Spawn Tank",
                "Champion of Light",
                "Huddle Dispel",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\terrace_of_endless_spring__shaoffear",
            mechanics = {
                Mechanic("Assign Dread Spray side-platform teams, tank and kill Terror Spawns from behind, stand in the Wall of Light, and rotate heroic Huddle dispels."),
            },
        }),
    },
})
