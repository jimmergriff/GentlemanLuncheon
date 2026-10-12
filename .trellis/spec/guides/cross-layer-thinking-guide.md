# Cross-Layer Thinking Guide

> **Purpose**: Think through Fury Fist data flow across JSON, gameplay scripts, config/autoloads, and UI before implementing.

---

## The Problem

Most real bugs in this repo happen at boundaries, not inside one isolated function.

Typical examples here:

- a JSON field changes but `GameData` normalization is not updated
- a new action/state id is added but fighter logic, skill labels, or previews do not know about it
- config/input changes work in `GameConfig` but the UI does not refresh
- battle results or role stats are correct internally but not reflected in HUD/menu UI

---

## Common Fury Fist Data Flows

### 1. Role content flow

```text
resources/data/roles.json
  → GameData.load_role(s)
  → app_controller.gd / battle_scene.gd / fighter.gd
  → role select UI / battle setup / combat logic
```

### 2. Stage content flow

```text
resources/data/stages.json
  → GameData.load_stage()
  → battle_scene.gd
  → background / camera / battle rect / BGM
```

### 3. Localization flow

```text
Localization.TRANSLATIONS / locale helpers
  → GameConfig.set_language()
  → language_changed signal
  → app_controller.gd / battle_scene.gd / keyboard_settings.gd refresh helpers
  → visible text updates
```

### 4. Settings/input flow

```text
project.godot input map + GameConfig defaults
  → GameConfig load/save/remap
  → keyboard_settings.gd / menu helpers
  → InputMap / UI labels / actual controls
```

---

## Before Implementing Cross-Layer Changes

### Step 1: Map the Full Path

When you change an id, key, or field, trace it from source to display/runtime use.

Ask:

- where is the source of truth?
- who normalizes it?
- who reads it next?
- where is it displayed to the player?
- what fallback happens if it is missing?

### Step 2: Identify Boundaries

Important repo boundaries include:

| Boundary | Common Issues |
|----------|---------------|
| `resources/data/*.json` ↔ `GameData` | missing keys, renamed ids, fallback drift |
| `GameData` ↔ UI scripts | display labels, missing role/stage ids |
| `GameConfig` ↔ UI | setting changes not refreshing labels or controls |
| `BattleScene` ↔ `BattleHud` | state updated internally but not pushed to HUD |
| `Localization` ↔ UI text | untranslated new labels, stale refresh paths |
| `project.godot` input map ↔ settings UI | action names drift from remapping UI |

### Step 3: Define the Contract

For each changed boundary, define:

- exact key/id/path name
- expected type (`String`, `Dictionary`, `Array`, etc.)
- fallback behavior if missing
- which script owns normalization/translation

---

## Common Cross-Layer Mistakes In This Repo

### Mistake 1: Changing a JSON id without updating helpers

If you rename a role, stage, skill, or action id, you may also need to update:

- `GameData` fallback/alias logic
- localization keys
- UI display code
- fighter state/action checks

### Mistake 2: Updating config without a refresh path

Changing language, key bindings, or difficulty is not enough by itself. Check whether listeners refresh visible text or button labels.

### Mistake 3: Updating battle internals but not HUD output

If combat state changes, confirm the outward signal/update path still reaches HUD methods like `set_slot_hp(...)`, `set_slot_defeated(...)`, and banner text refreshes.

---

## Checklist For Cross-Layer Features

Before implementation:

- [ ] Identified the true source of truth
- [ ] Listed every script/scene that consumes the changed field/id/state
- [ ] Defined fallback behavior for missing/invalid data
- [ ] Decided which layer owns normalization and translation

After implementation:

- [ ] Tested the happy path in the running Godot project
- [ ] Tested at least one fallback or missing-data path
- [ ] Verified UI text/HUD/settings refresh if visible state changed
- [ ] Verified no layer still depends on the old key/id/path
