# Mobbin as the primary benchmark source — design

- **Date:** 2026-07-26
- **Status:** Draft, pending user review
- **Scope:** Make Mobbin the default source for benchmark evidence, with Claude-in-Chrome
  as the justified exception; add a visual-companion mechanism so research documents can
  be read with screenshots without publishing Mobbin's library.

---

## 1. Problem

The workspace benchmarks products by driving Claude-in-Chrome against them and committing
the captures (`platforms/<platform>/screenshots/*.png`, `flow.gif`). That model has four
standing limits:

1. **Web-only.** Chrome captures web surfaces. Every `research/PATTERNS.md` entry carries a
   *"desktop-web capture"* caveat, while the active design work (`design/ai-literacy-app`)
   is explicitly mobile-first and Android-first.

   **Correction (verified 2026-07-26 against the live tool schemas):** Mobbin's `platform`
   parameter accepts **`ios` and `web` only — there is no Android**. So Mobbin adds native
   *iOS* coverage, a genuine gain over web-only, but it does **not** close the Android gap.
   For an Android-first product, iOS patterns transfer at the level of flow structure and
   information architecture, not at the level of platform interaction convention (back
   behaviour, system sheets, navigation idiom). Android-specific questions still require
   Chrome, or a device, or are simply unanswerable from this library.
2. **Paywalls end the study.** The Guardrails forbid transacting, so capture stops at the
   paywall and the rest of the flow is recorded as "gated".
3. **PII burden.** Capturing from a logged-in session requires the redact-before-capture
   ritual, a `window.__redact()` helper, and re-application after every navigation —
   including third-party names on social surfaces.
4. **Cost per platform.** Each platform is a full browser session, so studies stay narrow.

Mobbin's MCP server (registered 2026-07-26) exposes ~621,500 curated screens and ~142,200
flows from shipped mobile, web, and desktop products, including subscription-only and
region-locked apps. It addresses all four limits directly.

### The constraint that shapes everything

Mobbin's terms state the library's images are *"copyright and/or trademark protected by
their respective owners"* and licensed to Mobbin; their acceptable-use policy forbids
storing or distributing copyrighted material without authorization.
`rekyb/research-workspace` is **public**. Committing Mobbin images therefore publishes
them, which is both a terms violation and a resale of the product Mobbin sells.

This is narrower than "you cannot use third-party screenshots" — the repo already commits
self-captured screenshots of Duolingo, Khan, CodeSignal, and others. Those are first-party
observations of publicly reachable products, which is ordinary design-research practice.
The distinction is that Mobbin's captures are a licensed library, which adds a contractual
restriction that does not attach to your own captures.

## 2. Goals / non-goals

**Goals**

- Mobbin is the default benchmark source; Chrome use becomes deliberate and justified.
- Research documents remain readable with screenshots inline, locally.
- No committed file ever contains a Mobbin image — enforced structurally, not by memory.
- A reader can always tell whether a finding was observed first-party or read in a library.

**Non-goals**

- Replacing Chrome. Chrome remains required for the cases in §3.
- Retroactively changing the 8 already-committed `.docx` files or any existing study.
- Changing the synthesis format, the review debate, or any persona's remit beyond the two
  narrow additions in §8.
- Building a Mobbin cache, index, or offline mirror. Reference images are per-study and
  disposable.

## 3. Sourcing decision rule

**Mobbin is the default.** Chrome is required — not merely preferred — when any of these
holds, and the reason is written into `PLAN.md`:

| # | Trigger | Why Mobbin cannot serve it |
|---|---|---|
| C1 | The product is ours (`solve.education`, anything under `design/`) | Unreleased or internal product has no library coverage |
| C2 | Mobbin has no coverage of the platform | Verified by search, not assumed |
| C3 | The question needs live behaviour — validation response, error states, timing, "what the system does" | Stills cannot demonstrate system response |
| C4 | Currency is itself the question | Mobbin is a snapshot; live product may have moved |
| C5 | The question is **Android-specific** | Mobbin covers `ios` and `web` only (verified against the tool schema); Android interaction convention is out of library scope |

Usability studies (`--type usability`) are unaffected: they test our own product and are
always Chrome/first-party.

## 4. Folder shapes

Two shapes, by source.

**Mobbin-sourced (default):**

```
platforms/<platform>/
├── references.md     committed — the screen ↔ URL mapping table
├── flow.md           committed — written flow (existing standard)
├── notes.md          committed — analysis
└── reference/        GITIGNORED — downloaded Mobbin PNGs
```

**Chrome-sourced (unchanged):**

```
platforms/<platform>/
├── screenshots/      committed — first-party PNGs
├── flow.gif          committed — first-party recording
├── flow.md           committed
└── notes.md          committed
```

### `references.md` format

The mapping table is what makes the visual swap mechanical and reversible.

```markdown
# References — <platform> (Mobbin-sourced)

| # | Screen | Mobbin URL | Screen ID | Local file | Accessed |
|---|---|---|---|---|---|
| 01 | Paywall — annual default | https://mobbin.com/screens/abc123 | abc123 | reference/01-paywall.png | 2026-07-26 |
```

### How reference images get there

The MCP's `search_screens` / `search_flows` / `search_sections` return image URLs. During
capture the workflow downloads the selected screens into `reference/` with numbered,
descriptive filenames matching the `screenshots/` convention (`01-paywall.png`), and writes
the corresponding `references.md` row at the same time. A `reference/` file with no
`references.md` row is an error — the mapping is what makes the file citable.

Downloads are per-study and disposable: deleting `reference/` and re-running the download
from `references.md` must reproduce the same state.

### Consequences, stated plainly

- **`flow.gif` becomes Chrome-only.** A GIF stitched from Mobbin frames is a derivative of
  their library and would have to be gitignored — a committed-evidence artifact that isn't
  committed. Mobbin platforms carry the flow in `flow.md` + `references.md` instead. This is
  a real reduction in evidence richness, accepted knowingly.
- **`flow.md`'s "what the system does" weakens for Mobbin platforms.** Screen sequence does
  not prove system response. Mobbin-sourced `flow.md` must mark such claims as *inferred
  from screen sequence*, not observed. Without this the workspace begins asserting things it
  did not see.

## 5. Visual companion

A deterministic script, not a model, so source and visual copy cannot drift.

`.claude/scripts/md_visualize.ps1` reads a markdown file and walks every inline link. A link
is a swap candidate **only if its URL appears in the URL column of a `references.md` table
within the same study** — matching is by table lookup, not by URL pattern, so an ordinary
link to `mobbin.com` in prose is never rewritten. Where the matched row's local file exists,
the link becomes an image embed. Everything else passes through untouched.

```
SYNTHESIS.md  ──┐
                ├─→  md_visualize.ps1  ──→  SYNTHESIS.visual.md
references.md ──┘         (link → image)         (gitignored)
```

Exposed as `/synth-findings --visual`; also runnable standalone so the visual copy can be
regenerated without re-synthesizing.

**Rules:**

- **One direction only.** The script never writes to the source markdown. An accidentally
  edited visual copy is discarded on the next regeneration, losing nothing.
- **Missing images degrade, never fail.** A Mobbin link with no local PNG stays a link,
  yielding a partial visual document rather than an error.
- **Idempotent.** Running it twice produces the same output.

PowerShell is chosen to match the existing `md_to_docx.ps1` convention. (Note: Python 3.14.6
and `python-docx` were verified working on this machine on 2026-07-26, so the older
"no working Python" note is stale — Python remains a viable alternative if preferred.)

## 6. IP boundary — four gates

No single gate carries the weight.

**Gate 1 — `.gitignore`**

```
research/*/platforms/*/reference/    # downloaded Mobbin PNGs
*.visual.md                          # generated visual copies
research/*/docx/                     # image-bearing exports
```

**Gate 2 — the docx rule.** `--docx` on a Mobbin-illustrated synthesis embeds the images
into a binary that no markdown inspection can catch. Docx exports therefore move to the
gitignored `research/*/docx/` folder — already the convention in
`research/2026-07-13-onboarding-activation-education-apps/docx/`, now made mandatory.

*Subtlety:* `.gitignore` does not untrack already-tracked files. The 8 currently-committed
`.docx` files predate Mobbin and contain only first-party captures, so they remain tracked
and are deliberately left alone rather than churning history.

**Gate 3 — `/publish-research` leak gate.** Alongside the existing PII check, refuse to push
when staged files include anything under `reference/`, any `*.visual.md`, or any `.docx`
outside the ignored folder. Fail loudly with the offending paths listed.

**Gate 4 — provenance label.** `research/PATTERNS.md` already distinguishes
`benchmark-observed` from `literature-grounded design principle (litreview; no live UI
observed)`. Add a third:

> **Kind:** `reference-library observed (Mobbin; not first-party captured)`

This is what keeps "ground every claim in captured evidence" meaningful once Mobbin is the
default — a reader can tell whether the workspace watched a pattern or read it.

## 7. Provenance in synthesis

A Mobbin-sourced finding cites its Mobbin URL, exactly as a Chrome-sourced finding cites its
screenshot path. `sources.md` logs every Mobbin screen/flow consulted with provenance
`mobbin` and an access date, mirroring the litreview `provided | found` convention.

No finding may claim first-party observation of a Mobbin-sourced screen.

## 8. File-by-file changes

| File | Change |
|---|---|
| `README.md` | **Requirements & setup** — add Mobbin MCP row, demote Chrome to fallback capture · **Repository structure** — tree gains `reference/`, `references.md`, `md_visualize.ps1`, `mobbin-sourcing.md`; show both platform shapes · **Capture standards** — rewrite Mobbin-first · **Guardrails** — add the redistribution boundary · **Tooling notes** — Mobbin entry; docx folder gitignored |
| `GEMINI.md` | §2 *Capturing Evidence (benchmark Studies)* rewritten to match, so Antigravity operators do not get Chrome-first instructions |
| `CLAUDE.md` | **Capture standards** rewritten Mobbin-first; **replace** the Mobbin subsection added 2026-07-26, which currently states Mobbin must never substitute for captured evidence — correct under the old model, wrong under this one. **Preserve** the connector-first / `.mcp.json`-fallback rule (§8.1) through the rewrite |
| `.claude/commands/new-research.md` | Step 7 selects a source per platform; benchmark `PLAN.md` template gains a **Source** column and a Chrome-justification field |
| `.claude/commands/synth-findings.md` | `--visual` flag invoking `md_visualize.ps1`; Mobbin citations as links |
| `.claude/commands/publish-research.md` | Gate 3 |
| `.claude/commands/close-research.md` | Pass the new Kind through to the Principal Designer |
| `.claude/personas/principal-researcher.md` | At the plan gate, require a written C1–C4 reason for each Chrome-sourced platform |
| `.claude/personas/principal-designer.md` | Handle the third `PATTERNS.md` Kind when merging patterns |
| `.claude/references/mobbin-sourcing.md` | **New** — the sourcing standard, mirroring *Litreview sourcing standards* in `CLAUDE.md` |
| `.claude/scripts/md_visualize.ps1` | **New** — the link↔image transform |
| `.gitignore` | Gate 1's three lines |

### 8.1 Registration: connector-first, `.mcp.json` fallback

Mobbin is registered as a **claude.ai connector** (one OAuth, inherited by Claude Code,
Desktop, and Web), verified with `claude mcp list`.

If the connector is unavailable — absent, failing its health check, or a headless/cron
session where interactively-authenticated connectors do not load — the fallback is a
project-scoped `.mcp.json` at the repo root pointing at the same URL, approved and
authenticated locally.

**The two must never run simultaneously.** Both registrations resolve to
`https://api.mobbin.com/mcp`, so running both produces a duplicate server, a recurring
approval prompt, and a second OAuth. `.mcp.json` is deleted once the connector works again
and is deliberately **not committed**, keeping the fallback local and reversible.

A newly added connector is invisible until Claude Code restarts — restart before concluding
it is unavailable.

## 9. Risks and open questions

- **Mobbin URL stability — partly resolved.** The `search_screens` schema returns a
  `mobbin_url` it describes as *the canonical Mobbin link for that screen*, and instructs
  clients to always cite it, so citation-by-URL is the intended usage rather than a
  workaround. Screen IDs are UUIDs (`exclude_screen_ids` format), so `references.md` storing
  both URL and ID keeps a citation recoverable if URL form ever changes. Remaining unknown:
  whether a screen can be *withdrawn* from the library, which would rot the citation
  regardless of form.
- **Coverage is unmeasured.** How often C2 ("Mobbin has no coverage") fires is unknown until
  the first few studies run. If it fires often, Mobbin-as-default is the wrong default and
  the rule should invert.
- **No Android coverage.** The single biggest limit, and it lands directly on the current
  design work. `design/ai-literacy-app` targets Android-first teachers on low-end devices;
  Mobbin can show how a flow is *structured* on iOS but not how it should *behave* on
  Android. Treat Mobbin-sourced mobile findings as structural evidence and keep platform
  convention questions out of them.
- **Evidence richness drops for Mobbin platforms** — no `flow.gif`, weaker system-response
  claims. Accepted, but it should be reviewed after two or three studies rather than assumed
  permanent.
- **Two-shape `platforms/` adds cognitive load.** A reader must check which shape they are
  looking at. `references.md` existing (vs `screenshots/`) is the tell; the README documents
  both.
- **The visual copy is a second artifact.** If the review habit is "open `SYNTHESIS.md` and
  read," the generated companion is friction felt on every review. This was chosen knowingly
  over a mutate-at-publish design, because the latter puts the IP boundary behind remembering
  to publish through one command — unsafe in a workspace explicitly run across parallel
  terminals.

## 10. Acceptance criteria

1. A new benchmark study can be planned and synthesized entirely from Mobbin, with no browser
   session, producing `references.md`, `flow.md`, `notes.md`, and a `SYNTHESIS.md` whose
   evidence citations are Mobbin links.
2. `/synth-findings --visual` produces `SYNTHESIS.visual.md` with images inline; content is
   otherwise byte-identical to the source apart from the swapped embeds.
3. `git status` is clean after generating reference images and a visual copy — nothing
   untracked-but-committable appears.
4. `/publish-research` refuses to push a deliberately staged `reference/` PNG, naming the file.
5. `README.md`, `GEMINI.md`, and `CLAUDE.md` agree with each other and with this spec; no
   remaining text asserts Chrome-first capture or forbids Mobbin as an evidence source.
6. A Chrome-sourced platform in a new `PLAN.md` carries a written C1–C4 justification, and the
   Principal Researcher flags its absence.
