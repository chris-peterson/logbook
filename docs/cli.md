# CLI reference

```text
logbook session                                       print session info as JSON
logbook session-id                                    print only the active session's id (fast)
logbook note add <text> [--disposition --kind --target]   append a note to the session's log
logbook note list [--session <id>] [--json]           list the session's notes
logbook add-team <git-url> [--as <name>]              register a team retro repo
logbook device-id                                     print/persist per-workstation id
logbook config                                        print resolved config
logbook retro publish <category> <slug> <dir> [--team <t>]
logbook retro template-path                           absolute path to retro template
logbook retro estimate-cost <i> <o> <cc> <cr> [--model claude-opus-5|claude-sonnet-5|...]
logbook install-cli [--dir <path>]                    install 'logbook' wrapper on PATH + zsh completions
logbook completions zsh [--print]                     install/print zsh completions
```

## Configuration

`~/.logbook/config.yaml` is created by `logbook add-team`:

```yaml
default_team: teamX
teams:
  teamX:
    remote: git@github.com:teamX/retros.git
```

Override the location with `LOGBOOK_HOME`:

```bash
export LOGBOOK_HOME=/some/other/path
```

## Multiple teams on one workstation

```text
/logbook:logbook add-team git@github.com:teamY/retros.git --as teamY
```

Override the default at retro time by passing `--team teamY` to the publish call.

## Layout in the team repo

```text
retros/
├── debugging/
│   └── pwsh-gitlab-get-changerequest-bug/
│       └── index.md
├── new-feature/
│   └── apps-pages-mcp-server/
│       └── index.md
└── ...
```

Categories are chosen by the team — they live as directory names, with no enforced list.
