# Skills

A skill is a Claude Code surface that gathers context conversationally. Invoke one by typing its slash command — `/logbook:<name>` — with or without arguments.

| Skill | Use when… |
|---|---|
| [`/logbook:retro`](/skills/retro) | You want to capture an AI coding session as a retrospective in the team repo. |
| [`/logbook:note`](/skills/note) | Mid-session, you notice something not working well, and want the choice to fix it now, do it in parallel (fresh session), or just log it. |
| [`/logbook:session-id`](/skills/session-id) | You need only the active session's id — for scripting, log correlation, or feeding into another tool. |

Each per-skill page is generated from that skill's `SKILL.md` at build time — the operational instructions Claude follows when you invoke it. No parallel docs to maintain; what you see on the page is what Claude reads.
