// ============================================================================
// generate-css-vars.mjs
// Syncs lib/design-system/tokens.ts -> app/globals.css (Tailwind @theme block)
// Runs automatically before dev/build via npm scripts. Do not edit the
// generated block in globals.css by hand -- edit tokens.ts instead.
// ============================================================================
import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const tokensPath = path.join(__dirname, "tokens.ts");
const cssPath = path.join(__dirname, "..", "..", "app", "globals.css");

const START_MARKER = "/* === AUTO-GENERATED TOKENS START (do not edit) === */";
const END_MARKER = "/* === AUTO-GENERATED TOKENS END === */";

async function loadTokens() {
  // Dynamic import works because tokens.ts is plain TS object literal,
  // executed here via a lightweight transpile-free eval of the exported object.
  const raw = readFileSync(tokensPath, "utf-8");
  const match = raw.match(/export const tokens = ({[\s\S]*?}) as const;/);
  if (!match) throw new Error("Could not parse tokens.ts");
  // eslint-disable-next-line no-eval
  const tokens = eval(`(${match[1]})`);
  return tokens;
}

function flatten(obj, prefix = "") {
  const out = {};
  for (const [key, value] of Object.entries(obj)) {
    const varName = prefix ? `${prefix}-${key}` : key;
    if (typeof value === "object" && value !== null) {
      Object.assign(out, flatten(value, varName));
    } else {
      out[varName] = value;
    }
  }
  return out;
}

const tokens = await loadTokens();
const flat = flatten(tokens);

const cssVars = Object.entries(flat)
  .map(([k, v]) => `  --token-${k}: ${v};`)
  .join("\n");

const block = `${START_MARKER}\n@theme {\n${cssVars}\n}\n${END_MARKER}`;

let css = readFileSync(cssPath, "utf-8");

if (css.includes(START_MARKER) && css.includes(END_MARKER)) {
  const regex = new RegExp(`${START_MARKER}[\\s\\S]*?${END_MARKER}`);
  css = css.replace(regex, block);
} else {
  css = `${block}\n\n${css}`;
}

writeFileSync(cssPath, css, "utf-8");
console.log(`[tokens:sync] ${Object.keys(flat).length} tokens written to globals.css`);