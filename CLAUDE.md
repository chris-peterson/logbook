Agent instructions live in [AGENTS.md](./AGENTS.md).

@AGENTS.md

## Claude Code

- Mount the working tree as a plugin to exercise the skills and slash command:
  `claude --plugin-dir .` Then `/logbook:logbook` and the rest resolve against the
  checkout rather than the installed version.
- The CLI resolves its plugin root from `CLAUDE_PLUGIN_ROOT`, which Claude Code
  sets when running as a plugin; outside a session it falls back to the script's
  own location.
