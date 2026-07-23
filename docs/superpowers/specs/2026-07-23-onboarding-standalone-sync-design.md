# Onboarding Standalone Synchronization Design

## Goal

Update `design/onboarding-solve-edu/standalone.html` so it is an exact,
self-contained snapshot of the current modular onboarding prototype in
`prototype-web.html`, `styles.css`, `data.js`, and `main.js`.

## Scope

- Preserve the document structure and body markup from `prototype-web.html`.
- Replace the local `styles.css` link with the complete stylesheet in an inline
  `<style>` element.
- Replace the local `data.js` and `main.js` script references with inline
  scripts in the same order.
- Convert local image references used by the snapshot into data URLs so the
  result works without neighboring project files.
- Preserve external Google Fonts and Material Symbols references. Fonts are not
  required to be embedded as part of this synchronization.
- Do not introduce new layout, copy, interaction, or data changes.

## Assembly Approach

Rebuild the standalone file from the current modular sources instead of
manually patching the existing generated artifact. The transformation will be
deterministic:

1. Read `prototype-web.html`.
2. Inline the exact contents of `styles.css`.
3. Inline `data.js`, then `main.js`.
4. Resolve local image paths and replace them with MIME-appropriate base64 data
   URLs.
5. Write the result to `standalone.html`.

This avoids stale markup, CSS, or JavaScript surviving from an earlier
standalone build.

## Verification

- Run `prototype-web.test.ps1` to verify the shared prototype requirements.
- Confirm `standalone.html` contains no references to local `.css` or `.js`
  files.
- Confirm local image paths have been embedded.
- Compare key markup, CSS, data, and behavior-bearing JavaScript content against
  their source files.
- Perform a browser smoke check when the available environment supports it.

## Constraints

- Existing unrelated working-tree changes must remain untouched.
- The output may remain large because raster assets are embedded.
- External font availability can affect typography when fully offline, but the
  page structure, content, images, and interactions remain self-contained.
