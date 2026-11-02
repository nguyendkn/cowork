---
title: Release Notes
description: What changed in each Cowork release, newest first.
---

# Release Notes

Installers for every release are on the [Releases page](https://github.com/nguyendkn/cowork/releases).
Release tags look like `v0.1.<YYYYMMDD><N>`: the build date, then the day's counter.

## Unreleased

## v0.1.202611027 (2026-11-02)

### Fixes

- **Linux**: the `.deb` and the `.tar.gz` now include the browser runtime (`libcef.so`, the `.pak` files and `locales/`). The first release, `v0.1.202611026`, shipped without them and did not start; use this release instead.
- The release build now fails when the browser runtime is missing from a package, so this cannot ship unnoticed again.

## v0.1.202611026 (2026-11-02)

First release with installers for all three platforms.

### Installers

- **Windows**: `cowork-<version>-windows-x86_64-setup.exe` (Inno Setup; installs for the current user by default, adds a Start menu entry, an optional desktop icon and an uninstaller).
- **macOS**: `cowork-<version>-macos-aarch64.dmg` (Apple silicon) and `cowork-<version>-macos-x86_64.dmg` (Intel). Drag Cowork to Applications.
- **Linux**: `cowork-<version>-linux-x86_64.deb` for Ubuntu and Debian.
- Zip / tar.gz archives and a `SHA256SUMS.txt` accompany each release.

### macOS

- Text now renders (the text system was missing from the macOS build).
- Native window buttons (close, minimize, zoom) and a resizable window; double-click the title bar to zoom.
- Keyboard shortcuts follow the Mac: `⌘` replaces `Ctrl` (`⌘S`, `⌘F`, `⌘,`, `⌘Q`...), `⌥←/→` move by word, `⌘←/→` to line start and end, `⌘↑/↓` to document start and end. Shortcuts are shown the Mac way (`⇧⌘S`).
- `⌘A`, `⌘C`, `⌘X`, `⌘V`, `⌘Z` and the delete keys work in the address bar and inside web pages.
- Terminal: `⌘C`/`⌘V` copy and paste, `⌘K` clears; `Ctrl` combinations go to the shell.
- A Cowork menu with Settings, Hide and Quit.

### Windows

- A Settings button at the left of the title bar opens the Settings tab.

### Known limitations

- The builds are not signed with a developer certificate. Windows SmartScreen shows "Windows protected your PC": choose **More info**, then **Run anyway**. On macOS, Control-click Cowork in Applications and choose **Open** the first time.
- The Linux package has been built and inspected but not yet run on a clean machine.
