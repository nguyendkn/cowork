---
title: Troubleshooting
description: Fixes for common problems: startup, lost notes, shortcuts, terminal and browser tabs, and how to report a bug.
---

# Troubleshooting

## The App Does Not Start {#startup}

Run it from a terminal to see its messages:

```sh
cd app
cargo run -p app
```

For a crash, add a backtrace:

```sh
$env:RUST_BACKTRACE = "1"; cargo run -p app     # PowerShell
RUST_BACKTRACE=1 cargo run -p app               # bash
```

If it only crashes with your data, try a clean config folder to find out which file is the cause:

```sh
$env:COWORK_CONFIG_DIR = "$env:TEMP\cowork-clean"; cargo run -p app
```

If that starts, move your session, shortcut and history files back one at a time. See [Configuration Files](./configuration-files.md#resetting).

## The First Build Fails {#build}

The first build compiles CEF's C++ wrapper. It needs `cmake` and `ninja` on `PATH`; `make build` adds the copies that ship with Visual Studio Build Tools. It also downloads about 300 MB of CEF, so it needs network access. A build that fails on `cef-dll-sys` right after another cargo process was running usually works when you run it again.

## My Notes Are Missing {#missing-notes}

- Check that **Restore Session** is on (General page of [Settings](./settings.md#general)).
- Notes are saved to the [session](./sessions.md) a few seconds after you change them and when you close the window. Ending the process (a crash, or killing it) can lose the last few seconds.
- Closing a tab throws its note away.
- Check that you start Cowork with the same config folder; `COWORK_CONFIG_DIR` points elsewhere.
- Look in the `session` folder: the `.txt` files there hold the text of notes that were open when the app last saved.

## A Shortcut Does Nothing {#shortcuts}

- Open the [shortcuts drawer](./key-bindings.md#shortcuts-drawer) and look for the command: another command may have taken the keys (it shows `—`), or you may have changed it.
- Inside a [terminal](./terminal.md#shell-keys) several shortcuts go to the shell.
- Look the command up in the [command palette](./command-palette.md); its binding is listed on the row.
- To go back to the defaults, delete `editor-keymap.txt`.

## Typing in Another Language {#ime}

Input methods (Telex, VNI, Pinyin, ...) work in the editor, the find bar, the address bar and the settings boxes. Composed text is shown while you type and committed with the word. Shortcuts use the physical key, not the composed character, so they work whichever layout is active.

Vietnamese letters behave the same whether they were typed as one character (`ệ`) or as a letter plus marks (`e` + `◌̂` + `◌̣`): the arrow keys, `Backspace`, word movement and the column counter treat either as one letter. Search is the one exception, because the two spellings are different text.

## The Terminal Is Blank or Shows an Error {#terminal}

The shell starts in the background; if it cannot start, the error is printed in the tab. Check that the shell program exists. Close the tab with `Ctrl+Shift+W` and open a new one.

## The Browser Says "CEF is not running" {#browser}

The Chromium runtime was not found next to the executable. Build with `make build`, or copy the CEF files as described in [Installation](./installation.md#shipping). Details are in `%LOCALAPPDATA%\cowork\cef.log`.

## Reporting a Bug {#reporting}

Include:

1. what you did, step by step, and what you expected;
2. the Cowork version or commit (`git rev-parse --short HEAD`);
3. your Windows version;
4. the terminal output (with `RUST_BACKTRACE=1` for a crash);
5. a screenshot if it is about how something looks.
