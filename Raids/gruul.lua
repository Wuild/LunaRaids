local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic
local Rec = Raid.Recommendation

local raid = Raid:RegisterRaid({
    expansion = "TBC",
    key = "gruul", name = "Gruul's Lair", size = 25, instanceID = 565,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\gruul",
    guides = {
        ["High King Maulgar"] = {
            Mechanic("Krosh's mage tank steals Spell Shield on every cast; dedicated healing must account for unavoidable fire damage."),
            Mechanic("Purge Kiggler's Lightning Shield, keep his ranged tank outside Arcane Shock range, and fear or control Olm's summon."),
        },
        ["Gruul the Dragonkiller"] = {
            Mechanic("The Hateful Strike tank stays second on threat and at high health; other melee must not overtake that threat position."),
            Mechanic("After Ground Slam, spread before Shatter based on the movement debuff and avoid Cave In without collapsing onto others."),
        },
    },
    recommendations = {
        Rec("krosh", { "MAGE" }, { "Fire", "Arcane" }),
        Rec("kiggler", { "HUNTER" }, { "Marksmanship", "Beast Mastery" }),
        Rec("olm", { "WARLOCK" }, { "Demonology", "Affliction" }),
        Rec("blindeye interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
        Rec("olm interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
        Rec("felhunter", { "WARLOCK" }, { "Demonology", "Affliction" }),
        Rec("hateful strike tank", { "WARRIOR", "DRUID" }, { "Protection", "Feral" }),
    },
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, "Add Tank 1", "Add Tank 2" }),
            Group("Healing", A:Healers(5)),
            Group("Utility", Slots("Interrupt", 3)),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\gruul",
        }),
        Encounter("High King Maulgar", {
            Group("Tanks", {
                A:Tank("maulgar", "Maulgar Tank"),
                A:ClassUtility(
                    "krosh_tank", "Krosh Mage Tank", { "MAGE" }),
                A:ClassUtility(
                    "olm_tank", "Olm Felhunter Controller", { "WARLOCK" }),
                A:ClassUtility(
                    "kiggler_tank", "Kiggler Ranged Tank",
                    { "HUNTER", "DRUID" }),
                A:Tank("blindeye", "Blindeye Tank"),
            }),
            Group("Healing", {
                A:Healer(A.Target.TANKS, nil,
                    "Maulgar Tank Healer", "Maulgar Tank"),
                A:Healer(A.Target.TANKS, nil,
                    "Krosh Tank Healer", "Krosh Mage Tank"),
                A:Healer(A.Target.TANKS, nil,
                    "Olm Tank Healer", "Olm Felhunter Controller"),
                A:Healer(A.Target.TANKS, nil,
                    "Kiggler Tank Healer", "Kiggler Ranged Tank"),
                A:Healer(A.Target.TANKS, nil,
                    "Blindeye Tank Healer", "Blindeye Tank"),
            }),
            Group("Interrupts", { "Blindeye Interrupt 1", "Blindeye Interrupt 2", "Olm Interrupt" }),
            Group("Utility", {
                A:ClassUtility(
                    "olm_backup", "Olm Backup Enslave", { "WARLOCK" }),
                "Council Kill Order Caller",
            }),
        }, {
            "High King Maulgar",
            "Krosh Firehand",
            "Olm the Summoner",
            "Kiggler the Crazed",
            "Blindeye the Seer",
        }, {
            5, -- Maulgar: Triangle, last
            3, -- Krosh: Square, third
            2, -- Olm: Cross, second
            4, -- Kiggler: Moon, fourth
            1, -- Blindeye: Skull, first
        }, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\gruul__highkingmaulgar",
            spellIcon = 33238,
            mechanics = {
                Mechanic("Separate all five enemies immediately and keep their areas from overlapping."),
                Mechanic("A mage tanks Krosh by Spellstealing Spell Shield; a warlock controls Olm with an enslaved Felhunter."),
                Mechanic("Kill Blindeye first while interrupting heals, then Olm, Krosh, Kiggler, and Maulgar."),
                Mechanic("Maulgar's tank faces him away; ranged spread and react to Whirlwind and charge."),
            },
        }),
        Encounter("Gruul the Dragonkiller", {
            Group("Tanks", { A.TANK.MAIN, "Hateful Strike Tank" }),
            Group("Healing", {
                A:Healer(A.Target.MAIN_TANK, 1),
                A:Healer(A.Target.MAIN_TANK, 2),
                A:Healer(A.Target.TANKS, nil,
                    "Hateful Strike Tank Healer", "Hateful Strike Tank"),
                A:Healer(A.Target.RAID, 1),
                A:Healer(A.Target.RAID, 2),
            }),
            Group("Utility", { "Shatter Position Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\gruul",
            spellIcon = 36300,
            mechanics = {
                Mechanic("Spread throughout the room while tanks maintain the top two threat positions."),
                Mechanic("Move away from others during Ground Slam before Shatter resolves."),
                Mechanic("Avoid Cave In and race the stacking Growth damage with clean cooldown usage."),
            },
        }),
    },
})
