# Gemini Integration Guide (Antigravity CLI)

This workspace is optimized for desk-research, UX benchmarking, usability testing, and litreview (evidence synthesis from documents). While originally configured for Claude Code via the `.claude/commands/` slash commands, it is fully compatible with Gemini running within the Antigravity CLI. 

This file acts as the bridge for Gemini to understand how to operate this workspace natively. All 16 slash commands have been fully ported into first-class Gemini Skills (`.agents/skills/*/SKILL.md`).

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
- Present the block and the strengthening actions in chat for user approval, then append `## Peer Review` to `SYNTHESIS.md` and apply the approved strengthenings into the findings. (The build decision now lives at `draft-spec`.)

### 6. Canva Feature & Stakeholder Briefs (`brief-feature`)
When asked to create a Canva presentation deck for a reviewed study:
- Draft a skimmable slide outline branching on `Type` (`benchmark` feature story vs. `usability` severity-ranked findings).
- Gate the outline through the Principal Designer (`Mode R — design review`) and verify zero-PII compliance.
- Once approved by the user, build the presentation via Canva MCP tools using the free tier only.

### 7. Build-Ready Spec Drafting (`draft-spec`)
When asked to turn a reviewed study into a build-ready spec — optional, run only on
request, one `SPEC.md` per study at the study root:
- Locate the study (named folder, else resolve per `.claude/references/active-research.md`);
  confirm `SYNTHESIS.md` exists, else tell the user to run `synth-findings` first.
- **Hard gate:** require `SYNTHESIS.md` to already contain a `## Peer Review` section
  (written by `review-research`), or a legacy `## Agent Review`. If neither is present,
  stop and tell the user to run `review-research` first — proceed only on an explicit override.
- Read `SYNTHESIS.md` (incl. its `## Peer Review`, or legacy `## Agent Review`, and any `## Gaps & caveats`) plus the
  `README.md` `Type`/`Goal`/`Scope`. Branch on `Type`: **benchmark** → a forward spec
  (features become requirements, prioritized by the synthesis's own sequencing; Go/No-Go
  is decided at the stakeholder review below, not read from the synthesis); **usability** → a redesign
  spec (findings' recommendations become requirements, priority follows severity).
- Draft `SPEC.md` with the user section by section: MoSCoW-prioritized **functional
  requirements** (each with a stable ID, a **Source** back-reference to its synthesis
  entry + evidence, acceptance criteria, edge cases), a **Mermaid** user-flow diagram
  plus written step-by-step, an **information architecture** Mermaid sitemap + screen
  table, a **wireframe-level screen list** (purpose, content, actions, FRs satisfied,
  states), cross-cutting **edge cases & error states**, a **traceability matrix** (FR ↔
  synthesis source ↔ screen), and flagged **assumptions & open questions**. Every
  requirement must trace to a synthesis entry — never invent scope.
- After drafting, run a **stakeholder review** of the SPEC's functional requirements via
  the chained `product-manager`, `tech-lead`, and `head-of-product` personas (PM soundness;
  build effort; Go/Conditional Go/No-Go), recording a `## Stakeholder Review` section and
  dropping any No-Go FR, before the Principal Designer Mode S gate.
- Gate the draft through the Principal Designer (`Mode S — spec review`) for
  traceability, scope discipline, flow completeness, IA coherence, and completeness of
  the required set; revise on `revise`/`reject` and relay the verdict.
- Re-check any embedded capture for PII before writing.
- Only on explicit user approval, write `SPEC.md` to the study folder root. Optionally
  export `.docx` with `powershell -NoProfile -File .claude/scripts/md_to_docx.ps1
  -Source "<research-folder>/SPEC.md" -Out "<research-folder>/docx/SPEC.docx"` — always
  into the gitignored `docx/` folder, never the study root — noting Mermaid renders as
  fenced code in Word. Log a dated "spec drafted" entry in the study `README.md`.

### 8. Clickable Prototypes (`design-prototype`)
When asked to turn a synthesized study into a clickable prototype — optional, run only
on request:
- Locate the study and confirm `SYNTHESIS.md` exists (else point to `synth-findings`).
  Prefer `SPEC.md` as the source of the screen list, flow, IA, and per-screen states if
  present; if absent, warn that traceability will be weaker, offer to run `draft-spec`
  first, and suggest `--fidelity lo` for a cheap first pass — proceed only on the
  user's yes.
- Support `--fidelity lo|hi` (default `hi`: full tokens/colour/type/motion plus the
  full Definition-of-Done audit; `lo`: grayscale structure-only, reduced gate set), an
  à-la-carte `--gate <name,…>` fast path that redeploys the same existing artifact, and
  an optional `--scope <moment>` to prototype only one slice of the flow.
- Context-lock first (token source, reference screens, personas, Definition of Done) —
  ask rather than guess if any is missing.
- Generate a single self-contained HTML prototype grounded in the SPEC/synthesis (inline
  all CSS/JS, embed captures as `data:` URIs, no invented screens or data — flag
  extrapolations as assumptions), then self-audit against the **Definition of Done
  (G1–G8)** from `.claude/references/design-gates.md` and fix failures.
- Gate the draft through the Principal Designer (`Mode T — prototype review`) for
  traceability, gate compliance, flow completeness, fidelity honesty, and PII-safety;
  revise on `revise`/`reject` and relay the verdict.
- Re-check for zero internal specifics and no un-redacted PII, and that nothing
  impersonates a real organization — this step is outward-facing like `brief-feature`
  and `publish-research`.
- **Note for Gemini:** publishing to `claude.ai/code/artifacts` via the Artifact tool is
  a Claude-specific surface. Where that tool isn't available, produce the same
  self-contained HTML file locally (in the study folder or scratchpad, per the user's
  preference) instead of publishing it, and say so explicitly in the report.
- Only on explicit user approval, publish/save the prototype. Log a dated "prototype
  drafted" entry in the study `README.md` (fidelity, screen count, gates passed/failed,
  Mode T verdict, and the Artifact URL or local path).

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

### 11. Showing the Research Board (`research-board`)
When asked to show the research board, or which studies exist:
- Treat `research/` folders as the source of truth.
- Print two tables (`Active` and `Closed & archived`) to the terminal.
- Automatically refresh `BOARD.md` (`## Active` and `## Closed & archived` tables + `_Last updated:_` date) so the committed board never drifts.

### 12. Benchmark Analysis Lenses (`heuristic-eval`, `a11y-audit`, `extract-tokens`)
Optional retrospective analysis passes over a **benchmark** study's captured evidence (`platforms/`), writing to a `lenses/` subfolder:
- **Heuristic eval (`heuristic-eval`):** Score each captured platform against Nielsen's 10 heuristics (violations and exemplary patterns), severity-ranked (`0–4`).
- **A11y audit:** Sample pixels with Pillow to measure colour contrast, target size, and visible labels (`lenses/a11y-audit.md`).
- **Extract tokens:** Sample design tokens (colour/type/spacing/radius) with Pillow (`lenses/tokens.md`).

### 13. The `ui-library/` Design System (`sync-tokens`)
Separate from the research lifecycle. `ui-library/` is the shared vocabulary a prototype is built *from*, so prototypes look like the real product instead of improvising a lookalike. The full contract is `.claude/references/design-system.md` — read it before touching anything here.

- **`ui-library/tokens.css`, `components.css`, and `tokens.json` are GENERATED and read-only.** They are extracted verbatim from the Solve Education production repo by `sync-tokens`, which scrubs internal identifiers (a project UUID, an unannounced rebrand, internal PRD and wiki paths) and the external-host font `@import` before writing. **Never hand-edit them and never commit a hand-edit.** The sync is one-directional; nothing flows back upstream.
- **`sync-tokens --check` is the drift guard.** It writes no file and exits non-zero on any divergence from source for the three generated files. Run it before trusting the library. `--ref <branch|sha>` pins a specific upstream revision.
  ```bash
  powershell -NoProfile -File .claude/scripts/sync-tokens.ps1 -Check
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

All 16 skills reside in `.agents/skills/<skill-name>/SKILL.md` with complete YAML frontmatter (`name`, `description`). Gemini automatically triggers these workflows when matching conversational intent or when invoked directly.
