# Research: Indonesian Teacher EdTech Onboarding & Activation Literature

- **Status:** Closed
- **Type:** benchmark
- **Started:** 2026-07-16
- **Closed:** 2026-07-17
- **Researcher:** Gemini (acting Senior UI/UX & Academic Researcher)
- **Coverage:** unverified (pre-2026-07-29 study)

## Goal
Gather, synthesize, and evaluate empirical research papers, peer-reviewed articles, and industry reports on three core pillars to ground our Android app growth strategy:
1. **Deferred vs. Upfront Registration:** Quantitative and behavioral impacts on mobile app activation rates, drop-off friction, and user engagement when deferring account creation ("try-first") versus upfront signup ("wall-first").
2. **Loss Aversion & The Endowment Effect in Onboarding:** How psychological ownership (completing Module 1 or creating an initial teaching artifact) drives subsequent user registration and habit formation.
3. **Indonesian Teacher (`Guru di Indonesia`) EdTech Adoption & Motivation:** Empirical findings using the Technology Acceptance Model (TAM), digital literacy constraints, infrastructure limitations, and the role of recognized PD credentials (*Sertifikasi / Jam Pelatihan* via *Platform Merdeka Mengajar / PMM*) in driving sustained usage and adoption.

## Scope
**In scope:**
- Academic literature (peer-reviewed papers from OpenAlex, ERIC, PubMed, Europe PMC, and Indonesian university repositories such as Unram, UM, UNUJA).
- High-quality industry research reports and case studies (e.g., UX benchmarks, mobile app onboarding statistics on D1/D7 retention).
- Specific behavioral analysis of Indonesian educators across public and private school segments (*jenjang PAUD/SD/SMP/SMA/SMK*).

**Out of scope:**
- Live user testing or primary fielding (that belongs to usability testing).
- Non-educational e-commerce or gaming-only onboarding benchmarks unless directly demonstrating universal loss aversion mechanics.

## Research Areas & Key Literature Targets
- [x] Pillar 1: Mobile App Onboarding & Deferred Registration Benchmarks
- [x] Pillar 2: Loss Aversion, Endowment Effect & Enactive Mastery in Digital Learning
- [x] Pillar 3: TAM, Digital Literacy & PMM Adoption Among Indonesian Teachers

## Log
- 2026-07-16 — research created (type: benchmark, literature-focused parallel study).
- 2026-07-16 — synthesis written (`Type: benchmark`, 3 empirical features synthesized; Principal Researcher QA pass Mode B ran: 4 prose/em-dash fixes applied, 0 content issues flagged, readiness verdict: **Status: ready for `/review-research`**).
- 2026-07-16 — peer review recorded (`/review-research` completed: 0 Robust, 3 Strengthen, 0 Unsupported; all 3 features strengthened with steelmanned narrower claims, PEOU/WhatsApp OTP adaptations, `Modul Ajar / RPP` endowment trigger, and MGMP/KKG 32 JP co-certification paths; external domain sources recorded in `references.md`).
- 2026-07-17 — peer review re-run (`/review-research`, superseding the 2026-07-16 pass): 0 Robust, 3 Strengthen, 0 Unsupported, plus 5 cross-cutting integrity fixes applied — consolidated `data/*/notes.md` (formerly `platforms/*/notes.md`) citations onto `sources.md`; corrected the Feature 2 endowment citation (Charpentier → **Litovsky et al. 2022**, DOI `10.1073/pnas.2202700119`) in `SYNTHESIS.md` and `sources.md`; fixed the Overview "prove" headline; re-grounded Feature 3 on **Perdirjen GTK 7607/2023** (not PermenPANRB 6/2022); demoted MGMP/KKG 32 JP co-certification to an open governance hypothesis; re-anchored Feature 1 on **KepmenPANRB 16/2025** Dapodik lock and labelled $\lambda$/drop-off figures directional. New debate sources logged in `references.md`.
- 2026-07-17 — **folder structure formalized (`data/`).** Renamed `platforms/` to `data/` per workspace config (`data/*/notes.md`), formalizing that non-platform literature and desk-research studies store supplementary data and notes under `data/` instead of `platforms/`.
- 2026-07-17 — **research closed** (`/close-research`). Principal Designer (Mode P) harvested reusable patterns into `research/PATTERNS.md`: 2 added ("Endowment quality at the save-wall" design hypothesis; "Institution-recognized credentials as an activation driver"), 2 updated (deferred try-first registration; icon-first low-text intake), 0 contradictions. Removed from the active registry.
