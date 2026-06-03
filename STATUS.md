# logbook — Spec Coverage Status

Tracking status of the requirements declared in [SPEC.md](SPEC.md). Updated
after each `/spec-audit`, when implementation lands, or when the spec is
revised.

**Last audit:** 2026-06-03
**Spec version:** v0.1
**Coverage:** 75 / 75 normative requirements (all Covered) + 7 deferred

## Status by category

| Prefix | Count | Status | Notes |
|--------|------:|--------|-------|
| CFG | 11 | All Covered | `scripts/logbook` config + state |
| CLI | 11 | All Covered | `scripts/logbook` argv dispatch; CLI-2 enumeration now includes `install-cli`; CLI-11 (`help` alias for `--help`) |
| SES | 12 | All Covered | `scripts/logbook` session detection; SES-5/SES-11 decomposed into lettered sub-requirements |
| RETRO | 6 | All Covered | `templates/retro.md` |
| PUB | 11 | All Covered | `scripts/logbook` retro publish path |
| PRIV | 4 | All Covered | Core contract |
| INST | 12 | All Covered | `commands/logbook.md`, `skills/`, `hooks/` |
| COMP | 6 | All Covered | `scripts/logbook` completions + `install-cli` |
| COST | 7 | All Covered | `scripts/logbook` retro estimate-cost; `scripts/model_prices.json` |
| NOTE | 9 | All Covered | `skills/note/SKILL.md` |

## Audit history

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
