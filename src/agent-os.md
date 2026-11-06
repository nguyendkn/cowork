---
title: Agent OS
description: Make your own agents, talk to them in channels and DMs, and what they can do: tools, routines, specification files, providers and usage.
---

# Agent OS

Agent OS is a chat workspace for agents you make yourself. Open it from the launcher (**Agent OS**). A fresh install has the `#general` channel and no agents; there are no built-in roles.

## Agents {#agents}

An agent is a name, a title, a **Role** (its instructions), a provider and model, a look (its face) and a folder. Create one with **Add agent** in the sidebar (or **Create your first agent**); the form checks the name and folder as you type, and nothing is saved until **Save**. **Archive** (click twice) retires an agent and keeps its history. At most 50 agents are active.

- **Describe it in words**: in the Add agent dialog, or the prompt box of the form, then **Draft from description**. The draft (name, title, one-paragraph Role) is made on this computer without a model, also from Vietnamese text; edit it, then save. The **Look** button cycles the faces.
- **Folder**: each agent works in its own folder, `<config folder>/agents/<id>/workspace` by default; you can pick another one. A relative folder stays inside the agent's home; `..` is refused.
- **Provider and model**: set per agent (see [Providers](#providers)). An empty provider follows the default provider.

### The first agent: Master {#master}

When the workspace has never had an agent, `#general` shows a card: check the provider, name the Master (default "Master", title "Điều phối"), then **Create Master**, or **Skip** for this run. The Master is an ordinary agent that you can edit or archive; it posts a welcome in `#general`. Archiving it never makes another one.

The Master answers or delegates (it can use `list_agents` and `send_message`, up to 3 agents). Given a plain description of a helper, it can call `create_agent`: a card appears in the chat with **Create agent** and **Cancel**, and nothing is made until you click Create. A card answered after restarting Cowork cannot create the agent; the turn gets the plain answer.

## Messages and routing {#routing}

- `@name` sends to the mentioned agents only.
- A message with no `@` goes to the agents already in that thread, otherwise to the channel's **default agent** (the Master, for `#general`) if it is active and a member.
- Only your messages route: an agent's message never wakes another agent by itself (see the `send_message` rules below).

## Saved chat {#persistence}

Channels, DMs, messages, drafts, reactions and agents are saved in `agent_os.db` in the [config folder](./configuration-files.md#files) and shown again after a restart or a crash. A message still waiting for an agent is delivered once after the restart; a turn that was running when the app quit shows as interrupted. Before a database upgrade Cowork copies the file to `agent_os.db.bak-v<N>` (the newest two are kept); a database from a newer Cowork is refused instead of changed, restore the backup to go back. See [System Architecture](./system-architecture.md).

## Queue, retries and undelivered {#engine}

Every message to an agent is a task on a queue; up to 4 turns run at once, the rest wait and are shown as queued. A failed turn is retried with a growing delay; after 5 failed deliveries the message stops and appears under **Undelivered** in the sidebar, with the reason, **Retry** and **Dismiss**. The row only shows when something is undelivered. A session that sits idle is closed to free memory (**Settings > Agent OS > Providers > Keep Idle Agents Ready**: None, 1, 2, 3 or 5 kept, and in any case after a few minutes); the next message opens a fresh one with the full prompt, so what an agent must remember belongs in its files.

## Tools {#tools}

Agents reach Cowork through a local tool server:

| Tool | What it does |
| ---- | ------------ |
| `send_message` | Write to another agent. Only `needs_reply` wakes it and the sender waits for the answer; plain text is appended without a turn |
| `list_agents` | Who exists (archived agents excluded) |
| `react_to_message` | Add a reaction |
| `ask_user` | Ask you a question and wait |
| `routine_no_update`, `routine_report_failure` | End a scheduled run quietly or as failed |
| `create_agent`, `list/create/update/delete_routine`, `browser` | Found with `tool_search`, called with `tool_call` |

`search_memories`, `remember`, `forget_memory`, `history_search` and `history_read` are listed but not implemented yet. `send_message` limits: 3 different recipients per turn, 4 delegation hops, 20 messages per task tree, the same text to the same agent not twice in a minute, and nobody writes to an agent that is waiting on the sender. A refusal comes back to the model as text.

## Specification files {#specifications}

Each agent folder holds markdown files you can edit in the agent panel: `AGENTS.md` (standing instructions), `SOUL.md` (character), `IDENTITY.md`, `USER.md` (about you, capped at 4 000 characters), `TOOLS.md`, `BOOTSTRAP.md` (first-run steps, removed when setup is done), `MEMORY.md`, `HEARTBEAT.md` and `DREAMS.md`. Each file is capped at 20 000 characters and the set at 60 000 (the head and tail are kept). Together with the Role they form the agent's prompt.

The prompt never appears in your chat. Cowork writes it into a marked, generated block in `CLAUDE.md` (Claude Code) and `AGENTS.md` (Codex, opencode) in the agent folder, before each turn and only when it changed. Text you write outside the block is yours and untouched; the block is hidden in the editor and kept on save; edits inside it are overwritten.

## Providers {#providers}

See [Settings](./settings.md#agent) for the pages. Built in: Claude Code, Codex and opencode (which also serves API endpoints). **ACP agents** adds any other agent that speaks the Agent Client Protocol, from a bundled list or your own command (`acp:<id>`). Bundled entries carry a `verified` flag; a one not yet run end to end in Cowork shows as "unverified". The agent form marks a provider that is not found "(not found)".

API keys of endpoints live in the system keychain (macOS Keychain, Windows Credential Manager), never in `settings.json`, and Cowork refuses to save a key where no keychain exists. Log lines are redacted (registered keys, `sk-` and token shapes, `Bearer`, `key=value`).

## Context and usage {#usage}

The DM header shows "Context 35% of 24k" (`~` when estimated, because the agent reports nothing). At 80% the lane starts a fresh session whose prompt opens with a handoff of at most 32 000 characters (open items, recent messages, steps; secrets masked) and the chat shows "Context compacted". If that does not help twice, it stops and says so. When a provider says the plan is used up, the agent is held and the header shows "usage limit reached" until a turn succeeds.

## Routines, heartbeat and dreams {#routines}

The agent panel lists **Routines** with an on/off switch and **Run now**. A scheduled run uses its own session and receives a short handoff of the DM. A run whose answer is `[[no-update]]` (or `HEARTBEAT_OK`) is deleted from the chat. Limits: 64 routines per agent, at least 3 minutes between runs. Two are made for you and hidden from the model:

- **Heartbeat**: every 30 minutes; skipped (no tokens) while `HEARTBEAT.md` is empty.
- **Dream**: daily at 03:00, always on, no model call: lines of the last week that repeat or say "keep" go to `MEMORY.md`, and `DREAMS.md` says what moved.

Webhook routines have a receiver on the loopback interface (port 47821, else a free one, signed, with a replay window), but no screen or tool to create one yet.

## Avatars {#avatars}

Agents wear a face drawn by Cowork, always the same for the same agent and look. The default is a felt "plush" look (flat vector below 28 px). Looks: `pill`, `yarn` (yarn eyes) and the characters `nexo`, `vita`, `cloe`, `malu`, `yoshi`, `fred`; an agent made without a pick gets one from its name. The avatar has moods (idle, working, waiting, failed, responded) and hops while the agent works, landing once when it stops.
