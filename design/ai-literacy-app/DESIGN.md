# Design System — Component & Pattern Layer

*The component layer for the AI-Literacy App. Foundations owns the atoms (colour, type,
spacing, shape, language, a11y). This document owns everything built from them: what a
component is made of, every state it can be in, and the rules that govern it.*

- **Version:** v1, 2026-07-17
- **Token source:** [`tokens.css`](tokens.css) — the only place token *values* live.
- **Grounded in:**
  - `research/2026-07-14-ai-literacy-upskilling-indonesian-teachers/DESIGN-FOUNDATIONS.md`
    (atoms: colour, type, spacing, shape, motion, iconography, language system, a11y)
  - `information-architecture.md` (surfaces this doc must serve)
  - `user-journey.md` (moments this doc must support)
  - `validation-model.md` (the check types and badge logic)
  - `onboarding.md` (the boundary flow and the deferred account moment)

---

## Reconciliation — where this doc overrides foundations

`DESIGN-FOUNDATIONS.md` is dated **2026-07-15**. Two of its decisions are superseded.

### Override 1 — brand direction (v3, 2026-07-17)

> **Superseded — DESIGN-FOUNDATIONS locked decisions:**
> *"Brand direction | **Calm & credible** — deep-teal primary + warm off-white + amber accent"*
> *"Primary hue | **Deep, serious teal `#0F766E`**"*

The brand is **indigo velvet** (`--primary`) with a lighter slate-blue (`--primary-bright`),
at the design lead's direction. This is a change of brand thesis, not a recolour. It gives the
strongest brand contrast the system has had — `--primary` carries white text at **10.18:1**.

Four consequences, all forced by the semantic model rather than chosen:

- **The supplied warm ramp does not become the meaning colours.** It lands on top of `win` and
  `danger`, and the three warms collapse into each other under colour-blindness (dE 6–8 — they
  are effectively one colour to a deuteranope). Mapping `win`→amber-flame and `danger`→cayenne
  would have **halved** the win/danger separation for the ~8% of men with red-green deficiency,
  on the signal carrying the student-data guardrail. So **`--win-fill` takes amber-flame only**
  — which *improves* the separation (protan 26.1 → 29.2) — and tiger-orange and cayenne-red
  become **illustration-only** `--deco-*` tokens, per foundations §7.
- **`danger` stays a true red.** The palette's cayenne fails AA body as text (3.17:1) and is a
  worse signal. This one does not bend to the palette.
- **`safe` keeps the v1 teal**, verified clear of both `--verify-text` (dE 97.0) and the new
  indigo brand (dE 74.9).
- **`readiness` is deep forest green** — dE 83.1 from the brand, distinct from every claimed
  colour. Green reads *complete/go*, and `safe` has vacated green. Its mark is a light green,
  **not amber**: an amber mark would read as a win and muddy the exact distinction the token
  exists to make.

**The neutrals stay warm.** Cream + indigo is coherent, and they are already validated.

The rest of foundations — type, spacing, shape, motion, iconography, language, a11y — stands.

### Override 2 — credential framing

The certificate-vs-badge decision was resolved **2026-07-17** by
`research/2026-07-17-certificate-vs-badge-gamification`. This part of foundations is **stale,
and this document supersedes it**:

> **Superseded — DESIGN-FOUNDATIONS §5, "Anchoring & credential terms":**
> *"Frame the credential in terms teachers know: **'Sertifikat + Jam PKB'**"*

That framing is **not permitted in v1.** The resolved decision holds:

- **No self-issued certificate**, and no certification / PD-hour / PKB / government-recognition
  claim anywhere in the product.
- **Badges are in-loop engagement recognition, not the terminal reward.**
- The terminal reward is a **portfolio-worthy readiness completion**, designed
  **PD-credit-*ready*** (feed-not-issue) so a future official PPG / PKB integration slots in
  without a redesign — the same discipline the IA uses with "generation-ready but prompt-only
  functional."

Every other part of foundations stands unchanged and is authoritative.

> ⚠️ **Confidence.** The resolved decision itself flags that its local transfer to Indonesian
> teachers rests on only 2 directly-Indonesian anchors. It is a validated *direction to test*,
> not settled fact. The `readiness-*` pattern below inherits that uncertainty.

---

## How to use this doc

- **Token names, never values.** This document says `--primary`, never a hex. If a value changes
  after device validation, `tokens.css` changes and this document stays correct. Do not restate
  values here.
  - *One documented exception:* the **superseded-decision quotes** in Reconciliation cite
    foundations' original hexes verbatim, to name precisely what was overturned. A historical
    quote cannot drift, so it is safe — and it is the only hex permitted in this file.
- **Traceability.** Every component names the surface or journey step it serves. A component
  that cannot name what it serves does not belong here — and must not appear in a prototype.
- **Design language, not implementation.** Anatomy, states, tokens, rules. CSS lives in the
  prototype.
- **Three tiers.** Primitives are generic and mostly *apply* foundations. Domain patterns are
  where the design thinking lives. The surface map connects both to real screens.

---

# Tier 1 — Primitives

Generic, token-driven, no domain knowledge. These apply foundations rather than decide anything
new; specs are deliberately thin.

## Pill button

**Anatomy:** full-pill container (`--r-pill`), optional leading SVG icon (`--icon-size`,
`currentColor`), label at `--fs-label` / `--fw-label`, `--pill-pad-x` horizontal padding, height
≥ `--touch-min`.

**Variants:** `primary` (fill `--primary`, text `--on-primary`) · `secondary` (transparent fill,
`--border` outline, text `--ink`) · `text` (no fill, no border, text `--primary`).

**States:** default · pressed (`--primary-strong` fill for primary; `--surface-alt` for others) ·
disabled (reduced opacity, no pointer) · loading (label replaced by spinner, width held).

**Rules:**
- **One primary button per screen** (foundations §0). If two actions compete, one is secondary.
- A screen's primary action sits in a **sticky bottom pill** inside the thumb zone.
- Destructive actions never sit in the easy-tap zone.
- Focus ring follows the pill silhouette (`--focus-*`).

## Icon button

**Anatomy:** circular pill, exactly `--touch-min` × `--touch-min`, single SVG icon at
`--icon-size`, `currentColor`.

**Rules:** must carry an accessible name. Decorative icons never become icon buttons. Never the
sole carrier of a meaning colour — see *Meaning-colour pairing* below.

## Chip

**Anatomy:** pill container, `--fs-label`, optional leading icon, height ≥ `--touch-min`.

**States:** unselected (`--card` fill, `--border` outline) · selected (`--primary-tint` fill,
`--primary-strong` text, check icon) · disabled.

**Rules:** used for mapel selection and prompt filters. Multi-select is visually distinct from
single-select by the presence of the check icon. Wraps to multiple rows; never scrolls
horizontally for primary content.

## Pill input & select

**Anatomy:** pill container, `--input-pad-x` horizontal padding (the curve needs clearance),
height ≥ `--touch-min`, `--fs-body` text, `--border` outline, `--card` fill.

**States:** default · focused (`--focus-*` ring) · filled · error (`--danger-text` message
below, `--danger-text` outline) · disabled.

**Rules:** **selects open a bottom sheet, never a top dropdown** (foundations §0). Placeholder
text is never the only label.

## Card

**Anatomy:** `--card` fill, `--r-card` radius, `--elevation-1`, `--sp-4` internal padding,
optional `--border`.

**Rules:** cards are **not** literal pills — `--r-card`, never `--r-pill`, which would clip
rectangular content. Inner images use `--r-md`.

## List row

**Anatomy:** full-width, `--r-card`, min-height `--touch-min`, optional leading icon, title at
`--fs-body`, optional secondary line at `--fs-cap` / `--ink-muted`, optional trailing chevron.

## Bottom sheet

**Anatomy:** `--r-sheet` on top corners only, `--card` fill, grab handle, optional title at
`--fs-h2`, content, optional sticky primary pill.

**Rules:** the default picker for jenjang, mapel, and any option list. Dismissible by drag and by
an explicit control — never drag-only.

## Bottom tab bar

**Anatomy:** three tabs (Belajar · Prompt · Profil), each an icon at `--icon-size` plus a label
at `--fs-cap`, each ≥ `--touch-min`, `--card` fill, top `--border`.

**States:** active (`--primary` icon + label, `--fw-label`) · inactive (`--ink-muted`).

**Rules:** exactly three tabs — no Beranda, no Badges tab (IA decision). Persistent across all
tabbed surfaces; **absent during onboarding** (a boundary flow) and during the readiness
completion. Active state is never colour-alone — weight changes too.

## Callout

**Anatomy:** `--r-card` container, tinted fill, leading SVG icon, text at `--fs-body`, optional
inline action.

**Variants — each carries exactly one meaning:**

| Variant | Fill | Text | Icon | Used for |
|---|---|---|---|---|
| `verify` | `--verify-bg` | `--verify-text` | `circle-check` | the check-it habit |
| `safe` | `--safe-bg` | `--safe-text` | `shield-check` | privacy-safe confirmation |
| `danger` | `--danger-bg` | `--danger-text` | `alert-triangle` | a never-do |
| `win` | `--win-bg` | `--win-bg-text` | `clock` | in-loop recognition |

**Rules:** meaning colours are semantic, not decorative (foundations §1). Amber appears only on a
win; red only on a never-do. A callout **always** pairs its colour with an icon *and* a text
label — never colour alone.

## Progress indicator

**Anatomy:** pill-capped track (`--surface-alt`) with `--primary` fill; optional `--fs-cap`
counter.

**Rules:** never framed as speed or competition (validation-model badge rules). Shows position,
not pace.

## Badge chip

**Anatomy:** pill, `--win-bg` fill, `--win-bg-text` text, leading badge icon, `--fs-label`.

**States:** earned · unearned (`--surface-alt` fill, `--ink-muted` text, outline icon).

**Rules:** plain, honest competence language only. **Never** implies certification, PD hours, PKB,
or government recognition. Never the terminal reward — see *Readiness completion*.

## Focus ring

`--focus-width` outline in `--focus-color` at `--focus-offset`, following the host's silhouette
(pill for controls, `--r-card` for cards). Present on every interactive element. Never removed.

## Meaning-colour pairing *(cross-cutting rule)*

A meaning colour **never** appears without an SVG icon and a text label beside it
(foundations §6 · WCAG 1.4.1 · heuristic H6). This rule outranks any layout preference. If space
forces a choice between the icon and the label, cut the icon — the label stays.

---

# Tier 2 — Domain patterns

Components only this product has. This is where the design thinking lives.

## Path node

**Serves:** `Belajar → Current path` · journey step 1 ("Land in Belajar") and 3 ("Continue
learning").

**Anatomy:** circular node (≥ `--touch-min`) carrying a type icon, a connector to the next node,
a label at `--fs-label`, and a time estimate at `--fs-cap` / `--ink-muted`. The active node
additionally shows a short value promise at `--fs-body`.

**Types** (per IA → Node Types): `lesson` · `practice` · `validation` · `prompt-challenge` ·
`unlock` · `badge`. Type is carried by the icon, never by colour alone.

**States:**

| State | Treatment |
|---|---|
| `completed` | `--primary` fill, `check` icon, `--on-primary`. Remains tappable — teachers may revisit. |
| `active` | `--primary` fill, type icon, plus the value promise and time estimate. **Exactly one active node exists.** |
| `locked` | `--surface-alt` fill, `--border` outline, `lock` icon, `--ink-muted` label. Tappable — opens the locked explainer, never silently rejects. |

**Rules:**
- **Never make the teacher hunt for the next step** (journey guardrail). The active node is
  visually unmistakable and the path scrolls to it on entry.
- The active node is primed by `first_need` from onboarding; if skipped, it falls back to the
  default first node. No dead-end.
- A locked node **always explains why and what to do next**. Locked is instructional, never
  punitive.
- Time estimates are shown for every module and unit (Belajar rule).

## Module card

**Serves:** `Belajar → Module detail`.

**Anatomy:** card with module title at `--fs-display`, goal sentence at `--fs-bodylg`, a time
estimate, a unit/check list, and the badge milestone it leads to (badge chip, unearned state).

**Rules:** states the goal before the content. No long AI tutorial front-loading (Belajar rule).

## Prompt card

**Serves:** `Prompt → Prompt list` · journey steps 4–5. **The most important component in the
product** — it encodes the entire safety-gate thesis.

**Anatomy:** card with prompt title in *teacher language* at `--fs-body`, a one-line use case at
`--fs-cap` / `--ink-muted`, an access-state indicator, and a save toggle (icon button).

**State model.** The IA lists four states flat; they are in fact **two orthogonal dimensions**,
and the component must model them as such (a prompt can be simultaneously `unlocked` and
`saved`):

**Dimension 1 — access:**

| State | Treatment |
|---|---|
| `open` | No indicator. Low-risk prompts carry no visual tax. |
| `learn-first` | `lock` icon + "Learn first" label at `--fs-cap`, `--ink-muted`. Tappable → locked explainer. |
| `unlocked` | `shield-check` icon, `--safe-text`, shown **only briefly after unlocking**, then decays to `open`. |

**Dimension 2 — save:** `saved` (filled bookmark, `--primary`) · `not-saved` (outline bookmark,
`--ink-muted`).

**Rules:**
- **The dictionary must not feel blocked by default** (IA risk + journey guardrail). Open prompts
  are the visual default and carry no lock furniture. Only genuinely sensitive categories gate.
- `unlocked` decays to `open`. Permanently badging a prompt as "unlocked" would keep re-teaching a
  lesson already learned, and would make the dictionary feel more gated over time, not less.
- Save state is available in every access state **except** `learn-first` — you cannot save what you
  cannot use.
- Titles use the **teacher's word, never the AI term** (foundations §5: UI chrome is never a
  vocabulary test; learning content is where real terms get scaffolded).

## Prompt detail

**Serves:** `Prompt → Prompt detail` · journey step 2 ("Get a safe first win").

**Anatomy, in order:**
1. Title in teacher language (`--fs-h1`).
2. "What this prompt helps with" (`--fs-body`).
3. Editable prompt template (`--fs-body`, `--card`, `--r-card`) with inline placeholder fields —
   `jenjang`, `mapel`, `topik`, `tujuan` — **prefilled from onboarding context**.
4. Safety reminder callout, where relevant.
5. **Primary:** `Salin prompt` (sticky bottom pill).
6. **Secondary:** `Simpan`.
7. **Dormant slot:** `Buat di aplikasi`.

**Rules:**
- **The prompt-only path must be complete.** `Buat di aplikasi` is a reserved slot — rendered only
  when in-app generation exists, and its absence must never break the layout or the flow. v1 is
  *generation-ready but prompt-only functional*.
- Placeholders prefill from teacher context to reduce typing (journey step 5).
- Copy failure shows a retry and permits manual text selection (journey failure state).

## Locked prompt explainer

**Serves:** `Prompt → Locked prompt explanation` · journey step 4 · Flow B.

**Anatomy:** bottom sheet containing — **why** this prompt is gated (plain Bahasa, one sentence),
**which** check is required (named), **how long** it takes, and a **primary pill deep-linking to
the exact `Belajar` node**.

**Rules:**
- **Instructional, never punitive.** The tone explains a reason; it does not scold. Example
  register: *"Prompt ini menyentuh data siswa. Selesaikan cek privasi dulu."*
- Must name the *exact* node and deep-link to it. "Go learn more" is a failure.
- Uses the `verify` or `safe` callout register — **not** `danger`. Being gated is not a violation.

## PII guardrail callout

**Serves:** journey failure state ("Teacher tries to use student PII in a prompt") · the
`safety_ack` from onboarding step 5.

**Anatomy:** `danger` callout with `alert-triangle`, the rule, and a **suggested anonymized
rewrite**.

**Rules:**
- **This is deliberately the coldest copy in the product.** Foundations §5's tone ladder puts
  student-data warnings at *high stakes*: formal and unadorned, no particle (`ya`, `kok`, `aja`,
  `nih`, `yuk`), no metaphor, no warmth, full `tidak` and never `nggak`. When the user can be
  harmed, wit reads as evasion. That coldness is a feature.
- Always offers the anonymized alternative. A warning without a path forward is a dead-end.
- `danger` red appears here and on real errors. Nowhere else.

## Win moment

**Serves:** first win (onboarding → account moment trigger) · module completion · streak marks.
**In-loop only.**

**Anatomy:** amber check + subtle particle burst (≤ `--dur-win`), a badge chip, and a **concrete
value line** with a leading `clock` icon — e.g. *"Selesai! Anda baru saja menghemat ~40 menit."*

**Rules:**
- **Medium, not maximal.** Not persistent confetti; not silent. One celebratory beat, then out of
  the way.
- `--win-*` tokens only. **Never** `--readiness-*`.
- **Reduced-motion fallback:** static badge + value line, no burst.
- **SVG only, never emoji** (foundations §3: emoji render inconsistently across low-end Android
  vendor fonts and cannot inherit theme colour).
- The value line makes the win concrete and repeatable — this is where a low-confidence teacher's
  self-efficacy is made or lost.

## Readiness completion

**Serves:** `Belajar → Final readiness check` (pass) · journey step 6. **The terminal moment.**

**Anatomy:** the **only full-viewport colour surface in the product** — `--readiness-bg` ground,
`--readiness-fg` text, `--readiness-accent` for the confirming mark. Contains: a confirming mark,
a **capability summary** ("what you can now do") written as demonstrated practice rather than
awarded status, the newly unlocked prompt categories, and suggested next daily-use prompts.

**Rules:**
- **Structurally unlike a badge win.** The distinction is composition, not just hue: no other
  surface fills the viewport with colour. A badge is a chip inside a screen; this *is* the screen.
- **No certificate iconography. Ever.** No seal, ribbon, ornamental border, signature line, or
  serif flourish. v1 issues no self-issued certificate — and if the screen *looks* like one, the
  guardrail is broken no matter what the copy says. A teacher will screenshot this; it must not be
  screenshot-able as a credential.
- **No credential language** — no certification, PD-hour, PKB, or government-recognition claim.
  Frame around **real professional progress**.
- **PD-credit-ready structure.** Compose the capability summary so that a future official PPG /
  PKB integration can attach to it without a redesign. Keep the demonstrated-capability list as
  discrete, nameable items rather than prose.
- Tab bar is absent here. This is an arrival, not a destination you navigate away from casually.
- Failing shows weak areas + deep-links to specific nodes + retry **without penalty**.

## Validation check types

**Serves:** `Belajar → Validation check` · `validation-model.md`.

Shared anatomy: a prompt/stem at `--fs-bodylg`, the interaction, a submit pill, then a **feedback
panel** (below). Shared rules: **short and mobile-friendly**; **no open-ended essays, no AI-graded
free text** (validation-model "Avoid in v1"); every item is retryable.

| Type | Interaction anatomy |
|---|---|
| **MCQ / myth-vs-fact** | 2–4 full-width pill options, single-select; selected uses `--primary-tint`. |
| **Scenario sorting** | Scenario card + three destination targets: `boleh` · `jangan` · `tergantung`. Tap-to-assign, **not drag** — drag fails on low-end touch panels and one-handed use. |
| **Spot-the-risk** | A prompt/output rendered as tappable spans; teacher taps the risky part. Correct spans confirm with `--safe-text`; missed risks reveal in `--danger-text`. |
| **Prompt repair** | A weak prompt plus 2–4 candidate improvements, single-select (**choose or assemble, never free-type**). |
| **Output critique** | An AI output with tappable segments; teacher marks what needs checking. Uses the `verify` register throughout — this is the check-it habit being built. |
| **Classroom dilemma** | Scenario + three judgments: cheating · acceptable · depends. Feedback explains the nuance rather than a bare verdict. |
| **Confidence pulse** | 1–5 scale, "Saya bisa memakai ini minggu ini." **Never graded, never gates anything.** |

## Feedback panel

**Serves:** every validation check.

**Anatomy, in order** (validation-model's three-part model):
1. **What the correct answer is.**
2. **Why it matters for teacher practice.**
3. **What to do next.**

**Rules:** explanatory, never bare right/wrong. Uses `--safe-text` for correct and `--danger-text`
only where the content is a genuine never-do — a wrong answer is not a never-do, and must not
borrow the danger register. Failing links back to the specific lesson node.

## Onboarding step

**Serves:** `onboarding.md` screens 1–5.

**Anatomy:** a single question as the heading (`--fs-h1`), one input, one primary pill, optional
`Lewati` as a text button. Optional progress indicator.

**Rules:**
- **One decision per screen.** Large targets, plain "Anda" copy, no jargon — this scaffolds the
  age-linked confidence gap explicitly.
- `Lewati`, where it exists, is **always visible** — never hidden behind a scroll.
- **No account wall, no permission prompts, no feature tour** before value.
- Completes fully **offline** — nothing leaves the device until the account moment.
- Heading register is a question: *"Anda ngajar di jenjang apa?"* (foundations §5).

## Account moment

**Serves:** `onboarding.md` → the deferred account sub-flow. Fires **inside Belajar**, after a
first win.

**Anatomy:** bottom sheet — loss-framed headline, a lightweight method (phone / Google), and a
**visible `Nanti`**.

**Rules:**
- **Loss-framed, not admin-framed.** *"Simpan progres Anda agar tidak hilang"* — protecting earned
  progress, not "make an account."
- Frames around **protecting real professional progress**, **never** "save your badge" (the
  resolved cert-vs-badge decision).
- **Never blocks.** `Nanti` keeps full function in guest mode; re-offer at the next win.
- **Be honest** that unsaved guest progress is device-only until registration.

---

# Tier 3 — Surface map

Every screen in the IA, the components it composes from, and its single primary action. A
prototype screen that is not on this list is an invented screen.

## Onboarding *(boundary flow — no tab bar)*

| Screen | Components | Primary action |
|---|---|---|
| 1 Welcome | Onboarding step | `Mulai` |
| 2 Jenjang | Onboarding step, chip, bottom sheet | auto-advance on tap |
| 3 Mapel | Onboarding step, chip (multi) | `Lanjut` |
| 4 First need | Onboarding step, chip, text button | tap option · `Lewati` |
| 5 Ground rule | Onboarding step, `danger`-register rule text | `Saya mengerti` |

## Belajar

| Screen | Components | Primary action |
|---|---|---|
| Current path | Path node (all types/states), progress indicator, tab bar | open active node |
| Module detail | Module card, path node list, badge chip | start next unit |
| Unit player | Lesson prose (`--fs-bodylg`), callout, pill button | continue |
| Validation check | Validation check type, feedback panel | submit |
| Prompt-use moment | Prompt card, prompt detail | `Salin prompt` |
| Badge milestone | Win moment, badge chip | continue |
| Final readiness check | Validation check types (mixed set) | submit |
| **Readiness completion** | Readiness completion *(no tab bar)* | continue to suggested prompts |
| *(overlay)* Account moment | Account moment sheet | register · `Nanti` |

## Prompt

| Screen | Components | Primary action |
|---|---|---|
| Search & filters | Pill input, chip, prompt card | open prompt |
| Categories | List row, card | open category |
| Prompt list | Prompt card (access × save) | open prompt |
| Prompt detail | Prompt detail, PII guardrail callout | `Salin prompt` |
| Saved prompts | Prompt card (saved), list row | open prompt |
| Locked explanation | Locked prompt explainer (sheet) | go to required check |

## Profil

| Screen | Components | Primary action |
|---|---|---|
| Teacher context | List row, chip, bottom sheet | edit context |
| Progress | Progress indicator, list row | open a node |
| Badges | Badge chip (earned/unearned) grid | view badge |
| Saved activity | Prompt card, list row | open prompt |
| Settings | List row, bottom sheet | — |

---

# Open questions

Recorded, not resolved.

**Inherited from `DESIGN-FOUNDATIONS.md` §8** *(all still open)*:
- Exact hex values on real low-end device screens in daylight **[to validate]**.
- Bahasa copy + term choices reviewed by a native-speaker educator **[to validate]**.
- `Anda` vs `kamu` — the teacher-as-learner framing argues for `kamu`, teacher-as-professional
  for `Anda`. Not settled by desk research **[to validate with teachers]**.
- Dark-theme hues are a first pass; verify contrast pairs on device.

**Opened by this document:**
- **Highest-risk assumption.** Whether a readiness completion reads as *credible* to an
  Indonesian teacher **without** certificate iconography is untested — and it sits directly on
  top of the cert-vs-badge decision's own flagged weakness (2 directly-Indonesian anchors). If
  teachers read the no-certificate screen as *worthless* rather than *honest*, the terminal
  motivation collapses and the whole badge-demotion premise needs revisiting. **First in line for
  primary research.**
- **Two of the five palette colours never appear in the UI.** `--deco-orange` and `--deco-red`
  are illustration-only, because they cannot be told apart from `--win-fill` under
  colour-blindness. If the warm ramp is meant to be the brand's visible signature rather than
  its illustration palette, that intent is **not** currently expressed — and it can't be
  without weakening the win/danger signal. Worth confirming this is the trade you want.
- **The brand has changed three times** (teal → green → indigo) in one day, and none of the
  three has been tested with an Indonesian teacher. Brand hue is one of the cheapest things to
  test and one of the most expensive to get wrong post-launch. **The palette is not the risk;
  the absence of a read from a real teacher is.**
- **In dark mode `--primary` and `--primary-bright` converge** on the same value, so components
  lose the light theme's deep/bright distinction. Shape and weight must carry it instead —
  verify this doesn't flatten the path-node hierarchy on a real dark screen.
- **Indigo's local reading is untested.** The teal and green directions each carried a specific
  Indonesian association (calm/credible; marketplace). Indigo carries a different one — it is
  close to the batik-indigo tradition, which may read as locally rooted, or may read as
  generic-tech. Unknown either way without a teacher.
- `--readiness-*` contrast pairs need device verification, same as foundations' existing hexes.
- Whether `unlocked` decaying to `open` is the right call, or whether teachers want durable proof
  of what they unlocked **[to validate]**.
- The `Buat di aplikasi` dormant slot has no visual spec until in-app generation is scoped —
  deliberately, to avoid designing a feature we have not decided to build.
