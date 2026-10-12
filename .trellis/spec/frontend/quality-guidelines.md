# Quality Guidelines

> Code quality standards for Fury Fist UI and interaction code.

---

## Overview

UI code in this project is highly visible and layout-sensitive. Good frontend changes preserve:

- bilingual text flow
- keyboard-first navigation
- shared theme consistency
- responsive layout across viewport sizes
- clear boundaries between UI presentation and gameplay logic

Reference files:

- `scripts/ui/app_controller.gd`
- `scripts/ui/battle_hud.gd`
- `scripts/ui/keyboard_settings.gd`
- `scripts/ui/life_bar.gd`

---

## Forbidden Patterns

### 1. Hardcoding user-facing text without localization

Use `Localization.text(...)` for menu/help/settings/battle strings unless the text is intentionally fixed branding.

### 2. Bypassing shared themes for large UI sections

Do not manually style every control if an existing theme resource and a few overrides can achieve the same result.

### 3. Mixing gameplay decisions into UI controllers

UI scripts may launch a battle or display role data, but combat rules and content interpretation belong in battle/config/data scripts.

### 4. Ignoring resize behavior

Large panels/HUD elements should not assume one fixed desktop resolution. Existing UI scripts actively recompute layout from viewport size.

### 5. Repeating node-tree mutation in many places

If multiple flows need the same refresh, create a `_refresh_*()` helper instead of copying the mutations.

---

## Required Patterns

### Keep keyboard navigation consistent

Main menu, submenu, pause menu, and role select all support predictable keyboard input. New menu-like UI should preserve that pattern.

### Refresh UI from centralized helpers

Examples:

- `_refresh_localized_text()`
- `_refresh_submenu_text()`
- `_refresh_role_roster_cards()`
- `_refresh_pause_menu_text()`

### Guard optional nodes and resources

This repo uses optional node/resource checks frequently. Follow that style instead of assuming every optional visual exists.

### Use shared visual language

Prefer `fury_poster_theme.tres` / `retro_arcade_theme.tres` and the existing orange/gold poster-style accent system over unrelated new styles.

---

## Testing Requirements

There is no established automated UI test suite in the repo. Manual testing in Godot is required.

For UI changes, test at least:

- launch `scenes/Main.tscn`
- navigate the changed UI with keyboard only
- switch language and confirm labels refresh
- resize or reopen the affected screen if layout changed
- enter/exit battle if the UI starts or overlays gameplay

If the change touches settings, verify persistence through `GameConfig` where applicable.

---

## Code Review Checklist

- [ ] Are all user-facing strings localized or intentionally fixed branding?
- [ ] Does the UI still work with keyboard navigation only?
- [ ] Does the layout still adapt to viewport size where relevant?
- [ ] Does the change reuse the project’s existing theme/style language?
- [ ] Are refresh helpers reused instead of copy-pasted mutations?
- [ ] Are optional nodes/resources guarded?
- [ ] Was the affected flow tested in the actual Godot scene?

---

## Good Reference Files

- `scripts/ui/app_controller.gd` — central menu and role-select flow
- `scripts/ui/battle_hud.gd` — dynamic HUD composition and scaling
- `scripts/ui/keyboard_settings.gd` — popup interaction and localization refresh
- `scenes/Main.tscn` — canonical UI scene structure
