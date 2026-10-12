# Frontend Development Guidelines

> Frontend-style conventions for Fury Fist Control-based UI, menu flow, HUD, and scene composition.

---

## Overview

In this Godot project, the “frontend” side means:

- Control-based menu and dialog flows
- HUD widgets and responsive layout logic
- theme usage and style overrides
- role selection and settings screens
- user-facing interaction and navigation

This repo does not use React-style components or hooks. The closest equivalents are scenes, Control nodes, helper methods, signals, and script-owned UI construction.

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Where UI scenes and scripts live | Filled |
| [Component Guidelines](./component-guidelines.md) | How Control widgets and screens are built | Filled |
| [Hook Guidelines](./hook-guidelines.md) | Godot equivalents for shared stateful UI logic | Filled |
| [State Management](./state-management.md) | Local UI state vs global/autoload state | Filled |
| [Quality Guidelines](./quality-guidelines.md) | Required patterns and review checks | Filled |
| [Type Safety](./type-safety.md) | Typed GDScript and runtime validation style | Filled |

---

## Read These First

- Editing menu flow or role selection → [Component Guidelines](./component-guidelines.md), [State Management](./state-management.md)
- Editing HUD layout or responsive UI → [Component Guidelines](./component-guidelines.md), [Quality Guidelines](./quality-guidelines.md)
- Editing shared UI behavior or localization wiring → [Hook Guidelines](./hook-guidelines.md)
- Editing typed UI scripts → [Type Safety](./type-safety.md)

---

## Representative Frontend Files

- `scenes/Main.tscn` — main screen composition and UI node tree
- `scripts/ui/app_controller.gd` — menu flow, dialogs, role selection, splash, and battle launch
- `scenes/ui/BattleHud.tscn` — thin HUD shell scene
- `scripts/ui/battle_hud.gd` — dynamic HUD widget assembly and responsive layout
- `scripts/ui/keyboard_settings.gd` — pop-up settings window assembled in code
- `scripts/ui/life_bar.gd` — custom drawn UI feedback control

---

## Project Reality

This codebase prefers:

1. **Theme-driven presentation** — shared `Theme` resources plus targeted style overrides.
2. **Script-owned responsive layout** — many Control positions and sizes are recalculated manually from viewport size.
3. **Thin scene skeleton + code-built children** — scenes provide anchors and key containers; scripts often add runtime children.
4. **Bilingual UI wiring** — labels are refreshed through `Localization.text(...)`, often after connecting to `GameConfig.language_changed`.

---

**Language:** Keep these docs in English even though UI text is bilingual.
