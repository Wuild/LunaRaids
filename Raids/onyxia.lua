local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic
local Rec = Raid.Recommendation
local Reuse = { roles = { Raid.Role.HEALER, Raid.Role.DAMAGE }, allowReuse = true }

local raid = Raid:RegisterRaid({
    expansion = "VANILLA",
    key = "onyxia", name = "Onyxia's Lair", size = 40,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\onyxia",
    guides = {
        ["Onyxia"] = {
            Mechanic("Phase 1: tank Onyxia facing the back wall; everyone else stays at her sides and avoids tail swipes."),
            Mechanic("Phase 2: spread, kill whelps, and move perpendicular to her position when Deep Breath is called."),
            Mechanic("Phase 3: return to phase-one positioning, use Fear Ward or stance tools, and control threat after fears."),
        },
    },
    recommendations = {
        Rec("fear ward", { "PRIEST" }, { "Discipline", "Holy", "Shadow" }, Reuse),
        Rec("whelp tank", { "PALADIN", "WARRIOR", "DRUID" }, { "Protection", "Feral" }),
        Rec("whelp aoe", { "MAGE", "WARLOCK", "PALADIN" }, { "Frost", "Fire", "Destruction", "Protection" }),
    },
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, "Whelp Tank 1", "Whelp Tank 2" }),
            Group("Healing", A:Healers(10)),
            Group("Utility", { "Fear Ward", "Whelp AoE Lead" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\onyxia",
        }),
        Boss("Onyxia", {
            A.TANK.MAIN, "Whelp Tank 1", "Whelp Tank 2",
        }, {
            "Fear Ward", "Deep Breath Caller",
            "Whelp AoE Lead", "Phase 3 Position Caller",
        }, 10, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\onyxia",
            spellIcon = 18392,
        }),
    },
})
