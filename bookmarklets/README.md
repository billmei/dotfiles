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

### Install

New bookmark, paste this as the URL:

```
javascript:%28function%20%28%29%20%7B%20var%20OVERLAY_ID%20%3D%20%22pf-overlay%22%3B%20if%20%28document.getElementById%28OVERLAY_ID%29%29%20%7B%20window.print%28%29%3B%20return%3B%20%7D%20var%20JUNK%20%3D%20%2Fcomment%7Cdisqus%7Creply%7Cfootnote%7Csidebar%7Csponsor%7Cadvert%7Cadsense%7Cbanner%7Cshare%7Csocial%7Crelated%7Crecommend%7Cnewsletter%7Csubscribe%7Cpopup%7Cmodal%7Cpromo%7Cbreadcrumb%7Cpagination%7Ccookie%7Cwidget%7Cmasthead%7Cutility%2Fi%3B%20var%20GOOD%20%3D%20%2Farticle%7Ccontent%7Cpost%7Cstory%7Centry%7Cmain%7Cbody%7Cprose%7Cmarkdown%2Fi%3B%20function%20hintOf%28el%29%20%7B%20return%20%28%28%28el.className%20%26%26%20el.className.toString%28%29%29%20%7C%7C%20%22%22%29%20%2B%20%22%20%22%20%2B%20%28el.id%20%7C%7C%20%22%22%29%29%3B%20%7D%20function%20linkDensity%28el%29%20%7B%20var%20t%20%3D%20%28el.innerText%20%7C%7C%20%22%22%29.length%3B%20if%20%28%21t%29%20return%200%3B%20var%20l%20%3D%200%3B%20el.querySelectorAll%28%22a%22%29.forEach%28function%20%28a%29%20%7B%20l%20%2B%3D%20%28a.innerText%20%7C%7C%20%22%22%29.length%3B%20%7D%29%3B%20return%20l%20%2F%20t%3B%20%7D%20document.querySelectorAll%28%22img%22%29.forEach%28function%20%28img%29%20%7B%20img.loading%20%3D%20%22eager%22%3B%20%5B%22data-src%22%2C%20%22data-original%22%2C%20%22data-lazy-src%22%2C%20%22data-actualsrc%22%5D.forEach%28function%20%28a%29%20%7B%20var%20v%20%3D%20img.getAttribute%28a%29%3B%20if%20%28v%29%20img.src%20%3D%20v%3B%20%7D%29%3B%20var%20ss%20%3D%20img.getAttribute%28%22data-srcset%22%29%3B%20if%20%28ss%29%20img.srcset%20%3D%20ss%3B%20%7D%29%3B%20function%20score%28el%29%20%7B%20var%20text%20%3D%20el.innerText%20%7C%7C%20%22%22%3B%20if%20%28text.length%20%3C%20140%29%20return%200%3B%20var%20s%20%3D%20text.length%20%2B%20el.querySelectorAll%28%22p%22%29.length%20%2A%2080%3B%20var%20hint%20%3D%20hintOf%28el%29%3B%20if%20%28JUNK.test%28hint%29%29%20s%20%2A%3D%200.25%3B%20if%20%28GOOD.test%28hint%29%29%20s%20%2A%3D%201.5%3B%20s%20%2A%3D%201%20-%20Math.min%28linkDensity%28el%29%2C%200.9%29%20%2A%200.6%3B%20return%20s%3B%20%7D%20var%20best%20%3D%20document.body%2C%20bestScore%20%3D%200%3B%20document.querySelectorAll%28%22article%2C%20main%2C%20%5Brole%3Dmain%5D%2C%20section%2C%20div%22%29.forEach%28function%20%28el%29%20%7B%20var%20s%20%3D%20score%28el%29%3B%20if%20%28el.tagName%20%3D%3D%3D%20%22ARTICLE%22%20%7C%7C%20el.tagName%20%3D%3D%3D%20%22MAIN%22%20%7C%7C%20el.getAttribute%28%22role%22%29%20%3D%3D%3D%20%22main%22%29%20s%20%2A%3D%201.4%3B%20if%20%28s%20%3E%20bestScore%29%20%7B%20bestScore%20%3D%20s%3B%20best%20%3D%20el%3B%20%7D%20%7D%29%3B%20var%20content%20%3D%20best.cloneNode%28true%29%3B%20content.querySelectorAll%28%22script%2Cstyle%2Cnoscript%2Ciframe%2Cform%2Cbutton%2Cinput%2Cselect%2Ctextarea%2Clink%2Cnav%2Caside%2Cfooter%22%29.forEach%28function%20%28n%29%20%7B%20n.remove%28%29%3B%20%7D%29%3B%20content.querySelectorAll%28%22%2A%22%29.forEach%28function%20%28n%29%20%7B%20if%20%28JUNK.test%28hintOf%28n%29%29%20%26%26%20n.querySelectorAll%28%22p%22%29.length%20%3C%3D%202%29%20n.remove%28%29%3B%20%7D%29%3B%20var%20style%20%3D%20document.createElement%28%22style%22%29%3B%20style.id%20%3D%20%22pf-style%22%3B%20style.textContent%20%3D%20%22%23pf-overlay%7Bposition%3Afixed%3Binset%3A0%3Bz-index%3A2147483647%3Boverflow%3Aauto%3Bbackground%3A%23fff%3Bcolor%3A%23111%3B%22%20%2B%20%22font%3A16px%2F1.6%20-apple-system%2CBlinkMacSystemFont%2CGeorgia%2Cserif%3B-webkit-font-smoothing%3Aantialiased%3B%7D%22%20%2B%20%22%23pf-bar%7Bposition%3Asticky%3Btop%3A0%3Bdisplay%3Aflex%3Bgap%3A8px%3Balign-items%3Acenter%3Bpadding%3A10px%2016px%3B%22%20%2B%20%22background%3A%231a1a1a%3Bcolor%3A%23fff%3Bfont%3A13px%2F1%20-apple-system%2Csystem-ui%2Csans-serif%3Bbox-shadow%3A0%201px%206px%20rgba%280%2C0%2C0%2C.3%29%3B%7D%22%20%2B%20%22%23pf-bar%20b%7Bfont-weight%3A600%3Bmargin-right%3Aauto%3B%7D%22%20%2B%20%22%23pf-bar%20button%7Bfont%3A13px%2F1%20inherit%3Bcolor%3A%23fff%3Bbackground%3A%23333%3Bborder%3A1px%20solid%20%23555%3Bborder-radius%3A6px%3B%22%20%2B%20%22padding%3A7px%2012px%3Bcursor%3Apointer%3B%7D%22%20%2B%20%22%23pf-bar%20button%3Ahover%7Bbackground%3A%23444%3B%7D%22%20%2B%20%22%23pf-bar%20%23pf-print%7Bbackground%3A%232563eb%3Bborder-color%3A%232563eb%3B%7D%22%20%2B%20%22%23pf-bar%20%23pf-print%3Ahover%7Bbackground%3A%231d4ed8%3B%7D%22%20%2B%20%22%23pf-doc%7Bmax-width%3A720px%3Bmargin%3A0%20auto%3Bpadding%3A32px%2024px%2096px%3B%7D%22%20%2B%20%22%23pf-doc%20img%7Bmax-width%3A100%25%21important%3Bheight%3Aauto%21important%3B%7D%22%20%2B%20%22%23pf-doc%20a%7Bcolor%3A%231d4ed8%3B%7D%22%20%2B%20%22%23pf-doc%20%2A%7Bcursor%3Acrosshair%3B%7D%22%20%2B%20%22%23pf-doc%20.pf-hi%7Boutline%3A2px%20solid%20%23ef4444%21important%3Boutline-offset%3A2px%3Bbackground%3Argba%28239%2C68%2C68%2C.08%29%21important%3B%7D%22%20%2B%20%22%40media%20print%7Bbody%3E%2A%3Anot%28%23pf-overlay%29%7Bdisplay%3Anone%21important%3B%7D%22%20%2B%20%22%23pf-overlay%7Bposition%3Astatic%21important%3Boverflow%3Avisible%21important%3B%7D%22%20%2B%20%22%23pf-bar%7Bdisplay%3Anone%21important%3B%7D%23pf-doc%7Bmax-width%3Anone%3Bpadding%3A0%3B%7D%22%20%2B%20%22%23pf-doc%20%2A%7Bcursor%3Aauto%3B%7D.pf-hi%7Boutline%3Anone%21important%3Bbackground%3Anone%21important%3B%7D%7D%22%3B%20document.head.appendChild%28style%29%3B%20var%20overlay%20%3D%20document.createElement%28%22div%22%29%3B%20overlay.id%20%3D%20OVERLAY_ID%3B%20overlay.innerHTML%20%3D%20%27%3Cdiv%20id%3D%22pf-bar%22%3E%3Cb%3EReader%20%26mdash%3B%20click%20any%20block%20to%20remove%20it%3C%2Fb%3E%27%20%2B%20%27%3Cbutton%20id%3D%22pf-undo%22%3EUndo%3C%2Fbutton%3E%27%20%2B%20%27%3Cbutton%20id%3D%22pf-close%22%3EClose%3C%2Fbutton%3E%27%20%2B%20%27%3Cbutton%20id%3D%22pf-print%22%3ESave%20as%20PDF%3C%2Fbutton%3E%3C%2Fdiv%3E%27%20%2B%20%27%3Cdiv%20id%3D%22pf-doc%22%3E%3C%2Fdiv%3E%27%3B%20document.body.appendChild%28overlay%29%3B%20document.getElementById%28%22pf-doc%22%29.appendChild%28content%29%3B%20var%20doc%20%3D%20document.getElementById%28%22pf-doc%22%29%3B%20var%20undo%20%3D%20%5B%5D%3B%20doc.addEventListener%28%22mouseover%22%2C%20function%20%28e%29%20%7B%20if%20%28e.target%20%21%3D%3D%20doc%29%20e.target.classList.add%28%22pf-hi%22%29%3B%20%7D%29%3B%20doc.addEventListener%28%22mouseout%22%2C%20function%20%28e%29%20%7B%20e.target.classList.remove%28%22pf-hi%22%29%3B%20%7D%29%3B%20doc.addEventListener%28%22click%22%2C%20function%20%28e%29%20%7B%20if%20%28e.target%20%3D%3D%3D%20doc%29%20return%3B%20e.preventDefault%28%29%3B%20e.stopPropagation%28%29%3B%20var%20n%20%3D%20e.target%3B%20undo.push%28%7B%20node%3A%20n%2C%20parent%3A%20n.parentNode%2C%20next%3A%20n.nextSibling%20%7D%29%3B%20n.remove%28%29%3B%20%7D%2C%20true%29%3B%20document.getElementById%28%22pf-undo%22%29.onclick%20%3D%20function%20%28%29%20%7B%20var%20last%20%3D%20undo.pop%28%29%3B%20if%20%28last%29%20last.parent.insertBefore%28last.node%2C%20last.next%29%3B%20%7D%3B%20document.getElementById%28%22pf-close%22%29.onclick%20%3D%20function%20%28%29%20%7B%20overlay.remove%28%29%3B%20style.remove%28%29%3B%20%7D%3B%20document.getElementById%28%22pf-print%22%29.onclick%20%3D%20function%20%28%29%20%7B%20window.print%28%29%3B%20%7D%3B%20%7D%29%28%29%3B
```

The readable source is [`reader-pdf.js`](reader-pdf.js). To regenerate the
one-liner after editing it, strip the `//` comment lines, collapse to one line,
URL-encode, and prefix with `javascript:`.
