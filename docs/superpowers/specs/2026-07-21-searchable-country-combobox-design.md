# Searchable Country Combobox Design

## Scope

Repair the country-selection screen in `design/onboarding-solve-edu/prototype-web.html` by replacing the broken plain input with a searchable, single-select country combobox. Preserve the existing `allCountries` dataset, onboarding navigation, selected-country state, and card-based learning-goal selector.

## Root cause

The country dropdown markup was replaced by a plain `country_input` field, while the JavaScript still expects `country_dropdown`, `country_list`, `country_search`, and related display elements. The replacement input calls an undefined `validateCountry()` function, so typed text cannot render results.

## Interface and behavior

- Render a text input with combobox semantics and a separate dropdown listbox.
- Keep the dropdown closed while the input is empty, including when it first receives focus.
- Open the dropdown after the user types one or more characters.
- Filter case-insensitively by a substring match anywhere in the country name.
- Render each result with its existing flag and country name.
- Display “No countries found” when the query has no matches.
- Mouse click selects a result and closes the dropdown.
- Arrow Down and Arrow Up move the active result, Enter selects it, and Escape closes the dropdown.
- Clicking outside closes the dropdown without changing the current selection.
- After selection, show the selected country and flag in the field and enable Continue.
- Editing or clearing the selected value resets `selectedCountry` and disables Continue until a result is selected again.

## Accessibility

- Use `role="combobox"`, `aria-autocomplete="list"`, `aria-expanded`, and `aria-controls` on the input.
- Use `role="listbox"` on the results container and `role="option"` with `aria-selected` on results.
- Track the keyboard-active option through `aria-activedescendant`.
- Maintain visible keyboard focus and ensure selection never depends on pointer input.

## Boundaries

- Do not change the country dataset or onboarding sequence.
- Do not change the learning-goal card grid.
- Remove the undefined `validateCountry()` call and reconcile obsolete country-dropdown handlers rather than adding a parallel implementation.
- Avoid unrelated restructuring of the self-contained prototype.

## Verification

Automated checks will verify required combobox/listbox markup, hidden-until-typing behavior, filtering, selection reset, keyboard handling, outside-click closure, and removal of `validateCountry()`. A browser-level check will exercise typing, result rendering, keyboard selection, Continue enablement, and the transition to the age screen.
