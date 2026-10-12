# Logging Guidelines

> How logging is handled in Fury Fist.

---

## Overview

Logging is intentionally lightweight in this repository.

There is no structured logging library and no multi-level logging framework. The project mainly uses:

- `push_error(...)` for real load/parse failures
- temporary local debugging during development (not meant to stay committed)
- signals and visible UI feedback instead of log spam for normal gameplay events

---

## Log Levels

### Error

Use `push_error(...)` for failures that indicate missing or invalid project data/resources.

Current examples:

- `scripts/battle/game_data.gd::_load_json()` when a data file cannot be opened
- `scripts/battle/game_data.gd::_load_json()` when JSON parsing fails

### Info / Debug

There is no committed project-wide pattern for persistent info/debug logs. If you need short-term debug output while developing, remove it before finishing unless it has clear long-term value.

### Warnings

There is no distinct warning convention right now. Prefer either:

- an early return for harmless optional absence, or
- `push_error` when the project data is truly broken

---

## Structured Logging

Structured logging is not currently used.

If you must log, keep messages concise and include the failing path or action id directly in the string, for example:

- data file path
- resource path
- action/state id
- role/stage id

Do not introduce a custom logging abstraction unless the repo adopts one broadly.

---

## What to Log

Log one-off failures that help maintainers fix broken project data:

- missing JSON data files
- invalid JSON payloads
- broken required resource paths discovered during loading

Good locations for this kind of logging:

- `scripts/battle/game_data.gd`
- future loader/validator utilities under `scripts/` or `tools/`

---

## What NOT to Log

Avoid committed logs for:

- per-frame state in `_process()` / `_physics_process()`
- fighter position, HP, or AI decisions every tick
- successful normal gameplay flow
- large dumped dictionaries every time a battle starts
- localized UI refreshes or other routine refresh functions

In this project, noisy runtime logging is especially harmful because combat and layout code run every frame.

---

## Project-Specific Rule

When deciding between logs and gameplay/UI signals:

- use **signals** for state propagation (`hp_changed`, `defeated`, `language_changed`)
- use **logs** only for genuine failures or short-lived debugging
