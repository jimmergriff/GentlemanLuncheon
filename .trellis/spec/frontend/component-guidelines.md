# Component Guidelines

> How Control-based UI components are built in Fury Fist.

---

## Overview

Godot UI in this project is built from scenes plus typed GDScript, not JSX or declarative component trees. The practical “component” units are:

- a scene + script pair (`BattleHud.tscn` + `battle_hud.gd`)
- a reusable script-backed Control (`LifeBar`)
- a popup window assembled in code (`keyboard_settings.gd`)

---

## Component Structure

### Prefer thin scene shells with script-owned behavior

Typical pattern:

1. scene defines stable anchor nodes and base theme
2. script grabs important nodes with `@onready`
3. script builds dynamic children as needed
4. script exposes setter methods for external updates

Examples:

- `scripts/ui/battle_hud.gd`
- `scenes/ui/BattleHud.tscn`
- `scripts/ui/app_controller.gd`

### Build repeated UI pieces in loops

For repeated UI blocks, this repo prefers code-built widget trees instead of hand-authoring every nested node in the scene.

Examples:

- `BattleHud._build_slot_widgets(...)` creates slot contents at runtime
- `app_controller.gd::_build_role_roster_cards()` builds roster cards in a loop
- `keyboard_settings.gd::_build_ui()` builds the settings window in code

### Expose narrow imperative update methods

Instead of letting outside callers mutate child nodes directly, provide focused methods such as:

- `set_slot_name(...)`
- `set_slot_avatar(...)`
- `set_slot_hp(...)`
- `set_help_text(...)`

This keeps the widget boundary clear.

---

## Props Conventions

There are no React-style props. Equivalent data flow is usually one of these:

### Constructor/setup-style methods

Examples:

- `BattleScene.start_session(session: Dictionary)`
- `Fighter.setup(config: Dictionary, stage_rect: Rect2, mode: String, prefix: String)`
- `LifeBar.setup(max_health: int, per_bar: int = 500)`

### Explicit setter methods

Examples:

- `BattleHud.set_slot_hp(...)`
- `BattleHud.set_center_text(...)`
- `BattleHud.show_result_banner(...)`

### Node/script configuration after instantiation

Examples:

- `Window.new()` + `set_script(kb_script)` in `app_controller.gd::_open_keyboard_settings()`
- button properties and signal connections configured right after creation

---

## Styling Patterns

### Shared theme first, local override second

Most UI nodes receive a shared theme resource first:

- `fury_poster_theme.tres` for menu/HUD/pause flows
- `retro_arcade_theme.tres` for keyboard settings

Then scripts apply targeted `StyleBoxFlat` or font-color overrides where needed.

Examples:

- `scripts/ui/battle_hud.gd`
- `scripts/ui/app_controller.gd`
- `scripts/ui/keyboard_settings.gd`

### StyleBoxes are created in code for dynamic states

For dynamic selected/focused/result styles, the project often creates `StyleBoxFlat` instances in script rather than storing every variation as a separate resource.

Examples:

- `battle_hud.gd::_make_slot_style()` and related helpers
- `app_controller.gd::_make_role_card_style(...)`

### Layout is recalculated from viewport size

This repo does not rely only on container auto-layout for major screens. Large screens/HUDs usually compute a scale factor and apply manual positions and sizes.

Examples:

- `app_controller.gd::_apply_menu_layout()`
- `app_controller.gd::_apply_role_select_layout()`
- `battle_hud.gd::_apply_layout()`

---

## Accessibility / Interaction Consistency

There is no formal accessibility framework, but there are clear interaction conventions:

- menu navigation supports keyboard input consistently
- focus/selected states receive obvious color and style changes
- button text often includes key hints like `[ESC]` or `[ENTER]`
- bilingual text is refreshed after locale changes

Examples:

- `app_controller.gd::_update_menu_focus()`
- `battle_scene.gd::_update_pause_menu_focus()`
- `app_controller.gd::_with_button_hint(...)`

---

## Common Mistakes

- Editing child labels/textures directly from external code instead of adding a widget method
- Mixing static scene layout and code layout in ways that fight each other
- Hardcoding English-only labels in a new UI path without wiring `Localization.text(...)`
- Creating duplicate style logic when an existing theme/style helper already matches the need
- Adding too many inspector-authored repeated nodes when a loop-built widget would be simpler
