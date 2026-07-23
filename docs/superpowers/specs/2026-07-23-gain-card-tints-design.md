# GAIN Card Tint Design

## Goal

Give each GAIN card in the onboarding landing page a full, light-tinted
background based on its assigned palette color.

## Visual Treatment

- Gamification uses a light blue background derived from `--blue`.
- AI Coach uses a light magenta background derived from `--magenta`.
- Incentives uses a light purple background derived from `--purple`.
- Network uses a light red background derived from `--red`.
- Each card uses one uniform tint across both the icon and content areas.
- Icons and headings retain their saturated palette colors.
- Body copy uses `--ink2` for readable dark text.
- Borders use a translucent version of the corresponding palette color.

## Scope

Only the four GAIN cards change. Their markup, content, layout, spacing, and
responsive behavior remain unchanged. After updating `prototype-web.html`, the
standalone artifact is regenerated with `build-standalone.ps1`.

## Verification

- Each card has the intended palette-derived background and border.
- No GAIN card retains the neutral `--bg` background.
- Body copy remains dark.
- `standalone.html` contains the same updated card markup.
- A browser render confirms the four cards remain readable and aligned.
