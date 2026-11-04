# Macro catalog

391 templates across nine Classic classes and general utility, including 239 optional additions.
Starter and attack templates install automatically for the current class and learned abilities while character slots remain. Choose other templates in /fm. English examples are shown here; names are checked against the learned spellbook.
These patterns have not yet been validated in-game on Forever.

FM Auto sequence examples show the fullest starter recipe. At runtime, only learned abilities are selected; some steps prefer an upgrade or fallback. These bounded openers stop at null. They are not live optimal rotations. The separate workshop has nine editable class starters and eight custom slots; user-created slots are not part of this static catalog.

Form and stance numbers below are examples. The addon resolves each character's actual slots when generating a macro.

## ALL

### FM Stop

Template ID: stop. Stop your current cast and auto attack.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Stop attacks.

```text
/stopcasting
/stopattack
```

### FM Focus

Template ID: focus. Set focus to your living mouseover, otherwise target.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
/focus [@mouseover,exists,nodead][@target,exists,nodead]
```

### FM ClearFocus

Template ID: clear_focus. Clear your focus.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
/clearfocus
```

### FM Assist

Template ID: assist. Assist a living friendly focus.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
/assist [@focus,help,nodead]
```

### FM AllyAssist

Template ID: ally_assist. Assist a friendly mouseover or focus. Assign a teammate in the window.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
/assist [@mouseover,help,nodead][@focus,help,nodead]
```

### FM TrinketTop

Template ID: trinket_top. Use the equipped top trinket. This does not equip a different item.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/use 13
```

### FM TrinketBottom

Template ID: trinket_bottom. Use the equipped bottom trinket. This does not equip a different item.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/use 14
```

### FM WillForsaken

Template ID: racial_will. Press to attempt Will of the Forsaken. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Will of the Forsaken
/cast  Will of the Forsaken
```

### FM EscapeArtist

Template ID: racial_escape. Press to attempt Escape Artist. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Escape Artist
/cast  Escape Artist
```

### FM Stoneform

Template ID: racial_stoneform. Press to attempt Stoneform. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Stoneform
/cast  Stoneform
```

### FM WarStomp

Template ID: racial_warstomp. Press to attempt War Stomp. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip War Stomp
/cast  War Stomp
```

## DRUID

### FM Rejuvenate

Template ID: druid_rejuv. Rejuvenate mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Rejuvenation
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Rejuvenation
```

### FM Regrowth

Template ID: druid_regrowth. Regrowth mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Regrowth
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Regrowth
```

### FM HealTouch

Template ID: druid_touch. Healing Touch on mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Healing Touch
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Healing Touch
```

### FM Roots

Template ID: druid_roots. Root a hostile mouseover, target, or Shift-focus. Stops your attacks for crowd control.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Entangling Roots
/stopattack
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Entangling Roots
/stopattack
```

### FM Decurse

Template ID: druid_decurse. Remove Curse from mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Remove Curse
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Remove Curse
```

### FM Rebirth

Template ID: druid_rebirth. Rebirth a dead friendly mouseover or target when usable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Rebirth
/cast [@mouseover,help,dead][help,dead] Rebirth
```

### FM CurePoison

Template ID: druid_poison. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Cure Poison
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Cure Poison
```

### FM AbolPoison

Template ID: druid_abolish. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Abolish Poison
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Abolish Poison
```

### FM Bash

Template ID: druid_bash. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Bash
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Bash
```

### FM Hibernate

Template ID: druid_hibernate. Shift: focus. Otherwise hostile mouseover, then target. Stops your attacks for crowd control.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Hibernate
/stopattack
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Hibernate
/stopattack
```

### FM Barkskin

Template ID: druid_barkskin. Press to attempt Barkskin. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Barkskin
/cast  Barkskin
```

### FM Swiftmend

Template ID: druid_swiftmend. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Swiftmend
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Swiftmend
```

### FM Innervate

Template ID: druid_innervate. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Innervate
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Innervate
```

### FM BearForm

Template ID: druid_bear. Press to attempt Bear Form. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Bear Form
/cast  Bear Form
```

### FM CatForm

Template ID: druid_cat. Press to attempt Cat Form. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Cat Form
/cast  Cat Form
```

### FM TravelForm

Template ID: druid_travel. Press to attempt Travel Form. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Travel Form
/cast  Travel Form
```

### FM Maul

Template ID: druid_maul. Current enemy only. Starts melee swings even if the ability is unavailable. Requires the matching animal form; protects Prowl.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee in matching form, outside stealth.

```text
#showtooltip Maul
/startattack [form:1,nostealth,harm,nodead]
/cast [form:1,harm,nodead] !Maul
```

### FM Claw

Template ID: druid_claw. Current enemy only. Starts melee swings even if the ability is unavailable. Requires the matching animal form; protects Prowl.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee in matching form, outside stealth.

```text
#showtooltip Claw
/startattack [form:3,nostealth,harm,nodead]
/cast [form:3,harm,nodead] Claw
```

### FM Shred

Template ID: druid_shred. Current enemy only. Starts melee swings even if the ability is unavailable. Requires the matching animal form; protects Prowl.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee in matching form, outside stealth.

```text
#showtooltip Shred
/startattack [form:3,nostealth,harm,nodead]
/cast [form:3,harm,nodead] Shred
```

### FM Rake

Template ID: druid_rake. Current enemy only. Starts melee swings even when the spell cannot cast. Requires the matching form; protects Prowl.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee in matching form, outside stealth.

```text
#showtooltip Rake
/startattack [form:3,nostealth,harm,nodead]
/cast [form:3,harm,nodead] Rake
```

### FM Rip

Template ID: druid_rip. Current enemy only. Starts melee swings even when the spell cannot cast. Requires the matching form; protects Prowl.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee in matching form, outside stealth.

```text
#showtooltip Rip
/startattack [form:3,nostealth,harm,nodead]
/cast [form:3,harm,nodead] Rip
```

### FM FeroBite

Template ID: druid_ferocious. Current enemy only. Starts melee swings even when the spell cannot cast. Requires the matching form; protects Prowl.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee in matching form, outside stealth.

```text
#showtooltip Ferocious Bite
/startattack [form:3,nostealth,harm,nodead]
/cast [form:3,harm,nodead] Ferocious Bite
```

### FM Swipe

Template ID: druid_swipe. Current enemy only. Starts melee swings even when the spell cannot cast. Requires the matching form; protects Prowl.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee in matching form, outside stealth.

```text
#showtooltip Swipe
/startattack [form:1,nostealth,harm,nodead]
/cast [form:1,harm,nodead] Swipe
```

### FM PrimalBite

Template ID: druid_primalbite. Current enemy only. Starts melee swings even when the spell cannot cast. Requires the matching form; protects Prowl.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee in matching form, outside stealth.

```text
#showtooltip Primal Bite
/startattack [form:1,nostealth,harm,nodead]
/cast [form:1,harm,nodead] Primal Bite
```

### FM ShiftingPower

Template ID: druid_shiftingpower. Use Shifting Power while already in Cat Form. Spends mana for energy. The game rejects it at full energy. Does not shift forms or start attacks.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shifting Power
/cast [form:3] Shifting Power
```

### FM Wrath

Template ID: druid_wrath. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Wrath
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Wrath
```

### FM Starfire

Template ID: druid_starfire. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Starfire
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Starfire
```

### FM Moonfire

Template ID: druid_moonfire. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Moonfire
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Moonfire
```

### FM MarkWild

Template ID: druid_mark. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Mark of the Wild
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Mark of the Wild
```

### FM Thorns

Template ID: druid_thorns. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Thorns
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Thorns
```

### FM ShiftRegrow

Template ID: druid_regrowth_shift. Leave animal form, then heal a friendly mouseover, target, or self. Costs the form and heal mana when shifting back.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Regrowth
/cancelform
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Regrowth
```

### FM Prowl

Template ID: druid_prowl. Stop attacking and enter Prowl only while already in Cat Form outside combat. Repeated presses leave Prowl active. Does not shift forms.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks; enter stealth in Cat Form.

```text
#showtooltip Prowl
/stopattack
/cast [form:3,nocombat,nostealth] !Prowl
```

### FM Dash

Template ID: druid_dash. Use Dash while already in Cat Form. Does not shift forms, cancel Prowl, or start attacks.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Dash
/cast [form:3] Dash
```

### FM Growl

Template ID: druid_growl. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Growl
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Growl
```

### FM FeralCharge

Template ID: druid_feralcharge. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Feral Charge
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Feral Charge
```

### FM Tranquility

Template ID: druid_tranquility. Press to attempt Tranquility. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Tranquility
/cast [nochanneling] Tranquility
```

### FM AutoOpen

Template ID: auto_druid_open. Caster-form ranged opener. Change form manually afterward. Learned steps only. One press per cast; stops at the end. Alt resets. Changing target or leaving combat also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/castsequence [noform,harm,nodead] reset=target/combat/alt Wrath,Moonfire,null
```

### FM AutoPrep

Template ID: auto_druid_prep. Self preparation outside combat in caster form. Learned steps only. One press per cast; stops at the end. Alt resets. Ten seconds without pressing also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/stopmacro [combat]
/castsequence [noform,@player] reset=10/alt Mark of the Wild,Thorns,null
```

### FM AutoCat

Template ID: auto_druid_cat. Cat opener outside Prowl. Use stealth openers and combo-point finishers separately. Learned steps only. One press per cast; stops at the end. Alt resets. Changing target or leaving combat also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy with form and stealth guards.

```text
#showtooltip
/stopmacro [channeling]
/startattack [form:3,nostealth,harm,nodead]
/castsequence [form:3,nostealth,harm,nodead] reset=target/combat/alt Rake,Claw,null
```

### FM AutoBear

Template ID: auto_druid_bear. Bear multi-target opener. Swipe can hit nearby enemies; use only when that is intended. Learned steps only. One press per cast; stops at the end. Alt resets. Changing target or leaving combat also resets. A fixed starter, not a live optimal rotation.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Melee on current enemy with form and stealth guards.

```text
#showtooltip
/stopmacro [channeling]
/startattack [form:1,harm,nodead]
/castsequence [form:1,harm,nodead] reset=target/combat/alt Demoralizing Roar,Swipe,null
```

## HUNTER

### FM PetAttack

Template ID: HUNTER_pet_attack. Send your pet to the living hostile mouseover, otherwise target.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Pet attack only.

```text
/petattack [@mouseover,harm,nodead][harm,nodead]
```

### FM PetFollow

Template ID: HUNTER_pet_follow. Set your pet passive and call it back. It stays passive afterward.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
/petpassive
/petfollow
```

### FM MarkPet

Template ID: hunter_mark. Mark and send your pet to the same chosen enemy.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Pet attack only.

```text
#showtooltip Hunter's Mark
/cast [@mouseover,harm,nodead][harm,nodead] Hunter's Mark
/petattack [@mouseover,harm,nodead][harm,nodead]
```

### FM AutoShot

Template ID: hunter_auto. Start Auto Shot and send your pet to your current enemy.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot and pet on current enemy.

```text
#showtooltip Auto Shot
/cast [harm,nodead] !Auto Shot
/petattack [harm,nodead]
```

### FM Concuss

Template ID: hunter_concussive. Shift-focus, then hostile mouseover, then target. Only the target branch starts Auto Shot.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot on target branch only.

```text
#showtooltip Concussive Shot
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Concussive Shot
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/cast [harm,nodead] !Auto Shot
```

### FM MendPet

Template ID: hunter_mend. Mend your living pet.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Mend Pet
/cast [@pet,exists,nodead] Mend Pet
```

### FM RevivePet

Template ID: hunter_revive. Revive your pet with the normal spell targeting rules.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Revive Pet
/cast  Revive Pet
```

### FM CallPet

Template ID: hunter_call. Call your pet when none is present.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Call Pet
/cast [nopet] Call Pet
```

### FM Raptor

Template ID: hunter_raptor. Start melee attacking and attempt Raptor Strike on your target.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Raptor Strike
/startattack [harm,nodead]
/cast [harm,nodead] !Raptor Strike
```

### FM Feign

Template ID: hunter_feign. Stop attacking, recall your pet in passive mode, then attempt Feign Death.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Stop attacks.

```text
#showtooltip Feign Death
/stopcasting
/stopattack
/petpassive
/petfollow
/cast  Feign Death
```

### FM HuntSeq

Template ID: hunter_sequence. Press repeatedly: Serpent Sting, then three Arcane Shots. Waits on cooldowns. Alt resets; use MarkPet separately.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot and pet on current enemy.

```text
#showtooltip
/petattack [harm,nodead]
/cast [harm,nodead] !Auto Shot
/castsequence [harm,nodead] reset=target/combat/alt Serpent Sting, Arcane Shot, Arcane Shot, Arcane Shot
```

### FM Scatter

Template ID: hunter_scatter. Shift: focus. Otherwise hostile mouseover, then target. Stops your attacks for crowd control.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Scatter Shot
/stopcasting
/stopattack
/petpassive
/petfollow
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Scatter Shot
/stopattack
```

### FM WingClip

Template ID: hunter_wingclip. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Wing Clip
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Wing Clip
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM Intimidate

Template ID: hunter_intimidation. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Intimidation
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Intimidation
```

### FM Deterrence

Template ID: hunter_deterrence. Press to attempt Deterrence. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Deterrence
/stopcasting
/cast  Deterrence
```

### FM FreezeTrap

Template ID: hunter_freezing. Stop attacking and recall your pet in passive mode before attempting Freezing Trap.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks and recall pet.

```text
#showtooltip Freezing Trap
/stopattack
/petpassive
/petfollow
/cast  Freezing Trap
```

### FM FrostTrap

Template ID: hunter_frost. Press to attempt Frost Trap. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Frost Trap
/cast  Frost Trap
```

### FM ViperSting

Template ID: hunter_viper. Shift-focus, then hostile mouseover, then target. Only the target branch starts Auto Shot.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Ranged Auto Shot on target branch only.

```text
#showtooltip Viper Sting
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Viper Sting
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/cast [harm,nodead] !Auto Shot
```

### FM TranqShot

Template ID: hunter_tranq. Shift-focus, then hostile mouseover, then target. Only the target branch starts Auto Shot.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Ranged Auto Shot on target branch only.

```text
#showtooltip Tranquilizing Shot
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Tranquilizing Shot
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/cast [harm,nodead] !Auto Shot
```

### FM Mongoose

Template ID: hunter_mongoose. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Mongoose Bite
/startattack [harm,nodead]
/cast [harm,nodead] Mongoose Bite
```

### FM ArcaneShot

Template ID: hunter_arcane. Current enemy only. Starts ranged Auto Shot and attempts the shot. Does not send your pet.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot on current enemy.

```text
#showtooltip Arcane Shot
/cast [harm,nodead] !Auto Shot
/cast [harm,nodead] Arcane Shot
```

### FM SerpentSting

Template ID: hunter_serpent. Current enemy only. Starts ranged Auto Shot and attempts the shot. Does not send your pet.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot on current enemy.

```text
#showtooltip Serpent Sting
/cast [harm,nodead] !Auto Shot
/cast [harm,nodead] Serpent Sting
```

### FM AimedShot

Template ID: hunter_aimed. Current enemy only. Starts Auto Shot without toggling it off. Does not send your pet.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot on current enemy.

```text
#showtooltip Aimed Shot
/cast [harm,nodead] !Auto Shot
/cast [harm,nodead] Aimed Shot
```

### FM MultiShot

Template ID: hunter_multi. Current enemy only. Starts Auto Shot without toggling it off. Does not send your pet.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot on current enemy.

```text
#showtooltip Multi-Shot
/cast [harm,nodead] !Auto Shot
/cast [harm,nodead] Multi-Shot
```

### FM ScorpidSting

Template ID: hunter_scorpid. Current enemy only. Starts Auto Shot without toggling it off. Does not send your pet.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot on current enemy.

```text
#showtooltip Scorpid Sting
/cast [harm,nodead] !Auto Shot
/cast [harm,nodead] Scorpid Sting
```

### FM DistractShot

Template ID: hunter_distracting. Current enemy only. Starts Auto Shot without toggling it off. Does not send your pet.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot on current enemy.

```text
#showtooltip Distracting Shot
/cast [harm,nodead] !Auto Shot
/cast [harm,nodead] Distracting Shot
```

### FM SniperShot

Template ID: hunter_sniper. Current enemy only. Starts Auto Shot without toggling it off. Does not send your pet.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot on current enemy.

```text
#showtooltip Sniper Shot
/cast [harm,nodead] !Auto Shot
/cast [harm,nodead] Sniper Shot
```

### FM SummonHawk

Template ID: hunter_summonhawk. Current enemy only. Starts Auto Shot without toggling it off. Does not send your pet.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot on current enemy.

```text
#showtooltip Summon Hawk
/cast [harm,nodead] !Auto Shot
/cast [harm,nodead] Summon Hawk
```

### FM StriderKick

Template ID: hunter_strider. Current enemy only. Starts melee swings even when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Strider Kick
/startattack [harm,nodead]
/cast [harm,nodead] Strider Kick
```

### FM Counteratk

Template ID: hunter_counterattack. Current enemy only. Starts melee swings even when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Counterattack
/startattack [harm,nodead]
/cast [harm,nodead] Counterattack
```

### FM Volley

Template ID: hunter_volley. Place Volley at the cursor. No Auto Shot to interrupt the channel.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Volley
/cast [@cursor] Volley
```

### FM Flare

Template ID: hunter_flare. Press to attempt Flare. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Flare
/cast [@cursor] Flare
```

### FM ImmoTrap

Template ID: hunter_immolation. Press to attempt Immolation Trap. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Immolation Trap
/cast  Immolation Trap
```

### FM ExplodeTrap

Template ID: hunter_explosive. Press to attempt Explosive Trap. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Explosive Trap
/cast  Explosive Trap
```

### FM RapidFire

Template ID: hunter_rapidfire. Press to attempt Rapid Fire. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Rapid Fire
/cast  Rapid Fire
```

### FM BestialWrath

Template ID: hunter_bestial. Press to attempt Bestial Wrath. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Bestial Wrath
/cast  Bestial Wrath
```

### FM Disengage

Template ID: hunter_disengage. Stop attacking and attempt the Classic threat-reduction ability on your enemy. This is not a backward leap.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks.

```text
#showtooltip Disengage
/stopattack
/cast [harm,nodead] Disengage
```

### FM FeignTrap

Template ID: hunter_fdtrap. Press for Freezing Trap. Alt: Feign Death. Separate choices; Forever traps can be placed in combat.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks and recall pet.

```text
#showtooltip
/stopcasting
/stopattack
/petpassive
/petfollow
/cast [mod:alt] Feign Death; Freezing Trap
```

### FM MeleeWeave

Template ID: hunter_melee. Stop your cast and attempt Raptor Strike and Mongoose Bite. Cooldowns and the global cooldown still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Raptor Strike
/stopcasting
/startattack [harm,nodead]
/cast [harm,nodead] !Raptor Strike
/cast [harm,nodead] Mongoose Bite
```

### FM MarkShot

Template ID: hunter_markshot. Mark your current enemy, start Auto Shot, and send your pet.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Ranged Auto Shot and pet on current enemy.

```text
#showtooltip Hunter's Mark
/cast [harm,nodead] !Auto Shot
/cast [harm,nodead] Hunter's Mark
/petattack [harm,nodead]
```

### FM Hawk

Template ID: hunter_hawk. Press to attempt Aspect of the Hawk. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Aspect of the Hawk
/cast !Aspect of the Hawk
```

### FM Monkey

Template ID: hunter_monkey. Press to attempt Aspect of the Monkey. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Aspect of the Monkey
/cast !Aspect of the Monkey
```

### FM Cheetah

Template ID: hunter_cheetah. Press to attempt Aspect of the Cheetah. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Aspect of the Cheetah
/cast !Aspect of the Cheetah
```

### FM Pack

Template ID: hunter_pack. Press to attempt Aspect of the Pack. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Aspect of the Pack
/cast !Aspect of the Pack
```

### FM Wild

Template ID: hunter_wild. Press to attempt Aspect of the Wild. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Aspect of the Wild
/cast !Aspect of the Wild
```

### FM Beast

Template ID: hunter_beast. Press to attempt Aspect of the Beast. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Aspect of the Beast
/cast !Aspect of the Beast
```

### FM Trueshot

Template ID: hunter_trueshot. Press to attempt Trueshot Aura. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Trueshot Aura
/cast !Trueshot Aura
```

### FM TrackBeasts

Template ID: hunter_track_beasts. Press to attempt Track Beasts. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Track Beasts
/cast  Track Beasts
```

### FM TrackHumans

Template ID: hunter_track_humanoids. Press to attempt Track Humanoids. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Track Humanoids
/cast  Track Humanoids
```

### FM TrackHidden

Template ID: hunter_track_hidden. Press to attempt Track Hidden. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Track Hidden
/cast  Track Hidden
```

### FM TrackUndead

Template ID: hunter_track_undead. Press to attempt Track Undead. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Track Undead
/cast  Track Undead
```

### FM TrackDemons

Template ID: hunter_track_demons. Press to attempt Track Demons. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Track Demons
/cast  Track Demons
```

### FM TrackElem

Template ID: hunter_track_elementals. Press to attempt Track Elementals. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Track Elementals
/cast  Track Elementals
```

### FM TrackGiants

Template ID: hunter_track_giants. Press to attempt Track Giants. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Track Giants
/cast  Track Giants
```

### FM TrackDragons

Template ID: hunter_track_dragonkin. Press to attempt Track Dragonkin. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Track Dragonkin
/cast  Track Dragonkin
```

### FM EyesBeast

Template ID: hunter_eyes. Press to attempt Eyes of the Beast. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Eyes of the Beast
/cast  Eyes of the Beast
```

### FM EagleEye

Template ID: hunter_eagle. Press to attempt Eagle Eye. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Eagle Eye
/cast  Eagle Eye
```

### FM TameBeast

Template ID: hunter_tame. Press to attempt Tame Beast. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Tame Beast
/cast  Tame Beast
```

### FM DismissPet

Template ID: hunter_dismiss. Press to attempt Dismiss Pet. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Dismiss Pet
/cast  Dismiss Pet
```

### FM FeedPet

Template ID: hunter_feed. Activate Feed Pet, then click suitable food in your bag.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Feed Pet
/cast  Feed Pet
```

### FM ScareBeast

Template ID: hunter_scare. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks and recall pet.

```text
#showtooltip Scare Beast
/stopattack
/petpassive
/petfollow
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Scare Beast
```

### FM PetDash

Template ID: hunter_pet_dash. Press to attempt Dash. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Dash
/cast  Dash
```

### FM PetDive

Template ID: hunter_pet_dive. Press to attempt Dive. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Dive
/cast  Dive
```

### FM PetCharge

Template ID: hunter_pet_charge. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Charge
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Charge
```

### FM PetGrowl

Template ID: hunter_pet_growl. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Growl
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Growl
```

### FM PetCower

Template ID: hunter_pet_cower. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Cower
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Cower
```

### FM PetBite

Template ID: hunter_pet_bite. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Bite
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Bite
```

### FM PetClaw

Template ID: hunter_pet_claw. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Claw
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Claw
```

### FM PetScreech

Template ID: hunter_pet_screech. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Demoralizing Screech
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Demoralizing Screech
```

### FM PetLightning

Template ID: hunter_pet_lightning. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Lightning Breath
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Lightning Breath
```

### FM PetSonic

Template ID: hunter_pet_sonic. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Sonic Blast
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Sonic Blast
```

### FM PetProwl

Template ID: hunter_pet_prowl. Press to attempt Prowl. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Prowl
/cast  Prowl
```

### FM PetSwipe

Template ID: hunter_pet_swipe. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Swipe
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Swipe
```

### FM PetWeb

Template ID: hunter_pet_web. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Web
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Web
```

### FM PetPinch

Template ID: hunter_pet_pinch. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Pinch
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Pinch
```

### FM PetDismember

Template ID: hunter_pet_dismember. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Dismember
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Dismember
```

### FM PetRend

Template ID: hunter_pet_rend. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Savage Rend
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Savage Rend
```

### FM PetTendon

Template ID: hunter_pet_tendon. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Tendon Rip
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Tendon Rip
```

### FM PetDust

Template ID: hunter_pet_dust. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Dust Cloud
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Dust Cloud
```

### FM PetDisarm

Template ID: hunter_pet_mine. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Mine!
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Mine!
```

### FM PetLava

Template ID: hunter_pet_lava. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Lava Breath
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Lava Breath
```

### FM PetPoison

Template ID: hunter_pet_poison. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Scorpid Poison
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Scorpid Poison
```

### FM PetStomp

Template ID: hunter_pet_stomp. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Thunderstomp
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Thunderstomp
```

### FM PetTrickster

Template ID: hunter_pet_trickster. Press to attempt Trickster's Dance. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Trickster's Dance
/cast  Trickster's Dance
```

### FM PetHowl

Template ID: hunter_pet_howl. Press to attempt Furious Howl. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Furious Howl
/cast  Furious Howl
```

### FM PetShell

Template ID: hunter_pet_shell. Press to attempt Shell Shield. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shell Shield
/cast  Shell Shield
```

### FM RapidTrinkets

Template ID: hunter_burst. Attempt both equipped on-use trinkets and Rapid Fire. Shared cooldowns can prevent the second trinket.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Rapid Fire
/use 13
/use 14
/cast Rapid Fire
```

### FM GrowlOn

Template ID: hunter_growl_on. Set Growl autocast for your current pet. Choose off when another player is tanking.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Growl
/petautocaston Growl
```

### FM GrowlOff

Template ID: hunter_growl_off. Set Growl autocast for your current pet. Choose off when another player is tanking.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Growl
/petautocastoff Growl
```

### FM PetStay

Template ID: hunter_pet_stay. Stop your pet and keep it at its current position.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
/petpassive
/petstay
```

### FM PetAggressive

Template ID: hunter_pet_aggressive. Set your active pet to Aggressive. It can attack nearby enemies without a target command. Choose this mode manually.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Pet chooses nearby enemies after activation.

```text
/petaggressive [pet]
```

### FM Easy

Template ID: auto_hunter_easy. Pet + Auto Shot. Cycle Sting and three Arcanes; with Summon Hawk, Sting, two Hawks, Arcane. Shared cooldowns pause casting. Aspect, Mend Pet and Aimed Shot stay separate. Repeat presses. Target/combat end/Alt resets. Mana, range or cooldowns may pause a step. Fixed routine.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Pet attack and learned Auto Shot on current living enemy.

```text
#showtooltip
/stopmacro [channeling][noharm][dead]
/petattack
/cast !Auto Shot
/castsequence reset=target/combat/alt Serpent Sting,Summon Hawk,Summon Hawk,Arcane Shot
```

### FM AutoOpen

Template ID: auto_hunter_open. Ranged opener. Auto Shot starts if learned; send your pet separately. Learned steps only. One press per cast; stops at the end. Alt resets. Changing target or leaving combat also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged Auto Shot if learned; no pet command.

```text
#showtooltip
/stopmacro [channeling]
/cast [harm,nodead] !Auto Shot
/castsequence [harm,nodead] reset=target/combat/alt Serpent Sting,Arcane Shot,null
```

### FM AutoPrep

Template ID: auto_hunter_prep. Ranged preparation. Change aspect manually for travel or melee. Learned steps only. One press per cast; stops at the end. Alt resets. Ten seconds without pressing also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/stopmacro [combat]
/castsequence [@player] reset=10/alt Aspect of the Hawk,null
```

## MAGE

### FM Counter

Template ID: mage_counterspell. Interrupt your own cast and attempt Counterspell.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Counterspell
/stopcasting
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Counterspell
```

### FM Polymorph

Template ID: mage_polymorph. Polymorph a hostile mouseover, target, or Shift-focus. Stops your attacks for crowd control.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Polymorph
/stopattack
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Polymorph
/stopattack
```

### FM Decurse

Template ID: mage_decurse. Remove Lesser Curse from mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Remove Lesser Curse
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Remove Lesser Curse
```

### FM Blink

Template ID: mage_blink. Interrupt your own cast and attempt Blink.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Blink
/stopcasting
/cast  Blink
```

### FM Blizzard

Template ID: mage_blizzard. Place Blizzard at the mouse cursor when the spell supports it.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Blizzard
/cast [@cursor] Blizzard
```

### FM FrostNova

Template ID: mage_nova. Press to attempt Frost Nova. Spell requirements still apply. Stops your attacks for crowd control.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Frost Nova
/stopattack
/stopcasting
/cast  Frost Nova
/stopattack
```

### FM IceBlock

Template ID: mage_iceblock. Press to attempt Ice Block. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Ice Block
/stopcasting
/cast  Ice Block
```

### FM IceBarrier

Template ID: mage_barrier. Press to attempt Ice Barrier. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Ice Barrier
/cast  Ice Barrier
```

### FM ColdSnap

Template ID: mage_cold. Press to attempt Cold Snap. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Cold Snap
/cast  Cold Snap
```

### FM FireBlast

Template ID: mage_fireblast. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Fire Blast
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Fire Blast
```

### FM Frostbolt

Template ID: mage_frostbolt. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Frostbolt
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Frostbolt
```

### FM Wand

Template ID: mage_wand. Attempt wand shooting at your current enemy with !Shoot. Repeat-press behavior has an open Forever beta bug report; test it on your build. Use this separate button between spells.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged wand Shoot on current enemy.

```text
#showtooltip Shoot
/cast [harm,nodead] !Shoot
```

### FM Fireball

Template ID: mage_fireball. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Fireball
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Fireball
```

### FM Scorch

Template ID: mage_scorch. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Scorch
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Scorch
```

### FM Missiles

Template ID: mage_missiles. Cast at your current enemy only when not channeling. Prevents early channel clipping.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Arcane Missiles
/cast [nochanneling,harm,nodead] Arcane Missiles
```

### FM Flamestrike

Template ID: mage_flamestrike. Press to attempt Flamestrike. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Flamestrike
/cast [@cursor] Flamestrike
```

### FM ArcExplosion

Template ID: mage_explosion. Press to attempt Arcane Explosion. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Arcane Explosion
/cast  Arcane Explosion
```

### FM ConeCold

Template ID: mage_cone. Press to attempt Cone of Cold. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Cone of Cold
/cast  Cone of Cold
```

### FM Intellect

Template ID: mage_intellect. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Arcane Intellect
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Arcane Intellect
```

### FM Dampen

Template ID: mage_dampen. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Dampen Magic
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Dampen Magic
```

### FM Amplify

Template ID: mage_amplify. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Amplify Magic
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Amplify Magic
```

### FM Evocation

Template ID: mage_evocation. Press to attempt Evocation. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Evocation
/cast [nochanneling] Evocation
```

### FM Conjure

Template ID: mage_conjure. Conjure water. Hold Shift for food. Uses the highest learned rank.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/cast [mod:shift] Conjure Food; Conjure Water
```

### FM CancelBlock

Template ID: mage_cancelblock. Cancel your Ice Block aura. This button does not cast it.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Ice Block
/cancelaura Ice Block
```

### FM AutoOpen

Template ID: auto_mage_open. Ranged solo pull using the learned slow when available. Continue with your chosen filler afterward. Learned steps only. One press per cast; stops at the end. Alt resets. Changing target or leaving combat also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/castsequence [harm,nodead] reset=target/combat/alt Frostbolt,null
```

### FM AutoPrep

Template ID: auto_mage_prep. Solo preparation. Uses Ice Armor when learned; choose Mage Armor separately if preferred. Learned steps only. One press per cast; stops at the end. Alt resets. Ten seconds without pressing also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/stopmacro [combat]
/castsequence [@player] reset=10/alt Arcane Intellect,Ice Armor,null
```

## PALADIN

### FM HolyLight

Template ID: paladin_holy. Holy Light on mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Holy Light
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Holy Light
```

### FM FlashLight

Template ID: paladin_flash. Flash of Light on mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Flash of Light
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Flash of Light
```

### FM Purify

Template ID: paladin_purify. Purify mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Purify
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Purify
```

### FM Cleanse

Template ID: paladin_cleanse. Cleanse mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Cleanse
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Cleanse
```

### FM Freedom

Template ID: paladin_freedom. Blessing of Freedom on mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Blessing of Freedom
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Blessing of Freedom
```

### FM Hammer

Template ID: paladin_hammer. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Hammer of Justice
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Hammer of Justice
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM Redemption

Template ID: paladin_res. Redemption on a dead friendly mouseover or target.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Redemption
/cast [@mouseover,help,dead][help,dead] Redemption
```

### FM Protection

Template ID: paladin_protection. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Blessing of Protection
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Blessing of Protection
```

### FM Sacrifice

Template ID: paladin_sacrifice. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Blessing of Sacrifice
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Blessing of Sacrifice
```

### FM DivineShield

Template ID: paladin_bubble. Press to attempt Divine Shield. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Divine Shield
/stopcasting
/cast  Divine Shield
```

### FM LayHands

Template ID: paladin_layhands. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Lay on Hands
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Lay on Hands
```

### FM Repentance

Template ID: paladin_repentance. Shift: focus. Otherwise hostile mouseover, then target. Stops your attacks for crowd control.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Repentance
/stopattack
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Repentance
/stopattack
```

### FM Judgement

Template ID: paladin_judgement. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Judgement
/startattack [harm,nodead]
/cast [harm,nodead] Judgement
```

### FM HolyStrike

Template ID: paladin_holystrike. Current enemy only. Starts melee swings even when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Holy Strike
/startattack [harm,nodead]
/cast [harm,nodead] Holy Strike
```

### FM Consecrate

Template ID: paladin_consecration. Attempt Consecration at your feet. Also start melee swings at a living selected enemy, even if the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Consecration
/cast  Consecration
/startattack [harm,nodead]
```

### FM Exorcism

Template ID: paladin_exorcism. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings, including when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Exorcism
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Exorcism
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM HammerWrath

Template ID: paladin_wrath. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings, including when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Hammer of Wrath
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Hammer of Wrath
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM HolyShock

Template ID: paladin_holyshock. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Holy Shock
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Holy Shock
```

### FM ShockEnemy

Template ID: paladin_holyshock_enemy. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings, including when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Holy Shock
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Holy Shock
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM Might

Template ID: paladin_might. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Blessing of Might
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Blessing of Might
```

### FM Wisdom

Template ID: paladin_wisdom. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Blessing of Wisdom
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Blessing of Wisdom
```

### FM Kings

Template ID: paladin_kings. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Blessing of Kings
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Blessing of Kings
```

### FM SealRight

Template ID: paladin_sealright. Press to attempt Seal of Righteousness. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Seal of Righteousness
/cast  Seal of Righteousness
```

### FM SealCommand

Template ID: paladin_sealcommand. Press to attempt Seal of Command. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Seal of Command
/cast  Seal of Command
```

### FM SealWisdom

Template ID: paladin_sealwisdom. Press to attempt Seal of Wisdom. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Seal of Wisdom
/cast  Seal of Wisdom
```

### FM SealLight

Template ID: paladin_seallight. Press to attempt Seal of Light. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Seal of Light
/cast  Seal of Light
```

### FM CancelBubble

Template ID: paladin_cancelbubble. Cancel your Divine Shield aura. This button does not cast it.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Divine Shield
/cancelaura Divine Shield
```

### FM Easy

Template ID: auto_paladin_easy. Righteousness once per target, melee, then Judgement and Holy Strike. Off-GCD Judgement preserves the seal. Buff with FM AutoPrep. Reset after manually changing your seal. Repeat presses. Target/combat end/Alt resets. Mana, range or cooldowns may pause a step. Fixed routine.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current living enemy.

```text
#showtooltip
/stopmacro [channeling][noharm][dead]
/castsequence [@player] reset=target/combat/alt Seal of Righteousness,null
/startattack
/cast Judgement
/cast Holy Strike
```

### FM AutoOpen

Template ID: auto_paladin_open. Seal then judge on a living enemy. Forever Judgement does not consume the seal. Learned steps only. One press per cast; stops at the end. Alt resets. Changing target or leaving combat also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy with form and stealth guards.

```text
#showtooltip
/stopmacro [channeling]
/startattack [harm,nodead]
/castsequence [harm,nodead] reset=target/combat/alt Seal of Righteousness,Judgement,null
```

### FM AutoPrep

Template ID: auto_paladin_prep. Solo melee preparation. Other blessings or auras may suit your group better. Learned steps only. One press per cast; stops at the end. Alt resets. Ten seconds without pressing also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/stopmacro [combat]
/castsequence [@player] reset=10/alt Blessing of Might,Devotion Aura,null
```

## PRIEST

### FM LesserHeal

Template ID: priest_lesser. Heal mouseover, friendly target, or yourself; Alt forces self.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Lesser Heal
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Lesser Heal
```

### FM Heal

Template ID: priest_heal. Heal mouseover, friendly target, or yourself; Alt forces self.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Heal
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Heal
```

### FM FlashHeal

Template ID: priest_flash. Flash Heal mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Flash Heal
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Flash Heal
```

### FM Shield

Template ID: priest_shield. Shield mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Power Word: Shield
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Power Word: Shield
```

### FM Renew

Template ID: priest_renew. Renew mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Renew
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Renew
```

### FM Dispel

Template ID: priest_dispel. Friendly Dispel Magic on mouseover, target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Dispel Magic
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Dispel Magic
```

### FM Resurrect

Template ID: priest_res. Resurrect a dead friendly mouseover or target.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Resurrection
/cast [@mouseover,help,dead][help,dead] Resurrection
```

### FM PurgeMagic

Template ID: priest_offdispel. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Dispel Magic
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Dispel Magic
```

### FM CureDisease

Template ID: priest_cure. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Cure Disease
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Cure Disease
```

### FM AbolDisease

Template ID: priest_abolish. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Abolish Disease
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Abolish Disease
```

### FM PsychScream

Template ID: priest_fear. Press to attempt Psychic Scream. Spell requirements still apply. Stops your attacks for crowd control.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Psychic Scream
/stopattack
/stopcasting
/cast  Psychic Scream
/stopattack
```

### FM Silence

Template ID: priest_silence. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Silence
/stopcasting
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Silence
```

### FM MindControl

Template ID: priest_mindcontrol. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Mind Control
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Mind Control
```

### FM Wand

Template ID: priest_wand. Attempt wand shooting at your current enemy with !Shoot. Repeat-press behavior has an open Forever beta bug report; test it on your build. Use this separate button between spells.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged wand Shoot on current enemy.

```text
#showtooltip Shoot
/cast [harm,nodead] !Shoot
```

### FM Smite

Template ID: priest_smite. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Smite
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Smite
```

### FM HolyFire

Template ID: priest_holyfire. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Holy Fire
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Holy Fire
```

### FM ShadowPain

Template ID: priest_pain. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shadow Word: Pain
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Shadow Word: Pain
```

### FM MindBlast

Template ID: priest_mindblast. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Mind Blast
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Mind Blast
```

### FM ManaBurn

Template ID: priest_manaburn. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Mana Burn
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Mana Burn
```

### FM MindFlay

Template ID: priest_flay. Press to attempt Mind Flay. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Mind Flay
/cast [nochanneling,harm,nodead] Mind Flay
```

### FM PenanceHeal

Template ID: priest_penance_heal. Heal with Penance. Alt: self, then friendly mouseover, target, self. Supports teammate assignment. Waits for any current channel to finish.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Penance
/stopmacro [channeling]
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Penance
```

### FM PenanceHarm

Template ID: priest_penance_harm. Damage with Penance. Shift: hostile focus, then hostile mouseover, target. Waits for any current channel to finish. Does not start melee or wand attacks.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Penance
/stopmacro [channeling]
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Penance
```

### FM GreaterHeal

Template ID: priest_greater. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Greater Heal
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Greater Heal
```

### FM Fortitude

Template ID: priest_fortitude. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Power Word: Fortitude
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Power Word: Fortitude
```

### FM DivineSpirit

Template ID: priest_spirit. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Divine Spirit
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Divine Spirit
```

### FM ShadowProt

Template ID: priest_shadowprotect. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Shadow Protection
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Shadow Protection
```

### FM PowerInfuse

Template ID: priest_powerinfuse. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Power Infusion
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Power Infusion
```

### FM Shackle

Template ID: priest_shackle. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Shackle Undead
/stopattack
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Shackle Undead
```

### FM Fade

Template ID: priest_fade. Press to attempt Fade. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Fade
/cast  Fade
```

### FM Easy

Template ID: auto_priest_easy. Self shield once per target, then Penance/Mind Blast, Pain and four Smites. Learning Mind Flay switches to shadow spells. Channels protected; use a separate wand key to conserve mana. Repeat presses. Target/combat end/Alt resets. Mana, range or cooldowns may pause a step. Fixed routine.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling][noharm][dead]
/castsequence [@player] reset=target/combat/alt Power Word: Shield,null
/castsequence reset=target/combat/alt Mind Blast,Shadow Word: Pain,Mind Flay,Mind Flay,Mind Flay,Mind Flay
```

### FM AutoOpen

Template ID: auto_priest_open. Caster opener before wand or filler attacks. Use shadow attacks separately in Shadowform. Learned steps only. One press per cast; stops at the end. Alt resets. Changing target or leaving combat also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/castsequence [noform,harm,nodead] reset=target/combat/alt Holy Fire,Shadow Word: Pain,null
```

### FM AutoPrep

Template ID: auto_priest_prep. Self preparation outside combat. Learned steps only. One press per cast; stops at the end. Alt resets. Ten seconds without pressing also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/stopmacro [combat]
/castsequence [@player] reset=10/alt Power Word: Fortitude,Inner Fire,null
```

## ROGUE

### FM Kick

Template ID: rogue_kick. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Kick
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Kick
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [nostealth,harm,nodead]
```

### FM Blind

Template ID: rogue_blind. Blind a hostile mouseover, target, or Shift-focus. Stops your attacks for crowd control.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Blind
/stopattack
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Blind
/stopattack
```

### FM Sap

Template ID: rogue_sap. Sap a hostile mouseover, target, or Shift-focus when usable. Stops your attacks for crowd control.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Sap
/stopattack
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Sap
/stopattack
```

### FM Sinister

Template ID: rogue_sinister. Attempt Sinister Strike on your target. Start melee swings when not stealthed, even if energy is low.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Sinister Strike
/startattack [nostealth,harm,nodead]
/cast [harm,nodead] Sinister Strike
```

### FM Stealth

Template ID: rogue_stealth. Enter Stealth without toggling it off on repeat presses.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Stealth
/cast !Stealth
```

### FM Gouge

Template ID: rogue_gouge. Shift: focus. Otherwise hostile mouseover, then target. Stops your attacks for crowd control.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Gouge
/stopattack
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Gouge
/stopattack
```

### FM Kidney

Template ID: rogue_kidney. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Kidney Shot
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Kidney Shot
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [nostealth,harm,nodead]
```

### FM CheapShot

Template ID: rogue_cheap. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Cheap Shot
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Cheap Shot
```

### FM Vanish

Template ID: rogue_vanish. Press to attempt Vanish. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks.

```text
#showtooltip Vanish
/stopattack
/cast  Vanish
```

### FM Evasion

Template ID: rogue_evasion. Press to attempt Evasion. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Evasion
/cast  Evasion
```

### FM Sprint

Template ID: rogue_sprint. Press to attempt Sprint. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Sprint
/cast  Sprint
```

### FM Distract

Template ID: rogue_distract. Press to attempt Distract. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Distract
/cast [@cursor] Distract
```

### FM Backstab

Template ID: rogue_backstab. Current enemy only. Starts melee swings even if the ability is unavailable. Protects Stealth on a failed cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Backstab
/startattack [nostealth,harm,nodead]
/cast [harm,nodead] Backstab
```

### FM Eviscerate

Template ID: rogue_eviscerate. Current enemy only. Starts melee swings even if the ability is unavailable. Protects Stealth on a failed cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Eviscerate
/startattack [nostealth,harm,nodead]
/cast [harm,nodead] Eviscerate
```

### FM Hemorrhage

Template ID: rogue_hemorrhage. Current enemy only. Starts melee swings even if the ability is unavailable. Protects Stealth on a failed cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Hemorrhage
/startattack [nostealth,harm,nodead]
/cast [harm,nodead] Hemorrhage
```

### FM Rupture

Template ID: rogue_rupture. Current enemy only. Starts melee swings even when the spell cannot cast. Protects Stealth on failed casts.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Rupture
/startattack [nostealth,harm,nodead]
/cast [harm,nodead] Rupture
```

### FM Riposte

Template ID: rogue_riposte. Current enemy only. Starts melee swings even when the spell cannot cast. Protects Stealth on failed casts.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Riposte
/startattack [nostealth,harm,nodead]
/cast [harm,nodead] Riposte
```

### FM ExposeArmor

Template ID: rogue_expose. Current enemy only. Starts melee swings even when the spell cannot cast. Protects Stealth on failed casts.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Expose Armor
/startattack [nostealth,harm,nodead]
/cast [harm,nodead] Expose Armor
```

### FM SliceDice

Template ID: rogue_slice. Current enemy only. Starts melee swings even when the spell cannot cast. Protects Stealth on failed casts.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Slice and Dice
/startattack [nostealth,harm,nodead]
/cast [harm,nodead] Slice and Dice
```

### FM Mutilate

Template ID: rogue_mutilate. Current enemy only. Starts melee swings even when the spell cannot cast. Protects Stealth on failed casts.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Mutilate
/startattack [nostealth,harm,nodead]
/cast [harm,nodead] Mutilate
```

### FM Venom

Template ID: rogue_venom. Current enemy only. Starts melee swings even when the spell cannot cast. Protects Stealth on failed casts.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Venom
/startattack [nostealth,harm,nodead]
/cast [harm,nodead] Venom
```

### FM GhostlyStrike

Template ID: rogue_ghostly. Current enemy only. Starts melee swings even when the spell cannot cast. Protects Stealth on failed casts.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Ghostly Strike
/startattack [nostealth,harm,nodead]
/cast [harm,nodead] Ghostly Strike
```

### FM Ambush

Template ID: rogue_ambush. Stealthed current enemy only. No auto attack before the opener.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Ambush
/cast [stealth,harm,nodead] Ambush
```

### FM Garrote

Template ID: rogue_garrote. Stealthed current enemy only. No auto attack before the opener.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Garrote
/cast [stealth,harm,nodead] Garrote
```

### FM PickPocket

Template ID: rogue_pickpocket. Stealthed current enemy only. No auto attack before the opener.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Pick Pocket
/cast [stealth,harm,nodead] Pick Pocket
```

### FM Feint

Template ID: rogue_feint. Press to attempt Feint. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Feint
/cast [harm,nodead] Feint
```

### FM BladeFlurry

Template ID: rogue_bladeflurry. Press to attempt Blade Flurry. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Blade Flurry
/cast  Blade Flurry
```

### FM Adrenaline

Template ID: rogue_adrenaline. Press to attempt Adrenaline Rush. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Adrenaline Rush
/cast  Adrenaline Rush
```

### FM Preparation

Template ID: rogue_preparation. Press to attempt Preparation. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Preparation
/cast  Preparation
```

### FM Throw

Template ID: rogue_throw. Pull your current enemy with the matching ranged weapon. Requires that weapon and its learned skill.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Throw
/cast [harm,nodead] Throw
```

### FM ShootBow

Template ID: rogue_bow. Pull your current enemy with the matching ranged weapon. Requires that weapon and its learned skill.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shoot Bow
/cast [harm,nodead] Shoot Bow
```

### FM ShootGun

Template ID: rogue_gun. Pull your current enemy with the matching ranged weapon. Requires that weapon and its learned skill.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shoot Gun
/cast [harm,nodead] Shoot Gun
```

### FM ShootXbow

Template ID: rogue_crossbow. Pull your current enemy with the matching ranged weapon. Requires that weapon and its learned skill.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shoot Crossbow
/cast [harm,nodead] Shoot Crossbow
```

### FM AutoOpen

Template ID: auto_rogue_open. Begin outside stealth: build one combo point, then Slice and Dice. Open from stealth separately. Learned steps only. One press per cast; stops at the end. Alt resets. Changing target or leaving combat also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy with form and stealth guards.

```text
#showtooltip
/stopmacro [channeling]
/startattack [nostealth,harm,nodead]
/castsequence [nostealth,harm,nodead] reset=target/combat/alt Sinister Strike,Slice and Dice,null
```

### FM AutoPrep

Template ID: auto_rogue_prep. Enter stealth before a pull. This does not select a stealth opener. Learned steps only. One press per cast; stops at the end. Alt resets. Ten seconds without pressing also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/stopmacro [combat]
/castsequence [@player] reset=10/alt Stealth,null
```

## SHAMAN

### FM HealingWave

Template ID: shaman_heal. Healing Wave on mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Healing Wave
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Healing Wave
```

### FM LesserWave

Template ID: shaman_lesser. Lesser Healing Wave on mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Lesser Healing Wave
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Lesser Healing Wave
```

### FM ChainHeal

Template ID: shaman_chain. Chain Heal on mouseover, friendly target, or yourself.

Installation: Automatic starter. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Chain Heal
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Chain Heal
```

### FM EarthShock

Template ID: shaman_shock. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Earth Shock
/stopcasting
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Earth Shock
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM Purge

Template ID: shaman_purge. Purge a hostile mouseover, target, or Shift-focus.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Purge
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Purge
```

### FM Ancestral

Template ID: shaman_res. Ancestral Spirit on a dead friendly mouseover or target.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Ancestral Spirit
/cast [@mouseover,help,dead][help,dead] Ancestral Spirit
```

### FM CurePoison

Template ID: shaman_poison. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Cure Poison
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Cure Poison
```

### FM CureDisease

Template ID: shaman_disease. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Cure Disease
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Cure Disease
```

### FM FrostShock

Template ID: shaman_frostshock. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Frost Shock
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Frost Shock
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM Grounding

Template ID: shaman_grounding. Press to attempt Grounding Totem. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Grounding Totem
/cast  Grounding Totem
```

### FM Tremor

Template ID: shaman_tremor. Press to attempt Tremor Totem. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Tremor Totem
/cast  Tremor Totem
```

### FM Earthbind

Template ID: shaman_earthbind. Press to attempt Earthbind Totem. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Earthbind Totem
/cast  Earthbind Totem
```

### FM GhostWolf

Template ID: shaman_ghostwolf. Press to attempt Ghost Wolf. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Ghost Wolf
/cast  Ghost Wolf
```

### FM FlameShock

Template ID: shaman_flameshock. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Flame Shock
/startattack [harm,nodead]
/cast [harm,nodead] Flame Shock
```

### FM Stormstrike

Template ID: shaman_stormstrike. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Stormstrike
/startattack [harm,nodead]
/cast [harm,nodead] Stormstrike
```

### FM LightnBolt

Template ID: shaman_bolt. Current enemy only. Starts melee swings even when the spell cannot cast. Intended for melee weaving; casting can delay swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Lightning Bolt
/startattack [harm,nodead]
/cast [harm,nodead] Lightning Bolt
```

### FM ChainLightn

Template ID: shaman_chainlight. Current enemy only. Starts melee swings even when the spell cannot cast. Intended for melee weaving; casting can delay swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Chain Lightning
/startattack [harm,nodead]
/cast [harm,nodead] Chain Lightning
```

### FM LavaBurst

Template ID: shaman_lavaburst. Current enemy only. Starts melee swings even when the spell cannot cast. Intended for melee weaving; casting can delay swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Lava Burst
/startattack [harm,nodead]
/cast [harm,nodead] Lava Burst
```

### FM Riptide

Template ID: shaman_riptide. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Riptide
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Riptide
```

### FM FarSeer

Template ID: shaman_farseer. Press to attempt Rage of the Far Seer. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Rage of the Far Seer
/cast  Rage of the Far Seer
```

### FM ElemMastery

Template ID: shaman_mastery. Press to attempt Lightning Mastery. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Lightning Mastery
/cast  Lightning Mastery
```

### FM NatSwift

Template ID: shaman_swiftness. Press to attempt Nature's Swiftness. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Nature's Swiftness
/cast  Nature's Swiftness
```

### FM Searing

Template ID: shaman_searing. Press to attempt Searing Totem. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Searing Totem
/cast  Searing Totem
```

### FM Magma

Template ID: shaman_magma. Press to attempt Magma Totem. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Magma Totem
/cast  Magma Totem
```

### FM FireNova

Template ID: shaman_firenova. Press to attempt Fire Nova. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Fire Nova
/cast  Fire Nova
```

### FM ManaSpring

Template ID: shaman_manaspring. Press to attempt Mana Spring Totem. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Mana Spring Totem
/cast  Mana Spring Totem
```

### FM ManaTide

Template ID: shaman_manatide. Press to attempt Mana Tide Totem. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Mana Tide Totem
/cast  Mana Tide Totem
```

### FM HealStream

Template ID: shaman_healingstream. Press to attempt Healing Stream Totem. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Healing Stream Totem
/cast  Healing Stream Totem
```

### FM Windfury

Template ID: shaman_windfury. Press to attempt Windfury Totem. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Windfury Totem
/cast  Windfury Totem
```

### FM GraceAir

Template ID: shaman_graceair. Press to attempt Grace of Air Totem. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Grace of Air Totem
/cast  Grace of Air Totem
```

### FM Strength

Template ID: shaman_strength. Press to attempt Strength of Earth Totem. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Strength of Earth Totem
/cast  Strength of Earth Totem
```

### FM Stoneclaw

Template ID: shaman_stoneclaw. Press to attempt Stoneclaw Totem. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Stoneclaw Totem
/cast  Stoneclaw Totem
```

### FM PoisonClean

Template ID: shaman_poisonclean. Press to attempt Poison Cleansing Totem. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Poison Cleansing Totem
/cast  Poison Cleansing Totem
```

### FM DiseaseClean

Template ID: shaman_diseaseclean. Press to attempt Disease Cleansing Totem. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Disease Cleansing Totem
/cast  Disease Cleansing Totem
```

### FM Easy

Template ID: auto_shaman_easy. Shield once per target, melee, then learned Flame Shock, Stormstrike and Earth Shock. Earlier fallback: Lightning Bolt. Refreshing an active shield spends mana. Totems and weapon imbues stay separate. Repeat presses. Target/combat end/Alt resets. Mana, range or cooldowns may pause a step. Fixed routine.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current living enemy.

```text
#showtooltip
/stopmacro [channeling][noharm][dead]
/castsequence [@player] reset=target/combat/alt Lightning Shield,null
/startattack
/castsequence reset=target/combat/alt Flame Shock,Stormstrike,Earth Shock
```

### FM Totems

Template ID: auto_shaman_totems. Drops your saved Call of the Elements set with one cast. Configure that set in the game's totem bar first. Press only when you want to spend mana on that set; it is separate from FM Easy.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/cast Call of the Elements
```

### FM Recall

Template ID: auto_shaman_recall. Recall your totems on a deliberate keypress. Never recalled automatically during a pull.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/cast Totemic Recall
```

### FM AutoOpen

Template ID: auto_shaman_open. Pull with Lightning Bolt, then the learned shock. Starts melee swings when in reach. Keep interrupts separate. Learned steps only. One press per cast; stops at the end. Alt resets. Changing target or leaving combat also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy with form and stealth guards.

```text
#showtooltip
/stopmacro [channeling]
/startattack [harm,nodead]
/castsequence [harm,nodead] reset=target/combat/alt Lightning Bolt,Flame Shock,null
```

### FM AutoPrep

Template ID: auto_shaman_prep. Solo preparation. Choose other shields manually when appropriate. Learned steps only. One press per cast; stops at the end. Alt resets. Ten seconds without pressing also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/stopmacro [combat]
/castsequence [@player] reset=10/alt Lightning Shield,null
```

## WARLOCK

### FM PetAttack

Template ID: WARLOCK_pet_attack. Send your pet to the living hostile mouseover, otherwise target.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Pet attack only.

```text
/petattack [@mouseover,harm,nodead][harm,nodead]
```

### FM PetFollow

Template ID: WARLOCK_pet_follow. Set your pet passive and call it back. It stays passive afterward.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
/petpassive
/petfollow
```

### FM Fear

Template ID: warlock_fear. Fear a hostile mouseover, target, or Shift-focus. Stops your attacks for crowd control.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Fear
/stopattack
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Fear
/stopattack
```

### FM Banish

Template ID: warlock_banish. Banish a hostile mouseover, target, or Shift-focus.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Banish
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Banish
```

### FM Corruption

Template ID: warlock_corruption. Corruption on a hostile mouseover, target, or Shift-focus.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Corruption
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Corruption
```

### FM Agony

Template ID: warlock_agony. Bane of Agony on a hostile mouseover, target, or Shift-focus.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Bane of Agony
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Bane of Agony
```

### FM HealthFunnel

Template ID: warlock_funnel. Health Funnel to your living pet.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Health Funnel
/cast [@pet,exists,nodead] Health Funnel
```

### FM DeathCoil

Template ID: warlock_deathcoil. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Death Coil
/stopcasting
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Death Coil
```

### FM HowlTerror

Template ID: warlock_howl. Press to attempt Howl of Terror. Spell requirements still apply. Stops your attacks for crowd control.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Howl of Terror
/stopattack
/cast  Howl of Terror
/stopattack
```

### FM Tongues

Template ID: warlock_tongues. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Curse of Tongues
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Curse of Tongues
```

### FM Exhaustion

Template ID: warlock_exhaustion. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Curse of Exhaustion
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Curse of Exhaustion
```

### FM SpellLock

Template ID: warlock_spelllock. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Spell Lock
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Spell Lock
```

### FM Seduction

Template ID: warlock_seduction. Shift: focus. Otherwise hostile mouseover, then target. Stops your attacks for crowd control.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Seduction
/stopattack
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Seduction
/stopattack
```

### FM PetCleanse

Template ID: warlock_devour_friend. Friendly mouseover, target, or self. Alt: self. Can assign a teammate.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Devour Magic
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Devour Magic
```

### FM PetPurge

Template ID: warlock_devour_enemy. Shift: focus. Otherwise hostile mouseover, then target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Devour Magic
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Devour Magic
```

### FM PetStay

Template ID: warlock_pet_stay. Stop your pet and keep it at its current position.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
/petpassive
/petstay
```

### FM PetAggressive

Template ID: warlock_pet_aggressive. Set your active pet to Aggressive. It can attack nearby enemies without a target command. Choose this mode manually.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Pet chooses nearby enemies after activation.

```text
/petaggressive [pet]
```

### FM Wand

Template ID: warlock_wand. Attempt wand shooting at your current enemy with !Shoot. Repeat-press behavior has an open Forever beta bug report; test it on your build. Use this separate button between spells.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Ranged wand Shoot on current enemy.

```text
#showtooltip Shoot
/cast [harm,nodead] !Shoot
```

### FM ShadowBolt

Template ID: warlock_shadowbolt. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shadow Bolt
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Shadow Bolt
```

### FM Immolate

Template ID: warlock_immolate. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Immolate
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Immolate
```

### FM SearingPain

Template ID: warlock_searingpain. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Searing Pain
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Searing Pain
```

### FM SoulFire

Template ID: warlock_soulfire. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Soul Fire
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Soul Fire
```

### FM Shadowburn

Template ID: warlock_shadowburn. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shadowburn
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Shadowburn
```

### FM Conflagrate

Template ID: warlock_conflagrate. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Conflagrate
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Conflagrate
```

### FM Elements

Template ID: warlock_elements. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Curse of the Elements
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Curse of the Elements
```

### FM RecklessCurse

Template ID: warlock_recklessness. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Curse of Recklessness
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Curse of Recklessness
```

### FM Weakness

Template ID: warlock_weakness. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Curse of Weakness
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Curse of Weakness
```

### FM Doom

Template ID: warlock_doom. Shift: focus. Otherwise hostile mouseover, then your target.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Bane of Doom
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Bane of Doom
```

### FM DrainLife

Template ID: warlock_drainlife. Press to attempt Drain Life. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Drain Life
/cast [nochanneling,harm,nodead] Drain Life
```

### FM DrainSoul

Template ID: warlock_drainsoul. Press to attempt Drain Soul. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Drain Soul
/cast [nochanneling,harm,nodead] Drain Soul
```

### FM DrainMana

Template ID: warlock_drainmana. Press to attempt Drain Mana. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Drain Mana
/cast [nochanneling,harm,nodead] Drain Mana
```

### FM RainFire

Template ID: warlock_rainfire. Press to attempt Rain of Fire. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Rain of Fire
/cast [@cursor] Rain of Fire
```

### FM LifeTap

Template ID: warlock_lifetap. Press to attempt Life Tap. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Life Tap
/cast  Life Tap
```

### FM PetSacrifice

Template ID: warlock_sacrifice. Press to attempt Sacrifice. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Sacrifice
/cast  Sacrifice
```

### FM MakeSoulstone

Template ID: warlock_soulstone. Press to attempt Create Soulstone. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Create Soulstone
/cast  Create Soulstone
```

### FM MakeHealth

Template ID: warlock_healthstone. Press to attempt Create Healthstone. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Create Healthstone
/cast  Create Healthstone
```

### FM UnendBreath

Template ID: warlock_unending. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Unending Breath
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Unending Breath
```

### FM DetectInvis

Template ID: warlock_detect. Alt: self. Otherwise friendly mouseover, target, then self. Supports teammate assignment.

Installation: Choose in /fm. Teammate assignment: yes.

Attack behavior: No attack-start command.

```text
#showtooltip Detect Invisibility
/cast [mod:alt,@player][@mouseover,help,nodead][help,nodead][@player] Detect Invisibility
```

### FM AutoOpen

Template ID: auto_warlock_open. Short solo damage opener. Send your pet separately; then use filler, wand or drains manually. Learned steps only. One press per cast; stops at the end. Alt resets. Changing target or leaving combat also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/castsequence [harm,nodead] reset=target/combat/alt Corruption,Immolate,Shadow Bolt,null
```

### FM AutoPrep

Template ID: auto_warlock_prep. Self preparation. Uses the learned armor upgrade. Learned steps only. One press per cast; stops at the end. Alt resets. Ten seconds without pressing also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/stopmacro [combat]
/castsequence [@player] reset=10/alt Demon Armor,Unending Breath,null
```

## WARRIOR

### FM Charge

Template ID: warrior_charge. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Charge
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Charge
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM Taunt

Template ID: warrior_taunt. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings, including when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Taunt
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Taunt
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM Pummel

Template ID: warrior_pummel. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Pummel
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Pummel
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM Sunder

Template ID: warrior_sunder. Start melee attacking and attempt Sunder Armor.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Sunder Armor
/startattack [harm,nodead]
/cast [harm,nodead] Sunder Armor
```

### FM Rend

Template ID: warrior_rend. Start melee attacking and attempt Rend.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Rend
/startattack [harm,nodead]
/cast [harm,nodead] Rend
```

### FM Intercept

Template ID: warrior_intercept. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Intercept
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Intercept
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM Disarm

Template ID: warrior_disarm. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Disarm
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Disarm
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM Hamstring

Template ID: warrior_hamstring. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Hamstring
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Hamstring
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM ShieldBash

Template ID: warrior_shieldbash. Shift-focus, then hostile mouseover, then target. Only the target branch starts melee swings.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on target branch only.

```text
#showtooltip Shield Bash
/cast [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead][harm,nodead] Shield Bash
/stopmacro [mod:shift,@focus,harm,nodead][@mouseover,harm,nodead]
/startattack [harm,nodead]
```

### FM ShieldWall

Template ID: warrior_shieldwall. Press to attempt Shield Wall. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shield Wall
/stopcasting
/cast  Shield Wall
```

### FM BerserkRage

Template ID: warrior_berserker. Press to attempt Berserker Rage. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Berserker Rage
/cast  Berserker Rage
```

### FM IntimShout

Template ID: warrior_intimidate. Press to attempt Intimidating Shout. Spell requirements still apply. Stops your attacks for crowd control.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: Stop attacks for crowd control.

```text
#showtooltip Intimidating Shout
/stopattack
/cast [harm,nodead] Intimidating Shout
/stopattack
```

### FM BattleStance

Template ID: warrior_battle_stance. Press to attempt Battle Stance. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Battle Stance
/cast  Battle Stance
```

### FM DefStance

Template ID: warrior_def_stance. Press to attempt Defensive Stance. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Defensive Stance
/cast  Defensive Stance
```

### FM BersStance

Template ID: warrior_berserk_stance. Press to attempt Berserker Stance. Spell requirements still apply.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Berserker Stance
/cast  Berserker Stance
```

### FM HeroicStrike

Template ID: warrior_heroic. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Heroic Strike
/startattack [harm,nodead]
/cast [harm,nodead] !Heroic Strike
```

### FM Cleave

Template ID: warrior_cleave. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Cleave
/startattack [harm,nodead]
/cast [harm,nodead] !Cleave
```

### FM Execute

Template ID: warrior_execute. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Execute
/startattack [harm,nodead]
/cast [harm,nodead] Execute
```

### FM Overpower

Template ID: warrior_overpower. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Overpower
/startattack [harm,nodead]
/cast [harm,nodead] Overpower
```

### FM MortalStrike

Template ID: warrior_mortal. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Mortal Strike
/startattack [harm,nodead]
/cast [harm,nodead] Mortal Strike
```

### FM Bloodthirst

Template ID: warrior_bloodthirst. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Bloodthirst
/startattack [harm,nodead]
/cast [harm,nodead] Bloodthirst
```

### FM Whirlwind

Template ID: warrior_whirlwind. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Whirlwind
/startattack [harm,nodead]
/cast [harm,nodead] Whirlwind
```

### FM Revenge

Template ID: warrior_revenge. Current enemy only. Starts melee swings even if the ability is unavailable.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Revenge
/startattack [harm,nodead]
/cast [harm,nodead] Revenge
```

### FM SpearStrike

Template ID: warrior_spearing. Current enemy only, in Battle Stance. Starts melee swings even when the ability cannot cast. No two-handed weapon requirement.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee in Battle Stance on current enemy.

```text
#showtooltip Spearing Strike
/startattack [form:1,harm,nodead]
/cast [form:1,harm,nodead] Spearing Strike
```

### FM Slam

Template ID: warrior_slam. Current enemy only. Starts melee swings even when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Slam
/startattack [harm,nodead]
/cast [harm,nodead] Slam
```

### FM ShieldSlam

Template ID: warrior_shieldslam. Current enemy only. Starts melee swings even when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Shield Slam
/startattack [harm,nodead]
/cast [harm,nodead] Shield Slam
```

### FM ThunderClap

Template ID: warrior_thunder. Current enemy only. Starts melee swings even when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Thunder Clap
/startattack [harm,nodead]
/cast [harm,nodead] Thunder Clap
```

### FM MockingBlow

Template ID: warrior_mocking. Current enemy only. Starts melee swings even when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Mocking Blow
/startattack [harm,nodead]
/cast [harm,nodead] Mocking Blow
```

### FM ConcussBlow

Template ID: warrior_concussion. Current enemy only. Starts melee swings even when the spell cannot cast.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy.

```text
#showtooltip Concussion Blow
/startattack [harm,nodead]
/cast [harm,nodead] Concussion Blow
```

### FM BattleShout

Template ID: warrior_battle. Press to attempt Battle Shout. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Battle Shout
/cast  Battle Shout
```

### FM DemoShout

Template ID: warrior_demo. Press to attempt Demoralizing Shout. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Demoralizing Shout
/cast  Demoralizing Shout
```

### FM Bloodrage

Template ID: warrior_bloodrage. Press to attempt Bloodrage. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Bloodrage
/cast  Bloodrage
```

### FM ShieldBlock

Template ID: warrior_shieldblock. Press to attempt Shield Block. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shield Block
/cast  Shield Block
```

### FM Retaliation

Template ID: warrior_retaliation. Press to attempt Retaliation. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Retaliation
/cast  Retaliation
```

### FM Reckless

Template ID: warrior_reckless. Press to attempt Recklessness. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Recklessness
/cast  Recklessness
```

### FM LastStand

Template ID: warrior_laststand. Press to attempt Last Stand. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Last Stand
/cast  Last Stand
```

### FM Sweeping

Template ID: warrior_sweeping. Press to attempt Sweeping Strikes. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Sweeping Strikes
/cast  Sweeping Strikes
```

### FM PierceHowl

Template ID: warrior_piercing. Press to attempt Piercing Howl. Requires the learned ability.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Piercing Howl
/cast  Piercing Howl
```

### FM Throw

Template ID: warrior_throw. Pull your current enemy with the matching ranged weapon. Requires that weapon and its learned skill.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Throw
/cast [harm,nodead] Throw
```

### FM ShootBow

Template ID: warrior_bow. Pull your current enemy with the matching ranged weapon. Requires that weapon and its learned skill.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shoot Bow
/cast [harm,nodead] Shoot Bow
```

### FM ShootGun

Template ID: warrior_gun. Pull your current enemy with the matching ranged weapon. Requires that weapon and its learned skill.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shoot Gun
/cast [harm,nodead] Shoot Gun
```

### FM ShootXbow

Template ID: warrior_crossbow. Pull your current enemy with the matching ranged weapon. Requires that weapon and its learned skill.

Installation: Choose in /fm. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip Shoot Crossbow
/cast [harm,nodead] Shoot Crossbow
```

### FM AutoOpen

Template ID: auto_warrior_open. Melee opener. Build rage and use a compatible stance first. Learned steps only. One press per cast; stops at the end. Alt resets. Changing target or leaving combat also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: Melee on current enemy with form and stealth guards.

```text
#showtooltip
/stopmacro [channeling]
/startattack [harm,nodead]
/castsequence [harm,nodead] reset=target/combat/alt Rend,Sunder Armor,null
```

### FM AutoPrep

Template ID: auto_warrior_prep. Self preparation. Battle Shout needs rage. Learned steps only. One press per cast; stops at the end. Alt resets. Ten seconds without pressing also resets. A fixed starter, not a live optimal rotation.

Installation: Automatic starter. Teammate assignment: no.

Attack behavior: No attack-start command.

```text
#showtooltip
/stopmacro [channeling]
/stopmacro [combat]
/castsequence [@player] reset=10/alt Battle Shout,null
```
