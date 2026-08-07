# R&D Workspace (`rnd-workspace`)

> A UX-research and design workspace operating on a **Dual-Track Operational Model**: turning benchmark research and evidence synthesis into shippable, interactive prototypes.

---

## 🗺️ Workspace Workflow Architecture

This workspace connects **Research (Discover)** and **Design (Make)** into a continuous, evidence-backed pipeline. Below is the end-to-end operational flowchart:

```mermaid
flowchart TD
    classDef research fill:#1f2937,stroke:#3b82f6,stroke-width:2px,color:#fff;
    classDef design fill:#1f2937,stroke:#10b981,stroke-width:2px,color:#fff;
    classDef gate fill:#374151,stroke:#f59e0b,stroke-width:2px,color:#fff;

    subgraph RTrack ["Track 1: Strategic R&D (research/YYYY-MM-DD-slug/)"]
        R1["/new-research [slug]<br/>Scaffold study (Benchmark/Usability/Litreview)"] :::research --> R2["Capture Evidence<br/>Screenshots, Flows & Notes<br/>(Mobbin default / Chrome C1-C5)"] :::research
        R2 --> R3["/synth-findings<br/>Synthesize into SYNTHESIS.md"] :::research
        R3 --> R4["/review-research<br/>Peer Review Debate<br/>(Skeptic, Domain Expert, Auditor)"] :::gate
        R4 --> R5["/close-research<br/>Merge findings into PATTERNS.md"] :::research
    end

    subgraph DTrack ["Track 2: Direct Design & Prototyping (design/project/)"]
        D1["/new-design [project]<br/>Scaffold design container"] :::design --> D2["/draft-prd<br/>Draft PRD.md Shape-Up Doc<br/>(Jobs, Appetite, Slices, Criteria)"] :::design
        D2 --> D3["Stakeholder Review<br/>(PM, Tech Lead, Head of Product)<br/>& Principal Designer Gate (Mode S)"] :::gate
        D3 --> D4["/design-prototype<br/>Author multi-file source in src/<br/>(using ui-library/ design system)"] :::design
        D4 --> D5["/export-prototype<br/>Build build/standalone.html<br/>& run design gate checks"] :::gate
    end

    %% Cross-track evidence flow
    R4 -. "Cited Evidence & Findings (F1, F2...)" .-> D2
    R5 -. "UX Patterns (PATTERNS.md)" .-> D2
```

---

## 📌 What this Repo Is (and isn't)

- **Is:** A UX-research and design workspace. We observe publicly available products, benchmark user flows, synthesize primary/secondary evidence, draft Shape-Up PRDs, and build component-driven interactive prototypes.
- **Is Not:** A production application repository or live participant recruitment platform. The output is evidence-backed research, decision documents (`PRD.md`), and validation prototypes.

Work is executed from the perspective of a **Senior UI/UX Designer**: analytical, opinionated about interaction patterns, and grounded strictly in empirical evidence.

---

## 🛡️ Guardrails

Three non-negotiable rules govern all operations in this workspace:

1. 💳 **Never pay for anything:** No purchases, subscriptions, upgrades, or paid trials on benchmarked platforms. If paywalled, capture observable free flows and document the gating.
2. 🔒 **Redact sensitive info before saving:** Scrub personal data (real names, avatars, emails, PII) in-page *before* capturing screenshots or recordings. Non-sensitive mechanics (XP, streaks, progress) remain visible.
3. 📜 **Never republish licensed reference material:** Mobbin PNGs live in gitignored `reference/` folders and are cited by URL. They are never committed to this public repo.

---

## 🛠️ Requirements & Setup

Clone the repository:
```bash
git clone https://github.com/rekyb/rnd-workspace.git
cd rnd-workspace
```

### Core Tooling Stack

| Tool | Used For | Notes |
|---|---|---|
| **Google Antigravity (`agy`)** / **Claude Code** | Workflow execution (`/new-research`, `/draft-prd`, `/design-prototype`, etc.) | Authoritative briefs: [`CLAUDE.md`](CLAUDE.md) and [`GEMINI.md`](GEMINI.md). |
| **Mobbin** (MCP) | **Default benchmark source** for iOS & Web screens and flows. | Connector registered at `https://api.mobbin.com/mcp`. |
| **Google Chrome** + Extension | **Fallback capture** for C1–C5 cases (internal apps, live behavior, Android). | Extension ID: `eeijfnjmjelapkebgockoeaadonbchdd`. |
| **Python 3** + **Pillow** | Extracting PNG stills from flow GIFs & image manipulation. | `pip install Pillow`. |
| **PowerShell** | Running build/export scripts & `.docx` exports. | Executed via `.claude/scripts/`. |
| **git** + **GitHub CLI (`gh`)** | Version control & publishing evidence. | Remote: `rnd-workspace`. |

---

## 📁 Repository Structure

```
rnd-workspace/
├── README.md                       # Workspace sitemap & workflow overview (this file)
├── CLAUDE.md                       # Authoritative rules, guardrails & command specifications
├── GEMINI.md                       # Antigravity/Gemini integration delta
├── ROADMAP.md                      # R&D workspace roadmap
├── BOARD.md                        # Active/closed research & design board (rendered by /research-board)
├── .claude/                        # Workflow specifications, personas, references & scripts
│   ├── commands/                   # 19 CLI workflow command definitions
│   ├── personas/                   # Reviewer subagents (principal-researcher, principal-designer, etc.)
│   ├── references/                 # Core contracts (design-projects, design-system, coverage-contract, etc.)
│   └── scripts/                    # Automation scripts (build-prototype, check-prototype, sync-tokens, etc.)
├── .agents/skills/                 # Harness skill registration stubs
├── ui-library/                     # Synced design system (tokens.css, components.css, COMPONENTS.md)
├── design/<project>/               # Design track: README.md, PRD.md, src/, build/ standalone HTML
└── research/                       # Research track: PATTERNS.md & dated study folders
    ├── PATTERNS.md                 # Cross-study pattern library (owned by Principal Designer)
    └── YYYY-MM-DD-<slug>/          # Individual research study folder
        ├── README.md               # Study brief, scope & coverage status
        ├── PLAN.md                 # Approved research plan & Q# questions
        ├── sources.md              # Logged source URLs & access dates
        ├── platforms/              # Benchmark evidence per platform (reference/ or screenshots/)
        └── SYNTHESIS.md            # Synthesized findings & feature write-ups
```

---

## ⚡ Workflow Commands Reference

### 🔍 Research Track (`research/`)

| Command | Purpose | Output / Artifact |
|---|---|---|
| `/new-research <slug> [--type benchmark\|usability\|litreview]` | Create & scaffold a new research study | `research/YYYY-MM-DD-<slug>/` |
| `/plan-usability` | Design usability test instrument & moderator script | `test-plan.md` |
| `/gather-evidence [folder]` | Run deep-research harness over literature plan | `evidence.md` & `sources.md` |
| `/synth-findings [--docx] [--visual]` | Synthesize research findings into structured write-ups | `SYNTHESIS.md` |
| `/review-research` | Run 3-persona peer-review debate over synthesis | `## Peer Review` in `SYNTHESIS.md` |
| `/brief-feature [folder]` | Draft & build Canva stakeholder deck | Canva Deck |
| `/close-research` | Verify synthesis, extract patterns & retire from registry | Merged into `PATTERNS.md` |
| `/focus-research <folder>` | Point current terminal session to a specific active study | `.claude/.current-research/` |
| `/publish-research [-m "msg"]` | PII safety check, commit & push to GitHub | Git commit & push |

### 🛠️ Optional Analysis Lenses (`research/*/lenses/`)

| Command | Purpose | Output |
|---|---|---|
| `/heuristic-eval [folder]` | Nielsen's 10 usability heuristics evaluation | `lenses/heuristic-eval.md` |
| `/a11y-audit [folder]` | WCAG 2.2 accessibility audit on captured stills | `lenses/a11y-audit.md` |
| `/extract-tokens [folder]` | Pixel-sample screenshot colors/typography into tokens | `lenses/tokens.md` |

### 🎨 Design & Prototype Track (`design/`)

| Command | Purpose | Output / Artifact |
|---|---|---|
| `/new-design <project> [--informed-by ...]` | Create & scaffold a design project container | `design/<project>/` |
| `/draft-prd [project] [--docx]` | Turn evidence into Shape-Up decision doc with vertical slices | `design/<project>/PRD.md` |
| `/design-prototype [project]` | Author multi-file clickable prototype in `src/` using `ui-library/` | `design/<project>/src/` |
| `/export-prototype [project] [--artifact]` | Build standalone HTML, validate design gates & export | `design/<project>/build/standalone.html` |

### 📋 Board & Session Management

| Command | Purpose | Output / Artifact |
|---|---|---|
| `/research-board` | Refresh and display active/closed research & design projects | Updates [`BOARD.md`](BOARD.md) |
| `/save-session [note]` | Write handoff checkpoint with git status & next steps | Writes `SAVE.md` |
| `/sync-tokens [--check]` | Sync upstream design system tokens & components into `ui-library/` | Refreshes `ui-library/` |

---

## 🎨 Design System & Prototype Validation

All prototypes built with `/design-prototype` derive their styling from [`ui-library/`](ui-library/COMPONENTS.md).

Before export, `.claude/scripts/check-prototype.ps1` automatically verifies:
1. 🌐 **No external host dependencies** (all assets self-contained).
2. 🎨 **No raw CSS values** outside of token definitions.
3. 🔑 **Token resolution**: Every `var(--x)` exists in `tokens.css`.
4. 📦 **Component contracts**: Every CSS class exists in `components.css`.
5. 🛡️ **PII scrubbing**: Scans for un-redacted personal information.

---

## 📖 Further Reading

- [`CLAUDE.md`](CLAUDE.md) — Authoritative rulebook, persona contracts, and workflow gates.
- [`GEMINI.md`](GEMINI.md) — Harness delta and Antigravity skill execution guide.
- [`BOARD.md`](BOARD.md) — Current R&D status board.
