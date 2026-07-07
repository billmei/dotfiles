#!/usr/bin/env -S deno run --allow-read --allow-write
// build.js — deterministically compile the readable bookmarklet sources into
// pasteable `*-min.js` bookmarklet files. Same input always produces the same
// output. Run it after editing any `*-pdf.js` source:
//
//   deno run --allow-read --allow-write build.js
//   # or, from this directory:  ./build.js
//
// Each `<name>.js` source becomes `<name>-min.js`, whose single line is the
// `javascript:` URL you paste into a bookmark's location field.

const SOURCES = ["reader-pdf"];

// Minify: drop whole-line `//` comments, trim each line, drop blank lines, and
// join the rest with a single space. The sources deliberately keep every string
// literal on one line, so trimming + single-space joins never disturb
// significant whitespace — that's what makes this safe without a full JS parser.
function minify(src) {
  return src
    .split("\n")
    .filter((line) => !line.trimStart().startsWith("//"))
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .join(" ");
}

// A `javascript:` URL must percent-encode its body: the source contains `%`
// (e.g. `max-width:100%`) and spaces that would otherwise corrupt the URL.
function toBookmarklet(src) {
  return "javascript:" + encodeURIComponent(minify(src));
}

// Tiny shim so this runs under both Deno and Node (18+, via `node build.js`).
const dir = new URL(".", import.meta.url).pathname;
let readText, writeText;
if (typeof Deno !== "undefined") {
  readText = (p) => Deno.readTextFile(p);
  writeText = (p, s) => Deno.writeTextFile(p, s);
} else {
  const fs = await import("node:fs/promises");
  readText = (p) => fs.readFile(p, "utf8");
  writeText = (p, s) => fs.writeFile(p, s);
}

for (const base of SOURCES) {
  const src = await readText(dir + base + ".js");
  await writeText(dir + base + "-min.js", toBookmarklet(src) + "\n");
  console.log("wrote " + base + "-min.js");
}
