local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic
local Rec = Raid.Recommendation
local Reuse = { roles = { Raid.Role.HEALER, Raid.Role.DAMAGE }, allowReuse = true }

Raid:RegisterRaid({
    expansion = "TBC",
    key = "tempest_keep", name = "Tempest Keep", size = 25, instanceID = 550,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\tempest_keep",
    guides = {
        ["Al'ar"] = {
            Mechanic("Platform tanks trade Al'ar at each movement and never stand directly below a platform when Flame Quills begins."),
            Mechanic("In phase 2, tanks swap for Melt Armor, stack Embers for controlled AoE, and move away from Dive Bomb impact."),
        },
        ["Void Reaver"] = {
            Mechanic("Ranged spread at maximum range and move sideways from incoming Arcane Orbs without running through other players."),
            Mechanic("Tanks maintain a threat rotation through Knock Away while melee remain behind and healers cover Pounding."),
        },
        ["High Astromancer Solarian"] = {
            Mechanic("Wrath of the Astromancer targets move to the assigned safe position before the debuff jumps or expires."),
            Mechanic("Stack and AoE agents, interrupt priests immediately, then spread and stabilize for Solarian's voidwalker phase."),
        },
        ["Kael'thas Sunstrider"] = {
            Mechanic("Assign every legendary weapon before the pull; loot and equip the correct weapon immediately after the weapon phase."),
            Mechanic("Kill resurrected advisers in the planned order while using staff immunity, mace healing, shield protection, and dagger debuffs."),
            Mechanic("Interrupt Fireball, break Shock Barrier before Pyroblast, kill Phoenix eggs, and spread vertically during Gravity Lapse."),
        },
    },
    recommendations = {
        Rec("crowd control", { "MAGE", "WARLOCK", "HUNTER", "PRIEST" }, { "Frost", "Affliction", "Survival", "Shadow" }),
        Rec("ember tank", { "PALADIN", "WARRIOR", "DRUID" }, { "Protection", "Feral" }),
        Rec("priest interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
        Rec("thaladred kiter", { "HUNTER", "MAGE", "WARLOCK" }, { "Marksmanship", "Frost", "Affliction" }),
        Rec("capernian tank", { "WARLOCK" }, { "Destruction", "Demonology" }),
        Rec("bow hunter tank", { "HUNTER" }, { "Marksmanship", "Beast Mastery" }),
        Rec("aoe weapons tank", { "PALADIN" }, { "Protection" }),
        Rec("interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
        Rec("mind control", { "PRIEST" }, { "Shadow", "Discipline", "Holy" }, Reuse),
    },
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A.TANK.THIRD }),
            Group("Healing", A:Healers(6)),
            Group("Utility", { "Interrupt Lead", "Crowd Control Lead" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\tempest_keep",
        }),
        Encounter("Al'ar", {
            Group("Tanks", { "Platform Tank 1", "Platform Tank 2", "Ember Tank" }),
            Group("Healing", {
                A:Healer(A.Target.TANKS, nil, "Platform Healer 1"),
                A:Healer(A.Target.TANKS, nil, "Platform Healer 2"),
                A:Healer(A.Target.TANKS, nil, "Ember Healer"),
                A:Healer(A.Target.RAID, 1),
                A:Healer(A.Target.RAID, 2),
                A:Healer(A.Target.RAID, 3),
            }),
            Group("Utility", { "Meteor Stack Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\tempest_keep__alar",
            spellIcon = 35181,
            mechanics = {
                Mechanic("Phase 1 tanks rotate between platforms while the raid kills Embers away from the group."),
                Mechanic("Move promptly when Al'ar changes platforms and avoid Flame Quills in the center and upper ring."),
                Mechanic("Phase 2: stack for Dive Bomb, control Embers, move from flame patches, and swap for Melt Armor."),
            },
        }),
        Encounter("Void Reaver", {
            Group("Tanks", { "Tank 1", "Tank 2", "Tank 3", "Tank 4" }),
            Group("Healing", {
                A:Healer(A.Target.TANKS, 1),
                A:Healer(A.Target.TANKS, 2),
                A:Healer(A.Target.TANKS, 3),
                A:Healer(A.Target.RAID, 1),
                A:Healer(A.Target.RAID, 2),
                A:Healer(A.Target.RAID, 3),
            }),
            Group("Utility", { "Orb Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\tempest_keep__voidreaver",
            spellIcon = 34172,
            mechanics = {
                Mechanic("Three or four tanks maintain threat so Knock Away does not send the boss into the raid."),
                Mechanic("Ranged players spread and move immediately from incoming Arcane Orbs."),
                Mechanic("Melee stay behind the boss, endure Pounding, and avoid pulling threat after tank knockbacks."),
            },
        }),
        Encounter("High Astromancer Solarian", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", { A:Healer(A.Target.TANKS, 1), A:Healer(A.Target.TANKS, 2), A:Healer(A.Target.RAID, 1), A:Healer(A.Target.RAID, 2), A:Healer(A.Target.RAID, 3) }),
            Group("Utility", { "Wrath Caller", "Priest Interrupt 1", "Priest Interrupt 2" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\tempest_keep__highastromancersolarian",
            spellIcon = 42783,
            mechanics = {
                Mechanic("Stack by role; the player with post-nerf Wrath moves away before the six-second explosion."),
                Mechanic("During portals, AoE the Agents and interrupt or stun both Solarium Priests."),
                Mechanic("At 20%, a tank picks up the voidwalker while fear protection covers the final burn."),
            },
        }),
        Encounter("Kael'thas Sunstrider", {
            Group("Advisors", {
                A:Utility("thaladred_kiter", "Thaladred Kiter"),
                A:Tank("sanguinar", "Sanguinar Tank"),
                A:Utility("capernian_tank", "Capernian Tank"),
                A:Tank("telonicus", "Telonicus Tank"),
            }),
            Group("Weapons", {
                A:Tank("devastation_weapon", "Devastation Tank"),
                A:Tank("aoe_weapons", "AoE Weapons Tank"),
                A:Utility("bow_weapon", "Bow Hunter Tank"),
            }),
            Group("Interrupts", { "Kael Interrupt 1", "Kael Interrupt 2", "Kael Interrupt 3" }),
            Group("Utility", {
                "Mind Control Break 1",
                "Mind Control Break 2",
                A:Tank("phoenix", "Phoenix Tank"),
                "Egg Kill Lead",
            }),
        }, {
            "Kael'thas Sunstrider", "Thaladred",
            "Lord Sanguinar", "Grand Astromancer Capernian",
            "Master Engineer Telonicus", "Phoenix",
        }, {
            5, -- Kael'thas
            1, -- Thaladred
            2, -- Sanguinar
            3, -- Capernian
            4, -- Telonicus
            6, -- Phoenix
        }, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\tempest_keep",
            spellIcon = 44863,
            mechanics = {
                Mechanic("Place the four advisers carefully, then kill Devastation, the bow, and the AoE weapon pack."),
                Mechanic("Loot and equip the correct legendary weapon before all advisers resurrect together."),
                Mechanic("Interrupt Fireballs, break Shock Barrier, stop Pyroblast, control Phoenixes, and spread during Gravity Lapse."),
            },
        }),
    },
})
