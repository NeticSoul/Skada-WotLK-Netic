# Skada-WotLK-Netic

![WoW 3.3.5a](https://img.shields.io/badge/WoW-3.3.5a-1f6feb)
![Interface 30300](https://img.shields.io/badge/Interface-30300-0b7285)
![Version](https://img.shields.io/badge/Version-1.8.88--netic-2b8a3e)
![License MIT](https://img.shields.io/badge/License-MIT-f08c00)

Skada is a lightweight modular combat meter for World of Warcraft,
with multiple views, segmented fights and customizable windows,
designed for low memory and CPU usage.

This repository is a personal fork of
[bkader/Skada-WoTLK](https://github.com/bkader/Skada-WoTLK)
for **World of Warcraft 3.3.5a**.

- Base: Skada **1.8.88** (released by the original author on MEGA;
  not published on his GitHub, where the latest tag is 1.8.87).
- Includes targeted fixes for long-standing 3.3.5a issues reported in
  the original upstream repository and still unresolved there
  (see [CHANGELOG.md](CHANGELOG.md)).
- TWW (5Buttons)-style visual defaults out of the box, ported from
  [Skada-Revisited-TWW-skin](https://github.com/5Buttons/Skada-Revisited-TWW-skin)
  by [5Buttons](https://github.com/5Buttons) (Details: The War Within
  inspired), plus a selectable DragonUI theme as an alternative.

## Install

1. Download the [latest release](https://github.com/neticsoul/Skada-WotLK-Netic/releases/latest).
2. Unzip the downloaded file.
3. Copy the `Skada` folder to `Interface/AddOns/`.
4. Optional: copy `SkadaImprovement` and/or `SkadaStorage` if you want
  those extra modules.
5. On the character selection screen, open **AddOns** and verify all
  installed Skada modules are enabled.

### Migration note

If you previously used another Skada build, remove old `Skada*` folders
from `Interface/AddOns/` and old `Skada.lua` / `Skada.lua.bak`
SavedVariables from `WTF/` before installing this fork.

### Included modules

- `Skada`: main addon (combat meter window, modes, reports, etc.).
- `SkadaImprovement`: optional (disabled by default). Saves your
  per-character raid boss history and adds Improvement views to compare
  your own results across kills.
- `SkadaStorage`: optional (disabled by default). Stores Skada segments
  in a dedicated per-character database and adds memory-usage checks.

## Commands

- `/skada`
- `/sk`

## Credits

Original Skada by Zarnivoop.
WotLK revival by Kader Bouyakoub (bkader).
Localization contributors: meatgaga (CN), Icar & Septimun (ES),
Kader (FR), NGL (RU).
Direct and indirect contributors: Abel, Iqui, Jeb, Shoggoth,
Havi & Ganrod, WotLK community, Nomadra.
Fork maintained by NeticSoul. License: MIT ([`LICENSE.md`](LICENSE.md)).
