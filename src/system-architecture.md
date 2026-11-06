---
title: System Architecture
description: How Agent OS stores its chat and runs agent turns: agent_os.db, the engine, backups, the specification block and the log signals.
---

# System Architecture: Agent OS

The user view is in [Agent OS](./agent-os.md). This page is for people who debug or extend it.

## Storage {#storage}

Everything is in `<config folder>/agent_os.db` (SQLite, WAL), one file with two parts:

| Part | Tables |
| ---- | ------ |
| Chat (`agent_chat` domain, `crates/agent/src/chat_db/`) | `agent`, `channel`, `channel_member`, `message`, `reaction`, `thread_summary`, `conv_state`, `conv_preview`, `pending_prompt`, `usage`, `usage_hold`, `channel_default`, `meta` |
| Engine (`crates/agent/src/sqlite/`) | `task`, `journal`, `outbox`, `idempotency`, `delivery_done`, `breaker`, `bus_message`, `bus_dlq`, plus the routine tables |

The UI thread only pushes writes to a channel (`ChatWriter`); a background thread batches them, and reads (`ChatReader`) run off the UI thread. Migrations are append-only and versioned (`meta.schema_version`). Before a migration on an existing file, `VACUUM INTO agent_os.db.bak-v<N>` makes a copy (the newest 2 are kept). A file written by a newer Cowork is refused with a message that names the backup to restore. A missing or unreadable file is logged at `ERROR` and the chat then runs unsaved.

## Run path {#engine}

A message you send is inserted as a `message` row and, in the same transaction, enqueued as a `chat.message.v1` task for the agent's lane (one lane per agent and conversation). The hub is an adapter: it starts turns, shows streamed rows and cards, and talks to the ACP process.

- **Queue and workers**: durable (`bus_message`), 4 turns at once. A step's sends go through the `outbox`, so a delivery happens once; the task id is the idempotency key.
- **Retries**: a failed attempt marks the task `Retrying` and re-delivers with a growing delay (100 ms doubling to 60 s). After 5 deliveries the message moves to `bus_dlq`; the Undelivered view lists it with Retry and Dismiss. A circuit breaker per agent is persisted in `breaker`.
- **Recovery**: at start, a task that was `Running` is reported as interrupted, queued ones are delivered. Every 30 s the expiry scan fails tasks past their deadline (1 h).
- **Lanes and sessions**: one ACP session per lane (a routine run gets its own, `routine:<id>@<lane>`). Idle sessions are closed by the idle policy, never while a turn, card, question or open task needs them.
- **Compaction**: at 80% of the reported window the lane drops its session and starts a new one with a handoff packet (<= 32 000 characters).

## Prompt delivery {#prompt}

The prompt (Role, then `AGENTS.md`, `SOUL.md`, `IDENTITY.md`, `USER.md`, `TOOLS.md`, `BOOTSTRAP.md`, `MEMORY.md`, each capped) is never sent as the user's message. It is written between these markers in the agent folder before each turn, only when it changed:

```
<!-- cowork:managed:start -- generated ... -->
...
<!-- cowork:managed:end -->
```

`CLAUDE.md` gets the whole prompt and `AGENTS.md` the rest, since it already holds your instructions. Text outside the block is never touched.

## Tool server {#tools}

Agents get an MCP stdio bridge to an in-app tool server. Eleven tools are advertised directly; the others are reached through `tool_search` and `tool_call`, so the advertised schema stays under 6 KB (asserted by `tools_catalog_budget`). The owner of a task tree comes from the session, never from an argument.

## Logs {#logs}

`make logs` lists the signals described in the project's `CLAUDE.md`. Agent OS tracks `acp.thread`, `onboarding.card` and `routine.timer`/`routine.webhook` for leaks and times `chat_db.backup`, `agent_os.folder_prepare`, `agent_os.onboard_master` and the routine passes.
