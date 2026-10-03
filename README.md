# Forever Macros 0.4.1

**Beta release.** Maintained by Eclat Health Solutions, QA Division.

Download the installable ZIP from [GitHub Releases](https://github.com/hccbuddy-svg/forever-macros/releases). The source-code download contains development files and is not the addon installation package.

Open `/fm` to browse macros, assign a teammate, or save equipment presets. The addon supports WoW: Forever 1.60.x. This update targets the installed client 1.60.1.70205, interface 16001.

The library has 363 templates across all nine Classic classes: 120 automatic starter and attack templates and 243 optional choices. Hunter has 91 class templates plus shared utility. Only your current class and learned abilities qualify. Character macro slots limit how many you can install. The rest stay in the searchable library.

The test suite uses mocked WoW APIs in Lua 5.1. See VALIDATION.md for the current result. Version 0.4.1 still needs an in-game check of training, combat transitions, and artwork rendering. Earlier user testing does not verify this release.

## October client update

Version 0.4.1 adds **ShiftingPower**, an optional Druid button that uses the learned Shifting Power talent only while already in Cat Form. **SpearStrike** installs for Warriors who learn Spearing Strike and have Battle Stance. Its cast and attack commands require that stance, with no two-handed weapon restriction.

Hunters and Warlocks can choose **PetAggressive** in the Pet library. It changes the active pet to Aggressive when pressed, which can make it attack nearby enemies. It is never installed automatically. Existing pet-control buttons retain their behavior.

These additions follow the [October development notes](https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-october-1/2360696/4). Spell buttons still require learned abilities and available macro slots. The two new spell names use English spellbook matching until their localized IDs are verified. `/fm status` now includes the full client build and interface number.

## Quick start

1. Exit WoW completely and reopen it after installation. Open `/fm` and confirm **v0.4.1** in the lower right.
2. Search by spell or purpose in the box above the list. Select a macro, review its preview, and click **Install / update selected**. Choosing an unlearned ability with default targeting saves it for installation after you learn it.
3. Open `/macro` and drag that macro onto your action bar once.
4. For a friendly action, click a teammate in the addon window. Later assignments edit that same macro.
5. Open **Equipment** to capture your equipped weapons or choose items from your bags. No item names need typing.

A `+` marks a managed macro, `~` marks a saved learning request, and `*` marks an unavailable ability. The detail panel explains edited or missing macros. The Attacks filter finds damage buttons, and PvP includes relevant starters. See CATALOG.md for every template and its exact default text.

## Learning skills and updating macros

Learning a skill, receiving updated spell text, logging in, or changing the active pet triggers a check. Core melee and Hunter shot templates now install automatically when learned, with attacks taking priority over general utility. Still-owned macros are refreshed in place when their generated text changes. These checks wait until combat ends.

Spell names are rankless, so a higher learned rank normally needs no text change. A macro can look unchanged and already use your new rank. Changes to a spell's name or the template itself are separate cases that may rewrite the owned macro. Personal edits, renames, and deletions are preserved. `/fm update` remains available for a manual check.

Some new Forever abilities have no verified stable spell ID in this release. They are matched to exact learned names on English clients. Those specific additions stay unavailable on other locales. See RESEARCH.md for this limit and the sources reviewed.

If a skill still has no macro, run `/fm status` and `/fm list`. Check that updates are enabled, the spell is learned, the template is eligible, and a character macro slot is free. Two slots are reserved by default. The window shows used and total slots; a chat warning reports learned starters blocked by space. The addon never deletes a macro to make room. You can lower the reserve with `/fm reserve 0` or free a character slot yourself in `/macro`.

An optional macro selected before learning its ability stays saved across reloads and retries when space becomes available. **Cancel queued change** cancels that saved request. Teammate changes queued during combat remain session-only requests.

## Illustrated class backgrounds in 0.3.3

The painting sits behind light header and footer panels. Version 0.4.0 makes it more visible behind the content and retries a failed texture load. The class icon remains as a fallback. If the artwork is missing, restart WoW and check that the Art folder contains all nine TGA files. They are included in this ZIP.

The window now has nine illustrated class backgrounds beneath light reading panels and gold trim. Hunters get a wolf and bow in a mountain forest. Shamans get elemental totems and lightning. Each other class has its own scene, from a druid woodland to a warlock's ruined sanctuary. Your class sets the painting, emblem, and selected-button colors automatically.

The header shows your character name and class beside an Alliance or Horde badge. The faction badge sits over the class painting, so the same class artwork works for either faction. No setup is needed.

All nine Classic classes are covered. The addon uses the player's reported faction, so party members and targets do not change your theme. If faction information is unavailable, the header says Azeroth. Text stays dark on light panels, including the macro preview.

The nine paintings are bundled in the addon's Art folder. Class icons and faction badges still use WoW's artwork. Faction badges use the atlas names in the [matching client character-creation source](https://github.com/Gethe/wow-ui-source/blob/c6e89983189e4f626f549204a23c2d2bea93080a/Interface/AddOns/Blizzard_CharacterCreate/Camelot/Blizzard_CharacterCreate_Templates.lua). If an atlas is unavailable, the class icon uses its classic texture fallback and the faction remains visible as text. The window scales down to fit smaller screens.

## Attack-start corrections in 0.3.1

Shaman Earth Shock and Frost Shock now start melee swings on the normal enemy-target path. Their focus and mouseover paths cast without adding a swing command. Flame Shock and Stormstrike are new optional current-target damage buttons. Move your pointer off hostile units or unit frames when testing the normal target path.

The class audit also adds core warrior, rogue, feral druid, paladin, and hunter attacks. Melee buttons use guarded attack start. Hunter ranged buttons use Auto Shot. Heals, buffs, escapes, and caster utility do not gain a generic melee command. Breakable crowd-control buttons stop player attacks. See ATTACK-AUDIT.md for the class decisions, sources, and exact tests.

Use **Update installed macros** or `/fm update` after this upgrade. This edits eligible addon-owned macros in place and keeps your manual edits. New optional buttons still require selection. Feral attacks resolve the character's current form slots and maintain those slots outside combat when the form layout changes.

## Teammates and targeting

Select a friendly action, such as a heal, cleanse, blessing, or AllyAssist. Then choose a mode and click a party or raid member:

| Mode | Result |
| --- | --- |
| Pin this person | Uses that character's full name. It keeps that name if someone else joins their old slot. |
| Follow party / raid slot | Uses the selected unit slot. Its occupant can change without rewriting the macro. |
| Use default targeting | Restores the template's mouseover, target, self, or focus behavior. |

The game may sort party frames differently from unit-slot order. The addon shows both the person's name and their actual slot. Default action buttons can show a small teammate label; other bar addons may only show the ordinary macro name. Keybind reminders currently inspect default bars.

A click during combat queues the request. The existing target remains active until combat ends. The latest request for that macro wins. The window shows active and pending assignments separately. You can cancel the pending change. Reloading clears pending requests.

Before applying a queued change, the addon checks the current roster and macro again. A departed pinned player or empty slot cancels the request. An occupied slot can follow its replacement. Assignment changes preserve the macro name and icon, which keeps the same action-bar reference.

Friendly default templates generally use Alt for self, then friendly mouseover, friendly target, and self as a fallback. Hostile templates generally use Shift-focus, then hostile mouseover, then target. Assigned friendly actions address only the selected person or slot. They do not fall back to a different teammate if that person is absent or dead.

## Weapons, trinkets, and equipment

Choose **Weapons A**, **Weapons B**, **Trinkets A**, or **Trinkets B**. Use **Capture equipped items**, or click a slot and choose an item from the inventory list. Then click **Save preset macro**. Each preset has a stable macro, so saving a different selection updates the same button.

Weapon presets support main hand, off hand, and ranged equipment. Choosing a two-handed main weapon clears the preset's off-hand selection. A blank slot means leave that slot unchanged; it does not unequip an item. The game checks whether your class can equip the selected combination. Identical copies with the same item ID are not distinguished by enchantment.

Trinket controls have two different uses:

- **Trinkets A/B** equip saved trinkets. Their macros stop in combat.
- **FM TrinketTop** and **FM TrinketBottom** activate the item currently equipped in that slot. They need no item name and keep working after you change trinkets. Passive trinkets have no activation to use.

If the client exposes native equipment sets, the window lists them. Click one to create or update **FM GearSet**. That macro also stops in combat. A client without native equipment sets still has the weapon and trinket presets. The addon does not create a full armor-set manager.

Equipment selection reads equipped items and normal bags. Bank contents are not listed. Item names may show a loading label until the client returns their data. Macros use item IDs. Capture and selection are available outside combat; saving an already selected preset can be queued during combat.

## Cleanses, control, and pet actions

The class library includes mouseover cleanses and dispels, interrupts, crowd control, defensive abilities, and available forms or stances. Racial abilities are offered only when learned. A cleanse removes only effects that the actual spell permits. A stun is not automatically removable by every cleanse or trinket.

The addon does not scan debuffs to choose a target or highlight which player needs a cleanse in this release. Use a friendly mouseover or assign the teammate yourself. Spells still obey range, line of sight, forms, stances, resources, reagents, and cooldowns.

Hunters retain PetAttack, PetFollow, MarkPet, AutoShot, MendPet, RevivePet, CallPet, Concuss, Raptor, Feign, and HuntSeq. New choices include Scatter, traps, Wing Clip, Viper Sting, and Deterrence. PetFollow leaves the pet passive. Feign and Scatter also recall the pet in passive mode.

Warlock pet spells require the appropriate ability in the active pet's spellbook. Existing pet macros stay installed when that pet is dismissed; they are usable only when the required pet ability is available again.

## Boss reminders

Reminders are optional and off by default. Open **Boss reminders** to test the display. A test shows **TEST REMINDER**, the selected macro name, an icon, and its default-bar keybind when available. It plays a warning sound if the client exposes that sound.

The DBM adapter listens for readable timer start, stop, update, pause, and resume notifications. After observing a timer, select it and an installed macro. Set the lead time from zero to ten seconds, link the timer, then enable reminders. A live reminder occurs that many seconds before the reported timer endpoint. It does not check whether the spell or trinket is ready.

Check what the endpoint means before relying on it. A cooldown timer may estimate the next cast start; a cast timer may indicate cast completion. Encounter changes can shift either. Stopped timers, encounter end, world changes, and player death cancel pending reminders. Restricted or malformed timer data is skipped. An edited or missing managed macro suppresses its live reminder.

The inspected installation has DBM Core and Midnight content packs. It has no Forever dungeon pack. The reviewed DBM Forever dungeon source contains placeholder boss modules. Core encounter signals may still be available, but no advance warning has been confirmed in a live fight. This release ships no preconfigured boss-to-defensive rules and does not promise warnings for any particular boss or random crushing hit.

The macro library and equipment controls work without DBM. Reminders do not cast spells, equip items, or activate macros.

## Preservation and recovery

The addon creates character macros only. It never deletes macros or changes bindings. Existing name and body collisions in either macro tab prevent new creation.

Automatic updates and UI selections can edit an addon-owned macro only when its current text matches the last confirmed text written by the addon. Manual edits, renames, deletions, and duplicate names block replacement. The first changed body is kept in a per-character edit backup. The original starter snapshot is also retained.

Two character slots remain free by default. Use `/fm reserve NUMBER` to change that reserve. An uncertain creation or edit pauses further writes. Check `/macro` before using `/fm retry`.

To recreate a deleted library macro, use `/fm restore TEMPLATE_ID`, then select it again. Starter templates are checked automatically. For a deleted equipment macro, use `/fm restore weapons_a`, `weapons_b`, `trinkets_a`, `trinkets_b`, or `equipment_set`, then save or select the preset again. Restore does not take over an existing edited macro. Remove or rename that conflicting macro yourself only if you want a separate replacement.

Settings are per character. Pinned teammate names, preset item IDs, and reminder rules are saved locally in the addon's SavedVariables. The addon sends none of them to a server. Persistence across reload and logout still needs a live check.

## Hunter sequence

FM HuntSeq retains the early questing sequence from version 0.2.0. It requires Auto Shot, Serpent Sting, and Arcane Shot. Select a living enemy, use MarkPet separately if wanted, then stand at ranged distance and press HuntSeq repeatedly.

Each successful press advances Serpent Sting followed by three Arcane Shots. The sequence waits on cooldown, range, or mana. Auto Shot and pet attacks can continue. It resets for a different target, after combat, or with one Alt-modified press. It does not check Sting duration, pick another enemy, or heal your pet. This is a fixed starter pattern, with no optimal damage claim. The [GSE author's castsequence explanation](https://github.com/TimothyLuke/GSE-Advanced-Macro-Compiler/wiki/Understanding--castsequence) describes the normal success-based sequence behavior.

## Commands

| Command | Result |
| --- | --- |
| `/fm` or `/forevermacros` | Open or close the window |
| `/fm update` | Refresh existing addon-owned library macros while preserving your edits |
| `/fm status` | Show loaded version, full client build, interface number, enabled state, macro-slot usage, and reserve |
| `/fm list` | List class template IDs and starter installation status |
| `/fm show TEMPLATE_ID` | Show the default template and learned-spell requirements |
| `/fm off` | Pause additions and managed updates |
| `/fm on` | Enable additions and check starters |
| `/fm install` | Check eligible starters now |
| `/fm skip TEMPLATE_ID` | Skip automatic installation and updates for that template |
| `/fm restore TEMPLATE_ID` | Clear the template's ownership/removal record without overwriting a macro |
| `/fm reserve NUMBER` | Keep that many character macro slots free |
| `/fm retry` | Clear a write fault after reviewing your macros |

Bindings using Alt or Shift can intercept a macro modifier. The game still requires your normal keypress or click for each action. The addon does not place buttons on bars or assign keys.

## Installation and rollback

For a first install, exit WoW, extract the ForeverMacros folder into your Forever client's `_classic_beta_/Interface/AddOns` folder, then enable the addon. Avoid an extra nested ForeverMacros folder.

Before replacing an installed copy, keep a backup. An already loaded copy uses the update after an out-of-combat `/reload`; if new files do not load, exit and restart the client. Installation copies addon files only. It does not edit character settings or macros on disk.

To roll back, exit WoW and restore your saved copy of the earlier addon folder. Macros already created or changed remain ordinary character macros; rolling back addon files does not roll back their text. Back up game settings before your first live trial if you want a separate settings recovery point.

## Development and evidence

Run from the project folder:

```powershell
uv run --no-project --with lupa==2.6 python tests/run_tests.py
uv run --no-project --with lupa==2.6 python tools/package.py
```

The tests exercise ownership, class filtering, combat queues, item selection, UI callbacks, and timer cancellation. They do not execute WoW macro commands or render the real game window. VALIDATION.md records the checks and remaining live tests.

API inspection for this update used the [UI source matching build 1.60.1.70205](https://github.com/Gethe/wow-ui-source/tree/e3ecc27b64d30fdc735a3f6579b866858f9f9df1). RESEARCH.md records the October compatibility check and the earlier library research. Timer support is unchanged from the earlier release and has not been verified in a live encounter.

See [SECURITY.md](SECURITY.md) before contributing. Source and accompanying documentation are provided under the [MIT license](LICENSE). World of Warcraft names and game assets referenced through the client belong to their respective owners.
