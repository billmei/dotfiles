// bookmark-pdf — browser bookmarklet companion to the `bookmark` shell function.
//
// The shell `bookmark` function (see ../.functions) mirrors a static page with
// wget. This does the browser-side equivalent: it saves whatever you're
// currently looking at — including logged-in / JS-rendered pages that wget
// can't reach — as a full-page PDF that preserves selectable text and images.
//
// Because a bookmarklet runs inside the browser sandbox it can't write files
// directly, so this triggers the native print dialog. In that dialog choose
// "Save as PDF" and point it at ~/Dropbox/bookmarks. The page title is used as
// the default filename.
//
// Before printing it forces lazy-loaded images to load (many sites defer
// images with loading="lazy" or data-src attributes, which otherwise show up
// blank in the PDF) by promoting those attributes and scrolling the whole page
// once to wake up lazy loaders.
//
// This file is the readable source. The minified one-line `javascript:` URL you
// actually drag into your bookmarks bar lives in README.md — regenerate it from
// this file whenever you edit here.

(function () {
  // Promote deferred/lazy image sources so they render in the print output.
  document.querySelectorAll("img").forEach(function (img) {
    img.loading = "eager";
    ["data-src", "data-original", "data-lazy-src", "data-actualsrc"].forEach(
      function (attr) {
        var v = img.getAttribute(attr);
        if (v) img.src = v;
      }
    );
    var srcset = img.getAttribute("data-srcset");
    if (srcset) img.srcset = srcset;
  });

  // Scroll through the page to trigger lazy loaders, restore position, print.
  var start = window.scrollY;
  window.scrollTo(0, document.body.scrollHeight);
  setTimeout(function () {
    window.scrollTo(0, 0);
    setTimeout(function () {
      window.scrollTo(0, start);
      window.print();
    }, 500);
  }, 500);
})();
