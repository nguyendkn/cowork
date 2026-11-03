---
title: Configuration Files
description: Where Cowork stores your settings, shortcuts, session and command history, the settings.json keys, and how to reset each file.
---

# Configuration Files

Cowork keeps everything it remembers in one **config folder**:

| Platform | Config folder                                     |
| -------- | ------------------------------------------------- |
| Windows  | `%APPDATA%\cowork\`                               |
| macOS    | `~/.config/cowork/`                               |
| Linux    | `$XDG_CONFIG_HOME/cowork/` or `~/.config/cowork/` |

Set the environment variable `COWORK_CONFIG_DIR` to use another folder (handy for trying things without touching your real data). The **General** page of [Settings](./settings.md#general) shows the exact path of `settings.json`.

## What Is Inside {#files}

| Path                  | What it holds                                         | Read more                                      |
| --------------------- | ----------------------------------------------------- | ---------------------------------------------- |
| `settings.json`       | Everything on the pages of the Settings tab           | [Settings file](#settings)                     |
| `editor-keymap.txt`   | Editor shortcuts you changed                          | [Key Bindings](./key-bindings.md#storage)      |
| `command-palette.txt` | Commands you ran and queries you typed in the palette | [Command Palette](./command-palette.md#recent) |
| `session/`            | Open tabs, layout and unsaved text                    | [Sessions](./sessions.md)                      |

The browser's page cache and log are separate, in `%LOCALAPPDATA%\cowork\`: `cef-cache\` and `cef.log`.

## The Settings File {#settings}

The [Settings tab](./settings.md) edits `settings.json` for you, so you rarely need to open it. You can also edit it by hand while Cowork is closed. It is read when the app starts; every key is optional, and a missing key keeps its default.

```json
{
  "general": { "restore_session": true },
  "editor": { "font_size": 14, "tab_size": 4 },
  "browser": { "home_url": "about:blank", "restore_pages": true },
  "terminal": { "font_family": "Consolas", "font_size": 14 }
}
```

| Key                                 | Default                 | Setting                                                                                             |
| ----------------------------------- | ----------------------- | --------------------------------------------------------------------------------------------------- |
| `general.restore_session`           | `true`                  | Restore Session                                                                                     |
| `editor.font_size`                  | `14`                    | Editor font size                                                                                    |
| `editor.tab_size`                   | `4`                     | Editor tab size                                                                                     |
| `browser.home_url`                  | `"about:blank"`         | Home URL (the `+` in a browser's page-tab strip)                                                    |
| `browser.restore_pages`             | `true`                  | Restore Pages                                                                                       |
| `browser.block_ads`                 | `true`                  | Block Ads                                                                                           |
| `browser.discard_background_pages`  | `true`                  | Free Memory of Background Pages                                                                     |
| `terminal.font_family`              | `"Consolas"` (Windows)  | Terminal font family                                                                                |
| `terminal.font_size`                | `14`                    | Terminal font size                                                                                  |
| `terminal.line_height`              | `"comfortable"`         | `"comfortable"`, `"standard"` or `{"custom": 1.6}`                                                  |
| `terminal.cursor_shape`             | `"block"`               | `"block"`, `"underline"`, `"bar"` or `"hollow"`                                                     |
| `terminal.blinking`                 | `"terminal_controlled"` | `"off"`, `"on"` or `"terminal_controlled"`                                                          |
| `terminal.alternate_scroll`         | `true`                  | Alternate Scroll                                                                                    |
| `terminal.option_as_meta`           | `false`                 | Option as Meta                                                                                      |
| `terminal.copy_on_select`           | `false`                 | Copy on Select                                                                                      |
| `terminal.keep_selection_on_copy`   | `true`                  | Keep Selection on Copy                                                                              |
| `terminal.max_scroll_history_lines` | `null` (unbounded)      | Max Scroll History                                                                                  |
| `terminal.scroll_multiplier`        | `1.0`                   | Scroll Multiplier                                                                                   |
| `terminal.minimum_contrast`         | `45`                    | Minimum Contrast                                                                                    |
| `terminal.shell`                    | `"system"`              | `"system"`, `{"program": "pwsh"}` or `{"with_arguments": {"program": "pwsh", "args": ["-NoLogo"]}}` |
| `terminal.env`                      | `{}`                    | Environment Variables                                                                               |

The `agent` section (`path`, `args`, `env`, `protocol`, `mcp_servers`) holds the agent launch configuration shown on the Agent page. It has no effect yet.

If `settings.json` cannot be read as JSON, Cowork starts with the defaults and renames the broken file to `settings.json.bak` so you can fix it.

## Resetting {#resetting}

Quit Cowork first, then delete what you want to reset:

| To reset                | Delete                                 |
| ----------------------- | -------------------------------------- |
| Settings                | `settings.json`                        |
| Editor shortcuts        | `editor-keymap.txt` (or a single line) |
| Recent palette commands | `command-palette.txt`                  |
| Open tabs and notes     | the `session` folder                   |
| Everything              | the whole config folder                |
