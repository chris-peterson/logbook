#!/usr/bin/env bash
# DOCUMENTATION: Surface deferred notes still waiting on a retro.
# SessionEnd / SessionStart hook: surface deferred notes still waiting on a retro.
#
# A note captured with the `deferred` disposition is left for `/logbook:retro`
# to consume. If the session ends before a retro runs, the note is stranded.
# This hook closes that gap from both ends:
#
#   SessionEnd   — if the closing session has un-harvested deferred notes,
#                  emit a `systemMessage` reminder. Display-only; SessionEnd
#                  does not fire on a crash or hard kill, so SessionStart is
#                  the real backstop.
#   SessionStart — scan every session for orphans (deferred notes, not the
#                  current session, not live, idle past the grace window, not
#                  harvested) and inject them as `additionalContext` so the new
#                  session opens knowing which prior sessions still need a retro.
#
# Both branches read the orphan/notes data from the CLI so the predicate lives
# in one place.

set -euo pipefail

LOGBOOK="${CLAUDE_PLUGIN_ROOT:-}/scripts/logbook"
[ -f "$LOGBOOK" ] || exit 0

INPUT=$(cat)

EVENT=$(printf '%s' "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('hook_event_name',''))" 2>/dev/null) || exit 0
SESSION_ID=$(printf '%s' "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null) || exit 0

case "$EVENT" in
  SessionEnd)
    [ -n "$SESSION_ID" ] || exit 0
    NOTES_JSON=$(python3 "$LOGBOOK" note list --session "$SESSION_ID" --json 2>/dev/null) || exit 0
    NOTES_JSON="$NOTES_JSON" python3 <<'PY'
import json, os
notes = json.loads(os.environ["NOTES_JSON"])
count = sum(1 for n in notes if n.get("disposition") == "deferred")
if count:
    noun = "note" if count == 1 else "notes"
    msg = (f"This session has {count} {noun} parked for a retro. "
           f"Run /logbook:retro to harvest them, or they will surface as an "
           f"orphan reminder at your next session start.")
    print(json.dumps({"systemMessage": msg}, separators=(",", ":")))
PY
    ;;
  SessionStart)
    ORPHANS_JSON=$(python3 "$LOGBOOK" note orphans --json --current "$SESSION_ID" 2>/dev/null) || exit 0
    ORPHANS_JSON="$ORPHANS_JSON" python3 <<'PY'
import json, os
orphans = json.loads(os.environ["ORPHANS_JSON"])
if orphans:
    lines = []
    for o in orphans:
        mins = o["idle_seconds"] // 60
        noun = "note" if o["deferred_count"] == 1 else "notes"
        lines.append(f"  - session {o['session_id']}: {o['deferred_count']} deferred {noun}, idle {mins}m")
    body = "\n".join(lines)
    msg = (
        "Prior sessions have deferred notes still waiting on a retro:\n"
        f"{body}\n"
        "To harvest one, run /logbook:retro against it (which calls "
        "`logbook note harvest <session-id>`)."
    )
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": msg,
        }
    }, separators=(",", ":")))
PY
    ;;
esac
