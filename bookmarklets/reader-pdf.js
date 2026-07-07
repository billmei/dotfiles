// reader-pdf — a self-contained PrintFriendly-style "clean up, then save as PDF"
// bookmarklet. Companion to bookmark-pdf.js.
//
// PrintFriendly's bookmarklet injects a script from cdn.printfriendly.com, which
// means it depends on their servers and sends the page to a third party. This
// does the same job with zero external dependencies: everything below runs
// locally in the page.
//
// What it does:
//   1. Scores the page's blocks to find the main article (a compact Readability-
//      style heuristic) and lifts just that content into a clean overlay.
//   2. Auto-strips obvious clutter: nav, sidebars, footers, comments, ad/share
//      /related/newsletter blocks.
//   3. Lets you hover + click any remaining block to delete it (with Undo).
//   4. "Save as PDF" opens the print dialog showing only the cleaned content —
//      choose Save as PDF and point it at ~/Dropbox/bookmarks.
//
// This is the readable source. The URL-encoded one-line `javascript:` version
// you drag to your bookmarks bar lives in README.md; regenerate it from this
// file whenever you edit here.

(function () {
  var OVERLAY_ID = "pf-overlay";
  if (document.getElementById(OVERLAY_ID)) {
    window.print();
    return;
  }

  // Class/id substrings that mark non-article clutter.
  var JUNK = /comment|disqus|reply|footnote|sidebar|sponsor|advert|adsense|banner|share|social|related|recommend|newsletter|subscribe|popup|modal|promo|breadcrumb|pagination|cookie|widget|masthead|utility/i;
  var GOOD = /article|content|post|story|entry|main|body|prose|markdown/i;

  function hintOf(el) {
    return (((el.className && el.className.toString()) || "") + " " + (el.id || ""));
  }

  function linkDensity(el) {
    var t = (el.innerText || "").length;
    if (!t) return 0;
    var l = 0;
    el.querySelectorAll("a").forEach(function (a) { l += (a.innerText || "").length; });
    return l / t;
  }

  // Promote lazy-loaded images so they aren't blank in the PDF.
  document.querySelectorAll("img").forEach(function (img) {
    img.loading = "eager";
    ["data-src", "data-original", "data-lazy-src", "data-actualsrc"].forEach(function (a) {
      var v = img.getAttribute(a);
      if (v) img.src = v;
    });
    var ss = img.getAttribute("data-srcset");
    if (ss) img.srcset = ss;
  });

  // Find the highest-scoring block: lots of paragraph text, low link density,
  // bonus for article-ish class/id, penalty for junk-ish class/id.
  function score(el) {
    var text = el.innerText || "";
    if (text.length < 140) return 0;
    var s = text.length + el.querySelectorAll("p").length * 80;
    var hint = hintOf(el);
    if (JUNK.test(hint)) s *= 0.25;
    if (GOOD.test(hint)) s *= 1.5;
    s *= 1 - Math.min(linkDensity(el), 0.9) * 0.6;
    return s;
  }

  var best = document.body, bestScore = 0;
  document.querySelectorAll("article, main, [role=main], section, div").forEach(function (el) {
    var s = score(el);
    if (el.tagName === "ARTICLE" || el.tagName === "MAIN" || el.getAttribute("role") === "main") s *= 1.4;
    if (s > bestScore) { bestScore = s; best = el; }
  });

  // Clone the winning block and scrub it.
  var content = best.cloneNode(true);
  content.querySelectorAll("script,style,noscript,iframe,form,button,input,select,textarea,link,nav,aside,footer").forEach(function (n) {
    n.remove();
  });
  // Drop small junk blocks, but never something holding real article body.
  content.querySelectorAll("*").forEach(function (n) {
    if (JUNK.test(hintOf(n)) && n.querySelectorAll("p").length <= 2) n.remove();
  });

  // Build the overlay UI.
  var style = document.createElement("style");
  style.id = "pf-style";
  style.textContent =
    "#pf-overlay{position:fixed;inset:0;z-index:2147483647;overflow:auto;background:#fff;color:#111;" +
    "font:16px/1.6 -apple-system,BlinkMacSystemFont,Georgia,serif;-webkit-font-smoothing:antialiased;}" +
    "#pf-bar{position:sticky;top:0;display:flex;gap:8px;align-items:center;padding:10px 16px;" +
    "background:#1a1a1a;color:#fff;font:13px/1 -apple-system,system-ui,sans-serif;box-shadow:0 1px 6px rgba(0,0,0,.3);}" +
    "#pf-bar b{font-weight:600;margin-right:auto;}" +
    "#pf-bar button{font:13px/1 inherit;color:#fff;background:#333;border:1px solid #555;border-radius:6px;" +
    "padding:7px 12px;cursor:pointer;}" +
    "#pf-bar button:hover{background:#444;}" +
    "#pf-bar #pf-print{background:#2563eb;border-color:#2563eb;}" +
    "#pf-bar #pf-print:hover{background:#1d4ed8;}" +
    "#pf-doc{max-width:720px;margin:0 auto;padding:32px 24px 96px;}" +
    "#pf-doc img{max-width:100%!important;height:auto!important;}" +
    "#pf-doc a{color:#1d4ed8;}" +
    "#pf-doc *{cursor:crosshair;}" +
    "#pf-doc .pf-hi{outline:2px solid #ef4444!important;outline-offset:2px;background:rgba(239,68,68,.08)!important;}" +
    "@media print{body>*:not(#pf-overlay){display:none!important;}" +
    "#pf-overlay{position:static!important;overflow:visible!important;}" +
    "#pf-bar{display:none!important;}#pf-doc{max-width:none;padding:0;}" +
    "#pf-doc *{cursor:auto;}.pf-hi{outline:none!important;background:none!important;}}";
  document.head.appendChild(style);

  var overlay = document.createElement("div");
  overlay.id = OVERLAY_ID;
  overlay.innerHTML =
    '<div id="pf-bar"><b>Reader &mdash; click any block to remove it</b>' +
    '<button id="pf-undo">Undo</button>' +
    '<button id="pf-close">Close</button>' +
    '<button id="pf-print">Save as PDF</button></div>' +
    '<div id="pf-doc"></div>';
  document.body.appendChild(overlay);
  document.getElementById("pf-doc").appendChild(content);

  // Interaction: hover to highlight, click to delete, undo to restore.
  var doc = document.getElementById("pf-doc");
  var undo = [];
  doc.addEventListener("mouseover", function (e) {
    if (e.target !== doc) e.target.classList.add("pf-hi");
  });
  doc.addEventListener("mouseout", function (e) {
    e.target.classList.remove("pf-hi");
  });
  doc.addEventListener("click", function (e) {
    if (e.target === doc) return;
    e.preventDefault();
    e.stopPropagation();
    var n = e.target;
    undo.push({ node: n, parent: n.parentNode, next: n.nextSibling });
    n.remove();
  }, true);

  document.getElementById("pf-undo").onclick = function () {
    var last = undo.pop();
    if (last) last.parent.insertBefore(last.node, last.next);
  };
  document.getElementById("pf-close").onclick = function () {
    overlay.remove();
    style.remove();
  };
  document.getElementById("pf-print").onclick = function () {
    window.print();
  };
})();
