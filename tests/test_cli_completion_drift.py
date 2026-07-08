"""Guard against the zsh completion drifting from the argparse CLI.

The completion (`ZSH_COMPLETION`) hand-maintains the list of subcommands and the
flags it offers for `export`/`import`. The CLI's real surface is the argparse
parser built by `build_parser()`. When someone adds or renames a subcommand and
forgets the completion (an easy miss — the two live ~1300 lines apart in the
same file), tab-completion silently goes stale. This test fails loudly on that
drift by comparing the completion's advertised names against the parser.

stdlib only — no pytest. Run via `python3 -m unittest` or `just test`.
"""
from __future__ import annotations

import argparse
import importlib.util
import re
import unittest
from importlib.machinery import SourceFileLoader
from pathlib import Path

CLI_PATH = Path(__file__).resolve().parent.parent / "scripts" / "logbook"

# Flags the completion intentionally does not advertise. `--workspace` is an
# internal path override (default ".") that a user rarely types; keeping it out
# of tab-completion is deliberate, so exclude it from the expected set rather
# than forcing it into the completion.
COMPLETION_OMIT_FLAGS = {"--workspace"}


def _load_cli():
    loader = SourceFileLoader("logbook_cli", str(CLI_PATH))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    mod = importlib.util.module_from_spec(spec)
    loader.exec_module(mod)
    return mod


def _nested_choices(subparser) -> set[str]:
    action = _subparsers_action_of(subparser)
    return set(action.choices) if action else set()


def _subparsers_action_of(parser) -> argparse._SubParsersAction | None:
    for action in parser._actions:
        if isinstance(action, argparse._SubParsersAction):
            return action
    return None


def _long_flags(parser) -> set[str]:
    """Long (`--x`) option strings a parser accepts, minus --help and the
    deliberately-unadvertised omissions."""
    flags = set()
    for action in parser._actions:
        for opt in action.option_strings:
            if opt.startswith("--") and opt != "--help":
                flags.add(opt)
    return flags - COMPLETION_OMIT_FLAGS


def _completion_array(script: str, name: str) -> set[str]:
    """The keys of a `local -a NAME=( 'key:desc' ... )` array in the completion,
    i.e. the text before the first colon of each single-quoted entry. Anchored on
    the array's own closing `)` line so a `)` inside a description (e.g. "(fast)")
    doesn't truncate the body."""
    m = re.search(rf"local -a {re.escape(name)}=\(\s*\n(.*?)\n\s*\)", script, re.DOTALL)
    if not m:
        raise AssertionError(f"completion array {name!r} not found")
    return {entry.split(":", 1)[0] for entry in re.findall(r"'([^']*)'", m.group(1))}


class CompletionDriftTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mod = _load_cli()
        cls.parser = cls.mod.build_parser()
        cls.top = _subparsers_action_of(cls.parser)
        cls.script = cls.mod.ZSH_COMPLETION

    def test_top_level_commands_match(self):
        self.assertEqual(
            _completion_array(self.script, "commands"),
            set(self.top.choices),
            "top-level commands in the zsh completion drifted from build_parser()",
        )

    def test_retro_subcommands_match(self):
        self.assertEqual(
            _completion_array(self.script, "retro_subs"),
            _nested_choices(self.top.choices["retro"]),
            "retro subcommands in the zsh completion drifted from build_parser()",
        )

    def test_note_subcommands_match(self):
        self.assertEqual(
            _completion_array(self.script, "note_subs"),
            _nested_choices(self.top.choices["note"]),
            "note subcommands in the zsh completion drifted from build_parser()",
        )

    def test_export_flags_match(self):
        self.assertEqual(
            _completion_array(self.script, "export_opts"),
            _long_flags(self.top.choices["export"]),
            "export flags in the zsh completion drifted from build_parser()",
        )

    def test_import_flags_match(self):
        self.assertEqual(
            _completion_array(self.script, "import_opts"),
            _long_flags(self.top.choices["import"]),
            "import flags in the zsh completion drifted from build_parser()",
        )


if __name__ == "__main__":
    unittest.main()
