# LunaRaids

LunaRaids is a raid-planning and raid-leadership addon for World of Warcraft
Classic. It combines encounter assignments, raid groups, readiness checks,
gear inspection, personal assignment reminders, officer synchronization, and
raid cooldown tracking in one interface.

It supports raids from Vanilla through Mists of Pandaria, including the
post-nerf Vanilla and Burning Crusade encounter versions used on Anniversary
realms.

LunaRaids is developed by **Wuild** with help from the guild **Voracious** on
Thunderstrike.

- GitHub: <https://github.com/Wuild/LunaRaids>
- Patreon: <https://patreon.com/wuild>


[![Support on Patreon](https://img.shields.io/badge/Support-Patreon-ff424d?logo=patreon&logoColor=white)](https://www.patreon.com/wuild)


![LunaRaids encounter assignments](https://github.com/Wuild/LunaRaids/raw/master/Media/assignments.png)

## What LunaRaids does

### Raid plans and boss assignments
LunaRaids contains templates for every supported raid from Vanilla through
Mists of Pandaria. Templates include boss-specific mechanics notes and
assignment slots for tank jobs, healing coverage, interrupts, dispels, soaks,
kiting, control, positioning, and other encounter-critical responsibilities.
Vanilla and Burning Crusade encounters also include dedicated encounter
artwork and default target markers.

A raid plan can contain:

- Tanks and their encounter targets
- Healers assigned to tanks, special targets, or the raid
- Interrupts, dispels, crowd control, clickers, soakers, and other utilities
- Boss and add raid markers
- Different assignments for every boss
- Per-boss assignment-count overrides
- Per-boss custom assignment categories
- Planned players who have not joined the group yet

Players can be dragged from the roster onto an assignment. A player can also
be selected and then placed by clicking an empty slot. Clicking an empty slot
without selecting a player asks LunaRaids to suggest a suitable character
using role, class, specialization, and available gear information.

`Auto Assign` fills the current encounter with suitable available players.
Assignments made on the Raid-Wide Plan are inherited by bosses that do not
already have an explicit assignment.

### Raid Groups

The Raid Groups page displays the live Blizzard raid groups. Only the raid
leader can drag players between groups or swap two players through LunaRaids.
These changes are applied to the real raid, not only to the LunaRaids display.

Right-click a player for group administration actions such as:

- Change their displayed role
- Promote or demote an assistant
- Transfer raid leadership
- Set the master looter where supported
- Remove a player from the raid
- Remove a planned player

Only authorized players can edit live raid groups.

![Raid group editor](https://github.com/Wuild/LunaRaids/raw/master/Media/groups.png)

### Raid Status and ready checks

The Raid Status page and LunaRaids ready-check window provide a compact view
of:

- Ready, waiting, not ready, and offline states
- Food, flasks, elixirs, raid buffs, and other tracked effects
- Weapon enhancements such as oils, stones, poisons, and imbues
- Durability percentages through the bundled LibDurability integration

Detected effects use their actual spell icons and tooltips. Players without
LunaRaids can still be inspected where the WoW client permits it, while addon
users can report their own data directly.

The standalone results window can remain open for a configurable duration.
Right-clicking it keeps it open, and it will not fade while the mouse is over
it. It can also be disabled in settings.

![Ready-check results](https://github.com/Wuild/LunaRaids/raw/master/Media/ready.png)

![Raid status, buffs, and consumables](https://github.com/Wuild/LunaRaids/raw/master/Media/status.png)

### Gear Inspect

Gear Inspect shows the raid's known GearScore, item level, and equipped-item
quality. LunaRaids prefers data reported by another LunaRaids user and uses
throttled inspection as a fallback.

TacoTip and TipTac data are used when available, but neither addon is
required.

![Raid gear inspection](https://github.com/Wuild/LunaRaids/raw/master/Media/gear.png)

### Personal assignments

Players running LunaRaids can receive a movable **Your Assignments** panel for
the raid leader's current boss. It shows only that boss's duties, including:

- The assigned role
- Target name
- Target raid marker
- Target role or class when known

Friendly targets can be clicked or used by mouseover macros. Enemy targets
use secure targeting where the game permits it. WoW combat restrictions still
apply to secure target changes.

The panel automatically hides after leaving or disbanding the group and can
be disabled in settings.

### Raid cooldown tracker

The cooldown HUD tracks important raid abilities such as Bloodlust/Heroism,
Mana Tide Totem, Innervate, Rebirth, defensive cooldowns, threat tools, and
other configured spells.

Features include:

- Ability Rows, Category Columns, and Vertical Player List layouts
- Configurable abilities, colors, order, scale, opacity, and visibility
- Class-colored cooldown progress
- Ready, remaining-time, and offline states
- Offline players remain visible but are excluded from ready/total counts
- Cooldown state synchronization between addon users
- Combat-log and local cooldown detection as fallbacks
- Click a player entry to whisper a request containing a clickable spell link
- Shift-left-drag the HUD to move it

The HUD position and active cooldown timers persist through `/reload`.

### Quick raid tools

The separate Raid Tools toolbar provides fast access to common leadership
actions:

- Open LunaRaids
- Ready check
- Role check
- Pull timer
- Break timer
- Previous and next current boss

The default break is five minutes. Right-click the Break button to choose
another duration. Pull and break timers use DBM when it is installed and use
the available Blizzard or chat fallback otherwise.

The toolbar can show icons only, hide during combat, or be limited to groups.
When group-only visibility is selected, it is shown only to the party leader,
raid leader, or raid assistants. Choosing Always removes those group and
permission visibility restrictions.

## Supported raids

### Mists of Pandaria

- Mogu'shan Vaults
- Heart of Fear
- Terrace of Endless Spring
- Throne of Thunder
- Siege of Orgrimmar

### Cataclysm

- Blackwing Descent
- The Bastion of Twilight
- Throne of the Four Winds
- Baradin Hold
- Firelands
- Dragon Soul

### Wrath of the Lich King

- Naxxramas
- The Obsidian Sanctum
- The Eye of Eternity
- Vault of Archavon
- Ulduar
- Trial of the Crusader
- Onyxia's Lair
- Icecrown Citadel
- The Ruby Sanctum

### The Burning Crusade

- Karazhan
- Gruul's Lair
- Magtheridon's Lair
- Serpentshrine Cavern
- Tempest Keep
- Battle for Mount Hyjal
- Black Temple
- Zul'Aman
- Sunwell Plateau

### Vanilla

- Molten Core
- Onyxia's Lair
- Blackwing Lair
- Zul'Gurub
- Ruins of Ahn'Qiraj
- Temple of Ahn'Qiraj
- Naxxramas

## Installation

1. Copy the addon folder into the appropriate WoW installation:

   `World of Warcraft\_anniversary_\Interface\AddOns\LunaRaids`

2. Confirm that the TOC is directly inside that folder:

   `Interface\AddOns\LunaRaids\LunaRaids.toc`

3. Restart World of Warcraft after installing a new addon.
4. Enable LunaRaids from the AddOns button on the character-selection screen.

An extra nested directory is the most common reason an addon does not appear.
For example, this will not work:

`Interface\AddOns\LunaRaids\LunaRaids\LunaRaids.toc`

LunaBags and MRT are not required. LunaRaids bundles the Ace3, LibDataBroker,
LibDBIcon, and other libraries it uses.

Flavor-specific TOCs are included for supported Classic clients.

## Opening LunaRaids

Use any of these commands:

```text
/lr
/lunaraid
/lunaraids
```

The LibDBIcon minimap button also opens the addon:

- Left-click: open or close LunaRaids
- Right-click: open LunaRaids settings
- Drag: reposition the minimap button

Use `/lr minimap` to hide or restore the minimap launcher.

The main window closes with Escape. Its position and size are saved. The
bottom-right resize handle resizes the window.

## Recommended raid-leader workflow

### 1. Create or load a raid

Open **Raid Assignments**, press **New Raid**, choose an expansion, and then
choose a raid.

![Expansion and raid selection](https://github.com/Wuild/LunaRaids/raw/master/Media/expac.png)

The first boss becomes the current boss for a newly created raid. Once the
raid is active, changing to a different raid requires creating or loading
another plan.

While in a raid group, only the actual raid leader can create or load the
active raid. Assistants receive the leader's plan as a read-only view. Outside
a live raid, plans can be prepared in advance.

If another plan is open, LunaRaids asks whether it should be saved before
starting a new one. Opening an existing saved raid updates that save instead
of asking for another name.

### 2. Build the roster

The live roster is read from the current party or raid automatically. It does
not require a manual refresh.

Use the `+` button in the Raid Roster header to add a planned player. Planned
players can be assigned before raid night. When the matching player joins,
the live roster entry replaces the placeholder and name-based assignments
remain intact.

Right-click a planned player to delete it.

### 3. Set raid-wide assignments

Use the **Raid-Wide Plan** (the first encounter-toolbar entry) to establish
normal tanks, healers, recurring utility assignments, and standard trash
markings. Player assignments carry into bosses that have not been assigned
separately. Its marker page covers kill order, crowd control, off-tanking,
interrupts, dispels, and do-not-attack targets.

For player-owned trash control, add a raid-wide custom category whose name
contains the marker and action, such as **Moon Polymorph**, **Star Polymorph**,
or **Square Trap**, then assign the responsible player. Marker names render as
raid icons and are included when announcing or whispering the Raid-Wide Plan.
**X** can be used as an alias for **Cross**.

Announce always uses the page currently being viewed. On the Raid-Wide Plan it
posts both the configured trash-mark legend and any player-owned raid-wide
duties; it no longer switches silently to the current boss.

### 4. Configure each boss

Choose a boss from the encounter toolbar at the top of Raid Assignments.

Each boss has three views:

- **Markers** — assign skull, cross, square, and other markers to bosses/adds
- **Assignments** — place players into encounter-specific duties
- **Mechanics** — read the quick encounter guide

Use the setup cog to change assignment counts or add and remove custom
categories. On a boss these settings affect only that encounter; on the
Raid-Wide Plan they define recurring duties for the whole raid.
Boss configurations can be reset to their built-in defaults or saved as
multiple named presets.

### 5. Set the current boss

Editing a boss does not automatically make it the raid's current boss. Use
**Set Current Boss**, or the previous/next controls on Raid Tools, when the
raid moves to another encounter.

The current boss controls what raiders see in their personal assignment
panels. Previous/next follows the current-boss index and does not overwrite
the boss an officer happens to be editing.

### 6. Communicate the plan

Use:

- **Announce** to post short assignments in Raid Warning
- **Whisper** to send each assigned player only their relevant duties

Messages include the `[LunaRaids]` prefix. Raid markers use WoW marker tokens
such as `{skull}` and render as icons in chat. Messages are split and paced to
avoid chat throttling.

Announcements intentionally omit unnecessary encounter-name repetition and
use concise formats such as:

```text
[LunaRaids] Healing: Player -> Main Tank
```

## Permissions and synchronization

LunaRaids uses private addon communication. It does not require a server or
external account.

### Raid leader

The actual raid leader can:

- Create, load, save, and close the active raid
- Edit assignments and markers
- Change the current boss
- Edit live raid groups
- Configure raid administration

### Raid assistants

Assistants can:

- Receive the active plan when joining or being promoted
- View raid-wide and boss assignments, markers, groups, and the current boss

Assistants cannot create, replace, or edit the active raid plan. Plan changes
received from assistant clients are ignored; only the raid leader is accepted
as synchronization authority.

### Normal raid members

Normal members have a read-only view. They cannot drag players, change
assignments, or make unsynchronized local edits.

### Synchronized data

Compatible addon users exchange:

- Active raid and current boss
- Boss assignments and healing targets
- Markers and boss-specific configuration
- Planned and simulated rosters
- Raid-group planning data
- Role, class, race, specialization, gear, and durability information
- Personal assignment updates
- Cooldown states

Plan changes are sent as compact enum/value data rather than verbose text
where possible. Joining or newly promoted officers request the current state
automatically. `/lr sync` manually requests a fresh plan.

Incompatible older protocol versions are ignored. LunaRaids shows a
once-per-session update notice instead of repeatedly whispering users.

## Raid administration settings

The Settings page is part of the main LunaRaids navigation.

Raid administration options include:

- Auto-invite from configurable whisper keywords
- Auto-promote named players already in the group
- Auto-promote multiple selected guild ranks
- Saved loot method and minimum loot quality
- Multiple preferred master-looter names, tried in order

Player-name fields accept names separated by common delimiters. Shift-clicking
a player link in the Blizzard UI inserts that player's name into supported
fields.

LunaRaids checks group changes when applying promotion and master-looter
rules. It does not repeatedly attempt to promote players who are not in the
group. A manually selected master looter is not overridden unnecessarily.

Loot rules are applied only while in a raid and are rechecked periodically
while out of combat.

The settings footer can reset addon settings and all saved window positions.
Saved raids and assignments are not deleted by this reset.

## Saving, closing, and deleting plans

**Save Raid** stores the full prepared raid:

- Planned roster
- Every boss plan
- Markers
- Boss-specific slot counts
- Named boss presets

Saved raids can be loaded from the New Raid flow and deleted from the saved
plan list. Once a saved raid is loaded, assignment, marker, roster,
composition, current-boss, and configuration edits are saved silently as they
are made.

Boss and raid-wide configuration is also retained as the default for that raid.
Starting a fresh plan for the same raid restores custom categories, assignment
counts, and boss presets without restoring the previous player assignments.

Closing/completing a raid clears the active session without deleting its
saved copy. Synchronization closing a raid does not close the recipient's
entire LunaRaids window; other pages remain open.

## Slash commands

| Command | Action |
| --- | --- |
| `/lr` | Open or close LunaRaids |
| `/lr settings` | Open settings |
| `/lr config` | Open settings |
| `/lr sync` | Request the current raid plan |
| `/lr reset` | Clear the current encounter plan |
| `/lr minimap` | Hide or restore the minimap button |
| `/lr cooldowns` | Toggle the cooldown HUD |
| `/lr cds` | Toggle the cooldown HUD |
| `/lr sim 10` | Simulate a 10-player raid |
| `/lr sim 25` | Simulate a 25-player raid |
| `/lr sim 40` | Simulate a 40-player raid |
| `/lr sim clear` | Clear simulation |
