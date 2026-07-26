# Organic Onboarding Prototype Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a self-contained, clickable HTML prototype of the non-program learner flow defined in `SPEC-2.md`.

**Architecture:** One HTML file contains the semantic screen markup, tokenized CSS, sample program data, and a small client-side state machine. A PowerShell contract test verifies the required screens, navigation hooks, accessibility landmarks, and absence of assessment mechanics.

**Tech Stack:** HTML5, CSS custom properties, vanilla JavaScript, PowerShell contract test.

## Global Constraints

- The source of truth is `research/2026-07-20-unified-onboarding-synthesis-and-patterns/SPEC-2.md`.
- Prototype only the organic learner flow: Landing → Age Gate → Program Discovery → Recommendations → Program Preview → Program Confirmation → Registration/OTP → Enrollment Confirmation → Program Welcome.
- Do not include Lesson 0, Skill Check, baseline assessment, placement, or scored interactions.
- Keep the prototype self-contained with no external dependencies or hosts.
- Provide a complete keyboard path, visible focus, 44px minimum targets, and responsive layouts at 375, 768, and 1440 pixels.

---

### Task 1: Prototype contract

**Files:**
- Create: `research/2026-07-20-unified-onboarding-synthesis-and-patterns/prototype-organic.test.ps1`
- Create: `research/2026-07-20-unified-onboarding-synthesis-and-patterns/prototype-organic.html`

**Interfaces:**
- Consumes: Screen IDs and actions specified in `SPEC-2.md`.
- Produces: A static contract check and a browser-openable prototype.

- [ ] **Step 1: Write the failing contract test**

Create a PowerShell test that requires the nine organic-flow screen IDs, `data-go` navigation controls, semantic `main` and progress elements, responsive CSS, and the explicit absence of assessment mechanics.

- [ ] **Step 2: Run the test to verify it fails**

Run: `powershell -ExecutionPolicy Bypass -File research/2026-07-20-unified-onboarding-synthesis-and-patterns/prototype-organic.test.ps1`

Expected: FAIL because `prototype-organic.html` does not exist.

- [ ] **Step 3: Implement the self-contained prototype**

Create the HTML with a screen-based state machine, specific sample program content, age validation, preference selection, recommendation choice, program preview, confirmation, OTP simulation, enrollment confirmation, and direct program welcome.

- [ ] **Step 4: Run the contract test**

Run the same PowerShell command.

Expected: PASS with all contract checks satisfied.

- [ ] **Step 5: Run structural and content checks**

Run HTML searches for duplicate screen IDs, placeholder copy, external URLs, forbidden assessment terms, and missing button labels. Confirm zero blocking findings.

- [ ] **Step 6: Audit and review**

Run the G1–G8 design-gate checklist and submit the prototype to Principal Designer Mode T. Apply all blocking revisions and rerun the contract test.

- [ ] **Step 7: Commit the prototype**

```powershell
git add -- research/2026-07-20-unified-onboarding-synthesis-and-patterns/prototype-organic.html research/2026-07-20-unified-onboarding-synthesis-and-patterns/prototype-organic.test.ps1 docs/superpowers/plans/2026-07-21-organic-onboarding-prototype.md
git commit -m "prototype: add organic program-confirmation flow"
```

