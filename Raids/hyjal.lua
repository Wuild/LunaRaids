local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local Slots = Raid.DataSlots
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local raid = Raid:RegisterRaid({
    expansion = "TBC",
    key = "hyjal", name = "Battle for Mount Hyjal", size = 25,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\hyjal",
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF, "Wave Tank 1", "Wave Tank 2" }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Wave Caller", "Decurse Lead", "Dispel Lead" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\hyjal",
        }),
        Encounter("Rage Winterchill", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Death and Decay Caller", "Dispel" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\hyjal__ragewinterchill",
            spellIcon = 31249,
            mechanics = {
                Mechanic("Spread loosely, dispel Icebolt quickly, and move out of Death and Decay."),
                Mechanic("Healers stabilize Frost Nova damage while melee avoid standing in the raid."),
                Mechanic("Use Jaina's forces, but keep the boss positioned safely away from fragile NPCs."),
            },
        }),
        Encounter("Anetheron", {
            Group("Tanks", { "Anetheron Tank", "Infernal Tank" }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Infernal Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\hyjal__anetheron",
            spellIcon = 31306,
            mechanics = {
                Mechanic("Keep Anetheron facing away and spread healers to reduce Carrion Swarm disruption."),
                Mechanic("The infernal tank collects Towering Infernals near Jaina while ranged kills them."),
                Mechanic("Players with Inferno move to the infernal area without dragging fire through the raid."),
            },
        }),
        Encounter("Kaz'rogal", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Mark Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\hyjal__kazrogal",
            spellIcon = 31447,
            mechanics = {
                Mechanic("Drain or burn mana aggressively; Mark of Kaz'rogal explodes players who reach zero mana."),
                Mechanic("Mana users spread away from each other before later Marks become frequent."),
                Mechanic("This is a damage race: use cooldowns early while healers conserve enough mana to finish."),
            },
        }),
        Encounter("Azgalor", {
            Group("Tanks", { "Azgalor Tank", "Doomguard Tank" }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Silence Position Caller", "Doom Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\hyjal__azgalor",
            spellIcon = 31344,
            mechanics = {
                Mechanic("Face Azgalor away, spread healers around the silence, and keep Rain of Fire clear."),
                Mechanic("Doomed players move to the assigned area before spawning a Lesser Doomguard."),
                Mechanic("The Doomguard tank gathers each spawn while the raid focuses the boss."),
            },
        }),
        Encounter("Archimonde", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", A:Healers(7)),
            Group("Utility", { "Fear Ward 1", "Fear Ward 2", "Decurse 1", "Decurse 2", "Air Burst Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\hyjal",
            spellIcon = 31972,
            mechanics = {
                Mechanic("Survival is the priority: decurse Grip immediately and move away from Doomfire."),
                Mechanic("Use Tears of the Goddess during Air Burst and maintain fear protection on the tank."),
                Mechanic("Never die near the raid; each death triggers Soul Charge and can chain into a wipe."),
            },
        }),
    },
})
