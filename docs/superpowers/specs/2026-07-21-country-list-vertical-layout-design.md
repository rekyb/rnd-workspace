# Country List Vertical Layout Design

## Problem

The global `.select-items div` rule applies `display: flex` to `#country_list`. Because its default flex direction is row, dynamically rendered country options appear side by side instead of vertically.

## Design

- Add a narrowly scoped `#country_list` rule with `display: flex` and `flex-direction: column`.
- Keep every individual option as a horizontal flex row so its flag remains beside its country name.
- Preserve the existing listbox scrolling, filtering, keyboard behavior, selection state, accessibility attributes, and arrow-free combobox.
- Do not alter the shared `.select-items div` rule because language dropdowns also use it.

## Verification

- Add a regression assertion for the vertical `#country_list` layout.
- Run the existing prototype regression suite.
- Use a browser-level check after typing a query to confirm multiple results share the same left position and have increasing top positions.
