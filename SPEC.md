# logbook — Specification

**Version:** 0.2
**Status:** Draft

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
| `NOTE` | Mid-session notes — capture, durable log, disposition |
| `EXP`  | Export and import of the notes stash |

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
- `[CLI-2]` The CLI shall support the subcommands `session`, `session-id`, `note`, `add-team`, `device-id`, `config`, `export`, `import`, `retro`, `install-cli`, and `completions`.
- `[CLI-3]` The `retro` subcommand shall support the nested subcommands `publish`, `template-path`, and `estimate-cost`.
- `[CLI-12]` The `note` subcommand shall support the nested subcommands `add`, `list`, `harvest`, and `orphans`.
- `[CLI-4]` When invoked with no subcommand, the CLI shall print top-level help to stdout and exit zero.
- `[CLI-5]` The CLI shall be runnable directly via `python3 <path>/logbook <args>` without prior installation.
- `[CLI-6]` Where the environment variable `CLAUDE_PLUGIN_ROOT` is set, the CLI shall resolve the plugin root from its value.
- `[CLI-7]` Where `CLAUDE_PLUGIN_ROOT` is unset, the CLI shall resolve the plugin root from the script's filesystem location (`__file__`).
- `[CLI-8]` The CLI shall be a single Python source file with no project-internal imports beyond the Python standard library and PyYAML.
- `[CLI-9]` If a subcommand fails, then the CLI shall exit with a non-zero status and write a one-line actionable error to stderr.
- `[CLI-10]` When invoked as `logbook --version` or `logbook -v`, the CLI shall print the value of `<plugin-root>/.claude-plugin/plugin.json#version` and exit zero.
- `[CLI-11]` When invoked as `logbook --help`, `-h`, or `help`, the CLI shall print top-level help to stdout and exit zero.

---

## SES — Session Info

- `[SES-1]` When invoked as `logbook session`, the CLI shall emit a JSON object on stdout describing the active AI coding session for the current workspace.
- `[SES-2]` The session JSON shall contain at minimum the keys `id`, `name`, `tool`, `model`, `start`, `end`, `tokens`, `transcript`, where `name` is the cleaned first user prompt.
- `[SES-3]` The session JSON shall contain a `slug` field, the slugified form of `name` (the session's first user prompt).
- `[SES-4]` Where `CLAUDE_CODE_SESSION_ID` is set, the CLI shall report the Claude Code session matching that id.
- `[SES-5a]` While `CLAUDE_CODE_SESSION_ID` is unset, the CLI shall walk its own process ancestry to the nearest `claude` process and, if `~/.claude/sessions/<pid>.json` exists for that PID, report the session named in that record.
- `[SES-5b]` While `CLAUDE_CODE_SESSION_ID` is unset and no `claude` ancestor or session record is found, the CLI shall fall back to the most-recently-modified `.jsonl` in the cwd-derived project directory under `~/.claude/projects/`.
- `[SES-6]` While no Claude Code session is detected, when a VS Code workspace storage entry contains GitHub Copilot chat sessions for the current workspace, the CLI shall report the latest Copilot session.
- `[SES-7]` While no Claude Code or Copilot session is detected, when a Cursor workspace storage entry exists for the current workspace, the CLI shall report the focused Cursor composer session.
- `[SES-8]` For Claude Code sessions, the JSON output shall include a `detailed` block with at least `tool_usage`, `files_touched`, `timeline`, `user_messages`, `overlapping_sessions`, `concurrency`, and `initial_context_tokens`. The `concurrency` block shall report `overlapping` (count of overlapping sessions), `max_parallel` (peak simultaneous sessions over the current session's window, including the current session, computed by a sweep line where touching boundaries do not count as concurrent), and `wall_hours` (the current session's wall-clock span). The `detailed` block may additionally include `compaction` (event timestamps and line numbers) and `git_activity` (commit timeline across detected repos for the last 7 days) when the relevant data is present.
- `[SES-9]` If no session can be detected, then the CLI shall exit with a non-zero status and an actionable error.
- `[SES-10]` When invoked as `logbook session-id`, the CLI shall write only the active session's identifier followed by a newline to stdout, without parsing the session transcript or computing the `detailed` block.
- `[SES-11a]` The `session-id` subcommand shall use the same detection precedence as `session`: `CLAUDE_CODE_SESSION_ID` env, then `claude`-ancestor PID lookup via `~/.claude/sessions/<pid>.json`, then the most-recently-modified Claude Code session for the current workspace.
- `[SES-11b]` If no Claude Code session is detected, then `session-id` shall exit with a non-zero status and an actionable error.
- `[SES-12]` Where the platform is not macOS, the behavior of Copilot and Cursor session detection ([SES-6], [SES-7]) is undefined — the implementation reads from paths under `~/Library/Application Support/`.
- `[SES-13]` The `session` JSON shall include a top-level `notes` array holding the records from the active session's durable notes log ([NOTE-16]), in capture order, so a retro (or a spawned retro worker) receives them as pre-gathered material. Where the session has no notes log, `notes` shall be an empty array.
- `[SES-14]` For Claude Code sessions, the `tokens` block shall aggregate LLM usage across the **parent transcript and every sub-agent transcript** the session spawned — including workflow-spawned agents — so cost estimation reflects the entire orchestration tree, not just the orchestrator. Sub-agent transcripts are located in the sidecar directory named for the session id alongside the parent transcript (`<projects>/<encoded-cwd>/<session-id>/subagents/**/agent-*.jsonl`). Where at least one sub-agent transcript is present, the output shall additionally include a `tokens_breakdown` object with `parent`, `subagents`, and `subagent_count` so consumers can render a parent-vs-sub-agent split without re-parsing transcripts.

---

## RETRO — Retro Generation

- `[RETRO-1]` The system shall provide a single retro template at `<plugin-root>/templates/retro.md`.
- `[RETRO-2]` When invoked as `logbook retro template-path`, the CLI shall print the absolute path of the template to stdout.
- `[RETRO-3]` If the template file is missing, then `logbook retro template-path` shall exit with a non-zero status and an actionable error.
- `[RETRO-4]` The retro template shall instruct authors to include a YAML frontmatter block containing at minimum: `date`, `category`, `slug`, `session_id`, `device_id`, `cost`, `tool`, `model`.
- `[RETRO-5]` The retro template shall include sections for Summary, Result, Timeline, Context, Synthesized Prompt, What Worked Well, What Didn't Work, Observations, and Applicability.
- `[RETRO-6]` The template shall not require Feedback Targets, retro index updates, or pattern-table cross-references — those concerns belong to the consumer, not the plugin.
- `[RETRO-7]` The `retro` skill shall read the active session's `notes` ([SES-13]) as pre-gathered retro material and synthesize from it — confirming and expanding the captured notes — rather than reconstructing the session cold.
- `[RETRO-8]` The `retro` skill shall surface the count of captured notes as a retro-worthiness signal when proposing whether to generate a retro.

---

## PUB — Publishing

- `[PUB-1]` When invoked as `logbook retro publish <category> <slug> <source-dir>`, the CLI shall publish the contents of `<source-dir>` to `<clone>/retros/<category>/<slug>/` in the resolved team's local clone.
- `[PUB-2]` Where `--team <name>` is passed, the CLI shall use the named team in place of `default_team`.
- `[PUB-3]` If the named team is not registered, then the CLI shall exit with a non-zero status before performing any git operations.
- `[PUB-4]` If one or more teams are registered but `default_team` is unset and `--team` is not passed, then the CLI shall exit with a non-zero status before performing any git operations.
- `[PUB-12]` If no team is configured (no `default_team` and no `teams`) and `--team` is not passed, then the CLI shall treat this as an opt-out: print the staged source directory and an actionable hint, then exit with status zero without performing any git operations.
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
- `[PRIV-5]` The durable notes log ([NOTE-16]) and its harvested archive ([NOTE-22], `<LOGBOOK_HOME>/notes/harvested/`) are per-workstation state under `<LOGBOOK_HOME>/` — the system shall not publish them to a team retro repo. A retro author may quote or paraphrase notes into the authored retro document, but the raw log is not itself an artifact.

---

## INST — Install and Onboarding

- `[INST-1]` The system shall be distributable as a Claude Code plugin.
- `[INST-2]` The plugin shall declare itself in `.claude-plugin/plugin.json` with at minimum `name`, `version`, `description`, and `license`.
- `[INST-3]` The plugin shall expose a slash command at `commands/logbook.md` that maps `/logbook:logbook <args>` to the underlying CLI.
- `[INST-4]` The plugin shall expose one or more skills under `skills/`; each skill shall defer deterministic operations to the CLI rather than reimplementing them. Skills that are purely conversational orchestrators with no deterministic operations are permitted.
- `[INST-5]` When invoked as `logbook add-team <git-url>`, the CLI shall clone the URL into `<LOGBOOK_HOME>/repos/<team>/` where `<team>` is derived from the URL basename or supplied via `--as <name>`.
- `[INST-6]` On the first `logbook add-team` invocation, the CLI shall create `<LOGBOOK_HOME>/config.yaml` and set the new team as `default_team`.
- `[INST-7]` On subsequent `logbook add-team` invocations, the CLI shall add the new team to `teams` without changing `default_team`.
- `[INST-8]` If the local clone path for a team already exists, then `logbook add-team` shall exit with a non-zero status before performing any git operations.
- `[INST-9]` If `git clone` fails, then `logbook add-team` shall exit with a non-zero status and an actionable error.
- `[INST-10]` Team names shall match the pattern `^[a-z0-9][a-z0-9_-]*$`. If the supplied or derived name does not match, then the CLI shall exit with a non-zero status.
- `[INST-11]` When invoked as `logbook install-cli [--dir <path>]`, the CLI shall write a bash wrapper to `<path>/logbook` (default `~/.local/bin/logbook`) that execs `python3 <plugin-root>/scripts/logbook "$@"`, and shall also install zsh completions per [COMP-3].
- `[INST-12]` The plugin shall register a `SessionStart` hook that detects drift between the installed `logbook` CLI wrapper version and `<plugin-root>/.claude-plugin/plugin.json#version`, and surfaces an `additionalContext` notice when they differ. The hook shall be silent when versions match and silent when the CLI is not on PATH.
- `[INST-13]` The plugin shall register a `SessionStart` hook that injects the orphan sessions ([NOTE-23]) as `additionalContext`, naming the starting session as current via `note orphans --current`, and stays silent when none exist.
- `[INST-14]` The plugin shall register a `SessionEnd` hook that, when the closing session has un-harvested `deferred` notes, surfaces a `systemMessage` reminder that those notes are parked for a retro, and stays silent otherwise.

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
- `[COST-2]` The CLI shall apply Anthropic's published per-token pricing for the resolved model, sourced from the vendored LiteLLM price table at `scripts/model_prices.json`.
- `[COST-3]` Where `--model <name>` is passed, the CLI shall use that model's pricing. The default model shall be `claude-opus-4-7`.
- `[COST-4]` The CLI shall recognize at minimum the model identifiers `claude-opus-4-7`, `claude-opus-4-6`, `claude-sonnet-4-6`, `claude-haiku-4-5`.
- `[COST-5]` If an unknown model is requested, then the CLI shall exit with a non-zero status and list the supported models.
- `[COST-6]` Where the supplied model identifier omits the `claude-` prefix or substitutes `.` for `-` (e.g. `opus-4.7` for `claude-opus-4-7`), the CLI shall normalize and accept it.
- `[COST-7]` The repository shall provide a `just refresh-prices` target that re-downloads the LiteLLM price file and writes the filtered Anthropic-direct subset to `scripts/model_prices.json`.

---

## NOTE — Mid-Session Notes

The `note` skill is a **recorder**: it captures a mid-session observation as
retro material — friction *or* something that worked well — and appends it to a
durable, session-scoped notes log. Recording is the primary act; the
*disposition* (what to do about the note) is metadata on the record. logbook
records that a disposition was chosen; actuation that lives outside its domain —
spawning or forking sessions to another project — is delegated to the
orchestration layer, not performed here.

### Capture and disposition

- `[NOTE-1]` The plugin shall expose a `note` skill at `skills/note/SKILL.md` that captures a mid-session observation — friction *or* a positive ("this worked well") — about a target artifact (a rule, skill, `CLAUDE.md`, recipe, setting, or similar) as retro material.
- `[NOTE-2]` When invoked with a prose observation, the skill shall identify the target artifact from the observation. If multiple plausible targets exist, then the skill shall list the candidates and ask the user before proceeding.
- `[NOTE-3]` On every prose-observation invocation, the skill shall record the observation to the durable notes log ([NOTE-16]) via `logbook note add` — this is the primary act, performed regardless of which disposition follows.
- `[NOTE-4]` The skill shall assign each note a disposition of `this-session`, `issue`, or `deferred`, proposing a default from the target location and observation scope and confirming with the user before acting. The chosen disposition shall be recorded on the note ([NOTE-19]).
- `[NOTE-5]` In the `this-session` disposition, the skill shall apply the change in the current session and shall sweep comparable sites per the `sweep-the-learnings` rule, reporting affected sites before returning to prior work.
- `[NOTE-6]` In the `issue` disposition, the skill shall not modify the target artifact and shall not spawn a session; it shall write the structured note body to a unique temporary file and print the path so the user can open or attach the file in a follow-up step.
- `[NOTE-7]` In the `issue` disposition, where a clipboard utility is available (`pbcopy` on macOS, `wl-copy` or `xclip` on Linux, `clip.exe` on Windows), the skill shall copy the note body to the system clipboard on a best-effort basis and report whether the copy succeeded.
- `[NOTE-8]` In the `issue` disposition, where the current working directory is a git repository whose origin host is a recognized forge (currently `github.com` and any `gitlab.*` host), the skill shall print a "create issue" URL with the title and body query-encoded so a single click opens a pre-populated new-issue form. For unrecognized hosts or non-git directories the skill shall omit the URL without erroring.
- `[NOTE-8a]` In the `issue` disposition, where the anchor plugin's `issue` skill is available to the agent, the skill shall delegate filing to it — passing the observation, the resolved target, and the user's rationale as the issue intent — in place of emitting the tempfile, clipboard, and URL artifacts of [NOTE-6]–[NOTE-8], so notes land in the same why-first shape as the rest of the suite's issues. Availability shall be determined from the agent's own skill listing rather than a filesystem probe, since the listing reflects invocability rather than presence on disk. Where anchor is unavailable, [NOTE-6]–[NOTE-8] apply unchanged; the dependency is optional and logbook shall not require anchor to be installed.
- `[NOTE-9]` In the `deferred` disposition, the skill shall take no action beyond the [NOTE-3] record; the note is left for `/logbook:retro` to consume.

### Harvest and orphan backstop

A `deferred` note ([NOTE-9]) is consumed by a retro. The harvest lifecycle marks a session's notes consumed so they stop surfacing, and the orphan backstop finds sessions whose deferred notes are still waiting because no retro ran.

- `[NOTE-22]` When invoked as `logbook note harvest <session-id>`, the CLI shall move that session's notes log from `<LOGBOOK_HOME>/notes/<session-id>.jsonl` to `<LOGBOOK_HOME>/notes/harvested/<session-id>.jsonl`, creating the `harvested/` directory on first use. The subcommand shall be idempotent: where the source log is absent, it shall report that and exit zero.
- `[NOTE-23]` A session is an orphan when all of: it is not the current session; it is not live (its id is not the `sessionId` of any `~/.claude/sessions/<pid>.json` whose pid is alive); its transcript has been idle longer than a grace window (30 minutes); its notes log has not been harvested; and it carries at least one `deferred` note. Notes with `this-session` or `issue` dispositions have their own resolution paths ([NOTE-5], [NOTE-6]) and shall not make a session an orphan.
- `[NOTE-24]` When invoked as `logbook note orphans`, the CLI shall list the sessions matching the [NOTE-23] predicate — with `--json` as raw records carrying at minimum `session_id`, `deferred_count`, and `idle_seconds`; otherwise as a human-readable summary including the count. The subcommand shall accept `--current <id>` to name the session treated as current, falling back to the [SES-11a] detection precedence when absent. Where no session matches, the CLI shall report none and exit zero.
- `[NOTE-25]` A retro implementation that consumes a session's notes shall call `logbook note harvest <session-id>` at publish time, so harvesting fires regardless of which publish path the retro uses.

### Durable notes log

- `[NOTE-16]` The system shall persist notes in an append-only log at `<LOGBOOK_HOME>/notes/<session-id>.jsonl`, one JSON object per line, where `<session-id>` is the active session's identifier.
- `[NOTE-17]` Each note record shall contain at minimum `text` (the observation), `captured_at` (an ISO 8601 timestamp), and `transcript_line` (the line offset into the active session transcript at capture time — "where you are in the transcript"). A record may additionally carry `disposition` (`this-session` | `issue` | `deferred`), `kind` (`friction` | `win`), and `target` (the identified artifact path).
- `[NOTE-18]` When invoked as `logbook note add <text>`, the CLI shall resolve the active session via the [SES-11a] detection precedence, compute `transcript_line` from the current transcript line count, append one record to that session's notes log, and create the log (and its parent directory) on first write. Where no session can be resolved, the CLI shall exit with a non-zero status and an actionable error.
- `[NOTE-19]` The `note add` subcommand shall accept optional `--disposition`, `--kind`, and `--target` values and record them on the appended note.
- `[NOTE-20]` When invoked as `logbook note list`, the CLI shall print the active session's notes — or those of the session named by `--session <id>` — and with `--json` shall emit the raw records; otherwise it shall print a human-readable summary that includes the note count. Where the session has no notes log, the CLI shall report zero notes and exit zero.
- `[NOTE-21]` The note record schema of [NOTE-17] is the contract consumed by retro generation and by downstream retro implementations; a change to it shall be reflected in this spec.

### Hand-edit bracket

- `[NOTE-10]` The skill shall additionally support a hand-edit bracket, distinct from the prose-observation flow, invoked as `note start` and `note end` (also recognizing `begin` / `done` / `refresh` and equivalent natural phrasings such as "take the wheel" / "I'm gonna drive" / "let me drive" for start, and "refresh context" for end). The bracket lets the user hand-edit files and have the skill read those edits back as the observation.
- `[NOTE-11]` On `note start`, where the working directory is a git repository, the skill shall stage all changes (`git add -A`) so the index records the assistant's last-known baseline, write a bracket marker under the repository's git directory, and stand down without making further edits until `end`. Where the working directory is not a git repository, the skill shall report this and not open a bracket.
- `[NOTE-12]` On `note end`, the skill shall compute the user's hand-edits as the unstaged diff against the staged baseline together with any untracked files, read the changed and new files in full, and incorporate them into the session as the current source of truth.
- `[NOTE-13]` On `note end`, if no bracket marker is present and nothing is staged, the skill shall warn that the user's edits cannot be isolated from other uncommitted work and ask the user whether to proceed before harvesting.
- `[NOTE-14]` On `note end`, the skill shall infer the lesson behind each meaningful edit, classify it as local-only or generalizable, record each generalizable lesson via [NOTE-3], and route it through the disposition machinery of `[NOTE-4]` (`this-session` / `issue` / `deferred`).
- `[NOTE-15]` On `note end`, after harvesting the skill shall remove the bracket marker and unstage the baseline (`git reset`), returning the working tree to a unified uncommitted state without committing or discarding any work, and report that state.

---

## EXP — Export and Import

Notes are an ephemeral, session-scoped stash (`[NOTE-16]`): captured mid-session, consumed at retro, durable only so a session closed early or abandoned does not lose them. Export and import move that stash between workstations, recover an abandoned session's notes, or produce an artifact that joins with tack's and beacon's data. The join key is the Claude Code session id — the same id tack records in `route.sessions[].id` and beacon carries in its wip payload's `session`.

### Archive format

- `[EXP-1]` The export archive shall be a JSON document with top-level keys `schemaVersion` (integer), `exportedAt` (ISO 8601 timestamp), `generator` (`logbook <version>`), `device_id` (the exporting workstation's device id, or null), and `sessions` (an array).
- `[EXP-2]` Each `sessions[]` entry shall contain `session_id` (the Claude Code session id) and `notes` (the session's note records per `[NOTE-17]`, in capture order). Sessions with no notes shall be omitted.
- `[EXP-3]` The current archive `schemaVersion` shall be `1`. Import shall refuse an archive whose `schemaVersion` exceeds the reader's, exiting non-zero with an actionable message, so a future revision can ship a migration rather than silently mishandling unknown fields.

### Export

- `[EXP-4]` When invoked as `logbook export`, the CLI shall build an archive and, by default, write its JSON to stdout.
- `[EXP-5]` With no `--session` or `--all`, `export` shall resolve the active session via the `[SES-11a]` detection precedence and export only that session; where no session is detected it shall exit non-zero with an actionable message.
- `[EXP-6]` Where `--session <id>` is passed, `export` shall export only that session's notes. Where `--all` is passed, `export` shall export every session with a notes log under `<LOGBOOK_HOME>/notes/`.
- `[EXP-7]` Where `--out-file <path>` is passed, `export` shall write the archive to that path instead of stdout and print a one-line summary of the counts, size, and schema version.
- `[EXP-8]` Where `--compress` is passed, `export` shall gzip the archive bytes, whether the sink is a file or stdout.

### Import

- `[EXP-9]` When invoked as `logbook import <path>`, the CLI shall read the archive from that path, or from stdin where `<path>` is `-`, and shall accept both plain-JSON and gzip-compressed archives, detecting gzip by its magic bytes.
- `[EXP-10]` Import shall restore each archived session's notes into `<LOGBOOK_HOME>/notes/<session-id>.jsonl`, creating the log and its parent directory on first write.
- `[EXP-11]` In the default `--merge` mode, import shall be additive: for each session it shall append only the archived notes not already present in the local log, identifying a note by its `captured_at` and `text`, and shall never mutate or reorder existing records.
- `[EXP-12]` Where `--replace` is passed, import shall overwrite each archived session's local notes log with the archived notes. Passing both `--merge` and `--replace` shall exit non-zero.
- `[EXP-13]` Where `--dry-run` is passed, import shall report what it would change — per session, notes added and already present — without writing to any log.
- `[EXP-14]` Import shall not restore `device_id` or any config; the archive's `device_id` is provenance metadata only, since the device id is per-workstation state (`[CFG-7]`).

---

## Non-Goals (v0.1)

- Sanitizing transcripts. (The transcript is the caller's responsibility.)
- A separate retro index, retro categories registry, or any cross-retro aggregation surface.
- Docsify rendering of the team retro repo.
- Session replay or playback.
- Anonymization of `session_id` or `device_id`.
- Multi-author or multi-tenant features beyond multiple teams per workstation.
- An MCP server or read-side aggregation API.

---

## Open Questions

- Should a `logbook retro stage <category> <slug>` subcommand exist to create the staging directory and seed the frontmatter? Currently the skill issues `mkdir -p` directly. Pro: more deterministic. Con: thinner skill is a virtue.
- Should `logbook add-team` support changing `default_team` (e.g. via `--default`)? Currently default is set only on first registration; users edit the YAML to change it.
- Should a `logbook doctor` subcommand validate config + clones + git access in one shot? Useful for onboarding triage.
