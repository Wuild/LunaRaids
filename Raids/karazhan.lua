local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "TBC",
    key = "karazhan", name = "Karazhan", size = 10,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(2)),
            Group("Utility", { "Dispel", "Interrupt", "Kiter" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan",
        }),
        Encounter("Attumen the Huntsman", {
            Group("Tanks", { "Attumen Tank", "Midnight Tank" }),
            Group("Healing", { A.HEALER.TANK, A.HEALER.RAID }),
            Group("Utility", { "Decurse Lead", "Disarm Lead" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__attumenthehuntsman",
            spellIcon = 29711,
            mechanics = {
                Mechanic("Tank Midnight away from the raid and pick up Attumen when he appears."),
                Mechanic("Remove Intangible Presence quickly; ranged stay spread for charges."),
                Mechanic("After they merge, face Attumen away and keep the raid out of his cleave."),
            },
        }),
        Encounter("Moroes", {
            Group("Tanks", { "Moroes Tank", A.TANK.OFF }),
            Group("Crowd Control", Slots("Guest CC", 4)),
            Group("Utility", { "Garrote Cleanse", "Interrupt" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__moroes",
            spellIcon = 29448,
            mechanics = {
                Mechanic("Crowd-control dangerous guests and establish a reliable kill order."),
                Mechanic("Two tanks stay highest on threat to control Gouge and Blind."),
                Mechanic("Remove Garrote where possible; otherwise finish before healing is overwhelmed."),
            },
        }),
        Encounter("Maiden of Virtue", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", { A.HEALER.TANK, A.HEALER.RAID }),
            Group("Utility", { "Dispel", "Blessing of Sacrifice" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__maidenofvirtue",
            spellIcon = 29522,
            mechanics = {
                Mechanic("Spread around the room and dispel Holy Fire immediately."),
                Mechanic("Melee minimize Holy Ground damage and healers prepare for Repentance."),
                Mechanic("A paladin can use Blessing of Sacrifice to break Repentance and recover the raid."),
            },
        }),
        Encounter("Opera Event", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Utility", { "Primary Interrupt", "Backup Interrupt", "Fear Ward", "Kiter" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__operaevent",
            spellIcon = 31013,
            mechanics = {
                Mechanic("Identify the active Opera encounter and confirm interrupts, fears, or kiting before pull."),
                Mechanic("Keep dangerous casts controlled and avoid overlapping ground effects."),
                Mechanic("Prioritize adds and encounter objects before returning damage to the boss."),
            },
        }),
        Encounter("Nightbane", {
            Group("Tanks", { A.TANK.MAIN, "Skeleton Tank" }),
            Group("Healing", { A.HEALER.TANK, A.HEALER.RAID }),
            Group("Utility", { "Fear Ward", "Skeleton AoE Lead" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__nightbane",
            spellIcon = 36922,
            mechanics = {
                Mechanic("Ground phase: face Nightbane away, avoid Charred Earth, and handle Fear."),
                Mechanic("Air phase: group carefully, kill skeletons quickly, and control healing threat."),
                Mechanic("Return to ground positions before each landing and watch the tail and cleave."),
            },
        }),
        Encounter("The Curator", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", { A.HEALER.TANK, A.HEALER.RAID }),
            Group("Utility", {
                "Astral Flare Kill Lead",
                "Evocation Burn Cooldowns",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__thecurator",
            spellIcon = 30254,
            mechanics = {
                Mechanic("Kill Astral Flares immediately while maintaining steady damage on Curator."),
                Mechanic("Use mana efficiently until Evocation, then commit cooldowns and burst damage."),
                Mechanic("Keep ranged spacing so flare damage does not pressure multiple players."),
            },
        }),
        Encounter("Terestian Illhoof", {
            Group("Tanks", { "Illhoof Tank", "Imp Tank" }),
            Group("Utility", { "Demon Chains Lead", "AoE Lead", "Primary Interrupt" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__terestianillhoof",
            spellIcon = 30065,
            mechanics = {
                Mechanic("Keep Illhoof and Kil'rek controlled; cleave imps without losing boss pressure."),
                Mechanic("Destroy Demon Chains immediately when a player is sacrificed."),
                Mechanic("Interrupt Shadow Bolt Volley and use AoE only when threat is stable."),
            },
        }),
        Encounter("Shade of Aran", {
            Group("Interrupt Rotation", Slots("Interrupt", 3)),
            Group("Utility", { "Elemental CC 1", "Elemental CC 2", "Elemental CC 3", "Elemental CC 4" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__shadeofaran",
            spellIcon = 29946,
            mechanics = {
                Mechanic("Interrupt Frostbolt and Fireball, but let Arcane Missiles channel."),
                Mechanic("Do not move during Flame Wreath; run to the walls for Arcane Explosion."),
                Mechanic("Control water elementals and conserve tools for the final high-damage stretch."),
            },
        }),
        Encounter("Netherspite", {
            Group("Red Beam", {
                A:Tank("netherspite_red_1", "Red Beam 1"),
                A:Tank("netherspite_red_2", "Red Beam 2"),
            }),
            Group("Green Beam", {
                A:Healer(A.Target.RAID, 1, "Green Beam"),
                A:Healer(A.Target.RAID, 2, "Green Beam"),
            }),
            Group("Blue Beam", {
                A:Utility("netherspite_blue", "Blue Beam", 1),
                A:Utility("netherspite_blue", "Blue Beam", 2),
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__netherspite",
            spellIcon = 38523,
            mechanics = {
                Mechanic("Assign rotations for the red, green, and blue beams before the pull."),
                Mechanic("Take beams before they reach Netherspite and rotate before stacks become dangerous."),
                Mechanic("During banish, avoid Netherbreath and reset for the next portal phase."),
            },
        }),
        Encounter("Chess Event", {
            Group("Pieces", { "King", "Queen", "Bishop 1", "Bishop 2", "Rook 1", "Rook 2" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__chessevent",
            spellIcon = 37471,
            mechanics = {
                Mechanic("Take key pieces quickly and move the king out of fire."),
                Mechanic("Use piece abilities on cooldown and keep healers positioned behind the front line."),
                Mechanic("Focus the enemy king while protecting your own."),
            },
        }),
        Encounter("Prince Malchezaar", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", { A.HEALER.TANK, A.HEALER.RAID }),
            Group("Utility", { "Enfeeble Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan",
            spellIcon = 30852,
            mechanics = {
                Mechanic("Tank Prince against a safe wall and keep ranged spread for Shadow Nova."),
                Mechanic("Players hit by Enfeeble move out before Shadow Nova, then return after it lands."),
                Mechanic("React early to infernals and save defensive cooldowns for the final phase."),
            },
        }),
    },
})
