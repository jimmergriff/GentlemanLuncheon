# Hook Guidelines

> Godot equivalents of shared stateful UI logic in Fury Fist.

---

## Overview

This project has no React hooks. The equivalent mechanisms are:

- helper methods inside the screen/controller script
- autoload access through `/root/GameConfig`
- signal subscriptions such as `language_changed`
- small script-local state machines for focus, preview animation, splash timing, etc.

When Trellis asks for “hooks”, map that request into Godot patterns instead of inventing a hook system.

---

## Shared Stateful Logic Patterns

### 1. Connect to global signals once in `_ready()`

Common shared behavior is wired by subscribing to `GameConfig.language_changed`.

Examples:

- `scripts/ui/app_controller.gd::_connect_language_signal()`
- `scripts/ui/keyboard_settings.gd::_connect_language_signal()`
- `scripts/battle/battle_scene.gd::_connect_language_signal()`

Pattern:

1. `get_node_or_null("/root/GameConfig")`
2. verify the signal exists
3. avoid duplicate connections
4. refresh UI from the callback

### 2. Encapsulate reusable refresh logic in helper methods

Instead of repeating UI mutation everywhere, centralize it into methods like:

- `_refresh_localized_text()`
- `_refresh_role_roster_cards()`
- `_refresh_pause_menu_text()`
- `_refresh_labels()`

This is the project’s main replacement for hook-style shared UI behavior.

### 3. Use script-local timers/state for interactive flows

Transient UI behavior is usually owned by member variables plus `_process()`:

- splash screen phase/timer in `app_controller.gd`
- role preview animation in `app_controller.gd`
- pause menu focus state in `battle_scene.gd`

---

## Data Fetching

There is no server fetching layer.

UI reads local runtime data through helper APIs:

- `GameData.load_role(...)`
- `GameData.get_role_ids()`
- `Localization.text(...)`
- autoloaded `GameConfig` getters/state

Do not invent async fetching abstractions for local JSON-driven UI unless the project architecture changes.

---

## Naming Conventions

For hook-like helpers, follow current GDScript naming:

- private helpers start with `_`, e.g. `_refresh_localized_text()`
- signal callbacks use `_on_*`, e.g. `_on_language_changed(...)`
- connector/setup helpers use verbs, e.g. `_connect_language_signal()`, `_setup_role_select()`

If the behavior is only meaningful inside one script, keep it private instead of extracting a reusable global utility too early.

---

## Common Mistakes

- Reconnecting the same signal repeatedly without an `is_connected(...)` check
- Reading `/root/GameConfig` directly in many spots instead of wrapping refresh behavior in a helper
- Repeating the same locale-refresh mutations in multiple callbacks instead of centralizing them
- Inventing a custom “hook” abstraction when a helper method and signal connection are enough
