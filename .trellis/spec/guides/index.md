# Thinking Guides

> **Purpose**: Expand your thinking before changing Fury Fist so you catch repo-specific issues early.

---

## Why Thinking Guides?

In this project, most expensive mistakes come from changing one layer and forgetting another:

- changing a JSON id but not the UI or localization fallback
- changing battle logic but not the HUD/session wiring
- changing a menu or HUD layout and forgetting viewport scaling
- duplicating role/stage/config logic instead of reusing the existing helper

These guides are here to make AI agents and maintainers pause before editing.

---

## Available Guides

| Guide | Purpose | When to Use |
|-------|---------|-------------|
| [Code Reuse Thinking Guide](./code-reuse-thinking-guide.md) | Reuse existing Godot helpers, themes, and data paths | When adding logic, constants, UI helpers, or data lookups |
| [Cross-Layer Thinking Guide](./cross-layer-thinking-guide.md) | Think through JSON → gameplay → UI → localization/config flow | When a change crosses multiple runtime layers |

---

## Quick Reference: Thinking Triggers

### When to Think About Cross-Layer Issues

- [ ] You changed a `resources/data/*.json` field or id
- [ ] You added or renamed a fighter action/state
- [ ] You changed autoload config, input map, or language behavior
- [ ] You changed battle data that is also displayed in HUD/menu/role select

→ Read [Cross-Layer Thinking Guide](./cross-layer-thinking-guide.md)

### When to Think About Code Reuse

- [ ] You are about to add another layout helper or style helper
- [ ] You are about to add another JSON/resource loader
- [ ] You are modifying constants, config values, or theme-driven UI behavior
- [ ] You want a new helper for localization, role labels, or resource fallback

→ Read [Code Reuse Thinking Guide](./code-reuse-thinking-guide.md)

---

## Pre-Modification Rule (CRITICAL)

> **Before changing any id, path, key, state name, or constant, search for all existing uses first.**

Examples in this repo:

- stage ids like `arena_1`
- action/state ids like `final_blow`, `spinhit`
- input actions like `p1_attack_a`
- localization keys like `menu.single_game`
- shared theme constants/colors

This habit prevents most “updated one layer but forgot another” bugs.

---

## How to Use This Directory

1. **Before coding**: read the relevant guide when a task touches multiple systems
2. **During coding**: if you see repeated patterns, stop and compare against current helpers
3. **After bugs**: update the guide if you found a repo-specific trap worth remembering

---

**Core Principle**: In Fury Fist, correctness usually comes from respecting existing data flow and helper boundaries, not from adding more abstraction.
