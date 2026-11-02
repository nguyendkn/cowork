"""Tests of the macro expander: `python -m unittest discover -s tools -p "test_*.py"`."""
import importlib.util
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("expand_macros", Path(__file__).with_name("expand-macros.py"))
expand_macros = importlib.util.module_from_spec(spec)
spec.loader.exec_module(expand_macros)

ACTIONS = {
    "editor::Save": {"kb": "`Ctrl+S`", "action": "`editor: save`"},
    "editor::Unbound": {"kb": "unbound", "action": "`editor: unbound`"},
    "editor::NoEntry": {"kb": None, "action": "`editor: no entry`"},
}


class ExpandTests(unittest.TestCase):
    def test_kb_and_action_expand(self):
        text = "Press {#kb editor::Save} or run {#action editor::Save}."
        self.assertEqual(expand_macros.expand(text, ACTIONS), "Press `Ctrl+S` or run `editor: save`.")

    def test_unbound_actions_say_so(self):
        self.assertEqual(expand_macros.expand("{#kb editor::Unbound}", ACTIONS), "unbound")

    def test_unknown_actions_fail_the_build(self):
        for text in ("{#kb nope::Nope}", "{#action nope::Nope}", "{#kb editor::NoEntry}"):
            with self.assertRaises(ValueError, msg=text):
                expand_macros.expand(text, ACTIONS)

    def test_other_braces_are_left_alone(self):
        text = "## Editor {#editor}\n\n{#anchor-id} and {# not closed"
        self.assertEqual(expand_macros.expand(text, ACTIONS), text)

    def test_front_matter_is_dropped(self):
        page = "---\ntitle: T\ndescription: D\n---\n\n# Heading\n"
        self.assertEqual(expand_macros.strip_front_matter(page), "# Heading\n")
        self.assertEqual(expand_macros.strip_front_matter("# No front matter\n"), "# No front matter\n")

    def test_nested_chapters_are_expanded_and_errors_name_the_chapter(self):
        items = [{"Chapter": {"name": "A", "content": "{#kb editor::Save}", "sub_items": [
            {"Chapter": {"name": "B", "content": "{#action editor::Save}", "sub_items": []}}]}}]
        expand_macros.expand_items(items, ACTIONS)
        self.assertEqual(items[0]["Chapter"]["content"], "`Ctrl+S`")
        self.assertEqual(items[0]["Chapter"]["sub_items"][0]["Chapter"]["content"], "`editor: save`")
        bad = [{"Chapter": {"name": "Broken", "content": "{#kb x::Y}", "sub_items": []}}]
        with self.assertRaisesRegex(ValueError, "in chapter `Broken`"):
            expand_macros.expand_items(bad, ACTIONS)

    def test_the_checked_in_table_covers_every_macro_in_the_book(self):
        import json, re
        table = json.loads(Path(__file__).with_name("action-table.json").read_text(encoding="utf-8"))["actions"]
        for page in Path(__file__).resolve().parent.parent.joinpath("src").rglob("*.md"):
            for kind, action in re.findall(r"\{#(kb|action) ([^}]+)\}", page.read_text(encoding="utf-8")):
                self.assertIn(action.strip(), table, f"{page.name}: {{#{kind} {action}}}")


if __name__ == "__main__":
    unittest.main()
