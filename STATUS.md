# logbook — Spec Coverage Status

Tracking status of the requirements declared in [SPEC.md](SPEC.md). Updated
after each `/spec-audit`, when implementation lands, or when the spec is
revised.

**Last audit:** 2026-07-08
**Spec version:** v0.2
**Coverage:** 129 / 129 normative requirements (all Covered); 0 deferred

## Status by category

| Prefix | Count | Status | Notes |
|--------|------:|--------|-------|
| CFG | 11 | All Covered | `scripts/logbook` config + state |
| CLI | 12 | All Covered | `scripts/logbook` argv dispatch; CLI-2 enumeration includes `note`; CLI-12 (`note add`/`list`/`harvest`/`orphans` nested) |
| SES | 16 | All Covered | `scripts/logbook` session detection; SES-5a/5b and SES-11a/11b each count as one; SES-13 (`notes[]` in session JSON); SES-14 (sub-agent token roll-up + `tokens_breakdown`) |
| RETRO | 8 | All Covered | `templates/retro.md`; RETRO-7/8 (`retro` reads `notes[]`, surfaces the count) — `skills/retro/SKILL.md` |
| PUB | 11 | All Covered | `scripts/logbook` retro publish path |
| PRIV | 5 | All Covered | Core contract; PRIV-5 (notes log is local-only, never published) |
| INST | 14 | All Covered | `commands/logbook.md`, `skills/`, `hooks/`; INST-13/14 (`SessionStart`/`SessionEnd` orphan-notes hook, `hooks/orphan-notes.sh`) |
| COMP | 6 | All Covered | `scripts/logbook` completions + `install-cli` |
| COST | 7 | All Covered | `scripts/logbook` retro estimate-cost; `scripts/model_prices.json` |
| EXP | 14 | All Covered | `scripts/logbook` `export`/`import` + archive format (shipped in 0.12.0) |
| NOTE | 25 | All Covered | `skills/note/SKILL.md` recorder model: dispositions This Session/File an issue/Defer to retro; durable notes log + `logbook note add`/`list`/`harvest`/`orphans` (`scripts/logbook`); NOTE-22..25 (harvest lifecycle + orphan backstop); `start`/`end` hand-edit bracket |

## Audit history

### 2026-07-08 — harvest lifecycle + orphan-notes backstop

Closed the gap where a `deferred` note ([NOTE-9]) is stranded when a session
ends before a retro runs. Added the harvest lifecycle and a two-ended backstop.

- **Spec (SPEC.md)** — `[NOTE-22]` (`note harvest <sid>` moves the log to
  `notes/harvested/`, idempotent), `[NOTE-23]` (orphan predicate: not current,
  not live, idle past a 30-minute grace window, not harvested, has a `deferred`
  note), `[NOTE-24]` (`note orphans` with `--json`/`--current`), `[NOTE-25]`
  (a retro harvests at publish time). `[INST-13]`/`[INST-14]` (the
  `SessionStart`/`SessionEnd` orphan-notes hook). `[CLI-12]` and `[PRIV-5]`
  reworded for the new subcommands and the `harvested/` archive.
- **Implementation** — `scripts/logbook` gains `cmd_note_harvest`,
  `cmd_note_orphans`, `_orphan_sessions`, `_live_session_ids`, `_pid_is_alive`.
  `hooks/orphan-notes.sh` registered for both events in `hooks/hooks.json`.
- **Coverage delta** — +6 normative requirements (NOTE-22..25, INST-13/14);
  123 → 129, all Covered.

### 2026-07-08 — sub-agent token roll-up + EXP backfill

Added `[SES-14]`: `logbook session` now aggregates token usage across the parent
transcript and every sub-agent transcript (direct delegates and workflow-spawned
agents), and exposes a `tokens_breakdown` split. Parent-only reporting had
undercounted multi-agent sessions by every LLM call their sub-agents made.

- **Spec (SPEC.md)** — `[SES-14]` (roll-up + `tokens_breakdown` shape).
- **Implementation (`scripts/logbook`)** — `_sum_subagent_tokens` walks the
  `<session-id>/subagents/**/agent-*.jsonl` sidecar tree; `_print_claude_session`
  folds it into `tokens` and emits `tokens_breakdown` when sub-agents are present.
- **Backfill** — reconciled the coverage table with the `EXP-1..14` requirements
  shipped in 0.12.0, whose export/import surface landed without a STATUS update.
- **Coverage delta** — 108 → **123** (+1 SES-14, +14 EXP backfill). SES 15 → 16,
  new EXP row (14).

### 2026-06-24 — recorder model: notes as a first-class noun (spec v0.2)

Reframed `note` from "flag something broken + act on it" into a **recorder**:
every note is captured as retro material, and the disposition is metadata on the
record. logbook records that a disposition was chosen; it no longer performs
session orchestration. Closes the capture → accumulate → synthesize loop end to
end inside the plugin.

- **Spec (SPEC.md) → v0.2** — `NOTE` concern rewritten. The `New Session`
  forking disposition and its `[NOTE-5]` requirement are gone; dispositions are
  now `this-session` / `issue` / `deferred`. Added the durable notes log:
  `[NOTE-16]` (append-only `~/.logbook/notes/<id>.jsonl`), `[NOTE-17]` (record
  schema — the downstream contract), `[NOTE-18]`/`[NOTE-19]` (`note add`),
  `[NOTE-20]` (`note list`), `[NOTE-21]` (schema-is-contract). `[SES-13]`
  (`notes[]` in session JSON), `[CLI-12]` (`note add`/`list`), `[PRIV-5]` (log is
  local-only), `[RETRO-7]`/`[RETRO-8]` (`retro` reads `notes[]`, surfaces the
  count as a worthiness signal).
- **Implementation (`scripts/logbook`)** — `note add` (resolves the session,
  captures the transcript line, appends a record) and `note list`; `session`
  merges `notes[]`; argparse + zsh completions wired.
- **Skills** — `skills/note/SKILL.md` rewritten for the recorder model;
  `skills/retro/SKILL.md` reads `notes[]` and confirms-and-expands from it.
- **Descoped** — deleted `scripts/open-iterm-tab.sh`; session forking/spawning
  is the orchestration layer's job (file an issue and pull it into a session
  there), not the recorder's.
- **Coverage delta** — 97 → **108** normative requirements (+11). NOTE 15 → 21,
  CLI 11 → 12, SES 14 → 15, RETRO 6 → 8, PRIV 4 → 5.

### 2026-06-22 — NOTE hand-edit bracket

Added the `note start` / `note end` hand-edit bracket (`[NOTE-10]`–`[NOTE-15]`):
`start` stages a baseline and stands down so the user can take the wheel; `end`
reads the isolated unstaged diff, incorporates it into the session, and harvests
generalizable lessons through the existing `[NOTE-3]` mode machinery. Pure
skill-level logic (git + bash); no CLI surface touched. 91 → 97 normative
requirements (+6).

### 2026-06-17 — pricing verified current

Spot-checked the vendored price table (`scripts/model_prices.json`, last
refreshed 2026-05-28) against Anthropic's published rates: Opus 4.7/4.6
($5/$25), Sonnet 4.6 ($3/$15), and Haiku 4.5 ($1/$5) per MTok all unchanged.
No refresh needed. (Opus 4.8 has since shipped at the same Opus-tier $5/$25 but
is not yet in the table — `--model claude-opus-4-7` gives the same figure.)

### 2026-06-04 — Coverage refresh + NOTE mode-name reword (spec-sync --to-spec)

Corrected ledger counts and resolved the NOTE mode-name drift. Normative count
fixed 75 → **91** (the header, the category table, and the spec inventory had
all disagreed); SES row 12 → 14 (lettered splits each count as one); the "+7
deferred" line dropped (no FUT/deferred IDs exist). `[NOTE-3]`–`[NOTE-9]`
reworded `now`/`parallel`/`log` → `This Session`/`New Session`/`Future Session`
to match the skill rename (commit `23a7da2`) — names only, no behavior change.
NOTE back to All Covered; 91/91.

### 2026-06-03 — concurrency metric moved into the tool

The retro skill used to have the agent generate a throwaway sweep-line Python
script per session to compute peak simultaneous sessions — wasted tokens and a
per-run permission prompt. `logbook session` already emitted everything the
sweep needs (each overlapping session's window plus the current session's
`start`/`end`), so the computation moves into the CLI.

- **Implementation (`scripts/logbook`)** — added `_compute_concurrency`, emitted
  as `detailed.concurrency` with `overlapping`, `max_parallel`, and `wall_hours`.
- **Spec edit (SPEC.md)** — `[SES-8]` now requires `concurrency` in the
  `detailed` block and specifies its three fields and the sweep-line rule.
- **Skill edit (`skills/retro/SKILL.md`)** — Step 1 reads `max_parallel` /
  `wall_hours` directly instead of recomputing.
- **Coverage delta** — none; `[SES-8]` is an existing requirement with expanded
  scope. Still 75 / 75.

### 2026-05-31 — spec-alignment pass (CLI-2 closed, EARS cleanups)

Follow-up to the same-day 0.6.0–0.7.0 review, which had reconciled `[CLI-2]`
to Partial. This pass applies the spec edits that close it and clears the
low-priority EARS backlog flagged in that audit.

- **Spec edits applied (SPEC.md)**
  - `[CLI-2]` enumeration: added the shipped `install-cli` subcommand and
    aligned the ordering with the module docstring (`session`, `session-id`,
    `add-team`, `device-id`, `config`, `retro`, `install-cli`, `completions`).
    Closes the lone Partial; CLI is now All Covered.
  - `[SES-2]`/`[SES-3]`: split the key-set guarantee from the
    name-definition note and removed the duplicated `slug` definition that
    overlapped `[SES-3]`. SES-2 now states the required keys plus the `name`
    definition; SES-3 defines `slug` as the slugified form of `name`.
  - `[SES-5]` → `[SES-5a]`/`[SES-5b]`: decomposed the 3-level detection +
    fallback into additive lettered sub-requirements (PID-lookup hit;
    project-directory fallback).
  - `[SES-11]` → `[SES-11a]`/`[SES-11b]`: same decomposition for `session-id`
    (detection precedence; error path on no-session).
  - `[SES-12]`: reworded from descriptive prose into Optional EARS form
    ("Where the platform is not macOS, the behavior of [SES-6]/[SES-7] is
    undefined").
  - Left `CFG-4`, `CFG-5`, `RETRO-4`, `RETRO-5`, `INST-2` as-is — acceptable
    Ubiquitous "shall contain/include" form.

- **Coverage delta**
  - No net change: 74 / 74 normative requirements, now all Covered (CLI-2
    moves Partial → Covered). The SES-5/SES-11 lettered splits re-express
    existing requirements rather than adding normative surface.

### 2026-05-24 — COST pricing source-of-truth

Triggered by an audit of `retro estimate-cost`: the hardcoded price table in
`scripts/logbook` had drifted three full repricings out of date, so Opus
sessions reported ~3x the actual cost.

- **Spec edits applied (SPEC.md)**
  - `[COST-2]` reworded: pricing source is now the vendored LiteLLM table
    (`scripts/model_prices.json`), not Anthropic's prose docs.
  - `[COST-3]` default model: `opus-4.7` → `claude-opus-4-7` (matches the
    Anthropic / LiteLLM id form that appears in transcripts).
  - `[COST-4]` recognized ids: `claude-opus-4-7`, `claude-opus-4-6`,
    `claude-sonnet-4-6`, `claude-haiku-4-5` (short forms still accepted via
    COST-6).
  - `[COST-6]` reworded around the dotted-vs-dashed normalization, matching
    the resolver's actual logic.
  - `[COST-7]` added — `just refresh-prices` re-downloads the LiteLLM file
    and writes the Anthropic-direct subset.

- **Coverage delta**
  - 73 → 74 normative requirements (+1 for `[COST-7]`).

### 2026-05-23 — note skill polish for v0.5.0 release

Triggered by a release-prep pass on the `note` skill ahead of v0.5.0.

- **Spec edits applied (SPEC.md)**
  - `[NOTE-3]`, `[NOTE-4]`, `[NOTE-5]` rename: modes `act`/`defer`/`log` → `now`/`parallel`/`log` (clearer about *when* each mode acts).
  - `[NOTE-6]` split into four requirements:
    - `[NOTE-6]` (narrowed) — log mode shall not modify the target and shall not spawn any session.
    - `[NOTE-7]` (new) — log mode shall write the body to a unique tempfile and print the path.
    - `[NOTE-8]` (new) — log mode shall best-effort copy the body to the system clipboard and report success.
    - `[NOTE-9]` (new) — log mode shall print a pre-filled "create issue" URL when the cwd is a git repo on a recognized forge (`github.com`, `gitlab.*`).

- **Coverage delta**
  - 70 → 73 normative requirements (+3 for the NOTE-6 split).
  - All sampled prior requirements remain covered. The release pass touched only NOTE and prose, no implementation surface.

- **Decoupling pass**
  - Stripped lingering `ai-sdlc` / personal-repo references from `skills/note/SKILL.md`, `docs/README.md`, `hooks/cli-freshness.sh`, and `CHANGELOG.md` so the plugin reads as a standalone artifact rather than a slice of a private workflow.

### 2026-05-17 — `note` skill spec'd, INST-4 relaxed

Triggered by adding the `/logbook:note` skill (commit `9c5b38d`). The skill ships behavior the spec didn't describe and doesn't route through the `logbook` CLI — both issues addressed in this pass.

- **Spec edits applied (SPEC.md)**
  - `[INST-4]` relaxed: previous wording required "each skill shall defer **all** deterministic operations to the CLI." Reworded to defer deterministic operations *rather than reimplementing them*, and to explicitly permit skills that are purely conversational orchestrators with no deterministic operations. `note` is the first such skill.
  - New `NOTE` category added with `[NOTE-1]`..`[NOTE-6]` covering: skill location and purpose, target identification with disambiguation, the three-mode contract (`act`/`defer`/`log`) with default proposal and confirmation, and per-mode behavior (`act` sweeps comparable sites; `defer` uses iTerm2 via `osascript` or prints the fallback command; `log` modifies nothing and emits only).
  - Prefix table updated to list `NOTE`.

- **Coverage delta**
  - 64 → 70 normative requirements.
  - All sampled prior requirements (CFG-7, CFG-11, CLI-10, SES-4/5/11, PUB-5..10, INST-12, COST-3/4) remain covered. The only commit since the previous audit was additive.

### 2026-05-08 — First post-bootstrap audit

Coverage was 56/60 (93%) before this session's edits. All four non-Covered
items were spec/wording issues, not implementation gaps:

- **Spec edits applied (SPEC.md)**
  - `[INST-3]` corrected: `/logbook <args>` → `/logbook:logbook <args>` (the
    actual plugin-namespaced slash-command form).
  - `[INST-4]` broadened to "one or more skills under `skills/`" and now
    enumerates both `retro/` and `session-id/`.
  - `[SES-2]` added `name` to the enumerated session-JSON keys.
  - `[SES-8]` added `compaction` and `git_activity` as optional `detailed`
    sub-blocks (these have shipped since 0.3.x but were undocumented).
  - `[CLI-10]` added — covers `--version` / `-v` (shipped in 0.3.0).
  - `[INST-11]` added — covers `install-cli [--dir]` semantics.
  - `[INST-12]` added — covers the headline 0.4.0 `SessionStart`
    cli-freshness hook.
  - `[SES-12]` added — declares Copilot/Cursor detection as macOS-only.

- **Workflow fix**
  - Deleted the working-tree copy of `docs/SPEC.md`. It was already
    `.gitignore`d, the GitHub Pages workflow runs `cp SPEC.md docs/SPEC.md`
    on every deploy, and `just docs` regenerates it locally — so the live
    site has always been correct. The local stale copy was a hazard for
    manual readers and audit subagents only.

- **Backlog (advisory; not addressed this pass)**
  - EARS conformance polish for definitional / static-property requirements
    (CFG-4, CFG-5, RETRO-4, RETRO-5, RETRO-6, INST-1, INST-10). These read
    fine but don't decompose cleanly into single testable assertions; defer
    to a v0.2 pass.
  - Open Question: `logbook retro stage <category> <slug>` subcommand to
    replace the skill's direct `mkdir -p`. Deferred per SPEC.md "Open
    Questions" — the skill's `mkdir` is acknowledged.
  - Open Question: `logbook add-team --default` for changing `default_team`
    after first registration. Deferred.
  - Open Question: `logbook doctor`. Deferred.
