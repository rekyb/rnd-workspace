# Onboarding Micro-Interactions Design

**Date:** 2026-07-21
**Topic:** Onboarding Flow - Tangible & Magnetic Interactions

## 1. Goal & Emotional Tone
To implement "Tangible & Magnetic Interactions" across the Solve Education! onboarding flow (`prototype-web.html`). The emotional tone should be energetic, tactile, and highly responsive. Elements will feel physical—they pop, press, spring, and snap into place, giving the user immediate, satisfying feedback.

## 2. Core Design Tokens
New CSS variables will be introduced to handle the physics and depth:
*   **Spring Easing:** `--easing-spring: cubic-bezier(0.34, 1.56, 0.64, 1);` (used for screen arrivals, progress bar, and code input pulses)
*   **Fast Easing:** `--easing-fast: cubic-bezier(0.2, 0, 0, 1);` (used for hover states and button presses)
*   **Depth Colors:** A darker hair border (`--hair-dark: #d5d5d5`) and a darker purple (`--purple-dark: #64156d`) will be used to create 3D block shadows.

## 3. Component Updates

### 3.1. Buttons
*   **Normal State:** 3D bottom shadow (`box-shadow: 0 6px 0 var(--purple-dark);`)
*   **Hover State:** Lifts slightly (`transform: translateY(-2px);`) and shadow extends to 8px.
*   **Active (Click) State:** Pushes down into the screen (`transform: translateY(6px);`) and shadow compresses to 0px.

### 3.2. Option Cards (Goals, Age)
*   **Normal State:** Solid 2px border, small bottom shadow (`box-shadow: 0 4px 0 var(--hair-dark);`).
*   **Hover State:** Lifts up (`translateY(-4px)`), shadow increases, and adds a soft ambient shadow.
*   **Active (Click) State:** Pushes down into the screen, bottom shadow compresses.
*   **Selected State:** Changes border and shadow color to Purple.

### 3.3. 6-Digit Code Input
*   **Normal State:** Inset shadow (`box-shadow: inset 0 3px 6px rgba(0,0,0,0.06);`) to look like a physical recessed hardware slot.
*   **Focus State:** Pops out (removes inset, scales to `1.05`, adds outer drop shadow).
*   **Typing (Keystroke):** Quick scale down to `0.9` and back to `1.0` (simulating a physical keypress).
*   **Error State:** Heavy, sharp, multi-step shake animation to indicate a firm rejection.

### 3.4. Progress Bar
*   **Track:** Inset shadow to look recessed.
*   **Fill:** Expands using the spring easing so it "bounces" slightly when reaching the new percentage.

### 3.5. Screen Transitions
*   **Card Arrival:** Outgoing cards disappear, and incoming cards use `animation: springSlideUpIn 0.5s var(--easing-spring) forwards`. They start scaled down at `0.95` and lower on the Y-axis, then spring up to scale `1.0` and `Y: 0`.

### 3.6. Success Screen ("You're In!")
*   **Stamp Reveal:** Elements do not slide up or fade in smoothly. Instead, they "stamp" into place—starting at scale `1.2`, 0 opacity, and snapping down to scale `1.0`, 1 opacity using the spring easing, with a staggered delay between the mascot, title, and program card.

## 4. Implementation Scope
These updates will be directly applied to `C:\research-workspace\design\onboarding-solve-edu\prototype-web.html`. We will refactor the existing CSS in that file to replace the current flat/fade transitions with the new tangible styles. No external frameworks or libraries are required.
