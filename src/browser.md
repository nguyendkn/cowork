---
title: Browser
description: Real Chromium pages in a tab, with an address bar, back and reload, and tabs of their own.
---

# Browser

Choose **Browser** on the [launcher](./getting-started.md#launcher) for a web page that lives in a Cowork tab. Pages are rendered by Chromium (through CEF), so sites behave as they do in any Chromium browser.

![A browser tab with a second page tab showing a page](./images/browser.png)

A new browser tab starts on a blank page:

![A new browser tab: toolbar and an empty page](./images/browser-new-tab.png)

## The Toolbar {#toolbar}

Across the top of the browser tab:

- a strip of page tabs, with a button to add one. These are tabs **inside** the browser tab, so one Cowork tab can hold several pages;
- **back** and **reload** buttons;
- the address bar.

Type an address in the bar and press `Enter` to load it. What you type is turned into a URL like this:

| You type                     | Cowork loads          |
| ---------------------------- | --------------------- |
| `example.com`                | `https://example.com` |
| `https://example.com/page`   | the same URL          |
| `http://localhost:3000`      | the same URL          |
| `file:///C:/notes/page.html` | the same file         |
| `about:blank`                | a blank page          |
| nothing                      | a blank page          |

`http://`, `https://`, `file://`, `about:` and `data:` addresses are kept as typed; anything else gets `https://` in front. The bar does not search the web: a plain word becomes `https://word`.

## Page Tabs {#page-tabs}

Add a page tab with the `+` in the browser's own strip (it opens your home page, `about:blank` unless you changed it on the Browser page of [Settings](./settings.md#browser)), switch by clicking, and close a page tab with its close button. Closing the last one leaves a blank page. The Cowork tab's title follows the page you are on.

## Splitting {#splitting}

Splitting a browser tab opens a new browser with one blank page. Open pages are not duplicated.

## Sessions {#sessions}

Your open pages are remembered (unless **Restore Pages** is turned off in [Settings](./settings.md#browser)): after a restart the browser tab comes back with every page tab and its address, and which one was active. The pages are loaded again; form input and scroll position are not kept.

## Ad Blocking {#ad-blocking}

On by default (**Block Ads** on the Browser page of [Settings](./settings.md#browser); reload a page after changing it). Requests to known ad networks are cancelled and ad slots are hidden. Page addresses you open yourself are never blocked, only what a page loads.

The toolbar shows "N blocked" next to the address bar for the page you are on (it starts again from zero with each new page, and is hidden when nothing was blocked).

The rules use the uBlock Origin / EasyList syntax (`||host^`, `@@` exceptions, `$third-party`, `$script,image`, `$domain=`, `site.com##.selector`). A small list is built in. EasyList and the uBlock filters list are downloaded into `%LOCALAPPDATA%\cowork\filters\` the first time and refreshed when they are older than 4 days (checked every 6 hours while the app runs); a failed download keeps the old copy, and the new rules apply without a restart. Your own lists go there too, as `*.txt` files, and are read at startup. Limits: only hiding rules that name a site or an attribute are applied (not class/id-only generic ones), and procedural filters (`:has-text`, `:xpath`) and scriptlets need resources the app does not ship.

## Requirements {#requirements}

The browser needs the CEF runtime next to the executable; see [Installation](./installation.md#shipping). If it is missing the tab shows "CEF is not running". The page cache and a log (`cef.log`) are kept in `%LOCALAPPDATA%\cowork\`.
