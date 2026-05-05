# logbook

A log of important learnings, e.g. AI-assisted coding session retros.

A Claude Code plugin (and standalone CLI) that turns a coding session — Claude Code, Cursor, or GitHub Copilot — into a retrospective committed to a team-owned git repository. Transcripts stay on the author's workstation; only the retro is published.

📖 **End-user docs:** https://chris-peterson.github.io/logbook

## Repo layout

```text
.claude-plugin/plugin.json   plugin manifest
commands/logbook.md          /logbook slash command (maps to the CLI)
skills/retro/                /logbook:retro skill (conversational retro authoring)
skills/session-id/           /logbook:session-id skill
scripts/logbook              the CLI — single Python file, stdlib + PyYAML
templates/retro.md           retro template (frontmatter + section scaffolding)
docs/                        end-user docs site (docsify, GitHub Pages)
SPEC.md                      formal requirements (EARS syntax)
```

## Dev setup

```bash
python3 --version            # 3.10+
pip install pyyaml
```

Run the CLI directly from source — no install needed:

```bash
python3 scripts/logbook --help
```

The CLI resolves the plugin root from `CLAUDE_PLUGIN_ROOT` (set by Claude Code when running as a plugin) or falls back to the script's filesystem location.

## Try the plugin locally

```bash
claude --plugin-dir .
```

Launches Claude Code with the working tree mounted as a plugin.

## Docs

```bash
just docs
```

Serves the docsify site at `docs/` locally. Deployed to GitHub Pages on push to `main` via `.github/workflows/deploy-docs.yml`.

## Specification

[SPEC.md](SPEC.md) — formal requirements in [EARS syntax](https://alistairmavin.com/ears) covering CLI, config, retro generation, publishing, privacy, install, completions, cost estimation, and session detection.

## License

MIT
