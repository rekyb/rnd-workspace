# Mobbin sourcing standard

How benchmark evidence is sourced, cited, and kept publishable. This file is the
single source of truth; other instruction files reference it rather than restating it.

## Default source

**Mobbin is the default source for benchmark evidence.** Claude-in-Chrome is the
exception, used when one of the C1–C5 triggers below applies and the reason is written
into the study's `PLAN.md`.

Tools: `mcp__claude_ai_Mobbin__search_screens`, `mcp__claude_ai_Mobbin__search_flows`,
`mcp__claude_ai_Mobbin__search_sections`. Load via ToolSearch if deferred.

**Registration:** Mobbin is a claude.ai connector. If the connector is unavailable
(absent from `claude mcp list`, failing its health check, or a headless/cron session),
fall back to a project-scoped `.mcp.json` at the repo root pointing at
`https://api.mobbin.com/mcp`. Never run both at once — same URL means a duplicate server
and a second OAuth. Delete `.mcp.json` once the connector works again; it is not committed.
A newly added connector is invisible until Claude Code restarts.

**Never purchase, upgrade, or change the Mobbin plan.** The no-payment guardrail applies
here exactly as it does to a benchmarked platform.

## Chrome-required triggers (C1–C5)

Use Claude-in-Chrome, and record which trigger applies, when:

| ID | Trigger | Why Mobbin cannot serve it |
|---|---|---|
| C1 | The product is ours (`solve.education`, anything under `design/`) | Unreleased or internal product has no library coverage |
| C2 | Mobbin has no coverage of the platform | Verified by search, not assumed |
| C3 | The question needs live behaviour — validation response, error states, timing, "what the system does" | Stills cannot demonstrate system response |
| C4 | Currency is itself the question | Mobbin is a snapshot; the live product may have moved |
| C5 | The question is Android-specific | Mobbin covers `ios` and `web` only; Android interaction convention is out of scope |

Usability studies (`--type usability`) are always first-party and unaffected by this standard.

## Platform coverage limit

Mobbin's `platform` parameter accepts **`ios` and `web` only — there is no Android.**
Mobbin adds native iOS coverage, which is a genuine gain over web-only capture, but it
does not close the Android gap. For Android-first work, iOS patterns transfer at the level
of flow structure and information architecture, not platform interaction convention (back
behaviour, system sheets, navigation idiom). Treat Mobbin-sourced mobile findings as
structural evidence; keep platform-convention claims out of them.

## Folder shapes

**Mobbin-sourced (default):**

```
platforms/<platform>/
├── references.md     committed — the screen ↔ URL mapping table
├── flow.md           committed — written flow
├── notes.md          committed — analysis
└── reference/        GITIGNORED — downloaded Mobbin PNGs
```

**Chrome-sourced:**

```
platforms/<platform>/
├── screenshots/      committed — first-party PNGs
├── flow.gif          committed — first-party recording
├── flow.md           committed
└── notes.md          committed
```

The presence of `references.md` (vs `screenshots/`) is how a reader tells which shape
they are looking at.

## `references.md` format

Column order is fixed — `md_visualize.ps1` parses by position (URL is column 3, local
file is column 5).

```markdown
# References — <platform> (Mobbin-sourced)

| # | Screen | Mobbin URL | Screen ID | Local file | Accessed |
|---|---|---|---|---|---|
| 01 | Paywall — annual default | https://mobbin.com/screens/abc123 | abc123 | reference/01-paywall.png | 2026-07-26 |
```

- **Mobbin URL** — the `mobbin_url` returned by the search tool. This is the canonical link
  and the citation used in committed prose.
- **Screen ID** — the UUID, kept so a citation stays recoverable if URL form changes.
- **Local file** — path relative to the platform folder. A file in `reference/` with no
  matching row is an error: the row is what makes it citable.

Downloads are disposable — deleting `reference/` and re-downloading from `references.md`
must reproduce the same state.

## Evidence rules

- **`flow.gif` is Chrome-only.** A GIF stitched from Mobbin frames is a derivative of their
  library and could not be committed. Mobbin platforms carry the flow in `flow.md` +
  `references.md`.
- **Mobbin-sourced `flow.md` must mark system-response claims as inferred.** Screen sequence
  does not prove what the system did. Write "inferred from screen sequence", never assert
  observation.
- **No finding may claim first-party observation of a Mobbin-sourced screen.**
- Every Mobbin screen or flow consulted is logged in the study's `sources.md` with
  provenance `mobbin` and an access date.

## IP boundary — four gates

The repo is **public** and Mobbin's library is licensed third-party content whose images are
copyright of their respective owners. Republishing it violates their terms and resells what
Mobbin sells.

1. **`.gitignore`** — `research/*/platforms/*/reference/`, `*.visual.md`, `research/*/docx/`
2. **The docx rule** — Word exports go in the gitignored `research/*/docx/` folder, because
   an export embeds images into a binary no markdown check can inspect
3. **`/publish-research` gate** — refuses to push when staged files include anything under
   `reference/`, any `*.visual.md`, or any `.docx` outside the ignored folder
4. **Provenance label** — `research/PATTERNS.md` entries sourced this way use
   **Kind:** `reference-library observed (Mobbin; not first-party captured)`

## Reading a synthesis with images

`SYNTHESIS.md` always carries Mobbin links and is always safe to commit. To read it with
screenshots inline:

```
powershell -File .claude/scripts/md_visualize.ps1 -Source research/<study>/SYNTHESIS.md
```

This writes `SYNTHESIS.visual.md` (gitignored). It never modifies the source. Regenerate
freely; the copy is disposable.
