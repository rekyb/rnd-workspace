# GAIN Card Tints Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give all four GAIN cards uniform light backgrounds derived from their individual palette colors.

**Architecture:** Keep the existing inline card markup and change only its visual style declarations. Add source-level assertions to the existing PowerShell test, then regenerate `standalone.html` with the established builder.

**Tech Stack:** HTML5, inline CSS, PowerShell 5+

## Global Constraints

- Use one uniform tint across both the icon and content areas of each card.
- Keep icons and headings in their saturated palette colors.
- Use `--ink2` for dark body copy.
- Use palette-coordinated translucent borders.
- Preserve markup, content, spacing, layout, and responsive behavior.

---

### Task 1: Apply and verify GAIN palette tints

**Files:**
- Modify: `design/onboarding-solve-edu/prototype-web.test.ps1`
- Modify: `design/onboarding-solve-edu/prototype-web.html:108-151`
- Generate: `design/onboarding-solve-edu/standalone.html`

**Interfaces:**
- Consumes: the four existing GAIN cards and CSS palette variables
- Produces: palette-tinted GAIN cards in both modular and standalone prototypes

- [ ] **Step 1: Add failing palette assertions**

Add assertions near the start of `prototype-web.test.ps1`:

```powershell
Assert-Matches 'background:\s*rgba\(35,\s*151,\s*203,\s*0\.12\);\s*border:\s*1px solid rgba\(35,\s*151,\s*203,\s*0\.28\)' 'Gamification card must use a full blue tint.'
Assert-Matches 'background:\s*rgba\(236,\s*26,\s*100,\s*0\.10\);\s*border:\s*1px solid rgba\(236,\s*26,\s*100,\s*0\.25\)' 'AI Coach card must use a full magenta tint.'
Assert-Matches 'background:\s*rgba\(142,\s*39,\s*155,\s*0\.10\);\s*border:\s*1px solid rgba\(142,\s*39,\s*155,\s*0\.25\)' 'Incentives card must use a full purple tint.'
Assert-Matches 'background:\s*rgba\(234,\s*65,\s*52,\s*0\.10\);\s*border:\s*1px solid rgba\(234,\s*65,\s*52,\s*0\.25\)' 'Network card must use a full red tint.'
Assert-Matches 'font-size:\s*15px;\s*color:\s*var\(--ink2\)' 'GAIN card body copy must use dark text.'
```

- [ ] **Step 2: Run the test and confirm the new assertion fails**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/prototype-web.test.ps1
```

Expected: fail with `Gamification card must use a full blue tint.`

- [ ] **Step 3: Apply the uniform tint styles**

For each card in `prototype-web.html`:

- Replace `background: var(--bg)` with its specified RGBA tint.
- Replace `border: 1px solid var(--hair)` with its specified RGBA border.
- Set the icon rail background to `transparent`.
- Replace paragraph `color: var(--sub)` with `color: var(--ink2)`.

- [ ] **Step 4: Regenerate the standalone snapshot**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/build-standalone.ps1
```

Expected: `standalone.html` is rebuilt successfully.

- [ ] **Step 5: Verify source and standalone parity**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File design/onboarding-solve-edu/prototype-web.test.ps1
```

Expected: the standalone and GAIN tint assertions pass. Any later pre-existing assertion failure is reported separately.

- [ ] **Step 6: Browser smoke test**

Render `standalone.html` at 1440 by 1000 pixels in headless Chrome and confirm all four cards use readable palette tints with intact alignment.
