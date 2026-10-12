# Type Safety

> Type-safety patterns for Fury Fist UI scripts.

---

## Overview

The project uses typed GDScript extensively. UI code follows the same style as gameplay code:

- typed constants
- typed member variables
- typed `@onready` node references
- typed function parameters and return values
- explicit casts with `as` when reading generic nodes/resources

---

## Type Organization

Types are mostly local to each script rather than defined in dedicated shared type files.

Common patterns:

- `@onready var role_name: Label = ...`
- `var _menu_buttons: Array[Button] = []`
- `const UI_THEME: Theme = preload(...)`
- `var config: Node = get_node_or_null("/root/GameConfig")`

For reusable entities/widgets, scripts also expose `class_name`, for example:

- `class_name BattleHud`
- `class_name LifeBar`
- `class_name BattleScene`
- `class_name Fighter`

---

## Validation

Runtime validation is lightweight and usually done with guard clauses plus casts.

Patterns used in UI code:

- `get_node_or_null(...) as Panel`
- `if config == null: return`
- `if _role_ids.is_empty(): return`
- checking `has_signal(...)` / `has_method(...)` before use
- clamping layout values with `clampf`, `clampi`, `maxf`, `maxi`

This is preferred over heavy validation frameworks.

---

## Common Patterns

### Typed node references

Always type important scene references when the node class is known.

### Typed arrays for widget collections

Examples:

- `Array[Button]`
- `Array[Panel]`
- `Array[String]`

### Explicit resource casts

Examples:

- `load(path) as Texture2D`
- `load(path) as AudioStream`
- `load(path) as GDScript`

### Nullable checks after broad casts

When the type may be absent, cast and then guard:

- `get_node_or_null(...) as Panel`
- `if hero_poster != null:`

---

## Forbidden Patterns

- Leaving important UI collections as untyped generic arrays when the element type is known
- Calling methods on `get_node_or_null(...)` results without a null check
- Using stringly typed magic values in many places when a constant or typed helper already exists
- Adding large dynamic dictionaries for UI state when a few typed fields are clearer
