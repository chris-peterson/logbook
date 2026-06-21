# Changelog

## 0.8.1

### Other
- Namespaced every command example as `/logbook:logbook <subcommand>` in the docs, replaced "whitelist" with "allowlist" in the categories note, and aligned the marketplace suite metadata with the bridge.ai schema.

## 0.8.0

### Features
- **`logbook help`** now works as an alias for `--help` (CLI-11).

## 0.7.0

### Features
- `logbook retro estimate-cost --model …` now accepts the dashed Anthropic model ids that appear in Claude Code transcripts (`claude-opus-4-7`, `claude-opus-4-7-20260416`) — paste the model field from `logbook session` directly without translation. Legacy short forms (`opus-4.7`, `haiku-4.5`) still resolve. ([COST-3], [COST-4], [COST-6])
- New `just refresh-prices` target re-downloads Anthropic's per-token prices from the canonical LiteLLM table whenever new models ship or pricing changes. ([COST-7])

### Fixes
- Opus 4.5 / 4.6 / 4.7 and Haiku 4.5 sessions now report accurate cost from `logbook retro estimate-cost`. The previous hardcoded price table held the older Opus generation's rate ($15/$75 per M tokens) and the Haiku 3.5 rate ($0.80/$4), so every session run on those models since their launch overcounted by ~3x. Back-compute against Claude Code's `/usage` output to verify.

  This bug has always existed — the hardcoded table was never reconciled against the Anthropic repricings that shipped with Opus 4.5 on 2025-11-01 and Haiku 4.5 on 2025-10-01. Consumers of `estimate-cost` should re-run against any retros authored between those dates and today.

### Other
- Pricing source-of-truth moved from a hand-maintained dict to a vendored LiteLLM JSON (`scripts/model_prices.json`, ~20 KiB, 21 Anthropic-direct entries). Maintenance recipe documented inline near the load site. ([COST-2])
- Spec coverage: 73 → 74 normative requirements (+1 for the new refresh target).

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
