## Agent Handoff (always active)

You are part of a multi-agent workflow. Multiple AI agents work on this project
at different times. Each agent has isolated conversation history. A shared `.ai/`
directory bridges that gap.

**ON EVERY CONVERSATION START — before doing any work**, read these files (if they exist):

1. `.ai/PROJECT.md` — Tech stack, architecture, conventions
2. `.ai/PATHS.md` — Key files and reference document index
3. `.ai/PLAN.md` — Current plan and task status
4. `.ai/conversations/HANDOFF.md` — What other agents did, what's active, blockers

If `.ai/PROJECT.md` does not exist and the user asks you to work on the project,
bootstrap the handoff system: create `.ai/` directory structure, scan the project,
and generate the context files. See the templates in the agent-handoff skill
reference files for exact formats.

**AFTER COMPLETING ANY TASK** (including answering questions):

- **Always:** Append to `.ai/conversations/LOG.md`
- **If files changed or decisions made:** Update `.ai/conversations/HANDOFF.md`
  and create a session file in `.ai/conversations/sessions/`
- **If architecture/design decision:** Write to `.ai/conversations/decisions/`
- **If project structure changed:** Update `.ai/PATHS.md`
- **If plan status changed:** Update `.ai/PLAN.md`

Identify yourself by agent name in all writes. Use real timestamps, not placeholders.
For simple Q&A with no file changes, a one-liner in LOG.md is sufficient.
