# Directory Structure

> How frontend-style UI code is organized in Fury Fist.

---

## Overview

UI code is split between scene shells under `scenes/` and behavior scripts under `scripts/ui/`. Scenes usually define the stable node tree and default theme resources; scripts then bind behavior, create dynamic children, apply style overrides, and recompute layout at runtime.

---

## Directory Layout

```text
scenes/
├── Main.tscn                # Main menu, role select, dialogs, battle host
└── ui/
    └── BattleHud.tscn       # HUD shell for battle overlay

scripts/
└── ui/
    ├── app_controller.gd    # Main menu / flow controller
    ├── battle_hud.gd        # HUD behavior and responsive layout
    ├── keyboard_settings.gd # Settings pop-up window
    └── life_bar.gd          # Custom drawn health bar widget

resources/
├── fury_poster_theme.tres   # Main UI / HUD theme
└── retro_arcade_theme.tres  # Keyboard settings and dialog theme
```

---

## Module Organization

### 1. Main flow lives in one controller script

`scenes/Main.tscn` and `scripts/ui/app_controller.gd` together own:

- splash screen flow
- menu focus/navigation
- submenu switching
- role selection
- popup dialogs
- launching and exiting battles

This project currently prefers a single controller for main-menu flow rather than many tiny screen scripts.

### 2. Reusable UI widgets get their own script or scene pair

Examples:

- `scenes/ui/BattleHud.tscn` + `scripts/ui/battle_hud.gd`
- `scripts/ui/life_bar.gd`
- `scripts/ui/keyboard_settings.gd`

If a UI element has standalone behavior or custom drawing, give it a dedicated script.

### 3. Themes and data stay outside the screen script

- shared visual language belongs in `resources/*.tres`
- localized strings belong in `scripts/i18n/localization.gd`
- runtime content belongs in `resources/data/*.json`

UI scripts should consume these sources rather than redefining them.

---

## Naming Conventions

- **Scene files:** PascalCase, e.g. `BattleHud.tscn`, `Main.tscn`
- **UI scripts:** snake_case, e.g. `app_controller.gd`, `keyboard_settings.gd`
- **Named UI classes:** use `class_name` for reusable widgets like `BattleHud` and `LifeBar`
- **Node names in scenes:** PascalCase or descriptive camel-like scene names such as `RoleSelect`, `MenuTicket`, `BattleHost`
- **Theme constants:** uppercase constants such as `UI_THEME`

---

## Examples

Use these as structural references:

- `scenes/Main.tscn` — dense but readable UI scene skeleton
- `scripts/ui/app_controller.gd` — central screen controller
- `scenes/ui/BattleHud.tscn` — minimal shell scene with named anchors
- `scripts/ui/battle_hud.gd` — script-driven HUD composition
- `scripts/ui/keyboard_settings.gd` — popup UI built mostly in code

---

## Anti-Patterns To Avoid

- Duplicating translation strings directly in several widgets when `Localization.text(...)` already exists
- Hardcoding UI content in multiple scripts instead of sourcing it from `GameData` or `Localization`
- Creating a new scene for every tiny visual fragment when a script-built child is sufficient
- Mixing battle rules into UI scripts; UI scripts should display and route, not own combat logic
