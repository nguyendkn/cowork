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

On by default (**Block Ads** on the Browser page of [Settings](./settings.md#browser); reload a page after changing it). Page addresses you open yourself are never blocked, only what a page loads.

The toolbar shows a shield icon next to the address bar with a small badge at its bottom-right corner: the number of requests blocked on the page you are on (shown as 99+ past 99). It starts again from zero with each new page, and is hidden when nothing was blocked.

Blocking works at three levels, the same ones uBlock Origin uses:

- **Requests** to ad and tracker servers are cancelled. A request that a filter replaces (`$redirect`) gets a harmless stand-in (an empty script, a transparent pixel) so pages that wait for it keep working, and tracking parameters are stripped from URLs (`$removeparam`).
- **Hiding**: ad slots are hidden before the page paints, both the ones a filter names for the site and, as the page builds, every element whose class or id EasyList lists as an ad. Procedural filters (`:has-text`, `:has`, `:upward`, `:xpath`, `:matches-css`, `:remove()`, `:style()`) are applied as the page changes.
- **Scriptlets** (`##+js(...)` filters) run before any script of the page. They defuse ad scripts, anti-ad-blocker traps, pop-ups and timers, and cut the ad fields out of responses such as YouTube's player data, so video ads are not shown.

The rules use the uBlock Origin / EasyList syntax. A small list is built in. These public lists are downloaded into `%LOCALAPPDATA%\cowork\filters\` the first time and refreshed when they are older than 4 days (checked every 6 hours while the app runs): EasyList, EasyPrivacy, the uBlock filters (including badware, privacy, quick fixes, unbreak and the yearly lists) and Peter Lowe's ad server list. A failed download keeps the old copy, and the new rules apply without a restart (to pages opened afterwards). Your own lists go there too, as `*.txt` files, and are read at startup.

About 30 scriptlets are built in, including the ones the lists use most (`set`, `aopr`, `aopw`, `acs`, `aost`, `nowoif`, `nostif`, `nosiif`, `aeld`, `rmnt`, `rpnt`, `json-prune`, `no-fetch-if`, `no-xhr-if`, `json-prune-fetch-response`, `trusted-replace-xhr-response`, `trusted-rpfr`), so they work offline from the first start. Limits: a scriptlet the list asks for that is not built in is skipped (for example `trusted-edit-inbound-object`, which YouTube's newest rules also use), and HTML filtering (`$replace`) and `$csp` are not applied. Filters apply to every frame of a page, except pages that are not http(s).

## Tab Audio Stream {#audio-stream}

While the page you are on makes sound, a waveform button appears next to the address bar (left of the Picture-in-Picture button). It is hidden on a silent page.

- **Crossed-out waveform**: the stream is off. This is the default for every page; nothing is encoded or sent anywhere.
- **Plain waveform, highlighted**: the stream is on. The page's sound is encoded as MP3 (128 kbps; mono stays mono, anything else becomes stereo) for other parts of the app, such as a live translator or a voice agent. Click again to turn it off.

The sound keeps playing through your speakers either way. The setting belongs to the page tab and starts off again on a new page tab. Only code inside the app can read the stream (`BrowserView::subscribe_audio`); it is not served on the network.

## Profiles {#profiles}

A profile keeps its own cookies, site data, history and settings, like Chrome's profiles. The round avatar at the right end of the toolbar (right of the ad-block shield) shows the profile this tab runs in: the first letter of its name on its color. Click it to open the profile panel.

- **Switch**: click a profile. The tab's pages reload in that profile; a tab that is still blank opens the profile's start pages. Each browser tab remembers its profile across restarts.
- **Add profile**, **Import** and **Trash** sit at the right of the sort dropdown (sort by name, last used or newest). Search matches a profile's name and note.
- **Edit** (pencil): name, note, avatar color, pages to open on start, **Incognito** (nothing is kept; everything is gone when the last tab using it closes) and **Clear browsing data on exit** (cookies, history, site data and caches are wiped when the app closes; bookmarks and preferences stay). **Duplicate** copies the settings and the data without caches; **Export** writes a folder `<name>.cowork-profile` to your Downloads folder.
- **Delete** moves a profile, with its data, to the **Trash**, where it can be restored for 30 days. A profile an open tab is using cannot be deleted. The Default profile cannot be deleted or made incognito.
- **Import** lists the profiles of Chrome, Chromium, Edge, Brave and Vivaldi on this computer, and imports an exported `.cowork-profile` folder (type its path). Bookmarks, settings, history and site data are copied; cookies and saved passwords are not, because the other browser encrypts them with a key only it can read.

The profile list is stored in `browser-data/profiles/profiles.json` next to the browser's cache folder.

## Agents {#agents}

An agent can drive a browser tab with the `browser` tool (found with `tool_search`). The agent reads a page as text, where each button, field or link has a ref like `e3`, then acts on the refs: open, click, fill, type, press keys, select, check, scroll, drag, upload, wait, find by role, text or label, read the console and network, take a screenshot (saved as a PNG file), and handle JavaScript dialogs.

- **Its own tabs.** An agent works in tabs of its own, beside yours; two agents never share a tab. Each action shows the agent's tab, so you can watch it work. Closing the agent's tab is fine: it gets a new one on its next action, and your tabs are never touched.
- **It asks before risky things.** Running script on the page, filling a password field, sending a file and saving a download show a card over the page with **Allow** and **Deny**. No answer within two minutes counts as "no".
- **Page text is data.** Everything the page says is fenced as untrusted content in the agent's context.
- **Limits.** A page from another site embedded in a frame cannot be read, and a screenshot needs the window to be showing (a hidden or minimized window produces no frames; the agent is told so instead of waiting).

## Requirements {#requirements}

The browser needs the CEF runtime next to the executable; see [Installation](./installation.md#shipping). If it is missing the tab shows "CEF is not running". The page cache and a log (`cef.log`) are kept in `%LOCALAPPDATA%\cowork\`.
