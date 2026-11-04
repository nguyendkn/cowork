# Agent OS design guidelines (Slack-clone tab)

Measurement sheet for `plans/20261103-1633-agent-os-slack-ui` (Phase 00). Every later phase cites rows
by id (`G-xx` geometry, `B-xx` behavior). Not part of the published book (`docs/src/` is).

## Status of this sheet

- 2026-11-03: Slack desktop is not available on the build machine. The user accepted
  `UNVERIFIED -> chosen default + reason` for **every** row, behaviors included (an explicit exception
  to Phase 00's "pixel nits only" rule). Sources: `research/researcher-03-slack-behavior.md` tags
  `[V]` (Slack help pages) and `[3P]`; everything else is our default.
- A row tagged `[V]` follows a fetched official Slack help page; `UNVERIFIED` rows are defaults to
  correct when a live measurement is taken (replace the value, keep the id, note the source shot).
- Colors: never Slack hexes. Every color is a theme key (`cx.theme().colors()`, ADR-6); new keys are
  optional tokens added in Phase 1.
- Fonts: Slack uses Lato (not bundled). UI text = `IBM Plex Sans` (`crates/ui/assets/fonts`), code
  spans/blocks = `Lilex`. No new font.
- Values are logical px at 100% scale, window 1440x900.

## Geometry

| Id | Item | Our value | Theme key | Source |
|---|---|---|---|---|
| G-01 | Workspace/tab rail width | 70 | `sidebar.rail_background` (new) | UNVERIFIED, Slack 2023 layout estimate |
| G-02 | Sidebar width default / min / max drag | 260 / 170 / 420 | `sidebar.background` (new) | UNVERIFIED (3P: 220 default; we use 260 for IBM Plex width) |
| G-03 | Top bar (search) height | 40 | `title_bar.background` | UNVERIFIED |
| G-04 | Channel header height | 49 | `panel.background`, `border` | UNVERIFIED |
| G-05 | Sidebar row height / section header height | 28 / 28 | `list.hover` (new) -> fallback `ghost_element.hover` | UNVERIFIED |
| G-06 | Message avatar size / radius | 36 / 6 | `avatar.1..8` (new) | UNVERIFIED |
| G-07 | Message row padding (v x h) / grouped row padding | 8 x 20 / 2 x 20 | - | UNVERIFIED |
| G-08 | Sender name / body / timestamp font size | 15 bold / 15 / 12 | `text`, `text.muted` | UNVERIFIED |
| G-09 | Hover toolbar: height, offset from row top-right | 32, (-16, 16) | `elevated_surface.background`, `border` | UNVERIFIED |
| G-10 | Reaction chip height / radius / gap | 24 / 12 / 4 | `element.background`, `border.selected` when mine | UNVERIFIED |
| G-11 | Composer min / max height (text area) | 1 line / 10 lines then scroll | `editor.background`, `border.focused` | UNVERIFIED |
| G-12 | Composer box padding / toolbar height | 12 / 32 | `toolbar.background` | UNVERIFIED |
| G-13 | Thread panel width default / min / max | 400 / 300 / 50% of window | `panel.background` | UNVERIFIED |
| G-14 | Split divider hit width / drawn width | 6 / 1 | `border` | UNVERIFIED |
| G-15 | Unread row: weight / mention badge height, min width | bold / 18, 18 | `badge.background`, `badge.text` (new) | UNVERIFIED (3P) |
| G-16 | Presence dot size / ring | 10 / 2 | `presence.online`, `presence.away` (new) -> fallback `status.success`, `text.muted` | UNVERIFIED |
| G-17 | Typing indicator line height, placement | 20, below composer, left aligned | `text.muted` | UNVERIFIED |
| G-18 | New-messages divider | 1px line + "New" label right | `status.error` | UNVERIFIED |
| G-19 | Day divider | 1px line + centered date pill (height 24), sticky at top while scrolling | `border`, `elevated_surface.background` | UNVERIFIED |
| G-20 | Quick switcher width / max results / row height | 600 / 10 / 36 | `elevated_surface.background` | UNVERIFIED |

## Behavior

| Id | Behavior | Our default | Source |
|---|---|---|---|
| B-01 | Message grouping window (same sender, consecutive) | 5 min; a day boundary or a different kind breaks the group | UNVERIFIED |
| B-02 | Grouped row shows time | on hover, left gutter, `12` font | UNVERIFIED |
| B-03 | Hover toolbar actions, left to right | React, Reply in thread, Edit (own), More (`...`: Mark unread, Copy text, Delete own) | UNVERIFIED; Reply in thread `[V]` |
| B-04 | "Also send to channel" | checkbox under the thread composer | `[V]` exists; placement UNVERIFIED |
| B-05 | Mark unread | Alt+click a message, or More > Mark unread | `[V]` |
| B-06 | Message focus | Shift+Tab from the composer focuses the newest message (Up in an empty composer is edit, B-09); Up/Down move; `T` or Right opens the thread; Esc returns to the composer | UNVERIFIED; `T`/Right `[V]` |
| B-07 | Enter / Shift+Enter | Enter sends, Shift+Enter newline; no preference toggle (YAGNI) | UNVERIFIED (3P) |
| B-08 | Formatting keys | `secondary-b` bold, `secondary-i` italic, `secondary-shift-x` strike, `secondary-shift-c` code, `secondary-shift-8` bullets, `secondary-shift-7` numbered; markdown markers, not WYSIWYG | `[V]` keys; rendering = plan deviation |
| B-09 | Up to edit | Up in an empty composer edits the newest own message in the conversation; Esc cancels, Enter saves | `[V]` Up; scope UNVERIFIED |
| B-10 | Mention / channel popups | `@` members + agents, `#` channels; prefix match then recency; max 8; Up/Down + Enter/Tab select, Esc closes | UNVERIFIED |
| B-11 | Slash commands | out of scope (no `/` popup) | plan scope |
| B-12 | Draft persistence | per conversation and per thread, kept across switches and restarts (`draft` table) | UNVERIFIED |
| B-13 | Stick to bottom | when within 48 px of the bottom, new rows keep the view at the bottom | UNVERIFIED |
| B-14 | New-messages pill | shown when a row arrives while scrolled up; label "New messages"; click scrolls to bottom | UNVERIFIED |
| B-15 | History paging | load 50 older rows when within 1 viewport of the top; spinner row at top while loading | UNVERIFIED |
| B-16 | Entering a conversation | scroll to the first unread (new-messages divider) if any, else bottom | UNVERIFIED |
| B-17 | Esc / Shift+Esc | Esc marks the open conversation read; Shift+Esc marks all read | `[V]` |
| B-18 | Unreads view | sidebar top item; per-conversation previews; sort: sidebar order, A-Z, newest, oldest; "Mark all read" | `[V]` |
| B-19 | Muted / archived | excluded from Unreads and badges; muted rows drawn `text.muted` | `[V]` |
| B-20 | Sidebar sections | collapsible (disclosure triangle), collapse state persisted (`ui_state`); no drag reorder | UNVERIFIED; drag = out of scope |
| B-21 | Thread notifications | DM with one agent: all replies; channels: if started, replied or mentioned; per-thread follow toggle | `[V]` |
| B-22 | Thread panel close | close button and Esc (when focus is in the panel) | UNVERIFIED |
| B-23 | Toggle right panel | `secondary-.` | `[V]` row exists, keys UNVERIFIED |
| B-24 | Quick switcher open | `secondary-k` (Ctrl+K on Windows/Linux, Cmd+K on macOS); `secondary-t` not bound | Ctrl+K `[V]`; Mac UNVERIFIED (gpui `secondary-` maps to Cmd) |
| B-25 | Switcher ranking / results | channels, DMs, agents; exact prefix > word prefix > substring, ties by recent activity; Up/Down, Enter opens, Esc closes | UNVERIFIED |
| B-26 | Shortcut list | `secondary-/` opens the shortcut help | `[V]` |
| B-27 | New message | `secondary-n` opens new conversation picker | `[V]` |
| B-28 | Typing indicator | "<name> is typing..." shown 5 s after the last keystroke event; agents: "<name> is thinking..." while a stream is open | UNVERIFIED; agent status `[V]` (2 min idle clear) |
| B-29 | Presence states | online (agent process connected), away (idle 10 min), offline; dot on avatar and sidebar DM rows | UNVERIFIED |

## Docs location decision (Phase 00 step 1 / 5)

`docs/` submodule was already initialized (aa1fb0d) with `docs/tools/ui-driver.ps1` and
`docs/tools/ui-layout.ps1`: **no vendoring**. Phase 1 adds the `launcher-agent-os` target to
`docs/tools/ui-layout.ps1`; Phases 6 and 8 add their click targets there additively.

## Screenshot checklist (Phase 8 verifies each, light + dark)

| # | Screen / state |
|---|---|
| 1 | Sidebar: default, a collapsed section, unread bold + mention badge, muted row |
| 2 | Timeline: grouped rows, hover toolbar, reactions, day divider, new-messages divider |
| 3 | Scrolled up with the new-messages pill |
| 4 | Thread panel open (split), "also send to channel" checked |
| 5 | Composer: wrapped multi-line text, mention popup open, Vietnamese text |
| 6 | Quick switcher with results |
| 7 | Agent streaming row + "is thinking..." |
| 8 | Permission card (pending, default focus Deny) |
| 9 | Empty states: no conversations, empty conversation, loading |
