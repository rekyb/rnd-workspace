# PRD: Solve Education! Learner Acquisition & Onboarding

**Date:** 2026-07-23  
**Status:** Draft — pending stakeholder approval  
**Prototype:** `design/onboarding-solve-edu/prototype-web.html`  
**Research:** `research/2026-07-20-unified-onboarding-synthesis-and-patterns/SYNTHESIS.md`  
**Reviewed specification:** `research/2026-07-20-unified-onboarding-synthesis-and-patterns/SPEC-5.md`  
**Audience:** Product, Design, Engineering, Data, Content, Program Operations, Legal/Privacy

---

## 1. TL;DR

Solve Education! needs one production-ready acquisition and onboarding funnel that serves two learner contexts without forcing either through irrelevant steps:

- **Organic learners** discover Solve Education!, provide lightweight profile information, select a learning goal, create an account, and arrive at a personalized Learning Home.
- **Program learners** enter a facilitator-issued code, confirm the resolved program, provide lightweight profile information, create an account, become enrolled in that program, and arrive at Learning Home with assigned tasks.

Both paths defer account creation until the learner has supplied enough context for the account to feel worth saving. Returning learners can log in from the landing page or account wall. The production implementation replaces prototype shortcuts with persistent onboarding sessions, real authentication, server-side program validation, atomic profile/enrollment creation, localization, accessible interactions, privacy controls, analytics, and recoverable error handling.

This PRD covers the public landing page through the first authenticated Learning Home view. It does not cover lesson delivery, complete dashboard functionality, program administration, or assessment design.

---

## 2. Problem & Evidence

The current learner entry experience must support people arriving with very different levels of context. An organic learner needs help deciding what to learn. A program learner already has a destination and should not have to browse or choose a goal. A returning learner should not repeat onboarding. If these contexts share one undifferentiated path, learners encounter unnecessary decisions, program attribution can be lost, and Solve Education! cannot reliably connect acquisition intent to the resulting account.

The reviewed research supports five product principles used in this PRD:

| Claim | Source | Confidence | Product implication |
|---|---|---:|---|
| Deferring registration until after useful intake can reduce early friction and make account creation feel like saving progress | Unified onboarding synthesis, Theme 1 | High, directional | Keep the account wall after path-specific intake |
| Program or class codes should route learners directly to assigned content instead of a catalogue | Unified onboarding synthesis, Theme 5; Khan Academy benchmark | High | Validate the code first and preserve program context throughout onboarding |
| Low-text, icon-led progressive intake reduces cognitive burden | Unified onboarding synthesis, Theme 3 | High | Ask one question per screen and use recognition-based choices |
| Localized interface chrome is necessary for learners who may not be fluent in English | Unified onboarding synthesis, Theme 4 | High | English and Bahasa Indonesia must cover the complete funnel, including errors |
| A verified identity is eventually required to protect durable learning records and credentials | Unified onboarding peer review | High | Authentication must complete before temporary onboarding data becomes a durable learner record |

The prototype validates the intended flow shape and interaction model, but it does not validate conversion performance, legal age policy, provider reliability, backend contracts, or production failure handling. All numeric success targets below are launch hypotheses to be reviewed after four weeks of stable production data.

---

## 3. Primary Job to be Done

When I decide to start learning with Solve Education!, I want the product to understand whether I am exploring independently or joining a specific program, guide me through only the information needed for that path, and preserve it when I create my account, so I can reach the right first learning action without getting lost or repeating myself.

---

## 4. Related Jobs

- When I receive a program code from a facilitator, I want to confirm that it belongs to the expected program before registering, so I know I am joining the right cohort.
- When I do not have a program code, I want to choose what I want to improve, so my first recommendation is relevant.
- When I return to Solve Education!, I want to log in using my existing account and continue without repeating onboarding.
- When a connection, authentication provider, or program code fails, I want to retry without losing information I already entered.
- When I prefer Bahasa Indonesia, I want every instruction, validation message, and recovery path in the funnel to use that language consistently.

---

## 5. Desired Outcomes / Success Metrics

### 5.1 North-star funnel

**Onboarding activation rate:** percentage of unique new-learner sessions that begin onboarding and reach an authenticated Learning Home with a persisted profile and, where applicable, a confirmed program enrollment.

### 5.2 Launch targets

| # | Outcome | Initial target | Measurement |
|---|---|---:|---|
| 5.1 | Landing visitors who start organic or program onboarding | ≥ 20% | `onboarding_started / landing_viewed` |
| 5.2 | Started onboarding sessions that create or link an account successfully | ≥ 70% | `account_linked / onboarding_started` |
| 5.3 | Median time from onboarding start to authenticated Learning Home | < 4 minutes | p50 between `onboarding_started` and `learning_home_viewed` |
| 5.4 | Valid program-code sessions that finish enrollment | ≥ 80% | `program_enrollment_completed / program_code_validated` |
| 5.5 | Authenticated organic learners who start their first lesson in the same session | ≥ 50% | `lesson_started / learning_home_viewed`, organic only |
| 5.6 | Authenticated program learners who open an assigned task in the same session | ≥ 60% | `assigned_task_opened / learning_home_viewed`, program only |
| 5.7 | Onboarding completion parity between English and Bahasa Indonesia | absolute gap < 8 percentage points | Compare metric 5.2 by locale |

### 5.3 Guardrails

| Guardrail | Threshold | Response |
|---|---:|---|
| Program validation API technical-error rate | < 2% of submissions | Investigate immediately above threshold for 30 minutes |
| Authentication technical-error rate | < 3% of attempts per provider | Disable an unhealthy provider through configuration and preserve alternate methods |
| Duplicate program enrollment caused by retries | 0 | Treat as data-integrity incident |
| Duplicate learner accounts attributable to this flow | < 0.5% of created accounts | Review identity matching and account-linking rules |
| Onboarding sessions logging raw name, email, code, or password values to analytics | 0 | Treat as privacy incident |
| Critical WCAG 2.2 A/AA blockers in the funnel | 0 at launch | Block release |

Targets are hypotheses, not claims of existing performance. Product and Data must reset targets after four weeks of representative traffic and document the new baseline.

---

## 6. Appetite

**Appetite: 10–12 atomic implementation iterations across frontend, backend, and analytics, followed by a stabilization pass.**

Suggested allocation:

- 2 iterations: landing, localization shell, and entry routing
- 2 iterations: authentication and temporary onboarding session
- 2 iterations: program-code validation and enrollment
- 3 iterations: progressive profile intake and goal selection
- 2 iterations: profile finalization, Learning Home handoff, and analytics
- 1 iteration: accessibility, responsive, and failure-state hardening

**Recut threshold:** If the work exceeds 12 iterations before end-to-end integration, defer the marketing sections below the impact banner and launch with the existing landing content, but do not cut program validation, state recovery, accessible form semantics, localization, consent capture, or analytics.

**Kill threshold:** If production authentication and atomic profile/enrollment finalization cannot be made reliable within 15 iterations, do not ship a simulated or partially durable funnel. Release only behind an internal feature flag until the identity and data-integrity risks are resolved.

---

## 7. Solution Shape

### 7.1 End-to-end flow

```text
                              ┌──────────────┐
                              │ Returning    │
                              │ learner login│
                              └──────┬───────┘
                                     │
[Public landing] ────────────────────┼────────────────────────┐
       │                             │                        │
       ├─ Get started ───────────────┘                        │
       │                                                      │
       │   Organic path                                      │
       │   Name → Country → Age → Goal                        │
       │                  │                                   │
       │                  └──────────────┐                    │
       │                                 ▼                    │
       │                         [Account wall]               │
       │                                 │                    │
       │                         Create/link identity         │
       │                                 │                    │
       │                                 ▼                    │
       │                         [Learning Home]              │
       │                                                      │
       └─ Program code → Validate → Program preview           │
                                      │                       │
                                      ▼                       │
                          Name → Country → Age                 │
                                      │                       │
                                      └──→ [Account wall] ────┘
                                               │
                                  Finalize enrollment atomically
                                               │
                                               ▼
                                  [Program-aware Learning Home]
```

### 7.2 Shared temporary onboarding session

Starting either new-learner path creates an opaque onboarding session. The session stores only the minimum state required to recover the funnel:

- entry path (`organic` or `program`)
- interface locale
- current step and completed-step markers
- selected country code
- selected age band
- selected organic goal, if applicable
- validated program reference and validation timestamp, if applicable
- display name
- acquisition attribution allowed by consent and policy
- consent version references

The browser stores only an opaque session identifier in a secure, same-site cookie. Passwords and authentication tokens never enter the onboarding-session payload. The server expires incomplete onboarding sessions after 24 hours. Expired sessions restart safely at entry and do not create learner or enrollment records.

### 7.3 Authentication and finalization

The account wall supports:

- email and password account creation
- Google identity
- Facebook identity when enabled
- existing-account login from the account wall

The production password policy is at least 8 characters and must be enforced server-side. The UI may give immediate guidance but may not be the source of truth.

After successful identity creation or login, the backend performs one idempotent finalization operation:

1. Resolve or create the learner identity.
2. Attach the temporary profile to that identity.
3. If the entry path is program, verify that the validated program reference is still eligible and create the enrollment.
4. Record the applicable consent versions and timestamps.
5. Mark the onboarding session consumed.
6. Return the destination and first-action payload for Learning Home.

If any required operation fails, the transaction rolls back. The learner remains on a recoverable account-wall state and does not see a false success.

### 7.4 Learning Home boundary

Learning Home is included only as the verified handoff:

- personalized greeting using the learner's display name
- a recommended first course for organic learners based on the chosen goal
- confirmed program identity and assigned task summary for program learners
- a primary action that emits `lesson_started` or `assigned_task_opened`

The complete Courses, Achievements, Settings, recommendation engine, points system, and task-completion system are outside this PRD.

---

## 8. Vertical Slices

### Slice 1 — Public landing and entry selection

The public page communicates the value proposition, impact, behavioural-science approach, credibility, and free access. “Get started” is the dominant action. “I have a program code” and “Login” remain clearly available without competing visually with the primary CTA. English and Bahasa Indonesia can be selected before onboarding begins.

### Slice 2 — Returning-learner login

A returning learner opens Login from the header or account wall, authenticates using email/password or an enabled identity provider, and lands on the correct authenticated destination. The login preserves any active onboarding session so an existing user can link collected data instead of repeating it.

### Slice 3 — Program-code validation and preview

A program learner enters a six-character, case-insensitive code. The client normalizes whitespace and casing, then submits it to the server. A valid response presents program name, organization, and facilitator only when supplied by the API. Invalid, expired, exhausted, not-yet-active, and technical failures have distinct recoverable states.

### Slice 4 — Name and country profile intake

Both new-learner paths collect display name and country one question per screen. The country control is a searchable, localized ARIA combobox. Back navigation preserves valid entries. Program context remains visible through contextual copy, without introducing extra fields.

### Slice 5 — Age segmentation and eligibility handling

The learner selects a recognition-based age range: 13–17, 18–24, or 25–64, with the adult branch refined to 25–34, 35–44, 45–54, or 55+. The selected band supports segmentation and policy evaluation. Country-specific minimum-age or consent rules are returned from policy configuration; the UI does not hard-code a universal eligibility threshold.

If policy blocks self-service registration, the product shows a localized explanation and safe next action approved by Legal/Privacy. It does not silently discard previously entered data, promise parental consent where none exists, or expose internal policy logic.

This order intentionally follows the approved prototype (Name → Country → Age). Because that means limited profile data is collected before eligibility is known, Legal/Privacy must approve the temporary-session handling before launch. If they require eligibility before personal-data collection, Age moves before Name for both entry paths without changing the remaining requirements.

### Slice 6 — Organic learning-goal selection

Organic learners choose exactly one configured goal:

- Data and analysis
- Customer service
- Project management
- Digital marketing
- Communication
- Language skills

The options are configuration-backed and localized. A selection enables Continue and becomes the initial recommendation signal. Program learners skip this slice because their validated assignment already supplies routing context.

### Slice 7 — Account creation and social sign-up

After path-specific intake, the learner sees why an account is needed: to save the personalized profile or finalize program registration. Email/password and enabled providers converge on one finalization contract. Terms and Privacy links are visible, versioned consent is recorded, loading prevents duplicate submission, and provider cancellation returns to the intact account wall.

### Slice 8 — Profile persistence and program enrollment

The backend consumes the temporary session idempotently. Organic learners receive a durable profile with goal attribution. Program learners receive a durable profile and program enrollment. Repeated callbacks, refreshes, or retries return the already-created result rather than creating duplicates.

### Slice 9 — Personalized Learning Home handoff

Successful finalization routes the learner to an authenticated Learning Home. Organic learners receive a goal-aligned first recommendation. Program learners see program tasks and program name. A direct authenticated visit skips onboarding unless the account is missing a required policy field, in which case only the missing field is requested.

### Slice 10 — Cross-cutting localization, accessibility, analytics, and responsive behavior

Every slice supports English and Bahasa Indonesia, keyboard and assistive-technology operation, reduced motion, mobile and desktop layouts, semantic error/status announcements, and consistent analytics. These are acceptance requirements for each slice, not a post-build polish phase.

---

## 9. Acceptance Criteria per Slice

### Slice 1 — Public landing and entry selection

- [ ] “Get started” begins an organic onboarding session and routes to Name.
- [ ] “I have a program code” opens a modal with focus trapped inside it and the background made inert.
- [ ] Login opens a dialog with a programmatic name and returns focus to its trigger when closed.
- [ ] The bottom “Get started” CTA invokes the same organic entry behavior as the hero CTA.
- [ ] Changing locale updates all visible landing and modal copy without reloading the page.
- [ ] The impact video renders inline over HTTP/HTTPS and shows a usable external-video fallback when no valid web referrer is available.
- [ ] External links use safe new-tab behavior and are keyboard reachable.
- [ ] `landing_viewed`, `entry_action_selected`, and `locale_changed` events fire once per qualifying action.

### Slice 2 — Returning-learner login

- [ ] Email/password submission stays disabled until the email shape and minimum password guidance are satisfied.
- [ ] The server validates credentials and returns a generic invalid-credentials response that does not reveal whether an email exists.
- [ ] Enabled social providers use supported OAuth/OIDC flows with state and nonce protection.
- [ ] Provider cancellation and technical failure return the learner to Login with a localized recovery message.
- [ ] Rate limiting and abuse protection apply to credential and provider-callback endpoints.
- [ ] Successful login with no active onboarding session routes directly to Learning Home.
- [ ] Successful login with an active onboarding session asks for confirmation before merging new intake into an existing profile when that merge would overwrite durable data.
- [ ] Authentication events identify method, result category, entry surface, and anonymous session ID without logging credentials or provider tokens.

### Slice 3 — Program-code validation and preview

- [ ] The code accepts six alphanumeric characters, supports paste, auto-advances on character entry, and moves backward on Backspace.
- [ ] Join remains disabled until six normalized characters are present.
- [ ] Submission displays a loading state, announces it to assistive technology, and prevents duplicate requests.
- [ ] A valid response stores an opaque program reference in the server-side onboarding session.
- [ ] Program preview shows program name and organization; facilitator appears only if present in the API response.
- [ ] Invalid, expired, exhausted, inactive, and technical errors use distinct localized messages and preserve the entered code for correction or retry.
- [ ] Closing code entry before successful validation returns to Landing without attaching a program.
- [ ] A program code is revalidated during finalization so a stale or revoked code cannot create an enrollment.
- [ ] Validation attempts are rate-limited without preventing legitimate retry and never include the raw code in analytics.

### Slice 4 — Name and country profile intake

- [ ] Name accepts 3–50 Unicode grapheme clusters after trimming leading/trailing whitespace.
- [ ] Letters, numbers, spaces, diacritics, apostrophes, periods, hyphens, and slashes are supported; production validation does not reject names merely for being non-ASCII.
- [ ] Invalid name input produces a localized inline message connected to the input with `aria-describedby`.
- [ ] The country field follows the ARIA combobox pattern with an actual listbox, active descendant, keyboard navigation, selection, Escape behavior, and announced empty state.
- [ ] Country search matches localized display names and supported alternate names without case sensitivity.
- [ ] Arbitrary text that does not resolve to a country code cannot enable Continue.
- [ ] Returning to Name or Country restores the prior valid value.
- [ ] The server stores ISO 3166-1 alpha-2 country code as the canonical value, not the localized label or flag URL.

### Slice 5 — Age segmentation and eligibility handling

- [ ] Selecting 13–17 or 18–24 immediately creates one valid single-choice result.
- [ ] Selecting Adult reveals 25–34, 35–44, 45–54, and 55+; Continue stays disabled until a subrange is selected.
- [ ] Changing from Adult to another primary range clears the adult subrange.
- [ ] The server evaluates the selected band, country, and current policy version before profile finalization.
- [ ] A blocked result shows localized, legally approved copy and an explicit safe exit or approved consent route.
- [ ] Analytics stores only the configured age-band key and policy result, never an inferred date of birth.
- [ ] Policy configuration is versioned so consent and eligibility decisions can be audited.

### Slice 6 — Organic learning-goal selection

- [ ] Six localized goal cards render from configuration in the approved order.
- [ ] Goal selection is single-choice and exposes its state programmatically with `aria-pressed` or radio semantics.
- [ ] Continue remains disabled until a goal is selected.
- [ ] Back navigation preserves the current goal.
- [ ] Program learners never receive the organic goal screen.
- [ ] The stored value is a stable goal identifier; localized display copy is not used as the database key.
- [ ] `goal_selected` includes the stable goal identifier and locale but no profile PII.

### Slice 7 — Account creation and social sign-up

- [ ] Account-wall copy adapts to the entry path and uses the learner's escaped display name.
- [ ] Email is normalized server-side and checked against existing identities without leaking account existence to unauthenticated attackers.
- [ ] Password creation requires at least 8 characters, supports password managers and paste, and is stored only as an approved password hash.
- [ ] Terms of Service and Privacy Policy links are visible before submission.
- [ ] The backend records terms version, privacy version, consent timestamp, and consent surface.
- [ ] Social provider actions are independently configurable; a disabled or unhealthy provider is not shown.
- [ ] Existing-email detection offers Login or approved account linking while preserving onboarding state.
- [ ] Duplicate submission is prevented in the UI and made safe through an idempotency key on the backend.
- [ ] Email verification may occur after first access and does not block Learning Home unless Security config explicitly requires it.

### Slice 8 — Profile persistence and program enrollment

- [ ] Finalization requires an authenticated identity and a valid, unconsumed onboarding session.
- [ ] Finalization is atomic across learner profile, consent record, goal attribution or enrollment, and session consumption.
- [ ] Repeating finalization with the same idempotency key returns the same learner and enrollment identifiers.
- [ ] Program enrollment uniqueness is enforced at the database level for learner, program, and cohort scope.
- [ ] A revoked or newly ineligible program response returns the learner to a recoverable program state without creating a partial profile.
- [ ] Security logs contain correlation identifiers and result categories but exclude name, email, password, raw program code, and OAuth tokens.
- [ ] Temporary onboarding data is deleted or irreversibly anonymized after successful finalization according to retention policy.

### Slice 9 — Personalized Learning Home handoff

- [ ] The first authenticated page shows the learner's display name from the durable profile.
- [ ] Organic learners receive a first-course recommendation tied to the stable goal identifier.
- [ ] Program learners see the confirmed program name and assigned task summary.
- [ ] Program tasks are fetched from the enrollment, not hard-coded client data.
- [ ] “Start Lesson” or its program-task equivalent routes to a valid destination and emits the appropriate first-action event.
- [ ] Refreshing Learning Home does not replay onboarding finalization.
- [ ] Missing downstream content shows a neutral empty state and recovery action rather than fabricated progress.

### Slice 10 — Cross-cutting requirements

- [ ] All user-facing strings, including validation, status, legal, and provider errors, are available in English and Bahasa Indonesia.
- [ ] Changing locale mid-onboarding preserves the current step and entered values.
- [ ] Progress reflects the actual configured step count for the current entry path and exposes equivalent text such as “Step 3 of 5.”
- [ ] Browser Back and the in-product Back action do not create contradictory history or accidental duplicate submissions.
- [ ] At 320px width, no primary task requires horizontal scrolling; layouts remain usable at 375px, 768px, and 1440px.
- [ ] Focus order follows visual order, focus is visible, and modals restore focus on close.
- [ ] Status and error feedback does not rely on color or animation alone.
- [ ] Reduced-motion preference disables nonessential shake, pulse, slide, and spring motion.
- [ ] Text and essential UI components meet WCAG 2.2 AA contrast requirements.
- [ ] Analytics events use a documented schema, are deduplicated, and include consent-appropriate attribution.
- [ ] The funnel remains recoverable after refresh, transient API failure, OAuth redirect, and network reconnection within the 24-hour session lifetime.

---

## 10. Non-Goals

- Full Learning Home/dashboard implementation beyond the first authenticated handoff
- Lesson player, course catalogue, assessments, certificates, points, streaks, or achievements
- Program creation, cohort administration, facilitator tools, or reporting
- Recommendation-model development; MVP uses deterministic goal-to-course configuration
- Multiple simultaneous organic goals
- Program discovery or browsing without a valid code
- Editing or switching a validated program during onboarding
- Cross-device continuation of an incomplete anonymous onboarding session
- Apple, Telegram, WhatsApp, or SMS authentication in this release
- Password reset implementation; the Login surface may link to an existing recovery system
- Profile editing, account deletion, or consent withdrawal interfaces
- Parental-consent workflow unless Legal/Privacy supplies an approved policy and operational process
- Baseline assessment before account creation; reviewed research recommends it, but the current approved prototype scope does not define assessment content, scoring, or accessible equivalence
- Translation beyond English and Bahasa Indonesia
- A CMS for landing-page content

---

## 11. Rabbit Holes & Open Questions

### Rabbit Holes

- **Do not port prototype JavaScript directly into production.** Preserve behavior and design intent while using the production application's routing, state, validation, and component conventions.
- **Do not make the browser the authority for eligibility, program validity, consent, authentication, or enrollment.** Client checks improve feedback; the server decides.
- **Do not create a learner record before authentication succeeds.** Anonymous state belongs to the temporary onboarding session.
- **Do not attach a program solely because it was valid earlier.** Revalidate it during finalization.
- **Do not log raw program codes or profile PII in analytics.** Use opaque references and controlled dimensions.
- **Do not introduce a general recommendation engine.** A configuration map is sufficient for the approved MVP.
- **Do not add fields merely because they may be useful later.** Name, country, age band, goal or program, identity, and consent are the approved minimum.
- **Do not treat social providers as guaranteed.** Each provider needs health monitoring, configuration, and an alternate path.

### Open Questions requiring named decisions

| Decision | Owner | Decision deadline | Default if unresolved |
|---|---|---|---|
| Country-specific age/consent policy and whether any range must be blocked | Legal/Privacy + Product | Before Slice 5 development starts | Do not launch in a market without an approved rule |
| Production identity-provider set and account-linking policy | Security + Engineering | Before Slice 2 integration | Email/password + Google only |
| Program code character set and cohort-capacity rules | Program Operations + Backend | Before Slice 3 API freeze | Six case-insensitive alphanumeric characters; no client-visible capacity detail |
| Canonical goal taxonomy and goal-to-first-course map | Content + Product | Before Slice 6 content freeze | Use the six prototype identifiers and manually approved mappings |
| Email-verification gating policy | Security + Product | Before Slice 7 release review | Send verification after registration; do not block first Learning Home |
| Exact Terms and Privacy versions and localized consent copy | Legal/Privacy | Before Slice 7 QA | Block production release |
| Existing-account merge behavior when intake conflicts with durable profile | Product + Backend | Before Slice 2/8 integration | Ask for confirmation; preserve existing durable data by default |
| Temporary-session data retention and deletion schedule | Privacy + Backend | Before Slice 8 implementation | Expire incomplete sessions after 24 hours and delete consumed sessions promptly |

---

## 12. Technical Constraints

### 12.1 Frontend and design

- The prototype is behavioral and visual reference, not production architecture.
- Preserve the current brand tokens, `Plus Jakarta Sans` headings, `Open Sans` body copy, responsive card layouts, and single-dominant-action pattern.
- Production must use semantic HTML first and ARIA only where native semantics are insufficient.
- Country flags are supplementary; country selection must remain understandable and operable if flag assets fail.
- Third-party video and external marketing assets must not block onboarding actions or core rendering.
- The web app must support the latest two major versions of Chrome, Edge, Firefox, and Safari, including mobile Safari and Chrome for Android.

### 12.2 API contracts

Minimum endpoints or equivalent application services:

| Capability | Contract requirement |
|---|---|
| Start onboarding | Return opaque session and expiry |
| Update onboarding | Accept versioned partial state and reject stale writes safely |
| Validate program code | Return opaque program reference, safe preview metadata, status category, and validation expiry |
| Evaluate eligibility | Return versioned policy result from country and age band |
| Create account / authenticate | Return verified identity or actionable result category |
| Finalize onboarding | Idempotently attach profile, consent, goal/enrollment, consume session, and return destination |
| Fetch Learning Home handoff | Return personalized greeting data, first action, and program summary when applicable |

All write endpoints require server-side validation, structured error codes, correlation IDs, rate limiting appropriate to abuse risk, and idempotency where retry could duplicate state.

### 12.3 Security and privacy

- Session cookies must be `Secure`, `HttpOnly`, and `SameSite=Lax` or stricter where compatible with provider callbacks.
- OAuth/OIDC uses authorization code flow with PKCE where supported, plus state and nonce validation.
- Passwords must never be logged or placed in analytics and must be hashed using the platform's approved adaptive algorithm.
- PII access follows least privilege. Program Operations may view only what its operational role requires.
- Consent records are append-only and retain the document version shown at action time.
- Data retention, deletion, incident response, and data-subject rights use the organization's approved privacy policy and operating procedures.

### 12.4 Reliability and observability

- Program validation and onboarding finalization define availability objectives before launch.
- Each request carries a correlation ID across frontend, API, identity, and enrollment services.
- Dashboards break down funnel and error metrics by entry path, locale, device class, provider, and safe result category.
- Alerts must distinguish user-correctable errors from system failures.
- Feature flags independently control the new funnel, each identity provider, and Learning Home personalization.

### 12.5 Analytics event schema

Required events:

`landing_viewed`, `entry_action_selected`, `onboarding_started`, `program_code_submitted`, `program_code_result`, `program_preview_viewed`, `onboarding_step_viewed`, `onboarding_step_completed`, `goal_selected`, `account_wall_viewed`, `auth_attempted`, `auth_result`, `onboarding_finalization_result`, `learning_home_viewed`, `lesson_started`, `assigned_task_opened`, `locale_changed`.

Common safe properties:

- anonymous onboarding session ID
- authenticated learner ID only after authentication
- entry path
- locale
- step identifier
- device class
- identity provider
- stable goal identifier
- opaque program reference
- controlled result category
- campaign attribution where consent and policy permit

Prohibited analytics properties include display name, email, password, raw program code, OAuth token, facilitator name, and free-form error text.

---

## 13. Dependencies

- **Identity platform:** email/password, Google, optional Facebook, provider health controls, recovery integration, and account linking
- **Program service:** code validation, program/cohort metadata, status and capacity rules, and idempotent enrollment
- **Learner profile service:** durable profile schema and partial-profile update rules
- **Content service:** goal taxonomy, localized labels, deterministic first-course mapping, and program task payload
- **Localization:** approved English and Bahasa Indonesia strings, country names, validation messages, legal copy, and translation QA
- **Legal/Privacy:** age policy, consent language and versions, temporary-session retention, analytics consent rules, and blocked-state copy
- **Data/Analytics:** event taxonomy, funnel dashboard, data-quality checks, deduplication, and four-week target review
- **Design/Accessibility:** responsive specifications, focus states, reduced-motion behavior, contrast validation, and assistive-technology QA
- **Program Operations:** code rules, preview metadata quality, facilitator-data policy, revoked/expired behavior, and support playbook
- **Platform/DevOps:** secure environments, secrets, rate limiting, feature flags, monitoring, alerts, and rollback

---

## Appendix A: Prototype Element Dictionary

### A.1 Landing page

| Element | Production purpose | Requirement |
|---|---|---|
| Solve Education! logo | Brand confirmation and return-to-entry action | Accessible name; returning to Landing must not silently discard active data |
| Language selector | Choose interface language before conversion | Full-flow localization; persisted preference |
| Login | Returning-learner entry | Opens accessible authentication dialog |
| Get started | Primary organic entry | Starts organic onboarding |
| Program-code action | Deterministic cohort entry | Opens focused code modal |
| Impact metrics | Trust and social proof | Content owner and review date required; not hard-coded indefinitely |
| Embedded video | Explain mission and impact | Must have a fallback and may not block page usability |
| GAIN cards | Explain behavioural-science approach | Localized, responsive, readable without icons |
| Expert testimonial | Credibility signal | Source approval and content ownership required |
| Footer links | Legal, organizational, and support access | Correct destinations, safe external links, localized labels |

### A.2 Program-code modal

| Element | Production purpose | Requirement |
|---|---|---|
| Six segmented inputs | Make code length and progress legible | Paste, keyboard, mobile, auto-advance, backspace, and screen-reader support |
| Join | Validate server-side | Loading, rate limiting, no duplicate submissions |
| Inline error | Explain recoverable result | Distinguish invalid, expired, unavailable, and technical states |
| Close | Exit without attachment | Restore focus to invoking action |

### A.3 Progressive intake

| Screen | Captured value | Durable representation |
|---|---|---|
| Name | Learner-facing display name | Unicode string, 3–50 grapheme clusters |
| Country | Selected country | ISO alpha-2 code |
| Age | Recognition-based age segment | Stable configured band key and policy version |
| Goal | Organic personalization choice | Stable goal identifier |
| Program preview | Validated routing context | Opaque program/cohort reference |

### A.4 Account wall and login

| Element | Purpose | Production requirement |
|---|---|---|
| Contextual heading | Explain why identity is needed now | Adapt by organic/program path; escape user content |
| Email/password | Universal account route | Server validation, password-manager support, abuse protection |
| Google/Facebook | Lower-friction identity routes | Provider configuration, secure callback, cancellation recovery |
| Terms and Privacy | Informed consent | Versioned links and recorded action |
| Existing-account link | Prevent duplicate identity | Preserve onboarding state through login |

### A.5 Learning Home boundary

| Element | Organic behavior | Program behavior |
|---|---|---|
| Greeting | Durable display name | Durable display name |
| Primary content | Goal-mapped first course | Assigned program content |
| Program task list | Hidden | Visible from enrollment payload |
| First action | `lesson_started` | `assigned_task_opened` |
| Progress/points | Placeholder only; outside scope | Placeholder only; outside scope |

---

## Appendix B: Core Data Model

```text
OnboardingSession
  id
  entry_path
  locale
  current_step
  completed_steps[]
  display_name
  country_code
  age_band
  eligibility_policy_version
  eligibility_result
  goal_id?
  validated_program_ref?
  program_validation_expires_at?
  attribution?
  created_at
  expires_at
  consumed_at?

LearnerProfile
  learner_id
  display_name
  country_code
  age_band
  onboarding_source
  initial_goal_id?
  locale
  created_at
  updated_at

ProgramEnrollment
  enrollment_id
  learner_id
  program_id
  cohort_id?
  source_onboarding_session_id
  enrolled_at
  status

ConsentRecord
  consent_id
  learner_id
  terms_version
  privacy_version
  locale
  surface
  consented_at
```

All identifiers in client-visible analytics or URLs must follow the platform's exposure policy. Internal database identifiers must not be assumed safe for public use.

---

*This PRD defines the production learner acquisition and onboarding funnel represented by the approved prototype. Research-proposed baseline assessment and deeper post-activation learning experiences require separate product decisions and specifications.*
