# logbook

A log of important learnings, e.g. AI-assisted coding session retros.

A Claude Code plugin (and standalone CLI) that turns a coding session — Claude Code, Cursor, or GitHub Copilot — into a retrospective committed to a team-owned git repository. Transcripts stay on the author's workstation; only the retro is published.

📖 **End-user docs:** https://chris-peterson.github.io/logbook

Working on logbook — repo layout, the `just` targets, and the conventions this
codebase holds itself to — is in [AGENTS.md](./AGENTS.md), the same file the
agents read. Requirements are in [SPEC.md](./SPEC.md), their coverage in
[STATUS.md](./STATUS.md).

## Dev setup

```bash
python3 --version            # 3.10+
pip install pyyaml
```

## License

MIT
