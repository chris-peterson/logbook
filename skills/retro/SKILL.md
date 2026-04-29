---
name: retro
description: Generate a retrospective document from the current AI coding session and publish it to the team retro repo. Triggers on 'retro', 'retrospective', 'capture this session'.
argument-hint: "[category]"
---

# `/logbook:retro`

Generate a retrospective for the current session and publish it to the team retro repo configured via `/logbook add-team`.

The skill orchestrates user-facing decisions; deterministic operations defer to the `logbook` CLI. Run any CLI invocation as:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/logbook" <subcommand> [args]
```

## Step 0: Identify the session

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/logbook" session
```

Returns JSON: `id`, `name`, `slug`, `tool`, `model`, `start`, `end`, `tokens`, `transcript`, plus a `detailed` block with tool usage, files touched, timeline, user messages, overlapping sessions, git activity, initial context tokens, compaction events.

## Step 1: Read the metrics

Note tool usage, files touched, git activity, token usage, and any **overlapping sessions**. If overlap exists, ask the user whether any were intentionally concurrent and should be reflected in the retro.

For Claude Code, token usage is exact. For Cursor, token estimates are unreliable — they only capture visible message text and miss cache reads (which dominate actual usage by 50-100x). Note source and reliability when including token data.

### Cost estimation

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/logbook" retro estimate-cost \
  <input_tokens> <output_tokens> <cache_create> <cache_read> --model <model>
```

The CLI knows pricing for `opus-4.7`, `opus-4.6`, `sonnet-4.6`, `haiku-4.5`. Output format: `~$X.XX`.

## Step 2: Gather context

Show what was auto-detected and propose defaults:

- **Category**: Suggest one based on session activity. Use `$ARGUMENTS` if provided.
- **Slug**: Default to `slug` from `logbook session` output. This is the directory name for the retro.
- **Date / tool / model**: Today and the tool/model from `logbook session`.
- **Session ID**: Auto-filled from the session output — do not ask.
- **Device ID**: Auto-filled from `logbook device-id` — do not ask.

Then ask the user to confirm or correct the defaults, and provide what can't be inferred:

- **Deliverable links**: PRs, MRs, repos, or other artifacts
- **Brief description**: What was the task? What was the outcome?
- **The prompt used** (if applicable): the working prompt that produced results
- **What worked well** + **why** (not just "it worked")
- **What didn't work**: specific things that went wrong or required iteration
- **Observations**: generalizable lessons and actionable takeaways

## Step 3: Get the device id

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/logbook" device-id
```

Generates and persists `~/.logbook/device-id` on first run. Subsequent runs return the same id.

## Step 4: Read the template

```bash
TEMPLATE=$(python3 "${CLAUDE_PLUGIN_ROOT}/scripts/logbook" retro template-path)
cat "$TEMPLATE"
```

Use the template for structure and quality standards.

## Step 5: Stage the retro locally

```bash
mkdir -p /tmp/logbook-staging/<slug>
```

Write `index.md` with frontmatter:

```yaml
---
date: YYYY-MM-DD
category: <category>
slug: <slug>
session_id: <session uuid>
device_id: <device id>
cost: "~$X.XX"
tool: <tool>
model: <model>
initial_context: <token count>
---
```

Body follows the template. The published artifact is `index.md` only — do not stage anything else.

## Step 6: Publish

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/logbook" retro publish <category> <slug> /tmp/logbook-staging/<slug>
```

This:
1. Reads the team's clone path from `~/.logbook/config.yaml`.
2. Pulls latest from the remote (rebase).
3. Copies the staging contents to `<clone>/retros/<category>/<slug>/`.
4. Commits with message `retro: <category>/<slug>` and pushes.

If multiple teams are registered, pass `--team <name>` to override the default.

On rebase conflict or push failure, the CLI bails loudly and leaves the team clone in place for manual resolution.

## Step 7: Confirm

Print the published path and the remote URL where the retro now lives.
