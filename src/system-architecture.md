# System Architecture: Agent OS Chat Data Layer

This page documents the chat data layer (`crates/agent/src/chat/` +
`crates/agent/src/sqlite/chat_*`): the schema, how it relates to the
Runtime's own tables, and the `agent_os_import` export file format. It is
gpui-free and lives outside `crates/agent/src/app/` — later phases
(UI, hub wiring, ACP bridge) add sections here additively.

## Entity-relationship diagram

```
task (Runtime, unmodified)              conversation
  task_id PK                              id PK
  conversation_id (free string;             kind  'channel' | 'dm'
    a task correlation id, NOT a            name
    chat conversation)                      topic
  state, state_version                      created_at
  ...                                        archived_at
       ^                                     last_seq
       | task_id (informational link,
       |  message.task_id -> task.task_id,
       |  never a FK constraint: the
       |  projector writes it, nothing
       |  enforces referential integrity
       |  so Runtime migrations stay free
       |  to evolve task_id independently)
       |
  message                                 conversation_member
    msg_id PK                               conversation_id FK -> conversation.id
    conversation_id FK -> conversation.id   member_id          (both PK)
    seq                                     joined_at
    parent_msg_id FK -> message.msg_id      muted
    task_id            (see above)
    sender                                 reaction
    kind  'text'|'status'|'tool'|           msg_id FK -> message.msg_id
          'plan'|'interrupted'|'permission' actor               (all 3 PK)
    body                                    emoji
    client_msg_id UNIQUE (idempotency key)  created_at
    created_at
    edited_at                              read_marker
    deleted_at                              member_id
                                             conversation_id FK -> conversation.id
  message_mention                                              (both PK)
    msg_id FK -> message.msg_id             last_read_seq
    member_id            (both PK)
                                           draft
  message_permission                        member_id
    msg_id PK FK -> message.msg_id          conversation_id FK -> conversation.id
    tool                                    parent_msg_id FK -> message.msg_id
    args_summary (truncated/redacted)                          (all 3 PK)
    status 'pending'|'allowed'|             body
           'denied'|'expired'               updated_at
    stream_id
    thread_ref                            thread_follow
                                             member_id
  chat_stream                                parent_msg_id FK -> message.msg_id
    stream_id PK                                               (both PK)
    conversation_id FK -> conversation.id   following
    parent_msg_id FK -> message.msg_id
    agent                                 ui_state
    started_at                              member_id
    ended_at                                key                (both PK)
                                             value

  message_fts (FTS5 virtual table, standalone — not external-content,
               since message.msg_id is TEXT not an INTEGER rowid alias)
    msg_id    UNINDEXED
    body_nfc  (NFC-normalized copy of message.body; message.body itself
               is stored byte-for-byte untouched — only the search index
               is normalized)
```

All tables live in `ChatDomain` (`crates/agent/src/sqlite/chat_schema.rs`),
appended to the same `agent.db` file as the Runtime's `StoreDomain`/
`BusDomain` (`AgentMigrator = (StoreDomain, BusDomain, ChatDomain)`), so the
projector below can join `task` without a cross-file query. Migrations are
append-only (sqlez `Domain`), never edited in place once shipped.

## Backup

Before the **first** migration that adds `ChatDomain`'s tables to an
existing `agent.db`, `SqliteBackend::open_with_backup` checkpoints the WAL
(`PRAGMA wal_checkpoint(TRUNCATE)`) and copies `agent.db` (+ `-wal`/`-shm`
if present) to `agent.db.pre-chat`, once. A second open on an
already-migrated file is a no-op (detected by probing for the
`conversation` table) and never overwrites that backup.

## The projector

`ChatProjector` (`chat_projector.rs`) backfills real Runtime data into
chat rows — it never writes to `task`/`journal`/`outbox`:

- One root task (`causation_task_id IS NULL`) becomes one DM
  `conversation`, with a deterministic id (`dm:<task_id>:<counterpart>`)
  so re-running the backfill finds the same conversation rather than
  duplicating it.
- Every `send` journal entry's envelope becomes a `message` row
  (`kind = 'text'`), keyed `client_msg_id = "journal:<task_id>:<seq>"` for
  idempotent re-import.
- A terminal `TaskState` becomes one `status` message
  (`client_msg_id = "status:<task_id>"`).

## FTS5 decision

`crates/agent/tests/chat_search_fts5_probe.rs` measured that this repo's
vendored `sqlez` build (`libsqlite3-sys` 0.30.1, `bundled` feature) DOES
support FTS5. `search_messages` therefore queries the real `message_fts`
virtual table (`MATCH`, query text passed as a quoted FTS5 phrase literal
so `*`/`-`/`(`/`)`/boolean keywords in a human-typed query are matched
literally, never parsed as FTS5 query syntax) rather than falling back to
`LIKE`. If a future `sqlez`/`libsqlite3-sys` upgrade disables FTS5, that
probe test fails loudly and `chat_search_impl.rs` needs a LIKE-based
fallback at that point.

## Import file format (`agent_os_import`)

`agent_os_import <export.json> <db_path>` (`crates/agent/src/bin/agent_os_import.rs`)
imports a user-supplied export through the public `ChatStore` API only
(parameterized writes; a hostile body is stored as inert text, never
interpreted). The export file itself is never committed to this repo —
only its format, below, and the labelled fixture
`crates/agent/tests/fixtures/chat_export_format.json` (format-conformance
data, not a real export).

```json
{
  "conversations": [
    {
      "id": "conv_...",
      "kind": "dm | channel",
      "name": null,
      "members": ["user://local", "agent://ws/agent/x"],
      "messages": [
        {
          "client_msg_id": "...",
          "sender": "user://local",
          "kind": "text | status | tool | plan | interrupted",
          "body": "...",
          "parent_client_msg_id": null
        }
      ]
    }
  ]
}
```

Rules: every `messages[].body` is capped at 256 KiB (an oversize body
fails the whole import before any row is written); `client_msg_id` is the
idempotency key, so re-running the same file over the same database writes
no duplicate rows; `parent_client_msg_id` (optional) resolves to the real
`ChatMsgId` assigned on first import, so threaded replies survive a
re-import with the same structure; a malformed file (invalid JSON, unknown
`kind`/`conversation.kind` value) exits non-zero and writes nothing — the
whole file is parsed and validated before the database is even opened.
