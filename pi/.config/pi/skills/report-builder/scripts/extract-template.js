#!/usr/bin/env node
/**
 * extract-template.js
 * Reads a .docx file and outputs its structure as JSON:
 *   { rawText, sections, headings, tables }
 *
 * Usage: node extract-template.js <path/to/model.docx>
 */

const mammoth = require("mammoth");
const fs = require("node:fs");
const path = require("node:path");

const docxPath = process.argv[2];
if (!docxPath) {
  console.error("Usage: node extract-template.js <path/to/model.docx>");
  process.exit(1);
}

const absPath = path.resolve(docxPath);
if (!fs.existsSync(absPath)) {
  console.error(`File not found: ${absPath}`);
  process.exit(1);
}

(async () => {
  // Extract raw text
  const textResult = await mammoth.extractRawText({ path: absPath });

  // Extract HTML (preserves headings, tables, lists)
  const htmlResult = await mammoth.convertToHtml({ path: absPath });

  const rawText = textResult.value;
  const html = htmlResult.value;

  // Parse headings from HTML
  const headingRegex = /<h([1-6])[^>]*>(.*?)<\/h[1-6]>/gi;
  const headings = [];
  let match;
  while ((match = headingRegex.exec(html)) !== null) {
    headings.push({
      level: parseInt(match[1], 10),
      text: match[2].replace(/<[^>]+>/g, "").trim(),
    });
  }

  // Parse tables (detect presence and column count)
  const tableRegex = /<table[\s\S]*?<\/table>/gi;
  const tables = [];
  let tableIndex = 0;
  while ((match = tableRegex.exec(html)) !== null) {
    const rows = (match[0].match(/<tr/gi) || []).length;
    const cols = (match[0].match(/<td|<th/gi) || []).length / Math.max(rows, 1);
    tables.push({ index: tableIndex++, rows, estimatedCols: Math.round(cols) });
  }

  // Split raw text into sections by headings
  const lines = rawText.split("\n").map((l) => l.trim()).filter(Boolean);
  const sections = [];
  let current = null;
  for (const line of lines) {
    const isHeading = headings.find((h) => h.text === line);
    if (isHeading) {
      if (current) sections.push(current);
      current = { heading: line, level: isHeading.level, content: [] };
    } else if (current) {
      current.content.push(line);
    } else {
      // Preamble before first heading
      sections.push({ heading: "__preamble__", level: 0, content: [line] });
    }
  }
  if (current) sections.push(current);

  const output = {
    file: absPath,
    headings,
    tables,
    sections,
    rawText,
  };

  console.log(JSON.stringify(output, null, 2));
})().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
