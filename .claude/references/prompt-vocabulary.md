# Prompt vocabulary — the house language standard

The precise terms this workspace uses when it prompts, drafts, and reviews. It is a
**vocabulary**, not a workflow: `.claude/references/design-gates.md` says *which pass to
run*, this file says *how to phrase it* — and, just as importantly, which words to refuse.

Keywords are not magic. They work because each one is a **compressed pointer to a body of
method**. "Run a usability test" yields a generic script; "run a *formative*, *moderated*,
*think-aloud* study with *counterbalanced* task order, reporting *task success rate* and
*SEQ*" yields an instrument, because every one of those terms drags a standard behind it.

Four levers do the work; the banks below are how you pull them.

1. **Role & altitude** — who is speaking, and how high they are flying.
2. **Named method** — the term that imports its own rigor.
3. **Evidence discipline** — what is allowed to count as a claim.
4. **Output contract** — the shape you will accept back.

## Who uses this

| Surface | Uses it for |
|---|---|
| `/new-design` | The `## Problem` statement — job-story form, no unfalsifiable adjectives. |
| `/draft-prd` | §2 evidence language, §3 JTBD form, §5 metrics, §7 shape, §9 acceptance criteria. |
| `/design-prototype` | The `copy`, `critique`, `friction`, `a11y`, and `states` gate passes. |
| Principal Designer (Modes S, T) | Detecting unfalsifiable claims and untestable acceptance criteria. |
| Research spine (`/plan-usability`, `/synth-findings`, `/review-research`) | Method names, bias vocabulary, severity and confidence language. |

Applying it is **not** a licence to inflate. A term names a standard you are actually
meeting; using `triangulated` for a single session, or `WCAG 2.2 AA` for an unaudited
screen, is a fabrication in the same way an invented finding is. If the standard was not
met, do not reach for the word.

---

## A. Role & altitude

`Act as a Principal UX Researcher` · `Senior Product Designer` · `design partner, not
order-taker` · **opinionated, not descriptive** · `strategic altitude` · `decision-ready` ·
`so-what` · `design implication` · `pressure-test` · `steel-man, then attack` ·
`red-team this` · `adversarial review` · `what would a skeptic say`

The highest-leverage two words in the whole file: **"and the so-what?"** It forces every
observation into an implication, which is the difference between a note and a finding.

## B. Problem framing & discovery

`jobs-to-be-done` · `job story (when <situation>, I want to <motivation>, so I can
<outcome>)` · `problem space vs solution space` · `opportunity solution tree` ·
`assumption mapping` · `riskiest assumption test (RAT)` · `desirability / viability /
feasibility` · `appetite` (fixed time, variable scope) · `north star metric` ·
`HEART framework` · `activation` · `aha moment` · `time-to-value` · `first-run experience` ·
`behavioral segment` (not demographic) · `proto-persona` · `mental model` vs `conceptual
model` · `mental-model gap` · `top tasks`

## C. Method names (each imports its own rigor)

- **Generative** — contextual inquiry · diary study · semi-structured interview ·
  `laddering` · critical incident technique · ethnographic observation · switch-moment
  (jobs) interview
- **Evaluative** — cognitive walkthrough · heuristic evaluation · think-aloud protocol
  (*concurrent* vs *retrospective*) · moderated vs unmoderated · formative vs summative ·
  `within-subjects` / `between-subjects` · `counterbalancing`
- **IA & findability** — open / closed / hybrid card sort · tree testing · first-click
  test · five-second test · `information scent`
- **Attitude & preference** — desirability testing (reaction cards) · preference test ·
  SUS · UMUX-Lite · SEQ · `task success rate` · `time-on-task` · `error rate`
- **Experimental** — A/B · multivariate · `guardrail metric` · `minimum detectable
  effect` · `statistical power` · `sample size justification`

## D. Rigor & bias — the real differentiator

The cluster that separates senior output from confident-sounding output:

`construct validity` · `internal / external / ecological validity` · `confound` ·
`leading question` · `double-barrelled question` · `social desirability bias` ·
`acquiescence bias` · `selection bias` · `survivorship bias` · `priming` · `moderator
effect` · `Hawthorne effect` · `triangulation` · `member checking` · `inter-rater
reliability` · `thematic analysis` · `axial coding` · `saturation` ·
**`disconfirming evidence`** · `effect size vs significance` · `base rate` ·
`confidence label` · `provenance`

Ask for **`disconfirming evidence`** by name and the answer changes character: it flips
the work from justifying a finding to auditing it.

## E. Synthesis

`affinity diagram` · `theme` vs `finding` vs `insight` · `signal vs noise` ·
`we observed X → which suggests Y → therefore Z` · `severity (0–4)` ·
`frequency × impact × persistence` · `journey map` · `service blueprint` (front-stage /
back-stage / support) · `experience map` · `friction log` · `moment of truth` ·
`pain point` vs `opportunity area` · `How Might We` · `POV statement` ·
`design principle` · `explicit tradeoff`

## F. Interaction & cognition — the named laws

Naming a law makes the reasoning checkable instead of a matter of taste:

`affordance` / `signifier` / `mapping` / `constraint` / `feedback` / **`feedforward`** ·
`gulf of execution` & `gulf of evaluation` · `recognition over recall` · `cognitive load`
(intrinsic / extraneous / germane) · `Hick's law` · `Fitts's law` · `Jakob's law` ·
`Tesler's law` (conservation of complexity) · `Doherty threshold` (~400ms) ·
`peak-end rule` · `serial position effect` · `von Restorff effect` · `Zeigarnik effect` ·
`goal-gradient` / `endowed progress` · `choice architecture` · `default effect` ·
`deceptive pattern` (use this, not "dark pattern") · `intentional friction` ·
`forgiveness / undo` · `error prevention vs error recovery` · `progressive disclosure` ·
`optimistic UI` · `latency budget` ·
`empty / loading / error / partial / offline` **state coverage**

## G. IA, content & UX writing

`taxonomy` · `labelling scheme` · `navigation model` · `wayfinding` · `findability vs
discoverability` · `chunking` · `content model` · `microcopy` · `voice and tone` ·
`error message anatomy (cause + fix)` · `front-loaded scanning` · `plain language` ·
`reading level`

## H. Visual & systems design

- **Structure** — `design token` (primitive → semantic → component) · `modular type
  scale` · `8pt grid` · `baseline grid` · `optical alignment` · `elevation scale` ·
  `density` · `visual hierarchy` · gestalt: `proximity, similarity, closure, continuity,
  common region` · `figure-ground` · `negative space`
- **Motion** — `easing (ease-out entering, ease-in exiting)` · `choreography` · `stagger` ·
  `spatial continuity` · `shared element transition` · `interruptible` ·
  `prefers-reduced-motion`
- **Systems** — `component API` · `variant / slot` · `semantic color token` ·
  `dark-mode tonal variant` (not inversion) · `governance` · `deprecation path`

**Style names.** Name one precisely instead of saying "modern". A usable set:
Swiss Modernism 2.0 · Editorial Grid / Magazine · Bento Grids · Glassmorphism ·
Liquid Glass · Neubrutalism · Claymorphism · Neumorphism · Aurora UI / Gradient Mesh ·
Material You (MD3) · Spatial UI (visionOS) · Exaggerated Minimalism · Minimalist
Monochrome · E-Ink / Paper · Kinetic Typography · Organic Biophilic · Retro-Futurism ·
Y2K · Vaporwave · Memphis · Bauhaus · Data-Dense Dashboard · Executive Dashboard ·
HUD / Sci-Fi FUI · Dark Mode (OLED) · AI-Native UI · Zero Interface ·
Voice-First Multimodal

In this workspace a named style describes *intent*; the actual values still come from
`ui-library/tokens.css` and, where the project diverges, its `tokens.overlay.css`. Naming
a style never licenses a raw value.

## I. Accessibility & inclusion

`WCAG 2.2 AA` — and **cite the success criterion by number**: 1.4.3 (contrast),
1.4.11 (non-text contrast), 2.4.7 (focus visible), 2.5.8 (target size),
3.3.1 (error identification) · `perceivable / operable / understandable / robust` ·
`semantic HTML first` · `no ARIA is better than bad ARIA` · `focus order` ·
`keyboard trap` · `live region` · `screen reader announcement` · `colour-independence` ·
`dynamic type` · `situational, temporary, permanent disability` ·
`cognitive accessibility` · `accessibility acceptance criteria`

## J. Output-contract phrases

The most-forgotten bank, and the one that changes results most — these control the shape
of what comes back, not its content:

- `evidence-cited — every claim carries a source ID`
- `severity-ranked, highest first`
- `label each finding high / medium / low confidence`
- `flag assumptions explicitly; do not state them as fact`
- **`if it was not observed, say "not observed" — never infer it as fact`**
- `quarantine refuted or weak claims in a separate section`
- `give me the tradeoff and a recommendation, not a menu of options`
- `vertical slice — independently shippable and demoable`
- `acceptance criteria per slice`
- `what would change your mind about this finding?`

---

## Anti-keywords (house rule)

These are unfalsifiable, so they get filled with cliché. Do not ship them in a `PRD.md`,
a prototype's copy, a `SYNTHESIS.md` finding, or a deck headline.

| Instead of | Write |
|---|---|
| modern, clean, beautiful | a **named style** — "Swiss Modernism, 8pt grid, monochrome plus one accent" |
| intuitive, user-friendly | "recognition over recall; first-click success ≥80%" |
| engaging, delightful | "peak-end rule at the completion moment" |
| seamless | "zero handoff — no re-auth, no re-entry of known data" |
| best practices | the criterion — "WCAG 2.2 AA §2.5.8", "Nielsen heuristic 5" |
| improve UX | "reduce time-on-task for the top task" |
| robust, scalable, leverage, streamline | the concrete mechanism, or delete the sentence |

The test: **can it fail?** If no observation could falsify the sentence, it is decoration.
In a PRD §9 acceptance criterion this is not a style problem but a defect — an untestable
criterion cannot gate anything, and the Principal Designer treats it as one.

---

## Scaffolds

**Research plan**

> Act as a Principal UX Researcher. Design a *formative*, *moderated* usability study for
> `<flow>`. Give me 5 *task scenarios* (goal-framed, not instruction-framed), a
> *think-aloud* moderator script free of *leading* and *double-barrelled* questions, and a
> metric set: *task success rate*, *time-on-task*, *SEQ*. State the *construct validity*
> risk of each task and how *counterbalancing* handles order effects. Flag anything only
> testable in the field for *ecological validity*.

**Synthesis critique**

> Act as an *Evidence Auditor*. For each finding: name the *evidence* behind it, rate its
> *strength*, identify the *confounds* and the *bias* most likely at play, and cite any
> *disconfirming evidence* in the data. Mark any claim that *generalizes beyond its
> sample*. Return *severity-ranked*, one claim per row, with a *confidence label*. Do not
> repair weak findings — flag them.

**Design brief**

> Act as a Senior Product Designer. From these findings, define the *solution shape* for
> `<feature>` as one *vertical slice*. Use *progressive disclosure* for the advanced path
> and *recognition over recall* for the primary. Specify all five *states* (empty,
> loading, error, partial, success), a *latency budget* under the *Doherty threshold*, and
> *acceptance criteria* in Given/When/Then. Style: `<named style>`, *semantic tokens only*,
> WCAG 2.2 AA with *target size (2.5.8)* met. Give me the *tradeoff you made*, not the
> option list.
