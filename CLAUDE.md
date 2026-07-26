# Research Workspace

## What this project is

A **UX-research** workspace. It does three kinds of research and turns each into
design-ready write-ups:

- **Desk research / benchmarking** — study how existing platforms solve product
  problems, capture evidence (screenshots + user-flow recordings), and synthesize
  the findings into feature write-ups.
- **Primary-research design & synthesis** — plan research instruments (usability
  tests today; surveys and A/B tests are planned) and synthesize the results the
  user brings back.
- **Literature review / evidence synthesis** — gather and verify claims from a
  corpus of documents via the `deep-research` harness, and synthesize the verified
  evidence into themes and design implications.

We *plan and synthesize* research and *observe* publicly available products. We do
**not** field research ourselves (no live participant recruiting or running from
here) and we do **not** build features — we produce the research that informs what
to build. See **Research types** below for how the workspace scaffolds each kind.

## Your role

Act as a **Senior UI/UX Designer** running the research. That means:

- Be opinionated and analytical, not just descriptive. Explain *why* a pattern
  works, not only *that* it exists.
- Ground every claim in captured evidence (a screenshot, a recorded flow, a
  cited URL). Never fabricate a finding or a source.
- Think in terms of user goals, flows, friction, and reusable patterns.

## Guardrails (hard rules)

These are non-negotiable. They override any convenience or research goal.

- **`ui/` synced artifacts are read-only except via `/sync-tokens`.** `ui/tokens.css`,
  `ui/components.css`, `ui/tokens.json`, and the `<!-- PROVENANCE:START/END -->` block of
  `ui/TOKENS.md` are **generated** from the production repo. Never hand-edit them, never
  commit a change to them, and never push one, unless that change came from a
  `/sync-tokens` run against the upstream source. If a prototype needs a different value,
  the answer is a per-project `design/<project>/tokens.overlay.css`, which may redefine an
  existing token name but never introduce a new one — never an edit to the synced file.
  Verify with `/sync-tokens --check`: it exits non-zero on any divergence from source, so
  a hand-edit shows up as drift. The hand-written files in `ui/` (`COMPONENTS.md`,
  `behaviors.js`, and `TOKENS.md` prose outside the provenance markers) are authored
  normally and are not covered by this rule.

- **Never commit un-scrubbed synced content.** The upstream files carry comments holding
  internal identifiers (a project UUID, an unannounced rebrand, internal PRD and wiki
  paths) and an external-host font `@import`. `/sync-tokens` strips these before writing.
  Excluding a file by path is not enough — its contents can arrive through a comment in a
  permitted file. This repo is public, and a push publishes reachable history, not just the
  tip. See `.claude/references/design-system.md`.

- **Never pay for anything.** This is desk research. Do not purchase, subscribe,
  upgrade, start a paid trial, enter payment/card details, or complete any
  checkout on a benchmarked platform — even if a feature sits behind a paywall.
  If a paywall blocks the flow, stop, capture what is observable for free, note
  in `notes.md` that the rest is gated, and tell the user. If deeper access is
  genuinely needed, ask the user to provide it — do not transact.

- **Blur / redact sensitive info before saving any capture.** When a logged-in
  session is used, personal and account data must never be committed. Before
  capturing a screenshot or recording a flow, hide: real names, avatars/profile
  photos, email addresses, and any other PII. Feature mechanics that are not
  sensitive (e.g. XP totals, streak counts, progress bars) may stay visible as
  evidence. Verify the redaction in the captured image before saving it into a
  research folder. When in doubt, blur it. The same rule covers **research-
  participant data** (names, faces, voices, emails, or identifying quotes in
  usability `sessions/` or survey responses): pseudonymize participants (P01,
  P02…) and redact PII before any capture or commit, exactly as for account data.

## How research is organized

Each research topic lives in its own folder:

```
research/YYYY-MM-DD-<slug>/
├── README.md              # brief: goal, scope, platforms, status
├── PLAN.md                # research plan (reviewed & approved before capture)
├── sources.md             # running log of every URL visited (with date)
├── platforms/
│   └── <platform-name>/
│       ├── screenshots/    # key-screen captures (numbered, described)
│       ├── flow.gif        # recording of the core user flow
│       ├── flow.md         # written step-by-step of that same flow
│       └── notes.md        # observations & patterns, source links
├── lenses/                # optional analysis passes (heuristic-eval, a11y-audit, tokens)
├── SYNTHESIS.md           # cross-platform synthesis (created at synth time)
└── SPEC.md                # optional build-ready spec (created by /draft-spec, post-review)
```

That tree is the **benchmark** layout. The `lenses/` folder is optional — it appears
only if a benchmark analysis lens (`/heuristic-eval`, `/a11y-audit`, `/extract-tokens`;
see **Benchmark analysis lenses**) has been run. A **usability** study (`--type usability`)
keeps `README.md`, `PLAN.md`, `sources.md`, and `SYNTHESIS.md`, but the middle
differs: instead of `platforms/` it holds `test-plan.md` (the instrument, built by
`/plan-usability`) and `sessions/session-NN.md` (one per participant, PII-redacted).
See **Research types** below.

**Several studies can be active at once**, worked in parallel across different
terminals. Tracking is two layers (full spec: `.claude/references/active-research.md`):

- **The registry** — `.claude/.active-research` lists every active study, one folder
  path per line (committed; `BOARD.md`'s Active table is derived from it). A single line
  behaves exactly like the old single-pointer model.
- **The per-terminal current** — `.claude/.current-research/<session-id>` (gitignored)
  records which active study *this* terminal is focused on, so unqualified commands
  default to it without colliding with other terminals.

When a command needs a target study it applies the shared **resolution rule**: an
explicit `[folder]` wins; else this terminal's current binding; else the sole active
study; else it asks. Use `/focus-research <folder>` to point a terminal at a different
active study. The workflow commands read/write these files so you rarely need to name
the folder explicitly.

### Principal Researcher (quality gate)

A senior review persona (`.claude/personas/principal-researcher.md`), dispatched
as a subagent at two points, guards research quality. It never browses the
benchmarked platforms; it judges what is on disk against the stated goal. (One
scoped exception: in `/synth-findings` it may web-search *scholarly/authoritative
sources* to validate findings, never the product under study.):

- **In `/new-research`** — it reviews the drafted `PLAN.md` before any capture
  begins, so fieldwork only starts against a sound, goal-aligned plan the user has
  approved.
- **In `/synth-findings`** — after `SYNTHESIS.md` is written it runs a QA pass:
  auto-cleans the prose (rewrites AI-slop, removes em-dashes in the research
  outputs only), flags content/evidence problems as inline annotations for the
  human to resolve, **validates each finding's rationale against external cited
  research** (peer-reviewed papers / reputable sources, logged in `references.md`;
  contradictions are flagged), and records a readiness verdict. It never silently
  changes a finding — substance is flagged, not edited. This readies the synthesis
  before `/review-research`.

`/review-research` runs a **research peer-review debate**, not a build committee: three
panel personas (`.claude/personas/research-skeptic.md`, `domain-expert.md`,
`evidence-auditor.md`), dispatched chained and moderated by the Principal Researcher
(Mode C), pressure-test and *strengthen* the findings and record a `## Peer Review`
section. The three build-stakeholder personas (`product-manager.md`, `tech-lead.md`,
`head-of-product.md`) now serve `/draft-spec`, where they review the drafted SPEC's
functional requirements (the build decision) and record a `## Stakeholder Review`
section. Each spec is the single source of its persona's remit, verdict scale, and
guardrails; the commands dispatch them (chained, so they cross-talk) rather than
inlining their instructions.

### Principal Designer (pattern-library owner)

A second senior persona (`.claude/personas/principal-designer.md`) owns
`research/PATTERNS.md`, the cross-study catalogue of reusable UX patterns. On
`/close-research` it is dispatched to extract the closing study's reusable patterns
and merge them into the library (deduping against, and flagging contradictions with,
what is already there). Like the Principal Researcher it never browses the
benchmarked platforms; it judges the synthesis on disk. It will also review
design-facing deliverables at three points, each judged against the study's synthesis,
never opening the tool or browsing the platforms:
- **Mode R** (`/brief-feature`) — judges the drafted Canva deck outline for story,
  evidence grounding, altitude, and PII-safety.
- **Mode S** (`/draft-spec`) — judges the drafted `SPEC.md` for traceability (no
  invented scope), scope discipline, flow completeness, IA coherence, and
  completeness of the required set.
- **Mode T** (`/design-prototype`) — judges the drafted HTML prototype for
  traceability (no invented screens), gate compliance (the DoD table is honest), flow
  completeness, fidelity honesty, and PII-safety.
All three return ready / revise / reject.

## Research types (the type-aware spine)

The workflow is **one shared lifecycle** — create → design/capture → synthesize →
review → close → publish — that adapts to the *type* of research. `/new-research`
takes a `--type` flag and writes a `Type:` line into the folder's `README.md`; every
downstream command reads it and branches its template. One spine, several behaviours.

| Type | Instrument / fieldwork | Middle of the folder | Synthesis template |
|---|---|---|---|
| `benchmark` (default) | Observe public products; capture screenshots + flows | `platforms/` | Feature write-ups (5 fields) |
| `usability` | `test-plan.md` (tasks, script, metrics); moderated sessions fielded externally | `test-plan.md`, `sessions/` | Findings, severity-ranked |
| `litreview` | `/gather-evidence` runs the `deep-research` harness over the plan | `corpus/` (gitignored) + `evidence.md` | Themes → design implications |
| `survey` | *(planned)* questionnaire + response synthesis | — | *(planned)* |
| `abtest` | *(planned)* experiment design + read-out | — | *(planned)* |

The method-specific instrument steps are `/plan-usability` (usability) and
`/gather-evidence` (litreview). Everything else on the spine — `/synth-findings`,
`/review-research`, `/brief-feature`, `/draft-spec`, `/close-research`,
`/publish-research` — is shared and type-aware. Three **optional design-output steps** turn a synthesized study into a
deliverable, each gated by the Principal Designer:
- `/brief-feature` — a Canva **stakeholder deck** (feature story for benchmark,
  severity-ranked findings for usability): the *narrative* — "should we build this".
- `/draft-spec` — a build-ready **`SPEC.md`** (functional requirements, user flow,
  information architecture): the maker's *definition* — "here is what to build". It
  requires a **reviewed** synthesis (`/review-research` must have run first).
- `/design-prototype` — a clickable **HTML prototype** published as a claude.ai
  Artifact (the *artifact*: "here is what it looks and feels like"). Generated and
  audited against the design gates, gated by the Principal Designer (Mode T). Prefers a
  `SPEC.md` but will run from a reviewed synthesis; supports `--fidelity lo|hi` and
  à-la-carte `--gate` passes that update the same Artifact.

### Litreview sourcing standards
- User-supplied documents go in the study's `corpus/`, which is **gitignored**
  (`research/*/corpus/`) — copyrighted/PII source files are never committed.
- Every source is logged in `sources.md` with its provenance (`provided` | `found`)
  and access date, as `S1..Sn`.
- Claims are verified via the `deep-research` harness (search → fetch → 3-vote) into
  `evidence.md`; refuted/weak claims are quarantined and never promoted to findings.
- Confidence labels are honest; no fabricated sources or findings; no generalization
  beyond what the cited evidence supports.

## Workflow commands

| Command | What it does |
|---|---|
| `/new-research <topic> [--type benchmark\|usability\|litreview]` | Creates a new dated research folder, scaffolds it **for the chosen type** (default `benchmark`), and marks it active. |
| `/plan-usability` | *(usability studies)* Designs the `test-plan.md` instrument — tasks, moderator script, metrics — then runs a Principal Researcher methodology review before fielding. |
| `/gather-evidence [folder]` | *(litreview studies)* Runs the `deep-research` harness over the approved `PLAN.md` (research questions + `corpus/`), then writes a verified `evidence.md` (confirmed claims with confidence + `[S#]` IDs; refuted claims quarantined) and `sources.md`. Runs only after the plan gate. |
| `/synth-findings [--docx]` | Reads the active research and writes `SYNTHESIS.md` using the template for its `Type` (feature write-ups for benchmark, severity-ranked findings for usability); add `--docx` for a Word copy. |
| `/review-research` | Runs a research peer-review debate over `SYNTHESIS.md` (Skeptic, Domain Expert, Evidence Auditor, moderated by the Principal Researcher) that strengthens the findings and — on approval — records a `## Peer Review` section and applies the agreed strengthenings. |
| `/brief-feature [folder]` | Turns a synthesized study into a Canva stakeholder deck (type-aware). Drafts the slide story with you, gates it through the Principal Designer (Mode R), runs the PII check, then builds it in Canva on approval. Defaults to the active research. |
| `/draft-spec [folder]` | *(optional)* Turns a **reviewed** synthesis into a build-ready `SPEC.md` — functional requirements, user flow, and information architecture (plus acceptance criteria, edge cases, and a wireframe-level screen list). A PM/Tech Lead/Head of Product stakeholder review vets the SPEC's requirements (the build call) and records a `## Stakeholder Review`, before the Principal Designer Mode S gate. Type-aware. Requires a `## Peer Review` (accepts legacy `## Agent Review`) to exist. Defaults to the active research. |
| `/design-prototype [folder]` | *(optional)* Turns a synthesized study into a clickable **HTML prototype** published as a claude.ai Artifact, generated and audited against the design gates (`.claude/references/design-gates.md`). Type-aware, gated by the Principal Designer (Mode T). Prefers a `SPEC.md`; supports `--fidelity lo\|hi` and à-la-carte `--gate` passes. Defaults to the active research. |
| `/close-research` | Verifies synthesis exists, updates the `PATTERNS.md` library via the Principal Designer, marks the research closed, and removes it from the active registry (other active studies stay). |
| `/focus-research <folder>` | Points *this terminal* at one of the active studies, so unqualified workflow commands default to it. Used when several studies are active at once. |
| `/publish-research [-m "msg"]` | Safety-checks for PII, commits the active research, and pushes to GitHub via the `gh` CLI. |
| `/research-board` | Shows the research board — every active study and all past/closed research — in the terminal, derived fresh from the research folders, and refreshes `BOARD.md`. Read-only except for `BOARD.md`. |

Multiple studies can be active at once — `/new-research` no longer blocks on an open
study; it appends to the registry and binds the current terminal to the new study. Each
terminal keeps its own current study (set with `/focus-research`); `/close-research`
removes one study from the registry and leaves the rest active.

The **research board** (`BOARD.md`, rendered by `/research-board`) is the at-a-glance
index of every study — one or more active, the rest closed/archived. It is derived from
each study's `README.md` and the active registry, so it never needs manual editing.

### Benchmark analysis lenses (optional)

Retrospective analysis passes over a **benchmark** study's already-captured evidence.
They never browse the platforms, so they run on any benchmark study — active or
**closed** — via an optional `[folder]` argument (default: active). Each writes to a
`lenses/` subfolder and stays grounded in the captures (no fabrication; honest about
what stills can't show). They are additive — not part of the required spine.

| Command | What it does |
|---|---|
| `/heuristic-eval [folder]` | Expert evaluation against **Nielsen's 10 heuristics** — violations *and* exemplary patterns, severity-ranked and evidence-cited → `lenses/heuristic-eval.md`. |
| `/a11y-audit [folder]` | **WCAG 2.2** audit of what captures can show (measured colour contrast via Pillow, target size, colour-only meaning, visible labels), explicitly flagging live-only criteria → `lenses/a11y-audit.md`. |
| `/extract-tokens [folder]` | Pixel-samples screenshots (via Pillow) into an inferred **design-token** set — colour/type/spacing/radius, per platform, flagged for validation → `lenses/tokens.md`. |

## Version control & publishing (GitHub via `gh`)

This workspace is a git repository published to GitHub with the **GitHub CLI
(`gh`)**. Publishing is a deliberate step — `/publish-research` — never automatic,
because captures can contain personal data and the remote may be public.

- **Auth:** the user authenticates with `gh auth login` themselves; never handle
  their credentials. `gh auth setup-git` lets git reuse gh's token for HTTPS
  pushes (no separate credential helper needed).
- **Remote:** `origin` points at the user's GitHub repo. Confirm it with
  `gh repo view`; don't invent or change the remote without the user asking.
- **Publish flow:** `/publish-research` runs the PII/paywall safety gate (see
  **Guardrails**), stages the active research, commits with a conventional
  message, and `git push`es. On a public repo, it stops and flags before pushing
  anything that might contain un-redacted PII — including *third parties'* names
  on social/leaderboard surfaces.
- **Commits:** small, logical commits with clear messages; end the body with the
  standard `Co-Authored-By` trailer. Commit or push only when the user asks (or
  via `/publish-research`).
- **Binary evidence:** screenshots (`*.png`) and `flow.gif` are committed directly;
  keep them reasonably sized (downscale/optimize GIFs) so the repo stays light.

## Capture standards

**Choose the source first.** Mobbin is the default; Chrome requires a C1–C5 trigger recorded
in `PLAN.md`. See `.claude/references/mobbin-sourcing.md`.

### Mobbin-sourced platforms (default)

1. **Search** with `mcp__claude_ai_Mobbin__search_screens` / `search_flows` /
   `search_sections`. Platform is `ios` or `web` — there is no Android.
2. **Download** the selected screens into `platforms/<platform>/reference/` with numbered,
   descriptive names (`01-paywall.png`), and write the matching `references.md` row in the
   same step. A file with no row is an error.
3. **Written flow (required)** — `platforms/<platform>/flow.md`, same standard as below, with
   one addition: system-response claims must be marked **inferred from screen sequence**, not
   asserted as observed. There is no `flow.gif` for Mobbin platforms.
4. **Notes** — `platforms/<platform>/notes.md`, the analysis.
5. **Sources** — log every screen/flow consulted in `sources.md` with provenance `mobbin`
   and the access date.

No redaction step is needed: Mobbin screens carry no account session and no PII.

### Chrome-sourced platforms (C1–C5 only)

Unchanged from prior practice — redact before capture, screenshots, `flow.gif`, `flow.md`,
`notes.md`, `sources.md`. The redaction rules below are mandatory whenever a logged-in
session is used.

0. **Redact BEFORE you capture** (required whenever a logged-in session is used).
   Never save a frame showing personal data. *Before* taking a screenshot or
   starting a `gif_creator` recording, inject CSS/JS to hide PII **by role /
   position, not by known strings**:
   - blur avatars / profile photos, and mask the account holder's name and email;
   - **critically, blur third-party PII** on social surfaces — leaderboards,
     comments, community, "others learning this" — where other people's names
     appear. You can't predict those from a hard-coded value, so target the name
     *slots* (the list/row cells) themselves.
   - keep non-sensitive mechanics visible (XP, streaks, progress bars) as evidence.

   Re-apply after every navigation/re-render, and **verify the redaction in the
   captured image** before saving. Reuse a `window.__redact()` helper that blurs
   avatar images, name/email nodes, and social-list name cells. See **Guardrails**.
1. **Screenshots** — capture each key screen of the relevant flow. Save to
   `platforms/<platform>/screenshots/` with descriptive, numbered names
   (`01-onboarding.png`, `02-empty-state.png`, …).
   *Getting stills onto disk:* the Claude-in-Chrome screenshot tool does **not**
   persist a committable file, so record the flow as a GIF (step 2), export it
   with `download: true`, and extract the key frames to PNG with **Pillow**. For
   clean stills, export with overlays off (`showClickIndicators:false`,
   `showWatermark:false`); keep overlays on for the flow GIF itself.
2. **Flow recording** — record the core user flow as a GIF (`flow.gif`) using the
   `gif_creator` tool. Capture a few extra frames before/after each action for
   smooth playback. **Optimize before publishing:** if `flow.gif` exceeds ~3 MB,
   downscale it to ~1280px wide and/or reduce its palette with **Pillow**
   (no `ffmpeg` / ImageMagick / gifsicle is installed) so the repo stays light.
3. **Written flow (required)** — alongside `flow.gif`, write the same core flow in
   prose as `platforms/<platform>/flow.md`. This is the readable companion to the
   GIF: a **numbered step-by-step**, one step per meaningful user action, each step
   stating *what the user does* and *what the screen shows in response*, and citing
   the evidence for that step (the matching screenshot `NN-….png` and/or the point
   in `flow.gif`). Lead with a one-line summary of the flow (entry point → goal) and
   note where friction, delight, or dead-ends appear. It must stand on its own, so a
   reader who never opens the GIF can still follow the flow.
4. **Notes** — in `platforms/<platform>/notes.md`, log the *observations*: what
   stood out, the patterns worth synthesizing, and the source URL(s). (The blow-by-
   blow of the flow itself lives in `flow.md`; keep notes.md for analysis, not a
   step replay.)
5. **Sources** — append every URL you visit to the research-level `sources.md`
   with the date it was accessed.

Stay focused on the research goal. If a browser task fails 2–3 times or leads
into unrelated territory, stop and check in.

## Synthesis format (required)

`SYNTHESIS.md` is **type-aware** (see **Research types**). For a **benchmark** study
it is organized as a list of **features**; every feature entry MUST contain these
five fields, in this order:

1. **Feature name** — e.g. "AI Companion"
2. **Short description** — one or two sentences on what it is.
3. **Key findings** — what we learned from observing it. The analysis under key findings must follow the logic:
   - **What the user sees:** The visual interface, cues, layout, and cues shown.
   - **What the user does:** The actions, inputs, and interactions performed.
   - **What the system does:** How the system processes inputs, validates code, transitions state, and triggers loops.
   *(This should be written as natural paragraphs/text flowing in this order, rather than a table, citing the platforms and evidence. Embed screenshots or GIFs directly using relative markdown syntax).*
4. **Why this feature works (rationale)** — the UX / product reasoning.
5. **How to validate this feature in the future** — concrete next steps to
   test the idea (usability test, prototype, metric, experiment, etc.).

Each feature should cite the platform(s) and evidence (screenshot / flow /
source) it draws from.

For a **usability** study, `SYNTHESIS.md` is organized as **findings** instead of
features. Lead with an `## Overview` (goal, method, participant count, headline
findings) and a `## Metrics summary` (task success rates, SEQ/SUS, time-on-task),
then one section per finding, ordered by **severity, highest first**. Every finding
entry MUST contain, in order:

1. **Finding** — the observed problem or insight.
2. **Evidence** — which sessions/participants (by pseudonym P01…), task
   success/failure, and redacted quotes support it (embed relevant captures with
   relative markdown).
3. **Severity (0–4)** and the **affected task / usability heuristic**.
4. **Recommendation** — the concrete design change it implies.

End with a `## What worked` section (positive findings worth preserving) and the same
`## Gaps & caveats` section benchmark uses.

For a **litreview** study, `SYNTHESIS.md` is organized as **themes → design
implications**, drawn from the verified `evidence.md`. Lead with a `## TL;DR`, then one
`## Theme N — <name>` section per theme whose findings each carry a **confidence** label
and `[S#]` citation(s) traced to `evidence.md`. Then, in order:

1. **`## Design implications`** — numbered; what each theme means for what we build.
2. **`## Refuted / weak claims`** — reproduced from `evidence.md`, kept out of the findings.
3. **`## Evidence gaps for primary research`** — what the literature could not answer and
   needs a survey/usability study to resolve.
4. **`## Sources table (S1..Sn)`** — mirrors `sources.md`.

Every finding MUST trace to a source in `evidence.md`; confidence labels are honest; no
generalization beyond what the sources support; no fabricated sources or findings.

## Tooling notes

- **Browsing & capture:** Claude-in-Chrome MCP tools (`navigate`, `computer`,
  `read_page`, `gif_creator`, …). Chrome is installed at `/usr/bin/google-chrome`.
- **Image handling:** `Pillow` (PIL) is available for extracting PNG stills from
  flow GIFs and for downscaling/optimizing GIFs. `ffmpeg`, ImageMagick, and
  gifsicle are NOT installed — use Pillow.
- **Word export:** `pandoc` is NOT installed. `.docx` is generated by
  `.claude/scripts/md_to_docx.ps1`, the dependency-free PowerShell converter — this is
  the one the workflow commands invoke, because its `-Out` is mandatory (an export must
  land in the study's gitignored `docx/` folder, never the study root, since a `.docx`
  can embed `reference/` images into a binary no markdown check can inspect). Invoke it
  as `powershell -NoProfile -File .claude/scripts/md_to_docx.ps1 -Source <in.md> -Out
  <folder>/docx/<name>.docx`. A `python-docx` equivalent exists at
  `.claude/scripts/md_to_docx.py`, but the `python3` alias is not on PATH on this
  machine and it defaults its output to the source folder — prefer the PowerShell one.
  Both render text/lists/tables, inline bold/italic/code, fenced code blocks,
  blockquotes, and embedded images (`![alt](path)`, resolved relative to the source
  markdown), in a clean grayscale style.
- **Stakeholder decks:** built in **Canva** via the Canva MCP tools (load via
  ToolSearch if deferred), used by `/brief-feature`. Free tier only — never pay for
  or upgrade Canva. Local capture PNGs/GIFs may need manual placement in a slide if
  the Canva tools can't ingest a local asset.
- **Pattern reference:** **Mobbin** via the Mobbin MCP server (remote HTTP,
  `https://api.mobbin.com/mcp`, OAuth; registered as a claude.ai connector alongside
  Figma/Canva/ClickUp/Drive). Three tools: `search_screens` (UI screens),
  `search_flows` (multi-step flows — onboarding, checkout), `search_sections`
  (web sections — pricing, footers). Load via ToolSearch if deferred. See
  **Mobbin in the research workflow** below for what it may and may not be used for.

  **Connector-first, `.mcp.json` as fallback.** The claude.ai connector is the primary
  registration — one OAuth, inherited by Claude Code, Desktop, and Web. Verify with
  `claude mcp list` (expect `claude.ai Mobbin — ✔ Connected`). **If the connector is
  unavailable** — absent from `claude mcp list`, failing its health check, or the session
  is headless/cron where interactively-authenticated connectors don't load — fall back to
  a project-scoped server by creating `.mcp.json` at the repo root:

  ```json
  {
    "mcpServers": {
      "mobbin": {
        "type": "http",
        "url": "https://api.mobbin.com/mcp"
      }
    }
  }
  ```

  Then approve the project server when prompted and authenticate via `/mcp`. **Never run
  both at once** — two registrations of the same URL means a duplicate server, a recurring
  approval prompt, and a second OAuth. Delete `.mcp.json` once the connector is working
  again. The file is intentionally not committed, so this is a local, reversible fallback.
  Newly added connectors are not visible until Claude Code restarts; restart before
  concluding the connector is unavailable.
- Save any temporary/working files to the session scratchpad, never into a
  research folder unless it is real evidence.

### Mobbin in the research workflow

**Mobbin is the default source for benchmark evidence.** Claude-in-Chrome is the exception,
used when a C1–C5 trigger applies. The full standard — triggers, folder shapes,
`references.md` format, evidence rules, and the IP boundary — lives in
`.claude/references/mobbin-sourcing.md`. Read it before capturing.

The three rules that must never be violated, restated here because they are load-bearing:

- **No Mobbin image is ever committed.** The repo is public; the library is licensed
  third-party content. Reference images live in a gitignored `reference/` folder and are
  cited by URL in committed prose.
- **No finding claims first-party observation of a Mobbin screen.** Mobbin shows a pattern
  exists; it does not show that we watched it work.
- **Mobbin covers `ios` and `web` only.** Android-specific questions are C5 — Chrome, a
  device, or unanswerable.
