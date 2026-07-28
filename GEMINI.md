# Gemini Integration Guide (Antigravity CLI)

This workspace is optimized for desk-research, UX benchmarking, usability testing, and litreview (evidence synthesis from documents). While originally configured for Claude Code via the `.claude/commands/` slash commands, it is fully compatible with Gemini running within the Antigravity CLI. 

This file acts as the bridge for Gemini to understand how to operate this workspace natively. All 19 slash commands have been fully ported into first-class Gemini Skills (`.agents/skills/*/SKILL.md`).

The workspace also carries a **design half** — the shared `ui-library/` design system that prototypes are built from. Its files are generated and read-only; see §13 before touching them.

---

## How to Work in this Repository

As Gemini, you do not use the `.claude` slash commands directly. Instead, you operate via your intent-matching capabilities or by invoking the skills inside `.agents/skills/`. When the user asks you to perform research tasks, follow these mapped workflows:

### 1. Starting New Research (`new-research`)
When the user asks to start a new research topic (or run `new-research`):
- Read the `.claude/.active-research` registry. Multiple studies may be active at once, so an existing active study does not block a new one; only warn if the new topic duplicates one already active. See `.claude/references/active-research.md`.
- Check for an optional `--type <benchmark | usability | litreview>` flag (defaulting to `benchmark`).
- **Confirm the goal:** Explicitly establish the `## Goal` (what we want to learn and why, or what decision the usability test informs) before scaffolding.
- Create a new directory at `research/<YYYY-MM-DD>-<topic-slug>`.
- Scaffold the directory by type (`README.md`, `PLAN.md`, `sources.md`, plus `platforms/` for platform benchmarks, `data/` for non-platform desk-research or quantitative/data studies, `sessions/` for usability, or `corpus/` for litreview). **Rule:** when doing other research aside from a platform benchmark, do not use `platforms/` to save notes or pillars — use `data/` (`data/<topic>/notes.md`) instead. A document-driven **literature review** is its own type: use `--type litreview`, which creates `corpus/` (not `data/`) — it is **gitignored**, so any user-supplied PDFs/reports dropped there never get committed, and you do not create `platforms/` or `data/` for a litreview study. The verified `evidence.md` is produced later by `gather-evidence`, not at scaffold time.
- **Append** the new folder path to the `.claude/.active-research` registry (preserving other active studies), bind this terminal to it by writing `.claude/.current-research/<session-id>`, and automatically refresh `BOARD.md` to show the new study as **Active**.
- Dispatch the Principal Researcher (`Mode A`) to review the drafted `PLAN.md` before user approval and capture/fielding.

### 1b. Focusing a Terminal (`focus-research`)
When several studies are active and the user wants *this* terminal to default to a
specific one (or runs `focus-research`):
- Confirm the named `<folder>` is a line in the `.claude/.active-research` registry; if not, tell the user to start it with `new-research` or check `research-board`.
- Write the folder path to `.claude/.current-research/<session-id>` (the session id is the UUID segment of the scratchpad path; create the dir if absent). See `.claude/references/active-research.md`.
- Report the terminal's new focus and list the other active studies.

### 2. Capturing Evidence (`benchmark` Studies)
- **Mobbin is the default source.** Use the Mobbin MCP tools (`search_screens`,
  `search_flows`, `search_sections`) to find the screens and flows the study needs. Platform
  is `ios` or `web` — **Mobbin has no Android coverage.**
- **Browser capture is the exception**, used only for a C1–C5 trigger recorded in `PLAN.md`:
  C1 our own product · C2 no Mobbin coverage · C3 the question needs live behaviour · C4
  currency is the question · C5 the question is Android-specific.
- **Mobbin-sourced:** download screens to `platforms/<platform>/reference/` (**gitignored**)
  and log each in a committed `references.md` table (screen, Mobbin URL, screen ID, local
  file, accessed). Write `flow.md` marking system-response claims as *inferred from screen
  sequence*. There is no `flow.gif`. **Never commit a Mobbin image** — this repo is public
  and the library is licensed.
- **Chrome-sourced:** **Redaction is CRITICAL (Hard Rule)** — before saving any visual
  evidence you MUST inject CSS or manipulate the DOM to blur personal data (avatars, names,
  emails) to comply with the workspace's zero-PII policy. Save screenshots as numbered PNGs
  in `platforms/<platform>/screenshots/`, plus `flow.gif`.
- Full standard: `.claude/references/mobbin-sourcing.md`.

### 2b. Gathering Evidence (`litreview` Studies) (`gather-evidence`)
When the active study is `Type: litreview` and the user asks to gather evidence (or
runs `gather-evidence`), this is the litreview analogue of benchmark capture — the
one method-specific step that produces the raw material `synth-findings` reads:
- Confirm the study is `Type: litreview`, and confirm `PLAN.md`'s Principal
  Researcher review recorded an **approved** verdict. This step is expensive
  (multi-agent adversarial verification) and must **not** run before that plan gate.
- Read `PLAN.md`'s research questions, provided corpus, search angles, and inclusion
  criteria, plus any documents already dropped into `corpus/` (these count as
  `provided` sources; anything the harness finds on the web counts as `found`).
- Invoke the `deep-research` skill/harness with a brief assembled from those inputs.
  Let it fan out searches, fetch sources, and adversarially verify claims (search →
  fetch → 3-vote), folding in the `corpus/` documents as anchor evidence.
- Write `sources.md` (one row per source `S1..Sn`: source, URL, provenance
  `provided`/`found`, accessed date, notes).
- Write `evidence.md` with `## Verified claims` (confidence label + `[S#]` citation
  per claim) and `## Refuted / weak claims` (quarantined — never promoted to
  findings).
- Report verified/refuted counts and point to `synth-findings` as the next step.

### 3. Usability Instrument Planning (`plan-usability`)
When the active study is `Type: usability` and the user asks to design the test plan:
- Draft `test-plan.md` in the research folder with non-leading task scenarios, moderator script, metrics (SEQ/SUS), and severity scale (0–4).
- Gate the instrument through the Principal Researcher (`Mode A — methodology review`) to check that tasks don't give away UI hints before presenting for user sign-off.
- Field sessions externally, then drop PII-redacted participant notes into `sessions/session-NN.md`.

### 4. Synthesizing Findings (`synth-findings`)
When asked to synthesize the active research:
- Resolve the target study per `.claude/references/active-research.md` (explicit folder, else this terminal's binding, else the sole active study, else ask) and note its `Type`.
- **Benchmark:** Read `platforms/*/notes.md` and generate `SYNTHESIS.md` with the 5-part feature structure (Feature Name, Short Description, Key Findings, Rationale, Validation). Ensure the key findings section follows the flow: **what the user sees, what the user does, and what the system does**.
- **Usability:** Read `test-plan.md` and `sessions/session-*.md` and generate `SYNTHESIS.md` ordered by **severity (highest first)**, citing pseudonymized participants (P01…).
- **Litreview:** Read `evidence.md` and `sources.md` (if `evidence.md` is missing, stop and tell the user to run `gather-evidence` first). Use only the `## Verified claims` as findings input. Generate `SYNTHESIS.md` as **themes → design implications**: a `## TL;DR`, then one `## Theme N` section per theme with findings as bullets carrying a confidence label and `[S#]` citation(s), a `## Design implications` section, a `## Refuted / weak claims` section (reproduced from `evidence.md`, never promoted to findings), a `## Evidence gaps for primary research` section, and a `## Sources table` mirroring `sources.md`.
- **Cite evidence by source shape** (see §2 and `.claude/references/mobbin-sourcing.md`). A platform folder with `screenshots/` is Chrome-sourced; one with `references.md` is Mobbin-sourced.
  - **Chrome-sourced:** embed the capture directly with relative Markdown, e.g. `![flow](platforms/<platform>/flow.gif)` or `![screen](platforms/<platform>/screenshots/01-onboarding.png)`.
  - **Mobbin-sourced:** cite the canonical Mobbin URL as a link, e.g. `[<platform> — <screen>](https://mobbin.com/screens/<id>)`. There is no `flow.gif`. **Never embed a Mobbin reference image** — `reference/` is gitignored, `SYNTHESIS.md` is committed, and this repo is public. Generate a gitignored reading copy instead: `powershell -NoProfile -File .claude/scripts/md_visualize.ps1 -Source research/<study>/SYNTHESIS.md`.
- Gate through the Principal Researcher (`Mode B — synthesis QA`) to auto-fix prose and flag structural gaps via inline `> [Principal Researcher]...` annotations before any `.docx` export. Export with `powershell -NoProfile -File .claude/scripts/md_to_docx.ps1 -Source "<research-folder>/SYNTHESIS.md" -Out "<research-folder>/docx/SYNTHESIS.docx"` — always into the gitignored `docx/` folder, never the study root (a docx can embed reference images invisibly). Use the PowerShell converter, not the Python one: the `python3` alias is not on PATH on this machine, and the PowerShell script's `-Out` is mandatory.

### 5. Research Peer-Review Debate (`review-research`)
When asked to review the active research synthesis:
- Run three chained panel personas (`research-skeptic`, `domain-expert`, `evidence-auditor`) from `.claude/personas/` against the stated `## Goal` + `Type`, debating the findings to strengthen them; the `domain-expert` may use scoped scholarly web-search.
- Have the Principal Researcher (`Mode C — peer-review moderation`) synthesize a `## Peer Review` block: per-finding **Robust / Strengthen / Unsupported** verdicts with a `### Legend`, a `### Strengthened findings` table, and a `### Actions to apply` list (each with the original wording preserved).
- Present the block and the strengthening actions in chat for user approval, then append `## Peer Review` to `SYNTHESIS.md` and apply the approved strengthenings into the findings. (The build decision now lives at `draft-prd`, in the design half.)

### 6. Canva Feature & Stakeholder Briefs (`brief-feature`)
When asked to create a Canva presentation deck for a reviewed study:
- Draft a skimmable slide outline branching on `Type` (`benchmark` feature story vs. `usability` severity-ranked findings).
- Gate the outline through the Principal Designer (`Mode R — design review`) and verify zero-PII compliance.
- Once approved by the user, build the presentation via Canva MCP tools using the free tier only.

### 7. The Design Half — Projects, PRDs & Prototypes (`new-design`, `draft-prd`, `design-prototype`, `export-prototype`)
Research is the **discover** half; design is the **make** half. One pipeline:
`discover → synthesize → DECIDE (PRD.md) → MAKE (design-prototype authors src/,
export-prototype ships build/standalone.html) → validate`. The build decision moved
here from the retired `draft-spec`: a PRD belongs to a **design project**, not to a
study — and so, since this plan, does the clickable prototype built from it. The
canonical contract is `.claude/references/design-projects.md`.

**A design project is not a study.** A study is point-in-time — dated, closed, never
reopened. A design project is long-lived and iterates, so it takes a plain slug (no date
prefix) and a mutable status:

```
design/<project>/
  README.md            Status: Active | Shipped | Archived · Informed by: <studies>
  PRD.md               the decision doc (written by draft-prd)
  tokens.overlay.css   OPTIONAL — per-project brand divergence
  src/                 index.html · app.js · data.js · img/ (authored by design-prototype)
  build/               standalone.html (generated by export-prototype, gitignored)
```

**Resolving the project — there is no registry.** Studies churn, so they need
`.claude/.active-research`; design projects are few and long-lived, so status lives in
each `README.md` and nowhere else. Only the per-terminal binding gets a file
(`.claude/.current-design/<session-id>`, gitignored). Resolve in order: explicit
`[project]` argument (which also **adopts** the binding) → this terminal's binding → the
sole `Status: Active` project → otherwise stop and ask. Naming a project explicitly *is*
focusing on it, so there is no `focus-design`; status is a one-line edit, so there is no
`close-design`.

**`new-design <project> [--informed-by research/<study> …]`** — creates the container
only: the folder, a `README.md` (status, `Informed by:`, problem statement), and an empty
`src/`. It does **not** write `PRD.md`. Refuse to clobber an existing project; require a
real problem statement rather than a `TBD`; validate each `--informed-by` study exists and
has a `SYNTHESIS.md`. Zero studies is allowed — record
`none (assumptions labelled in PRD §2)`. Bind this terminal, then refresh `BOARD.md`.

**`draft-prd [project] [--docx]`** — writes `design/<project>/PRD.md`:
- Resolve the project per the rule above; never create one here. Read its `README.md`
  (`## Problem`, `Informed by:`, `Design system:`). An existing `PRD.md` means this is a
  **revision** — preserve decisions that still hold and say what changed.
- **Evidence gate (soft, but honest).** Each cited study must be reviewed (`## Peer
  Review`, or legacy `## Agent Review`); a study with a synthesis but no review may not be
  cited as settled evidence — offer to run `review-research`, drop it, or demote its claims
  to §2 assumptions. Zero studies is allowed, but §2 must then declare the project
  unevidenced and label every claim as an assumption with a validation path.
- Read each cited `SYNTHESIS.md` in full. **benchmark** → features are "what good looks
  like" elsewhere, never proof our users need them; **usability** → findings are diagnosed
  pain, severity drives slice order; **litreview** → carry confidence labels and `[S#]`
  citations through verbatim. Drop findings the peer review marked **Unsupported**.
- Read `ui-library/COMPONENTS.md` for the class contract and ported status, unless the
  project is `Design system: independent`. Flag anything `not yet ported` — the prototype
  step **stops** on one rather than improvising.
- Draft **with the user**, section by section. The template is **17 numbered sections**
  plus a *Prototype Element Dictionary* appendix and a `## Stakeholder Review`: TL;DR ·
  Problem & Evidence · Primary JTBD · Related Jobs · Success Metrics · Appetite · Solution
  Shape · Vertical Slices · Acceptance Criteria per Slice · Users & Roles · Screens, IA &
  Empty States · Modal Reference · Data Model · Non-Goals · Rabbit Holes & Open Questions ·
  Technical Constraints · Dependencies. There is **no FR/MoSCoW section** — §9 carries it.
  §2 cites the study syntheses, §7 carries a **Mermaid** flowchart, and the appendix points
  at `ui-library/COMPONENTS.md`.
- Each **vertical slice** must be independently shippable and demoable end to end; a slice
  that cannot be demoed alone is a layer, so re-cut it. §6 Appetite is a fixed time box,
  not an estimate — if the slices do not fit, cut scope, never extend the box.
- Run a **stakeholder review of the slices** via the chained `product-manager`,
  `tech-lead`, and `head-of-product` personas (PM soundness; build effort + top risk;
  Go/Conditional Go/No-Go + sequencing). Record `## Stakeholder Review` with a
  `Slice | PM | Tech Lead | Head of Product` table. A **No-Go** slice must leave §8 — move
  it to §14 Non-Goals with the reason, or cut it.
- Gate the draft through the Principal Designer (`Mode S — PRD review`) for traceability,
  scope discipline against the appetite, slice integrity, flow completeness, IA coherence,
  and completeness of the set; revise on `revise`/`reject` and relay the verdict.
- Re-check any embedded capture for PII; never embed a Mobbin `reference/` image.
- Only on explicit user approval, write `PRD.md`. Optionally export `.docx` with
  `powershell -NoProfile -File .claude/scripts/md_to_docx.ps1 -Source
  "design/<project>/PRD.md" -Out "design/<project>/docx/PRD.docx"` — always into the
  gitignored `docx/` folder, never the project root — noting Mermaid renders as fenced
  code in Word. Log a dated row in the project `README.md`'s `## Status log`.

**`design-prototype [project] [--fidelity lo|hi] [--gate name,…] [--scope moment]`** —
authors the project's clickable prototype as multi-file source in `design/<project>/src/`,
built from `PRD.md` against `ui-library/`:
- Resolve the project per the rule above; never create one here. **Hard-gate on
  `PRD.md` existing** — if it does not, STOP and point to `draft-prd`. This is a harder
  gate than the old soft one: a prototype with nothing to trace to has nothing for the
  Principal Designer to judge.
- Read `PRD.md` in full (§7 Mermaid flow, §8 slices, §9 acceptance criteria, §11
  screens/IA/empty states, §12 modals, the Prototype Element Dictionary) plus each cited
  study's `SYNTHESIS.md`. Context-lock the token source, component source, the §11 screen
  list, and the Definition of Done — ask rather than guess if any is missing.
- **Component availability check — STOP on an unported component.** Cross-check every
  Prototype Element Dictionary entry against `ui-library/COMPONENTS.md`. Anything marked
  `not yet ported` has CSS but no behavior: STOP and offer to port it, swap the PRD to a
  ported component, or scope it out with `--scope` — never improvise a lookalike.
- Write `src/index.html`, `app.js`, `data.js`, `img/` using tokens and component classes
  only (no raw hex/px), every screen traced to a §11 entry and §8 slice, all states, and
  specific load-bearing copy. Self-audit against the **Definition of Done (G1–G8)** from
  `.claude/references/design-gates.md` and fix failures.
- Run `export-prototype` **without** `--artifact` as a fast local check, then gate the
  draft through the Principal Designer (`Mode T — prototype review`, now judging the
  authored `src/` against `PRD.md` and the design system, not a built HTML file) for
  traceability, gate compliance, flow completeness, fidelity honesty, and PII-safety;
  revise on `revise`/`reject` and relay the verdict.
- Log a dated status row in `design/<project>/README.md` (fidelity, screen count, gates
  passed/failed, Mode T verdict). **This command authors source only — it never
  publishes.** Tell the user the next step is `export-prototype --artifact`.

**`export-prototype [project] [--artifact]`** — builds `src/` into
`design/<project>/build/standalone.html` and gates it; the two commands are kept apart
because they fail differently (authoring fails on design questions, exporting on
mechanical ones — a missing asset, a raw hex value):
- Resolve the project per the rule above. If `src/index.html` is missing, STOP and point
  to `design-prototype`.
- Run `powershell -NoProfile -File .claude/scripts/build-prototype.ps1 -ProjectPath
  design/<project>`; on a non-zero exit relay the builder's message verbatim and STOP.
- Run `powershell -NoProfile -File .claude/scripts/check-prototype.ps1 -Path
  design/<project>/build/standalone.html` (add `-OverlayPath
  design/<project>/tokens.overlay.css` if it exists — without it the overlay's own
  declarations count as raw values outside the recognised design-system blocks and **rule
  2** fails with `raw hex outside the design-system files: #…`; rule 3 is unaffected,
  since an overlay may only redefine names `tokens.css` already defines). Branch on
  `$LASTEXITCODE`, never on
  output text, and report **every** violation. If `tokens.css`/`components.css` was not
  found inlined verbatim, the raw-value rule did not run — say so; a skipped rule is not a
  passed gate.
- Without `--artifact`, stop here and report the built path and gate result.
- With `--artifact`: re-check for internal specifics, un-redacted PII, and organization
  impersonation; ask for **explicit confirmation** naming what will publish (Artifacts
  start private); then publish — from a scratchpad copy with the outer `<!DOCTYPE>` /
  `<html>` / `<head>` / `<body>` tags stripped (styles, scripts, and body content kept),
  because the Artifact tool supplies its own document skeleton and would otherwise nest one
  document inside another; `build/standalone.html` itself stays a complete document.
  **Note for Gemini:** publishing to
  `claude.ai/code/artifacts` via the Artifact tool is a Claude-specific surface — where
  that tool isn't available, hand over the built `standalone.html` locally instead and say
  so explicitly in the report. Use a **stable file path per project** so a later export
  redeploys the same URL rather than minting a new one.
- Log a dated status row in `design/<project>/README.md` (built, gate result, Artifact URL
  if published).

### 8. Gemini Notes on Prototyping (`design-prototype`, `export-prototype`)
Both commands are described in full in §7 above, alongside the rest of the design half —
they act on a **design project**, never a study, and the Artifact-tool caveat noted there
is the only Gemini-specific behavior: where the Artifact tool is unavailable,
`export-prototype --artifact` hands over the built `standalone.html` locally instead of
publishing it, and reports that explicitly.

### 9. Closing Research & Pattern Extraction (`close-research`)
When asked to close the active research:
- Verify that `SYNTHESIS.md` exists and check whether `## Peer Review` (or legacy `## Agent Review`) is present.
- **Pattern Extraction:** Dispatch the Principal Designer (`Mode P`) to extract reusable design patterns (`benchmark-observed` or `usability-validated`) and merge them into `research/PATTERNS.md`. For a **litreview** study it instead harvests evidence-based **design principles** (not observed UI patterns) — it must not force UI patterns where none exist; if the synthesis yields no genuine, evidence-grounded principle, it records that plainly and adds nothing.
- Mark the status in the research's `README.md` to `Closed`, remove the study's line from the `.claude/.active-research` registry (leaving other active studies), and prune any per-terminal binding in `.claude/.current-research/` that pointed at it.
- Refresh `BOARD.md` so the study moves from **Active** to **Closed & archived**.

### 10. Publishing (`publish-research`)
When asked to publish or commit:
- Perform a final visual safety check on all benchmark captures (`screenshots/*.png`, `flow.gif`) and usability session notes (`session-*.md`) to guarantee zero PII is visible.
- Ensure no paywalls were breached.
- **Mobbin redistribution guard (required).** After staging and before committing, run:

  ```bash
  git diff --cached --name-only | grep -E '(/reference/|\.visual\.md$)' && echo LEAK || echo "clean — no reference/ or .visual.md staged"
  git diff --cached --name-only | grep -E '\.docx$' | grep -v '/docx/' && echo DOCX_LEAK || echo "clean — no stray .docx staged"
  ```

  Both lines always print something and exit 0. If a line prints `LEAK` or `DOCX_LEAK` (with the offending path above it), **STOP** and tell the user exactly which files are staged and why they cannot be pushed: `reference/` holds licensed Mobbin library images, `*.visual.md` embeds them, and a `.docx` outside the gitignored `docx/` folder may embed them invisibly. This repo is public. Unstage them and re-run the gate — do not use `git add -f` to override.
- Confirm a `litreview` study's `corpus/` is not staged (it must stay gitignored).
- Commit via standard `git` terminal commands and `git push` (or `gh pr create`).

### 11. Showing the Board (`research-board`)
When asked to show the board, or which studies or design projects exist:
- Treat the `research/` and `design/` folders as the source of truth.
- Print three tables (`Active research`, `Closed & archived research`, `Design projects`) to the terminal.
- Automatically refresh `BOARD.md` (all three tables + `_Last updated:_` date) so the committed board never drifts.
- Prune stale per-terminal bindings in `.claude/.current-research/` and `.claude/.current-design/` as housekeeping.
- The command keeps its research-centric name; renaming it would churn every skill file for no gain.

### 12. Benchmark Analysis Lenses (`heuristic-eval`, `a11y-audit`, `extract-tokens`)
Optional retrospective analysis passes over a **benchmark** study's captured evidence (`platforms/`), writing to a `lenses/` subfolder:
- **Heuristic eval (`heuristic-eval`):** Score each captured platform against Nielsen's 10 heuristics (violations and exemplary patterns), severity-ranked (`0–4`).
- **A11y audit:** Sample pixels with Pillow to measure colour contrast, target size, and visible labels (`lenses/a11y-audit.md`).
- **Extract tokens:** Sample design tokens (colour/type/spacing/radius) with Pillow (`lenses/tokens.md`).

### 13. The `ui-library/` Design System (`sync-tokens`)
Separate from the research lifecycle. `ui-library/` is the shared vocabulary a prototype is built *from*, so prototypes look like the real product instead of improvising a lookalike. The full contract is `.claude/references/design-system.md` — read it before touching anything here.

- **`ui-library/tokens.css`, `components.css`, and `tokens.json` are GENERATED and read-only.** They are extracted verbatim from the upstream production repo by `sync-tokens`, which scrubs internal identifiers (a project UUID, an unannounced rebrand, internal PRD and wiki paths) and the external-host font `@import` before writing. The upstream repo URL is deliberately **not stored in this repo** — `sync-tokens` asks for it on every run and passes it as `-RepoUrl`. **Never hand-edit them and never commit a hand-edit.** The sync is one-directional; nothing flows back upstream.
- **`sync-tokens --check` is the drift guard.** It writes no file and exits non-zero on any divergence from source for the three generated files. Run it before trusting the library. `--ref <branch|sha>` pins a specific upstream revision.
  ```bash
  powershell -NoProfile -File .claude/scripts/sync-tokens.ps1 -RepoUrl <url> -Check
  ```
- **`ui-library/TOKENS.md`'s provenance block is NOT machine-verified.** `--check` never reads it. Treat it as a hand-editing convention, not a guarantee.
- **Hand-written files** in `ui-library/` — `COMPONENTS.md` (each upstream component's class contract and ported status) and `behaviors.js` (port-on-demand JS) — are authored normally and are not covered by the read-only rule.
- **Port on demand, fail loudly.** A component marked `not yet ported` has working CSS but no behavior. When a prototype calls for one, **STOP** and say so — do not improvise a lookalike.
- **Per-project divergence** goes in `design/<project>/tokens.overlay.css`, which may redefine an existing token name but never introduce a new one. Never edit a synced file to change a value.
- **Typography is approximate by design.** The external font `@import` is stripped for CSP compliance, so text falls back to system faces. Do not "fix" this by re-adding an external font link.
- **Gate a built prototype** before publishing it:
  ```bash
  powershell -NoProfile -File .claude/scripts/check-prototype.ps1 -Path <built.html>
  ```
  Five rules: no external hosts, no raw style values outside the token/component files, every `var(--x)` resolves (this is also what catches an overlay defining a name absent from `tokens.css`), every class used in the markup exists in `components.css`, and a PII lint. Every violation is listed, not just the first. The PII rule is a lint, not a guarantee — human review is still required.

---

## Skill Architecture

All 19 skills reside in `.agents/skills/<skill-name>/SKILL.md` with complete YAML frontmatter (`name`, `description`). Gemini automatically triggers these workflows when matching conversational intent or when invoked directly.
