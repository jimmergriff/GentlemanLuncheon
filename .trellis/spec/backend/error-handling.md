# Error Handling

> How runtime failures are handled in Fury Fist gameplay/data code.

---

## Overview

This project does not use a custom exception hierarchy. Error handling is pragmatic and local:

- validate inputs early
- return safe defaults when data is missing
- log one-off resource/data failures with `push_error`
- ignore invalid optional UI/runtime targets with guard clauses

The code favors keeping the game running over failing hard.

---

## Error Types

### 1. Data/resource load failures

Used when a file is expected but cannot be opened or parsed.

Example:

- `scripts/battle/game_data.gd` uses `push_error("Failed to open data file: %s" % path)`
- `scripts/battle/game_data.gd` uses `push_error("Failed to parse JSON: %s" % path)`

### 2. Optional resource absence

Optional textures/audio are allowed to be missing. The loader returns `null`, and callers choose a fallback.

Examples:

- `scripts/battle/battle_scene.gd::_load_optional_texture()`
- `scripts/ui/app_controller.gd::_load_optional_texture()`

### 3. Invalid target/index input

UI/runtime helpers usually return early instead of throwing.

Examples:

- `scripts/ui/battle_hud.gd::_resolve_slot_index()` returns `-1`
- `scripts/ui/battle_hud.gd::set_slot_name()` and related setters exit when the slot is invalid

---

## Error Handling Patterns

### Guard clauses first

Prefer short early returns over deeply nested conditionals.

Common patterns in this repo:

- `if config == null: return`
- `if resolved_index == -1: return`
- `if viewport_size.x <= 0.0 or viewport_size.y <= 0.0: return`
- `if stream == null: return`

### Safe defaults instead of crashes

When a load or lookup fails, return a neutral value:

- `{}` for missing dictionaries
- `[]` or empty strings for missing collections/labels
- `null` for optional textures/audio
- fallback ids such as `arena_1` when a requested stage is missing

Examples:

- `scripts/battle/game_data.gd::load_stage()`
- `scripts/battle/game_data.gd::load_role()`
- `scripts/battle/battle_scene.gd::_pick_random_stage()`
- `scripts/config/game_config.gd::load_config()`

### Check node existence before connecting or reading

Anything fetched through the scene tree or autoload path should be treated as optional until proven present.

Examples:

- `get_node_or_null("/root/GameConfig")` in UI and battle scripts
- signal connection checks before `connect(...)`

### Emit signals after state changes

When state changes matter to other systems, emit a signal rather than expecting callers to poll internals.

Examples:

- `GameConfig.language_changed`
- `Fighter.hp_changed`
- `Fighter.defeated`

---

## Runtime Failure Responses

There is no API response format in this project. Typical runtime responses are:

- **load failure:** log with `push_error`, return an empty dictionary, keep the game running
- **missing optional asset:** return `null`, use fallback asset or skip presentation
- **invalid UI target:** early return without side effects
- **missing config file:** keep defaults and continue

This pattern is visible in:

- `scripts/battle/game_data.gd`
- `scripts/config/game_config.gd`
- `scripts/battle/battle_scene.gd`
- `scripts/ui/battle_hud.gd`

---

## Common Mistakes

- Assuming `get_node_or_null()` returned a valid node and using it immediately
- Loading optional resources without checking `ResourceLoader.exists()` / file existence first
- Returning cached dictionaries and then mutating them in place
- Forgetting to emit the relevant signal after changing state that other systems display
- Adding noisy recovery code for impossible states inside hot paths instead of validating at the boundary
