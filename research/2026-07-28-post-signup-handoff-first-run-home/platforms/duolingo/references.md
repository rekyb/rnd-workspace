# References — Duolingo (Mobbin-sourced)

Two web flows. Mobbin's flow search returns a flow-level `mobbin_url` plus per-screen
UUIDs rather than per-screen URLs, so the URL column carries the flow link and the
position is given alongside the screen ID — that pair is what makes a citation
recoverable.

Images are `.webp` because that is what the Mobbin endpoint serves; the extension is
accurate to the bytes rather than to the example in the sourcing standard.

**Flow A — "Creating a profile"** (8 screens) · https://mobbin.com/flows/65ea5f1c-ba09-44ae-9a88-1b4f9a5778e4
**Flow B — "Joining a classroom"** (5 screens) · https://mobbin.com/flows/a5ac043e-d231-4f6e-a113-8b51e4151fb4

| # | Screen | Mobbin URL | Screen ID | Local file | Accessed |
|---|---|---|---|---|---|
| 01 | Deferred registration wall — "Time to create a profile!" (Flow A, pos 1) | https://mobbin.com/flows/65ea5f1c-ba09-44ae-9a88-1b4f9a5778e4 | 2c199207-c454-4696-8261-de0b2023d834 | reference/01-deferred-profile-wall.webp | 2026-07-28 |
| 02 | Age gate — "How old are you?", value entered, Next enabled (Flow A, pos 3) | https://mobbin.com/flows/65ea5f1c-ba09-44ae-9a88-1b4f9a5778e4 | 57c594ec-62ed-4f42-b82a-8b24654f17af | reference/02-age-gate.webp | 2026-07-28 |
| 03 | Create-profile form — Name (optional), Email, Password (Flow A, pos 4) | https://mobbin.com/flows/65ea5f1c-ba09-44ae-9a88-1b4f9a5778e4 | 32f5ca15-02e1-4d72-80c7-3c75cb98bc4a | reference/03-create-profile-form.webp | 2026-07-28 |
| 04 | Create-account button in submitting state (Flow A, pos 7) | https://mobbin.com/flows/65ea5f1c-ba09-44ae-9a88-1b4f9a5778e4 | 44a4abcf-a84e-4792-b196-70aa6d257f99 | reference/04-create-account-submitting.webp | 2026-07-28 |
| 05 | Terminal home — **progressed account, not a zero state** (Flow A, pos 8) | https://mobbin.com/flows/65ea5f1c-ba09-44ae-9a88-1b4f9a5778e4 | 417702d1-de43-4d60-976e-34139e82c473 | reference/05-home-progressed-not-zero-state.webp | 2026-07-28 |
| 06 | Class-code entry, empty, Submit disabled (Flow B, pos 1) | https://mobbin.com/flows/a5ac043e-d231-4f6e-a113-8b51e4151fb4 | 22d37e27-0fa3-4a69-9b07-44d0c1cf5ad8 | reference/06-classroom-code-empty.webp | 2026-07-28 |
| 07 | Class-code invalid — error shown, entered code preserved (Flow B, pos 3) | https://mobbin.com/flows/a5ac043e-d231-4f6e-a113-8b51e4151fb4 | 50ccbee8-ad74-4088-ad9a-bb3cc1ac4603 | reference/07-classroom-code-error.webp | 2026-07-28 |
| 08 | Join-confirmation modal naming teacher, class, and teacher permissions (Flow B, pos 5) | https://mobbin.com/flows/a5ac043e-d231-4f6e-a113-8b51e4151fb4 | aef1aba3-60e0-4a94-a3ad-a543b01d20f1 | reference/08-classroom-join-confirm.webp | 2026-07-28 |

## Not downloaded

Flow A positions 2, 5, and 6 are intermediate states of screens already captured (empty
age field; partially-filled profile form). Flow B positions 2 and 4 are the
code-typed-but-not-yet-submitted states of 06 and 08. Excluded under the plan's 8-screen
per-platform ceiling; nothing they show is absent from the eight above.

## Staged demo data

These are Mobbin's staged capture accounts, not real learners. The profile screens carry a
placeholder name and a `@mobbin.com` address, and the join modal names a fictional teacher.
Committed prose in `flow.md` and `notes.md` genericises the person name to `[Teacher]`
while quoting the surrounding copy verbatim, so no finding depends on reproducing it.
