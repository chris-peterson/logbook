# Changelog

## 0.6.0

### Features
- New `/logbook:note` skill for capturing mid-session observations. When something isn't working well — a rule, a skill, a CLAUDE.md, a recipe, a setting — `note` captures it and offers three responses: **now** (apply the fix and sweep comparable sites in the current session), **parallel** (spawn a fresh session in a new iTerm tab pointed at the affected repo), or **log** (capture for later without modifying anything). Pairs with `/logbook:retro`: retro reflects after the voyage, `note` captures mid-voyage.
- `log` mode emits the structured note three ways in a single pass: a markdown tempfile (clickable path), the body on the system clipboard via `pbcopy`/`wl-copy`/`xclip`/`clip.exe`, and — when the cwd is a git repo with a recognized origin (`github.com` or any `gitlab.*` host) — a pre-filled "new issue" URL with the title and body query-encoded. Tight forge integration (actually filing via `gh`/`glab`) remains deferred.
- Hosted docs site now has a Skills landing page that lists every skill with a one-line "use when..." hook, reachable from the sidebar.

### Other
- Skill docs pages are now generated from each `skills/<name>/SKILL.md` at build time (mirrors the existing `SPEC.md` pattern), so the hosted docs no longer drift from the source skill files.
- SPEC backfilled to cover behavior that shipped in 0.3.x and 0.4.0 (`--version`, `install-cli` semantics, `SessionStart` freshness hook, Copilot/Cursor detection scope). Added a per-category coverage tracker in `STATUS.md`.

## 0.4.0

### Features
- `SessionStart` hook now checks CLI wrapper freshness on every Claude Code session start, regardless of which surface invokes the CLI. Previously the freshness check lived in `/logbook:retro`'s pre-flight, which only fired when that skill was invoked — consumers calling `logbook` directly (other skills, shell, external integrations) bypassed it. The hook compares `logbook --version` against `plugin.json#version` and emits an `additionalContext` nudge when they differ; silent on match, silent when the CLI isn't on PATH, never blocks the session.

## 0.3.1

### Fixes
- `logbook session` and `logbook session-id` no longer return a stale transcript when the shell's cwd at invocation time differs from the session's origin cwd (e.g., after a Bash `cd` into another repo). Resolution now prefers the `CLAUDE_CODE_SESSION_ID` env var, then walks the process tree to the nearest `claude` ancestor and reads `~/.claude/sessions/<pid>.json`, and only falls back to cwd-derived `.jsonl` mtime sort as a last resort. The previous code checked `CLAUDE_SESSION_ID` (wrong env var name), so it always fell through to the cwd heuristic. ([SES-4], [SES-5], [SES-11])

## 0.3.0

### Features
- `logbook --version` (and `-v`) now reports the installed plugin version, sourced from `.claude-plugin/plugin.json`.
- The `/logbook:retro` skill now does a CLI freshness pre-flight check. If the shell `logbook` wrapper (from `/logbook:logbook install-cli`) is older than the running plugin, it surfaces a one-line note and offers to refresh.

### Fixes
- Corrected slash-command syntax in skill prose: `/logbook add-team` → `/logbook:logbook add-team`; `/logbook:session` → `/logbook:logbook session`. The slash command shim is `/<plugin>:<plugin> <subcommand>`, not `/<plugin>:<subcommand>`.
