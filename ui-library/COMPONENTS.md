# ui-library/ component catalogue

Class contracts mirrored from the production repo's `apps/web/components/ui/`. Prototype
markup uses the same classes the React components emit, so
`<button class="btn pri">` renders identically to `<Button variant="pri">`.

**Port on demand.** A component marked `not yet ported` has working CSS but no
behavior. `/design-prototype` must STOP when a PRD calls for one rather than
improvising a lookalike - improvisation is what produced the `--sub` / `--mut`
divergence this library exists to end.

## Typography caveat

The sync that produces `ui-library/tokens.css` and `ui-library/components.css` deliberately
strips the external Google Fonts `@import` that the production stylesheet uses to load
Plus Jakarta Sans, Open Sans, IBM Plex Mono, and Noto Sans Khmer. An external font host
would violate the Artifact CSP and the self-contained-file requirement every prototype
built from this library depends on (`.claude/scripts/check-prototype.ps1` rule 1 rejects
any external `src`/`href`/`@import`). The four `--font-display`, `--font-body`,
`--font-mono`, and `--font-khmer` tokens still *name* those families, so `disp`/`body`/
`mono`/`km`-scoped text renders in whatever the browser falls back to when the named font
isn't installed locally (a system sans/serif/monospace) - not the actual production
typeface. Treat this as approximate typography, not pixel parity with production: font
weights, x-heights, and line-wrap points will differ from what the real app renders. This
is a deliberate trade-off for CSP compliance, not an oversight, and it is not something a
prototype build should try to "fix" by re-adding an external font link.

## Known broken asset reference

`ui-library/components.css`'s `.logo` rule references `background: url("/brand/logo-icon.svg") ...`,
a root-relative path into the production repo's asset pipeline. It does not resolve inside
a prototype (there is no `/brand/` folder to serve it from) and renders as a missing image.
This is a local path, not an external host, so `check-prototype.ps1` rule 1 does not - and
should not - flag it. It is left in place intentionally rather than patched, since
`components.css` is generated and read-only; don't treat the missing logo icon as a bug to
chase when building or auditing a prototype.

| Component | Class contract | Behavior | Status |
|---|---|---|---|
| Accordion | `.accordion-item` > `.accordion-trigger[data-state]`, `.accordion-content[data-state]` | `RndUI.initAccordion` | ported |
| Alert | `.alert` + `alert-info` \| `alert-success` \| `alert-warning` \| `alert-danger` + `.alert-icon`, `.alert-body`, `.alert-title`, `.alert-text` | none | CSS-only |
| AlertDialog | `.dialog-overlay`, `.dialog-panel` (shared with Dialog) + `.alertdialog-actions` | — | not yet ported |
| Avatar | `.avatar` + `avatar-sm` \| `avatar-md` \| `avatar-lg` + `.avatar-img`, `.avatar-fallback` | — | not yet ported |
| Badge | `.badge` + `badge-neutral` \| `badge-info` \| `badge-success` \| `badge-warning` \| `badge-danger` \| `badge-purple` + `.badge-dot` | none | CSS-only |
| Breadcrumb | `.breadcrumb-list` > `.breadcrumb-item`, `.breadcrumb-link`, `.breadcrumb-current`, `.breadcrumb-sep` | none | CSS-only |
| Button | `.btn` + `pri` \| `ghost` \| `dark` \| `subtle` + `block` | none | CSS-only |
| Card | `.card` | none | CSS-only |
| Checkbox | `.checkbox-field` > `.checkbox-root[data-state]`, `.checkbox-indicator`, `.checkbox-label` | — | not yet ported |
| Chip | `.chip` + `.y` \| `.g` \| `.n` \| `.p` \| `.b` | none | CSS-only |
| Command | `.command` > `.command-input-row`, `.command-input-icon`, `.command-input`, `.command-list`, `.command-item[-active\|-disabled]`, `.command-item-group`, `.command-item-label`, `.command-empty` | — | not yet ported |
| Dialog | `.dialog-overlay`, `.dialog-panel`, `.dialog-x` | `RndUI.initDialog` | ported |
| DobPicker | `.input` (no dedicated classes; composed from three date `.input` fields) | — | not yet ported |
| Drawer | `.drawer-overlay`, `.drawer-panel` + `drawer-left` \| `drawer-right` \| `drawer-bottom` + `.drawer-head`, `.drawer-title`, `.drawer-desc`, `.drawer-body` | — | not yet ported |
| EmptyState | `.state-block` > `.state-block-icon`, `.state-block-title`, `.state-block-desc`, `.state-block-actions` | none | CSS-only |
| ErrorState | `.state-block.state-block-danger` (same structure as EmptyState, danger modifier) | none | CSS-only |
| Field | `.field` > `.field-label`, `.field-err`, `.field-help`, `.field-req` | none | CSS-only |
| Hero | `.hero` | none | CSS-only |
| Input | `.input` + `.input.err` | — | not yet ported |
| List | `.list` > `.list-item`, `.list-item-inner`, `.list-item-lead`, `.list-item-main`, `.list-item-title`, `.list-item-desc`, `.list-item-trail` (`.list-item-link` modifier) | none | CSS-only |
| LoadingState | `.loading-state` > `.loading-state-title`, `.loading-state-line` | none | CSS-only |
| Menu | `.menu-content` > `.menu-item[data-highlighted]`, `.menu-item[data-disabled]` | — | not yet ported |
| Pagination | `.pagination` > `.pagination-btn`, `.pagination-on`, `.pagination-gap` | — | not yet ported |
| PasswordInput | `.input` (no dedicated classes; adds a visibility-toggle affordance over Input) | — | not yet ported |
| Popover | `.popover-content`, `.popover-arrow` | — | not yet ported |
| Progress | `.progress[data-state=indeterminate]` > `.progress-fill` | — | not yet ported |
| RadioGroup | `.radio-group` + `radio-group-row` > `.radio-field`, `.radio-item[data-state]`, `.radio-indicator`, `.radio-label` | — | not yet ported |
| Row | `.row` | none | CSS-only |
| Select | `.select-trigger`, `.select-icon`, `.select-content`, `.select-viewport`, `.select-item[data-state\|data-highlighted\|data-disabled]`, `.select-check` | — | not yet ported |
| Sidebar | `.sidebar` > `.sidebar-section`, `.sidebar-section-label`, `.sidebar-section-summary`, `.sidebar-section-chevron`, `.sidebar-links`, `.sidebar-link`, `.sidebar-link-active`, `.sidebar-link-icon`, `.sidebar-link-label`, `.sidebar-link-trail` | none | CSS-only |
| Slider | `.slider-root` > `.slider-track`, `.slider-range`, `.slider-thumb` | — | not yet ported |
| Spinner | `.spinner` + `spinner-sm` \| `spinner-md` \| `spinner-lg` | none | CSS-only |
| Stat | `.stat` > `.n`, `.l`, `.s` | none | CSS-only |
| StrengthMeter | `.track` > `i` (+ `i.gr` fill modifier) | none | CSS-only |
| Switch | `.switch-field` > `.switch-root[data-state]`, `.switch-thumb[data-state]`, `.switch-label` | — | not yet ported |
| Table | `.dtable` > `.dtable-th`, `.dtable-td`, `.dtable-row`, `.dtable-caption`, `.dtable-center`, `.dtable-end`, `.dtable-sort`, `.dtable-sort-arrow`, `.dtable-sticky` | — | not yet ported |
| Tabs | `.tabs` > `.tab[data-state=active]`, `.tab-panel` | `RndUI.initTabs` | ported |
| Text | `.disp` \| `.h1` \| `.h2` \| `.sub` \| `.muted` \| `.eyebrow` \| `.lbl` \| `.mono` (typographic variants) | none | CSS-only |
| Textarea | `.textarea` | none | CSS-only |
| ThemeToggle | `.btn` (no dedicated classes; a labeled toggle button) | — | not yet ported |
| Toast | `.toast-viewport` > `.toast-root`, `.toast-close` | `RndUI.initToast` | ported |
| Tooltip | `.tooltip-content`, `.tooltip-arrow` | — | not yet ported |

## Status counts

- **CSS-only (19):** Alert, Badge, Breadcrumb, Button, Card, Chip, EmptyState, ErrorState,
  Field, Hero, List, LoadingState, Row, Sidebar, Spinner, Stat, StrengthMeter, Text, Textarea.
- **ported (4):** Accordion, Dialog, Tabs, Toast - implemented in `ui-library/behaviors.js`.
- **not yet ported (19):** AlertDialog, Avatar, Checkbox, Command, DobPicker, Drawer, Input,
  Menu, Pagination, PasswordInput, Popover, Progress, RadioGroup, Select, Slider, Switch,
  Table, ThemeToggle, Tooltip.

19 + 4 + 19 = 42, the full component set mirrored from the upstream
`apps/web/components/ui/` folder (44 files on disk: these 42 `.tsx` components plus two
non-component helpers, `cx.ts` and `index.ts`, which get no row here).
