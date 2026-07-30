local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "TBC",
    key = "zulaman", name = "Zul'Aman", size = 10,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulaman",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(2)),
            Group("Utility", {
                "Primary Interrupt",
                "Backup Interrupt",
                "Dispel",
                "Crowd Control",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulaman",
        }),
        Encounter("Akil'zon", {
            Group("Tanks", { "Akil'zon Tank" }),
            Group("Healing", {
                A.HEALER.TANK,
                A.HEALER.RAID,
            }),
            Group("Utility", {
                "Electrical Storm Stack Caller",
                "Eagle Kill Lead",
                "Static Disruption Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulaman__akilzon",
            spellIcon = 43648,
            mechanics = {
                Mechanic("Spread for Static Disruption, then collapse under the Electrical Storm target."),
                Mechanic("Kill Soaring Eagles without missing the next storm stack."),
                Mechanic("Keep the raid near enough to regroup quickly but not stacked between storms."),
            },
        }),
        Encounter("Nalorakk", {
            Group("Tanks", {
                "Troll Form Tank",
                "Bear Form Tank",
            }),
            Group("Healing", {
                A:Healer(A.Target.TANKS, nil, "Troll Tank Healer"),
                A:Healer(A.Target.TANKS, nil, "Bear Tank Healer"),
            }),
            Group("Utility", {
                "Charge Position Caller",
                "Tank Swap Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulaman__nalorakk",
            spellIcon = 42398,
            mechanics = {
                Mechanic("Two tanks swap between troll and bear forms to manage form-specific debuffs."),
                Mechanic("Spread ranged players so Brutal Swipe and Surge do not punish the group."),
                Mechanic("Healers prepare for heavy tank damage and raid bleeds during bear form."),
            },
        }),
        Encounter("Jan'alai", {
            Group("Tanks", {
                "Jan'alai Tank",
                "Hatchling Tank",
            }),
            Group("Hatchers", {
                "Left Hatcher Control",
                "Right Hatcher Control",
                "Left Egg Kill Lead",
                "Right Egg Kill Lead",
            }),
            Group("Healing", {
                A:Healer(A.Target.TANKS, nil, "Boss Tank Healer"),
                A:Healer(A.Target.TANKS, nil, "Hatchling Tank Healer"),
            }),
            Group("Utility", {
                "Fire Bomb Caller",
                "Flame Breath Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulaman__janalai",
            spellIcon = 43140,
            mechanics = {
                Mechanic("Control the hatchers so one hatchling tank receives manageable egg waves."),
                Mechanic("Stack hatchlings for controlled AoE and do not leave too many eggs for the forced hatch."),
                Mechanic("Spread around Fire Bombs and move away from the bomb nearest your position."),
            },
        }),
        Encounter("Halazzi", {
            Group("Tanks", {
                "Halazzi Tank",
                "Spirit Lynx Tank",
            }),
            Group("Healing", {
                A:Healer(A.Target.TANKS, nil, "Halazzi Tank Healer"),
                A:Healer(A.Target.TANKS, nil, "Lynx Tank Healer"),
            }),
            Group("Utility", {
                "Corrupted Lightning Totem Lead",
                "Flame Shock Dispel",
                "Phase Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulaman__halazzi",
            spellIcon = 43303,
            mechanics = {
                Mechanic("A second tank controls the Spirit Lynx whenever Halazzi splits."),
                Mechanic("Destroy Corrupted Lightning Totems immediately and dispel Flame Shock."),
                Mechanic("Recombine damage carefully and save cooldowns for the final rapid phase."),
            },
        }),
        Encounter("Hex Lord Malacrass", {
            Group("Tanks", {
                "Malacrass Tank",
                "Add Tank",
            }),
            Group("Add Control", {
                "Add 1 Control",
                "Add 2 Control",
                "Add 3 Control",
                "Add 4 Control",
            }),
            Group("Interrupts", {
                "Primary Interrupt",
                "Backup Interrupt",
            }),
            Group("Utility", {
                "Siphoned Ability Caller",
                "Purge or Dispel",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulaman__hexlordmalacrass",
            spellIcon = 43501,
            mechanics = {
                Mechanic("Crowd-control eligible adds, kill the dangerous remaining adds, then focus Malacrass."),
                Mechanic("Interrupt or counter dangerous stolen class abilities after every Siphon Soul."),
                Mechanic("Heal through Spirit Bolts and purge or dispel the boss whenever applicable."),
            },
        }),
        Encounter("Zul'jin", {
            Group("Tanks", { "Zul'jin Tank" }),
            Group("Healing", {
                A.HEALER.TANK,
                A.HEALER.RAID,
            }),
            Group("Utility", {
                "Grievous Throw Clear",
                "Creeping Paralysis Dispel",
                "Claw Rage Healer",
                "Lynx Rush Healer",
                "Flame Whirl Position Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulaman",
            spellIcon = 43093,
            mechanics = {
                Mechanic("Handle each animal phase separately: clear Grievous Throw and dispel Paralysis."),
                Mechanic("Stop unnecessary casts during the eagle phase and focus healing through lynx attacks."),
                Mechanic("In dragonhawk phase, spread out and move from Flame Whirl fire columns."),
            },
        }),
    },
})
