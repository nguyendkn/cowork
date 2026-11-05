---
title: Settings
description: Change Cowork's settings in a tab: search, toggles and number fields, and the editor shortcuts, with changes saved as you make them.
---

# Settings

Settings opens in a tab, like everything else in Cowork. Click the gear at the far left of the title bar, press {#kb workspace::OpenSettings}, or run {#action workspace::OpenSettings} from the [command palette](./command-palette.md).

![The Settings tab: search, a list of pages, and the General page](./images/settings.png)

The list on the left has one page per area: **General**, **Terminal**, **Editor**, **Browser** and **Agent OS**. Pick one to see its settings on the right. Changes apply and are saved to [`settings.json`](./configuration-files.md#settings) as soon as you make them. Where a text box says "Press Enter to apply", type the new value and press `Enter`.

## Searching {#searching}

Type in the search box above the list to find a setting by its name or description. The list shows only the pages with a match, and the right side shows just the matching settings.

![Searching for "font" lists the Terminal and Editor font settings](./images/settings-search.png)

Clear the box to see the pages again.

## General {#general}

| Setting             | Default | What it does                                                                 |
| ------------------- | ------- | ---------------------------------------------------------------------------- |
| **Restore Session** | on      | Reopen the previous session's tabs on launch. See [Sessions](./sessions.md). |
| **Config Folder**   |         | Shows where `settings.json` is stored.                                       |

## Terminal {#terminal}

![The Terminal page](./images/settings-terminal.png)

| Setting                    | What it does                                                                |
| -------------------------- | --------------------------------------------------------------------------- |
| **Font Family**            | Font for terminal text (Enter to apply)                                     |
| **Font Size**              | Terminal text size                                                          |
| **Line Height**            | Spacing between lines: Comfortable, Standard or Custom                      |
| **Custom Line Height**     | Line height multiplier; changing it switches Line Height to Custom          |
| **Cursor Shape**           | Block, Underline, Bar or Hollow                                             |
| **Cursor Blinking**        | Whether the cursor blinks                                                   |
| **Alternate Scroll**       | The mouse wheel sends arrow keys in full-screen programs                    |
| **Option as Meta**         | Treat the Option/Alt key as Meta                                            |
| **Copy on Select**         | Copy selected text to the clipboard automatically                           |
| **Keep Selection on Copy** | Keep the text selected after copying it                                     |
| **Max Scroll History**     | Lines kept in the scrollback; empty means unbounded                         |
| **Scroll Multiplier**      | Scroll speed                                                                |
| **Minimum Contrast**       | Minimum contrast between text and its background (0 turns it off)           |
| **Shell**                  | Which shell new terminals start (the system default, or a program you name) |
| **Shell Program**          | Path or name of the shell; empty uses the system shell                      |
| **Shell Arguments**        | Space-separated arguments for the shell program                             |
| **Environment Variables**  | Extra `KEY=VALUE` variables for new terminals                               |
| **Shell Integration**      | Detect prompts, exit codes and the working directory from the shell (on by default); see [Shell Integration](./terminal.md#shell-integration) |

![The rest of the Terminal page: scrolling, contrast and the shell](./images/settings-terminal-more.png)

Terminal settings that say "Applies to new terminals" do not change terminals that are already open; open a new terminal tab to see them.

## Editor {#editor}

![The Editor page: text settings and the list of shortcuts](./images/settings-editor.png)

| Setting         | Default | What it does                                                        |
| --------------- | ------- | ------------------------------------------------------------------- |
| **Font Size**   | 12 (macOS), 14 (Windows, Linux) | Text size in the editor (VS Code's defaults)                |
| **Line Height** | Custom (1.5 on macOS, 1.35 on Windows and Linux) | Line spacing: **Comfortable** (1.618), **Standard** (1.3) or **Custom** |
| **Custom Line Height** | 1.5 (macOS), 1.35 (Windows, Linux) | The multiple of the font size for Custom (1.0 to 3.0, step 0.1) |
| **Tab Size**    | 4       | Spaces a tab stop spans                                             |

Below them, **Keyboard Shortcuts** lists every editor shortcut, the same list as the [shortcuts drawer](./key-bindings.md#shortcuts-drawer). Click the keys of a command and press the new combination; the box reads **Press keys…** while it waits.

![Waiting for the new keys of Save](./images/settings-editor-rebind.png)

## Browser {#browser}

![The Browser page](./images/settings-browser.png)

| Setting                             | Default       | What it does                                                                                                                       |
| ----------------------------------- | ------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| **Home URL**                        | `about:blank` | The page opened by the `+` in the browser's own tab strip (Enter to apply)                                                         |
| **Restore Pages**                   | on            | Reopen browser pages from the previous session. Only the page you were on loads at once; the others load when you open their tab |
| **Block Ads**                       | on            | Block known ad networks and hide ad slots (reload a page to apply)                                                                 |
| **Free Memory of Background Pages** | on            | A page tab not looked at for 30 minutes gives its memory back and reloads when you open it; pages loading or playing sound are kept |

## Agent OS {#agent}

![The Agent OS page](./images/settings-agent.png)

The Agent OS page has two tabs, Agent and Providers. The Agent tab stores the launch configuration for an agent that speaks the [Agent Client Protocol](https://agentclientprotocol.com): its program path, arguments, environment variables, protocol version and MCP servers. Each Agent OS agent (Planner, Coder, Reviewer, Researcher) runs on its own provider: Claude Code and Codex through their ACP adapters, OpenCode and API endpoints through `opencode acp`. A program path set here is an optional override that runs your own command for Claude Code and Codex; arguments, environment, protocol and MCP servers apply to every agent. The **Agent models** section sets the provider and model of each agent; an empty provider follows the default provider, an empty model uses the provider's own default.

The Providers tab lists the supported agent CLIs (Claude Code, Codex and others) with a default provider, then Connected and Other providers; a row opens that provider's own settings (picker, CLI path, default model, accounts). Usage, privacy and advanced options follow the list. Claude Code and Codex pages show the account found on this computer and its usage limits (current session and week); the CLI is found through your login shell's `PATH` plus **CLI Search Folders**. **API endpoints** adds an OpenAI-compatible or Anthropic-compatible server by base URL and API key (the key is stored as typed in `settings.json`); **Fetch models** lists its models. Agent OS reads these values when it starts an agent.
