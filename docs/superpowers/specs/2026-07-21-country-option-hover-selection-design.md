# Country Option Hover and Selection Design

## Problem

The global `.select-items div:hover` selector also matches the `#country_list` container. Hovering any nested option therefore applies a background to both the option and its parent, making the whole list appear hovered. Country option styling also does not clearly separate pointer hover from the keyboard-active selection state.

## Design

- Assign every rendered country result the dedicated `.country-option` class.
- Reset interactive container styling on `#country_list`: no padding, no hover background, default cursor, and no inherited gap.
- Apply hover background only to `.country-option:hover`.
- Apply the active highlight only to `.country-option[aria-selected="true"]`.
- Keep exactly one keyboard-active option selected and all other options transparent.
- Preserve the vertical list, horizontal flag/name layout, mouse selection, keyboard navigation, filtering, ARIA behavior, scrolling, arrow-free combobox, and goal cards.
- Do not change the shared dropdown rule because language dropdowns depend on it.

## Verification

- Regression checks will require the dedicated option class and scoped hover/selected selectors.
- Browser verification will type a query with multiple results and confirm that hovering one option changes only that option, then keyboard navigation highlights exactly one option.
