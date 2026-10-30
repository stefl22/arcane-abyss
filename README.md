# Arcane Abyss · Abismo Arcano

A fantasy dungeon-crawler prototype built in **Roblox Studio with Luau**. Begin in a sanctuary, descend into increasingly dangerous cave floors, and combine melee attacks, dodges and elemental magic.

This portfolio project explores responsive third-person combat, spell presentation and client/server gameplay systems. Developed by **Stefano Lopez (stefl22)** with AI-assisted implementation and iteration.

## Gameplay and technical highlights

- A sanctuary and five dungeon floors, with enemy-clear requirements for descent.
- Random character lineages, including Human, Elf, Dwarf, Draconic, Demon and God.
- Click-based punches, dodging, sprinting and a centered third-person camera.
- Arcane Spear, Frost Nova, Radiant Renewal and Flame Bolt, with further abilities unlocked through progression.
- Layered magic effects: animated fire, trails, particles, magic circles, impact effects and temporary lighting.
- Server-side cooldown and aiming validation, raycast obstruction checks, and delayed projectile damage.
- Client-side presentation with temporary-effect cleanup and distance-based environmental effects.

## Repository status

**Work in progress / source showcase.** `src/` contains the latest saved local gameplay/VFX scripts (v9; camera export v7). The included `archive/AbismoArcano-v2.rbxlx` is an **older playable scene snapshot**, not a packaged v9 release. Later Studio-only changes are not included in this export.

The archived place and newer scripts are deliberately kept separate. The latest scene, its terrain and asset instances must be exported from Studio before a complete current release can be distributed. Performance optimization, enemy visuals, balance, mobile testing and persistent progression remain work in progress. There is no verified public play link or active Robux shop in this repository.

## Explore the code

| File | Responsibility |
| --- | --- |
| [AbismoServer](src/server/AbismoServer.server.luau) | Combat validation, enemies, lineages and floor progression |
| [AbismoClient](src/client/AbismoClient.client.luau) | Input, HUD, spell selection and character action presentation |
| [AbismoCharacterCamera](src/client/AbismoCharacterCamera.client.luau) | Third-person camera and cursor controls |
| [ArcaneSpellArtV8](src/shared/ArcaneSpellArtV8.luau) | v9 spell VFX; instance name retained for compatibility |
| [AbismoEnvironmentVFX](src/client/AbismoEnvironmentVFX.client.luau) | Environmental flame and lighting effects |

## Try the archived prototype

1. Download or clone this repository.
2. Open `archive/AbismoArcano-v2.rbxlx` in Roblox Studio.
3. Press **F5** to play the historical snapshot.

That snapshot uses older controls and effects: click or Q for the first power, E/R for the other equipped powers, and F for portals. It does not demonstrate all newer source features below.

### Newer source controls

| Input | Action |
| --- | --- |
| WASD / mouse | Move / look |
| Left click | Punch |
| Shift / Ctrl | Dodge / sprint |
| Q / E / R / T | Equipped spells |
| F | Interact with portals |
| B | Spellbook |
| Alt | Free cursor |
| M | Reduced motion |

See [setup and dependencies](docs/SETUP.md), [development notes](docs/v9-development-notes.md) and [asset credits](CREDITS.md).

## Next milestones

- Export and verify a complete current Studio scene.
- Measure and improve frame pacing on target devices.
- Complete earned cosmetic progression and its interface.
- Replace placeholder enemies and expand encounter variety.
- Record a short gameplay showcase from the verified build.

## Credits and rights

Third-party Roblox assets remain subject to their creators' terms. No blanket open-source license is granted for this project or its referenced assets. See [CREDITS.md](CREDITS.md).
