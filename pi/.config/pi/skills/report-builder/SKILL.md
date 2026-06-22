---
name: report-builder
description: Build a full report, optionally from a model.docx template. Extracts the document structure (headings, sections, tables) and guides the agent to produce a complete, well-written report. Works with or without a template. Use when the user asks for a report, with or without a .docx model.
---

# Report Builder

Generates a complete report, optionally based on a `.docx` template. Works in two modes:
- **With model.docx** — inherits header, footer, fonts, styles, and brand colors from the template
- **Without model.docx** — produces a clean standalone `.docx` with sensible default styling

## Setup (run once)

Install dependencies for the extraction script:

```bash
cd ~/.pi/agent/skills/report-builder/scripts && npm install
```

## Workflow

### 1 — Check for a template (optional)

If the user provided a `model.docx`, extract its structure:

```bash
node ~/.pi/agent/skills/report-builder/scripts/extract-template.js <path/to/model.docx>
```

This outputs a JSON object with:
- `headings` — all heading levels found in the document
- `sections` — each section with its heading and any placeholder/sample content
- `tables` — table count, rows, estimated columns
- `rawText` — full raw text for context

If **no model.docx was provided**, skip this step entirely and proceed directly to gathering content.

### 2 — Understand the template (if provided)

If a template was provided, parse the JSON output and identify:
- All section headings and their hierarchy
- Any placeholder text, brackets `[like this]`, or instructions embedded in the template
- Table structures that need to be populated
- The overall document purpose and audience (infer from section names and preamble)

If **no template**, infer a sensible structure from the report subject and content type.

### 3 — Gather content from the user

Before writing, ask the user for any information that is missing and cannot be inferred:
- What is the subject / topic of this report?
- What data, facts, or findings should populate each section?
- Any specific tone, length requirements, or audience?
- Are there tables that need real data?

Do **not** ask for information that can be inferred from the template itself.

### 4 — Write the full report

Produce the complete report in **Markdown** by default (easy to copy, convert, or paste). Structure it to mirror the template exactly:
- Reproduce every heading at the correct level (`#`, `##`, `###`)
- Fill every section with real, substantive content — no placeholders
- Populate all tables with actual data in Markdown table syntax
- Respect any instructions or notes embedded in the template (then remove them from output)
- Match the formality and tone implied by the template

### 5 — Export to `.docx` automatically

After writing the Markdown report to disk, **always** generate the `.docx` automatically:

1. **Save the `.md` file** with `write` (e.g. `report.md` next to the template).

2. **Ensure pandoc is available** — check and install if missing:

```bash
which pandoc || apt-get install -y pandoc 2>/dev/null || brew install pandoc 2>/dev/null
```

3. **Convert to `.docx`**:

   - **With model.docx** (inherits header, footer, fonts):
     ```bash
     pandoc <report.md> --reference-doc=<path/to/model.docx> -o <report.docx>
     ```
   - **Without model.docx** (standalone, clean output):
     ```bash
     pandoc <report.md> -o <report.docx>
     ```

   Name the output file after the report subject, e.g. `report-june-2026.docx`.

4. **Apply branded table styles** using the post-processor script:

   - **With model.docx** (reads brand colors from template theme):
     ```bash
     node ~/.pi/agent/skills/report-builder/scripts/style-tables.js <report.docx> <path/to/model.docx>
     ```
   - **Without model.docx** (uses built-in dark navy defaults):
     ```bash
     node ~/.pi/agent/skills/report-builder/scripts/style-tables.js <report.docx>
     ```

   Both modes inject a `PrimeTable` style: dark navy header, gray/white banded rows, clean outer border.

5. **Confirm** the `.docx` was created (`ls -lh <report.docx>`) and tell the user the full path.

## Notes

- If the `.docx` has tracked changes or comments, mammoth may include them in raw text — flag this to the user.
- If the template is mostly tables with no headings, treat each table as a section.
- If `npm install` fails (no internet), the user can run `npm install mammoth` manually in the scripts directory.
- Always confirm the final report matches the template's section count before delivering.
- `.docx` export is mandatory, not optional — do not skip it or leave it to the user.
- If pandoc is unavailable and cannot be installed, tell the user clearly and provide the exact command to run manually.
