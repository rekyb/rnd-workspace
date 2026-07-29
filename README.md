# R&D Workspace (`rnd-workspace`)

> A UX-research workspace with a **type-aware research spine**: desk research /
> benchmarking of existing products, and primary-research design & synthesis
> (planning usability studies and synthesizing the results brought back), both
> turned into design-ready write-ups.

This repository does two kinds of research. **Desk research / benchmarking**
studies how existing platforms solve product problems — we **observe and
document publicly available products**, capture evidence as we go (screenshots,
recorded user flows, cited URLs), and synthesize the findings into structured
feature briefs. **Primary-research design & synthesis** plans research
instruments (usability tests today; surveys and A/B tests are planned) and
synthesizes the results the user brings back.

Every claim here is grounded in captured evidence. We do not fabricate findings
or sources.

## What this repo is (and isn't)

- **Is:** A research workspace. We plan and synthesize research and observe
  publicly available products — benchmarking how they solve a given problem, or
  designing and synthesizing primary research (usability studies) — to produce
  evidence-backed synthesis that design and product teams can act on.
- **Is not:** A place where features get built, and not a place that fields
  research itself (no live participant recruiting or running from here). The
  output is the research that informs what to build, not code.

The work is run from the perspective of a **Senior UI/UX Designer**: opinionated
and analytical (explaining *why* a pattern works, not just *that* it exists),
and always thinking in terms of user goals, flows, friction, and reusable
patterns.

## Guardrails

Three hard rules govern all research in this workspace (see `CLAUDE.md` for the
full wording):

- **Never pay for anything.** This is desk research — no purchases,
  subscriptions, upgrades, paid trials, or checkouts on a benchmarked platform.
  When a paywall blocks a flow, we capture what is observable for free, note that
  the rest is gated, and move on.
- **Redact sensitive info before saving any capture.** When a logged-in session
  is used, personal/account data (real names, avatars, emails, other PII) is
  blurred or masked *before* a screenshot or flow recording is saved. Non-
  sensitive feature mechanics (XP, streaks, progress) may remain visible as
  evidence.
- **Never republish licensed reference material.** Mobbin is the default benchmark
  source, and its library is licensed third-party content. Reference images are kept in
  a gitignored `reference/` folder and cited by URL — they are never committed to this
  public repo. A Mobbin-sourced finding is labelled as such, so "grounded in captured
  evidence" keeps its meaning.

## Requirements & setup

Clone the repository:

```bash
git clone https://github.com/rekyb/rnd-workspace.git
cd rnd-workspace
```

This is a research/automation workspace rather than a buildable app — there is no
package to compile. What you need is the tooling that runs the research and
produces its artifacts:

| Tool | Used for | Notes |
|---|---|---|
| **Claude Code** / **Google Antigravity (`agy`)** | Runs the workflow commands (`/new-research`, `/plan-usability`, `/synth-findings`, `/review-research`, `/close-research`, `/publish-research`, and the optional design-output/lens commands) and drives the research. | The workspace is designed to be operated through Claude or Antigravity; see `CLAUDE.md` and `GEMINI.md`. |
| **Mobbin** (MCP) | **Default source** for benchmark evidence — curated screens and flows from shipped iOS and web products, including paywalled and region-locked apps. | Registered as a claude.ai connector at `https://api.mobbin.com/mcp` (OAuth). Requires a paid Mobbin plan. Covers `ios` and `web` only — no Android. |
| **Google Chrome** + **Claude-in-Chrome** (or Antigravity Browser Extension) | **Fallback capture** for the C1–C5 cases Mobbin cannot serve — our own products, missing coverage, live-behaviour questions, currency, and Android. | Chrome extension ID: `eeijfnjmjelapkebgockoeaadonbchdd`. |
| **Python 3** | Runs the helper scripts below. | Standard CPython 3. |
| ├─ **python-docx** | Markdown → `.docx` export via `.claude/scripts/md_to_docx.py` (used by `/synth-findings --docx`). | `pip install python-docx`. **`pandoc` is *not* used.** |
| └─ **Pillow (PIL)** | Extracting PNG stills from recorded flow GIFs into `screenshots/`. | `pip install Pillow`. |
| **git** + **GitHub CLI (`gh`)** | Version control and pushing evidence to the remote. | Auth handled by `gh auth login`; the remote is `rnd-workspace`. |

> Nothing here transacts or installs system packages on its own. Evidence capture
> uses a logged-in browser session you control; personal data is redacted before
> anything is saved (see **Guardrails**).

## Repository structure

Each research topic lives in its own dated folder under `research/`:

```
rnd-workspace/
├── README.md                       # this file
├── CLAUDE.md                       # authoritative project brief & working rules
├── GEMINI.md                       # Antigravity/Gemini entry point (harness delta only; CLAUDE.md is authoritative)
├── ROADMAP.md                      # workspace roadmap
├── BOARD.md                        # R&D board (active + closed studies, design projects), rendered by /research-board
├── .claude/
│   ├── .active-research            # registry of active research folders (one path per line)
│   ├── .current-research/          # per-terminal focus (gitignored; one file per session id)
│   ├── .current-design/            # per-terminal design-project focus (gitignored; no registry — see below)
│   ├── commands/                   # workflow commands (new / plan-usability / synth / review /
│   │                                #   brief-feature / focus / close / publish / board / lenses,
│   │                                #   plus the design half: new-design / draft-prd /
│   │                                #   design-prototype / export-prototype)
│   ├── references/
│   │   ├── active-research.md      # the registry / per-terminal-focus resolution rule
│   │   ├── coverage-contract.md    # Q#/F# schemes, the three vocabularies, the Coverage: line
│   │   ├── design-projects.md      # the design/<project>/ contract & project-resolution rule
│   │   ├── design-gates.md         # design-gate definitions used by /design-prototype
│   │   ├── design-system.md        # the ui-library/ sync contract & disclosure boundary
│   │   ├── mobbin-sourcing.md      # Mobbin sourcing standard: C1–C5, folder shapes, IP boundary
│   │   └── prompt-vocabulary.md    # the house language standard & anti-keyword table
│   ├── personas/                   # reviewer subagent specs: principal-researcher, principal-designer,
│   │                                #   research-skeptic, domain-expert, evidence-auditor,
│   │                                #   product-manager, tech-lead, head-of-product
│   └── scripts/
│       ├── md_to_docx.py           # Markdown → .docx export (python-docx)
│       ├── md_to_docx.ps1          # dependency-free PowerShell fallback for the same export
│       ├── md_visualize.ps1        # Mobbin links → local image embeds (gitignored *.visual.md)
│       ├── sync-tokens.ps1         # refreshes ui-library/ from the upstream repo (+ --check; asks for the URL)
│       ├── build-prototype.ps1     # inlines a design project's src/ into one self-contained HTML file
│       ├── check-prototype.ps1     # local design gate for a built prototype HTML file
│       └── sync-agent-skills.ps1   # verifies/regenerates the .agents/skills/ stubs (+ -Fix)
├── .agents/skills/                 # one registration stub per command, for skill-resolving
│                                    #   harnesses; the body stays in .claude/commands/
├── ui-library/                     # the shared design system (see below) — synced, read-only
├── design/<project>/               # a design project (see The design half): README, PRD.md,
│                                    #   optional tokens.overlay.css, src/ (authored by
│                                    #   /design-prototype), build/ (generated by
│                                    #   /export-prototype, gitignored)
├── docs/superpowers/               # design specs & implementation plans (the project record)
├── raw-data/                       # working research data (GITIGNORED)
└── research/
    ├── PATTERNS.md                 # cross-study reusable-pattern library (owned by the Principal Designer)
    └── YYYY-MM-DD-<slug>/
        ├── README.md               # brief: goal, scope, type, platforms, status
        ├── PLAN.md                 # research plan (reviewed & approved before capture)
        ├── sources.md              # running log of every source consulted (with date & provenance)
        ├── corpus/                 # litreview studies: user-supplied documents (GITIGNORED)
        ├── evidence.md             # litreview studies: verified claims + quarantined refuted ones
        ├── platforms/              # benchmark studies: one folder per platform
        │   ├── <mobbin-sourced>/   #   default shape
        │   │   ├── references.md   #     screen ↔ Mobbin URL mapping table (committed)
        │   │   ├── reference/      #     downloaded Mobbin PNGs (GITIGNORED)
        │   │   ├── flow.md         #     written step-by-step
        │   │   └── notes.md        #     observations & patterns
        │   └── <chrome-sourced>/   #   C1–C5 cases only
        │       ├── screenshots/    #     first-party captures (committed)
        │       ├── flow.gif        #     first-party recording (committed)
        │       ├── flow.md
        │       └── notes.md
        ├── test-plan.md            # usability studies: the instrument (tasks, script, metrics)
        ├── sessions/                # usability studies: session-NN.md, one per PII-redacted participant
        ├── lenses/                 # optional benchmark analysis passes (heuristic-eval / a11y-audit / tokens)
        ├── SYNTHESIS.md            # cross-platform / cross-session synthesis (created at synth time)
        └── SPEC.md                 # legacy: spec from the retired /draft-spec. New build
                                    #   definitions are PRDs in design/<project>/
```

**Several studies can be active at once**, worked in parallel across terminals.
`.claude/.active-research` is a **registry** listing every active study (one folder
path per line), and `.claude/.current-research/<session-id>` (gitignored) records which
one *this* terminal is focused on. Commands resolve their target with a shared rule
(explicit `[folder]` → this terminal's binding → the sole active study → ask); see
`.claude/references/active-research.md`. The workflow commands read and write these, so
the folder rarely needs to be named explicitly. The middle of a study's folder depends on
its `Type`: `platforms/` for benchmark, `test-plan.md` + `sessions/` for usability,
`corpus/` + `evidence.md` for litreview — see **Workflow** below.

## Workflow

The workflow is **one shared lifecycle** — create → design/capture → synthesize
→ review → close → publish — that adapts to the research **type** (`benchmark`,
the default, `usability`, or `litreview`; `survey`/`abtest` are planned).
`/new-research` takes a `--type` flag, and every downstream command reads it and
branches its template accordingly, so the same commands drive all three kinds of
research. Only the instrument step is method-specific: `/plan-usability` for
usability, `/gather-evidence` for litreview.

Research moves through a sequence of commands — capture with `/new-research`
(and, for usability, design the instrument with `/plan-usability`), distill with
`/synth-findings`, strengthen with `/review-research`, optionally turn the
synthesis into a design deliverable, then `/close-research` and
`/publish-research`. **Several studies can run in parallel** — `/new-research` appends
to the registry and binds this terminal to the new study; use `/focus-research <folder>`
to switch a terminal's focus, and `/close-research` to retire one study from the registry.

| Command | What it does |
|---|---|
| `/new-research <topic> [--type benchmark\|usability\|litreview]` | Creates a new dated research folder, scaffolds it for the chosen type (default `benchmark`), and marks it active. |
| `/plan-usability` | *(usability studies)* Designs the `test-plan.md` instrument — tasks, moderator script, metrics — then runs a Principal Researcher methodology review before fielding. |
| `/gather-evidence [folder]` | *(litreview studies)* Runs the `deep-research` harness over the approved `PLAN.md`, then writes a verified `evidence.md` (confirmed claims with confidence labels and `[S#]` IDs; refuted claims quarantined) and `sources.md`. Runs only after the plan gate. |
| `/synth-findings [--docx] [--visual]` | Reads the active research and writes `SYNTHESIS.md` using the template for its type. `--docx` adds a Word copy in the study's gitignored `docx/` folder; `--visual` adds a gitignored `SYNTHESIS.visual.md` with Mobbin reference images inlined for reading. |
| `/review-research` | Runs a research peer-review debate over `SYNTHESIS.md` (Skeptic, Domain Expert, Evidence Auditor, moderated by the Principal Researcher) that strengthens the findings and — on approval — records a `## Peer Review` section. |
| `/brief-feature [folder]` | Turns a synthesized study into a Canva stakeholder deck, gated by the Principal Designer before it's built in Canva. Defaults to the active research. |
| `/close-research` | Verifies synthesis exists, updates the `PATTERNS.md` pattern library via the Principal Designer, marks the research closed, and removes it from the active registry (other active studies stay). |
| `/focus-research <folder>` | Points *this terminal* at one of the active studies, so unqualified workflow commands default to it. For working several studies in parallel. |
| `/publish-research [-m "msg"]` | Safety-checks captures for PII, commits the active research, and pushes to GitHub via the `gh` CLI. |
| `/research-board` | Shows the board — every active study, all past/closed research, and every design project — and refreshes `BOARD.md`. |
| `/save-session [note]` | Writes a session handoff to `SAVE.md` so the next session resumes cold — real git state, what is verified vs assumed, the decisions and why, and what is deferred vs blocked. `SAVE.md` is gitignored. |
| `/sync-tokens [--check] [--ref <branch\|sha>]` | Refreshes the generated files in `ui-library/` from the upstream production repo, asking you for the repo URL on every run. Not part of the research lifecycle — see **The `ui-library/` design system** below. |

`/brief-feature` is the study's **optional design-output step**, run only when asked
and gated by the Principal Designer: the stakeholder **narrative** ("should we build
this"). The maker's **definition** ("here is what to build") is `/draft-prd`, and the
clickable **artifact** ("here is what it looks and feels like") is `/design-prototype`
— both live in the design half below and act on a `design/<project>/`, not a study.

A **Principal Researcher** review persona
(`.claude/personas/principal-researcher.md`) runs as a subagent quality gate at
two points: it reviews the research `PLAN.md` before capture begins (inside
`/new-research`), and it QA-checks the finished `SYNTHESIS.md` (inside
`/synth-findings`) — auto-cleaning the prose (AI-slop and em-dashes in the
research outputs), flagging content problems as inline annotations for you to
resolve, and never silently changing a finding.

A **Principal Designer** persona (`.claude/personas/principal-designer.md`)
owns `research/PATTERNS.md`, the cross-study pattern library, and reviews every
design deliverable — the drafted Canva deck (`/brief-feature`, Mode R), the drafted
`PRD.md` (`/draft-prd`, Mode S), and the authored `src/` prototype (`/design-prototype`,
Mode T) — against the evidence on disk — never browsing the benchmarked platforms
itself — returning ready / revise / reject.

## Capture standards

Benchmark evidence comes from **Mobbin by default**; Chrome is used for the C1–C5 cases it
cannot serve (our own products, missing coverage, live-behaviour questions, currency,
Android). The full standard is `.claude/references/mobbin-sourcing.md`.

**Mobbin-sourced** — screens downloaded to a gitignored `platforms/<platform>/reference/`,
each logged in a committed `references.md` mapping table (screen, Mobbin URL, screen ID,
local file, access date). The flow is written as `flow.md`, with system-response claims
marked *inferred from screen sequence*. No `flow.gif`.

**Chrome-sourced** — numbered PNGs in `platforms/<platform>/screenshots/`, the core flow
recorded as `flow.gif`, the same flow written as `flow.md`, analysis in `notes.md`.
Personal data is redacted *before* anything is saved.

**Both** — every source logged in the research-level `sources.md` with its access date and
provenance.

Reading a synthesis with its screenshots inline:

```bash
powershell -File .claude/scripts/md_visualize.ps1 -Source research/<study>/SYNTHESIS.md
```

This writes a gitignored `SYNTHESIS.visual.md`. `SYNTHESIS.md` itself always carries links,
so it is always safe to commit.

## Synthesis format

`SYNTHESIS.md` is **type-aware**. For a **benchmark** study it is organized as a
list of **features**. Every feature entry contains these five fields, in this
order:

1. **Feature name** — e.g. "AI Companion".
2. **Short description** — one or two sentences on what it is.
3. **Key findings** — what we learned from observing it across platforms,
   following the logic of what the user sees, what the user does, and what the
   system does in response.
4. **Why this feature works (rationale)** — the UX / product reasoning.
5. **How to validate this feature in the future** — concrete next steps to test
   the idea (usability test, prototype, metric, experiment, …).

Each feature cites the platform(s) and evidence (screenshot / flow / source) it
draws from.

For a **usability** study, `SYNTHESIS.md` is organized as **findings** instead,
ordered by severity (0–4, highest first), each with evidence (pseudonymized
participants, task success/failure, redacted quotes), the affected task/
heuristic, and a recommendation — led by an `## Overview` and a `## Metrics
summary` (task success rates, SEQ/SUS, time-on-task).

## Research board

Every active study, the full history of closed/archived research, and every design
project live on the **[R&D Board](BOARD.md)**. Render it to the terminal any time with
**`/research-board`** (it also refreshes `BOARD.md` from the research folders, the
design folders, and the active registry, so the board never drifts).

## Benchmark analysis lenses (optional)

Beyond the core spine, three optional lenses run *retrospective analysis* over a
benchmark study's already-captured evidence (they never re-browse, so they work on
closed studies via a `[folder]` argument). Each writes to the study's `lenses/`
folder and stays grounded in the captures:

- **`/heuristic-eval`** — expert evaluation against Nielsen's 10 heuristics
  (violations *and* exemplary patterns), severity-ranked and evidence-cited.
- **`/a11y-audit`** — a WCAG 2.2 pass on what stills can show (measured colour
  contrast, target size, colour-only meaning, visible labels), explicitly flagging
  the criteria that only live testing can confirm.
- **`/extract-tokens`** — pixel-samples screenshots into an inferred design-token
  set (colour / type / spacing), flagged for validation against the real CSS.

## The design half (`design/<project>/`)

Research is the **discover** half; design is the **make** half. One pipeline:

```
discover ──► synthesize ──► DECIDE ──► MAKE ──────────────────────► validate
research/     SYNTHESIS.md   PRD.md    /design-prototype (author src/)
(optional)                             /export-prototype (ship build/standalone.html)
```

A **design project is not a study**. A study is point-in-time — dated, closed, never
reopened. A design project is long-lived and iterates, so it takes a plain slug (no date
prefix) and a mutable status. The full contract is
[`.claude/references/design-projects.md`](.claude/references/design-projects.md).

```
design/<project>/
  README.md            Status: Active | Shipped | Archived · Informed by: <studies>
  PRD.md               the decision doc (written by /draft-prd)
  tokens.overlay.css   OPTIONAL — per-project brand divergence
  src/                 index.html · app.js · data.js · img/ (authored by /design-prototype)
  build/               standalone.html (generated by /export-prototype, gitignored)
```

| Command | What it does |
|---|---|
| `/new-design <project> [--informed-by research/<study> …]` | Creates `design/<project>/`, scaffolds its `README.md` and `src/`, and binds this terminal to it. The **container only** — it writes no `PRD.md`. |
| `/draft-prd [project] [--docx]` | Turns the project's evidence into a build-ready **`PRD.md`** — the Shape-Up decision doc: jobs, appetite, solution shape, **vertical slices**, and acceptance criteria per slice, plus screens/IA, modals, and data model. A PM / Tech Lead / Head of Product review vets the **slices** (the build call), then the Principal Designer Mode S gate. Defaults to this terminal's current project. |
| `/design-prototype [project]` | Authors the project's clickable prototype as multi-file source in `src/`, built from its `PRD.md` against `ui-library/`. STOPs on a component `COMPONENTS.md` marks `not yet ported`. Gated by the Principal Designer (Mode T). Does not publish. |
| `/export-prototype [project] [--artifact]` | Builds `src/` into `build/standalone.html`, runs `.claude/scripts/check-prototype.ps1`, and with `--artifact` publishes it to claude.ai after an explicit confirmation. |

**Authoring and exporting are deliberately separate commands.** `/design-prototype`
fails on design questions — a missing screen, an unported component — and
`/export-prototype` fails on mechanical ones — a missing asset, a raw hex value, an
unresolved token. Keeping them apart means a gate failure never sends you back through
a whole re-authoring pass; you fix `src/` and re-export.

**No registry, and no `/focus-design`.** Studies churn, so they need
`.claude/.active-research`; design projects are few and long-lived, so status lives in
each `README.md` and nowhere else. Only the per-terminal binding gets a file
(`.claude/.current-design/<session-id>`, gitignored). Resolution: explicit `[project]`
argument (which also *adopts* the binding) → this terminal's binding → the sole
`Status: Active` project → otherwise ask. Naming a project explicitly *is* focusing on
it. There is likewise **no `/close-design`** — status is a one-line edit.

**The PRD format** is 17 numbered sections plus a *Prototype Element Dictionary*
appendix and a `## Stakeholder Review`, organized around **vertical slices** (each
independently shippable and demoable) rather than a flat requirements list. There is
deliberately no FR/MoSCoW section — §9 Acceptance Criteria per Slice carries it, and the
slice is the unit every reviewer judges. Three sections bind outward: §2 cites the study
`SYNTHESIS.md`s, §7 carries a Mermaid flowchart, and the appendix points at
`ui-library/COMPONENTS.md`.

**Research is optional but never invisible.** A PRD may start with no study behind it,
but then §2 must say so and label its claims as assumptions with validation paths — and
the Principal Designer gate **fails a PRD that states unevidenced claims as fact**. Where
a study *is* cited, it must have been peer-reviewed first.

## The `ui-library/` design system

Separate from the research spine. Where research produces evidence, `ui-library/` is the
shared vocabulary a prototype is built *from*, so prototypes look like the real product
instead of improvising a lookalike. The full contract is
[`.claude/references/design-system.md`](.claude/references/design-system.md).

- **Generated, one-directional.** `tokens.css`, `components.css`, and `tokens.json` are
  extracted verbatim from the upstream production repo by **`/sync-tokens`**,
  which scrubs internal identifiers and the external-host font `@import` before writing.
  Nothing flows back upstream. **Never hand-edit them** — `/sync-tokens --check` writes
  nothing and exits non-zero on any drift. The upstream repo URL is deliberately **not
  stored in this repo** — `/sync-tokens` asks for it on every run.
- **Hand-written alongside them:** `COMPONENTS.md` (each upstream component's class
  contract and whether its behavior is ported) and `behaviors.js` (port-on-demand JS,
  seeded rather than exhaustive).
- **Port on demand, fail loudly.** A component marked `not yet ported` has working CSS
  but no behavior; a prototype needing one stops rather than improvising a substitute.
- **Per-project divergence** belongs in `design/<project>/tokens.overlay.css`, which may
  redefine an existing token name but never introduce a new one.
- **Typography is approximate by design** — the external font `@import` is stripped for
  CSP compliance, so text falls back to system faces.

`.claude/scripts/check-prototype.ps1 -Path <built.html>` is the local gate. Five rules:
no external hosts, no raw style values outside the token/component files, every
`var(--x)` resolves (which is also what catches an overlay defining a name absent from
`tokens.css`), every class used in the markup exists in `components.css`, and a PII lint
(a lint, not a guarantee — human review is still required).

It governs prototypes authored by `/design-prototype`, which build on `ui-library/` from
the start and so are gate-clean by construction. The two projects that predate the design
system are `Design system: independent` and are not expected to pass it — a settled
terminal state rather than a pending migration, for the reasons in
[`.claude/references/design-projects.md`](.claude/references/design-projects.md).

## Tooling notes

- **Pattern reference & default benchmark source:** **Mobbin** via its MCP server
  (`search_screens`, `search_flows`, `search_sections`) — curated screens and flows from
  shipped iOS and web products. Paid plan; claude.ai connector. Covers `ios` and `web` only.
- **Browsing & capture:** The Claude-in-Chrome MCP tools or the Antigravity Browser Extension (ID: `eeijfnjmjelapkebgockoeaadonbchdd`) and associated MCP tools (like BrowserMCP/WebMCP). Chrome is used as the browser runtime.
- **Screenshots:** the core flow is recorded as a GIF and downloaded, then key
  frames are extracted to numbered PNGs via **Pillow (PIL)** — redaction is
  applied in-page before capture, so saved frames carry no PII.
- **Word export:** `pandoc` is *not* installed. `.docx` files are generated from Markdown
  via `.claude/scripts/md_to_docx.ps1` (or `md_to_docx.py` with python-docx). Exports are
  written to the study's **gitignored** `docx/` folder, because an export embeds images
  into a binary that no text check can inspect.
- **Stakeholder decks:** built in **Canva** via the Canva MCP tools (used by
  `/brief-feature`) — free tier only.
- **Clickable prototypes:** `/design-prototype` authors the multi-file source in
  `design/<project>/src/`; `/export-prototype` builds it to `build/standalone.html`,
  gates it, and — with `--artifact` — publishes it as a **claude.ai Artifact** —
  default-private, shareable when the user chooses, redeployed to the same URL on
  later passes.
- Temporary and working files stay in the session scratchpad — never inside a
  research folder unless they are real evidence.
