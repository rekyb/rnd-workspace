# Phase 2: Cards & Inputs Implementation Plan

## Overview
This phase implements the "Tangible & Magnetic" micro-interactions for the age/goal selection cards and the 6-digit verification code inputs. 

## Task 3: Option & Goal Cards

**Files:** `prototype-web.html`
**Target Classes:** `.option-card`, `.goal-card`

### Requirements
- **Normal State:**
  - `box-shadow: 0 4px 0 var(--hair-dark);`
  - `transition: transform 0.2s var(--easing-fast), box-shadow 0.2s var(--easing-fast), border-color 0.2s, background 0.2s;`
- **Hover/Focus State:** 
  - Elevate (`transform: translateY(-4px);`)
  - Deepen shadow and add ambient drop-shadow (`box-shadow: 0 8px 0 var(--hair-dark), 0 12px 24px rgba(0,0,0,0.08);`)
- **Active (Press) State:**
  - Press down (`transform: translateY(4px);`)
  - Compress shadow (`box-shadow: 0 0px 0 var(--hair-dark);`)
  - Fast transition (`transition: transform 0.05s, box-shadow 0.05s;`)
- **Selected State:**
  - Border and shadow color change to Purple (`var(--purple)` border, `0 4px 0 var(--purple-dark)` shadow).
  - Hovering a selected card should use the purple-dark shadow, not hair-dark.

### Implementation Steps (for Implementer)
1. Write a python script to patch the CSS for `.option-card` and `.goal-card`. Consolidate shared hover and active states where possible to keep it DRY (e.g. `.option-card:hover, .goal-card:hover`).
2. Add `.option-card.selected` and `.goal-card.selected` rules that specifically override the `box-shadow` colors to use `--purple-dark` (and handle their selected-hover/selected-active states properly).
3. Run the script and verify the changes visually in the browser.
4. Commit: `style(cards): implement 3D tactile physics for selection cards`


## Task 4: 6-Digit Code Input

**Files:** `prototype-web.html`
**Target Classes:** `.code-digit`

### Requirements
- **Normal State:**
  - Hardware slot look: `box-shadow: inset 0 3px 6px rgba(0,0,0,0.06);`
  - Smooth spring transition: `transition: transform 0.3s var(--easing-spring), box-shadow 0.3s var(--easing-spring), border-color 0.2s;`
- **Focus State:**
  - Pops out towards user: `transform: scale(1.05);`
  - Remove inset shadow, add outer glow: `box-shadow: 0 4px 12px rgba(142, 39, 155, 0.15);` (Using a soft purple glow to match focus border).
- **Typing (Keystroke) Animation:**
  - Define a new CSS keyframe animation `@keyframes keystrokePulse { 0% { transform: scale(1.05); } 50% { transform: scale(0.9); } 100% { transform: scale(1.05); } }`.
  - The JS inside `prototype-web.html` around line 1180 handles the code input. Inject a script block to add a class `pulse` on `input` event, and remove it on `animationend`.
  - Add CSS for `.code-digit.pulse { animation: keystrokePulse 0.15s var(--easing-fast) forwards; }`

### Implementation Steps (for Implementer)
1. Write a python script to patch the CSS for `.code-digit` to include the normal and focus box-shadows, and the keyframe animation.
2. In the same script, patch the JS block for `input.addEventListener('input', (e) => { ... })` to add `input.classList.add('pulse');` and a one-time `animationend` listener to remove it.
3. Verify the inset appearance, the focus pop-out, and the typing pulse in the browser.
4. Commit: `feat(inputs): add tactile hardware slot styling and keystroke pulse to code input`
