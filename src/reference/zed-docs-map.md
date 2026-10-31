---
title: Zed Docs Map
description: Which page of Zed's documentation each Cowork page was ported from, and which Zed pages have no counterpart.
---

# Zed Docs Map

Cowork's docs are ported from [Zed's documentation](https://zed.dev/docs) and rewritten to describe only what Cowork does. The structure, voice and conventions come from Zed; the content comes from the app.

This table lists every page of Zed's docs and where it went.

| Zed page                | In Cowork                                                                                                       |
| ----------------------- | --------------------------------------------------------------------------------------------------------------- |
| `account/`              | Not in Cowork: There are no accounts.                                                                           |
| `ai/`                   | Not in Cowork: The `acp` crate speaks the Agent Client Protocol, but there is no agent UI yet.                  |
| `all-actions`           | [Default Shortcuts](./default-shortcuts.md)                                                                     |
| `appearance`            | Not in Cowork: One built-in dark theme.                                                                         |
| `authentication`        | Not in Cowork: There are no accounts.                                                                           |
| `business/`             | Not in Cowork: Not applicable.                                                                                  |
| `collaboration/`        | Not in Cowork: No collaboration features.                                                                       |
| `command-palette`       | [Command Palette](../command-palette.md)                                                                        |
| `completions`           | Not in Cowork: The editor has no language server or completions.                                                |
| `configuring-languages` | Not in Cowork: No language support.                                                                             |
| `configuring-zed`       | [Settings](../settings.md), [Configuration Files](../configuration-files.md)                                    |
| `debugger`              | Not in Cowork: Not in Cowork.                                                                                   |
| `dev-containers`        | Not in Cowork: No remote development.                                                                           |
| `development`           | Not in Cowork: Contributor docs for Cowork are in `docs/README.md`.                                             |
| `development/`          | Not in Cowork: Contributor docs for Cowork are in `docs/README.md`.                                             |
| `diagnostics`           | Not in Cowork: The editor has no language server.                                                               |
| `editing-code`          | [Editor](../editor.md)                                                                                          |
| `environment`           | Not in Cowork: No project environments; terminals use the app's environment.                                    |
| `extensions`            | Not in Cowork: No extension system yet.                                                                         |
| `extensions/`           | Not in Cowork: No extension system yet.                                                                         |
| `finding-navigating`    | [Find, Replace & Go to Line](../finding-navigating.md)                                                          |
| `getting-started`       | [Getting Started](../getting-started.md)                                                                        |
| `git`                   | Not in Cowork: Not in Cowork; use a terminal tab.                                                               |
| `globs`                 | Not in Cowork: No project settings.                                                                             |
| `helix`                 | Not in Cowork: No Helix mode.                                                                                   |
| `icon-themes`           | Not in Cowork: One built-in icon set.                                                                           |
| `installation`          | [Installation](../installation.md)                                                                              |
| `key-bindings`          | [Key Bindings](../key-bindings.md)                                                                              |
| `languages`             | Not in Cowork: No language support; text is plain.                                                              |
| `languages/`            | Not in Cowork: No language support; text is plain.                                                              |
| `linux`                 | [Installation](../installation.md#requirements)                                                                 |
| `macos`                 | [Installation](../installation.md#requirements)                                                                 |
| `migrate/`              | Not in Cowork: No migration guides.                                                                             |
| `modelines`             | Not in Cowork: Not supported.                                                                                   |
| `multibuffers`          | Not in Cowork: Not in the editor.                                                                               |
| `outline-panel`         | Not in Cowork: The editor has no language support, so no outline.                                               |
| `performance`           | Not in Cowork: Not documented yet.                                                                              |
| `project-panel`         | Not in Cowork: Cowork has no project or folder concept; files are opened one by one.                            |
| `quick-start`           | [Getting Started](../getting-started.md)                                                                        |
| `reference/`            | [Default Shortcuts, Configuration Files](./default-shortcuts.md)                                                |
| `remote-development`    | Not in Cowork: No remote development.                                                                           |
| `repl`                  | Not in Cowork: Not in Cowork.                                                                                   |
| `roles`                 | Not in Cowork: Not applicable.                                                                                  |
| `running-testing`       | Not in Cowork: Tasks and test running are not in Cowork; use a terminal tab.                                    |
| `semantic-tokens`       | Not in Cowork: No language support.                                                                             |
| `snippets`              | Not in Cowork: Not in the editor.                                                                               |
| `soc2`                  | Not in Cowork: Not applicable.                                                                                  |
| `tab-switcher`          | Not in Cowork: Tabs are switched by clicking; there is no tab switcher yet.                                     |
| `tasks`                 | Not in Cowork: Use a terminal tab.                                                                              |
| `telemetry`             | Not in Cowork: Cowork sends no telemetry.                                                                       |
| `terminal`              | [Terminal](../terminal.md)                                                                                      |
| `themes`                | Not in Cowork: One built-in dark theme; no theme selector.                                                      |
| `toolchains`            | Not in Cowork: No language support.                                                                             |
| `troubleshooting`       | [Troubleshooting](../troubleshooting.md)                                                                        |
| `uninstall`             | [Installation](../installation.md#update-uninstall)                                                             |
| `update`                | [Installation](../installation.md#update-uninstall)                                                             |
| `vim`                   | Not in Cowork: No Vim mode in the editor (the terminal has its own vi mode).                                    |
| `visual-customization`  | Not in Cowork: only fonts, tab width and terminal appearance are configurable (see [Settings](../settings.md)). |
| `windows`               | [Installation (Windows is the supported platform)](../installation.md)                                          |
| `windows-and-projects`  | [Windows, Panes & Tabs](../windows-and-panes.md)                                                                |
| `worktree-trust`        | Not in Cowork: No projects, so no trust prompts.                                                                |

Pages marked "Not in Cowork" describe features the app does not have. They are listed so that a missing page is a decision, not an oversight; when the feature arrives, port the page and update this table.

## Pages With No Zed Original {#new-pages}

| Cowork page                                      | Why                                                                    |
| ------------------------------------------------ | ---------------------------------------------------------------------- |
| [Browser](../browser.md)                         | Cowork's browser tab has no Zed counterpart                            |
| [Sessions & Quick Notes](../sessions.md)         | Notepad++-style session restore is specific to Cowork                  |
| [Settings](../settings.md)                       | Cowork's Settings tab has its own pages and layout                     |
| [Configuration Files](../configuration-files.md) | Zed documents settings in a reference; Cowork has a small set of files |
