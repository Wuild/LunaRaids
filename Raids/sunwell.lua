local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic
local Rec = Raid.Recommendation
local Reuse = { roles = { Raid.Role.HEALER, Raid.Role.DAMAGE }, allowReuse = true }
local HealerReuse = { roles = { Raid.Role.HEALER }, allowReuse = true }

Raid:RegisterRaid({
    expansion = "TBC",
    key = "sunwell", name = "Sunwell Plateau", size = 25, instanceID = 580,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell",
    guides = {
        ["Kalecgos"] = {
            Mechanic("Portal groups enter Spectral Realm in rotation, tank Sathrovarr, and leave before Spectral Exhaustion becomes dangerous."),
            Mechanic("Decurse Curse of Boundless Agony with controlled timing and balance damage so dragon and demon reach low health together."),
        },
        ["Brutallus"] = {
            Mechanic("Two tanks swap at the planned Meteor Slash count while both soak groups remain stacked separately behind the boss."),
            Mechanic("Burn targets run to their assigned side without clipping others; dedicated healers follow each Burn until it expires."),
        },
        ["Felmyst"] = {
            Mechanic("Mass-dispel Encapsulate quickly and keep north and south healers positioned to cover separated groups."),
            Mechanic("During air phase, watch Felmyst's direction, avoid all three Demonic Vapor trails, and move out of the lethal breath lane."),
        },
        ["The Eredar Twins"] = {
            Mechanic("A ranged tank holds Alythess while a physical tank holds Sacrolash; positioning controls Conflagration and Shadow Nova."),
            Mechanic("Conflagration targets move away immediately, Shadow Image adds are controlled, and healers manage alternating shadow/fire stacks."),
        },
        ["M'uru"] = {
            Mechanic("Side teams interrupt Shadowsword casters and kill Berserkers while the sentinel tank controls Void Sentinels and spawns."),
            Mechanic("Use planned AoE on humanoids and void spawns without missing Darkness; enter Entropius with adds dead and cooldowns ready."),
        },
        ["Kil'jaeden"] = {
            Mechanic("Spread for Fire Bloom, collapse behind Shield Orbs when Darkness is cast, and assign ranged players to kill Shield Orbs."),
            Mechanic("Dragon controllers rotate shields for Darkness and use haste or breath abilities on schedule without wasting orb duration."),
            Mechanic("Sinister Reflections are tanked and killed by class priority; move from Armageddon impacts while maintaining portal positioning."),
        },
    },
    recommendations = {
        Rec("dispel", { "PRIEST", "PALADIN", "SHAMAN" }, { "Discipline", "Holy", "Restoration" }, Reuse),
        Rec("curse dispel", { "MAGE", "DRUID" }, { "Arcane", "Frost", "Restoration", "Balance" }, Reuse),
        Rec("mass dispel", { "PRIEST" }, { "Discipline", "Holy", "Shadow" }, Reuse),
        Rec("north healer", { "SHAMAN", "DRUID", "PRIEST", "PALADIN" }, { "Restoration", "Holy", "Discipline" }, HealerReuse),
        Rec("south healer", { "SHAMAN", "DRUID", "PRIEST", "PALADIN" }, { "Restoration", "Holy", "Discipline" }, HealerReuse),
        Rec("alythess ranged tank", { "WARLOCK" }, { "Destruction", "Demonology" }),
        Rec("interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
        Rec("dragon", { "PRIEST", "PALADIN", "SHAMAN", "DRUID" }, { "Discipline", "Holy", "Restoration" }, { roles = { Raid.Role.HEALER, Raid.Role.DAMAGE }, allowReuse = true, encounter = "Kil'jaeden" }),
    },
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, A.TANK.THIRD }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Dispel Lead", "Interrupt Lead", "Dragon Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell",
        }),
        Encounter("Kalecgos", {
            Group("Tanks", {
                "Portal Tank 1", "Portal Tank 2", "Portal Tank 3",
            }),
            Group("Portal Groups", { "Portal Group 1 Lead", "Portal Group 2 Lead", "Portal Group 3 Lead" }),
            Group("Utility", { "Curse Dispel 1", "Curse Dispel 2", "Portal Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell__kalecgos",
            spellIcon = 45018,
            mechanics = {
                Mechanic("Rotate portal groups so tanks, healers, decursers, and damage enter the spectral realm together."),
                Mechanic("Swap tanks before Arcane Buffet grows dangerous and decurse in both realms."),
                Mechanic("Balance Kalecgos and Sathrovarr health, then finish both within the encounter window."),
            },
        }),
        Encounter("Brutallus", {
            Group("Tanks", { "Tank 1", "Tank 2" }),
            Group("Healing", { "Tank 1 Healer 1", "Tank 1 Healer 2", "Tank 2 Healer 1", "Tank 2 Healer 2", "Burn Healer 1", "Burn Healer 2", A.HEALER.RAID }),
            Group("Utility", { "Burn Caller", "Meteor Slash Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell__brutallus",
            spellIcon = 45150,
            mechanics = {
                Mechanic("Two tanks swap after three Meteor Slashes while two raid groups split each cone."),
                Mechanic("Burn targets leave their group without touching anyone and receive dedicated healing."),
                Mechanic("Maintain exact positioning and use all damage cooldowns to beat the enrage."),
            },
        }),
        Encounter("Felmyst", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", A:Healers(7)),
            Group("Encapsulate", { "North Healer", "South Healer" }),
            Group("Utility", { "Vapor Caller", "Mass Dispel 1", "Mass Dispel 2" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell__felmyst",
            spellIcon = 45665,
            mechanics = {
                Mechanic("Spread for Encapsulate, mass-dispel Gas Nova, and keep the tank clear of the raid."),
                Mechanic("During flight, follow Demonic Vapor paths and kill skeletons without crossing the trails."),
                Mechanic("Watch Felmyst's direction and move out of each green fog lane before she breathes."),
            },
        }),
        Encounter("Eredar Twins", {
            Group("Tanks", { "Sacrolash Tank" }),
            Group("Ranged Tank", {
                A:Utility("alythess_tank", "Alythess Ranged Tank"),
            }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Conflagration Caller", "Shadow Image Lead" }),
        }, { "Lady Sacrolash", "Grand Warlock Alythess" }, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell__eredartwins",
            spellIcon = 45248,
            mechanics = {
                Mechanic("A physical tank holds Sacrolash while a ranged tank controls Alythess."),
                Mechanic("Move Conflagration and Shadow Nova away and kill Shadow Images quickly."),
                Mechanic("Balance Fire and Shadow debuffs, then stabilize after the first twin dies."),
            },
        }),
        Encounter("M'uru", {
            Group("Tanks", { "Sentinel Tank", "Left Humanoid Tank", "Right Humanoid Tank", "Void Spawn Tank" }),
            Group("Teams", { "Left Side Lead", "Right Side Lead", "Portal Lead" }),
            Group("Interrupts", { "Left Interrupt 1", "Left Interrupt 2", "Right Interrupt 1", "Right Interrupt 2" }),
        }, {
            "M'uru", "Entropius", "Void Sentinel",
            "Shadowsword Berserker", "Shadowsword Fury Mage",
        }, {
            4, -- M'uru: Moon, cleave target after active adds
            5, -- Entropius: Triangle, phase two
            1, -- Void Sentinel: Skull, ranged priority
            3, -- Berserker: Square
            2, -- Fury Mage: Cross, melee priority
        }, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell__muru",
            spellIcon = 45996,
            mechanics = {
                Mechanic("Split teams left and right to tank and interrupt Berserkers and Fury Mages."),
                Mechanic("Tank Void Sentinels away, then control and AoE their Void Spawns."),
                Mechanic("Enter Entropius with adds cleared; spread, avoid Darkness, and burn through escalating damage."),
            },
        }),
        Encounter("Kil'jaeden", {
            Group("Tanks", { "Sinister Reflection Tank" }),
            Group("Healing", A:Healers(8)),
            Group("Dragon Rotation", { "Dragon 1", "Dragon 2", "Dragon 3", "Dragon 4" }),
            Group("Utility", { "Shield Orb Lead", "Armageddon Caller", "Darkness Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\sunwell",
            spellIcon = 45641,
            mechanics = {
                Mechanic("Stack and spread as called, kill Shield Orbs, and control Sinister Reflections."),
                Mechanic("Assigned players use the dragon orbs for Haste, shield, and healing at the planned times."),
                Mechanic("Group under Shield of the Blue for Darkness and move from Armageddon impacts."),
            },
        }),
    },
})
