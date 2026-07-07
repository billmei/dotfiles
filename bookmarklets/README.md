# bookmarklets

Browser-side companions to the shell functions in [`../.functions`](../.functions).

Each bookmarklet has a readable `*.js` source and a compiled `*-min.js` file.
The `*-min.js` file holds a single `javascript:` URL — **that** is what you
install. To install a bookmarklet, create a new bookmark in your bookmarks bar
and paste the entire contents of its `*-min.js` file as the **URL/location**.

## Building

The `*-min.js` files are generated from the sources by [`build.js`](build.js) —
never edit them by hand. After changing a source, rebuild:

```
deno run --allow-read --allow-write build.js
# or, from this directory:  ./build.js
# (Node 18+ also works:      node build.js)
```

The build is deterministic: it strips comments, collapses each source to one
line, URL-encodes it, and prefixes `javascript:`. Same input → byte-identical
output, so a rebuild only shows up in `git diff` when a source actually changed.

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

Install: paste [`bookmark-pdf-min.js`](bookmark-pdf-min.js) into a bookmark's URL
field. Source: [`bookmark-pdf.js`](bookmark-pdf.js).

### Tip: default the save folder

Browsers remember the last "Save as PDF" location, so after you point it at
`~/Dropbox/bookmarks` once it'll stay there. To make the print output cleaner,
most browsers also have "Save as PDF" options to disable headers/footers and set
"Background graphics" on to keep images and page colors.

## reader-pdf

A self-contained, PrintFriendly-style version. Instead of printing the page
as-is, it extracts the **main article** and strips clutter (nav, sidebars,
footers, comments, ads, share/related/newsletter blocks), then shows an on-screen
reader with a toolbar:

- **Hover + click** any remaining block to delete it.
- **Undo** restores the last deletion.
- **Save as PDF** opens the print dialog showing only the cleaned content — pick
  Save as PDF into `~/Dropbox/bookmarks`.
- **Close** dismisses the overlay and leaves the page untouched.

Unlike PrintFriendly's bookmarklet (which loads a script from
`cdn.printfriendly.com` and sends the page to their servers), this runs entirely
locally with no external dependencies or network calls. Run it a second time on
the same page and it just re-opens the print dialog.

The content extraction is a compact heuristic (paragraph density, link density,
class/id hints), so on unusual layouts it may pick the wrong block or leave some
clutter — that's what the click-to-delete editor is for.

Install: paste [`reader-pdf-min.js`](reader-pdf-min.js) into a bookmark's URL
field. Source: [`reader-pdf.js`](reader-pdf.js).
