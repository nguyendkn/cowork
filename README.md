# Cowork Docs

User documentation for Cowork, ported from [Zed's docs](../../other/docs) and rewritten for what the app actually does. It is an [mdBook](https://rust-lang.github.io/mdBook/): pages in `src/`, table of contents in `src/SUMMARY.md`.

[`src/reference/zed-docs-map.md`](src/reference/zed-docs-map.md) maps every Zed page to its Cowork page, or says why it has none.

## Install Cowork with an AI Agent

Paste this prompt into a coding agent (Claude Code, Codex, Cursor, ...) that can run shell commands on the machine where Cowork should be installed:

````text
Install the Cowork desktop app on this machine from its latest GitHub release.

Source: https://github.com/nguyendkn/cowork/releases/latest (repository nguyendkn/cowork).
Assets are named cowork-<tag>-<platform>.<ext>, plus SHA256SUMS.txt.

1. Detect the OS and CPU (uname -s / uname -m, or $env:OS and $env:PROCESSOR_ARCHITECTURE on
   Windows). Pick the installer:
   - Windows x64:        cowork-<tag>-windows-x86_64-setup.exe
   - macOS Apple silicon (arm64):  cowork-<tag>-macos-aarch64.dmg
   - macOS Intel (x86_64):         cowork-<tag>-macos-x86_64.dmg
   - Ubuntu/Debian x64:  cowork-<tag>-linux-x86_64.deb
   Any other system or CPU: stop and tell me, do not guess.
2. Download the installer and SHA256SUMS.txt into a new temporary directory, for example with
   `gh release download --repo nguyendkn/cowork --pattern "<asset>" --pattern SHA256SUMS.txt`,
   or curl against https://api.github.com/repos/nguyendkn/cowork/releases/latest.
3. Verify the installer's SHA-256 against SHA256SUMS.txt. If it does not match, stop and report.
4. Install:
   - Windows (PowerShell): Start-Process <setup.exe> -ArgumentList '/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART' -Wait
     (installs for the current user under %LOCALAPPDATA%\Programs\Cowork).
   - macOS: hdiutil attach -nobrowse -readonly -mountpoint /tmp/cowork-dmg <dmg>;
     cp -R /tmp/cowork-dmg/Cowork.app /Applications/; hdiutil detach /tmp/cowork-dmg.
   - Linux: sudo apt install ./<deb>  (ask me first if sudo needs a password).
5. Check that it is installed (Windows: the app.exe and unins000.exe in the install folder;
   macOS: /Applications/Cowork.app; Linux: `dpkg -s cowork` and `command -v cowork`).
6. Delete the temporary directory and report the installed version (the release tag) and where
   Cowork is.

Rules: the builds are not signed with a developer certificate. Do not turn off SmartScreen,
Gatekeeper or any other security feature and do not remove the macOS quarantine attribute
yourself. Tell me instead: on Windows choose "More info", then "Run anyway"; on macOS Control-click
Cowork in Applications, choose Open, then Open again. Do not start Cowork unless I ask. Change
nothing outside the install location and the temporary directory.
````

The installers, their first-launch steps and how to uninstall are described in [Installation](src/installation.md).

## Build and Preview

```sh
cargo install mdbook --locked    # once
make docs                        # builds docs/book/
make docs-serve                  # serves with live reload
```

`make docs` (in the app repository) first regenerates the shortcuts reference page and `tools/action-table.json`, the table of what the commands below expand to. On every build mdBook runs `tools/expand-macros.py` (Python only, no Rust) over the pages; `tools/test_expand_macros.py` tests it.

Outside the app repository (a fresh clone of just this repo, or CI) `mdbook build` works as is, because the table is checked in.

## Publishing

Every push to `main` runs [`.github/workflows/pages.yml`](.github/workflows/pages.yml): it tests the expander, builds the book with mdBook and deploys it to GitHub Pages at https://nguyendkn.github.io/cowork/. Pull requests only build. The app repository's tests fail when `tools/action-table.json` or the shortcuts page is stale, so run `make docs-actions docs-shortcuts` there after changing shortcuts, commit here, then update the submodule pointer.

## Writing Rules

These follow Zed's `docs/AGENTS.md`, adjusted for Cowork.

### Document what exists

Describe only what the current build does. If a feature is unfinished, leave it out; do not write "coming soon". When a Zed page covers something Cowork lacks, it gets a row in the Zed docs map, not a page.

### Page layout

- Front matter with `title` and `description` (one sentence, about what the reader can do).
- One `#` heading, the same as the title. Sections are `##`, and each section a reader may link to has an anchor: `## Rebinding a Shortcut {#rebinding}`. Anchors are lowercase, hyphenated and unique within the page.
- Add every page to `src/SUMMARY.md`.
- Link to other pages with relative paths (`./editor.md#line-commands`).

### Key bindings and actions

Never hard-code a shortcut or a command name. Use the preprocessor commands:

| Write                       | It becomes                         |
| --------------------------- | ---------------------------------- |
| `{#kb editor::Save}`        | `` `Ctrl+S` ``                     |
| `{#kb workspace::ActivatePaneLeft}` | `` `Ctrl+K Ctrl+Left` ``   |
| `{#action editor::Save}`    | `` `editor: save` ``               |

`{#kb}` reads the editor's live shortcut table, plus the window-level bindings listed in `crates/docs/src/lib.rs` (`EXTRA_BINDINGS`). A test checks that list against the source that binds the keys. An action the preprocessor does not know fails the build, which is how a renamed action is caught.

Shortcuts that belong to a context with no table (the terminal's keys) are written out by hand in the page that covers them.

### Reference pages are generated

`src/reference/default-shortcuts.md` is generated by `make docs-shortcuts`. Do not edit it; a test fails when it is stale.

### Screenshots

Screenshots are captured from the real app, never mocked or drawn.

```sh
make docs-screenshots                                 # every scene
pwsh docs/tools/capture-screenshots.ps1 -Scene find   # one scene
```

The script starts the app with a throw-away config folder, places the window at 1280x800, drives it with the mouse and keyboard, and saves PNGs to `src/images/`. It takes about a minute: **leave the PC alone while it runs**, and keep the screen unlocked. Text is typed with Unicode input events, so an active input method (Telex, Pinyin) cannot change it, and the clipboard is not touched.

- Name images after the feature: `command-palette.png`, `split-panes.png`.
- Every image has alt text that says what to look at.
- To add a screenshot, add a scene to `docs/tools/capture-screenshots.ps1`, run it, and reference the image from the page. Do not commit hand-edited images: if a screenshot is wrong, fix the scene and capture again.
- Capture again after any visible UI change. Scenes call `Start-Cowork`, drive the UI, then `Save-Shot`; see `docs/tools/ui-driver.ps1` for the helpers.

### Formatting

Pages are formatted with Prettier (80 columns, prose not re-wrapped):

```sh
cd docs && npx prettier --write src/
cd docs && npx prettier --check src/
```

## Checks

Text input in other languages has its own end-to-end check against the real app: `pwsh tools/check-vietnamese.ps1` (Unicode input, Telex through the active input method, search, address bar). Its unit-level twins are `crates/editor/tests/vietnamese.rs` and `crates/ui/tests/text_field_vietnamese.rs`.

`cargo test -p docs` verifies that every `{#kb}` and `{#action}` resolves, that the bindings table matches the source, that the shortcuts reference is up to date, and that every page in `SUMMARY.md` exists and every relative link and image resolves.
