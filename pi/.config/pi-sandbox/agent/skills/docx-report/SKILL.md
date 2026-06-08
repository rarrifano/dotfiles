---
name: docx-report
description: Generate a formatted .docx report from a template file using only Python stdlib (zipfile + raw OOXML). Use when the user wants a Word document report — contributor analysis, vendor activity, project summaries, or any structured data presented as a professional document. Preserves the template's header, footer, logo, and page settings while replacing the body with well-structured content.
---

# docx-report — Word Document Report Generator

## Purpose

Produce a polished `.docx` report by cloning a template file and injecting
fully-formed OOXML into `word/document.xml` — no external libraries required.
The template's header, footer, images, styles, and page geometry are preserved
exactly. Only the body content is replaced.

## When to use this skill

- Contributor / vendor activity reports
- Project or sprint summaries
- Any structured data (tables, sections, highlights) destined for a Word document
- Environments where `python-docx` / `pip` are unavailable

## Pre-flight checklist

Before writing any code, confirm:

1. **Template path** — ask the user if not obvious (look for `*.docx` in the project root).
2. **Language** — default to the template's locale; ask if ambiguous.
3. **Report period and scope** — be explicit about what data is included.
4. **Author / signatory** — who signs the report (name, title, date).
5. **Output filename** — default: `relatorio-<topic>-<period>.docx` or `report-<topic>-<period>.docx`.

## Document structure (standard sections)

Use this section order unless the user specifies otherwise:

```
1. Title block       — title, subtitle, author, date (centered, no page break needed)
2. Horizontal rule
3. Objetivo / Objective
4. Metodologia / Methodology   ← always include; explain data source + any caveats
5. Equipe / Team               ← when the report is about people/contributors
6. Resumo Consolidado / Summary  ← main data table(s)
7. Detalhamento / Breakdown    ← per-dimension tables (per repo, per team, etc.)
8. Considerações Finais / Closing remarks
9. Horizontal rule + signature line
```

Skip sections that don't apply. Never skip **Metodologia** — always explain how
the data was collected and any known limitations.

## Visual design rules

### Colors (default palette — matches Prime Energy template)

| Token        | Hex      | Use                          |
|---|---|---|
| `primary`    | `2E3A87` | Section headings, header rows |
| `secondary`  | `404040` | Sub-headings, total rows      |
| `stripe-a`   | `F0F3FF` | Alternating table row (even)  |
| `stripe-b`   | `FFFFFF` | Alternating table row (odd)   |
| `muted`      | `888888` | Captions, footer text         |
| `body-text`  | `000000` | Normal paragraph text         |
| `accent-dim` | `555555` | Secondary cell content        |

Override with a project-specific palette when the template uses different brand colors.

### Typography

| Element              | Size (half-points) | Bold | Color     |
|---|---|---|---|
| Report title         | 28                 | yes  | primary   |
| Report subtitle      | 22                 | no   | secondary |
| Author / date line   | 18                 | no   | muted     |
| Section heading      | 24                 | yes  | primary   |
| Sub-section heading  | 22                 | yes  | secondary |
| Body paragraph       | 20                 | no   | body-text |
| Table header cell    | 18                 | yes  | FFFFFF    |
| Table body cell      | 18                 | no   | body-text |
| Footer / caption     | 18                 | no   | muted     |

### Spacing

- Section heading: `spacing_before=240`, `spacing_after=100`
- Body paragraph: `spacing_before=0`, `spacing_after=80–120`
- After a table: add an empty paragraph (`spacing_after=80`)
- Horizontal rule: `spacing_before=0`, `spacing_after=120`

### Tables

- Always include a header row with `bg=primary`, white text, bold.
- Alternate row stripes (`stripe-a` / `stripe-b`) by row index.
- Total/summary rows: `bg=secondary`, white text, bold.
- Numeric columns: `align="center"`. Label columns: `align="left"`.
- Missing / zero values: display as `"–"` not `"0"` for readability.
- Bold the row total cell.

## Core XML helpers (copy-paste pattern)

```python
import zipfile, io, os

def para(text="", bold=False, size=22, color=None, align=None, sb=0, sa=120):
    pPr = "<w:pPr>"
    if align:
        pPr += "<w:jc w:val=\"" + align + "\"/>"
    pPr += "<w:spacing w:before=\"" + str(sb) + "\" w:after=\"" + str(sa) + "\"/>"
    pPr += "</w:pPr>"
    b_tag  = "<w:b/>" if bold else ""
    c_tag  = "<w:color w:val=\"" + color + "\"/>" if color else ""
    rPr = "<w:rPr>" + b_tag + "<w:sz w:val=\"" + str(size) + "\"/><w:szCs w:val=\"" + str(size) + "\"/>" + c_tag + "</w:rPr>"
    if text:
        return "<w:p>" + pPr + "<w:r>" + rPr + "<w:t xml:space=\"preserve\">" + text + "</w:t></w:r></w:p>"
    return "<w:p>" + pPr + "</w:p>"

def hr():
    return '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="CCCCCC"/></w:pBdr><w:spacing w:before="0" w:after="120"/></w:pPr></w:p>'

def cell(text, bold=False, color=None, bg=None, align="left", width=1000):
    b_tag  = "<w:b/>" if bold else ""
    c_tag  = "<w:color w:val=\"" + color + "\"/>" if color else ""
    bg_tag = "<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"" + bg + "\"/>" if bg else ""
    rPr  = "<w:rPr>" + b_tag + "<w:sz w:val=\"18\"/><w:szCs w:val=\"18\"/>" + c_tag + "</w:rPr>"
    pPr  = "<w:pPr><w:jc w:val=\"" + align + "\"/><w:spacing w:before=\"60\" w:after=\"60\"/></w:pPr>"
    tcPr = "<w:tcPr><w:tcW w:w=\"" + str(width) + "\" w:type=\"dxa\"/>" + bg_tag + "</w:tcPr>"
    return "<w:tc>" + tcPr + "<w:p>" + pPr + "<w:r>" + rPr + "<w:t xml:space=\"preserve\">" + text + "</w:t></w:r></w:p></w:tc>"

def table(rows, widths):
    borders = (
        '<w:tblBorders>'
        '<w:top    w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>'
        '<w:left   w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>'
        '<w:bottom w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>'
        '<w:right  w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>'
        '<w:insideH w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>'
        '<w:insideV w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>'
        '</w:tblBorders>'
    )
    xml = "<w:tbl><w:tblPr><w:tblW w:w=\"0\" w:type=\"auto\"/>" + borders + "</w:tblPr>"
    for row in rows:
        xml += "<w:tr>"
        for j, (t, b, co, bg, al) in enumerate(row):
            xml += cell(t, bold=b, color=co, bg=bg, align=al, width=widths[j])
        xml += "</w:tr>"
    xml += "</w:tbl>"
    return xml

def write_docx(template_path, output_path, body_parts, rels_map=None):
    """
    body_parts : list of OOXML strings (para, hr, table outputs)
    rels_map   : dict of filename -> new XML string for any additional overrides
                 (rarely needed; document.xml is always replaced automatically)
    """
    # sectPr is extracted from the template and reused to preserve page geometry
    import re
    with zipfile.ZipFile(template_path, 'r') as zin:
        orig_doc = zin.read("word/document.xml").decode("utf-8")
    sect_match = re.search(r'<w:sectPr[\s\S]+?</w:sectPr>', orig_doc)
    sect_pr = sect_match.group(0) if sect_match else (
        '<w:sectPr>'
        '<w:pgSz w:w="11906" w:h="16838"/>'
        '<w:pgMar w:top="1418" w:right="1701" w:bottom="1418" w:left="1701" w:header="709" w:footer="709" w:gutter="0"/>'
        '</w:sectPr>'
    )
    doc_xml = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<w:document '
        'xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
        'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
        'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
        'xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" '
        'xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml" '
        'mc:Ignorable="w14 w15">'
        '<w:body>'
        + "".join(body_parts)
        + sect_pr
        + '</w:body></w:document>'
    )
    buf = io.BytesIO()
    with zipfile.ZipFile(template_path, 'r') as zin:
        with zipfile.ZipFile(buf, 'w', zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                overrides = rels_map or {}
                overrides["word/document.xml"] = doc_xml
                if item.filename in overrides:
                    zout.writestr(item, overrides[item.filename])
                else:
                    zout.writestr(item, zin.read(item.filename))
    with open(output_path, 'wb') as f:
        f.write(buf.getvalue())
```

## Critical implementation notes

### No f-strings with backslashes
Python 3.11 does not allow backslash escapes inside f-string expressions.
**Always build XML strings with concatenation** for any part that embeds
quote characters inside a dynamic expression. The helpers above follow this
pattern — do not "modernize" them with f-strings.

### sectPr: always extract from template, never hardcode
The `write_docx` helper above extracts `<w:sectPr>` from the original template.
This preserves page size, margins, header/footer references, and column settings
exactly as the client's template defines them.

### Duplicate entry warning
When building the output zip, always use the **read-and-rewrite** pattern
(iterate `zin.infolist()`, replace matching filename) — never `ZipFile(..., 'a')`.
Appending to an existing zip creates duplicate entries that corrupt the file.

### Character encoding in body text
When generating body text that will go into `<w:t>` nodes:
- Avoid raw Unicode in XML if the environment has encoding edge cases.
- Accented characters (ã, ç, é, etc.) are safe in UTF-8 encoded XML — the
  `<?xml version="1.0" encoding="UTF-8"?>` declaration covers them.
- Do not HTML-escape unless the character is one of `< > & " '`.

## Data sourcing patterns

### Git contributor analysis
When the report is about Git contributor activity:
- **Never use `main`/`master` directly** when the project uses squash merges —
  the merge committer eats all credit.
- **Use `origin/develop`** (or the integration branch) where individual commits
  preserve real authorship.
- Normalize email aliases: one person often has 2–4 git identities across
  machines/clients. Build an `EMAIL_ALIASES` dict mapping each email to a
  canonical display name before counting.
- Exclude bot commits (`dependabot`, `renovate`, GitHub Actions bot emails).
- Dump raw data to `/tmp/<repo>_commits.txt` as `email|YYYY-MM` lines for
  reuse across multiple report iterations without re-running git.

### Dump command pattern
```bash
git -C /path/to/repo log origin/develop \
  --format="%ae|%ad" \
  --date=format:'%Y-%m' > /tmp/repo_commits.txt
```

## Workflow

1. **Inspect the template** — read `word/document.xml` to check if body is empty
   (common for blank branded templates); read `word/header1.xml` and
   `word/footer1.xml` for branding context; extract images if needed to confirm
   logo/colors.
2. **Confirm the five pre-flight items** (template path, language, scope, author, output name).
3. **Collect and normalize the data** — write to `/tmp/` if Git-based.
4. **Build `body_parts`** — assemble the section list using `para()`, `hr()`,
   `table()` helpers. Follow the standard section order.
5. **Call `write_docx()`** — single call, clean output.
6. **Verify** — `ls -lh <output>` to confirm file size is reasonable (> 10 KB
   means content was written; a ~5 KB file usually means the body is empty).

## Output naming convention

| Language | Pattern                                      |
|---|---|
| PT-BR    | `relatorio-<topico>-<periodo>.docx`          |
| EN       | `report-<topic>-<period>.docx`               |

Examples: `relatorio-liga-2026.docx`, `report-contributors-q1-2026.docx`

## Response after generation

After writing the file, confirm briefly:

- Output path and file size
- Sections included
- Any data caveats (e.g., "3 contributors had zero commits in 2026 and appear
  in the team table as inactive")
