local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic
local Rec = Raid.Recommendation
local Reuse = { roles = { Raid.Role.HEALER, Raid.Role.DAMAGE }, allowReuse = true }
local HealerReuse = { roles = { Raid.Role.HEALER }, allowReuse = true }

local raid = Raid:RegisterRaid({
    expansion = "TBC",
    key = "zulaman", name = "Zul'Aman", size = 10,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulaman",
    guides = {
        ["Akil'zon"] = {
            Mechanic("Stay loosely spread between storms, then collapse directly under the lifted player before Electrical Storm damage begins."),
            Mechanic("Ranged kill Soaring Eagles while the group remains close enough to stack quickly for the next storm."),
        },
        ["Nalorakk"] = {
            Mechanic("Tanks alternate troll and bear forms so Mangle and Lacerating Slash do not remain on the same target."),
            Mechanic("Ranged spread for Surge; healers prepare raid recovery from Deafening Roar and heavy bear-form bleeds."),
        },
        ["Jan'alai"] = {
            Mechanic("Control one hatcher and allow planned egg waves; the hatchling tank stacks adds for controlled AoE."),
            Mechanic("During Fire Bombs, stop movement until bomb positions are visible, then step into a clear gap before detonation."),
        },
        ["Halazzi"] = {
            Mechanic("The off-tank picks up Spirit Lynx immediately at every split while damage follows the planned boss or lynx priority."),
            Mechanic("Kill Corrupted Lightning Totems immediately and dispel Flame Shock before the final rapid split cycles."),
        },
        ["Hex Lord Malacrass"] = {
            Mechanic("Choose crowd control from the actual add roster, kill uncontrolled priority adds, and maintain control through the boss burn."),
            Mechanic("Interrupt dangerous stolen abilities, purge removable buffs, and use healing cooldowns for every Spirit Bolts channel."),
        },
        ["Zul'jin"] = {
            Mechanic("Bear: dispel Creeping Paralysis; eagle: stop unnecessary casts and avoid tornadoes; lynx: focus-heal Claw Rage targets."),
            Mechanic("Dragonhawk: spread and avoid fire columns; throughout the fight clear Grievous Throw by healing targets above its threshold."),
        },
    },
    recommendations = {
        Rec("dispel", { "PRIEST", "PALADIN", "SHAMAN" }, { "Discipline", "Holy", "Restoration" }, Reuse),
        Rec("interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
        Rec("hatcher", { "HUNTER", "MAGE", "WARLOCK" }, { "Marksmanship", "Frost", "Affliction" }),
        Rec("add control", { "MAGE", "HUNTER", "WARLOCK", "PRIEST" }, { "Frost", "Survival", "Affliction", "Shadow" }),
        Rec("hex", { "MAGE", "DRUID" }, { "Arcane", "Frost", "Restoration", "Balance" }, Reuse),
        Rec("claw rage healer", { "PALADIN", "PRIEST", "DRUID", "SHAMAN" }, { "Holy", "Discipline", "Restoration" }, HealerReuse),
        Rec("lynx rush healer", { "SHAMAN", "DRUID", "PRIEST", "PALADIN" }, { "Restoration", "Holy", "Discipline" }, HealerReuse),
        Rec("flame breath", { "HUNTER", "MAGE", "WARLOCK" }, { "Marksmanship", "Frost", "Affliction" }),
    },
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
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\zulaman__zuljin",
            spellIcon = 43093,
            mechanics = {
                Mechanic("Handle each animal phase separately: clear Grievous Throw and dispel Paralysis."),
                Mechanic("Stop unnecessary casts during the eagle phase and focus healing through lynx attacks."),
                Mechanic("In dragonhawk phase, spread out and move from Flame Whirl fire columns."),
            },
        }),
    },
})
