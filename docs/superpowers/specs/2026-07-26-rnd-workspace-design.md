# rnd-workspace: from research-only to research + design

- **Status:** Approved (design), Phase 1 ready to plan
- **Date:** 2026-07-26
- **Supersedes:** the "North star — from research workspace to R&D Toolkit" section of `ROADMAP.md`, in part (see §7)

## 1. Context

The workspace produces research write-ups. Design work already happens here —
`design/ai-literacy-app/` and `design/onboarding-solve-edu/` both hold PRDs, token
files, and working prototypes — but it has no spine: no commands, no shared
conventions, and no shared design system. The two projects settled on incompatible
token vocabularies, which is the concrete symptom.

The goal is to make **a PRD and a working interactive prototype** first-class outputs
of the workspace, with both built on the production design tokens and one standardized
UI library. The repo is renamed `rnd-workspace` to reflect that both halves live here.

A separate, portable toolkit repo is planned later. **Engine-vs-content extraction is
explicitly out of scope for this work** — this spec designs the workspace, not a plugin.

### 1.1 What already exists

| Asset | State |
|---|---|
| `design/onboarding-solve-edu/` | Shape-Up `PRD.md`; multi-file prototype (`prototype-web.html` + `styles.css` + `main.js` + `data.js`); `build-standalone.ps1` inliner; `prototype-web.test.ps1`; a 12 MB `standalone.html` |
| `design/ai-literacy-app/` | `DESIGN.md`, a disciplined `tokens.css` (indigo brand, research-traced), `prototype-onboarding.html`, `design-system-overview.html` |
| `design/onboarding-solve-edu/SPEC.md` | Redundant — same title and same 55 headings as its `PRD.md` |
| `/draft-spec` | Emits an FR/MoSCoW spec that **neither** design project used |
| `raw-data/edbot-v2-mvp/` | Reference only (gitignored): `design-system/edbot/MASTER.md`, four example PRDs, nine single-file prototypes |

The evidence is that the house PRD format is the Shape-Up one, and that `/draft-spec`'s
format is the outlier.

## 2. Mental model

Research becomes the evidence half of one pipeline rather than the product itself:

```
discover ──► synthesize ──► DECIDE ──► MAKE ──► validate
research/     SYNTHESIS.md   PRD.md    prototype
(optional)                   design/<project>/
```

**Design projects are not studies.** A study is point-in-time, so it is dated and
closed. A design project is long-lived and iterates, so it keeps a plain slug and a
status — which is what both existing projects already do.

```
design/<project>/
  README.md            Status: Active | Shipped | Archived · Informed by: <studies>
  PRD.md               the decision doc
  tokens.overlay.css   OPTIONAL — per-project brand divergence
  src/                 index.html · app.js · data.js · img/
  build/               standalone.html (generated, gitignored)
```

**No new registry file.** Studies are many and churn, which is why
`.claude/.active-research` exists. Design projects are few and long-lived, so
resolution derives from disk: explicit `[project]` argument → this terminal's
`.claude/.current-design/<session-id>` binding → the sole project whose `README.md`
says `Status: Active` → ask. One less file to drift.

**Research is optional but never invisible.** A design project's `README.md` lists
`Informed by:` study folders and PRD §2 cites them. Starting with no study is allowed,
but then §2 must say so and label its assumptions; the Principal Designer gate fails a
PRD that states unevidenced claims as fact. This preserves the workspace's core rule
(never fabricate a finding) without forcing a study before every design.

## 3. Phase 1 — Design system foundation

This phase is fully specified and is what gets planned first. It delivers real
production tokens and the shared component CSS into the repo, drift-checkable, before
anything consumes them.

### 3.1 Upstream source of truth

The production repo is `https://gitlab.solveeducation.org/solveearn/solveeducation.git`
(default branch `main`). It carries a W3C DTCG token SSOT at `packages/tokens/`:

| File | Contents |
|---|---|
| `tokens.json` | 133 tokens across 6 groups: `color`, `effect`, `font`, `radius`, `spacing`, `breakpoint` |
| `themes.json` | Dark overlay; overrides only semantic keys that already exist |
| `manifest.json` | Provenance and targets |
| `build.mjs` | Generator; `--check` is a CI drift guard |

`build.mjs` materializes those tokens into
`apps/web/app/(frontend)/globals.css` between two literal marker lines:

```
/* TOKENS:START (generated from packages/tokens/tokens.json by build.mjs — do not edit by hand) */
/* TOKENS:END */
```

The block between them contains **both** a `:root { … }` rule and a
`:root[data-theme="dark"] { … }` rule — **166 CSS custom properties total**. One
extraction yields light and dark together.

Outside that block, the same file defines **239 unique CSS class selectors** (`.btn`, `.card`,
`.badge-success`, `.accordion-trigger`, `.authshell`, …). The file is 2688 lines / 64 KB.

**ADR-0003** (`docs/adr/0003-design-tokens-as-ssot.md`, Accepted 2026-07-05) states the
governing rule, which this workspace adopts verbatim rather than inventing its own:

> No raw style values in component code — no hex codes, no pixel literals for anything
> a token covers.

Upstream enforces it with `tokens:check`, `gate:token-parity`, `gate:no-raw-style`, and
`gate:css-vars-defined`.

### 3.2 Access constraints (tested 2026-07-26, not assumed)

| Method | Result |
|---|---|
| `git clone --depth 1` | **Works anonymously.** 29 MB, 2360 files |
| `https://…/-/raw/main/<path>` | HTTP 302 → `/users/sign_in` |
| `git archive --remote=…` | HTTP 404 — GitLab does not serve it |
| `git clone --filter=blob:none` | Clone succeeds; promisor blob fetch fails server-side |

Therefore sync must shallow-clone to a temporary location, extract, and discard.
29 MB per run is acceptable for an occasional command.

### 3.3 The `ui-library/` library

```
ui/
  tokens.css       GENERATED — the marker block verbatim (light + dark, 166 props)
  tokens.json      GENERATED — the 133 DTCG tokens, kept for drift checking
  components.css   GENERATED — globals.css with the marker block removed (~59 KB)
  behaviors.js     HAND-WRITTEN — vanilla behavior for interactive components
  TOKENS.md        HAND-WRITTEN — digest + provenance (source repo, commit SHA, sync date)
  COMPONENTS.md    HAND-WRITTEN — the component catalogue
```

**Extract, do not reimplement.** `tokens.css` and `components.css` are taken from
`globals.css` by marker, never regenerated by re-running `build.mjs`'s logic. This
guarantees byte-identity with production and means changes to their generator never
need tracking here.

**The class contract is identical across React and vanilla.** Upstream `Button.tsx` is
`cx("btn", variant, block && "block", className)` with the docstring "No new styling is
introduced." So production `<Button variant="pri" block>` and prototype
`<button class="btn pri block">` render the same pixels from the same CSS.

**Only behavior is hand-written.** Of the 42 components in
`apps/web/components/ui/`, **19 are pure class wrappers with no state** (Alert, Badge,
Breadcrumb, Button, Card, Chip, EmptyState, ErrorState, Field, Hero, List,
LoadingState, Row, Sidebar, Spinner, Stat, StrengthMeter, Text, Textarea) and need no
JavaScript at all. The remaining 23 need behavior; upstream `focus-trap.ts` and
`useDialog.ts` are the references to mirror.

`behaviors.js` is the one artifact that can silently diverge from upstream, because it
has no upstream counterpart to diff against. Its contract is the class names, so if a
class disappears upstream the `components.css` drift check catches it.

**`COMPONENTS.md` is the catalogue** — per component: class contract, variants,
CSS-only vs needs-JS, upstream source file, and **ported status**. The PRD's *Prototype
Element Dictionary* appendix points at this file, which is what connects the two halves.

**Port on demand, fail loudly.** Behaviors are not built up front. Phase 1 seeds only
what the two existing prototypes use and marks the rest `not yet ported`.
`/design-prototype` (Phase 3) **stops** when a PRD calls for an unported component
rather than improvising a lookalike. Improvisation is what produced the existing
`--sub` / `--mut` divergence.

### 3.4 The overlay rule

Upstream `themes.json` may override only semantic keys that already exist, so
components re-skin from a token swap alone. `design/<project>/tokens.overlay.css`
follows the same rule: it may **redefine** a token name, never **introduce** one.
Violations are caught by `check-prototype.ps1` rule 3.

### 3.5 `/sync-tokens [--check] [--ref <branch|sha>]`

Backed by `.claude/scripts/sync-tokens.ps1`.

1. Shallow-clone the source repo to the session scratchpad — never into the workspace.
2. Extract the lines **strictly between** the `TOKENS:START` and `TOKENS:END` marker
   lines into `ui-library/tokens.css` (the markers themselves are not copied); write
   `globals.css` with those same lines **and** both marker lines removed into
   `ui-library/components.css`; copy `packages/tokens/tokens.json` to `ui-library/tokens.json`.

3. **Scrub the two non-token outputs** (added 2026-07-26 — see §3.6.1). Strip every
   CSS comment from `components.css`, remove any `@import` of an external host, and
   drop every `$description` field from `tokens.json`. `tokens.css` is **not**
   scrubbed: it is values-only, carries no comments, and stays byte-identical.
4. Write provenance into `ui-library/TOKENS.md`: source repo URL, **resolved commit SHA**, sync
   date, token count, class count.
5. Delete the clone.
6. Report the diff: tokens added, removed, and changed since the previous sync.

`--check` performs steps 1–2 into a temporary location, compares against the committed
`ui-library/` files, prints any drift, exits non-zero on drift, and **writes nothing**. This
mirrors upstream's `tokens:check` so it can gate CI or a publish.

`--ref` selects the source ref. The default is `main`. **`packages/tokens` has no
release tags upstream**, so `main` is a moving target; pinning to a SHA is the reliable
mode. Either way the resolved SHA is recorded.

The prototype build never phones home. It records which token SHA it embedded, so any
published prototype traces to an exact production state. Staleness is surfaced by
running `--check`, not guessed at build time.

### 3.6 Disclosure boundary

`rnd-workspace` is a **public** GitHub repo. The boundary is:

**Committed:** `ui-library/tokens.css`, `ui-library/tokens.json`, `ui-library/components.css`. A shipped web
product's palette, spacing, and type are already readable in devtools on the live site,
so these are not secrets.

**Never committed:** `packages/tokens/manifest.json` (contains an internal project
UUID, DesignSync references, and rebrand notes), anything from the source repo's
`.claude/` (`DESIGN.md`, `project-profile.md`, `constitution.md`, `PRIVACY.md`), and
any `apps/` source. Provenance in `TOKENS.md` is recorded as repo URL + commit SHA +
date only — no internal prose.

`sync-tokens.ps1` must not write any file outside `ui-library/`, and must not copy
`manifest.json` even into the scratchpad output.

#### 3.6.1 Path exclusion is not sufficient — scrub content too

Excluding `manifest.json` by path does **not** keep its contents out. The first real
sync (2026-07-26) proved this: the same internal project UUID, an unannounced rebrand,
an internal PRD name, an internal wiki path, and pre-decisional "RATIFY before locking"
language all reached the public repo through **comments inside the two permitted
files** — a door the path exclusion does not cover.

The sync therefore scrubs, deterministically, on every run:

| Output | Scrub | Rationale |
|---|---|---|
| `tokens.css` | none | Values only; 0 comments. Stays byte-identical. |
| `components.css` | strip all CSS comments; remove any external-host `@import` | Comments carry the leak and affect no rendering |
| `tokens.json` | drop every `$description` field | 118 of them; the top-level one carries the internal prose |

Because the scrub is deterministic and recomputed from source on both sides, `--check`
still detects real drift.

**Removing the external `@import` is not optional** — it is also a correctness fix.
Production's `globals.css` imports four Google-hosted font families, which violates the
Artifact CSP and the self-contained requirement every prototype depends on. Consequence
to state honestly: `--font-display`, `--font-body`, `--font-mono`, and `--font-khmer`
still *name* those families, so prototypes render with system fallbacks unless the fonts
are embedded. Typography fidelity is therefore approximate, and `COMPONENTS.md` must say so.

Known, accepted: `components.css` also references `url("/brand/logo-icon.svg")`, a
root-relative path that will not resolve inside a prototype. It is a local path, not an
external host, so it is not a CSP violation - it simply renders as a missing image.

### 3.7 `.claude/scripts/check-prototype.ps1`

Enforces ADR-0003 locally, mirroring upstream's `gate:no-raw-style` and
`gate:css-vars-defined`. Run against a built `standalone.html`. Any failure blocks
export.

1. **No external hosts** — no `http://` or `https://` in `src`, `href`, or `@import`.
   This is the Artifact CSP requirement, and it also catches the Google Fonts `@import`
   that `raw-data/edbot-v2-mvp/design-system/edbot/MASTER.md` carries.
2. **No raw style values** — no hex literal and no `px` literal outside `ui-library/tokens.css`
   and a project's `tokens.overlay.css`, for any property a token covers.
3. **Every custom property resolves** — every `var(--x)` used resolves to a definition
   in `tokens.css` or the project overlay; an overlay that defines a name absent from
   `tokens.css` fails (the §3.4 rule).
4. **Every class resolves** — every class used in the markup exists in
   `components.css`. This makes "fail loudly on an unported component" real.
5. **No PII** — the existing capture guardrail applied to prototype content.

`design/onboarding-solve-edu/prototype-web.test.ps1` is the existing precedent; this
generalizes it.

### 3.8 `.claude/references/design-system.md`

The single source of truth for the token and component contract — the role
`mobbin-sourcing.md` plays for capture. `CLAUDE.md`, `GEMINI.md`, and `README.md` point
at it rather than restating it, which is what kept the Mobbin rules from drifting.

Contents: the upstream source and marker contract, the access constraints table, the
`ui-library/` layout, the overlay rule, the disclosure boundary, the five `check-prototype`
rules, and the port-on-demand policy.

### 3.9 Phase 1 acceptance criteria

- `ui-library/tokens.css` contains exactly 166 custom properties across `:root` and
  `:root[data-theme="dark"]`, byte-identical to the source lines lying strictly between
  the two markers.
- `ui-library/components.css` equals the source `globals.css` with the marker block, both
  markers, every CSS comment, and any external-host `@import` removed. It retains 239
  unique class selectors and zero custom-property definitions (every `--x:` declaration
  lives in `tokens.css`). Line count is no longer 2515 once comments are stripped; the
  load-bearing invariant is the **239 selectors**, not the line count.
- `ui-library/components.css` contains no `http://` or `https://`, and `ui-library/tokens.json` contains
  no `$description` key.
- `ui-library/TOKENS.md` records a resolved 40-character commit SHA.
- `ui/manifest.json` does not exist; no file from the source repo's `.claude/` exists
  anywhere under `ui-library/`.
- `/sync-tokens --check` exits 0 immediately after a sync, and exits non-zero with a
  readable diff when any byte of `ui-library/tokens.css` is altered.
- `/sync-tokens --check` writes no file.
- `check-prototype.ps1` fails a fixture containing an external `@import`, a fixture with
  a raw hex outside the token files, a fixture using an undefined `var(--x)`, and a
  fixture using a class absent from `components.css`; and passes a clean fixture.
- `ui-library/COMPONENTS.md` lists all 42 upstream components with an explicit ported status,
  and the 19 no-JS components are marked as requiring no behavior.

## 4. Phase 2 — PRD lifecycle (scoped)

**Deliverables:** `/new-design`, `/draft-prd`, board integration, persona updates, and
the `CLAUDE.md` / `GEMINI.md` / `README.md` rewrites.

**The PRD template** is the Shape-Up 13-section format used by
`design/onboarding-solve-edu/PRD.md` and the `raw-data/example-prd/[PRD] …` files,
grafted with the four sections only the screen-by-screen variant carries:

```
 1  TL;DR                            10  Users & Roles               (grafted)
 2  Problem & Evidence               11  Screens, IA & Empty States  (grafted)
 3  Primary JTBD                     12  Modal Reference             (grafted)
 4  Related Jobs                     13  Data Model                  (grafted)
 5  Success Metrics                  14  Non-Goals
 6  Appetite                         15  Rabbit Holes & Open Questions
 7  Solution Shape                   16  Technical Constraints
 8  Vertical Slices                  17  Dependencies
 9  Acceptance Criteria per Slice    App Prototype Element Dictionary
                                         Stakeholder Review
```

Three sections carry a binding to something outside the PRD: §2 **Problem & Evidence**
cites the study's `SYNTHESIS.md`, §7 **Solution Shape** carries a Mermaid flowchart, and
the **Prototype Element Dictionary** appendix points at `ui-library/COMPONENTS.md`.

`/draft-spec` is **renamed** to `/draft-prd`; the FR/MoSCoW format is retired, since §9
Acceptance Criteria per Slice already carries that content. The command inherits the
existing PM / Tech Lead / Head of Product stakeholder review and the Principal Designer
Mode S gate, both retargeted from SPEC to PRD.

`/research-board` keeps its name and grows a Design table. Renaming it would churn 15
skill files for no functional gain.

There is **no `/close-design`** — `README.md` carries the status and a command for a
one-line edit is overhead.

## 5. Phase 3 — Prototype pipeline and migration (scoped)

**Deliverables:** `/design-prototype` rework, `/export-prototype`, and migration of both
existing projects.

- `/design-prototype [project]` authors multi-file source in `src/` against the PRD and
  the `ui-library/` library; Principal Designer Mode T gate.
- `/export-prototype [project] [--artifact]` builds `build/standalone.html` via a
  generalized `build-standalone.ps1` (promoted from `design/onboarding-solve-edu/`,
  which already inlines CSS and JS and base64-encodes images, failing loudly on a
  missing asset), runs `check-prototype.ps1`, and with `--artifact` publishes to
  claude.ai after an explicit confirmation, since publishing is outward-facing.

**Migration is uneven:**

- `onboarding-solve-edu` is straightforward. It is a Solve Education product, so it
  drops its 14 hand-copied tokens (which already renamed `--mut` to `--sub`) and
  inherits all 166 unchanged. `standalone.html` becomes gitignored and rebuilt; the
  4.1 MB `landing.png` and 4.7 MB `register.png` are downscaled first.
- `ai-literacy-app` is the risk. It is a different product with a deliberately
  different brand (indigo, explicitly overriding a teal decision) and its `tokens.css`
  uses entirely different token names. Migration means rewriting its values under the
  production names as an overlay, and the mapping may not be 1:1. **Fallback:** mark it
  `Design system: independent` and let it keep its own token file — `components.css`
  still works so long as the overlay defines every name it consumes.

**Cleanup folded into this phase:** delete `design/onboarding-solve-edu/SPEC.md`
(redundant with `PRD.md`), untrack `.claude/scripts/__pycache__/*.pyc` (committed
bytecode), and gitignore `design/*/build/`.

## 6. The rename

Four moves, executed **after** Phase 2 has updated the docs:

1. `gh repo rename rnd-workspace` — GitHub redirects the old URL and updates the local
   remote. Outward-facing, so it requires explicit go-ahead at execution time.
2. `Rename-Item C:\research-workspace C:\rnd-workspace` — requires no session open in
   the folder.
3. Update `README.md` (4 occurrences) and `.claude/settings.local.json` paths.
4. **Copy `~/.claude/projects/C--research-workspace/memory/` to
   `C--rnd-workspace/`.** Claude Code keys memory by path; without this all five memory
   files silently stop loading.

`research-workspace` appears in 20 tracked files, but 18 are historical plans and specs
under `docs/superpowers/`. Those are a record of what happened and **must not** be
rewritten.

## 7. Relationship to ROADMAP.md

`ROADMAP.md`'s "North star" section frames the R&D Toolkit as portability (Theme A) plus
primary-research expansion (Theme B). This spec supersedes neither but reorders them:
the design half ships first, and Theme A (engine/content extraction into a plugin) is
deferred to the separate toolkit repo. Theme B is untouched.

## 8. Risks

| Risk | Mitigation |
|---|---|
| Upstream `globals.css` drops or renames the `TOKENS` markers | `/sync-tokens` fails loudly with a clear message rather than writing a partial file; the markers are a documented upstream contract |
| `packages/tokens` has no release tags, so `main` moves | Resolved SHA is always recorded; `--ref <sha>` pins |
| `behaviors.js` diverges from upstream component behavior | Bounded by port-on-demand; class contract is drift-checked even though behavior is not |
| `ai-literacy-app` token names do not map 1:1 | Documented fallback to `Design system: independent` |
| A 29 MB clone per sync is slow on a poor connection | Sync is occasional; `--check` is the frequent operation and costs the same clone, so run it deliberately |
| Anonymous clone access is revoked upstream | Sync fails with a clear message; the committed `ui-library/` files keep working, only refresh is blocked |

## 9. Out of scope

- Engine-vs-content extraction into a portable plugin (separate repo, later)
- `survey` and `abtest` research types
- Any change to the research lifecycle commands other than the board and persona edits
  named in Phase 2
- Contributing changes back upstream to the GitLab repo — sync is one-directional
