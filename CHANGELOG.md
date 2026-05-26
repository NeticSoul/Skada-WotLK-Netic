## Initial commit — Skada-WotLK-Netic

### Bug fixes
- Fix set includes issues reported by users in the original
  `bkader/Skada-WoTLK` repository (not only fork-local findings).
- **[#115](https://github.com/bkader/Skada-WoTLK/issues/115) / [#118](https://github.com/bkader/Skada-WoTLK/issues/118)** `Skada/Modules/Deaths.lua` `mode:Announce`: coerce
  `log.id` through `tonumber` before `math.abs`. Prevents
  `bad argument #1 to 'abs' (number expected, got string)` when a
  deathlog entry has a non-numeric spell id in SavedVariables.
- **[#117](https://github.com/bkader/Skada-WoTLK/issues/117)** `Skada/Core/Display/Bar.lua` tooltip: guard against
  `bar.role` / `bar.spec` being a boolean (`true`) instead of a string
  key. Prevents `AceLocale-3.0: Skada: Missing entry for 'true'`.
- **[#116](https://github.com/bkader/Skada-WoTLK/issues/116)** `Skada/Libs/LibCompat-1.0/Libs/LibGroupTalents-1.0/LibGroupTalents-1.0.lua`:
  guard the `UnitGUID(unit)` call when `unit` may resolve to an invalid
  unit token (post-arena, post-BG, transitional roster states).
- **[#120](https://github.com/bkader/Skada-WoTLK/issues/120)** `Skada/Core/Core.lua` `check_boss_fight`: when a real boss
  is detected after the segment was already started against neutral
  trash (ICC rats, plagued insects, …), realign `set.starttime` to
  the boss-detection timestamp. Prevents segment-merge inflating the
  boss fight timer / DPS.

### Visual customisation — DragonUI-style theme
- New module `Skada/Modules/ThemeDragon.lua`. Applies DragonUI-style
  defaults on fresh profiles and adds a selectable preset named
  `"DragonUI (Netic)"` in Skada's Themes list. Adjusts:
  - Window backdrop (carbon/blue dark with subtle slate borders).
  - Bar height, spacing, font (compact and legible in combat).
  - Color tokens: DragonUI blue primary accent, soft gold for premium
    titles, controlled warm red for damage, clean green for healing,
    cyan for utility.
  - Hover highlight: discreet.
  - Title bar minimalist, coherent button iconography.
- Theme changes are visual-only and leave the underlying calculation
  engine untouched.
