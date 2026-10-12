# Backend Development Guidelines

> Backend-style conventions for Fury Fist gameplay logic, runtime data, scene orchestration, and config.

---

## Overview

In this repository, the “backend” side is not a web server. It is the part of the Godot project that owns:

- battle rules and fighter state machines
- runtime data loading from JSON assets
- config persistence and input remapping
- localization registration and lookup
- scene orchestration for battles and non-visual runtime flow

Start here before editing gameplay, data files, or autoload/config code.

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Where gameplay/data/config code lives | Filled |
| [Database Guidelines](./database-guidelines.md) | How JSON runtime data is loaded and normalized | Filled |
| [Error Handling](./error-handling.md) | Guard-clause and safe-fallback patterns | Filled |
| [Quality Guidelines](./quality-guidelines.md) | Required code patterns and review checks | Filled |
| [Logging Guidelines](./logging-guidelines.md) | What to log in a Godot runtime project | Filled |

---

## Read These First

- Editing battle flow or fighter behavior → [Directory Structure](./directory-structure.md), [Quality Guidelines](./quality-guidelines.md)
- Editing `resources/data/*.json` or role/stage lookups → [Database Guidelines](./database-guidelines.md)
- Touching file loading, optional resources, or fallback behavior → [Error Handling](./error-handling.md)
- Adding debug output or diagnostics → [Logging Guidelines](./logging-guidelines.md)

---

## Representative Backend Files

- `scripts/battle/fighter.gd` — core fighter state machine and combat rules
- `scripts/battle/battle_scene.gd` — battle session orchestration, spawning, camera, HUD sync
- `scripts/battle/game_data.gd` — JSON loading, caching, normalization, fallback labels
- `scripts/config/game_config.gd` — autoloaded settings, key bindings, persistence
- `scripts/i18n/localization.gd` — in-memory translations and locale helpers
- `resources/data/roles.json` / `resources/data/stages.json` — runtime structured data

---

## Project Reality

This codebase prefers:

1. **Thin scenes, thick scripts** — `.tscn` files define the node skeleton; scripts hold logic.
2. **Data-driven content** — roles, skills, and stages come from JSON rather than hardcoded scene copies.
3. **Typed GDScript with guard clauses** — invalid input usually returns safe defaults instead of throwing.
4. **Signals for outward state changes** — HP updates, defeat events, and language changes are emitted instead of polled.

---

**Language:** Keep documentation in English even though the game UI is bilingual.
