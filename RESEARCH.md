# Forever macro research, October 10, 2026

## Compact leveling controls in 0.10.0

Reviewed author-written Forever leveling guidance for [Shaman](https://www.method.gg/wow-forever/wow-forever-shaman-leveling-guide-and-talents), [Priest](https://www.method.gg/wow-forever/wow-forever-priest-leveling-guide-and-talents), [Paladin](https://www.method.gg/wow-forever/wow-forever-paladin-leveling-guide-and-talents) and [Hunter](https://www.method.gg/wow-forever/wow-forever-hunter-leveling-guide-and-talents). The Paladin page was updated October 10; the Shaman page was readable earlier in this review but a later fetch failed. The relevant Shaman changes are also described in [NickTew's October 8 guide](https://mobalytics.gg/wow-forever/classes/shaman-leveling-guide). These are beta guide authors' recommendations, not measured results for the user's characters.

Shaman sources describe Lightning Shield upkeep, shared shock cooldowns, Call of the Elements and Totemic Recall. FM Easy refreshes the shield once per target, as requested, and cycles learned shocks with Stormstrike. It does not inspect shield charges or mana. Totems stay on a separate key to avoid paying for them on every pull. FM Totems uses a short learned-only sequence before Call of the Elements and the native saved set afterward. Call of the Elements 66842 and Totemic Recall 36936 are confirmed against the local Forever spell-data snapshot and accepted only when actually learned. FM does not populate the native totem bar. Weapon imbues stay separate.

The Paladin author explicitly describes Judgement as off the global cooldown and says it no longer consumes seals in Forever. This corrects the older Classic-style reseal step in FM AutoOpen. The compact routine applies Righteousness once per target, then attempts Judgement and Holy Strike with melee. It leaves Consecration, other seals and defensive cooldowns under separate control. Holy Strike is resolved by learned English name; no Retail Crusader Strike ID is substituted.

The Priest author emphasizes wand use for mana efficiency and distinguishes early Smite, Mind Blast, later Penance and Shadowform/Mind Flay play. FM's repeated casting routine is a convenience compromise. It shields separately, uses a learned main attack plus Pain and four filler casts, and protects channels. It omits automated wand weaving because the reviewed Forever behavior is not reliable enough to promise it. The user still has a separate wand macro. Repeated casting spends more mana, and fixed cycles can refresh Pain early. Learning Mind Flay switches the generated routine to shadow damage; this is a learned-ability rule, not a talent optimizer.

The Hunter author describes a six-second shared cooldown for Summon Hawk and Arcane Shot, and maintaining two Hawks. The simplified learned routine uses Sting followed by two Hawks and an Arcane Shot, with a three-Arcane fallback before Hawk is learned. This adapts the guide into a fixed sequence and omits Aimed Shot from that loop. It is not the author's complete priority system or a proven fastest leveling macro. Pet attack addresses the selected living enemy; no pet mode, taunt or AoE setting is changed.

[GSE's castsequence explanation](https://github.com/TimothyLuke/GSE-Advanced-Macro-Compiler/wiki/Understanding--castsequence) documents successful-cast advancement and inactivity-based resets. FM uses native macro text and existing ownership rules, without copying a GSE sequence or external addon code. An unavailable step waits for a later user press. The two separate shield and damage sequences must still be checked in the real client, along with shot continuation and native totem-set casting. The tests validate text generation, conditions and lifecycle boundaries, not the game's spell execution.

No combat aura, enemy resource, cooldown or target-health scan was added. These controls are not live Hekili recommendations. They add no per-frame work and never send a keypress. Native execution, mana efficiency, damage and frame time remain unmeasured. The new controls are supported on the Forever 1.60.x target only; no Classic Era compatibility claim is added.

## Layout and movement correction in 0.9.0

The game was observed at 5120 x 2160 on the lower display. The minimap overlapped the Questie tracker, utility slots sat in tall columns at the far right, and the combined backpack had no movement controls. The saved bag settings had movement disabled. The old Hide tools command disabled our header while the integration also disabled BlizzMove's bag mover. The user confirmed that movement worked after opening the FM bag tools. The correction separates toolbar visibility from header movement and adds a Sort button on the backpack itself.

Reviewed the official [LuckyoneUI site](https://luckyone.dev/), including its damage/tank and healer preview images. The author states Forever support. Its central combat information and role-specific group-frame arrangements inform the revised custom layout. [RedtuzkUI Classic](https://github.com/dBlocc/ElvUI_RedtuzkClassic) provides another primary-source comparison for action-bar presets and party/raid styles, but its stated interface target is Classic Era 11508. Its package was not installed as a Forever-compatible replacement. The [Luckyone Classic healing listing](https://wago.io/XcyNz5dwZ) was identified, but its contents were not readable through the web fetcher. No import from that listing was performed.

No benchmark establishes a best profile for this user. The implemented profiles are original arrangements with larger controls, 36 main slots, 24 adjacent utility slots, class-specific pet/stance/resource controls, role-specific group frames and a corner minimap. ElvUI's own mover interface is exposed through the FM window. Original v1 layouts remain available. No third-party profile, custom tag implementation or artwork was copied. Code checks cover the installed development build; rendering and mouse routing require live observation.

## Bag controls in 0.7.0

The installed client remains 1.60.1.70338. The [matching ContainerFrame.xml](https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/ContainerFrame.xml) invokes `C_Container.SortBags` directly from its sort button. The [ContainerFrame implementation](https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/ContainerFrame.lua) contains button visibility branches for gamepad mode and still exposes the frame manager and anchor update function. [Container API declarations](https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/ContainerDocumentation.lua) include sorting, direction preferences and item locks.

These sources justify a separate Sort control without cursor-based item movement. They do not prove that every client-side sorting defect is resolved. The button requests one native equipped-bag sort, checks combat, cursor and item locks, and leaves exclusion flags untouched. Direction changes require a separate user click. The user's chosen behavior is click-only; there is no sorting on login, loot, bag opening or combat end.

The mover adds original drag handles to native equipped-bag frames and restores positions through a post-hook on the native anchor update. It keys positions by actual bag identity and keeps the combined layout separate. It does not replace native item buttons, bank frames or the global anchor function. Frame movement and restoration are suspended in combat. There is no external dependency or per-frame handler. Runtime rendering, taint behavior, item order and FPS remain live checks.

## Coach and talent guidance in 0.6.0

This review covers Forever-specific material published or updated from September 10 through October 10. The nine Method leveling guides below were checked on October 10. Their recommendations guide the class summaries; community popularity is displayed separately. These are beta recommendations, not measured speed records or proof of an optimal build for every role.

| Class | Current leveling advice used | Guide date and source |
| --- | --- | --- |
| Warrior | Protection for solo grinding; Arms with a two-handed weapon for supported group play | October 9, [Method Warrior guide](https://www.method.gg/wow-forever/wow-forever-warrior-leveling-guide-and-talents) |
| Paladin | Begin with Holy damage talents, then Retribution mana and movement talents; reassess the role around 30 | September 24, [Method Paladin guide](https://www.method.gg/wow-forever/wow-forever-paladin-leveling-guide-and-talents) |
| Hunter | Beast Mastery for solo leveling, with the pet handling damage and enemy attention | October 9, [Method Hunter guide](https://www.method.gg/wow-forever/wow-forever-hunter-leveling-guide-and-talents) |
| Rogue | Combat and Assassination alternatives; weapons, Legacy points and a possible level-30 respec affect the plan | October 9, [Method Rogue guide](https://www.method.gg/wow-forever/wow-forever-rogue-leveling-guide-and-talents) |
| Priest | Early wand support, Discipline for Penance at 30, then a separate Shadow plan at 40 | October 4, [Method Priest guide](https://www.method.gg/wow-forever/wow-forever-priest-leveling-guide-and-talents) |
| Shaman | Enhancement, with Improved Ghost Wolf before 20 and Stormstrike at 25 | September 30, [Method Shaman guide](https://www.method.gg/wow-forever/wow-forever-shaman-leveling-guide-and-talents) |
| Mage | Frost for control and ranged leveling; beta plans distinguish additional Legacy points | October 9, [Method Mage guide](https://www.method.gg/wow-forever/wow-forever-mage-leveling-guide-and-talents) |
| Warlock | Affliction early; Demonology gains value later, with other builds available | October 8, [Method Warlock guide](https://www.method.gg/wow-forever/wow-forever-warlock-leveling-guide-and-talents) |
| Druid | Feral, using Bear early and Cat after its level-20 quest; retain healing gear for groups | September 29, [Method Druid guide](https://www.method.gg/wow-forever/wow-forever-druid-leveling-guide-and-talents) |

[Talents Forever's leveling analysis](https://talentsforever.com/leveling) counted 707,500 planned builds on October 7, covering September 18 through October 6 and requiring at least ten ordered points. Its most-planned tree is Protection for Warrior (52.6%), Retribution for Paladin (41%), Survival for Hunter (43.9%), Subtlety for Rogue (38.5%), Discipline for Priest (42.7%), Enhancement for Shaman (60.5%), Frost for Mage (45.3%), Affliction for Warlock (43.5%) and Feral for Druid (45.4%). These are planning preferences. The Hunter and Rogue results differ from the selected author recommendations, which is why the UI does not equate popularity with speed.

The bundled data uses the [October 8 Talents Forever snapshot](https://talentsforever.com/data.json) and [ZBuilds at commit 0e89515105f22e3cf225630ed7a3b7d0209b6722](https://github.com/Zael98/Zbuilds/tree/0e89515105f22e3cf225630ed7a3b7d0209b6722). Of 128 selected candidates, eleven failed rank-order or prerequisite validation against that snapshot and were excluded. The remaining 117 cover all 27 trees, with 72 guide-leveling plans and 45 community plans. Final-rank community builds receive a valid estimated order when their source has none. Every plan keeps its source link. See THIRD-PARTY.md for attribution and licensing.

Version 0.11.0 (November 4) replaces that data with the November 3 Talents Forever snapshot and [ZBuilds at commit 57bae431e5b13bc04c2d8883e53ece17f909ab0a](https://github.com/Zael98/Zbuilds/tree/57bae431e5b13bc04c2d8883e53ece17f909ab0a), which carry the October 28 Mage and October 30 Paladin and Druid hotfix trees. All 96 leveling candidates passed validation; seven have estimated orders. ZBuilds no longer lists Talents Forever community builds, so there are none. The generator is the same adapter as in 0.6.0, re-run on the new inputs.

| Class | Plans by tree |
| --- | --- |
| Warrior | Arms 5; Fury 3; Protection 4 |
| Paladin | Holy 1; Protection 4; Retribution 5 |
| Hunter | Beast Mastery 4; Marksmanship 1; Survival 4 |
| Rogue | Assassination 2; Combat 6; Subtlety 3 |
| Priest | Discipline 9; Holy 4; Shadow 7 |
| Shaman | Elemental 1; Enhancement 7; Restoration 5 |
| Mage | Arcane 5; Fire 5; Frost 6 |
| Warlock | Affliction 3; Demonology 5; Destruction 4 |
| Druid | Balance 2; Feral Combat 9; Restoration 3 |

Holy Paladin, Marksmanship Hunter and Elemental Shaman have community plans only in this validated selection. They are not labeled as verified leveling recommendations. Plans for other trees can represent a group role, a partial beta endpoint or later-level theorycraft. The addon does not switch builds or spend points automatically. Points outside a plan stop personalized suggestions instead of silently recommending a respec. Devouring Contagion lacks a spell ID in the source snapshot, which limits current Priest comparison to an exact English name plus geometry; non-English Priest clients retain static previews.

The [matching trait declarations](https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/SharedTraitsDocumentation.lua) describe the read APIs used to compare committed ranks. The reader checks identity, maximum ranks, visibility and relative grid positions before trusting a full snapshot. Client drift, unreadable fields, pending changes and combat suppress personalized guidance. Mock verification covers all classes, every plan prefix and failure paths. Native client agreement still needs confirmation.

## Hekili-style display boundary

[Hekili's author README](https://github.com/Hekili/hekili) says Retail development ended with the January 20, 2026 Midnight prepatch because the API direction prevented its intended functionality. That older primary source supplies historical context, not a current Forever compatibility test. The [Forever-matching spell API declarations](https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpellDocumentation.lua) mark cooldown values as secret under restrictions. A true next-spell engine needs inputs beyond an icon display, and this review did not establish a supported live provider for Forever.

Version 0.6.0 therefore implements original fixed reference cards for all 27 trees and a separate Feral Bear set. It resolves learned abilities and readable default-bar keys outside combat. It does not evaluate cooldowns, resources, auras or targets, and it neither simulates a rotation nor decodes restricted values. The presence of [C_AssistedCombat](https://github.com/Gethe/wow-ui-source/blob/943764493e6b16d63ded3ab304150d1f05e58b57/Interface/AddOns/Blizzard_APIDocumentationGenerated/AssistedCombatDocumentation.lua) is insufficient evidence of Forever support. The manual check reports IsAvailable only; GetNextCastSpell is not called or integrated.

The new Coach coalesces events and caches talent snapshots. It has no OnUpdate handler, recurring ticker or combat-log scan. The bar freezes its reference cards in combat, and the panel suppresses character comparisons. Static talent data is about 196 KB of source; runtime memory and FPS have not been measured. This implementation adds event subscriptions, while the workshop-only performance statement below remains specific to 0.5.0.

## Sequence workshop source review

Version 0.5.0 implements a native castsequence and modifier-choice workshop with original Lua code. Eight stable macro slots, twelve named builds, data-only sharing, ten prior definitions per slot and a read-only patch check address the useful overlap from the addon comparison. No third-party code is copied or loaded at runtime.

| Reference | Verified source | Decision |
| --- | --- | --- |
| GSE 3.3.34 | [Author repository and license](https://github.com/TimothyLuke/GSE-Advanced-Macro-Compiler/blob/master/LICENSE) | Current license says All Rights Reserved. Do not copy its compiler. Native castsequence advances on successful casting, which differs from GSE's configured click progression. |
| MacroForge 7.7.1, October 9 | [Release](https://github.com/kriffin/MacroForge/releases/tag/v7.7.1), commit `961dfd7751d12fba92bd7b1554e91f12bf03b771`, [MIT license](https://github.com/kriffin/MacroForge/blob/main/LICENSE) | Adopt the ideas of revision previews, readable editing and build sets with our own code. Its icon fix reinforces preserving an existing macro's icon by passing nil to EditMacro, which ForeverMacros already does. |
| ZMacros 1.0.2, October 4 | [Project and MIT listing](https://www.curseforge.com/wow/addons/zmacros), [release file 9061914](https://www.curseforge.com/wow/addons/zmacros/files/9061914) | Add class starters, build previews and binding diagnostics. Its package source was not audited or copied. Automatic bar placement and binding replacement are outside this implementation. |

Native sequence semantics are described in the [GSE author's explanation](https://github.com/TimothyLuke/GSE-Advanced-Macro-Compiler/wiki/Understanding--castsequence). These patterns require a player press and can stall on an unusable ability. Time resets count inactivity. The new workshop never evaluates cooldowns, debuffs or combo points to select the next action. There is no unattended casting, priority engine, GSE encoded-string compatibility or claim of optimized class rotations.

The class starters use learned spell IDs already in the catalog, plus Inner Fire (588), Frost Armor (168) and Demon Armor (706). The existing resolver must confirm each as an active learned player spell. An absent or renamed ability blocks installation. All nine presets pass generated-text and lifecycle tests; none has a new live combat certification.

The patch check inspects generated and current macro text, detects simple bracket errors and warns about scripts and readable default-bar modifier bindings. It is a limited diagnostic, not a full parser for every legal macro command. Custom bar and click-casting integrations, a raw Lua macro editor, icon browser and a separately licensed GSE adapter remain future work.

No new event listener or recurring timer was added. The spell picker reuses the existing cache. Real frame-time measurements require the client and remain outstanding.

## October 10 compatibility update

The installed WowB.exe and active wow_classic_beta entry in .build.info both report **1.60.1.70338**. The UI-source mirror matches at commit **943764493e6b16d63ded3ab304150d1f05e58b57**. The comparison from build 70205 spans five commits. MacroUI changes its selected-row handling; the slash-command change concerns voice chat. The spellbook declarations and macro constants used by ForeverMacros did not change in this comparison. The interface remains 16001. [Client comparison](https://github.com/Gethe/wow-ui-source/compare/e3ecc27b64d30fdc735a3f6579b866858f9f9df1...943764493e6b16d63ded3ab304150d1f05e58b57).

Blizzard's October 8 notes confirm Penance damage and healing changes, a full-energy restriction for Shifting Power and restored multiple-weapon swaps within one global cooldown. Penance was missing from this library. Version 0.4.2 adds separate optional healing and hostile templates, with an existing-channel guard and no invented Forever spell ID. Existing weapon presets already emit separate slot commands, so no new equipment API or workaround is needed. Native execution still requires an in-game test. [Development notes](https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-october-8/2360696/5).

The Prowl and Dash updates use the existing form resolver, so Cat Form is not assumed to occupy a fixed slot. Prowl also requires no combat and no active stealth. These are conservative macro guards, not claims that a new client bug was fixed. An absent form leaves a selected utility queued, and a changed form layout refreshes only still-owned macros after combat.

The public `!Shoot` report remains open, last updated October 9. Version 0.4.2 corrects the Wand description to expose that uncertainty. Its body is unchanged because this review did not establish a tested replacement. [Issue 114](https://github.com/ClassicWoWCommunity/forever-bugs/issues/114).

No external addon code was copied for 0.4.2. The additional addon and sequencing comparison is maintained in the local research packet; proposed sequence packs are not installed by this compatibility update.

## October 3 compatibility record

The installed WowB.exe and active wow_classic_beta row in .build.info both report 1.60.1.70205. The matching UI source is commit e3ecc27b64d30fdc735a3f6579b866858f9f9df1. Comparison with the previously inspected build 70009 covers four client revisions. The spellbook declarations, macro constants, and cast/attack handlers used by this addon are unchanged. The slash-command changes concern character ignores. The client now exposes WOW_PROJECT_CAMELOT as 18; this addon's existing version check does not depend on the old project ID. [Build comparison](https://github.com/Gethe/wow-ui-source/compare/bd2470aed543f72697a044e989285b6c83e63f73...e3ecc27b64d30fdc735a3f6579b866858f9f9df1)

Blizzard's October notes introduce Shifting Power for Cat Form, remove Tiger's Fury, restore Aggressive mode for Hunter and Warlock pets, and specify Battle Stance for Spearing Strike without a two-handed weapon requirement. The existing catalog had no Tiger's Fury template to remove. Version 0.4.1 adds the two active spell buttons and an optional Aggressive command for each pet class. Balance changes to passive talents do not need cast buttons. [October development notes](https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-october-1/2360696/4)

The current secure handler parses conditions before calling PetAggressiveMode. The new macro uses `/petaggressive [pet]` and requires manual selection and a player keypress. Shifting Power and Spearing Strike use exact learned English names, with no guessed spell IDs. The live client must still confirm spell execution. [Current command handlers](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_ChatFrameBase/Shared/SlashCommands.lua)

## September 28 research record

The client inspected for 0.4.0 was Forever beta 1.60.1.70009, interface 16001. The addon remains scoped to 1.60.x. Classic Era, Season of Discovery, TBC, Wrath, Retail, and old 1.12 private-server macros cannot be assumed to work here. The sections below record the earlier library research; those external pages were not all rechecked for 0.4.1.

## Current build and macro system

Blizzard published the relevant class changes on September 24 and announced another beta server restart on September 25. The local build metadata and the UI-source mirror agree on build 70009. The September 24 notes rename Mangle to Primal Bite and change several Hunter, Paladin, and Shaman abilities. These notes describe a beta that is still changing. [Development notes](https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-september-24/2360696), [September 25 restart](https://us.forums.blizzard.com/en/wow/t/beta-realm-restarts-incoming-sept-25/2362048/1)

The matching Blizzard UI code uses secure conditional command handlers for cast, start attack, stop attack, and stop macro. Spell lookup uses C_SpellBook and separate player and pet banks. The resolver excludes future, hidden, flyout, and off-spec matches, then checks that the returned ability is learned and active. [Pinned source](https://github.com/Gethe/wow-ui-source/tree/bd2470aed543f72697a044e989285b6c83e63f73), [command handlers](https://github.com/Gethe/wow-ui-source/blob/bd2470aed543f72697a044e989285b6c83e63f73/Interface/AddOns/Blizzard_ChatFrameBase/Shared/SlashCommands.lua), [spellbook declarations](https://github.com/Gethe/wow-ui-source/blob/bd2470aed543f72697a044e989285b6c83e63f73/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpellBookDocumentation.lua)

## Hunter coverage

The public Classic Hunter community wiki supplies working patterns for non-toggle Auto Shot, melee attacks, pet orders, control, Feign Death, and ground targeting. Its current beta research adds Summon Hawk, Sniper Shot, Strider Kick, renamed pet abilities, and new pet-family attacks. The expansion covers those patterns with learned-spell checks. [Community macros](https://github.com/classic-hunter/forever-hunter/wiki/Hunter-Macros), [beta changes](https://github.com/classic-hunter/forever-hunter/wiki/Forever-Beta-Changes)

The beta changes page says traps can be placed during combat and Wyvern Sting has been removed. Therefore the library does not add a Wyvern template, and FeignTrap uses a modifier to choose between Freezing Trap and Feign Death. It does not require leaving combat before every trap. Separate shot and melee buttons let the player control a swap between them. Community reports about swing timing still require a live check on this build. [Beta mechanics](https://github.com/classic-hunter/forever-hunter/wiki/Forever-Beta-Changes)

Hunter coverage includes ordinary and talent shots, all four traps, Flare, Volley, defensive and threat buttons, aspects, tracking, pet care, autocast Growl controls, and family abilities. Some buttons intentionally share a spell with another template because their targeting or attack behavior differs. The generated catalog shows each exact body.

## Sources for the other eight classes

These are author-published Classic macro patterns. Their publication dates are older than this beta, so we adapt the targeting patterns and gate every ability through the current spellbook. They are not evidence that an old class rotation or talent tree still applies.

| Class | Source reviewed | Pattern used |
| --- | --- | --- |
| Warrior | [Vanilla Warrior, Warlord Drak](https://www.vanillawar.com/ui-macros.html) | Modern start attack, conditional targeting, ranged pulls, weapon slots, trinket slots. Legacy scripted 1.12 casts excluded. |
| Rogue | [Sellin's Classic macros](https://www.icy-veins.com/wow-classic/classic-guide-to-rogues-best-macros) | Mouseover control, independent attack buttons, stealth-safe openers. |
| Druid | [Seksixeny's Classic macros](https://www.icy-veins.com/wow-classic/classic-guide-to-druids-best-macros) | Form-aware melee and healing from forms. Actual form indices replace fixed cat-form numbers. |
| Paladin | [Classic Paladin macros](https://www.icy-veins.com/wow-classic/classic-guide-to-paladins-best-macros) | Mouseover heals, blessings, and utility. Separate Holy Strike attack button for Forever. |
| Shaman | [Seksixeny's Classic macros](https://www.icy-veins.com/wow-classic/classic-guide-to-shamans-best-macros) | Attack-start damage, immediate interrupts, friendly mouseover heals, and totems. |
| Mage | [Seksixeny's Classic macros](https://www.icy-veins.com/wow-classic/classic-guide-to-mages-best-macros) | Interrupt, mouseover control, conjuring modifiers, and channel protection. |
| Priest | [Classic Priest macros](https://www.icy-veins.com/wow-classic/classic-guide-to-priests-best-addons-and-macros) | Mouseover healing, offensive targeting, and a separate non-toggle wand button. |
| Warlock | [Abide's Classic macros](https://www.icy-veins.com/wow-classic/classic-guide-to-warlocks-best-macros) | Pet orders, pet-bank utility, offensive targeting, and channels. |

## Access and scope

The research window for beta changes was August 29 through September 28. We also used older authored Classic references for stable macro syntax. Public forum searches included the recent [Macros are Friends discussion](https://www.reddit.com/r/wowforever/comments/1wmbmaf/macros_are_friends/). Player observations guide what to test; they do not prove a macro works on every build.

Private Discord channels were not reviewed. Hunter testing issues [17](https://github.com/classic-hunter/forever-hunter/issues/17) and [44](https://github.com/classic-hunter/forever-hunter/issues/44) link to inaccessible Discord threads. Their contents are not evidence for this release.

## Compatibility limits

New beta abilities without a verified stable ID use exact learned English spellbook names. Those additions are available on enUS and enGB; they remain unavailable on other locales until a reliable localized ID mapping is supplied. Existing ID-backed templates use localized names. No guessed Retail ID is treated as proof that a Forever ability exists.

The library is a broad, reviewed collection, not every possible user-authored macro. Downrank shortcuts, alternate rotations, and arbitrary custom combinations can still need individual work. No live encounter, spell execution, or private Discord review is represented by the mock tests.
# October 10 sequence and UI follow-up

Search window: September 10 through October 10, 2026. Older maintainer documentation was used for API and design context. Discord research used the signed-in Chrome account, not the desktop Discord account. Agent Reach had no working Reddit or X backend; public web search covered Reddit. The focused X search returned no useful directly verifiable post. This is a coverage limit, not evidence that no such posts exist.

| Source | Finding | Use in Forever Macros |
| --- | --- | --- |
| [GSE maintainer releases](https://github.com/TimothyLuke/GSE-Advanced-Macro-Compiler/releases) | Forever is identified separately from Era despite both using major version 1. Its API generation differs from its content era. | Keep explicit Forever version checks. A Classic label alone is not compatibility evidence. |
| [GSE author on castsequence](https://github.com/TimothyLuke/GSE-Advanced-Macro-Compiler/wiki/Understanding--castsequence) | Native sequences wait for a successful step and can stall. Timed reset is inactivity. | Bounded openers, explicit resets and a stopping step. Avoid reactive interrupts or emergency defenses inside a fixed sequence. |
| [Forever sequence creator, October 4](https://gseunited.com/t/wow-forever-beta-sequences-macros/830) | The author offers class/spec/level/talent-aware GSE output. Performance claims were not independently tested. | A useful personal comparison tool. Its [license](https://gseunited.com/t/wow-forever-beta-sequences-license/831) does not permit redistribution of generated or modified sequences, so they are not bundled. |
| [Hekili maintainer README](https://github.com/Hekili/hekili) | Retail development ended at the Midnight prepatch. The historical engine required cooldowns, resources and aura state to predict actions. | Retain a readable reference display. No verified Forever prediction provider was found, so static cards are not labeled live recommendations. |
| [MacroForge](https://github.com/kriffin/MacroForge), [ZMacros](https://www.curseforge.com/wow/addons/zmacros) | Author features include spellbook validation, readable conditions, history and class profiles. | Existing workshop drafts and ownership checks plus new learned-only automatic class openers. No source copied. |
| [Reddit macro discussion, September 21](https://www.reddit.com/r/wowforever/comments/1wmbmaf/macros_are_friends/) | Players report castsequence use and pet-control patterns. This is community feedback, not a compatibility test. | Keep pet commands separate unless explicitly selected. Confirm behavior with tests and then live checks. |
| [Reddit wand report, October 10](https://www.reddit.com/r/classicwow/comments/1x27bcq/has_anyone_noticed_that_the_spammable_wand_macro/) | Repeat-press wand behavior remains disputed. | Preserve the existing limitation; do not promise a castsequence workaround. |
| [Shaman Classic Forever forum](https://discord.com/channels/260297137554849794/1553034209235435631) | September 28 through October 4 author posts describe ShamanPower, ShamanForever, resource-efficiency tooltips and ForeverAuras displays. | Candidate features are explicit totem selections, preparation reminders and mana-cost comparisons. The posted fragile custom auras and secure-button scripts were not imported. |
| [Fight Club Forever FAQ](https://discord.com/channels/383596811517952002/1548430294481375272) | October 2 FAQ, edited October 8, states that best-spec consensus is not established and points to changing beta mechanics. | Do not call a generic learned-spell sequence the best rotation or claim every leveling build is validated. |
| [LuckyoneUI author](https://luckyone.dev/) and [changelog](https://github.com/Luckyone961/LuckyoneUI/blob/development/CHANGELOG.md) | Role layouts group combat information centrally; healing layouts bring raid frames inward. Its published baseline is 1440p. | Original LG profiles use that general arrangement with larger labels and buttons. No imported profile or paid asset. |
| [Tukui Forever channel](https://discord.com/channels/209244641537556480/1550184102194446476), [official development download](https://api.tukui.org/v1/download/dev/elvui/main) | Maintainer pin labels the Forever package unsupported. The reviewed package is v15.26-810-g3f2bc8a, with interface 16001. An October 9 discussion reports missing Shaman weapon enchants. | Install the development build separately, retain native buffs and bags, and disclose that live rendering and performance remain unverified. |
| [BlizzMove 3.8.4](https://www.curseforge.com/wow/addons/blizzmove/files/8994028), [What's Training? Forever 1.1.1](https://www.curseforge.com/wow/addons/whats-training-forever/files/9050658) | Published Forever packages provide movable windows and trainer lists. | Separate unmodified installations. Original adapters handle header locks and embed the training window. |

The delivered automatic recipes cover nine classes. They prune unknown spells and select a learned fallback or upgrade; they do not compute an optimal all-spec rotation. The next useful extension is a reviewed recipe per spec, with a recorded client build and separate leveling, boss and area-damage intent. Each recipe needs live checks for stalls, form requirements and resource use before default installation. Spell-efficiency comparison is a candidate for an out-of-combat view; estimated cooldown reconstruction should not be labeled authoritative combat state.
