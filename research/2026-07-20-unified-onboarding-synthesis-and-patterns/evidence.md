# Evidence: Onboarding Strategy & Patterns

## Verified claims

### Universal Onboarding Principles
- **Value-before-signup (Deferred Registration)**: Front-loading an account wall before delivering value causes severe drop-off (25-40% in benchmarks) and blocks activation. Deferring registration until after the first "win" or completed lesson is the primary architectural recommendation across all contexts. [High Confidence] [S1, S2, S3]
- **Loss Aversion for Account Creation (Endowment Effect)**: When users create progress or an artifact as a guest, they develop psychological ownership. Framing the eventual registration ask as "saving progress" rather than "creating an account" leverages loss aversion to lift conversion. [High Confidence] [S1, S2, S3]
- **Optional, Positively-Framed Placement**: Placement tests should not be mandatory upfront walls. They should be offered as an optional fork ("start from scratch" vs "find my level") and use recognition-based mechanics rather than abstract labels to avoid intimidating novices while still respecting advanced users. [High Confidence] [S1, S3]
- **Guided First Task for Early Competence**: The first user interaction should be designed for a near-guaranteed win to build intrinsic motivation (competence). This requires structural scaffolding: one clear CTA, guided prompts (guide character/icons), instant positive feedback, and bounded progress indicators. [High Confidence] [S1, S3]

### Context-Specific Divergences
- **The Nature of the "Endowment Object"**: While generic learners (S1, S3) are motivated to save XP, streaks, or a lesson score, professionals such as Indonesian teachers (S2) require the generation of a tangible professional artifact (e.g., Modul Ajar/RPP) tied to recognized civil-service credentials (Sertifikasi/Jam Pelatihan) to trigger meaningful ownership. [Medium Confidence] [S1, S2, S3]
- **The Winnable-yet-Credible Trilemma**: In basic education apps (S1), an un-losable recognition task is sufficient for an "aha" moment. However, for a job-readiness product (S3), the first task must simulate a real job role to provide credible proof to employers. This introduces a tension where a task that is too easy feels like an ad, but a task that is too hard causes failure and erodes self-efficacy. [High Confidence] [S3]
- **Sources of Upfront Friction**: Generic audiences face cognitive load and trust deficits at a cold signup wall (S1, S3). In contrast, Indonesian teachers face hard structural and regulatory friction, such as government SSO (belajar.id) lockouts and poor network infrastructure, making deferred registration and alternative logins (WA OTP) a technical necessity, not just a UX optimization. [High Confidence] [S2]

### Reusable UX Patterns (for PATTERNS.md)
- **Deferred Registration (Try-first mode)** [S1, S3]
- **Single-CTA Landing Screen** [S1]
- **Loss-aversion Registration Trigger** [S1, S2, S3]
- **Optional Placement Fork & Recognition-based Level Selection** [S1, S3]
- **Assessment-as-Onboarding** [S1]
- **Character-guided, Icon-first Intake** [S1, S3]
- **Momentum Scaffolding (Progress bars, Instant Feedback)** [S1, S3]
- **Permission Priming with Graceful Fallbacks** [S1]
- **Repositioned Compliance/Safety Gates (at persistence, not entry)** [S3]
- **Deep UI Localization** [S1]

## Refuted / weak claims
- **Global 25-40% drop-off rate as a fixed metric**: The 25-40% drop-off for upfront registration is a cross-industry consumer app aggregate, not a measured figure for Indonesian teachers or youth job-readiness platforms. It should be used directionally, not as a guaranteed magnitude. [S2, S3]
- **The exact loss-aversion ratio (λ ≈ 2.2) as a conversion multiplier**: The lab-derived loss-aversion ratio is highly heterogeneous and contested; it justifies the *direction* (loss > gain) of the framing but does not predict a specific mathematical lift in funnel conversion. [S2]
- **Humanizing touches (1:1 founder onboarding) scale to education apps**: The 65% conversion lift observed for high-touch B2B products (e.g., Superhuman) does not naturally transfer to high-volume, low-context education products. It must be adapted into a scalable, lightweight variant (e.g., a signed note). [S1]
