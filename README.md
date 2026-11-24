# Forever Macros 0.11.0

**Beta release.** Maintained by Daniel Plasencia.

Published versions are available from [GitHub Releases](https://github.com/hccbuddy-svg/forever-macros/releases). A local development ZIP can be newer than the published version. Install the versioned ForeverMacros ZIP, not GitHub's source-code download.

Open `/fm` to browse macros, assign a teammate, or save equipment presets. The addon supports WoW: Forever 1.60.x. This update targets the launch client 1.60.1.70755, interface 16001.

The library has 391 templates across all nine Classic classes: 152 automatic starter and attack templates and 239 optional choices. Hunter has 94 class templates plus shared utility. Only your current class and learned abilities qualify. Character macro slots limit how many you can install. The rest stay in the searchable library.

The test suite uses mocked WoW APIs in Lua 5.1. See VALIDATION.md for the current result. Version 0.10.0 adds compact leveling controls for Shaman, Priest, Paladin and Hunter, with learned-only totem controls for Shaman. It retains the raised LG player and target frames and independent backpack header controls. Update the files, then use `/reload` outside combat.

## Launch update in 0.11.0

Checked against the launch client 1.60.1.70755. No game API that Forever Macros calls changed since build 70338.

- The talent coach uses the November 3 Talents Forever snapshot and ZBuilds of November 4: the rebuilt Paladin trees, the Druid and Mage hotfix changes, and 96 current leveling plans for all 27 trees.
- Warlock: FM Agony casts Bane of Agony and FM Doom casts Bane of Doom, the Forever names for the old curses.
- Shaman: FM FireNova casts Fire Nova, now a spell rather than a totem. FM ElemMastery casts Lightning Mastery, Forever's name for Elemental Mastery.
- Paladin: FM Salvation, FM Light and FM Sanctuary are gone, because those blessings are no longer taught.

## Compact leveling controls in 0.10.0

**FM Easy** appears in your character macro list when you know a supported ability and have a free slot beyond the reserve. Open `/fm easy` to inspect it. Drag it onto your existing **1** slot, then press that key repeatedly while targeting a living enemy. It combines the following learned abilities. These are original, fixed convenience routines; they have not been measured against an optimal rotation.

| Class | What FM Easy does |
| --- | --- |
| Shaman | Refreshes Lightning Shield once per target, starts melee swings, then cycles Flame Shock, Stormstrike and Earth Shock as learned. Before those attacks are learned, falls back to Lightning Bolt. Shield and damage use separate sequences. |
| Priest | Attempts a self shield once per target. Cycles learned Penance or Mind Blast, Shadow Word: Pain and four Smites. With Mind Flay learned, uses Mind Blast, Pain and four Flays instead. Repeated presses leave an active channel alone. Holy damage requires caster form. |
| Paladin | Applies Seal of Righteousness once per target, starts melee, and attempts Judgement and Holy Strike on each press. Forever Judgement is off the global cooldown and leaves the seal active. The older FM AutoOpen also stops resealing after Judgement. |
| Hunter | Sends the pet and starts Auto Shot. Cycles Sting and three Arcane Shots. When Summon Hawk is learned, uses Sting, two Hawks and Arcane Shot. Auto Shot continues through shared shot cooldowns. Aimed Shot, aspects and pet recovery remain separate. |

Use **Shift+1** for **FM AutoPrep**. It applies your learned class preparation buffs, one per successful press, outside combat. It stops when finished and resets after ten seconds without pressing, so you can use the same key later. Shaman's Lightning Shield is also available here for manual refresh between pulls. The dedicated shield macro remains available for combat refresh.

For Shaman, put **FM Totems** on **Shift+2**. Open `/fm totems` to find it. Before Call of the Elements is learned, it drops Searing Totem and Strength of Earth Totem as available, one per press, then stops. Ten seconds without pressing resets it. Searing may attack nearby enemies; use this key when you intend to engage and stay nearby. Learning Call of the Elements updates the same macro to cast your saved native totem set. Configure that set in the game's totem bar first. FM does not choose or fill that bar. Place **FM Recall** on **Shift+3** after learning Totemic Recall. Recall always requires its own press.

This is a suggested placement on your existing bound slots. FM does not change bindings or action-slot contents. Keep healing, interrupts and emergency cooldowns on other number or Shift-number keys. Lightning Bolt remains useful for a deliberate ranged Shaman pull; the main shock routine requires shock range. Long weapon imbues remain separate from each pull.

Each press can perform one global-cooldown action plus compatible off-global actions. The routines cannot check missing buffs, choose a spell based on remaining mana, skip a cooling-down sequence step or play without your input. Lightning Shield refreshes on every new target as requested, even if still active. Priest shielding and repeated casting spend more mana than a wand-focused approach; switch to a separate wand key to conserve mana. Fixed cycles can refresh damage-over-time effects early. An unavailable shield does not hold up the separate damage sequence, although it can be attempted again until successful.

Target changes, combat ending or Alt reset FM Easy. Changing your seal manually requires a reset before it reapplies Righteousness. Repeated target switching can cause repeated shielding or resealing. New spell learning rebuilds unchanged owned macros outside combat; it does not require another install or rebinding. Personal edits, renamed or deleted macros and the slot reserve are preserved. If the list is full, free a character macro slot and run `/fm install`. No macro is deleted to make space.

The feature adds no frame update loop, cooldown polling or background casting. Its extra work runs when the learned spellbook is refreshed. FPS impact has not been measured in the game. See [the source review](RESEARCH.md) for the guide references and limitations.

Version **0.8.1** fixes the ElvUI party-frame startup error, `attempt to perform arithmetic on local 'y' (a nil value)`. The 0.8.0 profile generator used the obsolete `DOWN` direction. New profiles use `DOWN_RIGHT`; existing named FM LG profiles receive the same correction before ElvUI creates its group frames. Other settings and customized valid directions remain intact. The original field values are saved in the character's layout settings. After updating from 0.8.0, use `/reload` outside combat.

## Automatic sequences and training in 0.8.0

**FM AutoOpen** and **FM AutoPrep** appear in the character macro list as supported spells become learned and slots are available. Druid also gets **FM AutoCat**; **FM AutoBear** is optional because it uses area damage. Search `FM Auto` under the library's **Sequences** filter. Drag a macro onto an action bar once. Spellbook changes and level events refresh unchanged owned macros outside combat. Learning a skill triggers the update immediately; reaching an even level alone does not mean the skill was trained. Personal edits, deletions, renamed macros and the slot reserve remain protected.

These are short, fixed openers and preparation sequences. Each successful keypress casts one step. The sequence stops at `null` to avoid repeatedly refreshing damage-over-time spells. Alt resets it; openers also reset on target change or combat ending. Preparation also resets after ten seconds without pressing. Lack of mana, rage, range, a required form or an available cooldown can stall a step. They are class starters, not optimized rotations for every spec. Keep reactive heals, interrupts and finishers on their dedicated buttons. The existing Coach covers all 27 talent trees with static reference cards and talent plans.

Use `/fm training` or the **Training** tab. It hosts the original **What's Training? Forever 1.1.1** window, installed separately, and restores that window when the tab closes. Available spells, missing ranks and the next two levels come from that provider. Trainer costs and required levels can change during beta; treat unobserved values as estimates. The addon does not buy training. Pet training and demon grimoires are outside this view. Missing or mismatched provider versions produce a message instead of a blank list.

## LG ElvUI profiles in 0.9.0

The optional integration creates **28 original profiles**: three talent trees for each of the nine classes, plus Feral Tank. Profile names start with **FM LG v2**. The layout targets the observed 5120 x 2160 game display: 44-unit action buttons, 14-unit key labels, 16-unit chat, three main rows and a 12-slot utility block immediately beside each end. That is 60 visible action slots. The minimap sits 24 units from the top-right corner. The empty right chat backdrop is removed. Actual physical size depends on game scaling.

Version 0.9.1 places the player and target frames 380 UI units above the bottom edge, with their centers 230 units to either side of screen center. At the standard 290-unit frame width, that leaves a 170-unit gap. Both frames are 108 units higher than in 0.9.0. Each cast bar sits below its own frame at the same width, leaving space above for buffs and debuffs. Focus, pet and target-of-target frames have matching clearances; the raid grid sits farther left. All 28 profiles and newly created FM profiles use these positions. Existing profiles receive the update once per account, only where a position still matches the old FM default. Customized positions stay intact. Previous changed coordinates and cast-bar width are retained in ElvUI's global settings. Floating overhead nameplates are unchanged.

Hunter and Warlock retain pet controls. Warrior, Druid and Paladin have stance or form controls; Shaman totem controls sit above the central rows. Rogue and Druid receive taller class-resource bars. Healing profiles use larger party frames, mana text, healing predictions and buff indicators. Tank profiles emphasize threat. Raid frames use five players across, with up to eight rows. These are presentation choices built on ElvUI's existing class logic. They do not assign spells, replace action-slot contents or change keybindings.

When ElvUI loads before Forever Macros, the first setup selects a class leveling layout and sets UI scale to 0.60. The v2 upgrade creates separate profiles, preserves the old FM LG v1 profiles, and selects the corresponding v2 layout if an exact v1 layout is active. It preserves the chosen scale and unrelated profile fields. Subsequent logins leave v2 adjustments intact. A unique dominant talent tree selects the matching profile; ties retain the current choice. Selecting an unrelated profile stops automatic switching. Feral Tank is a manual choice because the tree alone cannot identify the role.

Click **Move windows** at the top of `/fm`, or use `/fm move`, to show ElvUI's native anchors. Drag bars, the minimap and unit frames, then click **Lock**. Backpack headers and BlizzMove-supported window titles remain movable outside this mode. The layout draws on [LuckyoneUI's role layouts](https://luckyone.dev/) and a review of [RedtuzkUI Classic](https://github.com/dBlocc/ElvUI_RedtuzkClassic). It is a custom adaptation, not an imported community profile or a measured best-performing design.

`/fm layout 1`, `2` or `3` selects your class's corresponding talent tree and stops automatic switching. `/fm layout bear` selects Feral Tank. `/fm layout auto` follows talents again. `/fm layout off` stops that behavior. `/fm layout previous` selects the saved v1 profile for the next reload. `/fm layout restore` selects the original pre-FM profile names and scale. Use `/ec` for ElvUI's profile and layout options.

The reviewed **ElvUI v15.26-810-g3f2bc8a development package** includes Forever interface 16001. Tukui's maintainer labels the Forever download **unsupported**. It is not the stable release. The initial private profile keeps Blizzard bags and buffs so the combined-backpack tools and native weapon-enchant display remain available. A future ElvUI update may need a fresh compatibility check. If ElvUI already initialized before setup, profiles are created and the initial configuration waits for a reload. New addon folders need a full game restart.

With separately installed **BlizzMove 3.8.4**, supported Blizzard windows drag from their headers. Right-click a supported header to lock its position, then right-click again to enable dragging. Shift/Ctrl/Alt right-click retain BlizzMove's own shortcuts. `/bm` opens its settings. Positions are saved between sessions. Game-protected windows cannot be moved during combat; not every third-party window is supported. Forever Macros owns bag movement, so BlizzMove's bag mover is disabled to prevent competing anchors.

## Backpack controls in 0.9.0

Open your backpack normally. **Sort** appears directly on its header, and the title can be dragged immediately. Neither action requires the FM window or a separate panel. These controls support Blizzard's individual equipped bags and combined backpack, including their ElvUI skin. Replacement bag interfaces remain outside this adapter.

Left-drag the combined backpack's title to move the entire window. Right-click the title to lock its position, then right-click again to allow dragging. The lock and position persist across reloads. The Sort button has its own space beside the title, clear of the drag area, bag icon and close button. `/fm bags` opens optional reset and direction controls. `/fm bags move` also enables dragging.

Separate bag windows use the same header controls. Positions are saved per character, with separate layouts for individual and combined bags. Saving uses bag identity, so a reused Blizzard frame does not inherit another bag's position. Positions adjust for screen and UI scale changes. **Reset layout** clears both saved layouts and restores the game's placement. Movement and saved-position restoration wait until combat ends; combat cancels an active drag.

Click **Sort** to request one sort of your equipped bags. Opening bags, looting, logging in and leaving combat never trigger sorting. A busy item, occupied cursor or combat blocks the request without queuing a later sort. **Reverse sort direction** changes the game's direction preference; click Sort afterward to use it. The addon leaves the game's excluded bags, category filters and special-bag rules intact. It does not sort the bank, sell, delete or mail items.

This release supplies an independent button for the native `C_Container.SortBags` function still present in build 70338. It can avoid the missing or misplaced built-in button, but it cannot repair a failure inside the client's sorting function. **Sort requested** means the request was accepted without a Lua error, not proof that items moved. If nothing changes, check each bag's Ignore/Cleanup setting in its menu and try reversing the sort direction. Actual item order still needs an in-game check.

**Hide tools** and `/fm bags off` hide only the optional panel. Header dragging, the header Sort button and saved positions remain available. Version 0.9.0 repairs the older setting that disabled movement when hiding tools. `/fm bags reset` clears saved positions. `/fm bags status` reports the loaded version and frame detection. There is no per-frame loop or background sorting in this module. ElvUI and BlizzMove have their own update loops; total FPS and memory impact have not been measured in game.

## Talent coach and combat reference in 0.6.0

Open `/fm coach` or `/fm talents`. Choose a class and talent tree, then a plan with the source and point count you want. All nine classes and all 27 trees have plans. Since 0.11.0 the library includes 96 leveling-guide plans; the ZBuilds snapshot no longer carries Talents Forever community builds. None is presented as a proven fastest-leveling build.

**Follow this plan** saves the selected plan for your character. Outside combat, the panel compares the plan with your committed talents and lists the next three missing points. It checks the client's purchase eligibility for the first point. Spend points yourself in the game's talent window. A respec, pending talent edits, an unknown tree layout or points outside the chosen plan stops personalized guidance until you resolve the mismatch. You can still browse the plan.

Each plan distinguishes a published point order from an estimated order constructed from final ranks. The estimate satisfies the recorded rows and prerequisites; it is not an optimized leveling route. Point numbers are allocation order, not character levels. Legacy points and respecs change timing. Some plans stop at the current beta endpoint, and later plans are theorycraft. Finishing one plan does not automatically select another.

**Combat guide** shows three fixed ability cards for each tree, with a separate Bear reference for Feral Druids. **Show reference bar** displays those cards in a movable, lockable bar. Learned-spell and default action-bar key hints refresh outside combat. The bar does not evaluate targets, cooldowns, resources or buffs, and its order is not a cast sequence. It is not Hekili's live next-spell engine. `/fm coach status` checks native Assisted Combat availability; no native prediction provider is connected in this release. `/fm coach off` hides the bar.

The November 3 talent snapshot contains 468 talents, including the rebuilt Paladin trees. Every plan passed rank, row and prerequisite checks; none was excluded. The Priest talent Devouring Contagion has no spell ID in that snapshot, so its identity requires an exact English name and matching position. Other locales receive static Priest previews until this gap is resolved. Sources, adaptations and licenses appear in RESEARCH.md and THIRD-PARTY.md.

The Coach uses coalesced events with a 0.25-second delay. It has no per-frame handler, recurring polling, combat-log listener or combat-state prediction. The enabled reference bar performs a bounded scan of readable default bars after relevant events outside combat. Talent comparisons are cached and read only when the panel needs them. The bundled data takes about 196 KB of Lua source, not a measured runtime memory allocation. Live FPS, frame-time and memory effects still need measurement.

## Sequence workshop in 0.5.0

Open `/fm sequences`. Choose one of eight slots, then load your **Class starter** or clear the draft and add spells from the search results. Click a step to move or remove it. The preview shows the exact macro and its byte count. Every required spell must be learned, and the body must fit 255 bytes before installation.

**Save draft** keeps your work through reloads without changing a macro. **Install this draft** creates or updates `FM Seq1` through `FM Seq8`. Drag the macro to your bar once. Later changes keep that same name and icon. During combat, an install request waits until combat ends; **Cancel queued** cancels it. Your hand-edited, renamed or deleted macro is preserved.

Two modes are available. **Cast sequence** advances after a successful cast, with another keypress for each step. An unavailable spell holds the sequence. Alt resets to step one. The optional five- and ten-second reset values measure inactivity, not time since the first cast. **Modifier choices** use step one with no modifier, step two with Shift and step three with Ctrl. Ctrl takes precedence if both are held. These choices are fixed; the addon does not choose an optimal spell from cooldowns or resources.

Target controls select self, a living hostile target, a living friendly target or ordinary spell targeting. Optional guards require being outside combat, in caster form or free of a current channel. A caster-form guard does not shift forms. The picker includes catalog spells and three additional preparation spells, checked against the learned spellbook. It is not a complete spellbook browser. Missing or unsupported beta abilities remain unavailable.

| Class | Starter draft | Intended use |
| --- | --- | --- |
| Warrior | Rend, Sunder Armor | Short melee opener; requires rage and a usable stance |
| Paladin | Blessing of Might, Seal of Righteousness | Self preparation outside combat |
| Hunter | Serpent Sting, Arcane Shot | Short ranged opener; pet and Auto Shot controls stay separate |
| Rogue | Cheap Shot, Sinister Strike | Begin in stealth; use normal attacks afterward |
| Priest | Power Word: Fortitude, Inner Fire | Self preparation outside combat |
| Shaman | Strength of Earth, Healing Stream, Windfury Totem | Place one selected totem per successful press |
| Mage | Arcane Intellect, Frost Armor | Self preparation; change the armor if needed |
| Warlock | Demon Armor, Unending Breath | Self preparation outside combat |
| Druid | Mark of the Wild, Thorns | Self preparation outside combat in caster form |

These are editable starting points. They carry no raid damage or healing optimization claim. Keep interrupts, dispels, emergency defensives and finishers that depend on current resources on dedicated buttons. Native sequence behavior still needs testing on the installed beta build.

### Builds, history and sharing

Open **Builds** to save the confirmed workshop slot definitions under a name. Up to twelve builds fit in each character's settings. **Preview listed slots** checks every included slot for missing abilities, personal edits, collisions and space. **Apply previewed build** changes those slots only. Omitted slots remain unchanged. A changed macro or reserve setting requires another preview. An API failure stops the operation and reports the number of slots completed; applying a build is not an atomic transaction.

Each sequence slot retains ten prior confirmed definitions. **History** loads one into the draft for review. **Install this draft** applies it through the same ownership checks. Build names must be unique. Saving a draft changes only that slot's saved draft.

**Share / import** uses `FMSEQ1` text. Builds use `FMPROFILE1` text. Both formats contain class and spell references, with no character identity, executable Lua, keys or bars. Import opens a draft or build preview. It cannot execute code or install a macro. Sequence strings are limited to 1,024 bytes and build strings to 6,144 bytes. **Copy macro** provides ordinary generated macro text for another editor. GSE encoded imports and exports are not supported.

Run `/fm check` or click **Run read-only patch check** after a patch. It reports ownership and missing abilities, basic bracket errors, Lua script lines needing manual review and modifier conflicts on readable default action bars. Custom bar addons and click-casting bindings may not be visible to this check. It does not rewrite your keys or certify spell range, resources or cooldowns.

The workshop uses original code. The feature comparison informed its sequence controls, revisions, build profiles and checks. GSE's current license is All Rights Reserved. MacroForge has an MIT license; ZMacros lists MIT on its project page. No source from those addons is bundled here. See RESEARCH.md for the checked releases and limitations.

### Performance

There is no new polling loop, combat-log listener, background casting or external addon dependency. Spell choices reuse the existing coalesced cache, with at most one extra preparation spell lookup for Priest, Mage or Warlock before that spell enters an installed sequence. Previews and checks run on demand. The workshop stores at most eight active slots, eight drafts, twelve builds and ten history entries per slot through its normal controls. Real FPS and memory usage have not been measured in game.

## October 10 compatibility fixes retained from 0.4.2

Priests can choose **PenanceHeal** or **PenanceHarm** in the library after learning Penance. The healing button supports Alt-self, friendly mouseover, target and teammate assignments. The damage button uses Shift-focus, hostile mouseover and target. Both wait for an existing channel to finish and never start melee or wand attacks. They are optional and use exact learned English spell names until Forever spell IDs are verified.

**Prowl** now requires the character's actual Cat Form slot, no combat and no active stealth. Repeated presses do not ask the game to cancel Prowl. **Dash** also requires Cat Form. Neither button shifts forms for you. Unchanged addon-owned copies update in place outside combat; hand-edited copies remain yours.

The Shifting Power description now reflects the game's full-energy restriction. The Wand description flags the unresolved repeat-press bug instead of promising that `!Shoot` works correctly on every beta build. No guessed workaround was added. [October 8 development notes](https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-october-8/2360696/5), [wand issue](https://github.com/ClassicWoWCommunity/forever-bugs/issues/114).

The 0.4.2 compatibility fixes added no polling loop, event subscription or external dependency. Their FPS impact has not been measured in game.

## October client update

Version 0.4.1 adds **ShiftingPower**, an optional Druid button that uses the learned Shifting Power talent only while already in Cat Form. **SpearStrike** installs for Warriors who learn Spearing Strike and have Battle Stance. Its cast and attack commands require that stance, with no two-handed weapon restriction.

Hunters and Warlocks can choose **PetAggressive** in the Pet library. It changes the active pet to Aggressive when pressed, which can make it attack nearby enemies. It is never installed automatically. Existing pet-control buttons retain their behavior.

These additions follow the [October development notes](https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-october-1/2360696/4). Spell buttons still require learned abilities and available macro slots. The two new spell names use English spellbook matching until their localized IDs are verified. `/fm status` now includes the full client build and interface number.

## Quick start

1. Exit WoW completely and reopen it after a first installation. Updating from 0.8.0 only needs `/reload` outside combat. Open `/fm` and confirm **v0.9.0** in the lower right.
2. Search by spell or purpose in the box above the list. Select a macro, review its preview, and click **Install / update selected**. Choosing an unlearned ability with default targeting saves it for installation after you learn it.
3. Open `/macro` and drag that macro onto your action bar once.
4. For a friendly action, click a teammate in the addon window. Later assignments edit that same macro.
5. Open **Equipment** to capture your equipped weapons or choose items from your bags. No item names need typing.

A `+` marks a managed macro, `~` marks a saved learning request, and `*` marks an unavailable ability. The detail panel explains edited or missing macros. The Attacks filter finds damage buttons, and PvP includes relevant starters. See CATALOG.md for every template and its exact default text.

## Learning skills and updating macros

Learning a skill, receiving updated spell text, logging in, or changing the active pet triggers a check. Core melee and Hunter shot templates now install automatically when learned, with attacks taking priority over general utility. Still-owned macros are refreshed in place when their generated text changes. These checks wait until combat ends.

Leveling also triggers the check, but a level alone does not make an unlearned skill available. Version 0.6.0 adds learned Mutilate, Venom and Ghostly Strike attack buttons. Exorcism, Hammer of Wrath, hostile Holy Shock and Consecration now qualify automatically and start melee on their selected-target branch. Warrior Taunt gains the same target-only attack start. Earth Shock already has this guard. Stealth openers and breakable control retain their special handling. The combined Hunter MeleeWeave button remains optional because it cancels a cast; its individual melee attacks install automatically.

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

Shaman Earth Shock and Frost Shock start melee swings on the normal enemy-target path. Their focus and mouseover paths cast without adding a swing command. Flame Shock and Stormstrike began as optional current-target buttons and now install automatically when learned. Move your pointer off hostile units or unit frames when testing the normal target path.

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
| `/fm bags` | Open Blizzard's bags and enable their movement and Sort controls |
| `/fm bags move` | Open bags and enable dragging of the whole backpack window |
| `/fm bags off` | Hide bag tools and return to native bag placement |
| `/fm bags reset` | Clear individual and combined saved bag layouts |
| `/fm bags status` | Report combined-frame detection and header dragging state |
| `/fm training` | Open the embedded What's Training? Forever window |
| `/fm layout` | Show ElvUI profile controls and setup status |
| `/fm sequences` | Open the sequence workshop |
| `/fm easy` | Find your compact leveling routine |
| `/fm totems` | Find the learned Shaman totem control |
| `/fm builds` | Open saved sequence builds |
| `/fm coach` or `/fm talents` | Open class, talent and combat-reference guidance |
| `/fm coach status` | Check native Assisted Combat availability outside combat |
| `/fm coach off` | Hide the fixed reference bar |
| `/fm check` | Run the read-only patch and binding check |
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

API inspection for this update used the [UI source matching build 1.60.1.70338](https://github.com/Gethe/wow-ui-source/tree/943764493e6b16d63ded3ab304150d1f05e58b57). RESEARCH.md records the October compatibility check and the earlier library research. Timer support is unchanged from the earlier release and has not been verified in a live encounter.

See [SECURITY.md](SECURITY.md) before contributing. Original code and documentation use the [MIT license](LICENSE). Adapted talent data has separate terms and attribution in [THIRD-PARTY.md](THIRD-PARTY.md). World of Warcraft names and game assets referenced through the client belong to their respective owners.
