# Bootstrap: Fill Project Development Guidelines

## Goal

Document the actual Fury Fist project conventions inside `.trellis/spec/` so future AI agents use Godot-specific patterns instead of generic web-app assumptions.

## Requirements

- Fill backend guideline files with real patterns from gameplay logic, runtime data loading, config persistence, and error handling.
- Fill frontend guideline files with real patterns from Control nodes, theme usage, responsive layout, menu flow, and HUD composition.
- Include concrete references to current project files and data sources.
- Document anti-patterns that would cause drift in this repo.
- Adapt generic thinking guides so they reflect Fury Fist’s JSON → gameplay → UI workflow.

## Acceptance Criteria

- [x] Backend guideline files describe current project reality
- [x] Frontend guideline files describe current project reality
- [x] Each major guideline has concrete file examples
- [x] Anti-patterns are documented where useful
- [x] Guides reference Godot/Fury Fist-specific cross-layer and reuse concerns

## Technical Notes

Key reference files used while writing the specs:

- `project.godot`
- `scenes/Main.tscn`
- `scenes/battle/BattleScene.tscn`
- `scenes/battle/Fighter.tscn`
- `scenes/ui/BattleHud.tscn`
- `scripts/ui/app_controller.gd`
- `scripts/ui/battle_hud.gd`
- `scripts/ui/keyboard_settings.gd`
- `scripts/ui/life_bar.gd`
- `scripts/battle/battle_scene.gd`
- `scripts/battle/fighter.gd`
- `scripts/battle/game_data.gd`
- `scripts/config/game_config.gd`
- `scripts/i18n/localization.gd`
- `resources/data/roles.json`
- `resources/data/stages.json`

Notes:

- The repo has no `unit-test` spec directory yet.
- The repo currently relies on manual Godot smoke testing rather than an established automated gameplay test suite.
- Backend/frontend terms were mapped onto Godot runtime vs UI responsibilities, not web-service boundaries.
