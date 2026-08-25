# Cake Rain RNG Gameplay and Update Notes

## Markdown Maintenance Rules

1. **Do not overwrite the whole document**: update only the relevant sections so existing gameplay, architecture, and release history remain intact.
2. **Keep the three required sections**: `Gameplay Overview`, `Architecture Notes`, and `Update and Fix History` must not be removed or renamed.
3. **Document every new system**: when adding a skill, wheel term, UI, shop item, or player-data field, record its purpose and maintenance location here.
4. **Keep script ownership explicit**: skill tuning belongs in its own SkillScript, wheel-term tuning belongs in its own RewardScript, and services should only dispatch/control flow.
5. **Append release notes**: add the newest entry at the top of `Update and Fix History`; do not rewrite older entries.
6. **Game-facing text stays English-only**: do not add built-in non-English UI strings. Let Roblox localization/translation handle other languages.

## Gameplay Overview

Cake Rain RNG is a Roblox game built around falling cakes, eating cakes, and turning earned resources into RNG upgrades.

1. Cakes continuously fall near each player.
2. A player starts automatically eating an owned cake after touching it.
3. When a cake reaches zero health, it grants Cake Points and wheel spins.
4. Higher-rarity cakes have stronger rewards, and Glow Cakes unlock a card draw.
5. Players spend wheel spins to draw wheel terms such as Eat Speed Up, Auto-Roll, Wheel Haste, and Wheel Level Up.
6. The shop unlocks additional drawable content.
7. The bag lets players review owned and locked drawable skills and wheel terms.

## Architecture Notes

- `WheelConfig`: stores only wheel-term identity, weight, unlock policy, and script routing.
- `SkillConfig`: stores only card identity, weight, unlock policy, and script routing.
- `RewardScripts`: each wheel term owns its rarity tuning, duration, and effect application.
- `SkillScripts`: each skill owns its rarity tuning, cooldown, duration, parameters, visuals, and effect logic.
- `RewardService`: dispatches wheel terms by `ScriptName`; it should not store large term-tuning tables.
- `SkillService`: dispatches skills by `ScriptName`, creates state, and runs cooldown loops; it should not store large skill-tuning tables.
- `StateService.GetProfile(player)`: the unified accessor for player state so services read/write one consistent profile object.
- `StateService.BuildInventory(player)`: builds the server-owned bag payload for drawable wheel terms and skills.
- `LocalizationConfig`: English-only source strings; non-English player-facing text should be provided by Roblox localization/translation, not hard-coded here.

## Update and Fix History

### 2026-08-25: English-only game text and Roblox-managed translation

- Removed the built-in Traditional Chinese localization table and switched runtime text lookups to the English source table.
- Converted hard-coded HUD, tooltip, status-bar, button, print, and effect text to English.
- Added a documentation rule that game-facing text must stay English-only so Roblox can handle translation.

### 2026-08-25: Fix incomplete status bar and incorrect script architecture

- Fixed the bottom status readout so wheel reward name, rarity, effect text, and stack count are shown after a spin.
- Added the Bag button and Ability Bag panel so players can review owned and locked drawable skills and wheel terms.
- Added `StateService.GetProfile(player)` as a unified player-data accessor for other systems.
- Added `StateService.BuildInventory(player)` so the server prepares the inventory payload sent to clients.
- Refactored wheel-term architecture so Eat Speed Up, Glow Cake Rate Up, Auto-Roll, and Wheel Haste tuning live in their own RewardScripts.
- Refactored skill architecture so Grappling Hook, Tornado, Ant Courier, and Cake Attraction rarity tuning, duration, cooldown, and parameters live in their own SkillScripts.
- Kept service responsibilities clear: `RewardService` and `SkillService` dispatch and manage flow only, reducing future update conflicts.
