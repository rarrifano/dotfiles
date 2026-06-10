---
name: docx-report
description: Generate a formatted .docx report from a template file using only Python stdlib (zipfile + raw OOXML). Use when the user wants a Word document report — any structured data, analysis, summary, or narrative presented as a professional document. Preserves the template's header, footer, logo, and page settings while replacing the body with well-structured content.
---

# docx-report — Word Document Report Generator

## Purpose

Produce a polished `.docx` report by cloning a template file and injecting
fully-formed OOXML into `word/document.xml` — no external libraries required.
The template's header, footer, images, styles, and page geometry are preserved
exactly. Only the body content is replaced.

## When to use this skill

- Any structured data destined for a Word document
- Analysis reports (contributor activity, sales, incidents, audits, etc.)
- Project, sprint, or period summaries
- Narrative documents with mixed text and tables
- Environments where `python-docx` / `pip` are unavailable

## Pre-flight checklist

Before writing any code, confirm:

1. **Template path** — look for `*.docx` in the project root; ask if not obvious.
2. **Language / locale** — default to the template's locale; ask if ambiguous.
3. **Report scope** — what period, domain, or dataset is being reported on?
4. **Data source** — where does the data come from? (Git, CSV, JSON, API, manual input, etc.)
5. **Author / signatory** — who signs the report (name, title, date).
6. **Output filename** — default: `relatorio-<topico>-<periodo>.docx` (PT-BR) or `report-<topic>-<period>.docx` (EN).

## Document structure

The section order below is a recommended menu — pick what applies, skip what
doesn't. Never skip **Metodologia / Methodology** unless the report is purely
narrative with no data analysis.

```
1. Title block         — title, subtitle, author, date (centered)
2. Horizontal rule
3. Objetivo / Objective
4. Metodologia / Methodology   ← always include; explain data source + caveats
5. [Domain-specific sections]  ← tables, breakdowns, findings — as needed
6. Considerações Finais / Closing remarks
7. Horizontal rule + signature line
```

Common domain-specific section patterns:

| Report type        | Typical middle sections                              |
|--------------------|------------------------------------------------------|
| Contributor        | Team roster, consolidated summary, per-repo breakdown|
| Sales / pipeline   | Overview KPIs, per-segment table, trend notes        |
| Incident / audit   | Timeline, impact table, findings, recommendations    |
| Sprint / project   | Goals vs. delivered, blockers, next steps            |

## Visual design rules

### Colors

Default palette (neutral — works for any project):

| Token        | Hex      | Use                           |
|---|---|---|
| `primary`    | `1F3864` | Section headings, header rows |
| `secondary`  | `404040` | Sub-headings, total rows      |
| `stripe-a`   | `EEF2F7` | Alternating table row (even)  |
| `stripe-b`   | `FFFFFF` | Alternating table row (odd)   |
| `muted`      | `888888` | Captions, footer text         |
| `body-text`  | `000000` | Normal paragraph text         |
| `accent-dim` | `555555` | Secondary cell content        |

**Always inspect the template first.** If the template uses a specific brand
palette, extract those colors from `word/theme/theme1.xml` or visually from
`word/header1.xml` and override the defaults accordingly.

Prime Energy preset: `primary=2E3A87`, `secondary=404040`, `stripe-a=F0F3FF`.

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
The `write_docx` helper extracts `<w:sectPr>` from the original template.
This preserves page size, margins, header/footer references, and column
settings exactly as the template defines them.

### Duplicate entry warning
When building the output zip, always use the **read-and-rewrite** pattern
(iterate `zin.infolist()`, replace matching filename) — never `ZipFile(..., 'a')`.
Appending to an existing zip creates duplicate entries that corrupt the file.

### Character encoding in body text
- Accented characters (ã, ç, é, etc.) are safe in UTF-8 encoded XML.
- Do not HTML-escape unless the character is one of `< > & " '`.

## Workflow

1. **Inspect the template** — read `word/document.xml` to check body structure;
   read `word/header1.xml` and `word/footer1.xml` for branding; check
   `word/theme/theme1.xml` for brand colors.
2. **Confirm the six pre-flight items** (template, language, scope, data source,
   author, output name).
3. **Collect and normalize the data** — write intermediate results to `/tmp/`
   if the source requires shell commands or heavy processing.
4. **Build `body_parts`** — assemble sections using `para()`, `hr()`, `table()`
   helpers following the standard section order.
5. **Call `write_docx()`** — single call, clean output.
6. **Verify** — `ls -lh <output>` to confirm file size is reasonable (> 10 KB
   means content was written; ~5 KB usually means the body is empty).

## Output naming convention

| Locale | Pattern                                      |
|--------|----------------------------------------------|
| PT-BR  | `relatorio-<topico>-<periodo>.docx`          |
| EN     | `report-<topic>-<period>.docx`               |

Examples: `relatorio-contributors-2026.docx`, `report-incident-2026-06.docx`

## Response after generation

After writing the file, confirm briefly:

- Output path and file size
- Sections included
- Any data caveats (e.g., missing values, excluded rows, assumed defaults)

---

## Appendix A — Git contributor analysis

Use this appendix when the report data comes from Git commit history.
These steps are Prime Energy–tested but apply to any Git-backed project.

### Step 1 — Identify the source-of-truth branch

The branch used for counting commits matters enormously.

| Strategy       | Symptom                                    | Problem                                          |
|----------------|--------------------------------------------|--------------------------------------------------|
| Squash merge   | Each PR = 1 commit, single parent          | Authorship goes to the merger, not the developer |
| True merge     | Merge commit has 2 parents                 | Individual commits live in history               |
| Rebase merge   | Linear history, no merge commits           | Authorship preserved correctly                   |

Detect the strategy:
```bash
git -C /repo log origin/master --format="%H %P" | head -5 | while read hash parents; do
  count=$(echo $parents | wc -w)
  echo "$hash parents=$count"
done
# parents=1 on every commit → squash merge → use develop, not master
```

If squash merge is detected, use `origin/develop` (or the feature integration
branch) where individual commits retain their real authors.

### Step 2 — Discover all unique contributor identities

```bash
for repo in backend frontend frontend-legacy; do
  git -C /prime/$repo log origin/develop --format="%ae" 2>/dev/null
done | sort -u
```

Look for: multiple emails per person, hostname leaks (`name@MacBook-Pro.local`),
corporate display-name prefixes, and email typos.

### Step 3 — Build the alias normalization map

```python
EMAIL_ALIASES = {
    "person@gmail.com":           "Firstname Lastname",
    "person@company.com":         "Firstname Lastname",
    "person@MacBook-Pro.local":   "Firstname Lastname",
    # Bots — exclude
    "49699333+dependabot[bot]@users.noreply.github.com": "[bot]",
}
```

Skip any name resolving to `"[bot]"` or containing `dependabot`, `renovate`,
or `github-actions`.

### Step 4 — Dump raw commit data to /tmp/

```bash
git -C /path/to/repo log origin/develop \
  --format="%ae|%ad" \
  --date=format:'%Y-%m' > /tmp/<repo>_commits.txt
```

Load and normalize in Python:

```python
from collections import defaultdict

data = defaultdict(lambda: defaultdict(lambda: defaultdict(int)))

for repo, path in REPOS.items():
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line: continue
            parts = line.split("|")
            if len(parts) != 2: continue
            email, month = parts
            name = EMAIL_ALIASES.get(email.strip())
            if not name or name == "[bot]": continue
            data[name][repo][month] += 1
```

### Step 5 — Filter to the target period

```python
if not ("2025-10" <= month <= "2026-05"): continue
```

### Step 6 — Validate before building the report

```python
for name, repos in sorted(data.items()):
    total = sum(c for r in repos.values() for c in r.values())
    print(f"{name:<30} {total}")
```

Red flags: raw email appearing as a name (missing alias), known contributor
with zero commits (wrong branch or missing alias), implausibly high count on
one person (squash-merge credit absorption).

### Step 7 — Note caveats for the Metodologia section

Always document:
1. Which branch was used as source and why
2. That email aliases were normalized and how many identities were merged
3. What was excluded (bots, date range, external contributors)
4. Metric definition (commit count, not lines of code or PR count)
