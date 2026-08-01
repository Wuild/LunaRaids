local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local Boss = Raid.DataBoss
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local RAID_ICON = "Interface\\Icons\\INV_Misc_Map_01"

local function RegisterCatalogRaid(expansion, key, name, bosses, size)
    local encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(size == 10 and 3 or 6)),
        }, nil, nil, { icon = RAID_ICON }),
    }

    for _, boss in ipairs(bosses) do
        local guide = Raid.PostTBCGuides[key][boss]
        if not guide then
            error("Missing encounter guide: " .. key .. " / " .. boss)
        end
        local tanks = { A.TANK.MAIN, A.TANK.OFF }
        for index = 3, guide.tanks or 2 do
            tanks[index] = A:Tank("extra", "Extra Tank", index)
        end
        local mechanics = {}
        for _, description in ipairs(guide) do
            mechanics[#mechanics + 1] = Mechanic(description)
        end
        encounters[#encounters + 1] = Boss(boss, tanks,
            guide.utility or {}, guide.healers or 6, nil, nil, {
            icon = RAID_ICON,
            mechanics = mechanics,
        })
    end

    Raid:RegisterRaid({
        expansion = expansion,
        key = key,
        name = name,
        size = size or 25,
        icon = RAID_ICON,
        encounters = encounters,
    })
end

-- Wrath of the Lich King
RegisterCatalogRaid("WOTLK", "wotlk_naxxramas", "Naxxramas", {
    "Anub'Rekhan", "Grand Widow Faerlina", "Maexxna",
    "Noth the Plaguebringer", "Heigan the Unclean", "Loatheb",
    "Instructor Razuvious", "Gothik the Harvester", "The Four Horsemen",
    "Patchwerk", "Grobbulus", "Gluth", "Thaddius", "Sapphiron",
    "Kel'Thuzad",
}, 25)
RegisterCatalogRaid("WOTLK", "obsidian_sanctum", "The Obsidian Sanctum", {
    "Sartharion",
}, 25)
RegisterCatalogRaid("WOTLK", "eye_of_eternity", "The Eye of Eternity", {
    "Malygos",
}, 25)
RegisterCatalogRaid("WOTLK", "vault_of_archavon", "Vault of Archavon", {
    "Archavon the Stone Watcher", "Emalon the Storm Watcher",
    "Koralon the Flame Watcher", "Toravon the Ice Watcher",
}, 25)
RegisterCatalogRaid("WOTLK", "ulduar", "Ulduar", {
    "Flame Leviathan", "Ignis the Furnace Master", "Razorscale",
    "XT-002 Deconstructor", "The Assembly of Iron", "Kologarn", "Auriaya",
    "Hodir", "Thorim", "Freya", "Mimiron", "General Vezax",
    "Yogg-Saron", "Algalon the Observer",
}, 25)
RegisterCatalogRaid("WOTLK", "trial_of_the_crusader", "Trial of the Crusader", {
    "The Northrend Beasts", "Lord Jaraxxus", "Faction Champions",
    "The Twin Val'kyr", "Anub'arak",
}, 25)
RegisterCatalogRaid("WOTLK", "wotlk_onyxia", "Onyxia's Lair", {
    "Onyxia",
}, 25)
RegisterCatalogRaid("WOTLK", "icecrown_citadel", "Icecrown Citadel", {
    "Lord Marrowgar", "Lady Deathwhisper", "Gunship Battle",
    "Deathbringer Saurfang", "Festergut", "Rotface", "Professor Putricide",
    "Blood Prince Council", "Blood-Queen Lana'thel", "Valithria Dreamwalker",
    "Sindragosa", "The Lich King",
}, 25)
RegisterCatalogRaid("WOTLK", "ruby_sanctum", "The Ruby Sanctum", {
    "Baltharus the Warborn", "Saviana Ragefire", "General Zarithrian",
    "Halion",
}, 25)

-- Cataclysm
RegisterCatalogRaid("CATA", "blackwing_descent", "Blackwing Descent", {
    "Magmaw", "Omnotron Defense System", "Maloriak", "Atramedes",
    "Chimaeron", "Nefarian",
}, 25)
RegisterCatalogRaid("CATA", "bastion_of_twilight", "The Bastion of Twilight", {
    "Halfus Wyrmbreaker", "Valiona and Theralion", "Ascendant Council",
    "Cho'gall", "Sinestra",
}, 25)
RegisterCatalogRaid("CATA", "throne_of_the_four_winds", "Throne of the Four Winds", {
    "Conclave of Wind", "Al'Akir",
}, 25)
RegisterCatalogRaid("CATA", "baradin_hold", "Baradin Hold", {
    "Argaloth", "Occu'thar", "Alizabal",
}, 25)
RegisterCatalogRaid("CATA", "firelands", "Firelands", {
    "Beth'tilac", "Lord Rhyolith", "Alysrazor", "Shannox", "Baleroc",
    "Majordomo Staghelm", "Ragnaros",
}, 25)
RegisterCatalogRaid("CATA", "dragon_soul", "Dragon Soul", {
    "Morchok", "Warlord Zon'ozz", "Yor'sahj the Unsleeping", "Hagara the Stormbinder",
    "Ultraxion", "Warmaster Blackhorn", "Spine of Deathwing", "Madness of Deathwing",
}, 25)

-- Mists of Pandaria
RegisterCatalogRaid("MOP", "mogushan_vaults", "Mogu'shan Vaults", {
    "The Stone Guard", "Feng the Accursed", "Gara'jal the Spiritbinder",
    "The Spirit Kings", "Elegon", "Will of the Emperor",
}, 25)
RegisterCatalogRaid("MOP", "heart_of_fear", "Heart of Fear", {
    "Imperial Vizier Zor'lok", "Blade Lord Ta'yak", "Garalon",
    "Wind Lord Mel'jarak", "Amber-Shaper Un'sok", "Grand Empress Shek'zeer",
}, 25)
RegisterCatalogRaid("MOP", "terrace_of_endless_spring", "Terrace of Endless Spring", {
    "Protectors of the Endless", "Tsulong", "Lei Shi", "Sha of Fear",
}, 25)
RegisterCatalogRaid("MOP", "throne_of_thunder", "Throne of Thunder", {
    "Jin'rokh the Breaker", "Horridon", "Council of Elders", "Tortos", "Megaera",
    "Ji-Kun", "Durumu the Forgotten", "Primordius", "Dark Animus",
    "Iron Qon", "Twin Consorts", "Lei Shen", "Ra-den",
}, 25)
RegisterCatalogRaid("MOP", "siege_of_orgrimmar", "Siege of Orgrimmar", {
    "Immerseus", "The Fallen Protectors", "Norushen", "Sha of Pride",
    "Galakras", "Iron Juggernaut", "Kor'kron Dark Shaman", "General Nazgrim",
    "Malkorok", "Spoils of Pandaria", "Thok the Bloodthirsty", "Siegecrafter Blackfuse",
    "Paragons of the Klaxxi", "Garrosh Hellscream",
}, 25)
