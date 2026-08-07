local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Mechanic = Raid.DataMechanic
local A = Raid.Assignment
local RAID_ICON = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\dragon_soul"

Raid:RegisterRaid({
    expansion = "CATA",
    key = "dragon_soul", name = "Dragon Soul", size = 25, instanceID = 967,
    icon = RAID_ICON,
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
        }, nil, nil, { icon = RAID_ICON }),
        Encounter("Morchok", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Stomp Group 1",
                "Stomp Group 2",
                "Crystal Soak Lead",
                "Heroic Kohcrom Tank",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\dragon_soul__morchok",
            mechanics = {
                Mechanic("Tanks swap Crush Armor and split Stomp damage with assigned groups; crystal teams soak every Resonating Crystal and hide from Black Blood."),
            },
        }),
        Encounter("Warlord Zon'ozz", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Ranged Bounce Group",
                "Melee Bounce Group",
                "Void Impact Caller",
                "Tentacle Kill Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\dragon_soul__warlordzonozz",
            mechanics = {
                Mechanic("Assign a ranged bounce group and melee return, call the final Void impact into Zon'ozz, then spread to kill tentacles during Black Blood."),
            },
        }),
        Encounter("Yor'sahj the Unsleeping", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Ooze Priority Caller",
                "Mana Void Team",
                "Deep Corruption Caller",
                "Forgotten One AoE Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\dragon_soul__yorsahjtheunsleeping",
            mechanics = {
                Mechanic("Use a fixed ooze priority caller, assign Mana Void recovery, spread for green, stack for red/black, and limit healing during purple."),
            },
        }),
        Encounter("Hagara the Stormbinder", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Ice Lance Soaker 1",
                "Ice Lance Soaker 2",
                "Frost Crystal Team 1",
                "Frost Crystal Team 2",
                "Lightning Chain Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\dragon_soul__hagarathestormbinder",
            mechanics = {
                Mechanic("Assign Focused Assault tank cooldowns, Ice Lance soakers, frost-phase crystal groups, and a full lightning-conduit chain."),
            },
        }),
        Encounter("Ultraxion", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Hour Soaker 1",
                "Hour Soaker 2",
                "Hour Soaker 3",
                "Red Crystal Healer",
                "Green Crystal Healer",
                "Blue Crystal Healer",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\dragon_soul__ultraxion",
            mechanics = {
                Mechanic("Create Hour of Twilight soaker rotations and healer crystal order; everyone uses Heroic Will for Hour/Fading Light and stacks for cooldown coverage."),
            },
        }),
        Encounter("Warmaster Blackhorn", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Drake Team Left",
                "Drake Team Right",
                "Elite Interrupt 1",
                "Elite Interrupt 2",
                "Onslaught Caller",
                "Sapper Stun",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\dragon_soul__warmasterblackhorn",
            mechanics = {
                Mechanic("Split drake harpoon teams, tank and interrupt elites, soak Twilight Barrages in pairs and large Onslaughts as a raid, then swap Blackhorn."),
            },
        }),
        Encounter("Spine of Deathwing", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(6)),
            Group("Utility", {
                "Searing Plasma Dispel",
                "Fiery Grip Break 1",
                "Fiery Grip Break 2",
                "Blood Tank",
                "Amalgamation Tank",
                "Roll Caller",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\dragon_soul__spineofdeathwing",
            mechanics = {
                Mechanic("Assign one dispeller, Fiery Grip breakers and blood control; feed nine residues to each Amalgamation and position Nuclear Blast at the plate."),
            },
        }),
        Encounter("Madness of Deathwing", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(7)),
            Group("Utility", {
                "Platform Order Caller",
                "Impale Cooldown 1",
                "Impale Cooldown 2",
                "Elementium Bolt Team",
                "Blood Control Lead",
                "Phase 2 Cooldown Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\dragon_soul__madnessofdeathwing",
            mechanics = {
                Mechanic("Set platform order, assign Impale cooldowns and Elementium Bolt burst, control regenerative bloods, then rotate phase-two raid cooldowns."),
            },
        }),
    },
})
