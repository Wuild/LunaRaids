local _, Raid = ...

local Encounter = Raid.DataEncounter
local Group = Raid.DataGroup
local A = Raid.Assignment
local Mechanic = Raid.DataMechanic

local function R(slot, classes, specs, roles, allowReuse)
    return A:Recommended(slot, {
        classes = classes, specs = specs,
        roles = roles, allowReuse = allowReuse,
    })
end

local function U(id, label, classes, specs, index, roles, allowReuse)
    return R(
        A:Utility(id, label, index),
        classes, specs, roles, allowReuse)
end

local function RepeatedUtility(id, label, count, classes, specs)
    local result = {}
    for index = 1, count do
        result[index] = U(id, label .. " " .. index,
            classes, specs, index)
    end
    return result
end

Raid:RegisterRaid({
    expansion = "TBC",
    key = "karazhan", name = "Karazhan", size = 10, instanceID = 532,
    icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan",
    guides = {
        ["Attumen the Huntsman"] = {
            Mechanic("Disarm Attumen when possible and decurse Intangible Presence before its hit and spell penalties disrupt the group."),
            Mechanic("Threat resets when Attumen mounts Midnight; stop damage until the tank has the merged boss."),
        },
        ["Moroes"] = {
            Mechanic("Assign a reliable control method and backup to every guest; reapply control before it expires."),
            Mechanic("Use immunity or removal effects on Garrote where available and keep an interrupt ready for controlled healer guests."),
        },
        ["Maiden of Virtue"] = {
            Mechanic("Ranged and healers occupy separate pillars so Holy Wrath cannot chain across multiple players."),
            Mechanic("A healer times movement into Holy Ground or a pre-cast heal so the tank survives Repentance."),
        },
        ["Opera Event"] = {
            Mechanic("Big Bad Wolf: the Red Riding Hood target kites around the room without cutting through melee or the tank."),
            Mechanic("Romulo and Julianne must die together; interrupt Julianne's heals and dispel her buffs throughout both phases."),
            Mechanic("Wizard of Oz: control Roar and Strawman, interrupt Dorothee, avoid Tito, and burn the Crone after the actors die."),
        },
        ["Nightbane"] = {
            Mechanic("During air phases, one player controls skeleton positioning while the raid stacks loosely for healing and AoE."),
            Mechanic("Remove Distracting Ash, avoid Charred Earth, and let the tank rebuild threat after every landing."),
        },
        ["The Curator"] = {
            Mechanic("Ranged spread so Arcane Flare chains do not overlap and kill each Astral Flare before returning to Curator."),
            Mechanic("Save major damage cooldowns for Evocation; the designated Arcane-soak player maintains the highest valid health target."),
        },
        ["Terestian Illhoof"] = {
            Mechanic("Destroy Demonic Chains immediately; the sacrifice target cannot survive without focused healing and fast target swaps."),
            Mechanic("Keep Kil'rek controlled and use Seed of Corruption or equivalent AoE on imps without losing chain damage."),
        },
        ["Shade of Aran"] = {
            Mechanic("Do not interrupt weak filler spells; reserve interrupts for Frostbolt and Fireball to manage his mana timing."),
            Mechanic("For Flame Wreath, nobody moves; for Arcane Explosion, run to the walls after the mass slow."),
        },
        ["Netherspite"] = {
            Mechanic("Rotate assigned players through red, green, and blue beams before stacks become unsafe; never let a beam reach the boss."),
            Mechanic("During banish phase, clear the center and avoid Netherbreath while healers recover the raid for the next portal phase."),
        },
        ["Chess Event"] = {
            Mechanic("Move pieces out of Medivh's fire immediately and keep the King protected by pawns or durable pieces."),
            Mechanic("Use piece abilities on cooldown, rotate possession when needed, and focus damage on the opposing King."),
        },
        ["Prince Malchezaar"] = {
            Mechanic("Keep Prince against a wall with melee behind him; ranged use a position that leaves multiple escape routes from Infernals."),
            Mechanic("At one health after Enfeeble, avoid Shadow Nova completely; healers restore affected players only after it resolves."),
        },
    },
    encounters = {
        Encounter("Raid Overview", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Healing", A:Healers(2)),
            Group("Utility", {
                U("overview_dispel", "Dispel",
                    { "PRIEST", "PALADIN", "SHAMAN" }, nil, nil,
                    { "HEALER", "DAMAGER" }, true),
                U("overview_interrupt", "Interrupt",
                    { "ROGUE", "SHAMAN", "MAGE", "WARRIOR" }),
                U("overview_kiter", "Kiter",
                    { "HUNTER", "MAGE", "WARLOCK" }),
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan",
        }),
        Encounter("Attumen the Huntsman", {
            Group("Tanks", { "Attumen Tank", "Midnight Tank" }),
            Group("Healing", {
                R(A.HEALER.TANK,
                    { "PALADIN", "PRIEST", "DRUID" },
                    { "Holy", "Discipline", "Restoration" }),
                R(A.HEALER.RAID,
                    { "DRUID", "SHAMAN", "PRIEST" },
                    { "Restoration", "Holy", "Discipline" }),
            }),
            Group("Utility", {
                U("attumen_decurse", "Decurse Lead",
                    { "MAGE", "DRUID" }, nil, nil,
                    { "HEALER", "DAMAGER" }, true),
                U("attumen_disarm", "Disarm Lead",
                    { "WARRIOR", "ROGUE" }),
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__attumenthehuntsman",
            spellIcon = 29711,
            mechanics = {
                Mechanic("Tank Midnight away from the raid and pick up Attumen when he appears."),
                Mechanic("Remove Intangible Presence quickly; ranged stay spread for charges."),
                Mechanic("After they merge, face Attumen away and keep the raid out of his cleave."),
            },
        }),
        Encounter("Moroes", {
            Group("Tanks", { "Moroes Tank", A.TANK.OFF }),
            Group("Crowd Control", RepeatedUtility(
                "moroes_guest_cc", "Guest CC", 4,
                { "PRIEST", "MAGE", "HUNTER", "ROGUE", "PALADIN" })),
            Group("Utility", {
                U("moroes_garrote", "Garrote Cleanse",
                    { "PALADIN", "PRIEST" }, { "Holy", "Discipline" },
                    nil, { "HEALER", "DAMAGER" }, true),
                U("moroes_interrupt", "Interrupt",
                    { "ROGUE", "SHAMAN", "MAGE", "WARRIOR" }),
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__moroes",
            spellIcon = 29448,
            mechanics = {
                Mechanic("Crowd-control dangerous guests and establish a reliable kill order."),
                Mechanic("Two tanks stay highest on threat to control Gouge and Blind."),
                Mechanic("Remove Garrote where possible; otherwise finish before healing is overwhelmed."),
            },
        }),
        Encounter("Maiden of Virtue", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", { A.HEALER.TANK, A.HEALER.RAID }),
            Group("Utility", {
                U("maiden_dispel", "Dispel",
                    { "PRIEST", "PALADIN" },
                    { "Discipline", "Holy" }, nil,
                    { "HEALER", "DAMAGER" }, true),
                U("maiden_sacrifice", "Blessing of Sacrifice",
                    { "PALADIN" }, { "Holy", "Protection" }, nil,
                    { "HEALER", "TANK", "DAMAGER" }, true),
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__maidenofvirtue",
            spellIcon = 29522,
            mechanics = {
                Mechanic("Spread around the room and dispel Holy Fire immediately."),
                Mechanic("Melee minimize Holy Ground damage and healers prepare for Repentance."),
                Mechanic("A paladin can use Blessing of Sacrifice to break Repentance and recover the raid."),
            },
        }),
        Encounter("Opera Event", {
            Group("Tanks", { A.TANK.MAIN, A.TANK.OFF }),
            Group("Utility", {
                U("opera_interrupt_1", "Primary Interrupt",
                    { "ROGUE", "SHAMAN", "MAGE", "WARRIOR" }),
                U("opera_interrupt_2", "Backup Interrupt",
                    { "SHAMAN", "ROGUE", "MAGE", "WARRIOR" }),
                U("opera_fear_ward", "Fear Ward",
                    { "PRIEST" }, { "Discipline", "Holy" }, nil,
                    { "HEALER", "DAMAGER" }, true),
                U("opera_kiter", "Kiter",
                    { "HUNTER", "MAGE", "WARLOCK" }),
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__operaevent",
            spellIcon = 31013,
            encounterNames = {
                "Opera Hall",
                "Opera Event",
                "The Big Bad Wolf",
                "The Crone",
                "The Wizard of Oz",
                "Romulo and Julianne",
                "Julianne and Romulo",
                "Opera Hall: The Big Bad Wolf",
                "Opera Hall: The Wizard of Oz",
                "Opera Hall: Romulo and Julianne",
                "Theater Event",
                "Theatre Event",
            },
            mechanics = {
                Mechanic("Identify the active Opera encounter and confirm interrupts, fears, or kiting before pull."),
                Mechanic("Keep dangerous casts controlled and avoid overlapping ground effects."),
                Mechanic("Prioritize adds and encounter objects before returning damage to the boss."),
            },
        }),
        Encounter("Nightbane", {
            Group("Tanks", { A.TANK.MAIN, "Skeleton Tank" }),
            Group("Healing", { A.HEALER.TANK, A.HEALER.RAID }),
            Group("Utility", {
                U("nightbane_fear_ward", "Fear Ward",
                    { "PRIEST" }, { "Discipline", "Holy" }, nil,
                    { "HEALER", "DAMAGER" }, true),
                U("nightbane_aoe", "Skeleton AoE Lead",
                    { "MAGE", "WARLOCK", "PALADIN" },
                    { "Frost", "Fire", "Destruction", "Protection" }),
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__nightbane",
            spellIcon = 36922,
            mechanics = {
                Mechanic("Ground phase: face Nightbane away, avoid Charred Earth, and handle Fear."),
                Mechanic("Air phase: group carefully, kill skeletons quickly, and control healing threat."),
                Mechanic("Return to ground positions before each landing and watch the tail and cleave."),
            },
        }),
        Encounter("The Curator", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", { A.HEALER.TANK, A.HEALER.RAID }),
            Group("Utility", {
                U("curator_flare", "Astral Flare Kill Lead",
                    { "HUNTER", "MAGE", "WARLOCK" }),
                U("curator_burn", "Evocation Burn Cooldowns",
                    { "WARLOCK", "MAGE", "HUNTER", "ROGUE" },
                    { "Destruction", "Arcane", "Fire", "Marksmanship" }),
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__thecurator",
            spellIcon = 30254,
            mechanics = {
                Mechanic("Kill Astral Flares immediately while maintaining steady damage on Curator."),
                Mechanic("Use mana efficiently until Evocation, then commit cooldowns and burst damage."),
                Mechanic("Keep ranged spacing so flare damage does not pressure multiple players."),
            },
        }),
        Encounter("Terestian Illhoof", {
            Group("Tanks", { "Illhoof Tank", "Imp Tank" }),
            Group("Utility", {
                U("illhoof_chains", "Demon Chains Lead",
                    { "MAGE", "HUNTER", "WARLOCK" }),
                U("illhoof_aoe", "AoE Lead",
                    { "WARLOCK", "MAGE", "PALADIN" },
                    { "Destruction", "Fire", "Frost", "Protection" }),
                U("illhoof_interrupt", "Primary Interrupt",
                    { "ROGUE", "SHAMAN", "MAGE", "WARRIOR" }),
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__terestianillhoof",
            spellIcon = 30065,
            mechanics = {
                Mechanic("Keep Illhoof and Kil'rek controlled; cleave imps without losing boss pressure."),
                Mechanic("Destroy Demon Chains immediately when a player is sacrificed."),
                Mechanic("Interrupt Shadow Bolt Volley and use AoE only when threat is stable."),
            },
        }),
        Encounter("Shade of Aran", {
            Group("Interrupt Rotation", RepeatedUtility(
                "aran_interrupt", "Interrupt", 3,
                { "ROGUE", "SHAMAN", "MAGE", "WARRIOR" })),
            Group("Utility", RepeatedUtility(
                "aran_elemental_cc", "Elemental CC", 4,
                { "WARLOCK", "HUNTER", "PRIEST", "MAGE" })),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__shadeofaran",
            spellIcon = 29946,
            mechanics = {
                Mechanic("Interrupt Frostbolt and Fireball, but let Arcane Missiles channel."),
                Mechanic("Do not move during Flame Wreath; run to the walls for Arcane Explosion."),
                Mechanic("Control water elementals and conserve tools for the final high-damage stretch."),
            },
        }),
        Encounter("Netherspite", {
            Group("Red Beam", {
                A:Tank("netherspite_red_1", "Red Beam 1"),
                A:Tank("netherspite_red_2", "Red Beam 2"),
            }),
            Group("Green Beam", {
                A:Healer(A.Target.RAID, 1, "Green Beam"),
                A:Healer(A.Target.RAID, 2, "Green Beam"),
            }),
            Group("Blue Beam", {
                U("netherspite_blue", "Blue Beam",
                    { "WARLOCK", "MAGE", "PRIEST" },
                    { "Shadow", "Destruction", "Arcane" }, 1),
                U("netherspite_blue", "Blue Beam",
                    { "WARLOCK", "MAGE", "PRIEST" },
                    { "Shadow", "Destruction", "Arcane" }, 2),
            }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__netherspite",
            spellIcon = 38523,
            mechanics = {
                Mechanic("Assign rotations for the red, green, and blue beams before the pull."),
                Mechanic("Take beams before they reach Netherspite and rotate before stacks become dangerous."),
                Mechanic("During banish, avoid Netherbreath and reset for the next portal phase."),
            },
        }),
        Encounter("Chess Event", {
            Group("Pieces", { "King", "Queen", "Bishop 1", "Bishop 2", "Rook 1", "Rook 2" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan__chessevent",
            spellIcon = 37471,
            mechanics = {
                Mechanic("Take key pieces quickly and move the king out of fire."),
                Mechanic("Use piece abilities on cooldown and keep healers positioned behind the front line."),
                Mechanic("Focus the enemy king while protecting your own."),
            },
        }),
        Encounter("Prince Malchezaar", {
            Group("Tanks", { A.TANK.MAIN }),
            Group("Healing", { A.HEALER.TANK, A.HEALER.RAID }),
            Group("Utility", { "Enfeeble Caller" }),
        }, nil, nil, {
            icon = "Interface\\AddOns\\LunaRaids\\Assets\\Bosses\\karazhan",
            spellIcon = 30852,
            mechanics = {
                Mechanic("Tank Prince against a safe wall and keep ranged spread for Shadow Nova."),
                Mechanic("Players hit by Enfeeble move out before Shadow Nova, then return after it lands."),
                Mechanic("React early to infernals and save defensive cooldowns for the final phase."),
            },
        }),
    },
})
