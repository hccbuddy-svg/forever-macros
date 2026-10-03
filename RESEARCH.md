# Forever macro research, October 3, 2026

## October compatibility update

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
