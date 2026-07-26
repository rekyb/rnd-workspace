# Onboarding (Boundary Flow)

## What this is

Onboarding is the **boundary flow before the tabbed app**. It ends by dropping the
teacher into `Belajar` with a next step already chosen. It deliberately captures only
what `Belajar` and the `Prompt` dictionary need to feel relevant, plus the one
student-data safety rule. There is no account, no tutorial, and no feature tour here.

This file details what the README, `information-architecture.md`, and `user-journey.md`
each park as a boundary flow "to be detailed separately."

## Grounding

The decisions below are set by research already in this workspace, not by preference:

- `research/2026-07-16-indonesian-teacher-onboarding-literature/SYNTHESIS.md`
  - **F1 — Deferred "try-first" registration:** upfront account walls cause a 25–40%
    mobile session drop-off. No wall at launch.
  - **F2 — Loss-aversion trigger at the endowment moment:** ask for the account *after*
    the first win, framed as protecting earned progress (λ≈2.2), not "make an account."
  - **F3 — Context-anchored, icon-first intake:** a lightweight jenjang/mapel selector,
    bite-sized modules for low-bandwidth Android.
- `research/2026-07-14-ai-literacy-upskilling-indonesian-teachers/AUDIENCE-CONTEXT.md`
  - Mobile-first, Android-first, low-end devices; ~25% intermittently offline.
  - Digital self-efficacy is real but **age-linked** — onboarding cannot assume uniform
    confidence; scaffold older / rural teachers explicitly.
- `design/ai-literacy-app/validation-model.md`
  - **No self-issued certificate in v1.** The app never mints or claims an official
    credential (certification / PD-hours / PKB). Badges are in-loop engagement recognition,
    not the terminal reward. The account hook is framed around protecting real professional
    progress, not "saving a badge."

> **Resolved decision — certificate vs. badge framing at the account moment**
> *(resolved 2026-07-17 by `research/2026-07-17-certificate-vs-badge-gamification`).*
>
> The dedicated research pass is closed, and it reframes the question from either/or to
> **role assignment**:
> - A **certificate carries the extrinsic, credential-signalling pull** that Indonesian
>   teacher culture rewards — but its real value comes only when it **feeds a real external
>   credential** (the teacher's PKB / PPG *Sertifikat Pendidik* portfolio, which ties to the
>   professional allowance and civil-service progression). The product can **feed** that
>   portfolio; it must **not issue** a national credential itself.
> - **Badges are demoted to in-loop engagement recognition**, never the terminal reward.
>
> **v1 position (buildable, guardrail-safe):** do **not** build or claim official PD-credit
> in v1 — a real "feed PD credit" integration needs a government tie-in (Rumah Pendidikan /
> Kemendikbud) we don't control, and claiming credit we can't deliver breaks trust worse than
> badge-only. Instead: (a) keep the guardrail — no self-issued certificate or official-credit
> language; (b) frame the account hook around **protecting real professional progress**
> (a portfolio-worthy readiness completion), not "save your badge"; (c) design the terminal
> readiness moment to be **PD-credit-ready** so a future official integration slots in without
> a redesign — mirroring how the IA is "generation-ready but prompt-only functional."
>
> **Confidence:** the role-assignment logic rests on 4 solid mechanism sources, but its
> **local transfer to Indonesian teachers is an open hypothesis** (only 2 directly-Indonesian
> anchors). Treat this as a validated direction to test, not a settled fact.

---

## Onboarding Principle

**Reach the first `Belajar` node in under a minute, on a low-end Android, without an
account.** Capture the least intake that still personalizes the experience and keeps
students safe. Move the highest-friction step (the account) to the highest-motivation
moment (the first win), which happens *after* onboarding, inside `Belajar`.

---

## Information Architecture

### Screen inventory

| # | Screen | Purpose | Input | Exit |
|---|---|---|---|---|
| 1 | **Welcome / fear-reduction** | Lower threat; set the "assistant, not replacement" frame | None (read + tap) | **Mulai** → 2 |
| 2 | **Jenjang** | Capture teaching level | One tap: PAUD / SD / SMP / SMA / SMK | auto-advance → 3 |
| 3 | **Mapel** | Capture subject(s) | One+ chips | **Lanjut** → 4 |
| 4 | **First need** | Prime the first `Belajar` node with a real job | One tap of 3–4 options, or **Lewati** | → 5 |
| 5 | **Ground rule** | The student-data safety rule as a light acknowledgment | Tap **Saya mengerti** | → `Belajar` |

### IA diagram

```mermaid
flowchart TD
  Launch[App launch - guest, no wall] --> W[1 Welcome / fear-reduction]
  W --> J[2 Jenjang]
  J --> M[3 Mapel]
  M --> N[4 First need - skippable]
  N --> G[5 Ground rule]
  G --> B[Belajar: first node primed to need]

  subgraph Captured[Local guest context]
    J -.-> ctx[(jenjang)]
    M -.-> ctx2[(mapel)]
    N -.-> ctx3[(first need)]
    G -.-> ctx4[(safety ack)]
  end

  B --> Win[First win: copy/save prompt or finish Module 1]
  Win --> Acct[Account moment - deferred, loss-framed]
```

### Data captured (all local until account)

| Field | Source screen | Used by |
|---|---|---|
| `jenjang` | 2 | Prompt placeholders, personalized examples, primed node |
| `mapel[]` | 3 | Prompt placeholders, category relevance |
| `first_need` | 4 (optional) | Which `Belajar` node is highlighted first |
| `safety_ack` | 5 | Recorded; reinforced by the PII-in-prompt guardrail later |

Nothing leaves the device until the teacher registers at the endowment moment. Guest
progress is local and is claimed onto the account at registration.

### What onboarding deliberately does *not* do

- **No** email/password wall, login, or permission prompts before value (avoids the
  25–40% mobile drop-off — onboarding-lit F1).
- **No** long AI tutorial or feature tour (Belajar rule: do not front-load a tutorial).
- **No** certificate / PD-hour language anywhere (validation-model guardrail).

---

## User Journey

**Journey principle:** *warm → oriented → safe → first step.*

### Step-by-step

1. **Land warm, not walled.** The app opens straight into Welcome — no login. Plain
   Bahasa: AI lightens their work rather than replacing them. *User question: "Apakah ini
   aman untuk saya?" → Design answer: a calm yes, and one button.*
2. **Say who you teach (jenjang).** Icon-first, one tap, auto-advances. Large targets for
   older / rural teachers (scaffolds the age-linked confidence gap).
3. **Say what you teach (mapel).** Subject chips; multi-select allowed; one **Lanjut**.
4. **Name a first need (optional).** *"Apa yang ingin Anda lakukan dulu?"* — e.g. *bikin
   rencana mengajar*, *bikin kuis*, *hemat waktu admin*. The pick sets which node
   `Belajar` highlights first. **Lewati** is always visible, so it never blocks.
5. **Learn the one rule.** A single light screen states the student-data rule and asks for
   **Saya mengerti**. Instructional, not a legal wall.
6. **Arrive with a next step already chosen.** The teacher lands in `Belajar` with the
   first node primed to their stated need and a time promise (*"Prompt pertama Anda.
   5 menit."*).

### Emotional arc

```mermaid
journey
  title AI-Literacy App Onboarding Arc
  section Enter
    Open app as guest (no wall): 4: Teacher
    Read fear-reduction welcome: 4: Teacher
  section Orient
    Pick jenjang: 5: Teacher
    Pick mapel: 5: Teacher
    Name a first need: 4: Teacher
  section Safe start
    Acknowledge student-data rule: 3: Teacher
    Land in Belajar with a primed step: 5: Teacher
```

### Onboarding main flow

```mermaid
flowchart TD
  A[Launch as guest] --> B[Welcome: Mulai]
  B --> C[Pick jenjang]
  C --> D[Pick mapel]
  D --> E{Name a need?}
  E -->|Pick one| F[Prime first node to need]
  E -->|Lewati| G[Prime default first node]
  F --> H[Ground rule: Saya mengerti]
  G --> H
  H --> I[Land in Belajar]
```

### The account moment (deferred sub-flow, outside onboarding)

The highest-friction step is moved to the highest-motivation moment and framed as loss,
not admin. This fires inside `Belajar`, after onboarding is complete.

```mermaid
flowchart TD
  I[In Belajar as guest] --> W[First win: copy/save prompt OR finish Module 1]
  W --> P["Prompt: 'Simpan progres Anda agar tidak hilang'"]
  P --> Q{Register now?}
  Q -->|Ya| R[Lightweight account - phone / Google]
  R --> S[Guest context + progress claimed to account]
  Q -->|Nanti| T[Stay guest, keep using]
  T -. later win .-> P
```

---

## Failure & Recovery States

| Situation | Desired behavior |
|---|---|
| Poor / no connectivity during onboarding | Onboarding is local-only, so it completes offline; sync defers to the account moment. |
| Teacher taps **Lewati** on the need step | Fall back to the default first node (`Prompt pertama Anda`); no dead-end. |
| Teacher declines the account at first win | Stay in guest mode with full function; re-offer at the next win, never block. |
| Teacher picks the wrong jenjang / mapel | Editable later in `Profil → teacher context`; saved prompts preserved. |
| Older / low-confidence teacher hesitates | Large targets, one decision per screen, plain "Anda" copy, no jargon. |
| Guest data at risk (reinstall before account) | Be honest at the account prompt that unsaved guest progress is device-only until registration. |

---

## Guardrails

- Don't make the teacher hunt for the next step — they arrive with one primed.
- Don't gate first value behind an account or a tutorial.
- Keep the safety rule instructional, never punitive or legalistic.
- No self-issued certificate or official-credit (certification / PD-hour / PKB) language in
  v1. Frame the account hook around protecting real professional progress; badges are in-loop
  recognition, not the terminal reward. (See the resolved certificate-vs-badge decision above.)
- Assume mixed confidence and low bandwidth by default; never assume a fast phone or a
  confident user.

---

## Cross-References

- `information-architecture.md` — the `Onboarding boundary` node that hands off to `Belajar`.
- `user-journey.md` — stage "0. Boundary: Onboarding" in the core teacher journey.
- `validation-model.md` — the badge / no-certificate rule the account hook must honour.
