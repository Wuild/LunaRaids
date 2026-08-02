local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic
local Rec = Raid.Recommendation

local clickers = Slots("Clicker", 5)
for index, marker in ipairs({
    "Skull", "Cross", "Square", "Moon", "Triangle",
}) do
    clickers[index].label = marker .. " Clicker"
end

local raid = Raid:RegisterRaid({
    expansion = "TBC",
    key = "magtheridon", name = "Magtheridon's Lair", size = 25,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\magtheridon",
    guides = {
        ["Magtheridon"] = {
            Mechanic("Use a dedicated interrupt on every Channeler's Dark Mending and Shadow Bolt Volley; banish or tank Abyssals away."),
            Mechanic("All five cubes must be clicked together before Blast Nova; clickers hold through the channel and rotate for Mind Exhaustion."),
            Mechanic("At 30%, move away from walls before the ceiling collapse and stabilize tank healing before resuming full damage."),
        },
    },
    recommendations = {
        Rec("interrupt", { "ROGUE", "SHAMAN", "MAGE" }, { "Combat", "Enhancement", "Elemental" }),
        Rec("channeler tank", { "WARRIOR", "DRUID", "PALADIN" }, { "Protection", "Feral" }),
        Rec("clicker", { "HUNTER", "MAGE", "WARLOCK", "PRIEST", "SHAMAN" }, { "Marksmanship", "Frost", "Affliction", "Shadow", "Elemental" }),
        Rec("banish", { "WARLOCK" }, { "Affliction", "Demonology" }),
    },
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", {
                A.TANK.MAIN,
                "Channeler Tank 1",
                "Channeler Tank 2",
            }),
            Group("Healing", A:Healers(5)),
            Group("Utility", {
                "Click Team Lead",
                "Interrupt Lead",
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\magtheridon",
        }),
        Encounter("Magtheridon", {
            Group("Tanks", {
                A:Tank("magtheridon", "Skull Channeler / Magtheridon Tank"),
                A:Tank("channeler", "Cross Off Tank", 2),
                A:Tank("channeler", "Triangle Off Tank", 3),
            }),
            Group("Click Team", clickers),
            Group("Interrupts", { "Channeler 1 Interrupt", "Channeler 2 Interrupt", "Channeler 3 Interrupt", "Channeler 4 Interrupt", "Channeler 5 Interrupt" }),
            Group("Utility", {
                "Abyssal Banish Lead",
                "Click Caller",
                "Collapse Caller",
            }),
        }, {
            "Magtheridon", "Hellfire Channeler",
        }, {
            2, -- Magtheridon: Cross, after the Channelers
            1, -- Current Channeler: Skull
        }, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\magtheridon",
            spellIcon = 30528,
            mechanics = {
                Mechanic("Tank and interrupt each Channeler; focus them down in the assigned order."),
                Mechanic("The same five assigned players can click the cubes for every Blast Nova in the post-nerf encounter."),
                Mechanic("At 30%, stabilize after the ceiling collapse, then continue clicks and avoid fire."),
            },
        }),
    },
})
