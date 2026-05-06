# Changelog

## 0.3.0

### Features
- `logbook --version` (and `-v`) now reports the installed plugin version, sourced from `.claude-plugin/plugin.json`.
- The `/logbook:retro` skill now does a CLI freshness pre-flight check. If the shell `logbook` wrapper (from `/logbook:logbook install-cli`) is older than the running plugin, it surfaces a one-line note and offers to refresh.

### Fixes
- Corrected slash-command syntax in skill prose: `/logbook add-team` → `/logbook:logbook add-team`; `/logbook:session` → `/logbook:logbook session`. The slash command shim is `/<plugin>:<plugin> <subcommand>`, not `/<plugin>:<subcommand>`.
