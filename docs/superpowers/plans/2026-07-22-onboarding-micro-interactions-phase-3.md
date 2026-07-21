# Phase 3: Transitions & Polish Implementation Plan

## Overview
This final phase applies the "Tangible & Magnetic" physics to the macro-interactions: the progress bar fill, screen arrivals, and the success screen stamping animation.

## Task 5: Progress Bar & Screen Transitions

**Files:** `prototype-web.html`

### Requirements
- **Progress Bar Track:** Add an inset shadow to make it look physically recessed (`box-shadow: inset 0 2px 4px rgba(0,0,0,0.1);`).
- **Progress Bar Fill:** Change the transition easing to use the spring token (`transition: width 0.5s var(--easing-spring);`).
- **Screen Transition (Card Arrival):**
  - Create a new animation: `@keyframes springSlideUpIn { 0% { opacity: 0; transform: translateY(40px) scale(0.95); } 100% { opacity: 1; transform: translateY(0) scale(1); } }`
  - Apply it to `.card.active` replacing the old `obFadeInUp`: `animation: springSlideUpIn 0.5s var(--easing-spring) forwards;`

### Implementation Steps (for Implementer)
1. Write a python script to patch `prototype-web.html`.
2. Update the inline styles for the progress bar track (line ~799) to include the inset `box-shadow`.
3. Update the inline styles for the `#progress-bar` fill (line ~800) to use `transition: width 0.5s var(--easing-spring);`.
4. Replace `.card.active` animation with the new `springSlideUpIn` animation and add its `@keyframes` block to the CSS.
5. Commit: `style(transitions): implement spring physics for progress bar and screen arrivals`

## Task 6: Success Screen Stamp Animation

**Files:** `prototype-web.html`

### Requirements
- **Target:** The contents of the Assigned Content screen (`#assigned_content`).
- **Animation (Stamp):**
  - Create a new animation: `@keyframes springStampIn { 0% { opacity: 0; transform: scale(1.2); } 100% { opacity: 1; transform: scale(1); } }`
  - Elements in `#assigned_content` should start invisible (`opacity: 0`).
  - When `#assigned_content.active` is true, the children should trigger `springStampIn 0.5s var(--easing-spring) forwards`.
  - Apply staggered delays to the children (e.g., `h1.title` at 0.1s, `p.subtitle` at 0.2s, and the program card `div` at 0.3s).

### Implementation Steps (for Implementer)
1. Write a python script to patch `prototype-web.html`.
2. Add `@keyframes springStampIn` to the CSS.
3. Add CSS rules targeting `#assigned_content.active > h1.title`, `#assigned_content.active > p.subtitle`, and the program card (`#assigned_content.active > div`). They should all use `animation: springStampIn 0.5s var(--easing-spring) forwards;` with `opacity: 0;` initially, and staggered `animation-delay`s.
4. Commit: `feat(success): add staggered stamp animation to assigned content screen`
