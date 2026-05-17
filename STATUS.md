# logbook — Spec Coverage Status

Tracking status of the requirements declared in [SPEC.md](SPEC.md). Updated
after each `/spec-audit`, when implementation lands, or when the spec is
revised.

**Last audit:** 2026-05-17
**Spec version:** v0.1
**Coverage:** 70 / 70 normative requirements (100%) + 7 deferred

## Status by category

| Prefix | Count | Status | Notes |
|--------|------:|--------|-------|
| CFG | 11 | All Covered | `scripts/logbook` config + state |
| CLI | 10 | All Covered | `scripts/logbook` argv dispatch |
| SES | 12 | All Covered | `scripts/logbook` session detection |
| RETRO | 6 | All Covered | `templates/retro.md` |
| PUB | 11 | All Covered | `scripts/logbook` retro publish path |
| PRIV | 4 | All Covered | Core contract |
| INST | 12 | All Covered | `commands/logbook.md`, `skills/`, `hooks/` |
| COMP | 6 | All Covered | `scripts/logbook` completions + `install-cli` |
| COST | 6 | All Covered | `scripts/logbook` retro estimate-cost |
| NOTE | 6 | All Covered | `skills/note/SKILL.md` |

## Audit history

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
