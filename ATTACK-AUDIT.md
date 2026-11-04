# Attack behavior audit, October 10, 2026

Version 0.6.0 adds automatic learned Mutilate, Venom and Ghostly Strike macros with Stealth guards. Their talent IDs come from the attributed October 8 Forever tree snapshot in TalentData.lua, rather than Retail IDs. Exorcism, Hammer of Wrath, hostile Holy Shock and Consecration become automatic attack templates. Warrior Taunt gains attack start on its ordinary selected-target branch. Focus and mouseover branches stop before the swing command. Friendly Holy Shock stays a healing button.

Earth Shock already has the target-only attack start shown below. Every primary melee start-attack template now qualifies for creation after its spell is learned. The combined Hunter MeleeWeave button remains optional because it cancels casting; Raptor Strike and Mongoose Bite install as individual attacks. Learning during combat waits until combat ends. A higher spell rank normally retains the same rankless macro text and action-bar reference. The addon preserves personal edits, respects reserved slots and never removes an existing macro to create space.

The October 10 client check found build 1.60.1.70338. Its relevant command handlers are unchanged from the prior build comparison documented in RESEARCH.md. The earlier records below retain their original version context.

Version 0.4.1 adds a Battle Stance guard to both commands in the new Spearing Strike button. Shifting Power casts only while already in Cat Form and does not start attacks or change form. Hunter and Warlock Aggressive mode is an optional pet command that can cause the pet to attack nearby enemies after activation. No existing template switches to Aggressive.

Version 0.4.0 fixes a lifecycle gap: the old skill-change handler only checked for new starter macros. Most already-installed macros required a manual update, and many ordinary damage buttons were optional. The release now refreshes unchanged addon-owned macros after relevant events and promotes core attack buttons to automatic starters.

The inspected client is Forever 1.60.1.70205. Its command handlers parse cast, start attack, stop attack, and stop macro independently. Our conditions keep their targeting aligned. These handlers are unchanged from build 70009. [Matching Blizzard UI source](https://github.com/Gethe/wow-ui-source/blob/e3ecc27b64d30fdc735a3f6579b866858f9f9df1/Interface/AddOns/Blizzard_ChatFrameBase/Shared/SlashCommands.lua)

| Action | Generated behavior |
| --- | --- |
| Melee damage | Start swings at a living current enemy even when the spell cannot cast. No automatic target acquisition. |
| Rogue damage and feral damage | Guard attack start against Stealth or Prowl. Feral macros also require the actual form slot. Openers omit a pre-cast attack start. |
| Hunter shots | Use non-toggle Auto Shot. Dedicated damage buttons address the selected enemy. |
| Hunter Concussive Shot, Viper Sting, Tranquilizing Shot | Shift-focus, then hostile mouseover, then selected target. Only the last branch adds Auto Shot. |
| Melee interrupts and utility | Off-target branches cast without adding swings at a different selected enemy. The ordinary target branch starts swings. |
| Mage, Priest, Warlock | Offer separate non-toggle wand buttons. Damage casts do not also fire a wand or start player melee. |
| Channeled spells | Channel-safe variants refuse a new cast while channeling. Ground-area abilities keep explicit cursor targeting. |
| Healing, buffs, defensive abilities | Preserve their purpose without starting a new attack. |
| Breakable crowd control | Stop player attacks. Hunter control also recalls the pet where needed. Existing damage over time and projectiles can still break control. |

Classic authored guides support these separate patterns. The Hunter community's current beta notes also report that melee can affect the ranged swing timer, so a combined melee/ranged rotation is not treated as interchangeable with separate buttons. [Hunter patterns](https://github.com/classic-hunter/forever-hunter/wiki/Hunter-Macros), [current beta observations](https://github.com/classic-hunter/forever-hunter/wiki/Forever-Beta-Changes), [Shaman author guide](https://www.icy-veins.com/wow-classic/classic-guide-to-shamans-best-macros)

## Shaman target behavior

Earth Shock keeps the existing interrupt and targeting options. The final stop condition prevents a focus or mouseover press from starting swings at a different selected unit:

```text
#showtooltip Earth Shock
/stopcasting
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Earth Shock
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

Move the pointer off hostile units and their frames when testing the ordinary target branch. An off-target macro does not stop attacks already running unless it contains an explicit stop command.

Flame Shock and Stormstrike are automatic current-target attack buttons when learned. Lightning Bolt, Chain Lightning, and Lava Burst also have current-target melee-weaving versions. Casting can delay swings. These buttons do not imply that an Elemental player should remain in melee.

## Hunter patch adjustments

The library includes Summon Hawk, Sniper Shot, and Strider Kick. Pet Screech accepts its renamed Demoralizing Screech form. New family abilities are gated by the active pet's actual spellbook. English name checks cover beta abilities whose stable ID has not been verified.

Current beta notes say traps can be placed in combat and Wyvern Sting was removed. The optional FeignTrap button therefore chooses Freezing Trap normally and Feign Death with Alt. It is not a mandatory trap sequence or a one-press combination. [Hunter beta changes](https://github.com/classic-hunter/forever-hunter/wiki/Forever-Beta-Changes)

## Verification

All 375 mocked checks pass. Attack cases cover target conditions, failed spell attempts, stealth and form guards, skills learned during combat, higher ranks, later slot availability, ownership and update loops. They also cover the Paladin and Taunt target branches, optional pet-mode selection and corrected pet ranks. They do not reproduce the combat engine. Version 0.10.0 adds FM Easy for four classes, including Shaman shield and damage sequences, Paladin seal/Judgement correction, Priest channel protection, and Hunter pet/Auto Shot plus fixed shots. A top-level guard stops these buttons on friendly, dead or absent targets and during channels. Shaman totems and Recall require separate keys. See VALIDATION.md for the full results and live checklist, and RESEARCH.md for source coverage and access limits.
