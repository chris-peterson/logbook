# Changelog

## 0.3.1

### Fixes
- `logbook session` and `logbook session-id` no longer return a stale transcript when the shell's cwd at invocation time differs from the session's origin cwd (e.g., after a Bash `cd` into another repo). Resolution now prefers the `CLAUDE_CODE_SESSION_ID` env var, then walks the process tree to the nearest `claude` ancestor and reads `~/.claude/sessions/<pid>.json`, and only falls back to cwd-derived `.jsonl` mtime sort as a last resort. The previous code checked `CLAUDE_SESSION_ID` (wrong env var name), so it always fell through to the cwd heuristic. ([SES-4], [SES-5], [SES-11])

## 0.3.0

### Features
- `logbook --version` (and `-v`) now reports the installed plugin version, sourced from `.claude-plugin/plugin.json`.
- The `/logbook:retro` skill now does a CLI freshness pre-flight check. If the shell `logbook` wrapper (from `/logbook:logbook install-cli`) is older than the running plugin, it surfaces a one-line note and offers to refresh.

### Fixes
- Corrected slash-command syntax in skill prose: `/logbook add-team` → `/logbook:logbook add-team`; `/logbook:session` → `/logbook:logbook session`. The slash command shim is `/<plugin>:<plugin> <subcommand>`, not `/<plugin>:<subcommand>`.
