# Notes — CodeSignal (web)

Analysis. The step-by-step lives in `flow.md`.

**Standing caveats.** First-party Chrome capture, **2026-07-29**, trigger C2 (no Mobbin web
coverage). Desktop-web viewport, 1280×495–551 CSS px — narrower than a full desktop fold, so
ordering and presence are supportable claims here and *visual dominance measured against the
fold* is not. **Audience transfer is the weakest in the study**: CodeSignal is a technical
assessment and interview-prep platform for professional developers on paid tiers — the same
objection that cut Unity Learn at plan stage. It was added at user request with that caveat
recorded in `PLAN.md`, and **no finding here should outweigh Duolingo or Babbel on any question
about young or low-context learners.** Account creation itself was not observed (see `flow.md`,
*Capture conditions*).

---

## Observation 1 — A third zero-state mode the slot rule does not cover (Q2)

The study's strongest pattern so far is the **slot rule**, sighted independently at Uxcel,
Brilliant, and Babbel: *progress-derived slots stay present and state the condition that would
fill them; content-derived slots are populated from the first second.* Nothing hidden, nothing
fabricated.

CodeSignal's *My Learning* is neither branch. The slot is **reassigned** — the surface that
should hold the learner's own path is, at zero state, a full-panel advertisement for the mobile
app, followed immediately by the site-wide marketing footer
(`screenshots/10-…`, `11-…`). There is no message naming what is missing, no recovery action
pointing at the catalogue, and no reference to the path recommended minutes earlier.

That gives a three-way taxonomy the synthesis should carry, because the third mode is the one
our PRD is least protected against:

| Mode | Instance | What the learner learns |
|---|---|---|
| Present, condition stated | Uxcel, Brilliant | What to do to fill it, in countable terms |
| Populated from content | Babbel, Brilliant | Where to start now |
| **Reassigned to promotion** | **CodeSignal** | Nothing about their own learning |

**So what.** `PRD.md` §9 Slice 9 currently requires *"Missing downstream content shows a neutral
empty state and recovery action rather than fabricated progress."* That criterion was written
against the failure mode our own prototype exhibits — fabricated progress, the hard-coded 1-day
streak (`prototype-web.html:538`) and 150 points (`:541`). CodeSignal is the **disconfirming
case in the other direction**: it fabricates nothing and still tells the learner nothing,
because the slot was spent on a cross-sell. The criterion is satisfiable by a surface that fails
the learner. It needs the second half — that a first-run slot may not be reassigned to
promotion — or it does not gate what it was written to gate. That is a wording change, not a
scope change; the appetite cost is roughly zero.

## Observation 2 — Intake payoff has degrees of failure, and this is the lower one (Q3)

Coursera was the study's clearest intake-payoff case *and* its most instructive failure: the
goal is restated in the learner's framing, left editable in place, and then followed by a rail
headed *"Most Popular Certificates"* — echoed but not acted on.

CodeSignal sits one rung below. The intake resolves to something far more specific than
Coursera's career goal — a **named path with a course and practice count**, *JavaScript
Programming for Beginners, 7 courses · 184 practices* — and then **no home surface carries it at
all**. Not the Paths home, not *My Learning*. Instead the home offers **"Not sure where to
start? … Find your path"** (`screenshots/08-…`): an invitation to run the conversation the
learner has just finished.

| | Coursera | CodeSignal |
|---|---|---|
| Intake specificity | Career goal (broad) | **Named path + unit counts** (specific) |
| Echoed on the home? | Yes, persistent, editable | **No** |
| Acted on by home content? | No — popularity ordering | **No** — trend ordering, and levels not declared |
| Net | Told it mattered, shown it did not | **Not told, not shown** |

The ranking matters for our funnel because the two failures have different fixes. Coursera's is
a content-mapping problem. CodeSignal's is a **persistence** problem: the recommendation exists
only inside the chat transcript, so leaving the conversation discards it.

**So what.** §11 assigns *"Canonical goal taxonomy and goal-to-first-course map"* to Content +
Product. CodeSignal shows that resolving the map is necessary but not sufficient — **the result
has to be stored on the learner and read by the home**, or the funnel computes an answer and
throws it away. For our six-goal manually approved map that is a field, not a system. State it
in the synthesis as an explicit requirement on Slice 9 rather than leaving it implied by §11.

## Observation 3 — The four-platform split survives, but the axis needs restating (Q4)

The hypothesis opened at Uxcel, tested at Brilliant, and confirmed at Coursera: *the single
recommended next step is conditional on intake producing something specific enough to route on.*
Brilliant and Babbel resolve intake to a named unit and land on one dominant action; Uxcel and
Coursera do not and land on a menu.

CodeSignal looks at first like a counter-example that breaks the axis. Its intake resolves to a
named unit — the specific-enough condition is met — and yet the home is a catalogue: a
six-tile Collections grid, a Trending rail, and an app promotion above both.

It is not a counter-example. **The single dominant action exists** — a filled primary **Start
path** against an outlined **Learn more** — it just lives **inside the conversation**
(`screenshots/05-…`, `06-…`) and never reaches the home. So the axis holds, with one term added:

> The single-next-step pattern requires intake to resolve to a named unit **and** the surface
> that renders the next step to have access to that result.

CodeSignal satisfies the first and fails the second, which is why it produces both a textbook
single next step and a textbook catalogue home in the same session. That is a sharper statement
than the four-platform version, and it is the one that transfers to us: our Slice 6 produces a
goal identifier, and Slice 9 renders the home. If those two do not share state, we reproduce
this exact outcome no matter how good the §11 map is.

**Disconfirming evidence, recorded:** the level question is asked *after* a beginner path has
already been recommended, and answering it **replaces** the recommendation (Python → JavaScript)
while leaving both cards live with equally weighted CTAs. So even inside the conversation the
"single" next step is, at the end, **two** — which weakens any reading of CodeSignal as a clean
single-next-step instance. It is a clean instance of the *card pattern*, not of the *single*.

## Observation 4 — Second counter-instance to the countable unlock condition (Q5)

The slot rule's sharpest sub-finding is that unlock conditions are **countable**: *"0 of 175
XP"*, *"Earn 100 PX"*, *"Complete 9 more lessons"*, *"Solve 3 problems"*. Babbel was the useful
counter-instance — a streak at 0 with **no** stated condition.

CodeSignal is the second. The top nav carries a flame glyph reading **"0 days"** on every
authenticated screen (`screenshots/07-…` onward), with no adjacent text stating what would make
it 1, and no tooltip pursued. It is a counter rendered at zero, in the same visual register as a
populated one.

Two of six platforms now show a zero-value counter with no stated condition. That is enough to
stop the synthesis from writing the countable condition as a rule and make it a **majority
pattern with named exceptions** — which is the honest form and the one that survives review.

**So what.** Our prototype's two fabrications are a 1-day streak and 150 points. The replacement
is not "show 0 days" — Babbel and CodeSignal show that a bare zero states a fact without giving
a reason to act. It is the Uxcel/Brilliant form: **zero plus the countable condition that
changes it.** That is the concrete instruction the synthesis owes Slice 9.

## Observation 5 — Conversational intake, and what it costs (Q3, secondary)

The intake is an LLM exchange with a mascot persona rather than a stepped form: quick-reply
chips and a persistent free-text field live for the same question, each answer is acknowledged
before the next, and the result renders as a card in the transcript.

Two properties are worth carrying, and one warning.

Worth carrying: it **asks permission before spending effort** (*"Before we take off, can you
answer a few questions…"*) and **states the purpose** of the questions in the same breath. Our
Slice 5 collects an age band and, per the study's Duolingo and Brilliant sightings, does not
explain why it asks. This is the cheapest version of that explanation — one sentence, before the
first question, with an explicit **Skip for now**.

The warning: the exchange is **not deterministic**. The same declared profile produced two
different first paths within one turn (`screenshots/06-…`), and there is no progress indicator —
no *"Step 2 of 4"* as at Coursera — so the learner cannot tell how much is left. For a
free-access, low-context audience on a metered connection, an intake with no visible end and a
recommendation that changes under you is a worse trade than a four-step form. **Do not port the
conversational intake to our funnel on the strength of this capture.** The transferable parts
are the permission ask and the stated purpose.

---

## What this platform does and does not answer

**Answers well:** **Q2** — first-party, genuine zero state, and the only instance in the study of
a first-run slot reassigned to promotion. **Q3** — the lower rung of intake-payoff failure, and
the persistence problem behind it.

**Answers partially:** **Q4** — restates the axis rather than adding a data point, and supplies
disconfirming evidence against itself. **Q5** — a second counter-instance to the countable
unlock condition.

**Does not answer:** **Q1** — account creation was not observed, so the handoff between the
signup submit and the first screen is **not observed** here; no finding rests on it. **Q6** — no
cohort or class-code mechanic exists in this product.

**Observed and not transacted:** an **Upgrade** control is present in the top nav on every
authenticated screen, and a green-dotted notification bell. Neither was pursued; no paid surface
was entered.
