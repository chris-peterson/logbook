# Retro Template

Include all sections that have something substantive to say. Skip sections that would be empty or forced.

```markdown
---
date: YYYY-MM-DD
category: [category name — e.g., debugging, new-feature, cutover]
slug: [directory name for this retro]
session_id: [session UUID from /logbook:session]
device_id: [12-char device id from ~/.logbook/device-id]
cost: "~$X.XX"
tool: [tool — e.g., Claude Code, Cursor]
model: [model — e.g., Claude Opus 4.7]
initial_context: [token count — e.g., 23669]
---

# [Category]: [Short Title]

| | |
| --- | --- |
| **Date** | [date] |
| **Tool** | [tool] |
| **Model** | [model] |
| **Session ID** | [session UUID] |
| **Artifacts** | [linked deliverables — PRs, MRs, repos] |
| **Participants** | [who did what — e.g., "Author (direction), Claude Code (implementation)"] |
| **Cost** | [estimated from token data — e.g., "~$1.61"] |

---

## Summary
[2-3 sentences: what was done, how AI helped, outcome]

### The Result
| Aspect | Details |
|--------|---------|
| Problem | [what needed solving] |
| Approach | [how AI was used] |
| Stakes | [risk level, blast radius] |
| Timeline | [from session metrics — e.g., "3h 30m"] |
| Tokens | [from session metrics — exact for Claude Code, estimated for Cursor] |
| Initial context | [from `detailed.initial_context_tokens` — e.g., "23,669 tokens"] |
| Compactions | [from `detailed.compaction` — e.g., "3 (lines 342, 761, 1101 of 1183)"; omit row if 0] |
| Median turn | [median wall-clock between user message and next assistant text — e.g., "42s"] |
| Slow turns | [count of turns >60s with the longest — e.g., "7 (longest 4m 12s)"; omit row if 0] |
| Slowest tool | [single longest tool call — e.g., "Agent (Explore) 3m 48s"; omit row if all tools <30s] |

<details>
<summary>Cost Breakdown (~$X.XX)</summary>

| Component | Tokens | Cost | % of Total |
|-----------|--------|------|------------|
| Cache read | [count] | [cost] | [%] |
| Cache create | [count] | [cost] | [%] |
| Output | [count] | [cost] | [%] |
| Input | [count] | [cost] | [%] |
| **Total** | **[count]** | **[cost]** | |

[1-2 sentences explaining the primary cost driver — e.g., exploration agents, long session with repeated context, large codebase in context.]

</details>

<details>
<summary>Token Usage by Task</summary>

[Mermaid hand-drawn pie chart showing token consumption by logical task/phase. Group by what the user was doing, not by tool type. Title: "Token Usage by Task (N total)". Values in K tokens.]

**What was expensive?** [1-2 sentences on which tasks consumed disproportionate tokens and why.]

**What was cheap?** [1-2 sentences on what delivered good value relative to token cost.]

</details>

<details>
<summary>Tool Usage</summary>

| Tool | Count | % |
|------|------:|--:|
| [tool name] | [count] | [%] |
| ... | ... | ... |
| **Total** | **[count]** | |

[1-2 sentences on the tool usage pattern.]

</details>

<details>
<summary>Responsiveness</summary>

**Turn latency** — wall-clock between each user message and the start of the next assistant text response.

| Stat | Value |
|------|------:|
| Turns | [count of user→assistant turns] |
| Median | [e.g., "42s"] |
| p95 | [e.g., "3m 10s"] |
| Max | [e.g., "8m 34s"] |
| Turns >60s | [count] |
| Turns >5m | [count] |

**Slowest tool calls** — top 3-5 individual tool invocations by duration.

| Duration | Tool | Detail |
|---------:|------|--------|
| [e.g., 4m 12s] | [Agent / Bash / WebFetch / etc.] | [description, command, or url snippet] |

**Cache pressure** — long idle gaps (>5 min) between turns cause cache misses; the next turn pays full cache-create cost on the entire context.

| Idle gap | Position | Likely cause |
|---------:|----------|--------------|
| [e.g., 12m] | [turn 7→8] | [user stepped away / cross-session interruption / unknown] |

[2-3 sentences on what dominated wait time.]

</details>

### Timeline
[5-10 key events showing how the session progressed. Reconstruct from transcript — focus on turning points, not every message. Include cumulative token count at each event.]

| Time | Cumulative Tokens | Event |
|------|------------------:|-------|
| 0:00 | 0 | [Session start — initial prompt / goal] |
| 0:15 | ~[N]K | [First milestone] |
| 0:45 | ~[N]K | [First error / course correction] |
| ... | ... | ... |
| 3:30 | ~[N]K | [Session end — final state] |

---

## Context
[Technical context, constraints, domain details relevant to understanding this work]

---

## The Prompt
[If applicable — the working prompt that kicked off the session, followed by analysis of what made it effective]

## Synthesized Prompt
[Write 1-2 paragraphs representing the prompt you WISH you had used from the start, incorporating lessons learned. This is the "if I could do it again" prompt — front-load constraints, terminology, and architectural decisions that were discovered through iteration. Include guardrails that would have avoided the errors/rework encountered.]

---

## What Worked Well
### 1. [Named pattern]
[Substantive: not just WHAT worked, but WHY it worked]

---

## What Didn't Work
[If applicable — what went wrong, how it was resolved or worked around]

---

## Observations
[Both generalizable insights AND specific actionable takeaways. Each observation should teach something applicable beyond this specific case.]

1. **[Bold observation]** — [What it means and how to apply it in future work]

---

## Applicability
[Where this approach works best. Where it doesn't.]
```

## Quality Standards

- **Observations are actionable and generalizable**: "Point AI at existing codebase patterns" not "Existing patterns were helpful". Each should teach something applicable to future work.
- **Initial context is tracked**: Record the starting context token count from session metrics. This metric helps assess how much overhead CLAUDE.md, rules, and hooks impose before work begins.
- **Synthesized Prompt is mandatory**: Even a 3-line prompt is useful. This is the most reusable artifact of the retro.
- **Timeline uses session metrics**: Don't guess at duration when there's real data.
- **Timeline includes cumulative tokens**: Each timeline row should show cumulative token count, extracted from the transcript.
- **Timeline shows the narrative arc**: 5-10 key events — start, milestones, errors/corrections, turning points, end. Use relative timestamps (0:00, 0:15) when exact times aren't available.
- **Token Usage by Task is task-oriented**: Group by logical task (diagnosis, implementation, code review), not by tool type. The question is "what was I doing?" not "what tools were used?"
- **Responsiveness is tracked**: Compute turn latency, slowest tool calls, and idle gaps directly from transcript timestamps. Name the specific tools, agents, or gaps responsible for wait time.
- **Cost details are collapsible**: Total cost in the metadata header; detailed breakdown in a `<details>` block.
- **Skip empty sections**: Don't include "What Didn't Work" if it all went smoothly.
