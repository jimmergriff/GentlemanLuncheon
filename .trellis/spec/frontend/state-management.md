# State Management

> How UI and shared state are managed in Fury Fist.

---

## Overview

State management is straightforward and local. The project mainly uses three buckets:

1. **autoload global state** for persistent config (`GameConfig`)
2. **screen-local state** for menu flow, selection, splash, focus, and preview timers
3. **runtime data lookups** from `GameData` and `Localization`

There is no Redux-like store or external state library.

---

## State Categories

### Global persistent state

Owned by `/root/GameConfig`:

- language
- windowed/fullscreen mode
- AI difficulty
- key bindings

Reference:

- `scripts/config/game_config.gd`
- autoload declaration in `project.godot`

### Screen-local UI state

Owned by controller scripts as member variables.

Examples from `app_controller.gd`:

- `_selected_role_index`
- `_current_submenu`
- `_menu_focus_index`
- `_active_menu`
- `_pending_training_dummy`
- `_pending_2v2`
- splash and preview timers

Examples from `battle_scene.gd`:

- `_paused`
- `_pause_focus_index`
- `battle_finished`
- `session_data`

### Derived display state

Often recomputed on refresh instead of being stored separately.

Examples:

- button labels from `Localization.text(...)`
- displayed role stats from `GameData.load_role(...)`
- HUD text derived from battle mode / battle result

---

## When to Use Global State

Promote state to `GameConfig` only when it is:

- needed across multiple screens/scenes
- persistent between runs
- part of user settings/input configuration

Good fits in this repo:

- locale
- key bindings
- fullscreen/window mode
- AI difficulty default

Do **not** move temporary screen state like submenu visibility or selected role index into the autoload.

---

## Server State / External Data

There is no server-state layer. Local structured data from `GameData` acts as read-only content state.

Use `GameData` as the boundary for:

- role roster ids
- role stats and skill labels
- stage metadata
- action frame definitions

---

## Common Mistakes

- Turning one-screen temporary state into global autoload state
- Duplicating the same setting value both in `GameConfig` and a local script without a refresh path
- Mutating UI state in many places instead of routing updates through a single `_refresh_*()` helper
- Treating local content lookups as writable state when they should remain derived from JSON/Localization
