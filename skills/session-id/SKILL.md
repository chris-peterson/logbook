---
name: session-id
description: Print only the active session's id — fast path for when you just need the id.
---

# `/logbook:session-id`

Defers to the [logbook](https://github.com/chris-peterson/logbook) plugin. Run:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/logbook" session-id
```

Print the resulting id to the user. No transcript parsing, no git timeline, no overlap detection — use `/logbook:logbook session` (or `logbook session`) when you need the full JSON block.
