# <img src="favicon.svg" alt="logbook" width="64" height="64" style="vertical-align: middle"> logbook

A log of important learnings — turn an AI coding session into a retrospective committed to a team-owned git repository.

logbook works with Claude Code, Cursor, and GitHub Copilot. Transcripts stay on the author's workstation; only the retro is published.

## In action

The lessons worth keeping rarely belong to the repo you're sitting in. Here a
naming convention turns out to be a lesson about a *different* tool, so the note
is filed there — as tracked work — without derailing the session that found it.

<div class="cw-session" data-cw-session="session"></div>

Filing goes through [anchor](https://chris-peterson.github.io/anchor/) when you
have it installed, so the issue lands in the same why-first shape as the rest of
your issues. Without anchor you get the note body and a pre-filled issue URL
instead.

## Interface

| Surface | What it is |
|---|---|
| `/logbook:logbook <subcommand>` | Slash command that maps directly to the CLI (deterministic ops) |
| [`/logbook:retro`](/skills/retro) | Skill that gathers retro content conversationally and publishes via the CLI |
| [`/logbook:note`](/skills/note)   | Skill that captures a mid-session observation, then fixes it here, files it as an issue, or leaves it for the retro |
| `logbook` (shell)       | Same CLI, runnable from any terminal |

The two skills you reach for most — catch a lesson the moment it lands, or
reflect on the whole session once the work is done:

<div class="cw-session" data-cw-session="examples"></div>

## Quickstart

1. **Install the plugin.**

   ```bash
   claude plugin marketplace add chris-peterson/claude-marketplace
   claude plugin install logbook@chris-peterson
   ```

2. **(Optional) Install the shell wrapper** for tab completion and CLI use outside Claude Code:

   ```text
   /logbook:logbook install-cli
   ```

   Drops a `logbook` wrapper at `~/.local/bin/logbook` and installs the zsh completion script to `~/.zsh/completions/_logbook`. Then `exec zsh` to pick up completions.

3. **Register your team's retro repo** (one-time per workstation). Your team creates an empty git repo for retros (e.g. `git@github.com:teamX/retros.git`) where members have push access.

   ```text
   /logbook:logbook add-team git@github.com:teamX/retros.git
   ```

   Clones to `~/.logbook/repos/<team>/` and sets it as the default team.

4. **Run the retro skill** after a coding session.

   ```text
   /logbook:retro
   ```

   The skill gathers content conversationally, writes the retro, and publishes to the team repo.

## Privacy

> [!IMPORTANT]
> Transcripts are **never** published. `retro publish` copies the retro directory
> you hand it, verbatim — that directory is the boundary, and nothing from your
> transcript is written into it.

- The CLI reads your transcript locally, to count tokens and reconstruct the session's shape. It never writes any of that content into a published artifact — what crosses the boundary is prose you wrote.
- The retro frontmatter includes `session_id` and `device_id` so an author can correlate a published retro to their local session data.
- Notes stay on the workstation under `~/.logbook/`, harvested archive included. A retro may quote them; the log itself is never published.
- Categories are free-form strings — no enforced allowlist.

## Reference

- **Skills** — see the sidebar for per-skill pages (sourced directly from each skill's `SKILL.md`)
- **[CLI reference](/cli)** — full subcommand surface, configuration, multi-team setup
- **Prerequisites** — Python 3.10+, `pyyaml`, `git` on PATH with push access to the team retro remote
