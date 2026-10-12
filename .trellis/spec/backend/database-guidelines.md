# Database Guidelines

> Data-source conventions for Fury Fist. This project has no external database; structured runtime data is stored in JSON assets.

---

## Overview

Treat `resources/data/` as the project’s database layer.

Current runtime data sources include:

- `resources/data/roles.json`
- `resources/data/stages.json`
- `resources/data/actions/*.json`

All higher-level code should read these files through `scripts/battle/game_data.gd`, not by opening JSON files directly from UI or battle orchestration code.

---

## Query Patterns

### Use `GameData` as the single access layer

Preferred access points:

- `GameData.load_roles()`
- `GameData.load_role(role_id)`
- `GameData.load_stage(stage_id)`
- `GameData.get_role_ids()`
- `GameData.get_stage_ids()`
- `GameData.get_role_display_name(role)`
- `GameData.get_skill_label(skill_id)`

Examples:

- `scripts/battle/game_data.gd`
- `scripts/ui/app_controller.gd`
- `scripts/battle/battle_scene.gd`

### Cache by file path

`GameData._load_json()` caches parsed payloads in `_cache` using the resource path as the key. New structured data loaders should follow the same pattern if they read local files repeatedly.

### Normalize at the boundary

`GameData` performs normalization immediately after load:

- role display-name fallback injection in `_normalize_role()`
- action alias injection in `_inject_action_aliases()`
- translation fallback lookup in `get_role_display_name()` and `get_skill_label()`

Keep this normalization close to the loader, not scattered across callers.

### Duplicate before mutating

When loaded dictionaries need modification, duplicate them first:

- `role.duplicate(true)`
- `actions.duplicate(true)`

This prevents accidental mutation of cached source data.

---

## Migrations

There is no migration framework in this repository.

When the data shape changes:

1. Update the JSON files under `resources/data/`
2. Update `GameData` normalization and fallback logic
3. Update all callers that depend on the changed keys
4. Smoke-test the full flow in the running game

Typical cross-file updates after a schema change:

- `resources/data/roles.json`
- `resources/data/actions/*.json`
- `scripts/battle/game_data.gd`
- `scripts/ui/app_controller.gd`
- `scripts/battle/battle_scene.gd`
- `scripts/battle/fighter.gd`

---

## Naming Conventions

- Top-level collections use plural keys such as `roles` and `stages`
- Runtime ids are snake_case strings such as `kunio`, `arena_7`, `jump_spinkick`
- Per-role action files are named after the role id, e.g. `actions/kunio.json`
- Asset references inside JSON are stored as repo-relative resource paths and resolved with `res://`

Examples:

- `resources/data/roles.json`
- `resources/data/stages.json`
- `resources/data/actions/kunio.json`

---

## Common Mistakes

- Parsing `resources/data/*.json` directly in a screen/controller script instead of using `GameData`
- Mutating a cached dictionary without `duplicate(true)`
- Adding a new action/state id in JSON but forgetting the related fallback or alias logic
- Changing a JSON key without updating every consumer of that key
- Hardcoding translated names in UI code when `Localization`/`GameData` already provides a display helper
