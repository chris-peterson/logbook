# <img src="favicon.svg" alt="logbook" width="64" height="64" style="vertical-align: middle"> logbook

A log of important learnings — turn an AI coding session into a retrospective committed to a team-owned git repository.

logbook works with Claude Code, Cursor, and GitHub Copilot. Transcripts stay on the author's workstation; only the retro is published.

## Interface

| Surface | What it is |
|---|---|
| `/logbook <subcommand>` | Slash command that maps directly to the CLI (deterministic ops) |
| [`/logbook:retro`](/skills/retro) | Skill that gathers retro content conversationally and publishes via the CLI |
| [`/logbook:note`](/skills/note)   | Skill that captures a mid-session observation, then acts, defers to a fresh session, or logs only |
| `logbook` (shell)       | Same CLI, runnable from any terminal |

## Quickstart

1. **Install the plugin.**

   ```bash
   claude plugin marketplace add chris-peterson/claude-marketplace
   claude plugin install logbook@chris-peterson
   ```

2. **(Optional) Install the shell wrapper** for tab completion and CLI use outside Claude Code:

   ```text
   /logbook install-cli
   ```

   Drops a `logbook` wrapper at `~/.local/bin/logbook` and installs the zsh completion script to `~/.zsh/completions/_logbook`. Then `exec zsh` to pick up completions.

3. **Register your team's retro repo** (one-time per workstation). Your team creates an empty git repo for retros (e.g. `git@github.com:teamX/retros.git`) where members have push access.

   ```text
   /logbook add-team git@github.com:teamX/retros.git
   ```

   Clones to `~/.logbook/repos/<team>/` and sets it as the default team.

4. **Run the retro skill** after a coding session.

   ```text
   /logbook:retro
   ```

   The skill gathers content conversationally, writes the retro, and publishes to the team repo.

## Privacy

> [!IMPORTANT]
> Transcripts are **never** published. The team repo gets the retro `index.md` only.

- The retro frontmatter includes `session_id` and `device_id` so an author can correlate a published retro to their local session data.
- The CLI does not read or modify session transcripts. Transcript handling is the caller's responsibility (e.g. a separate sanitization hook before publishing).
- Categories are free-form strings — no enforced whitelist.

## Reference

- **Skills** — see the sidebar for per-skill pages (sourced directly from each skill's `SKILL.md`)
- **[CLI reference](/cli)** — full subcommand surface, configuration, multi-team setup
- **Prerequisites** — Python 3.10+, `pyyaml`, `git` on PATH with push access to the team retro remote
