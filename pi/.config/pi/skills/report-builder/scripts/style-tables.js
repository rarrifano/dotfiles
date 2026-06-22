#!/usr/bin/env node
/**
 * style-tables.js
 *
 * Post-processes a pandoc-generated .docx to inject a branded table style
 * using the color palette from the reference model.docx.
 *
 * Usage:
 *   node style-tables.js <report.docx> [model.docx]
 *
 * Reads color palette from model.docx (theme/theme1.xml) if provided,
 * otherwise falls back to Prime Energy brand defaults.
 * Modifies <report.docx> in-place.
 */

const fs   = require('fs');
const path = require('path');
const os   = require('os');
const { execSync } = require('child_process');
const JSZip = require(path.join(__dirname, 'node_modules', 'jszip'));

// ── args ──────────────────────────────────────────────────────────────────────
const [,, reportDocx, modelDocx] = process.argv;
if (!reportDocx) {
  console.error('Usage: node style-tables.js <report.docx> [model.docx]');
  process.exit(1);
}

// ── extract palette from model.docx or use defaults ───────────────────────────
function extractPalette(docxPath) {
  try {
    const xml = execSync(`unzip -p "${docxPath}" word/theme/theme1.xml`, { encoding: 'utf8' });
    const get = (key) => {
      const m = xml.match(new RegExp(`<a:${key}>.*?(?:lastClr|val)="([0-9A-Fa-f]{6})"`, 's'));
      return m ? m[1].toUpperCase() : null;
    };
    // Darken dk2 by blending with black at 40% to get a deep navy header
    const dk2 = get('dk2') || '1F497D';
    const darken = (hex, factor) => hex.match(/../g)
      .map(c => Math.round(parseInt(c, 16) * (1 - factor)).toString(16).padStart(2, '0'))
      .join('').toUpperCase();
    return {
      headerBg:    darken(dk2, 0.35),  // deep navy
      headerText:  'FFFFFF',
      bandBg:      'D9D9D9',           // light gray (matches reference)
      borderColor: darken(dk2, 0.20),  // subtle outer border
      altBandBg:   'FFFFFF',
    };
  } catch {
    return {
      headerBg:    '142D4C',
      headerText:  'FFFFFF',
      bandBg:      'D9D9D9',
      borderColor: '1F497D',
      altBandBg:   'FFFFFF',
    };
  }
}

const p = modelDocx ? extractPalette(modelDocx) : {
  headerBg:    '1F3864',  // deep navy default
  headerText:  'FFFFFF',
  bandBg:      'D9D9D9',
  borderColor: '2F5496',
  altBandBg:   'FFFFFF',
};
console.log('Palette:', p);

// ── build the custom table style XML ─────────────────────────────────────────
function outerBorderXml(color, sz = 6) {
  const b = `w:val="single" w:sz="${sz}" w:space="0" w:color="${color}"`;
  const none = `w:val="none" w:sz="0" w:space="0" w:color="auto"`;
  return `<w:top ${b}/><w:left ${b}/><w:bottom ${b}/><w:right ${b}/><w:insideH ${none}/><w:insideV ${none}/>`;
}

function rowBorderXml(color) {
  const thin = `w:val="single" w:sz="2" w:space="0" w:color="${color}"`;
  const none = `w:val="none" w:sz="0" w:space="0" w:color="auto"`;
  return `<w:top ${thin}/><w:bottom ${thin}/><w:insideH ${thin}/><w:left ${none}/><w:right ${none}/><w:insideV ${none}/>`;
}

const TABLE_STYLE_ID = 'PrimeTable';

const tableStyleXml = `
<w:style w:type="table" w:customStyle="1" w:styleId="${TABLE_STYLE_ID}">
  <w:name w:val="Prime Table"/>
  <w:basedOn w:val="TableNormal"/>
  <w:uiPriority w:val="40"/>
  <w:tblPr>
    <w:tblBorders>${outerBorderXml(p.borderColor)}</w:tblBorders>
    <w:tblCellMar>
      <w:top    w:w="80"  w:type="dxa"/>
      <w:left   w:w="120" w:type="dxa"/>
      <w:bottom w:w="80"  w:type="dxa"/>
      <w:right  w:w="120" w:type="dxa"/>
    </w:tblCellMar>
  </w:tblPr>
  <!-- header row -->
  <w:tblStylePr w:type="firstRow">
    <w:tblPr><w:tblBorders>${outerBorderXml(p.borderColor)}</w:tblBorders></w:tblPr>
    <w:trPr><w:tblHeader/></w:trPr>
    <w:tcPr>
      <w:shd w:val="clear" w:color="auto" w:fill="${p.headerBg}"/>
    </w:tcPr>
    <w:rPr>
      <w:b/>
      <w:color w:val="${p.headerText}"/>
    </w:rPr>
  </w:tblStylePr>
  <!-- odd banded rows -->
  <w:tblStylePr w:type="band1Horz">
    <w:tblPr><w:tblBorders>${rowBorderXml('C0C0C0')}</w:tblBorders></w:tblPr>
    <w:tcPr>
      <w:shd w:val="clear" w:color="auto" w:fill="${p.bandBg}"/>
    </w:tcPr>
  </w:tblStylePr>
  <!-- even banded rows -->
  <w:tblStylePr w:type="band2Horz">
    <w:tblPr><w:tblBorders>${rowBorderXml('C0C0C0')}</w:tblBorders></w:tblPr>
    <w:tcPr>
      <w:shd w:val="clear" w:color="auto" w:fill="${p.altBandBg}"/>
    </w:tcPr>
  </w:tblStylePr>
</w:style>`.trim();

const absReport = path.resolve(reportDocx);

(async () => {
  // ── load docx with JSZip ───────────────────────────────────────────────────
  const zip = await JSZip.loadAsync(fs.readFileSync(absReport));

  // ── inject style into styles.xml ──────────────────────────────────────────
  let styles = await zip.file('word/styles.xml').async('string');
  if (styles.includes(`styleId="${TABLE_STYLE_ID}"`)) {
    styles = styles.replace(
      new RegExp(`<w:style[^>]*styleId="${TABLE_STYLE_ID}"[\\s\\S]*?</w:style>`),
      tableStyleXml
    );
  } else {
    styles = styles.replace('</w:styles>', `${tableStyleXml}\n</w:styles>`);
  }
  zip.file('word/styles.xml', styles);

  // ── apply style to every table in document.xml ────────────────────────────
  let doc = await zip.file('word/document.xml').async('string');
  // Replace pandoc's default "Table" style reference with our branded style
  // and enable banded rows + header row look
  doc = doc.replace(/w:tblStyle w:val="Table"/g, `w:tblStyle w:val="${TABLE_STYLE_ID}"`);
  // For any table that somehow has no tblStyle at all, inject it
  doc = doc.replace(/<w:tblPr>((?!.*w:tblStyle)[\s\S]*?)<\/w:tblPr>/g, (match, inner) => {
    return `<w:tblPr><w:tblStyle w:val="${TABLE_STYLE_ID}"/><w:tblLook w:val="04A0" w:firstRow="1" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="1"/>${inner}</w:tblPr>`;
  });
  zip.file('word/document.xml', doc);

  // ── repack ─────────────────────────────────────────────────────────────────
  const outBuffer = await zip.generateAsync({
    type: 'nodebuffer',
    compression: 'DEFLATE',
    compressionOptions: { level: 6 },
  });
  fs.writeFileSync(absReport, outBuffer);

  console.log(`✓ Table styles applied → ${absReport}`);
})().catch(err => { console.error(err); process.exit(1); });
