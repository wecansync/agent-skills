---
name: agent-handoff
description: >
  Cross-agent conversation bridge. ALWAYS ACTIVE — triggers automatically on every
  conversation. Reads shared project context before working, writes structured summaries
  after completing any task (including answering questions). Enables seamless handoff
  between Claude, OpenCode, Codex, Gemini, Kilo, Antigravity, and any other AI agent
  working on the same project.
---

# Agent Handoff — Cross-Agent Conversation Bridge

You are participating in a multi-agent workflow. Multiple AI agents (Claude, OpenCode,
Codex, Gemini, Kilo, Antigravity, etc.) work on this project at different times. Each
agent has isolated conversation history. This skill bridges that gap using shared
project files that any agent can read and write.

## Trigger Rules

This skill has TWO mandatory trigger points:

### 1. BEFORE-WORK (on conversation start)

**When:** The FIRST message of every conversation, before doing any work.

**Action:** Read the context files in this order:

```
1. .ai/PROJECT.md              — Tech stack, architecture, conventions, key documents
2. .ai/PATHS.md                — Key files, directories, and reference documents
3. .ai/PLAN.md                 — Current implementation plan and status
4. .ai/conversations/HANDOFF.md — What other agents did, what's active, blockers
```

Read all four. They are designed to stay small (see Size Limits below).
Do NOT read additional reference documents at this stage — PATHS.md is an index
that tells you what exists. Read specific docs on-demand when the task requires them.

**If the user says "continue", "resume", "keep going", or similar:**
- Read HANDOFF.md to find the last active task and its session file pointer
- Read the referenced session file from `.ai/conversations/sessions/`
- Read any spec/plan files referenced in the session
- Then check the actual source files to verify current state before proceeding

**If the user asks to work on a specific feature or spec:**
- Check PATHS.md for the relevant spec/feature directory
- Read the spec, plan, and task files from that directory
- Read data-model or contract files if the task involves database or API work
- Cross-reference with PLAN.md to see what's already been done

**If `.ai/PROJECT.md` does not exist:** Run first-run bootstrapping (see below).

### 2. AFTER-WORK (when task is complete)

**When:** After completing ANY task, including answering a question.

**Action:** Write updates to the shared files. The scope depends on task complexity:

#### For simple Q&A (no file changes, no decisions):
- Append a **one-liner** to `.ai/conversations/LOG.md`
- Do NOT create a session file
- Do NOT update HANDOFF.md unless the answer revealed something important

#### For tasks with file changes or decisions:
- Append a structured entry to `.ai/conversations/LOG.md`
- Update `.ai/conversations/HANDOFF.md` (overwrite with rolling window)
- Create a session file in `.ai/conversations/sessions/`
- If an architecture/design decision was made, also write to `.ai/conversations/decisions/`
- If project structure changed, update `.ai/PATHS.md`
- If implementation plan status changed, update `.ai/PLAN.md`
- If new documentation was created or discovered, update the Reference Documents
  section of `.ai/PATHS.md`

---

## Size Limits

These limits keep startup reads cheap and prevent unbounded growth.

| File | Max Lines | Enforcement |
|------|-----------|-------------|
| PROJECT.md | ~80 | Stable — only update when tech stack or architecture changes |
| PATHS.md | ~150 | If exceeding, collapse less-important entries into directory-level summaries |
| PLAN.md | ~60 | Only track the active feature. Move completed features to a one-liner |
| HANDOFF.md | ~100 | Rolling window: max 15-20 entries in Recent Completions. Oldest roll off to LOG.md |
| LOG.md | ~500 | When exceeding 500 lines, archive entries older than 90 days to `LOG-archive-YYYY.md` |
| Session files | ~80 each | Keep summaries concise. Reference commit hashes instead of repeating diffs |

**Estimated startup read cost:** ~800-1500 tokens for all 4 files combined.
**Estimated per-task write cost:** ~500-1200 tokens depending on complexity.

---

## Directory Structure

```
.ai/
├── PROJECT.md                          ← Tech stack, architecture, key documents
├── PATHS.md                            ← Filesystem map and reference document index
├── PLAN.md                             ← Current implementation plan and task status
└── conversations/
    ├── HANDOFF.md                      ← Rolling window: active work, recent completions
    ├── LOG.md                          ← Append-only chronological changelog
    ├── decisions/                      ← One file per key decision
    │   └── YYYY-MM-DD-topic-slug.md
    └── sessions/                       ← Detailed session logs
        └── YYYY-MM-DD-HHMMSS-agent.md
```

---

## File Formats

### PROJECT.md

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

### PATHS.md

Filesystem map and reference document index. This is the primary lookup for
"where is X?" questions. Updated when project structure changes or new important
documents are created.

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

### PLAN.md

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

### HANDOFF.md

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

### LOG.md (append-only)

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

### Session file: `sessions/YYYY-MM-DD-HHMMSS-agent.md`

Detailed log for one session. Only read on-demand (resume or investigation).

```markdown
---
agent: {agent-name}
started: {YYYY-MM-DD HH:MM}
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

### Decision file: `decisions/YYYY-MM-DD-topic-slug.md`

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

---

## First-Run Bootstrapping

If `.ai/PROJECT.md` does not exist, this is a fresh installation.
Bootstrap before doing any other work.

### Step 1: Create directory structure

```bash
mkdir -p .ai/conversations/decisions .ai/conversations/sessions
```

### Step 2: Detect project type and tech stack

Read all package manifests that exist (a polyglot project may have several):
- `composer.json` → PHP (Laravel, Symfony, etc.)
- `package.json` → Node.js / frontend (Next.js, Nuxt, React, Vue, Angular, etc.)
- `Gemfile` → Ruby (Rails, Sinatra, etc.)
- `requirements.txt` / `pyproject.toml` / `Pipfile` → Python (Django, Flask, FastAPI, etc.)
- `go.mod` → Go
- `Cargo.toml` → Rust
- `pom.xml` / `build.gradle` → Java / Kotlin
- `*.csproj` / `*.sln` → .NET

Read all agent/convention configs that exist:
- `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.windsurfrules`, `codex.md`
- `README.md`, `CONTRIBUTING.md`
- `.editorconfig`, lint configs (`.prettierrc`, `eslint.config.*`, `phpcs.xml`, etc.)

Read environment hints:
- `.env.example` → expected environment variables
- `docker-compose.yml` / `Dockerfile` → containerized setup
- `Makefile` / `justfile` → common commands

### Step 3: Discover documentation

Scan for documentation files. Not all projects have a `docs/` folder — be thorough.

**Scan these locations:**

```
Root:
  *.md files (README, CHANGELOG, CONTRIBUTING, ARCHITECTURE, etc.)

Common doc directories (check all, use whichever exist):
  docs/  documentation/  wiki/  guides/  .github/

Spec/plan directories:
  specs/  spec/  plans/  rfcs/  adrs/  design/  proposals/

API documentation:
  docs/api/  api-docs/
  openapi.yaml  openapi.json  swagger.json  swagger.yaml
  *.postman_collection.json (search up to 3 levels deep)
  insomnia*.json  insomnia*.yaml

Nested documentation:
  docs/archive/  — older versions (mark as archived)
  docs/plans/    — future plans
  Any subdirectory of docs/ containing markdown files
```

**For each location found:** `find {dir} -maxdepth 3 -type f \( -name "*.md" -o -name "*.pdf" -o -name "*.postman_collection.json" -o -name "openapi.*" -o -name "swagger.*" \)`

**Classify documents by reading the title or first 10 lines:**

| Category | Examples | Priority |
|----------|----------|----------|
| Requirements | TRD, PRD, BRD, requirements doc | HIGH |
| Architecture | System design, architecture doc, ADR | HIGH |
| Implementation Plans | Roadmap, phasing doc, global plan | HIGH |
| Project Overview | Overview, project brief | HIGH |
| Operational Guides | User guides, admin guides, runbooks | MEDIUM |
| API Documentation | Integration guides, API refs, Postman/OpenAPI | MEDIUM |
| Feature Specs | Per-feature specs, RFCs, proposals | ON-DEMAND |
| Archived | Anything in archive/ or with version < current | LOW |
| Notes / Q&A | Meeting notes, Q&A, review notes | LOW |

**Version detection:** When multiple versions of a document exist (e.g., TRD-v3,
TRD-v4, TRD-v5), identify the current version by highest version number or most
recent modification date. List only the current version under "Reference Documents
(current)." Move older versions to "Archived Documents" with a supersession note.

### Step 4: Detect spec/plan directory patterns

If a specs/, rfcs/, adrs/, or similar directory exists:
1. List all subdirectories
2. Pick one representative subdirectory and list its contents
3. Document the detected pattern (what files each entry contains)
4. List all entries with a one-line description
5. Identify which appear active vs completed (check git history or task checkboxes)

If no formal spec system exists, note this in PATHS.md and explain how the project
tracks work (GitHub Issues, Jira, informal, etc.) if detectable.

### Step 5: Generate PROJECT.md, PATHS.md, PLAN.md

Using the templates above. Key points:
- PROJECT.md Key Documents table: list the 3-6 most important reference documents
- PATHS.md: include ALL discovered documentation, categorized
- PLAN.md: detect active work from git branch name, recent commits, or spec status

### Step 6: Create HANDOFF.md and LOG.md with headers only

HANDOFF.md:
```markdown
# Agent Handoff
Last updated: {now} by {agent-name}

## Active Work
No prior agent activity recorded.

## Recent Completions
(empty)

## Pending Decisions
None

## Key Context
- Agent handoff system initialized — first session
```

LOG.md:
```markdown
# Agent Activity Log
```

### Step 7: Report to the user

```
Agent handoff system initialized.

Discovered: {N} reference documents, {N} feature specs, {N} archived docs.
Key documents: {list top 3}
Active work detected: {feature/branch or "none detected"}
Gaps: {any missing elements like "no test directory found"}
```

---

## Documentation Maintenance

### When to update PATHS.md
- New documentation file created (spec, guide, API doc, ADR)
- Existing document renamed, moved, or significantly restructured
- Document moved to archive or superseded by a new version
- Agent discovers an important document not yet indexed

### When to update PROJECT.md Key Documents table
- A key document gets a new version (e.g., TRD v5 → v6)
- A new high-priority document is created that all agents should read
- A key document is retired

### Reading docs before implementation
When about to implement a feature:
1. Check PATHS.md for relevant spec/plan files
2. Read the spec and plan at minimum
3. If database work: read the data model or schema doc
4. If API work: read the relevant API contracts or OpenAPI spec
5. If the project has a requirements doc (TRD, PRD), check if the feature
   has requirements there — the requirements doc is authoritative when it
   conflicts with a feature spec
6. Record which documents were consulted in the session file References section

---

## Stale Detection

**HANDOFF.md stale (> 7 days since last update):**
1. Do NOT blindly trust the handoff state
2. Run `git log --oneline --since="7 days ago"` to check what changed
3. Cross-reference git history with HANDOFF.md
4. Update HANDOFF.md with current state before proceeding
5. Add a note: `[stale] Handoff was {N} days old. Refreshed from git history.`

**PATHS.md references a file that no longer exists:**
1. Remove the stale entry
2. Check if the file was renamed, moved, or superseded
3. Add the replacement if found
4. Log the cleanup in LOG.md

---

## Concurrent Agent Safety

When two agents work on the same project simultaneously (e.g., Claude in one
terminal, OpenCode in another), file conflicts can occur.

**Prevention:**
- HANDOFF.md Active Work section should list what each agent is working on.
  Before starting, check if another agent is currently active.
- Session files never conflict — each agent writes its own timestamped file.
- LOG.md is append-only — conflicts are simple to resolve (keep both entries).

**If a merge conflict occurs in HANDOFF.md:**
1. Keep both agents' Active Work entries
2. Merge Recent Completions chronologically
3. Union all Key Context entries
4. The agent that resolves the conflict adds a LOG.md entry noting it

**If a merge conflict occurs in PLAN.md:**
1. Keep the more recent task status for each task
2. If both agents updated the same task, prefer the one marked "done" or
   "in-progress" over "pending"

---

## Monorepo Projects

For monorepos with multiple packages/services:
- Place `.ai/` at the **repository root**, not inside individual packages
- PATHS.md should list all packages/services with their paths
- PLAN.md can track work across packages — use package prefixes in task names
- Session files should note which package(s) were modified

---

## Integration with Non-Claude Agents

This skill uses the `.agents/skills/` universal format. For agents that don't
auto-discover skills, add a pointer in their configuration:

**OpenCode:** Add to `.opencode/config.json` or project instructions:
"Read `.ai/PROJECT.md`, `.ai/PATHS.md`, `.ai/PLAN.md`, and
`.ai/conversations/HANDOFF.md` before starting work. After completing a task,
update HANDOFF.md and append to LOG.md."

**Codex / Gemini / Others:** Add the same instruction to the agent's project-level
config file (`.codex.md`, `AGENTS.md`, or equivalent). The key files are plain
markdown — any agent that can read and write files can participate.

**Minimum viable integration:** Even if an agent doesn't fully implement the skill,
just reading HANDOFF.md on startup and appending to LOG.md after work captures
80% of the value.

---

## Rules

1. **Always read before work.** Read the 4 context files (PROJECT.md, PATHS.md,
   PLAN.md, HANDOFF.md) at the start of every conversation. No exceptions.

2. **Always write after work.** Even for Q&A. A question answered today might be
   the context another agent needs tomorrow.

3. **Be concise in LOG.md.** 3-5 lines per entry. Full details go in session files.

4. **Respect size limits.** Keep files within the limits in the Size Limits table.
   Archive LOG.md when it exceeds ~500 lines.

5. **Promote decisions.** If a task involved choosing between approaches, write it
   to `decisions/`. Decisions are the highest-value cross-agent context.

6. **Don't duplicate git history.** Reference commit hashes instead of repeating
   diffs in session files.

7. **Use real timestamps.** Always use the current date and time, never placeholders.

8. **Tag every LOG.md entry.** Tags enable scanning. Use the tag list above.

9. **Keep PATHS.md accurate.** New directory, new file, new doc? Update PATHS.md.
   This is every agent's filesystem map.

10. **Update PLAN.md on task progress.** Mark tasks done, add blockers, note the agent.

11. **Progressive disclosure for resume.** HANDOFF.md → session file → source files.
    Don't flatten everything into HANDOFF.md.

12. **Minimal logging for simple Q&A.** One-liner in LOG.md. No session file unless
    the answer revealed important context or a decision.

13. **Identify yourself.** Always include your agent name in all writes. If unknown,
    use the name from your system prompt or `unknown-agent`.

14. **LOG.md is append-only.** Never delete entries. Archive to `LOG-archive-YYYY.md`
    when the file grows too large.

15. **Verify on resume.** When continuing another agent's work, check that the files
    mentioned in the session actually exist in their described state before proceeding.

16. **Read docs before implementation.** Check PATHS.md for relevant specs, plans, or
    requirements docs. The requirements doc (TRD/PRD) is authoritative when it
    conflicts with a feature spec.

17. **Index new documents immediately.** When you create a new doc, add it to PATHS.md.
    Don't leave it for the next agent to discover by accident.

18. **Current over archived.** Never reference an archived document as authoritative.
    Check if a newer version exists first.

19. **Record your sources.** In the session file References section, list every
    document you consulted. This helps the next agent understand your context.

20. **Read context, not the library.** On startup, read only the 4 context files.
    Read specific reference docs on-demand when the task requires them. PATHS.md
    is an index — use it to find what you need, not to load everything.
