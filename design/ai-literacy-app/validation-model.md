# Validation Model

## Purpose

Validation should confirm that teachers understand AI literacy and can use AI properly without requiring a heavy capstone project or formal certificate.

The model favors short, structured, mobile-friendly checks over open-ended essays.

## Validation Principles

- Match the check type to the learning target.
- Keep checks short enough for mobile completion.
- Give explanatory feedback, not just right/wrong.
- Use validation to unlock sensitive prompt categories.
- Award badges as competence markers, not formal credentials.

---

## Recommended Validation Tools

| Tool | Best for | Example |
|---|---|---|
| MCQ / myth-vs-fact | Basic AI concepts | "AI selalu benar." True or false? |
| Scenario sorting | Proper-use judgment | Sort into `boleh`, `jangan`, `tergantung`. |
| Spot-the-risk | Privacy, hallucination, bias, integrity | Identify what is risky in a prompt or output. |
| Prompt repair | Practical prompting skill | Choose or assemble a clearer prompt. |
| Output critique | Verification habit | Mark which part of an AI output needs checking. |
| Classroom dilemma | Nuanced classroom judgment | Decide whether a student AI use case is cheating, acceptable, or depends. |
| Confidence pulse | Self-efficacy and intent | "Saya bisa memakai ini minggu ini." 1-5. |

## Avoid in v1

- Long essay answers.
- AI-graded free text.
- Formal capstone submission.
- Student photo/work upload.
- Certificate-style assessment claims.

These add grading complexity, Bahasa evaluation risk, and unnecessary friction for the current IA.

---

## Module-Level Validation

| Module | Target | Recommended checks | Unlock / badge |
|---|---|---|---|
| AI tidak akan menggantikan Anda | Basic literacy + privacy rule | MCQ, safe/unsafe sorting | Badge: `Mulai Paham AI` |
| Prompt pertama Anda | Basic prompting | Prompt repair, prompt-use challenge | Badge: `Prompt Pertama` |
| Jangan percaya buta | Verification and hallucination | Spot-the-risk, output critique | Badge: `Pemeriksa Kritis` |
| Pakai AI dengan aman | Privacy, student data, integrity | Scenario sorting, spot-the-risk | Unlocks sensitive prompt categories; badge: `Aman dengan Data Siswa` |
| AI untuk kelas | Proper classroom use | Classroom dilemma, scenario sorting | Unlocks student-facing prompts; badge: `AI untuk Kelas` |
| Siap pakai sehari-hari | Daily workflows | Prompt selection, prompt repair | Badge: `Siap Pakai Harian` |
| Final readiness check | Integrated competence | Mixed check set | Badge: `Siap Pakai AI dengan Aman` |

```mermaid
flowchart TD
  M1[AI tidak akan menggantikan Anda] --> C1[MCQ + safe/unsafe sorting]
  C1 --> B1[Badge: Mulai Paham AI]
  B1 --> M2[Prompt pertama Anda]
  M2 --> C2[Prompt repair + prompt-use challenge]
  C2 --> B2[Badge: Prompt Pertama]
  B2 --> M3[Jangan percaya buta]
  M3 --> C3[Spot-the-risk + output critique]
  C3 --> B3[Badge: Pemeriksa Kritis]
  B3 --> M4[Pakai AI dengan aman]
  M4 --> C4[Privacy + proper-use checks]
  C4 --> U1[Unlock sensitive prompt categories]
  U1 --> B4[Badge: Aman dengan Data Siswa]
  B4 --> M5[AI untuk kelas]
  M5 --> C5[Classroom dilemma]
  C5 --> U2[Unlock student-facing prompts]
  U2 --> B5[Badge: AI untuk Kelas]
  B5 --> M6[Siap pakai sehari-hari]
  M6 --> C6[Prompt selection + repair]
  C6 --> B6[Badge: Siap Pakai Harian]
  B6 --> F[Final readiness check]
  F --> FB[Badge: Siap Pakai AI dengan Aman]
```

---

## Final Readiness Check

The final readiness check replaces a capstone.

Recommended length: **10-12 minutes**.

Recommended composition:

| Section | Count | Purpose |
|---|---:|---|
| MCQ / myth-vs-fact | 4 | Tests basic AI literacy. |
| Spot-the-risk | 3 | Tests safety and verification. |
| Prompt repair | 2 | Tests practical prompting. |
| Classroom dilemma | 2 | Tests proper-use judgment. |
| Prompt dictionary task | 1 | Tests whether teacher can choose the right prompt for a real job. |

Passing result:

- unlock final readiness badge;
- unlock remaining safety-gated prompt categories;
- show suggested next daily-use prompts.

If the teacher does not pass:

- show weak areas;
- link back to specific learning nodes;
- allow retry without penalty.

```mermaid
flowchart TD
  A[Start readiness check] --> B[MCQ / myth-vs-fact]
  B --> C[Spot-the-risk]
  C --> D[Prompt repair]
  D --> E[Classroom dilemma]
  E --> F[Prompt dictionary task]
  F --> G{Pass threshold met?}
  G -->|Yes| H[Unlock final readiness badge]
  H --> I[Suggest next daily-use prompts]
  G -->|No| J[Show weak areas]
  J --> K[Deep-link to relevant Belajar nodes]
  K --> A
```

---

## Prompt Unlock Mapping

| Prompt category | Required check |
|---|---|
| Rencana Mengajar | Open by default. |
| Administrasi Guru | Open by default. |
| Diferensiasi | Prompt repair or output critique check. |
| Asesmen & Kuis | Verification + proper-use check. |
| Komunikasi Orang Tua | Privacy / student-data check. |
| Aktivitas Siswa | Classroom-use dilemma check. |
| Etika & Penggunaan AI | Proper-use module check. |

## Badge Rules

> **Role of badges (resolved 2026-07-17, per `research/2026-07-17-certificate-vs-badge-gamification`).**
> Badges are **in-loop engagement recognition, not the terminal reward.** The research found
> that for Indonesian teachers a *credential* carries the extrinsic pull, while badges reliably
> drive activity but are fragile as a completion driver and weak as a competency claim. So
> badges keep teachers moving between sessions; the *reason to finish* is the portfolio-worthy
> readiness completion (see **Terminal readiness & PD-credit direction** below), not a badge.

Badges should:

- mark participation and progress inside the learning loop;
- be visible in `Belajar` as milestones and stored in `Profil`;
- use plain, honest competence language;
- avoid any certification, PD-hour, or PKB claim.

Badges should not:

- imply official recognition or an external credential;
- be the terminal reward or the main reason to complete the course;
- be framed as a reward for speed;
- replace actual feedback.

### Terminal readiness & PD-credit direction (v1 scope)

The final readiness check produces a **portfolio-worthy completion**, framed around real
professional progress — not a self-issued certificate.

- **v1 does not build or claim official PD-credit.** A real "feed PD credit" integration needs
  a government tie-in (Rumah Pendidikan / Kemendikbud) outside our control; claiming credit we
  cannot deliver breaks trust worse than badge-only. The no-self-issued-certificate guardrail
  holds for v1.
- **Design it PD-credit-*ready*.** Structure the readiness completion so that *if/when* an
  official PPG / PKB integration lands, it slots in without a redesign — the same "generation-
  ready but prompt-only functional" discipline the IA uses.
- **Confidence:** this direction rests on solid mechanism evidence, but its local transfer to
  Indonesian teachers is an open hypothesis (2 directly-Indonesian anchors). Treat as a
  validated direction to test, not settled fact.

## Feedback Model

Every validation item should explain:

1. what the correct answer is;
2. why it matters for teacher practice;
3. what to do next.

Example:

> Jangan masukkan nama siswa ke prompt. Ganti dengan deskripsi anonim seperti "siswa kelas 7 yang kesulitan memahami pecahan".

This keeps validation instructional rather than punitive.
