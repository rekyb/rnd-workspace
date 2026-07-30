# Learning Home: Sidebar to Top Nav, and the Top-Level IA — Design Spec

**Date:** 2026-07-30
**Component:** `design/onboarding-solve-edu` (`src/` prototype; PRD §6.2, §7.5, §11.1, §14, §15)
**Status:** Approved, pending implementation plan

## Goal

Two changes, taken together because the second decides the first:

1. **The Learning Home's navigation moves from a left sidebar to a top bar** on web.
2. **The eleven production destinations are reorganized into four top-level families**, so the
   top bar carries four items rather than eleven.

The prototype currently renders four invented destinations (`Home`, `Courses`, `Achievements`,
`Settings`) that do not exist in the product. This replaces them with the real information
architecture.

## Why this is being decided now

The production home at `staging.solve.education/learner` carries **eleven flat, ungrouped
destinations**: `Home`, `Inbox`, `Catalog`, `Ladders`, `Practice`, `Challenges`, `Evidence`,
`Credentials`, `Opportunities`, `Applications`, `Referral`. Confirmed live on 2026-07-30,
unchanged from the 2026-07-29 study.

`research/2026-07-29-learning-home-layout-and-ia` found that surface is **the only one in its
set with neither a structural device nor a current-location signal**, while two benchmarked
platforms carry *more* destinations than it (Uxcel 13, Codecademy 12) and both apply a device
and mark location. Nav labels were queried live: no `aria-current`, no active class on any of
the eleven items. That is a measured absence.

## The decision

### Top-level families

| Family | Contains | Rationale |
|---|---|---|
| **Home** | (the home itself) | Entry point; not a family |
| **Learn** | Catalog · Ladders · Practice · Challenges | The learner's day-to-day surface, identified by the product owner as most-used |
| **Portfolio** | Evidence · Credentials | What the learner can show someone else |
| **Work** | Opportunities · Applications | What they can apply to, and what they applied to |

Two destinations sit outside the families:

| Destination | Placement | Reason |
|---|---|---|
| **Inbox** | Bell icon, top right | A notification surface, not a destination the learner browses to |
| **Referral** | Profile menu | Occasional, and it serves the organisation more than the learner |

**All eleven destinations remain reachable. None is deleted.**

The split follows the product's own arc — **learn a skill → prove you have it → get work with
it**. That is the purpose-based device Uxcel applies (`LEARN` / `GROW`), which the study
records on one of the two platforms carrying more destinations than this product.

### Profile menu

```
[Profile ▾]
  ├─ Your profile
  ├─ Settings
  ├─ Referral
  ──────────────
  └─ Log out
```

`Log out` is separated by a divider: it is the one destructive-feeling action in the menu and
should not sit flush against a navigational one.

### Desktop structure

```
[Logo]   Home    Learn ▾    Portfolio ▾    Work ▾          [🔔 Inbox]  [Profile ▾]
                   │            │             │
                   │            │             └─ Opportunities · Applications
                   │            └─ Evidence · Credentials
                   └─ Catalog · Ladders · Practice · Challenges
```

A family opens a panel showing **all of its members at once**. No member is nested further.
Maximum depth to any destination is two.

### Narrow width

The top level is exactly four items, and the narrow destination row built and measured on
2026-07-30 holds **exactly four labelled destinations at 360px** — 71 × 53 px each, one line
per label, verified in English and against plausible Bahasa strings (`Beranda` / `Belajar` /
`Portofolio` / `Kerja`).

So the phone treatment needs no new decision: the four families become the destination row,
icon above label, every label retained. **No hamburger, no icon-only row** — both are
prohibited by PRD §6.2's kill threshold, and the study records that the one observed overflow
control keeps seven destinations permanently visible and is *not* a menu replacing the
navigation.

Family members are reached from inside the family surface at narrow width, not from a
dropdown over a 360px viewport.

### Current-location marking

Marking does two jobs, per the study's reading of Codecademy: it says where the learner is,
**and** which tier they are navigating within.

- On `Practice`, the top row marks **Learn** as the active family.
- The open panel marks `Practice` itself.
- Both carry `aria-current="page"`, inside a `nav` landmark with an accessible name.
- Every decorative icon is `aria-hidden`, so a destination's accessible name is its label alone.

This is adopted on **orientation** grounds. WCAG 2.2 SC 2.4.8 *Location* is **Level AAA**, with
G128 and ARIA26 as sufficient techniques. It must not be reported as AA conformance.

## What this costs, stated plainly

**A top nav cannot keep all eleven destinations visible; a sidebar can.**

The study's DI1 recommends keeping every destination visible under static headings — which is
what Uxcel does with thirteen. That works vertically because sidebar height is cheap.
Horizontal space is not. With four families across the top, **nine of the eleven destinations move
one click away** — the eight family members plus Referral in the profile menu. Home and Inbox stay
at the top level. *(An earlier draft of this spec said seven; corrected 2026-07-30 against the
actual assignment.)*

The study's specific warning, resting on Larson & Czerwinski `[R1]`, is against **trading
breadth for depth**. This design incurs exactly one level of depth, and each panel shows its
whole family at once rather than nesting further. That is a materially smaller cost than the
push-depth-down arm R1 penalises, but it is **not zero**, and it is the price of the top-bar
decision rather than a free improvement.

## What is NOT validated

Stated because the study refuses to assert it and this spec must not launder it:

- **The family names** (`Learn`, `Portfolio`, `Work`) are a judgement from destination labels.
- **The item-to-family assignment** is the same judgement.
- The study **declined to recommend any specific mapping**, because ten of the eleven
  destinations were never opened during it: *"Assigning them on their names alone would be a
  content judgement made without the content."* Its candidate table is explicitly the card
  sort's **input**, not its output.

**No part of this IA may be reported as validated** until the study's stated gate runs, in
order:

1. Content inventory of the ten unopened destinations — are any duplicative?
2. **Open card sort, n≈15, run in Bahasa Indonesia** — an English card sort validates English
   labels, and short UI strings expand substantially in translation.
3. Sample stratified by **facilitated versus self-directed arrival** — a facilitator saying
   "tap Practice" values stable, nameable destinations differently.
4. First-click test on the resulting variants.

**Falsified if:** the card sort produces learner clusters matching neither a purpose split nor
a scope split, or a first-click test shows the grouped variant no faster than the flat eleven
on a majority of tasks.

## Consequences

**Resolves PRD §6.2 entry condition 5.** That condition asks which navigation the first-run
Learning Home inherits — the prototype's four invented items or production's eleven. The
answer is neither: it inherits **the real IA, reorganized into four families**. Cycle 3's
five-destination budget holds at four, with headroom.

**Retires the `Achievements` reconciliation.** `Achievements` was a prototype destination
pointing at a §14 non-goal, reconciled in the PRD as "a destination is not a mechanic." It
leaves the navigation entirely, replaced by `Portfolio`. The §14 clarification stays, because
it still governs whether progress *values* render.

**Reverses commit `8a992ad`**, which removed a top nav from the Learning Home. That removal was
correct for the nav that then existed — a duplicate of the sidebar's brand and items. This is a
different nav carrying a different IA, and the sidebar goes away rather than being duplicated.
The `home.html` comment asserting "no global header on the home" must be replaced, not left
contradicting the markup.

## Scope

**In scope**

- `src/home.html` — replace the sidebar shell with a top bar across all three views
- `src/styles.css` — top-bar layout, family panels, narrow-width destination row
- `src/home.js` — panel open/close, active-family marking, profile menu, out-of-scope responses
- `src/src-prototype.test.ps1` — extend the guard suite for the new structure
- PRD `§6.2` entry condition 5, `§7.5`, `§11`, `§11.1`, `§14`, `§15`, `A.6` — record the decision

**Out of scope**

- Building the ten destination pages. Every family member routes to the existing out-of-scope
  response, which names the destination rather than swallowing the click.
- Changing the funnel's own header (`onboarding.html`). Different surface, different job.
- The steady-state Learning Home's content. This spec changes navigation only.
- Running the card sort or the first-click test. Those are research, not implementation.

## Collision risk

`docs/superpowers/specs/2026-07-30-age-conditional-goal-set-design.md` targets **the same
project and the same `src/` prototype** on the same day, from a parallel session. Its stated
surfaces are the **age gate and the goal screen** in `onboarding.html`; this spec's are the
**Learning Home** in `home.html`. They overlap in `styles.css` and
`src-prototype.test.ps1`, and both may touch the shared card component.

**Before implementing, check whether that spec has landed.** If both are applied blind, the
shared stylesheet and the guard suite are the two files that will conflict.

## Acceptance criteria

- [ ] The top bar carries exactly four top-level items: Home, Learn, Portfolio, Work.
- [ ] All eleven production destinations are reachable; none is deleted.
- [ ] Opening a family reveals every member of that family at once; no member nests further.
- [ ] Maximum depth from the home to any destination is two.
- [ ] The active family is marked in the top bar when the learner is on any of its members.
- [ ] Current location is marked visibly **and** with `aria-current="page"`, inside a named
      `nav` landmark, in every view.
- [ ] Every decorative icon carries `aria-hidden="true"`; no destination's accessible name
      contains icon ligature text.
- [ ] At 360px the four families render as a labelled destination row, no horizontal scrolling,
      no hamburger, no icon-only treatment, every label on one line in English and Bahasa.
- [ ] Every interactive control meets WCAG 2.2 SC 2.5.8 (24 × 24 CSS px), at every tested width.
- [ ] The profile menu contains Your profile, Settings, Referral, and Log out, with Log out
      separated.
- [ ] Every out-of-scope destination responds by naming itself; none swallows the click.
- [ ] Verified at 320 / 360 / 414 / 768 / 1440 px: zero overflowing elements, zero targets
      below the floor.
- [ ] `node --check` passes on every script, and the guard suite passes with the new checks
      mutation-tested.
