# Solve Education! - Onboarding Prototype Refactor

## Objective
Refactor the current single-file `prototype-web.html` into a modular, responsive, and robust vanilla web application. The primary goals are to fix visual layout breakage on larger desktop screens and mobile devices, and to resolve JavaScript errors caused by missing function declarations and undefined state variables.

## Architecture & File Structure
We will adopt a modular Vanilla Web Stack:
- **`index.html`**: Clean DOM structure without inline styling or inline event handlers.
- **`styles.css`**: Centralized stylesheet utilizing CSS Variables for the design system.
- **`data.js`**: Data models, specifically housing the large `allCountries` array and `goalOptions` configuration.
- **`main.js`**: Core application logic, event listeners, and state management.

## Responsive Design Requirements
- **Mobile-First Paradigm**: Base styles target small screens, leveraging `@media (min-width: 768px)` and `@media (min-width: 1024px)` for scaling up.
- **Layout Engines**: Use CSS Grid for robust layout structures (e.g., goal grids, split-screen zigzag rows) and Flexbox for linear alignment (headers, button groups).
- **Large Screen Constraints**: Enforce `max-width` (e.g., 1200px) on main layout containers to prevent content from stretching inappropriately on ultra-wide monitors.

## JavaScript & Interactivity Requirements
- **Centralized State**: Implement an `appState` object to track user progress and selections (e.g., `entryPath`, `selectedGoal`, `selectedAgeCategory`) to prevent undefined variable errors.
- **Event Delegation & Binding**: Replace all inline HTML `onclick="..."` attributes with programmatic `addEventListener` attachments in `main.js`.
- **Navigation Flow**: Implement the missing core navigation functions (`startOrganic()`, `startProgram()`, `goTo()`, `openSignInModal()`) to toggle the `.active` classes on appropriate `.card` containers, simulating the onboarding flow accurately.
- **Dropdown Logic**: Decouple the country dropdown search logic from the HTML to be purely driven by JavaScript and the newly separated `data.js`.

## Definition of Done (DoD)
- The application renders beautifully across Mobile, Tablet, and Desktop resolutions without layout breakage.
- Clicking through the onboarding flow produces no "undefined function/variable" errors in the console.
- The project is successfully split into `index.html`, `styles.css`, `main.js`, and `data.js`.
