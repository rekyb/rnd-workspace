# Mascot Specification: "Jali" the Jalak Bali

This document defines the character requirements for the AI-Literacy App mascot. It focuses on constraints, emotional range, and tone, ensuring the mascot aligns with the app's professional-but-supportive product thesis.

## 1. Core Identity & Role

- **Archetype:** The Supportive Peer / Teacher's Assistant.
- **Species/Anchor:** Jalak Bali (Bali Starling). It is intelligent, communicative, and culturally rooted in Indonesia without carrying the "trickster" baggage of other local tropes (like the Kancil).
- **Name:** A friendly, approachable name like "Jali" or "Bintang" to make the character memorable and reduce the intimidation factor of AI.
- **Role:** Jali guides, celebrates wins, and flags dangers, but the teacher is always the one in charge. Jali is a tool for the teacher's empowerment, never an omniscient authority or a student to be taught.

## 2. Visual Design & Brand Alignment

- **Base Colors:** Predominantly white with slate/indigo accents. This ensures perfect harmony with the `indigo velvet` (`--primary`) brand palette.
- **Color Independence:** Jali's core character design **must not** rely on our semantic meaning colors.
  - No teal (`--safe-bg`) body.
  - No amber (`--win-bg`) body.
  - No red (`--danger-bg`) or deep green (`--readiness-bg`).
- **Scalability:** Must remain highly legible when scaled down to an icon beside a bottom sheet (`--touch-min`) and when scaled up for the Onboarding welcome screen.
- **Simplicity:** The design should be clean and slightly stylized. SVG-friendly, avoiding hyper-realistic rendering or excessive gradients.

## 3. Emotional Range & UI State Mapping

The mascot must be capable of expressing distinct states that map 1:1 with our design system components:

| State | Context / Component | Mascot Behavior & Posture |
|---|---|---|
| **Guiding / Neutral** | Onboarding, `Belajar` current path | Open posture, ready to assist. Friendly but professional. |
| **Celebrating** | Win moment (module completion, badges) | Warm expression, slight upward posture. Fits within the subtle particle burst. *No hyper-energetic confetti explosions.* |
| **Instructional** | Locked prompt explainer (`learn-first`) | Patient, pointing/guiding posture. *Crucially: Must not look punitive, scolding, or disappointed.* |
| **Alert / Serious** | PII Guardrail Callout (`danger` state) | Stands tall, wings folded or pointing firmly. Serious but calm expression (no anger, no panic). Often holding a `shield-check` or `alert-triangle` icon. Matches the cold, unadorned copy. |

## 4. Tone & Voice Rules

When the mascot "speaks" (via UI copy):
- **Encouraging, not Overbearing:** Celebrates completions but gets out of the way during focused work in the Prompt dictionary.
- **Honest and Direct:** Avoids flowery language.
- **Respects the Stakes:** In danger states (e.g., student PII violations), Jali drops all warmth. The tone becomes formal and unadorned (e.g., full "tidak", no "nggak", no particles like "ya" or "kok").

## 5. Animation Constraints

- **Idle Motion:** Any idle animations must be subtle (following the `≤ --dur-win` constraint) so as not to distract from the learning content.
- **Fallback:** Must support a fully static (SVG) reduced-motion fallback that still clearly communicates the required emotional state through silhouette and expression alone.
