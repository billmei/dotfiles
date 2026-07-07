# bookmarklets

Browser-side companions to the shell functions in [`../.functions`](../.functions).

## bookmark-pdf

The browser equivalent of the `bookmark` shell function. Where `bookmark` mirrors
a static page with `wget`, this saves whatever you're **currently looking at** —
including logged-in and JavaScript-rendered pages — as a full-page PDF with
selectable text and images preserved.

A bookmarklet runs inside the browser sandbox and can't write files directly, so
it opens the native print dialog. In that dialog:

1. Choose **Save as PDF** as the destination.
2. Save into `~/Dropbox/bookmarks` (the page title is the default filename).

Before printing, it forces lazy-loaded images to load so they don't come out
blank in the PDF.

### Install

Create a new bookmark in your bookmarks bar and paste this as the **URL/location**
(name it "Bookmark PDF" or similar):

```
javascript:(function()%7Bdocument.querySelectorAll(%22img%22).forEach(function(i)%7Bi.loading=%22eager%22%3B%5B%22data-src%22%2C%22data-original%22%2C%22data-lazy-src%22%2C%22data-actualsrc%22%5D.forEach(function(a)%7Bvar v=i.getAttribute(a)%3Bif(v)i.src=v%7D)%3Bvar s=i.getAttribute(%22data-srcset%22)%3Bif(s)i.srcset=s%7D)%3Bvar y=window.scrollY%3Bwindow.scrollTo(0%2Cdocument.body.scrollHeight)%3BsetTimeout(function()%7Bwindow.scrollTo(0%2C0)%3BsetTimeout(function()%7Bwindow.scrollTo(0%2Cy)%3Bwindow.print()%7D%2C500)%7D%2C500)%7D)()
```

The readable source is in [`bookmark-pdf.js`](bookmark-pdf.js). If you edit it,
regenerate the one-liner above: strip the comments, collapse to a single line,
URL-encode it, and prefix with `javascript:`.

### Tip: default the save folder

Browsers remember the last "Save as PDF" location, so after you point it at
`~/Dropbox/bookmarks` once it'll stay there. To make the print output cleaner,
most browsers also have "Save as PDF" options to disable headers/footers and set
"Background graphics" on to keep images and page colors.
