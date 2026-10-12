# Quality Guidelines

> Code quality standards for backend-style Fury Fist development.

---

## Overview

Backend-style code in this repo is performance-sensitive gameplay/runtime code. Good changes keep battle flow readable, data-driven, and easy to trace from JSON/config input to in-game behavior.

Representative reference files:

- `scripts/battle/fighter.gd`
- `scripts/battle/battle_scene.gd`
- `scripts/battle/game_data.gd`
- `scripts/config/game_config.gd`

---

## Forbidden Patterns

### 1. Loading structured game data directly from random callers

Do not open `resources/data/*.json` from UI scripts or ad-hoc battle helpers. Route it through `GameData`.

### 2. Mutating cached source payloads in place

If a loaded dictionary needs modification, duplicate it first. `GameData` already follows this rule with `duplicate(true)`.

### 3. Re-loading resources every frame

Never put `load(...)`, JSON parsing, or similar expensive work in `_process()` or `_physics_process()`.

### 4. Committing temporary debug spam

Avoid leaving `print(...)`-style diagnostics in combat loops or layout loops. They quickly become noisy and hard to use.

### 5. Spreading the same runtime constant across files

If a tuning value is central to one system, keep it as a named constant near that system instead of duplicating the number in several places.

---

## Required Patterns

### Use typed GDScript where the current codebase does

Existing runtime scripts heavily annotate:

- constants
- member variables
- signal payloads
- function parameters and return values

Follow that style in new code.

### Keep orchestration and entity logic separated

- `battle_scene.gd` coordinates sessions, spawning, camera, pause flow, and HUD sync
- `fighter.gd` owns per-fighter rules and state transitions
- `game_data.gd` owns structured data loading/normalization

Extend the right layer instead of mixing responsibilities.

### Use signals for outward-facing state changes

If another node needs to react, emit a signal instead of coupling everything through direct polling.

### Prefer safe fallbacks and early returns

The codebase usually keeps runtime failures non-fatal where possible. Match that style.

---

## Testing Requirements

There is no established committed automated gameplay test suite in this repository right now.

For backend-style changes, the expected quality bar is manual smoke testing in the running Godot project:

- launch `scenes/Main.tscn`
- enter the affected battle flow or settings flow
- verify the changed role/stage/config path works in-game
- verify pause/exit/restart still work if battle flow changed
- verify bilingual text still resolves if labels or ids changed

For data-shape changes, also test at least one good path and one fallback/missing-data path.

---

## Code Review Checklist

- [ ] Does the change live in the correct layer (`GameData`, `BattleScene`, `Fighter`, `GameConfig`, etc.)?
- [ ] Are structured data changes centralized instead of scattered?
- [ ] Are new ids/keys consistent with existing snake_case naming?
- [ ] Are optional resources and node lookups guarded?
- [ ] Are signals emitted where external UI/runtime state depends on the change?
- [ ] Does the change avoid per-frame loading or debug spam?
- [ ] Was the affected flow tested from the actual Godot scene entry point?

---

## Good Reference Files

- `scripts/battle/game_data.gd` — central loading boundary and normalization
- `scripts/config/game_config.gd` — persistent config with safe defaults
- `scripts/battle/battle_scene.gd` — orchestrator with guarded resource loading
- `scripts/battle/fighter.gd` — large but strongly typed runtime state machine
