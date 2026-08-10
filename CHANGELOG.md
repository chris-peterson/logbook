# Changelog

## Unreleased

### Fixes
- **`retro estimate-cost` knows the Claude 5 generation, and defaults to it.** The vendored price table gained `claude-opus-5`, `claude-sonnet-5`, `claude-opus-4-8`, and `claude-fable-5`; the default model moves from `claude-opus-4-7` to `claude-opus-5`. No existing model's rates changed, so a figure you estimated before still stands. ([COST-3], [COST-4])
- **A model id with a context-window suffix resolves instead of erroring.** `--model claude-opus-5[1m]` — the exact id Claude Code reports for a long-context session — exited `unknown model`, because the price table keys on the base id. The suffix is now dropped, and both variants bill at the same per-token rates. ([COST-6a])

## 0.15.0

### Features
- **A note filed as an issue now goes through anchor when you have it installed.** `File an issue` used to hand you a pre-filled "new issue" URL to click through, which produced an unstructured issue and left the filing half-done until you got to the browser. With anchor present, `/logbook:note` delegates to `/anchor:issue`, which files it directly via `gh`/`glab` in the why-first shape (Context → Proposed approach → Acceptance criteria) the rest of the suite's issues use. Without anchor the pre-filled URL path is unchanged — the dependency is optional. ([NOTE-8a])

### Fixes
- **The retro template's Timeline column names its unit: `HH:MM` elapsed from session start.** The example rows showed values like `0:00` and `3:30` without saying what scale they were on, and a generator computing elapsed time naturally prints a duration as `MM:SS`. Under an hour the two are indistinguishable, so a wrong choice survives every short session and only surfaces on a multi-hour one, where `MM:SS` renders `311:14`. ([RETRO-5a])

### Other
- The docs site's home page examples come from sessions that happened, including the note-to-issue flow above — it links the issue that run filed, so you can check the story. Two claims on that page were also corrected: the note dispositions no longer list a "fresh session" option that spec v0.2 removed, and the privacy section now says where the boundary actually is (`retro publish` copies the retro directory you hand it; the CLI does read your transcript locally, to count tokens and reconstruct the session's shape).
- Requirement category prefixes are spelled out: `CFG` → `CONFIG`, `SES` → `SESSION`, `PUB` → `PUBLISH`, `PRIV` → `PRIVACY`, `INST` → `INSTALL`, `COMP` → `COMPLETION`, `EXP` → `EXPORT`. `CLI`, `RETRO`, `COST`, and `NOTE` are unchanged. Every reference in the spec, the coverage ledger, and the changelog moves with them, so an ID cited anywhere still resolves — but a citation of an old ID from outside this repo needs updating.
- Agent instructions live in `AGENTS.md`, with `CLAUDE.md` pointing at it, so tools that read either convention get the same content.

## 0.14.0

### Features
- Claude can now invoke `/logbook` and `/logbook:session-id` on its own, not just when you type them. Both carried `disable-model-invocation: true`, which held back these lightweight passthroughs from being used mid-conversation.

### Other
- The docs site's spec sits at a stable `/spec` route (sidebar entry "SPEC"), and the docsify page is generated from `plugin.yml` instead of a hand-maintained `docs/index.html` — so the shared site template and its sidebar-depth fix apply without a copied file drifting. Links to `#/SPEC.md` should point at `#/spec`.
- `plugin.json` now carries `homepage`, so the docs site surfaces from the plugin manifest and the marketplace listing.
- Build tooling and CI moved to [shipyard](https://github.com/chris-peterson/shipyard), the shared plugin build tool. The four local build scripts (plugin.json generation, docs-data generation, changelog prepend, skill-doc copy) and the hand-written release/docs-deploy workflows are replaced by a `scripts/shipyard` wrapper and thin callers of shipyard's reusable workflows, all pinned to `@v1`. Generated-artifact drift is previewed by a `Preview` CI job rather than blocked by a local pre-commit hook.
- Hooks are declared in `hooks/hooks.yml`, from which `hooks/hooks.json` is generated, and the catalog's per-skill and per-hook descriptions are read from source rather than hand-written.
- The docs-data file the shared session player fetches is now `plugin-docs.json` (was `suite.json`, which read as a Claude Code format).
- `just` recipes follow shipyard: `generate`, `check` (`generate --dry-run`), `docs`, `plugin-json`, `describe`.

## 0.13.0

### Features
- **Deferred notes no longer get stranded when a session ends before a retro.** A note left for `/logbook:retro` to consume was only surfaced if a retro actually ran; if the session ended first, it sat keyed to a dead session forever. `logbook note harvest <session-id>` now moves a session's notes log to `notes/harvested/` so its notes stop surfacing (idempotent), and `logbook note orphans` lists sessions whose `deferred` notes are still waiting on a retro — skipping the current session, live sessions, sessions idle less than a 30-minute grace window, and already-harvested ones. A `SessionStart` hook injects surviving orphans as context, a `SessionEnd` hook reminds you when the closing session still has un-harvested deferred notes, and the retro skill harvests at publish time. ([NOTE-22]–[NOTE-25], [INSTALL-13]/[INSTALL-14])

### Fixes
- **`logbook session` now rolls up sub-agent token usage.** Previously the `tokens` block (and any downstream cost estimate) reflected only the parent transcript, silently undercounting multi-agent sessions by every LLM call their orchestrated sub-agents made — often the majority of the bill. The CLI now also reads every `<session-id>/subagents/**/agent-*.jsonl` sidecar transcript (direct delegates and workflow-spawned agents both), sums them into `tokens`, and surfaces a sibling `tokens_breakdown` of `{parent, subagents, subagent_count}` for transparency. Sessions without sub-agents are unaffected. ([SESSION-14]) — surfaced by ai-sdlc's `bridge-ai-ralph-burndown` retro, where parent-only reporting understated a 57-sub-agent campaign by ~65% (~$131 reported vs ~$377 actual).

## 0.12.0

### Features
- **Export and import your session notes.** `logbook export` emits a session's notes as a JSON archive — to the console by default, or to a file with `--out-file` (optionally gzipped via `--compress`). By default it exports the active session; `--session <id>` targets one and `--all` dumps every session. `logbook import <path|->` restores them, merging by default (idempotent, never touches existing notes) or overwriting with `--replace`, with `--dry-run` to preview; it reads plain or gzipped archives, and `-` reads from stdin.
- **Notes now join cleanly with tack and beacon.** The export archive is keyed by session id — the same id tack records per route and beacon carries per session — so a session's logbook notes, tack route, and beacon activity line up in one join.
- Tab-completion now covers `export` and `import` and their flags.

### Other
- A CI test guards the zsh completion against drifting from the CLI's actual commands and flags, so a newly added subcommand can't silently ship without completion. The existing `plugin.json`-in-sync check now also runs in CI (previously local-only).
- SPEC: new `EXPORT` section specifying the export/import surface and archive format.

## 0.11.3

### Fixes
- `/logbook:note` reliably auto-fires again on a `note:` / `bug:` prefix (or when you say it's "for the retro"). In 0.11.2 those trigger cues had been moved to a `when_to_use` frontmatter field that Claude Code doesn't read, making auto-invocation unreliable; they're folded back into the skill `description`, which is always read.

### Other
- `plugin.json` now carries `author` and `repository`, so attribution and source surface in the plugin manifest and the marketplace listing.
- The `note` skill's always-resident body is ~40% smaller (3,228 → 1,903 words): hand-edit mode and the File-an-issue mechanics moved to reference files loaded only when that path runs, cutting the context cost every session pays to keep the skill available.
- Fixed Mermaid node labels in the `note` skill that used `<br/>`, which doesn't render.

## 0.11.2

### Other
- `session-id`, `retro`, and the `logbook` command are now `disable-model-invocation` — dropped from every session's always-resident context, still available via `/`.
- `note` stays model-invocable, but its trigger cues moved from inline description text to the `when_to_use` field and were tightened: it auto-fires on a `note:` / `bug:` prefix, or when you say it's for the retro.

## 0.11.1

### Other
- Trimmed the `description` frontmatter of the logbook skills (`note`, `retro`, `session-id`) to cut the always-resident context cost. `note` keeps its high-signal natural-language cues ("something is off", "this worked well", "take the wheel", "let me drive") and the `note start` / `note end` handoff; `retro` keeps "capture this session"; the redundant name-echo triggers are dropped.

## 0.11.0

### Features
- `logbook retro publish` now treats "no team configured" as a deliberate opt-out: it prints the staged retro path and exits 0, instead of failing with a fatal "no logbook config" error *after* the retro was already staged. Genuine misconfigurations — an unregistered named `--team`, or teams present with no `default_team` — still fail loudly.

## 0.10.0

### Features
- **Session notes are now a first-class record.** `/logbook:note` captures every mid-session observation — friction *or* "this worked well" — into a durable per-session log (`~/.logbook/notes/<id>.jsonl`). `logbook session` surfaces them as `notes[]`, and `/logbook:retro` reads them so it synthesizes from pre-gathered material instead of reconstructing the session cold. The note count is surfaced as a retro-worthiness signal. ([NOTE-16]–[NOTE-21], [SESSION-13], [RETRO-7]/[RETRO-8])
- **`logbook note add` / `logbook note list`** record and review a session's notes from any terminal. ([CLI-12])

### Changed
- **`/logbook:note` is now a recorder.** Recording the observation is the primary act; a note's disposition — This Session (apply + sweep), File an issue, or Defer to retro — is metadata on the record, not a fork in behavior, and every note is captured regardless of disposition.
- **Removed the `New Session` note mode** (and its `open-iterm-tab.sh` helper). It spawned a Claude session into another project — orchestration, not record-keeping. To act on a note in another repo, file an issue and pull it into a session there.

### Other
- Spec to v0.2: the `NOTE` concern is rewritten around the recorder model and the durable-log contract; coverage 97 → 108 normative requirements.

## 0.9.0

### Features
- **`/logbook:note start` / `/logbook:note end`** — a hand-edit bracket for taking the wheel. `start` stages everything as the assistant's last-known baseline and stands down so you can hand-edit files directly; `end` reads your isolated edits (the unstaged diff plus any new files), folds them into the session, and harvests the generalizable lessons through note's existing This / New / Future-Session machinery. Soft activations: "take the wheel" / "I'm gonna drive" / "let me drive" for start, "refresh context" for end. ([NOTE-10]–[NOTE-15])

### Other
- Spec coverage: 91 → 97 normative requirements (+6 for the note hand-edit bracket).

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
- `logbook session` and `logbook session-id` no longer return a stale transcript when the shell's cwd at invocation time differs from the session's origin cwd (e.g., after a Bash `cd` into another repo). Resolution now prefers the `CLAUDE_CODE_SESSION_ID` env var, then walks the process tree to the nearest `claude` ancestor and reads `~/.claude/sessions/<pid>.json`, and only falls back to cwd-derived `.jsonl` mtime sort as a last resort. The previous code checked `CLAUDE_SESSION_ID` (wrong env var name), so it always fell through to the cwd heuristic. ([SESSION-4], [SESSION-5], [SESSION-11])

## 0.3.0

### Features
- `logbook --version` (and `-v`) now reports the installed plugin version, sourced from `.claude-plugin/plugin.json`.
- The `/logbook:retro` skill now does a CLI freshness pre-flight check. If the shell `logbook` wrapper (from `/logbook:logbook install-cli`) is older than the running plugin, it surfaces a one-line note and offers to refresh.

### Fixes
- Corrected slash-command syntax in skill prose: `/logbook add-team` → `/logbook:logbook add-team`; `/logbook:session` → `/logbook:logbook session`. The slash command shim is `/<plugin>:<plugin> <subcommand>`, not `/<plugin>:<subcommand>`.
