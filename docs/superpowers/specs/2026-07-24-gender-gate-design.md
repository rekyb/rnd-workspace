# Gender Gate — Design Spec

**Date:** 2026-07-24
**Component:** `design/onboarding-solve-edu` (Solve Education! onboarding prototype)
**Status:** Approved, pending implementation plan

## Goal

Add a new onboarding screen that asks the learner's gender, placed immediately after
the age gate, for **program/funder demographic reporting** (Digital Heroes / HP).

## Context

The prototype has two entry paths through a shared set of gates:

- **Organic:** landing → name → country → **age** → goal → save-wall → home
- **Program:** code modal → assigned-content → name → country → **age** → save-wall → home

Each gate follows one consistent pattern:

- A `.card` div in `prototype-web.html` (e.g. `#age_gate`)
- Its selection stored on `appState` (e.g. `selectedAgeCategory`)
- A shared footer **Continue** button, enabled/disabled per gate in `updateHeaders()`
- `handleGlobalContinue()` dispatching on the active card to route onward
- `progressMap` / `programProgressMap` driving the header progress bar

The gender gate follows this same pattern exactly. No new architecture is introduced.

## Requirements

### Placement & routing

The new screen `#gender_gate` sits directly after `age_gate` on **both** paths:

- **Organic:** age → **gender** → `goal_intake`
- **Program:** age → **gender** → `save_wall`

`continueFromAge()` is re-pointed to always `goTo('gender_gate')`. A new
`continueFromGender()` takes over the routing `continueFromAge()` used to do:

- organic → `goTo('goal_intake')`
- program → `goTo('save_wall')` + `populateProfileSummary()`

Back navigation needs no change: `goTo()` already pushes onto `appState.historyStack`,
so the back button returns gender → age automatically.

### Options & data

Three options, single-select:

| Label | Stored value |
|---|---|
| Female | `'female'` |
| Male | `'male'` |
| Prefer not to say | `'prefer_not_to_say'` |

Stored as `appState.selectedGender` (initial value `null`).

**Required**, consistent with the other gates: the footer **Continue** button stays
disabled until one option is selected. Because "Prefer not to say" is itself a valid
choice, requiring a selection never forces disclosure.

### Layout & copy

Uses the existing `.option-card` component and the `.selected` purple border/tint state.
**No icons** — gendered iconography risks stereotyping, so the cards are text-only.

```
How do you identify?
This helps us understand our program's reach. Prefer not to answer? That's okay.

┌──────────────┐ ┌──────────────┐
│    Female    │ │     Male     │   ← row 1: two equal cards
└──────────────┘ └──────────────┘
┌─────────────────────────────────┐
│       Prefer not to say          │   ← row 2: full width, subtler
└─────────────────────────────────┘
```

- **Title:** "How do you identify?" (distinct from the age gate's "How would you
  describe yourself?")
- **Subtitle:** privacy-forward framing that states why we ask and that opting out is fine.
- Row 1 is a two-column grid; row 2 is a single full-width card, visually subordinate
  so the opt-out reads as secondary to the two primary answers. "Subordinate" means the
  same `.option-card` component with muted label colour (`--sub`) and regular rather
  than bold weight — not a different component, and not a disabled appearance.
- Cards stack to a single column on narrow screens.

### Progress-bar weighting

Both maps are rebalanced so every step is an equal increment. Uneven steps would make
progress feel arbitrary; all gates are single-tap selections of comparable effort, so
even weighting is the honest representation.

**Organic (`progressMap`)** — 6 bar screens, even 18% steps, starting at a visible 10%:

| Screen | Before | After |
|---|---|---|
| `landing` | 0 | 0 |
| `name_gate` | 0 | **10** |
| `country_gate` | 25 | **28** |
| `age_gate` | 50 | **46** |
| `gender_gate` | — | **64** |
| `goal_intake` | 75 | **82** |
| `assigned_content` | 75 | **(removed)** |
| `save_wall` | 100 | 100 |
| `learning_home` | 100 | 100 |

Two scoped cleanups included:

1. **`name_gate` starts at 10 instead of 0** so the bar shows a visible sliver on the
   first gate rather than reading as empty/broken.
2. **`assigned_content: 75` is removed** from the organic map — it is dead code, since
   `assigned_content` only ever appears on the program path where `programProgressMap`
   overrides it.

**Program (`programProgressMap`)** — 6 bar screens, even ~17% steps:

| Screen | Before | After |
|---|---|---|
| `assigned_content` | 20 | **17** |
| `name_gate` | 40 | **33** |
| `country_gate` | 60 | **50** |
| `age_gate` | 80 | **67** |
| `gender_gate` | — | **83** |
| `save_wall` | 100 | 100 |
| `learning_home` | 100 | 100 |

The program path already starts non-zero, so it needs no sliver fix.

## Code touchpoints

**`prototype-web.html`**
- Add the `#gender_gate` card markup directly after the `#age_gate` block.

**`main.js`**
- `appState`: add `selectedGender: null`.
- `progressMap` / `programProgressMap`: apply the tables above.
- `updateHeaders()`: add `'gender_gate'` to the footer-visible screen list, and add the
  branch `btn.disabled = !appState.selectedGender`.
- `handleGlobalContinue()`: add the `gender_gate` → `continueFromGender()` case.
- Add `selectGender(element, value)`: set `appState.selectedGender`, clear `.selected`
  from peer cards, apply `.selected` to the chosen card, enable Continue.
- Add `continueFromGender()`: organic → `goal_intake`; program → `save_wall` +
  `populateProfileSummary()`.
- Re-point `continueFromAge()` to `goTo('gender_gate')`.
- Wire the three cards' click handlers in the existing `DOMContentLoaded` block,
  matching how the age-gate buttons are wired.

## Out of scope

- No persistence or backend — this is a prototype; nothing is transmitted or stored.
- No free-text "Other" option and no non-binary option (decided: three options only).
- No changes to `standalone.html`, which is a generated build artifact and must be
  rebuilt separately via `build-standalone.ps1`.
- No localization of the new copy (the prototype currently mixes English UI with
  Indonesian program copy).

## Acceptance criteria

1. After selecting an age and pressing Continue, the gender gate appears on **both** the
   organic and program paths.
2. Continue is **disabled** on arrival and becomes enabled as soon as any of the three
   options is selected.
3. Selecting an option shows the purple `.selected` state, and selecting a different
   option clears the previous one (only one can be selected).
4. Continue from the gender gate routes to `goal_intake` on the organic path and to
   `save_wall` (with the profile summary populated) on the program path.
5. The back button returns from gender to the age gate, preserving the age selection.
6. The progress bar advances monotonically with equal-sized steps on both paths, and is
   visibly non-empty on the first gate.
7. No gendered icons appear on the gender cards.
