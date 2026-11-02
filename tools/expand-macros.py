#!/usr/bin/env python3
"""mdBook preprocessor: expands the docs' key-binding macros and strips front matter.

    {#kb editor::Save}      ->  `Ctrl+S`          (the action's default key binding)
    {#action editor::Save}  ->  `editor: save`    (the name the command palette shows)

The values come from `tools/action-table.json`, written from the app's real shortcut tables by
`make docs-actions` (in the app repository), so the book builds anywhere with only mdBook and
Python, such as the GitHub Pages workflow, and cannot drift from the app (the app repository's
tests fail when the table is stale). An unknown action fails the build.

mdBook protocol: `expand-macros.py supports <renderer>` exits 0; otherwise `[context, book]` JSON
arrives on stdin and the book JSON goes to stdout.
"""
import json
import sys
from pathlib import Path

TABLE = Path(__file__).resolve().parent / "action-table.json"


def strip_front_matter(text: str) -> str:
    """Drop a leading `---` block (`title:` / `description:` metadata): mdBook would render it as text."""
    for opener in ("---\n", "---\r\n"):
        if text.startswith(opener):
            rest = text[len(opener):]
            end = rest.find("\n---")
            if end == -1:
                return text
            return rest[end + 4:].lstrip("\r\n")
    return text


def expand(text: str, actions: dict) -> str:
    out = []
    rest = text
    while True:
        start = rest.find("{#")
        if start == -1:
            break
        out.append(rest[:start])
        tail = rest[start:]
        end = tail.find("}")
        if end == -1:
            out.append(tail)
            return "".join(out)
        command = tail[2:end]
        kind, _, action = command.partition(" ")
        action = action.strip()
        if kind == "kb" and _:
            entry = actions.get(action)
            if entry is None or entry.get("kb") is None:
                raise ValueError(f"{{#kb {action}}}: unknown action (regenerate the table with `make docs-actions`)")
            out.append(entry["kb"])
        elif kind == "action" and _:
            entry = actions.get(action)
            if entry is None:
                raise ValueError(f"{{#action {action}}}: unknown action")
            out.append(entry["action"])
        else:
            # `{#anchor-id}` after a heading is mdBook syntax, not ours.
            out.append(tail[: end + 1])
        rest = tail[end + 1:]
    out.append(rest)
    return "".join(out)


def expand_items(items, actions) -> None:
    for item in items:
        chapter = item.get("Chapter") if isinstance(item, dict) else None
        if not chapter:
            continue
        content = chapter.get("content")
        if isinstance(content, str):
            try:
                chapter["content"] = expand(strip_front_matter(content), actions)
            except ValueError as error:
                raise ValueError(f"in chapter `{chapter.get('name', '?')}`: {error}") from None
        expand_items(chapter.get("sub_items") or [], actions)


def main() -> int:
    if len(sys.argv) > 1 and sys.argv[1] == "supports":
        return 0  # every renderer is fine
    actions = json.loads(TABLE.read_text(encoding="utf-8"))["actions"]
    _context, book = json.loads(sys.stdin.buffer.read().decode("utf-8"))
    try:
        # mdBook 0.5 calls the list `items`; 0.4 called it `sections`.
        for key in ("items", "sections"):
            if key in book:
                expand_items(book[key], actions)
    except ValueError as error:
        print(f"expand-macros: {error}", file=sys.stderr)
        return 1
    sys.stdout.buffer.write(json.dumps(book, ensure_ascii=False).encode("utf-8"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
