# References — external research (Learning Home Layout & Information Architecture)

External literature retrieved during the **Principal Researcher Mode B (synthesis QA)** pass on
2026-07-29, used to corroborate or challenge the *rationale* of each finding in `SYNTHESIS.md`.

**Scope.** These sources validate the reasoning behind findings drawn from captured evidence.
They never substitute for a capture, and none of them is evidence about a benchmarked product.
Every source below was actually retrieved; anything that could not be retrieved is listed under
*Sought and not verified* rather than cited loosely.

Not to be confused with `platforms/*/references.md`, which index the Mobbin reference screens.

| ID | Source | Venue / year | What it establishes | Bears on |
|---|---|---|---|---|
| R1 | Larson, K. & Czerwinski, M. *Web page design: implications of memory, structure and scent for information retrieval.* [doi:10.1145/274644.274649](https://dl.acm.org/doi/10.1145/274644.274649) · [publisher copy](https://www.microsoft.com/en-us/research/publication/web-page-design-implications-memory-structure-scent-information-retrieval/) | ACM CHI '98 | 512 items arranged three ways (8³, 16×32, 32×16). Increased depth harmed search performance, and the **medium** breadth-and-depth structure (16×32) beat the broadest-shallow one on reaction time and lostness. | **F1** — corroborates the two-step-lookup argument; **challenges** the presentation of Babbel's push-depth-down device as co-equal with the others |
| R2 | Cowan, N. *The magical number 4 in short-term memory: a reconsideration of mental storage capacity.* [PDF](https://www.cambridge.org/core/services/aop-cambridge-core/content/view/44023F1147D4A1D44BDC0AD226838496/S0140525X01003922a.pdf/the-magical-number-4-in-short-term-memory-a-reconsideration-of-mental-storage-capacity.pdf) | Behavioral and Brain Sciences 24(1), 2001 | A central working-memory capacity limit averaging roughly **four chunks**, revising Miller's seven. Not universally agreed; some hold to seven. | **F1** — supports the chunking premise, and makes cluster size (3 / 6 / 4) the relevant number rather than the raw destination count |
| R3 | Proctor, R. W. & Schneider, D. W. *Hick's law for choice reaction time: a review.* [PDF](https://web.ics.purdue.edu/~dws/pubs/ProctorSchneider_2018_QJEP.pdf) | Quarterly Journal of Experimental Psychology, 2018 | Choice reaction time rises **logarithmically** with the number of alternatives (RT = a + b·log₂(n+1)), reviewed with its boundary conditions. | **F1** — **calibrates** "cost grows with length", which is a linear-search claim; the linear regime is scanning unfamiliar labels, not choice among known alternatives |
| R4 | W3C. *Understanding SC 2.4.8: Location (Level AAA).* [w3.org](https://www.w3.org/WAI/WCAG22/Understanding/location.html) | WCAG 2.2, W3C | "Information about the user's location within a set of web pages is available." Sufficient techniques include **G128** (indicating current location within navigation bars) and **ARIA26** (`aria-current`). | **F2** — corroborates the accessibility half; the criterion is **AAA**, and the two named techniques are exactly the fix F2 proposes |
| R5 | Treisman, A. M. & Gelade, G. *A feature-integration theory of attention.* [PDF](https://www.cse.psu.edu/~rtc12/CSE597E/papers/treismanFeatIntegration.pdf) | Cognitive Psychology 12, 1980, 97–136 | Targets defined by a single unique feature are detected in parallel, with reaction time flat in set size; targets defined by a **conjunction** of features are searched serially. | **F4** — corroborates the scarcity precondition. Fill ranks only while one control owns it; a second filled control turns a feature search into a conjunction search |
| R6 | Kivetz, R., Urminsky, O. & Zheng, Y. *The goal-gradient hypothesis resurrected: purchase acceleration, illusionary goal progress, and customer retention.* [journal](https://journals.sagepub.com/doi/abs/10.1509/jmkr.43.1.39) · [author PDF](https://home.uchicago.edu/ourminsky/Goal-Gradient_Illusionary_Goal_Progress.pdf) | Journal of Marketing Research 43(1), 2006, 39–58 | Effort rises as a visible goal nears completion, and the effect tracks **perceived** progress rather than real progress. | **F5** — corroborates keeping one persistent daily signal, and supplies a sharper objection to the baseline: `0%` stated twice offers no gradient |
| R7 | Dhar, R. *Consumer preference for a no-choice option.* [journal](https://academic.oup.com/jcr/article-abstract/24/2/215/1794929) · [PDF](https://bear.warrington.ufl.edu/brenner/mar7588/Papers/dhar-jcr1997.pdf) | Journal of Consumer Research 24(2), 1997, 215–231 | Across seven studies, preference uncertainty raises **choice deferral**; deferral tracks the absolute attractiveness of the options rather than trade-off difficulty. | **F6** — corroborates "the safe answer is to defer" and the bounded-commitment mechanism. Does **not** cover the remaining-cost-versus-percentage claim |
| R8 | Material Design. *Bottom navigation.* [m1.material.io](https://m1.material.io/components/bottom-navigation.html) | Google, design-system guidance — **archived Material Design 1**, scope is native Android apps | "Three to five top-level destinations." "Avoid using more than five destinations in bottom navigation as tap targets will be situated too close to one another." | **F7, DI6** — **recalibrated at peer review (Mode C).** A normative specification, not a study, so it does not empirically confirm the four-app sample; convention and sample plausibly share one ancestry, making the corroboration **convergent rather than independent**. Scope is native Android, not Android mobile web. Duolingo's own six-tab bar is a published counter-instance. F7 keeps full hypothesis weight on the count |

## Mode C additions (introduced at peer review, 2026-07-29)

R9 onward were introduced by the Domain Expert during the peer-review debate rather than in the Mode B
QA pass, so a reader can tell the two evidence rounds apart. **Retrieval status is recorded per row and
governs how each may be used:** *full text read* may be cited inline in a finding; *abstract only* may
appear here but may **not** be the sole support for any wording change; *located, not readable* goes to
`## Sought and not verified` and may **not** be cited anywhere in `SYNTHESIS.md`.

| # | Source | Retrieval status | What it establishes | Bears on |
|---|---|---|---|---|
| R9 | W3C. *Text size in translation.* [w3.org](https://www.w3.org/International/articles/article-text-size.en.html) | **Full text read** | Citing IBM globalization guidance: source strings up to 10 characters expand **200–300%**; 11–20 characters, 180–200%; over 70 characters, ~130%. "The smaller the source message, the higher the likely translation length." | `## Gaps & caveats` (localization), **DI1** (card sort must run in Bahasa), **DI6** (the five-label budget is a pixel budget). Every one of our eleven nav labels sits in the worst band |
| R10 | Nielsen Norman Group. *Hamburger Menus and Hidden Navigation Hurt UX Metrics.* [nngroup.com](https://www.nngroup.com/articles/hamburger-menus/) | **Full text read** | n=179, 6 sites. Hidden navigation: discoverability down more than 20% against visible or combo; perceived task difficulty +21% vs visible; navigation used in 27% of desktop cases hidden vs 48% visible and 50% combo | **DI6** — establishes that Duolingo's overflow is NN/g's **combo** condition (seven destinations permanently visible plus a tail), which performs close to fully visible, and that a hamburger is a materially worse pattern. Supports DI6's disposition rule |
| R11 | Nielsen Norman Group. *Scrolling and Attention.* [nngroup.com](https://www.nngroup.com/articles/scrolling-and-attention/) | **Full text read** | 120 participants, over 130,000 eye fixations at 1920×1080: **57% of viewing time above the fold, 74% within the first two screenfuls**, with a sharp drop after the fold | **F3, DI3** — supplies the measure F3's rationale lacked. Also **calibrates** the baseline reading: our CTA at y≈1001 sits in the *second* screenful, inside the 74% band, so the accurate claim is that three company-owned blocks occupy the highest-attention region, not that the action is unreachable |
| R12 | Padhi et al. *Hierarchy or List? Comparing Menu Navigation by Emergent Users.* IndiaHCI 2018. [doi:10.1145/3297121.3297125](https://dl.acm.org/doi/10.1145/3297121.3297125) | **Abstract / indexed only** — ACM returned 403 on direct fetch | 24 **emergent users**, 6 tasks, a 5-level hierarchy against a 5-page flat list. In the GUI condition the flat list was navigated faster than the hierarchy | **F1, DI1** — the closest source in the set to our audience. Reinforces DI1's static-labels constraint: for emergent users any added navigation step is a cost, not only deep ones. **Not sole support for any claim** |
| R13 | Medhi Thies et al. *Designing Mobile Interfaces for Novice and Low-Literacy Users.* ACM TOCHI 18(1), 2011. [Microsoft Research](https://www.microsoft.com/en-us/research/publication/designing-mobile-interfaces-for-novice-and-low-literacy-users/) | **Abstract read in full** | Ethnographic study of 90 low-literacy subjects across four countries plus two controlled studies with 70+ subjects: "textual interfaces are unusable by first-time low-literacy users, and error prone for literate but novice users" | **F7** — supports **redundant coding** (icon *and* label together), which is what 3 of 4 phone platforms do and what neither Duolingo's icon-only bar nor a text-only row provides. Does **not** discuss hierarchy versus flat lists. **Not sole support** |
| R15 | Nunes & Drèze. *The Endowed Progress Effect.* JCR 32(4), 2006. [academic.oup.com](https://academic.oup.com/jcr/article-abstract/32/4/504/1787425) | **Abstract / indexed only** | Artificial advancement raises persistence: 34% redemption with two pre-granted stamps against 19% from zero | **F5, DI5** — bears on a `0%` readiness figure offering no gradient. **Constraint:** `research/PATTERNS.md`'s mastery-honesty rule forbids inflating a *proficiency* estimate, so any endowment belongs on a **behavioural** counter, never on readiness. **Not sole support** |
| R17 | Vreugd et al. *Students' Use of a Learning Analytics Dashboard and Influence of Reference Frames.* JCAL 2025. [doi:10.1111/jcal.70015](https://onlinelibrary.wiley.com/doi/10.1111/jcal.70015) | **Abstract / indexed only** | Reference frames orient interpretation of a learning dashboard; social-comparison frames are reported as stressful for low-performing students | **F5, DI5** — indexes the reference-frame construct. The construct itself is recorded as an **open question**, not cited in the findings, pending R16. **Not sole support** |
| R19 | GSMA Intelligence. *The State of Mobile Internet Connectivity 2025: Affordability.* [gsmaintelligence.com](https://www.gsmaintelligence.com/research/the-state-of-mobile-internet-connectivity-2025-affordability-of-internet-enabled-handsets-and-data) | **Abstract / indexed only** | An entry-level internet-enabled handset costs ~16% of average monthly income across low- and middle-income countries, rising to 48% for the poorest 20% | `## Gaps & caveats` (conditions of use). Prices the device constraint the benchmark set does not share. **Not sole support** |

## Sought and not verified

### Added at peer review (Mode C, 2026-07-29)

- **R14 — Medhi, Sagar & Toyama. *Text-Free User Interfaces for Illiterate and Semiliterate Users.*
  ITID 4(1), 2007.** [dl.acm.org](https://dl.acm.org/doi/10.1162/itid.2007.4.1.37) ·
  [MIT OCW PDF](https://ocw.mit.edu/courses/mas-965-nextlab-i-designing-mobile-technologies-for-the-next-billion-users-fall-2008/8ccecb3eacd514b7ea0255f5158de907_MITMAS_965F08_medhi2007.pdf).
  **Located, not fetched.** Would corroborate F7's redundant-coding reading (semi-abstract graphics
  plus voice; glyphs alone insufficient). **Not cited anywhere in `SYNTHESIS.md`.**
- **R16 — Jivet, Scheffel, Drachsler & Specht. *Awareness Is Not Enough: Pitfalls of Learning
  Analytics Dashboards in the Educational Practice.* EC-TEL 2017.**
  [doi:10.1007/978-3-319-66610-5_7](https://doi.org/10.1007/978-3-319-66610-5_7) ·
  [OU preprint](https://research.ou.nl/ws/portalfiles/portal/10647100/115_ECTEL_preprint.pdf).
  **Located, not readable** — the preprint downloaded as a PDF the review environment could not
  render, and the publisher page redirects to an auth gate. **This is the load-bearing source for the
  reference-frame challenge to F5 and DI5**: that a progress display's operative variable is the frame
  it compares the learner to (social / progress / achievement) rather than the region it occupies, and
  that our four skill bars at `0%` constitute an achievement frame with no gradient. The claim drives a
  design change, so it is recorded as an **open question in DI5** and is **not cited**. Retrieve
  manually, then it may qualify F5 and DI5.
- **R18 — Hornof & Halverson. *Cognitive strategies and eye movements for searching hierarchical
  computer displays.* CHI 2003.** [doi:10.1145/642611.642656](https://dl.acm.org/doi/abs/10.1145/642611.642656).
  **Unverified** — the specific claim (labelled visual hierarchies are searched with a two-tiered
  rather than a noisy-systematic strategy) may belong to a companion paper rather than this one, and
  the full text was not retrieved. **This is the correct visual-search mechanism for F1**, in place of
  R2 (Cowan), which governs memory load rather than scanning a persistently visible list. Retrieving it
  is the single highest-value action left: it would let F1's two-step-lookup argument rest on the right
  law. **Not cited.**
- **A source for the hamburger-versus-combo discoverability figure as applied to DI6.** R10 is fully
  retrieved and does support the general finding, but the specific inference — that our overflow should
  be combo rather than hamburger — is an application of it to a case NN/g did not test. Recorded so the
  inference is visible as an inference.

### From the Mode B QA pass

- **Apple Human Interface Guidelines, *Tab bars*.** Widely reported to give three to five tabs on
  iPhone. The page at `developer.apple.com/design/human-interface-guidelines/tab-bars` resolves,
  but its body is client-rendered and could not be retrieved, so the guidance is **not cited**.
  Retrieve it manually before F7 leans on a second platform source.
- **A source for F5's frequency-separation mechanism** (a signal needed every session versus one
  needed occasionally, and the cost of sizing the frequent one for the infrequent question). R6
  supports the motivational half only. No study was found testing the layout claim itself, so it
  stands on the six captures alone.
- **A source for F8's *sought* versus *must-be-seen* distinction** and for F9's "one meaningful
  object per phone screenful". Both are structural readings of the iOS captures and are already
  labelled hypotheses; neither is backed by retrieved literature.

## How to read the citations in `SYNTHESIS.md`

A rationale backed by one of these carries an inline `[ref: R# — see references.md]` inside a
`> [Principal Researcher]` callout. The callout states whether the literature **corroborates**,
**calibrates**, or **challenges** the claim. No finding was edited to match a source; where a
source qualifies a finding, that is flagged for the researcher to resolve.
