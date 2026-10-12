# Directory Structure

> How backend-style code is organized in Fury Fist.

---

## Overview

Backend-style code in this project means gameplay rules, runtime data access, config/autoload logic, and non-visual orchestration. The project keeps most runtime behavior in GDScript files, while scenes stay relatively small and mostly define a node skeleton.

---

## Directory Layout

```text
project.godot                 # Project settings, autoloads, input map
scripts/
├── battle/
│   ├── fighter.gd            # Core combat state machine
│   ├── battle_scene.gd       # Match orchestration and HUD/camera sync
│   ├── game_data.gd          # JSON loading and normalization
│   └── damage_number.gd      # Battle feedback actor
├── config/
│   └── game_config.gd        # Persistent config autoload
├── i18n/
│   └── localization.gd       # Translation registration and lookup
└── ui/                       # Frontend-style Control logic

scenes/
├── battle/
│   ├── BattleScene.tscn      # Thin shell for battle_scene.gd
│   └── Fighter.tscn          # Thin shell for fighter.gd
└── ui/
    └── BattleHud.tscn        # UI shell, not backend

resources/
└── data/
    ├── roles.json            # Role roster and stats
    ├── stages.json           # Stage metadata
    └── actions/*.json        # Per-role action/frame data
```

---

## Module Organization

### 1. Scene files stay lightweight

The battle scenes mostly declare node structure and bind scripts:

- `scenes/battle/BattleScene.tscn`
- `scenes/battle/Fighter.tscn`

Heavy behavior belongs in the corresponding script, not in deeply configured scene trees.

### 2. `scripts/battle/` owns gameplay runtime

Keep combat and battle flow here:

- `scripts/battle/fighter.gd` — movement, attacks, AI, hit logic, defeat flow
- `scripts/battle/battle_scene.gd` — session startup, stage loading, fighter spawning, camera, pause menu, battle state
- `scripts/battle/game_data.gd` — role/stage/action loading and normalization

If a change affects battle rules or data interpretation, it usually belongs in this folder.

### 3. `scripts/config/` owns persistent global settings

`project.godot` autoloads `scripts/config/game_config.gd` as `/root/GameConfig`. Cross-screen settings such as language, window mode, AI difficulty, and key bindings belong there.

### 4. Data lives outside gameplay scripts

Structured content is stored under `resources/data/` and loaded at runtime by `GameData`. Do not spread role stats or stage definitions across multiple gameplay files.

---

## Naming Conventions

- **Scripts:** snake_case, e.g. `battle_scene.gd`, `game_config.gd`
- **Scenes:** PascalCase, e.g. `BattleScene.tscn`, `Fighter.tscn`
- **Reusable classes:** use `class_name` when the script is meant to be referenced by type (`BattleScene`, `Fighter`, `GameData`, `Localization`)
- **Runtime data ids:** snake_case strings such as `arena_1`, `mach_b_attack`, `final_blow`
- **Autoload name:** singular PascalCase node name (`GameConfig` in `project.godot`)

Match the existing pairing pattern whenever possible:

- `scenes/battle/BattleScene.tscn` ↔ `scripts/battle/battle_scene.gd`
- `scenes/battle/Fighter.tscn` ↔ `scripts/battle/fighter.gd`

---

## Examples

Use these files as the project’s reference structure:

- `project.godot` — autoload and input map definition
- `scripts/battle/battle_scene.gd` — high-level battle coordinator
- `scripts/battle/fighter.gd` — feature-complete runtime entity script
- `scripts/battle/game_data.gd` — central data access layer
- `resources/data/roles.json` — canonical role metadata source

---

## Anti-Patterns To Avoid

- Putting large gameplay systems directly into `.tscn` inspector configuration
- Loading and parsing JSON from random UI scripts instead of going through `GameData`
- Creating duplicate config owners instead of extending `GameConfig`
- Hardcoding battle content in multiple places when it already exists in `resources/data/`
