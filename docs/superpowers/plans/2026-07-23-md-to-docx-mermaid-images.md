# Markdown-to-DOCX Mermaid and Image Embedding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `.claude/scripts/md_to_docx.py` automatically render Mermaid fences to embedded PNGs and reliably embed supported local Markdown images.

**Architecture:** Keep the converter in one module, but separate image insertion, Mermaid command discovery/execution, and fenced-block flushing into independently testable functions. Conversion owns one temporary directory per run; Mermaid failures preserve the original source as formatted code and add a visible warning.

**Tech Stack:** Python 3, `python-docx`, Pillow-compatible image handling through `python-docx`, standard-library `unittest`, `tempfile`, `subprocess`, `shutil`, and OOXML ZIP inspection.

## Global Constraints

- Keep the CLI compatible: `python md_to_docx.py INPUT.md [OUTPUT.docx]`.
- Resolve local images relative to the input Markdown directory.
- Do not download remote Markdown images.
- Discover Mermaid renderers in this order: `mmdc`, then `npx --yes @mermaid-js/mermaid-cli`.
- Mermaid and image failures must remain visible without aborting an otherwise valid conversion.
- Preserve ordinary fenced code blocks as formatted code.
- Center embedded images, preserve aspect ratio, and never exceed 5.5 inches width.
- Delete all temporary Mermaid inputs and outputs after success or failure.
- Automated tests must not require network access or a real Mermaid/Chromium installation.

---

## File Structure

- Modify `.claude/scripts/md_to_docx.py`: image resolution/insertion, Mermaid rendering, fenced-block dispatch, CLI documentation.
- Create `.claude/scripts/test_md_to_docx.py`: isolated unit and integration tests using temporary Markdown, images, renderer stubs, and DOCX ZIP inspection.

### Task 1: Reliable Local Image Embedding

**Files:**
- Modify: `.claude/scripts/md_to_docx.py`
- Create: `.claude/scripts/test_md_to_docx.py`

**Interfaces:**
- Produces: `embed_image(doc, paragraph, image_ref, alt_text, md_parent_dir, max_width_inches=5.5) -> bool`.
- Produces: `add_image_fallback(paragraph, alt_text, image_ref, reason=None) -> None`.
- Existing `add_inline(...)` consumes `embed_image(...)` for standalone and inline Markdown images.

- [ ] **Step 1: Write failing tests for local image embedding and fallback**

Create `.claude/scripts/test_md_to_docx.py` with imports, OOXML helpers, and the first tests:

```python
import importlib.util
import tempfile
import unittest
import zipfile
from pathlib import Path

from docx import Document
from PIL import Image

SCRIPT = Path(__file__).with_name("md_to_docx.py")
SPEC = importlib.util.spec_from_file_location("md_to_docx", SCRIPT)
md_to_docx = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(md_to_docx)


def document_xml(docx_path):
    with zipfile.ZipFile(docx_path) as archive:
        return archive.read("word/document.xml").decode("utf-8")


def media_entries(docx_path):
    with zipfile.ZipFile(docx_path) as archive:
        return [name for name in archive.namelist() if name.startswith("word/media/")]


class MarkdownToDocxTests(unittest.TestCase):
    def test_embeds_local_png_and_caption(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            Image.new("RGB", (1200, 600), "white").save(root / "diagram.png")
            (root / "input.md").write_text(
                "Before\n\n![Architecture](diagram.png)\n\nAfter\n",
                encoding="utf-8",
            )

            md_to_docx.convert(root / "input.md", root / "output.docx")

            xml = document_xml(root / "output.docx")
            self.assertEqual(len(media_entries(root / "output.docx")), 1)
            self.assertIn("Figure: Architecture", xml)
            self.assertEqual(xml.count("<w:drawing>"), 1)

    def test_missing_image_emits_visible_fallback(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "input.md").write_text(
                "![Missing evidence](missing.png)\n", encoding="utf-8"
            )

            md_to_docx.convert(root / "input.md", root / "output.docx")

            xml = document_xml(root / "output.docx")
            self.assertEqual(media_entries(root / "output.docx"), [])
            self.assertIn("Missing evidence", xml)
            self.assertIn("missing.png", xml)

    def test_remote_image_is_not_downloaded(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "input.md").write_text(
                "![Remote](https://example.com/image.png)\n", encoding="utf-8"
            )

            md_to_docx.convert(root / "input.md", root / "output.docx")

            xml = document_xml(root / "output.docx")
            self.assertEqual(media_entries(root / "output.docx"), [])
            self.assertIn("Remote", xml)
            self.assertIn("https://example.com/image.png", xml)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run tests and verify the sizing/format support test fails for the missing new helper**

Add this test before running, so RED targets the desired API rather than behavior the existing converter already partially supports:

```python
    def test_embed_image_preserves_small_natural_width(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            image_path = root / "small.png"
            Image.new("RGB", (96, 48), "white").save(image_path, dpi=(96, 96))
            doc = Document()
            paragraph = doc.add_paragraph()

            embedded = md_to_docx.embed_image(
                doc, paragraph, "small.png", "Small", root
            )

            self.assertTrue(embedded)
            self.assertEqual(len(doc.inline_shapes), 1)
            self.assertAlmostEqual(doc.inline_shapes[0].width.inches, 1.0, places=1)
            self.assertAlmostEqual(doc.inline_shapes[0].height.inches, 0.5, places=1)
```

Run:

```powershell
python -m unittest .claude.scripts.test_md_to_docx.MarkdownToDocxTests.test_embed_image_preserves_small_natural_width -v
```

Expected: ERROR with `AttributeError: module 'md_to_docx' has no attribute 'embed_image'`.

- [ ] **Step 3: Implement image resolution, supported formats, sizing, and fallback**

In `.claude/scripts/md_to_docx.py`, import URL parsing and add constants/helpers:

```python
from urllib.parse import urlparse

SUPPORTED_IMAGE_SUFFIXES = {".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tif", ".tiff"}
MAX_IMAGE_WIDTH_INCHES = 5.5


def add_image_fallback(paragraph, alt_text, image_ref, reason=None):
    label = alt_text or image_ref
    detail = f"; {reason}" if reason else ""
    run = paragraph.add_run(f"[Image unavailable: {label} ({image_ref}){detail}]")
    run.italic = True
    run.font.color.rgb = MUTED_INK


def embed_image(
    doc, paragraph, image_ref, alt_text, md_parent_dir,
    max_width_inches=MAX_IMAGE_WIDTH_INCHES,
):
    parsed = urlparse(image_ref)
    if parsed.scheme or parsed.netloc:
        add_image_fallback(paragraph, alt_text, image_ref, "remote images are not fetched")
        return False

    image_path = (Path(md_parent_dir) / image_ref).resolve()
    if not image_path.is_file():
        add_image_fallback(paragraph, alt_text, image_ref, "file not found")
        return False
    if image_path.suffix.lower() not in SUPPORTED_IMAGE_SUFFIXES:
        add_image_fallback(paragraph, alt_text, image_ref, "unsupported format")
        return False

    try:
        from PIL import Image
        with Image.open(image_path) as source:
            dpi_x = (source.info.get("dpi") or (96, 96))[0] or 96
            natural_width = source.width / dpi_x
        width = Inches(min(natural_width, max_width_inches))
        image_paragraph = doc.add_paragraph()
        image_paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
        image_paragraph.add_run().add_picture(str(image_path), width=width)
        if alt_text:
            caption = doc.add_paragraph()
            caption.alignment = WD_ALIGN_PARAGRAPH.CENTER
            run = caption.add_run(f"Figure: {alt_text}")
            run.italic = True
            run.font.size = Pt(CAPTION_SIZE)
            run.font.color.rgb = MUTED_INK
        return True
    except Exception as exc:
        add_image_fallback(paragraph, alt_text, image_ref, f"cannot decode image: {exc}")
        return False
```

Update the image branch in `add_inline(...)` to call `embed_image(...)` and remove the previous PNG/JPEG-only insertion logic.

- [ ] **Step 4: Run the image tests and verify green**

Run:

```powershell
python -m unittest .claude.scripts.test_md_to_docx.MarkdownToDocxTests.test_embed_image_preserves_small_natural_width .claude.scripts.test_md_to_docx.MarkdownToDocxTests.test_embeds_local_png_and_caption .claude.scripts.test_md_to_docx.MarkdownToDocxTests.test_missing_image_emits_visible_fallback .claude.scripts.test_md_to_docx.MarkdownToDocxTests.test_remote_image_is_not_downloaded -v
```

Expected: four tests PASS; no network calls or warnings.

- [ ] **Step 5: Commit the image embedding unit**

```powershell
git add -- .claude/scripts/md_to_docx.py .claude/scripts/test_md_to_docx.py
git commit -m "feat: embed local markdown images in docx"
```

### Task 2: Mermaid Renderer and Failure-Safe Embedding

**Files:**
- Modify: `.claude/scripts/md_to_docx.py`
- Modify: `.claude/scripts/test_md_to_docx.py`

**Interfaces:**
- Produces: `find_mermaid_command() -> list[str] | None`.
- Produces: `render_mermaid(source, output_path, runner=subprocess.run) -> tuple[bool, str | None]`.
- Produces: `add_code_block(doc, source) -> None`.
- Task 3 consumes `render_mermaid(...)` and `add_code_block(...)` while flushing fenced blocks.

- [ ] **Step 1: Write failing tests for command discovery and successful rendering**

Add:

```python
from unittest.mock import patch


    @patch.object(md_to_docx.shutil, "which")
    def test_mermaid_command_prefers_mmdc_then_npx(self, which):
        which.side_effect = lambda name: {"mmdc": None, "npx": "C:/node/npx.cmd"}.get(name)

        command = md_to_docx.find_mermaid_command()

        self.assertEqual(
            command,
            ["C:/node/npx.cmd", "--yes", "@mermaid-js/mermaid-cli"],
        )
        self.assertEqual(which.call_args_list[0].args, ("mmdc",))

    def test_render_mermaid_invokes_renderer_and_requires_png(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "diagram.png"
            calls = []

            def fake_runner(command, **kwargs):
                calls.append((command, kwargs))
                output.write_bytes(b"fake-png")
                return type("Result", (), {"returncode": 0, "stderr": ""})()

            with patch.object(md_to_docx, "find_mermaid_command", return_value=["mmdc"]):
                ok, error = md_to_docx.render_mermaid(
                    "flowchart TD\nA-->B", output, runner=fake_runner
                )

            self.assertTrue(ok)
            self.assertIsNone(error)
            self.assertIn("-i", calls[0][0])
            self.assertIn("-o", calls[0][0])
            self.assertEqual(calls[0][1]["check"], False)
```

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```powershell
python -m unittest .claude.scripts.test_md_to_docx.MarkdownToDocxTests.test_mermaid_command_prefers_mmdc_then_npx -v
```

Expected: ERROR because `shutil` or `find_mermaid_command` is not defined by the converter.

- [ ] **Step 3: Implement renderer discovery and execution**

Add imports and helpers:

```python
import shutil
import subprocess


def find_mermaid_command():
    mmdc = shutil.which("mmdc")
    if mmdc:
        return [mmdc]
    npx = shutil.which("npx")
    if npx:
        return [npx, "--yes", "@mermaid-js/mermaid-cli"]
    return None


def render_mermaid(source, output_path, runner=subprocess.run):
    command = find_mermaid_command()
    if not command:
        return False, "Mermaid CLI unavailable: install mmdc or npx"

    output_path = Path(output_path)
    source_path = output_path.with_suffix(".mmd")
    source_path.write_text(source, encoding="utf-8")
    result = runner(
        command + [
            "-i", str(source_path),
            "-o", str(output_path),
            "-b", "white",
            "-w", "1800",
            "-s", "2",
        ],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return False, (result.stderr or "Mermaid renderer failed").strip()
    if not output_path.is_file() or output_path.stat().st_size == 0:
        return False, "Mermaid renderer produced no PNG"
    return True, None


def add_code_block(doc, source):
    paragraph = doc.add_paragraph()
    run = paragraph.add_run(source)
    run.font.name = MONO_FONT
    run.font.size = Pt(CODE_SIZE)
```

- [ ] **Step 4: Add and run renderer failure tests**

Add:

```python
    def test_render_mermaid_reports_missing_output(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "diagram.png"

            def fake_runner(command, **kwargs):
                return type("Result", (), {"returncode": 0, "stderr": ""})()

            with patch.object(md_to_docx, "find_mermaid_command", return_value=["mmdc"]):
                ok, error = md_to_docx.render_mermaid("flowchart TD\nA-->B", output, fake_runner)

            self.assertFalse(ok)
            self.assertEqual(error, "Mermaid renderer produced no PNG")
```

Run:

```powershell
python -m unittest .claude.scripts.test_md_to_docx.MarkdownToDocxTests.test_mermaid_command_prefers_mmdc_then_npx .claude.scripts.test_md_to_docx.MarkdownToDocxTests.test_render_mermaid_invokes_renderer_and_requires_png .claude.scripts.test_md_to_docx.MarkdownToDocxTests.test_render_mermaid_reports_missing_output -v
```

Expected: three tests PASS.

- [ ] **Step 5: Commit the renderer unit**

```powershell
git add -- .claude/scripts/md_to_docx.py .claude/scripts/test_md_to_docx.py
git commit -m "feat: add mermaid renderer discovery"
```

### Task 3: Fenced-Block Integration, Cleanup, and End-to-End Verification

**Files:**
- Modify: `.claude/scripts/md_to_docx.py`
- Modify: `.claude/scripts/test_md_to_docx.py`

**Interfaces:**
- Modify: `convert(md_path, docx_path, mermaid_renderer=render_mermaid) -> Path`.
- Conversion passes each Mermaid source and a temporary PNG path to `mermaid_renderer(source, output_path)`.
- Non-Mermaid fences call `add_code_block(doc, source)` unchanged.

- [ ] **Step 1: Write failing integration tests for Mermaid embedding, fallback, ordinary code, and cleanup**

Add:

```python
    def test_convert_embeds_mermaid_png_and_removes_code(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "input.md").write_text(
                "# Flow\n\n```mermaid\nflowchart TD\nA-->B\n```\n",
                encoding="utf-8",
            )
            seen_outputs = []

            def fake_renderer(source, output_path):
                self.assertIn("flowchart TD", source)
                seen_outputs.append(Path(output_path))
                Image.new("RGB", (800, 400), "white").save(output_path)
                return True, None

            md_to_docx.convert(
                root / "input.md", root / "output.docx", mermaid_renderer=fake_renderer
            )

            xml = document_xml(root / "output.docx")
            self.assertEqual(len(media_entries(root / "output.docx")), 1)
            self.assertNotIn("flowchart TD", xml)
            self.assertTrue(seen_outputs)
            self.assertTrue(all(not path.exists() for path in seen_outputs))

    def test_mermaid_failure_preserves_source_and_warning(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "input.md").write_text(
                "```mermaid\nflowchart TD\nA-->B\n```\n", encoding="utf-8"
            )

            md_to_docx.convert(
                root / "input.md",
                root / "output.docx",
                mermaid_renderer=lambda source, output: (False, "renderer unavailable"),
            )

            xml = document_xml(root / "output.docx")
            self.assertIn("Mermaid diagram could not be rendered", xml)
            self.assertIn("renderer unavailable", xml)
            self.assertIn("flowchart TD", xml)

    def test_non_mermaid_fence_remains_code(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "input.md").write_text(
                "```python\nprint('hello')\n```\n", encoding="utf-8"
            )

            md_to_docx.convert(root / "input.md", root / "output.docx")

            xml = document_xml(root / "output.docx")
            self.assertIn("print('hello')", xml)
            self.assertEqual(media_entries(root / "output.docx"), [])
```

- [ ] **Step 2: Run the Mermaid integration test and verify RED**

Run:

```powershell
python -m unittest .claude.scripts.test_md_to_docx.MarkdownToDocxTests.test_convert_embeds_mermaid_png_and_removes_code -v
```

Expected: ERROR because `convert()` does not accept `mermaid_renderer`.

- [ ] **Step 3: Implement fenced-language tracking and temporary-directory ownership**

Update `convert(...)` to accept the renderer, create one temporary directory, capture the fence language, and flush blocks through a helper:

```python
import tempfile


def flush_code_block(doc, language, source, md_parent_dir, temp_dir, index, mermaid_renderer):
    if language.lower() != "mermaid":
        add_code_block(doc, source)
        return

    output_path = Path(temp_dir) / f"mermaid-{index}.png"
    ok, error = mermaid_renderer(source, output_path)
    if ok:
        placeholder = doc.add_paragraph()
        embed_image(doc, placeholder, str(output_path), "Mermaid diagram", md_parent_dir)
        if not placeholder.text.strip():
            placeholder._element.getparent().remove(placeholder._element)
        return

    warning = doc.add_paragraph()
    run = warning.add_run(
        f"Mermaid diagram could not be rendered: {error or 'unknown error'}"
    )
    run.italic = True
    run.font.color.rgb = MUTED_INK
    add_code_block(doc, source)


def convert(md_path, docx_path, mermaid_renderer=render_mermaid):
    # Existing initialization remains.
    # Wrap the parsing loop in `with tempfile.TemporaryDirectory() as temp_dir:`.
    # On opening a fence, capture language from `^\s*```\s*([^\s`]*)`.
    # On closing a fence, call `flush_code_block(...)` with `"\n".join(code_buf)`.
    # Increment a Mermaid block index after every flushed block.
    # Keep table flushing and all non-code parsing behavior unchanged.
```

When embedding a temporary Mermaid output, pass the absolute output path through a dedicated `embed_image_path(...)` helper or teach `embed_image(...)` to accept absolute paths safely; do not concatenate an absolute path under `md_parent_dir`.

- [ ] **Step 4: Run all converter tests and verify green**

Run:

```powershell
python -m unittest .claude.scripts.test_md_to_docx -v
```

Expected: all tests PASS with no network access and no residual temporary files.

- [ ] **Step 5: Run a real end-to-end conversion of SPEC-5**

Run:

```powershell
python .claude/scripts/md_to_docx.py research/2026-07-20-unified-onboarding-synthesis-and-patterns/SPEC-5.md research/2026-07-20-unified-onboarding-synthesis-and-patterns/SPEC-5-auto.docx
```

Expected: exit code 0 and the output path printed. The first run may use `npx` and download Mermaid CLI if `mmdc` is absent.

Inspect the output package:

```powershell
$docx='research\2026-07-20-unified-onboarding-synthesis-and-patterns\SPEC-5-auto.docx'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip=[System.IO.Compression.ZipFile]::OpenRead((Resolve-Path $docx))
try {
  $media=@($zip.Entries | Where-Object FullName -Like 'word/media/*')
  $entry=$zip.GetEntry('word/document.xml')
  $reader=[System.IO.StreamReader]::new($entry.Open())
  try { $xml=$reader.ReadToEnd() } finally { $reader.Dispose() }
  [pscustomobject]@{
    MediaFiles=$media.Count
    Drawings=([regex]::Matches($xml,'<w:drawing>').Count)
    MermaidCodePresent=$xml.Contains('flowchart TD')
  }
} finally { $zip.Dispose() }
```

Expected: `MediaFiles` and `Drawings` are at least 2; `MermaidCodePresent` is `False`.

- [ ] **Step 6: Update module documentation and run syntax validation**

Update the module docstring to state:

```text
- local Markdown images (PNG, JPEG, GIF, BMP, TIFF) embedded relative to the source file
- fenced Mermaid diagrams rendered through mmdc or npx and embedded as PNG
- visible fallbacks for missing images and Mermaid rendering failures
```

Run:

```powershell
python -m py_compile .claude/scripts/md_to_docx.py .claude/scripts/test_md_to_docx.py
python -m unittest .claude.scripts.test_md_to_docx -v
```

Expected: compilation exits 0; all tests PASS.

- [ ] **Step 7: Commit the integrated converter**

```powershell
git add -- .claude/scripts/md_to_docx.py .claude/scripts/test_md_to_docx.py
git commit -m "feat: render mermaid diagrams in docx exports"
```

## Final Verification

- [ ] Run `python -m unittest .claude.scripts.test_md_to_docx -v` and confirm zero failures/errors.
- [ ] Run `python -m py_compile .claude/scripts/md_to_docx.py .claude/scripts/test_md_to_docx.py` and confirm exit code 0.
- [ ] Convert `SPEC-5.md` to `SPEC-5-auto.docx` and confirm the OOXML package contains embedded media and no Mermaid source text.
- [ ] Run `git diff --check` and confirm no whitespace errors in the converter or tests.
- [ ] Review `git status --short` and ensure only intentional converter/test/output changes are present.
