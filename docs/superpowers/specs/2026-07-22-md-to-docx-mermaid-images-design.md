# Markdown-to-DOCX Mermaid and Image Embedding Design

## Goal

Extend `.claude/scripts/md_to_docx.py` so Markdown exports automatically:

- render fenced `mermaid` blocks to PNG and embed them in the DOCX; and
- embed supported images referenced with Markdown image syntax.

The converter must remain useful when Mermaid rendering or an image fails: conversion continues with a visible, informative fallback rather than silently dropping content.

## Scope

In scope:

- Fenced Mermaid blocks using ```` ```mermaid ````.
- Local image paths resolved relative to the input Markdown file.
- Standalone and inline Markdown image references.
- Page-width-constrained image sizing with preserved aspect ratio.
- Renderer discovery, temporary-file cleanup, and failure fallbacks.
- Automated regression tests for the new behavior and existing fenced-code behavior.

Out of scope:

- Downloading remote Markdown images.
- Rendering other diagram languages.
- Changing the document's existing typography, table, list, or grayscale styling.
- Editing the source Markdown during conversion.

## Architecture

### Mermaid renderer

Add a small renderer abstraction that accepts Mermaid source and a destination PNG path.

Renderer discovery order:

1. Use `mmdc` when it is available on `PATH`.
2. Otherwise invoke `npx --yes @mermaid-js/mermaid-cli`.
3. If neither succeeds, return a structured failure to the converter.

Each Mermaid block receives its own temporary `.mmd` input and `.png` output inside a temporary directory owned by the conversion run. The renderer uses a white background and a high-resolution width suitable for Word. The temporary directory is removed whether rendering succeeds or fails.

The renderer command is injectable for tests, so tests exercise actual converter behavior without downloading Mermaid CLI or launching Chromium.

### Image embedding

Centralize image resolution and insertion in one helper used by standalone images, inline images, and rendered Mermaid PNGs.

Local image paths are resolved relative to the input Markdown directory. Supported formats are PNG, JPEG, GIF, BMP, and TIFF where the installed `python-docx`/Pillow stack can decode them. Images are centered, preserve aspect ratio, and are constrained to a maximum width of 5.5 inches. Smaller images are not enlarged beyond their natural size when dimensions are available.

Alternative text becomes an italic figure caption using the converter's existing caption styling. Missing, unsupported, remote, or unreadable images produce a visible fallback note containing the alternative text and source path.

### Markdown parsing

Track the fenced-code language when opening a code block:

- `mermaid`: render and embed the resulting PNG.
- Any other language or an unlabelled fence: retain the existing formatted code-block behavior.

Mermaid render failure inserts a warning paragraph followed by the original Mermaid source as a formatted code block. This preserves information and keeps DOCX generation successful.

## Data Flow

1. Read the Markdown source without modifying it.
2. Parse blocks in source order.
3. Resolve Markdown images against the Markdown file's directory and embed or emit a fallback.
4. For each Mermaid block, write temporary source, discover/invoke the renderer, embed the output PNG, and clean temporary files.
5. Preserve non-Mermaid fenced code as formatted text.
6. Save the DOCX only after all blocks have been processed.

## Error Handling

- Missing local image: visible fallback note; conversion continues.
- Remote image URL: visible fallback note; no network fetch.
- Unsupported or corrupt image: visible fallback note; conversion continues.
- Mermaid CLI unavailable: warning plus original Mermaid code.
- Mermaid renderer returns non-zero or produces no PNG: warning plus original Mermaid code.
- Temporary-file cleanup runs in `finally`/temporary-directory context handling.
- Output-save errors remain fatal and propagate to the caller.

## Testing Strategy

Use Python's standard `unittest` framework and temporary directories. Inspect the generated DOCX as an OOXML ZIP package to verify media entries, drawing elements, captions, and fallback text.

Tests:

1. A local PNG referenced from Markdown is embedded in `word/media`.
2. A missing image emits a visible fallback note.
3. A Mermaid block embeds a PNG when an injected fake renderer succeeds.
4. A Mermaid renderer failure emits a warning and preserves the original source as code.
5. An ordinary fenced code block remains text and does not invoke Mermaid rendering.
6. Temporary Mermaid inputs and outputs are removed after success and failure.
7. Image sizing does not exceed the configured page-width maximum and preserves the source aspect ratio.

Development follows red-green-refactor: add each failing test before the production change that satisfies it, run the focused test, then run the complete converter test suite.

## Compatibility

The command-line interface remains:

```text
python md_to_docx.py INPUT.md [OUTPUT.docx]
```

Existing Markdown without Mermaid or images produces the same document structure and styling. The first `npx` fallback may download Mermaid CLI and its browser dependency; subsequent runs can use the npm cache. Users who require offline conversion can install `mmdc` beforehand or accept the code-block fallback.

## Acceptance Criteria

- Converting `SPEC-5.md` directly embeds both Mermaid diagrams without preprocessing the Markdown.
- Local Markdown images are embedded at their source positions with captions.
- Missing images and Mermaid failures remain visible and do not abort otherwise valid conversion.
- No temporary Mermaid artifacts remain after conversion.
- Existing non-Mermaid fenced code behavior is preserved.
- All automated tests pass without requiring network access.
