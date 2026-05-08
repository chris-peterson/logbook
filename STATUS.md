# logbook — Spec Coverage Status

Tracking status of the requirements declared in [SPEC.md](SPEC.md). Updated
after each `/spec-audit`, when implementation lands, or when the spec is
revised.

**Last audit:** 2026-05-08
**Spec version:** v0.1
**Coverage:** 64 / 64 normative requirements (100%) + 7 deferred

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

## Audit history

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
