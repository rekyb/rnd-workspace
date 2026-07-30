# References: external evidence base

Sources used to corroborate or challenge the *rationales* in `SYNTHESIS.md`. Nothing here is a
product observation: these sources validate the reasoning, they never replace the captured
evidence.

Two layers, gathered on **2026-07-29**:

- **R1 to R10** were retrieved during the Principal Researcher Mode B QA pass. Every URL was
  fetched during that pass.
- **R11 to R19** were retrieved by the Domain Expert during the peer-review debate. **Their
  retrieval quality is uneven and is recorded per row.** Several were verified through search
  results, publisher abstracts, or third-party reporting rather than a successful publisher
  fetch, because the publisher page returned HTTP 403 or an unparseable PDF. **A row marked
  search-verified may be used to frame or contest a rationale; it may not be used to state an
  empirical claim as settled fact.**

Note the direction column. **Corroborates** means the literature supports the stated mechanism.
**Challenges** means it does not, or supports it only under conditions the study has not shown
hold here. A challenge is not a refutation of the finding; it is a limit on how the rationale may
be stated.

## R1 to R10: publisher-fetched during the QA pass

| # | Source | Finding in one line | Bears on | Direction |
|---|---|---|---|---|
| R1 | Buell, R. W., & Norton, M. I. (2011). *The Labor Illusion: How Operational Transparency Increases Perceived Value.* Management Science 57(9), 1564–1579. <https://pubsonline.informs.org/doi/10.1287/mnsc.1110.1376> | Across five experiments, showing that a service is working raised perceived value; participants sometimes preferred a longer wait with visible effort to an instant identical result. | Feature 1 (labelled handoff), Feature 3 (intake payoff) | **Corroborates** |
| R2 | *Counting the Wait: Effects of Temporal Feedback on Downstream Task Performance and Perceived Wait-Time Experience during System-Imposed Delays.* Proceedings of CHI 2026. <https://dl.acm.org/doi/10.1145/3772318.3790475> | Temporal feedback changed the felt quality of waiting and perceived usability and trust, without changing immediate task accuracy. | Feature 1 validation plan | **Challenges the metric choice** |
| R3 | Nielsen Norman Group. *Progress Indicators Make a Slow System Less Insufferable.* <https://www.nngroup.com/articles/progress-indicators/> | Industry synthesis: users shown moving progress feedback report higher satisfaction and tolerate substantially longer waits. Practitioner source, not peer-reviewed. | Feature 1 | **Corroborates (weaker source)** |
| R4 | Kivetz, R., Urminsky, O., & Zheng, Y. (2006). *The Goal-Gradient Hypothesis Resurrected: Purchase Acceleration, Illusionary Goal Progress, and Customer Retention.* Journal of Marketing Research 43(1), 39–58. <https://journals.sagepub.com/doi/abs/10.1509/jmkr.43.1.39> | Effort rises as a person approaches a stated, countable reward threshold, in field and lab settings. | Feature 2 (the countable condition with a denominator) | **Corroborates** |
| R5 | Nunes, J. C., & Drèze, X. (2006). *The Endowed Progress Effect: How Artificial Advancement Increases Effort.* Journal of Consumer Research 32(4), 504–512. <https://academic.oup.com/jcr/article-abstract/32/4/504/1787425> | Artificial advancement toward a goal (two pre-stamped squares on a 10-stamp card) raised completion from 19% to 34% versus an 8-stamp card requiring identical effort. | Feature 2 (honesty rationale) | **Challenges** |
| R6 | Scheibehenne, B., Greifeneder, R., & Todd, P. M. (2010). *Can There Ever Be Too Many Options? A Meta-Analytic Review of Choice Overload.* Journal of Consumer Research 37(3), 409–425. <https://academic.oup.com/jcr/article-abstract/37/3/409/1827647> | Meta-analysis of 63 conditions from 50 experiments (N = 5,036): mean choice-overload effect near zero, with large between-study variance and no sufficient conditions identified. | Feature 4 (rationale for a single next step) | **Challenges** |
| R7 | Johnson, E. J., & Goldstein, D. (2003). *Do Defaults Save Lives?* Science 302(5649), 1338–1339. <https://www.science.org/doi/10.1126/science.1091721> | A well-chosen default dominates the outcome distribution even when opting out is trivially easy. | Feature 5 (default destination, refinement optional) | **Corroborates** |
| R8 | Langer, E., Blank, A., & Chanowitz, B. (1978). *The Mindlessness of Ostensibly Thoughtful Action: The Role of "Placebic" Information in Interpersonal Interaction.* Journal of Personality and Social Psychology 36(6), 635–642. <https://jamesclear.com/wp-content/uploads/2015/03/copy-machine-study-ellen-langer.pdf> | A request carrying any reason drew far more compliance than a bare request, and a *placebic* reason ("because I have to make copies") performed about as well as a real one. | Feature 6 (stating the reason at the moment of asking) | **Corroborates and qualifies** |
| R9 | Steinfeld, N. (2020). *Situational user consent for access to personal information: Does purpose make any difference?* Telematics and Informatics. <https://www.sciencedirect.com/science/article/abs/pii/S0736585319308330> | Framing the stated purpose of a data request as security, commercial, or academic produced similar consent rates; purpose was non-significant in explaining the decision. | Feature 6 (rationale) | **Challenges** |
| R10 | Nielsen, J. *10 Usability Heuristics for User Interface Design* (heuristic 5, error prevention). <https://www.nngroup.com/articles/ten-usability-heuristics/> | Preventing an error condition is preferred to reporting one after the fact. Practitioner canon, not an empirical study. | Feature 8 (the CTA that states its own requirement) | **Corroborates (weaker source)** |

## R11 to R19: added during peer review, retrieval quality recorded per row

These were retrieved by the Domain Expert panelist on 2026-07-29 and audited by the Evidence
Auditor, who did not independently re-retrieve them and required that these verification notes
travel with them. **Nothing here was cited from memory.**

| # | Source | Finding in one line | Bears on | Direction | Verification |
|---|---|---|---|---|---|
| R11 | Deci, E. L., Koestner, R., & Ryan, R. M. (1999). *A Meta-Analytic Review of Experiments Examining the Effects of Extrinsic Rewards on Intrinsic Motivation.* Psychological Bulletin 125(6), 627–668. <https://sciencedatabase.strategian.com/?p=8141> | 128 studies. Engagement-, completion-, and performance-contingent tangible rewards undermined free-choice intrinsic motivation (d = −0.40, −0.36, −0.28); positive feedback helped (d = 0.33). **Tangible rewards were more detrimental for children than for college-age participants.** | Feature 2 (moving locked gamification slots into Slice 9); §10's exclusion of points, streaks, achievements | **Challenges** | Summary page fetched and parsed. Publisher PDF downloaded but not machine-readable. **Search-verified.** |
| R12 | Hanus, M. D., & Fox, J. (2015). *Assessing the effects of gamification in the classroom: a longitudinal study on intrinsic motivation, social comparison, satisfaction, effort, and academic performance.* Computers & Education 80, 152–161. <https://www.researchgate.net/publication/265644737_Assessing_the_effects_of_gamification_in_the_classroom_A_longitudinal_study_on_intrinsic_motivation_social_comparison_satisfaction_effort_and_academic_performance> | 16-week two-course design; the gamified course used **a leaderboard and badges** and showed *less* motivation, satisfaction and empowerment over time than the non-gamified course. Closest published analogue in this set to a facilitator-run cohort. | Feature 2 (a locked leaderboard slot in a cohort setting) | **Challenges** | Citation, design and findings retrieved via search; full text paywalled, not fetched. **Search-verified.** |
| R13 | Sailer, M., Hense, J. U., Mayr, S. K., & Mandl, H. (2017). *How gamification motivates: an experimental study of the effects of specific game design elements on psychological need satisfaction.* Computers in Human Behavior 69, 371–380. <https://www.sciencedirect.com/science/article/pii/S074756321630855X> | Badges, leaderboards and performance graphs raised **competence** need satisfaction and perceived task meaningfulness; avatars and teammates raised relatedness; autonomy was not moved. "Gamification is not effective per se." | Feature 2 (separating the competence-framed counter from the social-comparison slot) | **Corroborates, with a distinction** | Citation, design and findings retrieved via search; full text not fetched. **Search-verified.** |
| R14 | Orji, R. (2016). *Persuasion and Culture: Individualism–Collectivism and Susceptibility to Influence Strategies.* CEUR-WS Vol-1582. <https://ceur-ws.org/Vol-1582/16Orji.pdf> | N = 335 (155 collectivist Asian, 180 individualist North American). Collectivists were significantly more susceptible to most influence strategies. | Feature 2 (leaderboard and social slots for a collectivist audience); the existing `PATTERNS.md` collectivist caution | **Challenges the generic slot rule** | PDF retrieved but not machine-parseable; bibliographic record and findings from search and the Semantic Scholar record. **Search-verified.** |
| R15 | OECD (2023). *PISA 2022 Results (Volumes I and II), Country Note: Indonesia.* <https://www.oecd.org/en/publications/pisa-2022-results-volume-i-and-ii-country-notes_ed6fbcc5-en/indonesia_c2e1ae0e-en.html> | **25% of Indonesian 15-year-olds reached reading Level 2 or higher** (OECD average 74%); mean reading score 359. Level 2 is where a student can identify the main idea in a text of moderate length. | Features 5, 6, 8 (every microcopy-dependent recommendation); the missing reading-level constraint | **Challenges the transferability of every text-based recommendation** | OECD page returned 403; figure taken from the country-note text surfaced in search. Mean score 359 **independently confirmed** via a second fetched source: <https://databoks.katadata.co.id/en/education/statistics/871e4e286982d42/pisa-2022-indonesian-students-reading-proficiency-ranked-low-in-asean> |
| R16 | GSMA (2024). *The State of Mobile Internet Connectivity 2024.* <https://www.prnewswire.com/in/news-releases/new-gsma-report-shows-mobile-internet-connectivity-continues-to-grow-globally-302283483.html> | Usage gap of **3.1 billion**; an entry-level internet-enabled handset costs **18% of average monthly income** in low- and middle-income countries and **51%** for the poorest quintile. The report also states **730 million** people used mobile internet on a device they do not own, including **290 million under-18s**. | `## Gaps & caveats` (conditions of use; facilitator co-present use) | **Names conditions the study never tested** | Usage-gap and handset-affordability figures **fetched and verified**. The 730M / 290M shared-device figures are **reported-not-independently-fetched** (GSMA PDF and newsroom both 403). **Those two figures may support a gaps entry only, never a finding.** |
| R17 | Sambasivan, N., Cutrell, E., Toyama, K., & Nardi, B. (2010). *Intermediated Technology Use in Developing Communities.* CHI 2010. <https://dl.acm.org/doi/10.1145/1753326.1753718> | Documents intermediated use as a prevalent mode of information access in low-income communities: a more skilled proximate person operates or co-operates the technology with the end user. | `## Gaps & caveats` (facilitator as co-present user); Feature 7 | **Reframes the finding** | Citation, venue and abstract findings retrieved via search; ACM DL page not fetched. **Search-verified.** |
| R18 | Devanuj & Joshi, A. (2013). *Technology adoption by 'emergent' users: the user-usage model.* APCHI 2013. <https://dl.acm.org/doi/10.1145/2525194.2525209> | Models adoption for "emergent" users (less educated, economically disadvantaged, culturally heterogeneous), who lack transferable mental models and cannot fall back on manuals, so interfaces raise unintended barriers. | Feature 4 (why one ranked primary matters for this audience); Feature 8 | **Corroborates the recommendation on better grounds** | Citation, venue and findings retrieved via search; ACM DL page not fetched. **Search-verified.** |
| R19 | UK Information Commissioner's Office. *Age Appropriate Design Code, Standard 13: Nudge techniques.* <https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services/13-nudge-techniques/> | Design standard for services likely accessed by under-18s: do not use nudge techniques that exploit unconscious psychological processes or human affirmation needs, or that lead children away from their own interests; nudges toward wellbeing are permitted. | Feature 2 (streak and locked-league slots for 13 to 17); Feature 6 | **Constrains, does not refute** | Page returned 403; standard text from ICO guidance surfaced in search. **Regulatory guidance, not an empirical study, and not binding in Indonesia.** Weakest evidential weight in this file: it may frame a constraint and may never evidence an empirical claim. |

### Not found, recorded rather than papered over

**No authoritative source on Indonesia's child-consent requirements** for collecting personal data
from 13-to-17-year-olds was retrieved during peer review. That is a live input to the Slice 5
decision Feature 6 speaks to. It is recorded here as a **named question for Legal/Privacy**, not
as a citation, and no claim is made about what Indonesian law requires. Every age-rationale
sighting in this study comes from a product operating under COPPA or GDPR-K, which are not the
jurisdictions we operate in.

## Where the literature does not reach

Two rationales found no directly applicable source in this pass, and that is recorded rather
than papered over with a loose citation:

- **Feature 2's "stable footprint" mechanism** (the empty slot occupies the exact footprint of
  the card that replaces it, so the second visit reads as the same page). Plausible on gestalt
  grounds, but no study specific to it was retrieved. It stays an argued design claim.
- **Feature 7's code-first versus code-after ordering trade.** This is a product-architecture
  tradeoff, not a psychological mechanism, and the synthesis already presents it as a legible
  trade rather than a research finding.

## How to read R5 and R6 against this study

Both are **challenges to how a rationale is worded**, not to the observations.

**R5 (endowed progress) versus Feature 2.** The literature says artificial advancement can raise
persistence. The study's argument against the prototype's fabricated streak is not an efficacy
argument; it is that a number a learner can falsify from memory costs the credibility of every
other number on the page. Two further distinctions matter: Nunes and Drèze's advancement was
**disclosed** (the customer could see the two stamps were a gift), and it was measured on
purchase persistence, not on trust in the interface. Feature 2 should state that boundary rather
than let a reviewer read it as an unqualified efficacy claim.

**R6 (choice overload) versus Feature 4.** A meta-analysis putting the mean effect near zero
means "more options depress action" cannot be asserted as a general law. Feature 4's specific
mechanism survives that, because it is narrower: intake already resolved the question, so
re-presenting it as a menu discards work the learner did. That is a claim about redundant
choice, not about choice quantity, and R6 does not speak against it.

**But note what R6 does not supply.** Removing the quantity claim does not install a replacement.
**Nothing in R1 to R10 evidences redundant choice specifically**, so that mechanism is an argued
design claim in the same category as Feature 2's stable-footprint mechanism above, and Feature 4
labels it as one. R18 supplies the closest population-grounded support for a single ranked
primary, and it is search-verified rather than publisher-fetched.

## How to read R11 to R14 and R19 against Feature 2

These do **not** refute the locked-slot observation, which is the study's best-replicated device.
They change what kind of decision moving it into Slice 9 is. As originally written, that
implication was priced purely on build cost (a padlock, a label, a static condition). R11 to R14
make it simultaneously a **motivational** and **cross-cultural** decision, taken for minors in a
facilitator-mediated setting, which is the configuration where the adverse evidence is strongest
and where R12 is the closest published analogue.

The synthesis therefore splits the recommendation rather than dropping it: ship the
competence-framed countable denominator, which R4 and R13 both support, and hold the locked league
or leaderboard for a separate call under the same scrutiny §10 originally applied. Because R11 to
R14 are search-verified rather than publisher-fetched, the ruling is that the question is
**contested, not settled**. The literature removes the right to treat the locked league as a pure
appetite question; it does not decide it.
