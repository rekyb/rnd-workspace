# References: external validation (Principal Researcher QA, 2026-07-17)

Peer-reviewed and reputable sources retrieved to validate the rationales in
`SYNTHESIS.md`. Each entry: author + year, title, venue, one-line finding, URL, and which
feature it supports or challenges. Sources were retrieved via web search on 2026-07-17;
URLs verified reachable at capture time. This layer complements (does not replace) the
on-disk captured evidence.

---

## Feature 1: Value-before-signup (deferred registration)

**Baymard Institute (2024). "How to Reduce Cart Abandonment."** UX research institute
(large-scale checkout usability studies).
*Finding:* forced account creation is the second-highest single cause of checkout
abandonment (~26% of abandoners), and offering guest completion with the account ask moved
to *after* the goal reduces abandonment. Supports F1's "wall-first raises effort/lowers
trust at the worst moment" claim.
URL: <https://baymard.com/learn/reduce-cart-abandonment>
*Caveat:* e-commerce checkout context, not education onboarding; supports direction, not magnitude.
**Supports F1.**

**Spool, J. M. (2009). "The $300 Million Button."** User Interface Engineering
(practitioner case study).
*Finding:* replacing a forced-registration wall before checkout with a guest "continue"
option lifted completion ~45% and large revenue; first-time users resisted registering
*before* getting value but registered willingly *after*. Supports F1's re-ordering thesis.
URL: <https://articles.centercentre.com/three_hund_million_button/>
*Caveat:* uncontrolled single-company case study, not peer-reviewed; directional evidence only.
**Supports F1 (directionally).**

---

## Feature 2: The engineered first win (the aha moment)

**Ryan, R. M., & Deci, E. L. (2000). "Self-Determination Theory and the Facilitation of
Intrinsic Motivation, Social Development, and Well-Being." American Psychologist, 55(1),
68–78.**
*Finding:* competence is one of three innate psychological needs; events, feedback, and
communications that support felt competence enhance intrinsic motivation for the activity.
Directly supports F2's "an early experience of competence drives intrinsic motivation" and
F3's "autonomy is an SDT need" rationale.
URL: <https://selfdeterminationtheory.org/SDT/documents/2000_RyanDeci_SDT.pdf>
**Supports F2 and F3.**

---

## Feature 5: Progress ownership → loss-aversion signup ask

**Kahneman, D., Knetsch, J. L., & Thaler, R. H. (1991). "Anomalies: The Endowment Effect,
Loss Aversion, and Status Quo Bias." Journal of Economic Perspectives, 5(1), 193–206.**
(See also the experimental paper: Kahneman, Knetsch & Thaler (1990), "Experimental Tests of
the Endowment Effect and the Coase Theorem," Journal of Political Economy, 98(6).)
*Finding:* people demand substantially more to give up an object than they would pay to
acquire it; the disutility of losing exceeds the utility of gaining (loss aversion). The
effect persists under market discipline. Supports F5's "save what you already own" framing.
URL: <https://www.aeaweb.org/articles?id=10.1257/jep.5.1.193>
Experimental paper PDF: <https://web.mit.edu/curhan/www/docs/Articles/15341_Readings/Behavioral_Decision_Theory/Kahneman_et_al_1990_Experimental_tests.pdf>
**Supports F5.**

**Norton, M. I., Mochon, D., & Ariely, D. (2012). "The IKEA Effect: When Labor Leads to
Love." Journal of Consumer Psychology, 22(3), 453–460.**
*Finding:* people value self-made products more highly, *but only when the labour results
in successful completion*, the effect dissipates when the task is failed or the creation
destroyed. Supports F5, and specifically corroborates the synthesis's stated dependency
that a genuine *win* must come first (Features 1–2) for the ownership framing to work.
URL (SSRN): <https://papers.ssrn.com/sol3/papers.cfm?abstract_id=1777100>
Working-paper PDF (HBS): <https://www.hbs.edu/ris/Publication%20Files/11-091.pdf>
**Supports F5 (and reinforces the win-first ordering).**

---

## Added during peer review (Domain Expert, seat 2) — 2026-07-17

These were retrieved via scholarly web search on 2026-07-17 to pressure-test Feature 2. Some
carry **verification caveats** (primary PDF not directly extractable, or a secondary source
only); they are logged with those caveats and must not be presented as fully-verified
primary citations without confirming the DOI/title.

**Bandura, A. (1977). "Self-Efficacy: Toward a Unifying Theory of Behavioral Change."
Psychological Review, 84(2), 191–215.**
*Finding:* mastery experiences (actual success) are the strongest source of self-efficacy;
early failure on a novel task erodes efficacy and persistence.
*Caveat:* primary PDF not directly verified in this pass; a secondary summary was retrieved
(<https://www.simplypsychology.org/self-efficacy.html>). Corroborating ranking study:
<https://pmc.ncbi.nlm.nih.gov/articles/PMC12502103/>
**Qualifies F2** (the failure tail of the same mechanism the win-first instinct relies on).

**Yan, V. X., et al. (2023). "Worth the Effort: the Start and Stick to Desirable Difficulties
(S2D2) Framework." Educational Psychology Review.**
*Finding:* a difficulty that helps a knowledgeable learner can be *undesirable* for a novice.
URL: <https://link.springer.com/article/10.1007/s10648-023-09766-w>
*Caveat:* verify exact author list/DOI before relying on it verbatim. **Qualifies F2.**

**Kalyuga, S. (2007). "Expertise Reversal Effect and Its Implications for Learner-Tailored
Instruction." Educational Psychologist / Instructional Science.**
*Finding:* guidance essential for novices becomes redundant/harmful for experts; low-guidance
or evaluative formats overwhelm novices.
URL: <https://www.uky.edu/~gmswan3/EDC608/Kalyuga2007_Article_ExpertiseReversalEffectAndItsI.pdf>
(summary: <https://en.wikipedia.org/wiki/Expertise_reversal_effect>)
*Caveat:* PDF binary/unextractable; citation confirmed from search metadata + summary.
**Supports F4, qualifies F2.**

**Kapur, M. (2016). "Examining Productive Failure, Productive Success, Unproductive Failure,
and Unproductive Success in Learning." Educational Psychologist, 51(2).**
*Finding:* early failure aids learning *only* with support during the struggle and canonical
instruction afterward, neither of which exists in a pre-signup onboarding moment.
URL: <https://static1.squarespace.com/static/5c5310c785ede1e27998bbb0/t/6033ebab5190b8101bcae768/1614015403798/Learning+from+Productive+Failure.pdf>
**Nuances F2/F4** (productive failure does not rescue a scored-first-task onboarding).

**Jerrim, J. (2023). "Test anxiety: is it associated with performance in high-stakes
examinations?" Oxford Review of Education.**
*Finding:* evaluation apprehension/test anxiety depresses performance; first encounters are
deliberately made low-stakes.
URL: <https://www.tandfonline.com/doi/full/10.1080/03054985.2022.2079616>
*Caveat:* verify exact title/DOI. **Qualifies F2's "scored" framing.**

**Goal orientation (mastery vs performance) — secondary sources.**
*Finding:* a mastery frame ("improve/learn") beats a performance frame ("be evaluated") for
novice persistence and intrinsic motivation.
URL: <https://education.msu.edu/research/projects/eteams/goal-orientation> ;
<https://en.wikipedia.org/wiki/Goal_orientation>
*Caveat:* secondary/encyclopedic; find a primary (Dweck / Elliot) before relying on it.
**Qualifies F2's "a system scored me" framing.**

**Knowles, M. — andragogy — secondary sources.**
*Finding:* adult learners are motivated by direct, practical, career-relevant payoff and
want relevance immediately; bridges "make it job-real" with "don't make it a high-stakes test".
URL: <https://infed.org/dir/welcome/malcolm-knowles-informal-adult-education-self-direction-and-andragogy/> ;
<https://research.com/education/the-andragogy-approach>
*Caveat:* secondary sources. **Supports F2/F4 framing (missing lens).**

**Locke, E. A., & Latham, G. P. — goal-setting theory.**
*Finding:* specific, attainable, proximal goals raise performance; supports the "one concrete
next action" and "here's what you just proved" framing.
*Caveat:* not yet cited with a specific source; add a primary reference if used in the SPEC.
**Supports F3/F4/F5 (optional add).**

**Deferred registration in apps/EdTech (practitioner).**
*Finding:* deferring signup lifts activation ~10–30%; Duolingo is the canonical EdTech
exemplar. Moves F1 off the e-commerce-only island.
URL: <https://www.appcues.com/blog/user-onboarding-ui-ux-patterns> ;
<https://weareaffective.com/learning-centre/should-my-app-require-sign-up-before-users-can-explore-features>
*Caveat:* practitioner, not RCT; strengthens direction not magnitude. **Supports F1.**

**Time-to-value / activation (practitioner).**
*Finding:* faster time-to-value correlates with activation and retention.
URL: <https://amplitude.com/blog/time-to-value-drives-user-retention> ;
<https://www.chameleon.io/blog/successful-user-onboarding>
*Caveat:* practitioner/industry, not peer-reviewed. **This is the aha→retention link the A/B
must prove on this product's own data**, not assume.

---

## Validation summary

- **Corroborated:** F1 (deferred registration → activation), F2 (competence → intrinsic
  motivation), F3 (autonomy as an SDT need), F5 (endowment/loss aversion + IKEA effect).
- **Challenged/contradicted:** none. The IKEA-effect boundary condition (labour must
  succeed) does not contradict F5; it sharpens its stated pre-condition.
- **Strength caveats:** F1's two sources are practitioner/e-commerce evidence (Baymard,
  Spool), strong on direction but not a controlled education-onboarding magnitude; the
  synthesis already frames F1 as a hypothesis to A/B test, which is the correct posture.
