# Third-party notices

## Optional local installations

ElvUI v15.26-810-g3f2bc8a, BlizzMove v3.8.4 and What's Training? Forever 1.1.1 are separate upstream packages. Their source and assets are not part of the ForeverMacros ZIP. Their own notices and licenses remain in the installed directories. Layout.lua, WindowMover.lua and TrainingUI.lua are original configuration and integration code. The training integration hosts the provider's original window rather than copying its class data. The current window adapter is checked against BlizzMove 3.8.4; future versions need review.

The GSE United Forever sequence creator and its generated sequences have a separate personal-use license that restricts redistribution. No generated sequence from that tool is included. LuckyoneUI informed general role-layout choices; no LuckyoneUI profile, code or asset was copied.

## Talent trees and community builds

ForeverMacros/TalentData.lua adapts the November 3, 2026 snapshot (October 8 before 0.11.0) from [Talents Forever](https://talentsforever.com/data.json), distributed under [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/). Its [about page](https://talentsforever.com/about) states the data license. Credit belongs to Talents Forever and its contributors. This adaptation does not imply their endorsement.

The data was obtained through [ZBuilds Data.lua at commit 57bae431e5b13bc04c2d8883e53ece17f909ab0a](https://github.com/Zael98/Zbuilds/blob/57bae431e5b13bc04c2d8883e53ece17f909ab0a/Data.lua) and checked against the Talents Forever snapshot. The adapter adds explicit prerequisite indices, selects 96 leveling plans, rejects allocations or orders that fail validation (none did), normalizes labels, creates stable plan identifiers and marks generated allocation orders as estimates. It retains source links. The dataset includes 468 talents across nine classes and 27 trees. One missing Priest spell ID remains unresolved.

The Coach also summarizes planned-tree popularity from [Talents Forever's leveling analysis](https://talentsforever.com/leveling). Those figures describe submitted plans, not measured leveling speed. The dates and scope are recorded in RESEARCH.md.

## Guide-derived allocations

The selected allocations include 86 plans from [WoW Forever Builds](https://wowforeverbuilds.com), seven from [RankedBoost](https://rankedboost.com/world-of-warcraft/forever/), two from [Method](https://www.method.gg/wow-forever) and one from [WoW Forever Talent](https://wowforevertalent.com). Each record links to its source and calculator. No guide article text is bundled. Short class advice in Coach.lua is an original summary with a guide link, not a copied guide. Guide authors retain their rights in their publications. The upstream MIT license explicitly excludes third-party data in Data.lua; it does not grant a license to republish guide articles.

## ZBuilds notice

ZBuilds' source is MIT licensed. Its data has the separate terms above. No ZBuilds runtime code is bundled or executed. The following upstream notice is retained for the adapted data structure and extraction reference:

```text
MIT License

Copyright (c) 2026 Zael98

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Other addon references and game assets

GSE, MacroForge, ZMacros and Hekili informed the feature research. Their code, encoded formats and recommendation engines are not bundled. The current GSE source is All Rights Reserved. MacroForge and ZMacros license findings are recorded in RESEARCH.md; those findings do not grant rights in unrelated projects.

World of Warcraft names, spells, talent descriptions and game icons belong to Blizzard Entertainment. Game assets are outside the Talents Forever data license. This addon is not affiliated with or endorsed by Blizzard Entertainment.
