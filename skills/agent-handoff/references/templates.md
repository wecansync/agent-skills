# Agent Handoff — File Templates

Reference templates for all `.ai/` files. Used during bootstrapping and as a
format guide for ongoing writes.

---

## PROJECT.md

Stable project-level context. Updated rarely.

```markdown
# Project: {name}

## Overview
{One paragraph: what the project does, who it serves, domain context}

## Tech Stack
- **Language:** {e.g., PHP 8.3, Python 3.12, TypeScript 5.x}
- **Framework:** {e.g., Laravel 12, Next.js 15, Django 5.1}
- **Database:** {e.g., MySQL 8.x, PostgreSQL 16, MongoDB 7}
- **Frontend:** {e.g., Livewire 3, React 19, Vue 3}
- **Key packages:** {list with purpose — only include packages that affect architecture}

## Architecture
{2-3 sentences: monolith vs microservice, API structure, deployment model}

## Key Documents
These are the most important reference documents. Read before making architectural
decisions or starting new features.

| Document | Path | Purpose |
|----------|------|---------|
| {name} | `{path}` | {one-line purpose} |

If the project has no formal documentation beyond README, this section can list
just the README and any inline architecture notes.

## Conventions
- {Convention 1}
- {Convention 2}

## How to Run
- Dev server: {command}
- Tests: {command}
- Build: {command}

## How to Deploy
{Brief deployment process, or "See CI/CD pipeline" if automated}
```

---

## PATHS.md

Filesystem map and reference document index. Primary lookup for "where is X?"
Updated when project structure changes or new important documents are created.

```markdown
# Key Paths

## Application Code
- `{src dir}/` — {description}
- `{models dir}/` — {description}
{...framework-specific directories}

## Configuration
- `.env.example` — Environment template
- `{config dir}/` — Configuration files
{...}

## Tests
- `{test dir}/` — {test framework} tests

## Reference Documents (current)
High-value documents that agents should know about. Organized by category.

### {Category 1, e.g., Requirements / Design / Architecture}
- `{path}` — {one-line description}

### {Category 2, e.g., Guides / Operations}
- `{path}` — {one-line description}

### {Category 3, e.g., API Documentation}
- `{path}` — {one-line description}

### Agent & Project Config
- `{CLAUDE.md, .cursorrules, codex.md, etc.}` — {purpose}
- `README.md` — Project readme

## Feature Specs / Plans
{Describe the project's planning system — could be specs/, rfcs/, adrs/, GitHub
Issues, Linear tickets, or "no formal system detected."}

{If a directory-based system exists, document the pattern:}
### Structure per feature
Each `{pattern}/` contains:
- `{file1}` — {purpose}
- `{file2}` — {purpose}
{...detected pattern}

### Active / Recent
- `{path}` — {status}: {description}

## Archived Documents
{Older versions — reference only, NOT authoritative.}
- `{path}` — (superseded by {current version})

## Agent Handoff
- `.ai/` — Cross-agent conversation bridge (this system)
- `.ai/conversations/HANDOFF.md` — Agent activity and current state
- `.ai/conversations/LOG.md` — Full activity history
```

---

## PLAN.md

Current implementation plan. Updated after each task that progresses the plan.

```markdown
# Current Plan

## Active Work
**{Feature/task name}** — {one-line description}
- Spec/Issue: `{path or URL}`
- Plan: `{path, if exists}`

## Task Status
| Task | Status | Agent | Date |
|------|--------|-------|------|
| {task 1} | done | {agent} | {date} |
| {task 2} | in-progress | {agent} | {date} |
| {task 3} | pending | — | — |

## Blockers
- {blocker, or "None"}

## Key Decisions
- {decision} → see `decisions/{file}`
```

For projects without a formal spec system, PLAN.md can track work from any source:
GitHub Issues, Jira tickets, user instructions, or even "the user asked me to..."

---

## HANDOFF.md

Rolling window of agent activity. **Max 15-20 entries in Recent Completions.**

```markdown
# Agent Handoff
Last updated: {YYYY-MM-DD HH:MM} by {agent-name}

## Active Work
- {What's being worked on}
  - Last session: [sessions/{filename}]
  - Status: {where it stands}
  - Blocker: {if any, or "None"}

## Recent Completions
- [{YYYY-MM-DD} {agent}] {what was done} #{tag}
{... max 15-20 entries, then oldest roll off to LOG.md}

## Pending Decisions
- {Decision needed} → context in {file reference}

## Key Context
- {Important runtime context: feature flags, env quirks, gotchas}
```

On the very first write (no prior agent activity), set Active Work to whatever
the current task is and leave Recent Completions empty.

---

## LOG.md (append-only)

Permanent chronological record. Each entry is 3-5 lines.

**Tags:** `#question` `#bugfix` `#feature` `#refactor` `#spec` `#plan`
`#review` `#decision` `#migration` `#config` `#test` `#docs` `#deploy` `#setup`

Full entry format:
```markdown
---
## {YYYY-MM-DD HH:MM} — {agent-name} #{tag}
**Task:** {what was requested}
**Outcome:** {what was done}
**Files:** {files changed, or "None"}
**Next:** {what should happen next, or "N/A"}
---
```

Compact format for simple Q&A:
```markdown
---
## {YYYY-MM-DD HH:MM} — {agent-name} #question
{question} → {brief answer}
---
```

**Archival:** When LOG.md exceeds ~500 lines, move entries older than 90 days
to `LOG-archive-YYYY.md` in the same directory. Keep the last 90 days in LOG.md.

---

## Session file: `sessions/YYYY-MM-DD/HHMMSS-agent-task-slug.md`

Detailed log for one session. Only read on-demand (resume or investigation).
Create the date directory first. Use real local system time, not model memory or
dates copied from previous handoff entries.

```markdown
---
agent: {agent-name}
started: {YYYY-MM-DD HH:MM TZ}
task: {one-line task description}
tags: [#{tag1}, #{tag2}]
---

## Summary
{2-3 sentences: what was done and why}

## Files Created/Modified
- `{path}` — {what changed}

## Decisions Made
- {decision + rationale}

## Issues/Blockers Found
- {issue, or "None"}

## What's Next
- {next steps for whoever picks this up}

## References
- {docs, specs, PRs, or URLs consulted during this session}
```

---

## Decision file: `decisions/YYYY-MM-DD-topic-slug.md`

One file per significant architectural or design decision.

```markdown
# Decision: {Title}
Date: {YYYY-MM-DD}
Agent: {agent-name}
Status: {accepted | superseded | revisit}

## Context
{Why this decision was needed}

## Decision
{What was decided}

## Rationale
{Why this option, not others}

## Alternatives Considered
- {option} — {why rejected}

## Consequences
- {impact on codebase or future work}
```
