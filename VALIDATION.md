# Validation record

Version 0.4.1. Client inspected: WoW Forever 1.60.1.70205, interface 16001. Checked October 3, 2026. The executable version and active wow_classic_beta entry in .build.info both report build 70205.

| Check | Result | Evidence |
| --- | --- | --- |
| Logic and lifecycle | PASS | 172 scenarios in independent Lua 5.1 runtimes with mocked WoW APIs. Run tests/run_tests.py to reproduce. The unchanged 0.4.0 baseline also passed all 163 scenarios before editing. |
| October abilities | PASS in mocks | Shifting Power waits for an active learned spell, casts only in Cat Form, and preserves edits. Spearing Strike uses the actual Battle Stance slot and a living current enemy. Form and stance changes wait until combat ends. |
| Pet mode and rank changes | PASS in mocks | Hunter and Warlock Aggressive macros require explicit selection. Combat queues their installation. A missing pet rank leaves existing text intact and a learned replacement rank resolves by name. |
| Level 30 and status | PASS in mocks | A saved Berserker Rage request is fulfilled after the level event when learned. Status includes 1.60.1.70205 and interface 16001. |
| Learning skills | PASS | New attacks install after spell, text, level, and world events. Combat defers writes. Repeated events settle without duplicate creation or editing. |
| Macro upgrades | PASS | Owned templates refresh in place. Edited, renamed, removed, skipped, and paused macros are preserved. Higher rank IDs resolve by learned name. |
| Saved learning requests | PASS | Default-target optional choices made before learning persist in SavedVariables, retry after training or slot availability, and can be cancelled. Combat requests are also covered. |
| Pet spellbook | PASS | Player and pet banks stay separate, including same-name collisions, pet changes, and renamed Screech. |
| Attack behavior | PASS | Hunter Auto Shot, melee swings, off-target isolation, stealth/form guards, wand separation, channels, and control patterns checked in generated text and a small condition model. |
| Library | PASS | 363 templates, 120 automatic and 243 optional. 91 are Hunter-specific. Names fit 16 bytes; rendered default bodies fit 255 bytes. Each class's optional actions can be selected independently. |
| Slot limits | PASS | Client-provided limits and reserve enforced. Attack starters get priority. Full-slot warning is deduplicated. Existing macros are never removed to make room. |
| UI callbacks | PASS | Search, filters, paging, saved-request cancellation, teammate selection, gear controls, and status commands tested with mock frames. |
| Theme selection | PASS | Nine class paths, faction selection, missing texture fallback, and texture retry tested with mock frames. |
| Artwork files | PASS at package gate | All nine files must be uncompressed 1024x1024 RGB TGA with complete pixel data. Package and installer require the exact artwork manifest. |
| Package | PASS at package gate | ZIP CRC, exact manifest, and source-byte checks run by tools/package.py. One ForeverMacros folder contains the TOC, eleven Lua files, nine textures, and seven documentation or license files. |
| Local installation | PASS on the development machine | Addon files were backed up before replacement and checked by SHA-256 after copying. This does not validate another user's installation. Local installation receipts are excluded from the public repository. |
| Teammates and equipment | PASS | Existing ownership, queued assignment, item selection, weapon preset, trinket combat guard, and equipment-set tests retained. |
| DBM adapter | PASS in mocks | Existing timer cleanup, restricted-data handling, ownership checks, and disabled defaults retained. No live boss-timer validation was added. |
| Current live execution | EXTERNAL_DEPENDENCY | The tests do not execute WoW commands or render the game UI. Training and casting must still be checked in the running client. |
| Discord channel review | EXTERNAL_DEPENDENCY | Public community resources were reviewed. Private channel content was not read. |

## First check in the game

Exit and reopen WoW after installing this version, then open `/fm`. Confirm v0.4.1, your class artwork, faction label, and slot count. Run `/fm status` to check the loaded addon version and full client build.

1. Learn a new supported skill while a character macro slot is free. Confirm that its starter attack macro appears without running an install command. An optional skill needs a saved selection in the library first.
2. Drag the FM macro from the character tab of `/macro` onto a bar once. Existing plain spell buttons remain plain spell buttons until you replace them.
3. Test a damage button on a living selected enemy. For melee, check that swings start even when the ability is on cooldown. For Hunter shots, check that Auto Shot starts and repeat presses do not turn it off.
4. Test hostile mouseover and Shift-focus separately. Utility buttons should use the intended unit without starting a new attack at a different selected enemy.
5. Queue an assignment during combat. Confirm its previous target remains active until combat ends.
6. Check a personal edit is preserved, then reload and check saved choices. Test a second class and faction when available.
7. If learned, test ShiftingPower in Cat Form and outside it, or SpearStrike in Battle Stance and another stance. Check that the guarded button acts only in its required form or stance. PetAggressive should appear only after selecting it in the library.

A rankless spell name normally stays the same when learning a higher rank. The game chooses the learned rank. An unchanged macro body alone does not show that an update failed.

No live spell success, boss advance-warning accuracy, or complete private Discord review is claimed by these results. Earlier testing of version 0.3.x is historical evidence only.
