# Learning Goal Card Grid Design

## Scope

Replace the learning-goal dropdown in `design/onboarding-solve-edu/prototype-web.html` with six always-visible, single-select cards. Preserve the existing goal data, selected-goal state, Continue-button behavior, and navigation to `save_wall`.

## Interface

- Render the six entries in `goalOptions` as a grid.
- Use three columns and two rows on desktop, two columns on tablet and mobile, and one column on very narrow screens.
- Each card shows the goal's existing Material Symbol icon and title.
- Reuse the prototype's visual language for option cards while adding goal-specific grid styles.
- A selected card has an unambiguous highlighted state. Hover and keyboard-focus states remain distinct and visible.

## Interaction and accessibility

- The grid behaves as a single-select choice group.
- Each card is a native button with `aria-pressed` reflecting selection.
- Selecting a card updates `selectedGoal`, clears the previous visual and accessibility state, and enables the global Continue button.
- The existing `continueFromGoal()` behavior remains unchanged.
- The dropdown, search field, filtering behavior, and their event handlers are removed because all six choices are visible.

## Responsive behavior

- Default: three equal-width columns.
- At widths up to 768 px: two equal-width columns.
- At widths up to 420 px: one column.
- Card text may wrap without truncation and cards retain a comfortable pointer target.

## Verification

Automated checks will confirm that the HTML contains six goal-card buttons, the responsive column rules, accessible pressed-state handling, and no obsolete goal-dropdown markup or handlers. A browser render will verify layout and selection behavior at desktop and narrow viewport sizes.
