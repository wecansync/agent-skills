---
name: agent-handoff
description: >
  Bootstrap and manage the .ai/ shared context directory for multi-agent projects.
  Use when initializing agent handoff, bootstrapping .ai/ files, refreshing stale
  handoff state, or when the user says "bootstrap", "initialize", "set up handoff",
  "what did the last agent do", "continue where X left off", or "resume".
---

# Agent Handoff — Bootstrapper & Manager

This skill bootstraps and maintains the `.ai/` shared context directory that
enables seamless handoff between AI agents (Claude, Codex, Gemini, Cursor,
Windsurf, OpenCode, Copilot, and others).

The always-active read/write behavior is handled by the snippet injected into
each agent's config file (CLAUDE.md, codex.md, .cursorrules, etc.) during
installation. This skill handles the heavier operations: first-run bootstrapping,
stale detection, and project scanning.

For file format templates, see `references/templates.md`.
For real-world examples, see `references/examples.md`.

---

## When This Skill Triggers

- User says "bootstrap", "initialize", "set up handoff", "set up agent context"
- User says "continue", "resume", "keep going", "what was the last agent doing"
- `.ai/PROJECT.md` does not exist (first-run detection)
- HANDOFF.md is stale (>7 days since last update)
- User explicitly invokes `/agent-handoff`

---

## First-Run Bootstrapping

If `.ai/PROJECT.md` does not exist or is empty, run the full bootstrap.

### Step 1: Create directory structure

```bash
mkdir -p .ai/conversations/decisions .ai/conversations/sessions
```

### Step 2: Detect project type and tech stack

Read all package manifests that exist (a polyglot project may have several):
- `composer.json` — PHP (Laravel, Symfony, etc.)
- `package.json` — Node.js / frontend (Next.js, Nuxt, React, Vue, Angular, etc.)
- `Gemfile` — Ruby (Rails, Sinatra, etc.)
- `requirements.txt` / `pyproject.toml` / `Pipfile` — Python (Django, Flask, FastAPI, etc.)
- `go.mod` — Go
- `Cargo.toml` — Rust
- `pom.xml` / `build.gradle` — Java / Kotlin
- `*.csproj` / `*.sln` — .NET

Read all agent/convention configs that exist:
- `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.windsurfrules`, `codex.md`, `GEMINI.md`
- `README.md`, `CONTRIBUTING.md`
- `.editorconfig`, lint configs (`.prettierrc`, `eslint.config.*`, `phpcs.xml`, etc.)

Read environment hints:
- `.env.example` — expected environment variables
- `docker-compose.yml` / `Dockerfile` — containerized setup
- `Makefile` / `justfile` — common commands

### Step 3: Discover documentation

Scan these locations for documentation files:

```
Root:        *.md files (README, CHANGELOG, CONTRIBUTING, ARCHITECTURE, etc.)
Docs:        docs/  documentation/  wiki/  guides/  .github/
Specs:       specs/  spec/  plans/  rfcs/  adrs/  design/  proposals/
API:         docs/api/  api-docs/
             openapi.yaml  openapi.json  swagger.json  swagger.yaml
             *.postman_collection.json (up to 3 levels deep)
             insomnia*.json  insomnia*.yaml
Nested:      docs/archive/  docs/plans/  any docs/ subdirectory with markdown
```

For each location found:
```bash
find {dir} -maxdepth 3 -type f \( -name "*.md" -o -name "*.pdf" -o -name "*.postman_collection.json" -o -name "openapi.*" -o -name "swagger.*" \)
```

Classify by reading the title or first 10 lines:

| Category | Examples | Priority |
|----------|----------|----------|
| Requirements | TRD, PRD, BRD | HIGH — read before implementing |
| Architecture | System design, ADR | HIGH |
| Implementation Plans | Roadmap, phasing doc | HIGH |
| Project Overview | Overview, project brief | HIGH |
| Operational Guides | User guides, runbooks | MEDIUM |
| API Documentation | Integration guides, OpenAPI | MEDIUM |
| Feature Specs | Per-feature specs, RFCs | ON-DEMAND |
| Archived | Anything in archive/ or older version | LOW |

**Version detection:** When multiple versions exist (e.g., TRD-v3, TRD-v4, TRD-v5),
identify the current version by highest number or most recent date. List only the
current version under "Reference Documents (current)." Older versions go to "Archived."

### Step 4: Detect spec/plan directory patterns

If specs/, rfcs/, adrs/, or similar directories exist:
1. List all subdirectories
2. Pick one representative and list its contents
3. Document the detected pattern (what files each entry contains)
4. List all entries with one-line descriptions
5. Identify active vs completed (check git history or task checkboxes)

If no formal spec system exists, note how the project tracks work (GitHub Issues,
Jira, informal, etc.) if detectable.

### Step 5: Generate context files

Using the templates in `references/templates.md`, generate:
- `.ai/PROJECT.md` — from detected stack, architecture, and key documents
- `.ai/PATHS.md` — from discovered files and documentation
- `.ai/PLAN.md` — from active work (git branch, recent commits, spec status)
- `.ai/conversations/HANDOFF.md` — initial state with "system initialized" note
- `.ai/conversations/LOG.md` — header only

### Step 6: Report to the user

```
Agent handoff system initialized.

Discovered: {N} reference documents, {N} feature specs, {N} archived docs.
Key documents: {list top 3}
Active work detected: {feature/branch or "none detected"}
Gaps: {any missing elements like "no test directory found"}
```

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

## Size Limits

| File | Max Lines | Enforcement |
|------|-----------|-------------|
| PROJECT.md | ~80 | Stable — only update when stack or architecture changes |
| PATHS.md | ~150 | Collapse less-important entries into directory summaries |
| PLAN.md | ~60 | Track active feature only. Completed → one-liner |
| HANDOFF.md | ~100 | Rolling window: max 15-20 Recent Completions. Oldest → LOG.md |
| LOG.md | ~500 | Archive entries older than 90 days to `LOG-archive-YYYY.md` |
| Session files | ~80 each | Reference commit hashes instead of repeating diffs |

**Startup read cost:** ~800-1500 tokens for all 4 files combined.
**Per-task write cost:** ~500-1200 tokens depending on complexity.

---

## Concurrent Agent Safety

When two agents work simultaneously, file conflicts can occur.

**Prevention:**
- HANDOFF.md Active Work lists what each agent is working on.
  Before starting, check if another agent is currently active.
- Session files never conflict — each agent writes its own timestamped file.
- LOG.md is append-only — conflicts are simple to resolve (keep both entries).

**If a merge conflict occurs in HANDOFF.md:**
1. Keep both agents' Active Work entries
2. Merge Recent Completions chronologically
3. Union all Key Context entries

---

## Monorepo Projects

- Place `.ai/` at the **repository root**, not inside individual packages
- PATHS.md should list all packages/services with their paths
- PLAN.md can track work across packages — use package prefixes
- Session files should note which package(s) were modified

---

## Rules

1. **Always read before work.** The 4 context files at conversation start. No exceptions.
2. **Always write after work.** Even for Q&A — a question answered today is context tomorrow.
3. **Be concise in LOG.md.** 3-5 lines per entry. Full details in session files.
4. **Respect size limits.** Archive LOG.md when it exceeds ~500 lines.
5. **Promote decisions.** Architecture/design choices → `decisions/` directory.
6. **Don't duplicate git history.** Reference commit hashes, not diffs.
7. **Use real timestamps.** Never placeholders.
8. **Tag every LOG.md entry.** Tags enable scanning.
9. **Keep PATHS.md accurate.** New file or doc → update PATHS.md.
10. **Update PLAN.md on progress.** Mark tasks done, add blockers, note the agent.
11. **Progressive disclosure.** HANDOFF.md → session file → source files.
12. **Identify yourself.** Include agent name in all writes.
13. **LOG.md is append-only.** Never delete entries.
14. **Verify on resume.** Check files exist before continuing another agent's work.
15. **Read docs before implementation.** Check PATHS.md for relevant specs/plans.
16. **Index new documents immediately.** Don't leave them for the next agent.
17. **Current over archived.** Never reference an archived doc as authoritative.
18. **Record your sources.** List consulted docs in session file References section.
