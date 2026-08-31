#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const MarkdownIt = require('markdown-it');
const texmath = require('markdown-it-texmath');
const katex = require('katex');
const hljs = require('highlight.js');
const puppeteer = require('puppeteer-core');

const PROJECT_ROOT = path.resolve(__dirname, '..', '..');
const PDF_MARGIN_MM = { top: 18, bottom: 16, left: 16, right: 16 };
const PAGE_WIDTH_MM = 210; // A4
const MM_TO_PX = 96 / 25.4;
const PAGE_CONTENT_WIDTH_PX = Math.floor(
  (PAGE_WIDTH_MM - PDF_MARGIN_MM.left - PDF_MARGIN_MM.right) * MM_TO_PX
);
const KATEX_CSS = path.join(require.resolve('katex/package.json'), '..', 'dist', 'katex.min.css');
const KATEX_FONTS_DIR = path.join(path.dirname(KATEX_CSS), 'fonts');
const HLJS_CSS = path.join(require.resolve('highlight.js/package.json'), '..', 'styles', 'github.css');

function inlineKatexFontUrls(css) {
  const fontsUrl = 'file:///' + KATEX_FONTS_DIR.replace(/\\/g, '/');
  return css.replace(/url\(fonts\//g, `url(${fontsUrl}/`);
}

function findEdge() {
  const candidates = [
    process.env.CHROME_PATH,
    'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe',
    'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
    'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
  ].filter(Boolean);
  for (const c of candidates) {
    if (fs.existsSync(c)) return c;
  }
  throw new Error(
    '找不到 Edge 或 Chrome 瀏覽器，請安裝其中一個，或用環境變數 CHROME_PATH 指定路徑。'
  );
}

function findAllMarkdownFiles(dir) {
  const results = [];
  const skipDirs = new Set(['node_modules', '_tools', '.git']);
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith('.')) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (skipDirs.has(entry.name)) continue;
      results.push(...findAllMarkdownFiles(full));
    } else if (entry.isFile() && entry.name.toLowerCase().endsWith('.md')) {
      results.push(full);
    }
  }
  return results;
}

function buildMarkdownRenderer() {
  const md = new MarkdownIt({
    html: true,
    linkify: true,
    typographer: true,
    breaks: false,
    highlight(str, lang) {
      if (lang && hljs.getLanguage(lang)) {
        try {
          return hljs.highlight(str, { language: lang }).value;
        } catch (e) {
          // fall through to default escaping
        }
      }
      return md.utils.escapeHtml(str);
    },
  });
  md.use(texmath, {
    engine: katex,
    delimiters: 'dollars',
    katexOptions: { throwOnError: false, strict: false },
  });
  return md;
}

function renderHtml(md, markdownSource, title) {
  const bodyHtml = md.render(markdownSource);
  const katexCss = inlineKatexFontUrls(fs.readFileSync(KATEX_CSS, 'utf8'));
  const hljsCss = fs.readFileSync(HLJS_CSS, 'utf8');

  return `<!DOCTYPE html>
<html lang="zh-Hant">
<head>
<meta charset="utf-8">
<title>${title}</title>
<style>
${katexCss}
${hljsCss}
:root {
  --fg: #1a1a1a;
  --muted: #595959;
  --border: #d9d9d9;
  --code-bg: #f6f8fa;
  --accent: #2b5fb8;
}
* { box-sizing: border-box; }
body {
  font-family: "Microsoft JhengHei", "PingFang TC", "Noto Sans TC", "Segoe UI", Arial, sans-serif;
  color: var(--fg);
  line-height: 1.75;
  font-size: 12.5pt;
  padding: 0 4mm;
  word-wrap: break-word;
}
h1, h2, h3, h4, h5, h6 {
  font-weight: 700;
  line-height: 1.4;
  margin-top: 1.4em;
  margin-bottom: 0.6em;
  page-break-after: avoid;
}
h1 { font-size: 20pt; border-bottom: 3px solid var(--accent); padding-bottom: 0.2em; }
h2 { font-size: 16pt; border-bottom: 1px solid var(--border); padding-bottom: 0.15em; margin-top: 1.8em; }
h3 { font-size: 13.5pt; color: var(--accent); }
h4 { font-size: 12.5pt; }
p { margin: 0.6em 0; }
strong { font-weight: 700; }
blockquote {
  margin: 0.8em 0;
  padding: 0.3em 1em;
  border-left: 4px solid var(--accent);
  background: #f2f6fc;
  color: var(--muted);
}
table {
  border-collapse: collapse;
  width: 100%;
  margin: 0.9em 0;
  font-size: 11pt;
  page-break-inside: avoid;
}
th, td {
  border: 1px solid var(--border);
  padding: 0.4em 0.6em;
  text-align: left;
  vertical-align: top;
}
th { background: #eef2f8; font-weight: 700; }
tr:nth-child(even) td { background: #fafbfc; }
code {
  font-family: "Cascadia Mono", Consolas, "Courier New", monospace;
  background: var(--code-bg);
  padding: 0.1em 0.35em;
  border-radius: 3px;
  font-size: 0.92em;
}
pre {
  background: var(--code-bg);
  border: 1px solid var(--border);
  border-radius: 5px;
  padding: 0.8em 1em;
  white-space: pre-wrap;
  word-break: break-word;
  page-break-inside: avoid;
  font-size: 10.5pt;
  line-height: 1.5;
}
pre code { background: none; padding: 0; }
hr { border: none; border-top: 1px solid var(--border); margin: 1.6em 0; }
ul, ol { padding-left: 1.6em; margin: 0.5em 0; }
li { margin: 0.25em 0; }
img { max-width: 100%; }
.katex-display { margin: 0.9em 0; max-width: 100%; overflow: visible; }
a { color: var(--accent); text-decoration: none; }
</style>
</head>
<body>
${bodyHtml}
</body>
</html>`;
}

// KaTeX renders "\ne"/"\neq" by overlaying a private-use-area glyph (U+E020, its
// internal "\@not" slash symbol) on top of "=". On some Windows + Traditional/Simplified
// Chinese configurations, Chromium's font fallback substitutes a wrong CJK glyph for
// that PUA codepoint even though the KaTeX font itself defines it correctly — the
// symptom is "≠" rendering as a garbled Chinese-looking character. Swapping the PUA
// character for a plain "/" sidesteps the buggy substitution entirely: it's an
// ordinary ASCII character with no font-fallback ambiguity, and KaTeX's zero-width
// overlay positioning still lines it up on top of the following "=" correctly.
async function fixNotEqualGlyph(page) {
  await page.evaluate(() => {
    const BROKEN_CHAR = String.fromCharCode(0xe020);
    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null);
    const nodes = [];
    let n;
    while ((n = walker.nextNode())) {
      if (n.nodeValue.indexOf(BROKEN_CHAR) !== -1) nodes.push(n);
    }
    nodes.forEach((node) => {
      node.nodeValue = node.nodeValue.split(BROKEN_CHAR).join('/');
    });
  });
}

// KaTeX renders formulas at their natural width; a display equation with several
// fraction terms (e.g. K1/(τs+1) + K2/(τs+1) + K3/(τs+1)) easily exceeds the printable
// page width. `overflow-x` has no effect on paper (there's no scrollbar), so anything
// wider than the page just gets cut off. Shrink each formula's font-size in place
// until it fits, which reflows KaTeX's em-based layout instead of clipping it.
async function shrinkOverflowingMath(page) {
  await page.evaluate(() => {
    function shrinkToFit(el, maxWidth) {
      let guard = 0;
      while (el.scrollWidth > maxWidth && guard < 30) {
        const current = parseFloat(window.getComputedStyle(el).fontSize);
        if (!current || current < 4) break;
        el.style.fontSize = `${current * 0.95}px`;
        guard += 1;
      }
    }

    const maxWidth = document.body.clientWidth;
    document.querySelectorAll('.katex-display > .katex').forEach((el) => {
      shrinkToFit(el, maxWidth);
    });
    document.querySelectorAll('.katex').forEach((el) => {
      if (el.closest('.katex-display')) return; // already handled above
      shrinkToFit(el, maxWidth);
    });
  });
}

async function convertOne(md, browser, mdPath) {
  const source = fs.readFileSync(mdPath, 'utf8');
  const title = path.basename(mdPath, '.md');
  const html = renderHtml(md, source, title);

  const tmpHtmlPath = path.join(os.tmpdir(), `md2pdf-${Date.now()}-${Math.random().toString(16).slice(2)}.html`);
  fs.writeFileSync(tmpHtmlPath, html, 'utf8');

  const pdfPath = path.join(path.dirname(mdPath), `${title}.pdf`);

  const fileUrl = 'file:///' + tmpHtmlPath.replace(/\\/g, '/');
  const MAX_ATTEMPTS = 3;
  let lastErr;

  try {
    for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt += 1) {
      const page = await browser.newPage();
      try {
        await page.setViewport({ width: PAGE_CONTENT_WIDTH_PX, height: 1400 });
        // Font loading over file:// can occasionally stall well past Puppeteer's
        // default 30s navigation timeout on this machine; give it more room and
        // silently retry on a fresh page rather than failing the whole file.
        await page.goto(fileUrl, { waitUntil: 'networkidle0', timeout: 60000 });
        await fixNotEqualGlyph(page);
        await shrinkOverflowingMath(page);
        await page.pdf({
          path: pdfPath,
          format: 'A4',
          printBackground: true,
          // page.pdf() has its own `timeout` (defaults to Puppeteer's general 30s
          // default-timeout setting) that is entirely separate from both the
          // navigation timeout above and the browser's protocolTimeout — this is
          // the one that was actually firing "Timed out after waiting 30000ms" on
          // longer, math-heavy documents.
          timeout: 120000,
          margin: {
            top: `${PDF_MARGIN_MM.top}mm`,
            bottom: `${PDF_MARGIN_MM.bottom}mm`,
            left: `${PDF_MARGIN_MM.left}mm`,
            right: `${PDF_MARGIN_MM.right}mm`,
          },
        });
        return pdfPath;
      } catch (err) {
        lastErr = err;
      } finally {
        await page.close();
      }
    }
    throw lastErr;
  } finally {
    fs.unlinkSync(tmpHtmlPath);
  }
}

async function main() {
  const args = process.argv.slice(2);
  let targets;

  if (args.length === 0 || args.includes('--all')) {
    targets = findAllMarkdownFiles(PROJECT_ROOT);
    if (targets.length === 0) {
      console.error('在專案目錄下找不到任何 .md 檔案。');
      process.exit(1);
    }
  } else {
    targets = args.map((p) => path.resolve(process.cwd(), p));
    for (const t of targets) {
      if (!fs.existsSync(t)) {
        console.error(`找不到檔案：${t}`);
        process.exit(1);
      }
    }
  }

  console.log(`準備轉換 ${targets.length} 個檔案...`);

  const executablePath = findEdge();
  // protocolTimeout governs every individual CDP command Puppeteer issues, including
  // Page.printToPDF — independent of page.goto's own navigation timeout. Its default
  // (30s in some versions) can be too tight for a long, math-heavy document, which is
  // what was actually causing "Timed out after waiting 30000ms" even after the
  // per-file retry loop and a longer navigation timeout were added.
  const browser = await puppeteer.launch({ executablePath, headless: 'new', protocolTimeout: 180000 });
  const md = buildMarkdownRenderer();

  let ok = 0;
  try {
    for (const target of targets) {
      const rel = path.relative(PROJECT_ROOT, target);
      try {
        const pdfPath = await convertOne(md, browser, target);
        console.log(`  ✔ ${rel}  ->  ${path.relative(PROJECT_ROOT, pdfPath)}`);
        ok += 1;
      } catch (err) {
        console.error(`  ✘ ${rel} 轉換失敗：${err.message}`);
      }
    }
  } finally {
    await browser.close();
  }

  console.log(`完成：成功 ${ok}/${targets.length}`);
}

module.exports = {
  buildMarkdownRenderer,
  renderHtml,
  shrinkOverflowingMath,
  fixNotEqualGlyph,
  findEdge,
  PAGE_CONTENT_WIDTH_PX,
};

if (require.main === module) {
  main().catch((err) => {
    console.error('發生錯誤：', err);
    process.exit(1);
  });
}
