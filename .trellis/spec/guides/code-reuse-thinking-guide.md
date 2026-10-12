# Code Reuse Thinking Guide

> **Purpose**: Stop and check whether Fury Fist already has the helper, theme, data boundary, or UI pattern you need.

---

## The Problem

This repo already has several central helpers and reusable patterns. Bugs appear when new code duplicates them instead of extending them.

Common drift points here:

- loading JSON directly instead of using `GameData`
- adding another settings owner instead of extending `GameConfig`
- duplicating localization fallback logic instead of using `Localization` / `GameData`
- rebuilding menu/HUD styling without reusing the project themes or style helpers

---

## Before Writing New Code

### Step 1: Search First

Search for an existing version of the thing you want:

- resource loading helper
- role/stage display-name helper
- layout helper
- stylebox helper
- submenu/button refresh helper
- config getter/setter

Typical reuse anchors in this repo:

- `scripts/battle/game_data.gd`
- `scripts/config/game_config.gd`
- `scripts/i18n/localization.gd`
- `scripts/ui/app_controller.gd`
- `scripts/ui/battle_hud.gd`

### Step 2: Ask These Questions

| Question | If Yes... |
|----------|-----------|
| Does `GameData` already load or normalize this content? | Extend `GameData`, do not bypass it |
| Does `GameConfig` already own this setting/input state? | Add it there instead of another global owner |
| Does an existing `_refresh_*()` helper already update this UI area? | Reuse it |
| Does a shared theme/style helper already match the look? | Reuse or extend it |
| Am I copy-pasting a Control subtree builder? | Extract or extend the current builder |

---

## Common Duplication Patterns In This Repo

### Pattern 1: Repeated data loading

**Bad**: Another script opens `roles.json` or `stages.json` directly.

**Good**: Add/extend a method in `GameData`.

### Pattern 2: Repeated localization fallback logic

**Bad**: UI script hardcodes another role/skill label fallback.

**Good**: Extend `Localization` or `GameData.get_*_display_name()`.

### Pattern 3: Repeated theme/style creation

**Bad**: New UI path hardcodes unrelated colors and borders.

**Good**: Start from `fury_poster_theme.tres`, `retro_arcade_theme.tres`, or existing StyleBox helper methods.

### Pattern 4: Repeated layout math

**Bad**: Adding ad-hoc manual layout code without checking whether an existing scale/gutter/padding pattern already exists.

**Good**: Mirror the scale-from-viewport approach already used in `app_controller.gd` and `battle_hud.gd`.

---

## When to Abstract

**Abstract when**:

- the same helper logic appears in 3+ places
- multiple screens need the same refresh or styling behavior
- the same id/path fallback logic would otherwise be duplicated

**Do not abstract when**:

- the behavior is truly local to one screen
- the helper would hide battle-specific meaning
- a tiny amount of duplication is clearer than a generic Godot utility nobody else will reuse

---

## Fury Fist Reuse Checklist Before Commit

- [ ] Checked whether `GameData` should own the new data access
- [ ] Checked whether `GameConfig` should own the new persistent setting
- [ ] Reused `Localization.text(...)` for user-facing text
- [ ] Reused project themes or existing style helper patterns
- [ ] Avoided duplicating viewport-scaling/layout logic without reason
