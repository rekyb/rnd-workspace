# Dummy Home Section Design

## 1. Context & Goal
The user completes the onboarding flow (either via organic or program code path) and lands on a dummy home section (`#learning_home`). The goal is to update this section to reflect their onboarding choices, add a side navigation, and provide dummy content reflecting their "quickplay" status.

## 2. Requirements & Behavior
1. **Greetings**: The title should greet the user by name (e.g., "Hi, [Name]!").
2. **Top Navigation Removal**: Hide the existing top navigation (`#onboarding-header` and `#global-header`) when landing on the home section.
3. **Dummy Side Nav**: Introduce a side navigation bar on the left (e.g., Home, Courses, Profile). The layout for the home section will adapt to accommodate this side nav next to the main content area.
4. **Quickplay Course Logic**:
   - **Organic Path**: Show a dummy course directly tied to the user's selected goal (e.g., if "English", show "English for Workplace").
   - **Program Path**: Show the goal-based course PLUS a dummy task list showing program requirements (e.g., "Youth Job Readiness 2026 Tasks: [x] Register, [ ] Complete Module 1"). The program name will be dynamically inserted.

## 3. Implementation Details
### 3.1 HTML/CSS Structural Changes
- **Side Nav Element**: Create a `<aside id="home-sidenav">` that is only visible when `#learning_home` is active.
- **Layout Shift**: When active, the main container or `#learning_home` itself will use a CSS Grid/Flexbox layout to position the side nav on the left and the main dashboard content on the right.
- **Top Nav Hiding**: In `updateHeaders(screenId)`, if `screenId === 'learning_home'`, both `#global-header` and `#onboarding-header` will have `display: none;`.

### 3.2 Dynamic JavaScript Logic
- Create a `renderHomeSection()` function triggered when transitioning to `learning_home`.
- **Greeting**: Fetch `name_input.value`. If empty, use "Learner". Inject into the greeting.
- **Course Mapping**:
  ```javascript
  const courseMap = {
    'english': 'English for Workplace',
    'math': 'Practical Math Skills',
    'workplace': 'Workplace Communication',
    'digital': 'Digital Literacy 101'
  };
  ```
- **Program Task List**: 
  - Conditionally render a task list `<div>` inside `#learning_home` if `entryPath === 'program'`.
  - Fetch the program name (e.g., from a constant or default to "Youth Job Readiness 2026").

## 4. Alternatives Considered
- **Alternative 1 (Chosen)**: A dedicated `renderHomeSection()` JS function that handles DOM injection for the course name and program tasks. Simple and self-contained. Keeps HTML DRY.
- **Alternative 2**: Hardcoding multiple home screen variations in HTML and toggling them. Rejected because it creates too much duplicate HTML and violates DRY principles.

## 5. Next Steps
Review this spec, and once approved, move to implementation by creating an execution plan via the `writing-plans` skill.
