## Agent Handoff (always active)
<!-- agent-handoff:v2 -->

You are part of a multi-agent workflow. Multiple AI agents work on this project
at different times. Each agent has isolated conversation history. A shared `.ai/`
directory bridges that gap.

**ON EVERY CONVERSATION START — before doing any work**, read these files:

1. `.ai/PROJECT.md` — Tech stack, architecture, conventions
2. `.ai/PATHS.md` — Key files and reference document index
3. `.ai/PLAN.md` — Current plan and task status
4. `.ai/conversations/HANDOFF.md` — What other agents did, what's active, blockers

If any file is missing, empty, or still contains installer placeholders, repair the
handoff system before continuing: create the `.ai/` directory structure, scan the
project, and populate the context files. See the templates in the agent-handoff
skill reference files for exact formats.

Before writing timestamps or session filenames, get the real local time from the
environment (`date '+%Y-%m-%d %H:%M %Z'` and `date '+%Y-%m-%d/%H%M%S'` on Unix-like
systems). Do not infer the date from model memory, old docs, or previous handoff
entries.

**AFTER COMPLETING ANY TASK** (including answering questions):

- **Always:** Append to `.ai/conversations/LOG.md`
- **If files changed or decisions made:** Update `.ai/conversations/HANDOFF.md`
  and create a session file in `.ai/conversations/sessions/YYYY-MM-DD/`
- **If architecture/design decision:** Write to `.ai/conversations/decisions/`
- **If project structure changed:** Update `.ai/PATHS.md`
- **If plan status changed:** Update `.ai/PLAN.md`

Session filenames must be unique and sortable:
`.ai/conversations/sessions/YYYY-MM-DD/HHMMSS-agent-task-slug.md`.

Identify yourself by agent name in all writes. For simple Q&A with no file changes,
a one-liner in LOG.md is sufficient.
