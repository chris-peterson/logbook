# logbook

A log of important learnings, e.g. AI-assisted coding session retros.

A Claude Code plugin (and standalone CLI) that turns a coding session — Claude Code, Cursor, or GitHub Copilot — into a retrospective committed to a team-owned git repository. Transcripts stay on the author's workstation; only the retro is published.

## Surfaces

| Surface | What it is |
|---|---|
| `/logbook <subcommand>` | Slash command that maps directly to the CLI (deterministic ops) |
| `/logbook:retro`        | Skill that gathers retro content conversationally and publishes via the CLI |
| `logbook` (shell)       | Same CLI, runnable from any terminal |

## CLI

```text
logbook session                                       print session info as JSON
logbook session-id                                    print only the active session's id (fast)
logbook add-team <git-url> [--as <name>]              register a team retro repo
logbook device-id                                     print/persist per-workstation id
logbook config                                        print resolved config
logbook retro publish <category> <slug> <dir> [--team <t>]
logbook retro template-path                           absolute path to retro template
logbook retro estimate-cost <i> <o> <cc> <cr> [--model opus-4.7|opus-4.6|...]
logbook install-cli [--dir <path>]                    install 'logbook' wrapper on PATH + zsh completions
logbook completions zsh [--print]                     install/print zsh completions
```

## Install

```text
/plugin install logbook
```

For shell access (tab completion, direct CLI use outside Claude Code), run once:

```text
/logbook install-cli
```

This drops a `logbook` wrapper at `~/.local/bin/logbook` that points at the installed plugin and installs the zsh completion script to `~/.zsh/completions/_logbook`. Pass `--dir <path>` for a different wrapper install location. Then `exec zsh` to pick up completions.

## Onboarding (one-time per workstation)

1. Your team creates an empty git repo for retros (e.g. `git@github.com:teamX/retros.git`). Members need push access.
2. Register it:
   ```text
   /logbook add-team git@github.com:teamX/retros.git
   ```
   Clones to `~/.logbook/repos/<team>/` and sets it as default.
3. Run `/logbook:retro` after a session. The skill gathers content, writes the retro, and publishes to the team repo.

## Configuration

`~/.logbook/config.yaml` is created by `logbook add-team`:

```yaml
default_team: teamX
teams:
  teamX:
    remote: git@github.com:teamX/retros.git
```

## Layout in the team repo

```text
retros/
├── debugging/
│   └── pwsh-gitlab-get-changerequest-bug/
│       └── index.md
├── new-feature/
│   └── apps-pages-mcp-server/
│       └── index.md
└── ...
```

Categories are chosen by the team — they live as directory names, with no enforced list.

## Privacy model

- Transcripts are **never** published to the team repo. The team repo gets the retro `index.md` only.
- The retro frontmatter includes `session_id` and `device_id` so an author can correlate a published retro to their local session data.
- The CLI does not read or modify session transcripts. Transcript handling is the caller's responsibility (e.g. an ai-sdlc-side hook).

## Multiple teams on one workstation

```text
/logbook add-team git@github.com:teamY/retros.git --as teamY
```

Override the default at retro time by passing `--team teamY` to the publish call.

## Requirements

- Python 3.10+
- `pyyaml`: `pip install pyyaml`
- `git` on PATH with push access to the team retro remote

## License

MIT
