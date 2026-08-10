# logbook

A Claude Code plugin and standalone CLI that turns an AI coding session into a
retrospective committed to a team-owned git repository. What the commands do for
a *user* lives on the docs site (https://chris-peterson.github.io/logbook); this
file is for working on the plugin itself.

`SPEC.md` is the requirement source of record and `STATUS.md` is its coverage
ledger. A change to behavior updates the requirement and the ledger in the same
commit, not as a follow-up.

## The core contract

**A retrospective published to a team retro repo contains no session
transcript.** What crosses the boundary is the author's own markdown plus opaque
`session_id` / `device_id` values they can correlate locally. Transcripts, the
durable notes log, and its harvested archive are per-workstation state under
`$LOGBOOK_HOME` and never become artifacts.

This is the one invariant worth stopping over. A change that widens what
`retro publish` reads, or that quotes session content into a generated artifact
rather than into prose the author wrote, breaks it — check the PRIV requirements
before adding either.

## Commands

```bash
just test        # python3 -m unittest discover -s tests
just check       # validate source and preview the pending projection (no write)
just generate    # regenerate plugin.json and docs/ from plugin.yml and the sources
just docs        # serve the docsify site locally

python3 scripts/logbook --help    # run the CLI from source, no install needed
just refresh-prices               # refresh scripts/model_prices.json for cost estimation
```

## Layout

```text
plugin.yml               canonical descriptor — manifest, marketplace entry, docs copy
scripts/logbook          the CLI — one Python file, stdlib plus PyYAML
scripts/model_prices.json  per-model rates for `retro estimate-cost`, refreshed by scripts/refresh-prices
commands/logbook.md      the slash command that maps to the CLI
skills/retro/            conversational retro authoring
skills/note/             mid-session observation capture
skills/session-id/       the fast path for just the session id
hooks/                   CLI freshness and orphan-note reminders
templates/retro.md       the retro shape — frontmatter plus section scaffolding
tests/                   unittest suites
SPEC.md / STATUS.md      requirements and their coverage
docs/                    docsify site (index.html, _sidebar.md, favicon are source)
```

`.claude-plugin/plugin.json`, `plugin.yml`'s `suite.describe` block, and most of
`docs/` are **generated** by `shipyard` from the sources above. Never hand-edit a
generated file; edit its source and run `just generate`.

## Conventions

- **`scripts/logbook` is one Python file: standard library plus PyYAML.** No
  other third-party imports, no virtualenv. A missing PyYAML is reported with an
  actionable message before any config read, rather than surfacing as a traceback
  from somewhere deep in the run.
- **The CLI runs from source.** `python3 scripts/logbook <args>` has to work in a
  fresh checkout with nothing installed — it's how the plugin invokes it and how
  anyone reproduces a bug.
- **State lives under `$LOGBOOK_HOME`** (default `~/.logbook/`), never in the
  project tree. Config, the device id, the notes log, and team clones all resolve
  through it so a test can point the whole surface somewhere else.
- **The plugin version has one source**: `.claude-plugin/plugin.json`, projected
  from `plugin.yml`. `--version` reads it rather than carrying its own copy.
- **Tests are stdlib `unittest`, no pytest.** They load the CLI by path rather
  than importing a package, so they run against the same single file the plugin
  runs.
- **Adding or renaming a subcommand touches three places** — the argparse parser,
  the hand-maintained `ZSH_COMPLETION` block, and the SPEC's `CLI` requirements.
  The first two sit ~1300 lines apart in one file and drift silently, which is
  why `tests/test_cli_completion_drift.py` compares them.

## Glossary

- **Team retro repo** — the git repository a team owns and publishes retros to,
  registered by `add-team` and cloned under `<LOGBOOK_HOME>/repos/<team>/`.
- **Device id** — a per-workstation identifier derived from hostname and MAC,
  persisted at `<LOGBOOK_HOME>/device-id`. Rotation is deletion: the next request
  regenerates it.
- **Note** — a mid-session observation captured as it happens, held in the
  durable per-workstation log until a retro consumes it.
- **Harvest** — marking a session's notes consumed by a retro, which moves them to
  the archive.
- **Orphan notes** — a session with deferred notes and no retro yet; a hook
  surfaces them so they aren't lost.
