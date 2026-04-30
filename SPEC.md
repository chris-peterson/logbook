# logbook — Specification

**Version:** 0.1
**Status:** Draft (retroactive — written after the v0.1 implementation)

logbook is a log of important learnings, e.g. AI-assisted coding session retros. It turns an AI coding session — Claude Code, Cursor, or GitHub Copilot — into a retrospective committed to a team-owned git repository. It ships as both a Claude Code plugin and a standalone CLI. Transcripts stay on the author's workstation; only the retrospective is published.

Requirements use [EARS syntax](https://alistairmavin.com/ears) with formal requirement IDs grouped by concern:

| Prefix | Concern |
|---|---|
| `CFG`  | Configuration and per-workstation state |
| `CLI`  | CLI surface and subcommand structure |
| `RETRO`| Retro generation, template, frontmatter |
| `PUB`  | Publishing to a team retro repo |
| `PRIV` | Privacy — what is and is not published |
| `INST` | Install and onboarding |
| `COMP` | Shell completions |
| `COST` | Cost estimation |
| `SES`  | Session info detection |

---

## Core Contract

The single invariant: **a retrospective committed to a team retro repo contains no session transcript** — only an author-authored markdown document with frontmatter that includes opaque identifiers (`session_id`, `device_id`) for the author to correlate with their local data.

---

## CFG — Configuration and State

- `[CFG-1]` The system shall persist all per-workstation state under `~/.logbook/` by default.
- `[CFG-2]` Where the environment variable `LOGBOOK_HOME` is set, the system shall use its value as the state root in place of `~/.logbook/`.
- `[CFG-3]` The system shall persist team registrations in a YAML file at `<LOGBOOK_HOME>/config.yaml`.
- `[CFG-4]` The configuration file shall contain a top-level `default_team` key naming the default team for retro publishing.
- `[CFG-5]` The configuration file shall contain a top-level `teams` mapping where each entry maps a team name to an object with at least a `remote` field (git URL).
- `[CFG-6]` The system shall persist a per-workstation device id at `<LOGBOOK_HOME>/device-id` as a single line of plain text.
- `[CFG-7]` When the device id file is missing, the system shall generate a 12-character lowercase hex identifier derived from the workstation's hostname and primary MAC address, and persist it to the device id file.
- `[CFG-8]` Where the device id file is deleted, the system shall regenerate the id on the next request (rotation by deletion).
- `[CFG-9]` The system shall persist team retro repo clones under `<LOGBOOK_HOME>/repos/<team-name>/`.
- `[CFG-10]` If PyYAML is not importable, then the system shall exit with a non-zero status and an actionable message before attempting any config read or write.
- `[CFG-11]` When invoked as `logbook config`, the CLI shall print a JSON object containing the resolved values of `logbook_home`, `config_path`, `device_id_path`, `template_path`, and the parsed contents of `<LOGBOOK_HOME>/config.yaml`.

---

## CLI — Surface and Subcommands

- `[CLI-1]` The system shall expose a single executable named `logbook` that accepts subcommands.
- `[CLI-2]` The CLI shall support the subcommands `session`, `add-team`, `device-id`, `config`, `retro`, and `completions`.
- `[CLI-3]` The `retro` subcommand shall support the nested subcommands `publish`, `template-path`, and `estimate-cost`.
- `[CLI-4]` When invoked with no subcommand, the CLI shall print top-level help to stdout and exit zero.
- `[CLI-5]` The CLI shall be runnable directly via `python3 <path>/logbook <args>` without prior installation.
- `[CLI-6]` Where the environment variable `CLAUDE_PLUGIN_ROOT` is set, the CLI shall resolve the plugin root from its value.
- `[CLI-7]` Where `CLAUDE_PLUGIN_ROOT` is unset, the CLI shall resolve the plugin root from the script's filesystem location (`__file__`).
- `[CLI-8]` The CLI shall be a single Python source file with no project-internal imports beyond the Python standard library and PyYAML.
- `[CLI-9]` If a subcommand fails, then the CLI shall exit with a non-zero status and write a one-line actionable error to stderr.

---

## SES — Session Info

- `[SES-1]` When invoked as `logbook session`, the CLI shall emit a JSON object on stdout describing the active AI coding session for the current workspace.
- `[SES-2]` The session JSON shall contain at minimum the keys `id`, `tool`, `model`, `start`, `end`, `tokens`, `transcript`.
- `[SES-3]` The session JSON shall contain a `slug` field derived from the session's first user prompt.
- `[SES-4]` Where `CLAUDE_SESSION_ID` is set, the CLI shall report the Claude Code session matching that id.
- `[SES-5]` While `CLAUDE_SESSION_ID` is unset, when a Claude Code project directory exists for the current workspace, the CLI shall report the most recently modified Claude Code session in that directory.
- `[SES-6]` While no Claude Code session is detected, when a VS Code workspace storage entry contains GitHub Copilot chat sessions for the current workspace, the CLI shall report the latest Copilot session.
- `[SES-7]` While no Claude Code or Copilot session is detected, when a Cursor workspace storage entry exists for the current workspace, the CLI shall report the focused Cursor composer session.
- `[SES-8]` For Claude Code sessions, the JSON output shall include a `detailed` block with at least `tool_usage`, `files_touched`, `timeline`, `user_messages`, `overlapping_sessions`, and `initial_context_tokens`.
- `[SES-9]` If no session can be detected, then the CLI shall exit with a non-zero status and an actionable error.

---

## RETRO — Retro Generation

- `[RETRO-1]` The system shall provide a single retro template at `<plugin-root>/templates/retro.md`.
- `[RETRO-2]` When invoked as `logbook retro template-path`, the CLI shall print the absolute path of the template to stdout.
- `[RETRO-3]` If the template file is missing, then `logbook retro template-path` shall exit with a non-zero status and an actionable error.
- `[RETRO-4]` The retro template shall instruct authors to include a YAML frontmatter block containing at minimum: `date`, `category`, `slug`, `session_id`, `device_id`, `cost`, `tool`, `model`.
- `[RETRO-5]` The retro template shall include sections for Summary, Result, Timeline, Context, Synthesized Prompt, What Worked Well, What Didn't Work, Observations, and Applicability.
- `[RETRO-6]` The template shall not require Feedback Targets, retro index updates, or pattern-table cross-references — those concerns belong to the consumer, not the plugin.

---

## PUB — Publishing

- `[PUB-1]` When invoked as `logbook retro publish <category> <slug> <source-dir>`, the CLI shall publish the contents of `<source-dir>` to `<clone>/retros/<category>/<slug>/` in the resolved team's local clone.
- `[PUB-2]` Where `--team <name>` is passed, the CLI shall use the named team in place of `default_team`.
- `[PUB-3]` If the named team is not registered, then the CLI shall exit with a non-zero status before performing any git operations.
- `[PUB-4]` If `default_team` is unset and `--team` is not passed, then the CLI shall exit with a non-zero status before performing any git operations.
- `[PUB-5]` When publishing, the CLI shall fetch the remote and rebase the local clone before copying retro contents.
- `[PUB-6]` If `git fetch` or `git pull --rebase` fails, then the CLI shall exit with a non-zero status, leaving the local clone in place for manual resolution.
- `[PUB-7]` If `<clone>/retros/<category>/<slug>/` already exists, then the CLI shall exit with a non-zero status before overwriting.
- `[PUB-8]` If the source directory produces no staged changes after copy, then the CLI shall exit with a non-zero status and an actionable message.
- `[PUB-9]` When publishing succeeds, the CLI shall create a single git commit with message `retro: <category>/<slug>` and push to the upstream branch.
- `[PUB-10]` If `git push` fails, then the CLI shall exit with a non-zero status and an actionable error.
- `[PUB-11]` The CLI shall not modify, sanitize, or move the source directory — it shall only copy from it.

---

## PRIV — Privacy

- `[PRIV-1]` The system shall not include session transcript content in any artifact published to a team retro repo.
- `[PRIV-2]` The retro frontmatter shall include `session_id` and `device_id` so an author can correlate a published retro to their local session data.
- `[PRIV-3]` The system shall not attempt to anonymize or hash these identifiers — they are opaque values whose privacy properties are owned by the caller.
- `[PRIV-4]` Categories shall be free-form strings — the system shall not enforce a category whitelist.

---

## INST — Install and Onboarding

- `[INST-1]` The system shall be distributable as a Claude Code plugin.
- `[INST-2]` The plugin shall declare itself in `.claude-plugin/plugin.json` with at minimum `name`, `version`, `description`, and `license`.
- `[INST-3]` The plugin shall expose a slash command at `commands/logbook.md` that maps `/logbook <args>` to the underlying CLI.
- `[INST-4]` The plugin shall expose a skill at `skills/retro/SKILL.md` for conversational retro authoring; the skill shall defer all deterministic operations to the CLI.
- `[INST-5]` When invoked as `logbook add-team <git-url>`, the CLI shall clone the URL into `<LOGBOOK_HOME>/repos/<team>/` where `<team>` is derived from the URL basename or supplied via `--as <name>`.
- `[INST-6]` On the first `logbook add-team` invocation, the CLI shall create `<LOGBOOK_HOME>/config.yaml` and set the new team as `default_team`.
- `[INST-7]` On subsequent `logbook add-team` invocations, the CLI shall add the new team to `teams` without changing `default_team`.
- `[INST-8]` If the local clone path for a team already exists, then `logbook add-team` shall exit with a non-zero status before performing any git operations.
- `[INST-9]` If `git clone` fails, then `logbook add-team` shall exit with a non-zero status and an actionable error.
- `[INST-10]` Team names shall match the pattern `^[a-z0-9][a-z0-9_-]*$`. If the supplied or derived name does not match, then the CLI shall exit with a non-zero status.

---

## COMP — Shell Completions

- `[COMP-1]` The CLI shall expose a `completions` subcommand for installing shell completions.
- `[COMP-2]` The CLI shall support `zsh` as a completion target. It shall reject other shell names with a non-zero status.
- `[COMP-3]` When invoked as `logbook completions zsh`, the CLI shall write the completion script to `~/.zsh/completions/_logbook`.
- `[COMP-4]` Where the `--print` flag is passed, the CLI shall write the completion script to stdout instead of installing it.
- `[COMP-5]` The completion script shall offer top-level subcommands and the `retro` subcommand's nested commands.
- `[COMP-6]` The `install-cli` subcommand shall install the zsh completion script in addition to the wrapper, so a single invocation provisions both PATH access and tab completion.

---

## COST — Cost Estimation

- `[COST-1]` When invoked as `logbook retro estimate-cost <input> <output> <cache_create> <cache_read>`, the CLI shall print a single line of the form `~$X.XX` to stdout.
- `[COST-2]` The CLI shall apply Anthropic's published per-million-token pricing for the resolved model.
- `[COST-3]` Where `--model <name>` is passed, the CLI shall use that model's pricing. The default model shall be `opus-4.7`.
- `[COST-4]` The CLI shall recognize at minimum the model identifiers `opus-4.7`, `opus-4.6`, `sonnet-4.6`, `haiku-4.5`.
- `[COST-5]` If an unknown model is requested, then the CLI shall exit with a non-zero status and list the supported models.
- `[COST-6]` Where the supplied model identifier contains the `claude-` prefix or differs only by separator, the CLI shall normalize and accept it.

---

## Non-Goals (v0.1)

- Sanitizing transcripts. (The transcript is the caller's responsibility.)
- A separate retro index, retro categories registry, or any cross-retro aggregation surface.
- Docsify rendering of the team retro repo.
- Session replay or playback (deferred — see [retro playback issue](https://gitlab.getty.cloud/cpeterson/ai-sdlc/-/issues/2)).
- Anonymization of `session_id` or `device_id`.
- Multi-author or multi-tenant features beyond multiple teams per workstation.
- An MCP server or read-side aggregation API.

---

## Open Questions

- Should a `logbook retro stage <category> <slug>` subcommand exist to create the staging directory and seed the frontmatter? Currently the skill issues `mkdir -p` directly. Pro: more deterministic. Con: thinner skill is a virtue.
- Should `logbook add-team` support changing `default_team` (e.g. via `--default`)? Currently default is set only on first registration; users edit the YAML to change it.
- Should a `logbook doctor` subcommand validate config + clones + git access in one shot? Useful for onboarding triage.
