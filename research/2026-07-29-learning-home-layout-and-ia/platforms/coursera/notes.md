# Notes — Coursera (analysis)

Source: Mobbin reference library, `web`, accessed 2026-07-29. Three screens. **Reference-library
observation, not first-party.**

---

## Observation 1 — four learner destinations, with the utilities lifted out (Q1)

Coursera's learner nav is **four items**: `Home`, `My Learning`, `Online Degrees`, `Careers`.
Everything that is not a destination — search, language, cart, notifications, account,
catalogue browse — sits in a **separate row above**, as controls rather than nav items.

That is a variant of Codecademy's two-tier device with a different cut. Codecademy splits by
**scope** (the product's things above, the learner's things beside). Coursera splits by **type**:
*places you go* below, *controls you use* above.

Both splits are available to us, and the Coursera cut is the cheaper one to apply, because it
does not require deciding who owns each destination — only whether it is a place or a tool.

Applied to our eleven, the utility cut alone is small: our header already holds the language
selector, theme toggle, XP counter, and sign-out separately from the nav. So Coursera's device
is largely **already in place** on our baseline; it is the eleven remaining *places* that carry
the problem. Useful mostly as a negative result — this is the one device in the set that would
not help us.

## Observation 2 — the goal is stated three times, in three registers (Q5)

On `Home`: a `Weekly goal progress tracker` card with seven weekday circles, and a separate
full-width strip stating the **career** goal in a sentence. On `My Learning`: both again, moved
into a right rail, with the career goal folded into a greeting card.

So Coursera runs two distinct goal horizons at once — a **weekly behavioural goal** (three days
a week, rendered as dots) and a **career outcome goal** (become a Product Designer, rendered as
a sentence with an edit affordance). They are visually different: the weekly goal is a widget,
the career goal is prose.

Directly relevant to our baseline, which renders `GOAL: CUSTOMER SUPPORT · READINESS 0%` as a
single line in the hero, and then `READINESS NOW · 0%` again inside the objective card.
Coursera's version separates *what you are working toward* from *whether you showed up this
week*; ours states the same readiness figure twice and no behavioural goal at all.

*(Guard check: region and count only. This does not touch F3's intake-payoff ladder, which
concerns whether the intake signal is reflected at all; here both goals are established and the
question is where they sit.)*

## Observation 3 — the resume card carries the next item, not just the course (Q3)

The ranking device is a **two-pane card**: identity and progress on the left, the specific next
item plus a filled `Resume` button on the right. The learner is told they are resuming into
`Welcome to module 1 · Video (1 minute)` — a named, time-bounded thing.

Combined with Uxcel (`Current Lesson: The Anatomy of UI Components`, `7h left`), that is **two
of six platforms naming the specific next item and its cost inside the resume control**. Both
reduce the decision to continue into a decision about one small known thing.

Our baseline does the same in copy (`Angry customer`, `~8 min`, `one task, then you're done`),
which is a genuine strength worth recording — the defect is placement and competition, not the
card's content.

*(Guard check: ranking **device**, the neighbouring study's unmeasured half.)*

## Observation 4 — the learner's work ends, then merchandising begins (Q2)

Ordinal order on `Home`: **resume card + weekly goal → career-goal strip → merchandising**
(`Recently Viewed Products`, or `Earn Your Degree` university cards).

The boundary is clean and worth naming as a structural device: there is a point in the page
after which nothing belongs to the learner. Codecademy inverts it, putting a bootcamp promo
*above* `Keep learning`; Coursera puts the learner first and the catalogue after.

Our baseline has no such boundary — the tagline, the philosophy paragraph, the coach card, the
objective, the focus card, the loose content items, and the design-rule card interleave without
a rule about whose content each block is.

## Observation 5 — the rail appears only where the centre gets narrower (Q5, Q2)

`Home` has no rail; `My Learning` has one. Same pattern as Babbel, opposite to Uxcel and
Duolingo, where the rail is a persistent shell.

Across the four web platforms holding a rail, the study now has **two published positions**:
the rail as persistent furniture (Duolingo, Uxcel) and the rail as per-view content (Babbel,
Coursera). Worth carrying into any responsive decision, since a per-view rail is far easier to
collapse at narrow width than a shell one.

---

## Caveats carried

- **Reference-library observation.** No first-party use, no live behaviour, no timing.
- **Point-in-time**, accessed 2026-07-29.
- **`Explore ▾` contents unobserved**, so the "four destinations" count is *exposed* learner
  tabs and understates the catalogue's true depth.
- **Narrow-width behaviour unobserved.**
- **Audience transfer:** a paid credential marketplace for adult professionals, with a cart in
  the header. Its merchandising boundary is a device we can borrow; its content mix is not.
