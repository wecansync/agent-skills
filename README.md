# Agent Skills

[![skills.sh](https://skills.sh/b/wecansync/agent-skills)](https://skills.sh/wecansync/agent-skills)

Open agent skills for multi-agent development workflows. Built for real teams that use multiple AI agents (Claude, Codex, Gemini, Cursor, Windsurf, Copilot, OpenCode, etc.) on the same codebase.

## Quick Install

> **Important: Project scope only.** This skill must be installed inside your project directory, not at user scope (`~/.claude/skills/`). The `.ai/` context files and agent config snippets must live in the project so that **all** agents — not just Claude — can access them. The install script will warn you if it detects a user-scope path.

From your **project root**:

```bash
npx skills@latest add wecansync/agent-skills && bash .claude/skills/agent-handoff/install.sh
```

That's it. Two commands:
1. `npx skills@latest add` — downloads the skill files via [skills.sh](https://skills.sh/wecansync/agent-skills)
2. `bash install.sh` — activates the skill for every agent in your project

> **Why two commands?** The skills.sh CLI copies files to `.claude/skills/`, but no agent auto-runs skills on every prompt — they only invoke them when they think the user's message is relevant. The install script solves this by injecting a small always-active snippet into each agent's config file (`CLAUDE.md`, `codex.md`, `.cursorrules`, etc.) so every agent reads `.ai/` context on start and writes updates after every task. A native `postInstall` hook would make this a single command — [feature request is open](https://github.com/anthropics/claude-code/issues/9394).

### What `install.sh` does

1. Copies skill files to `.claude/skills/` and `.agents/skills/`
2. Detects which agents are configured in your project
3. Injects the always-active snippet into each agent's config file (`CLAUDE.md`, `codex.md`, `AGENTS.md`, `.cursorrules`, `.windsurfrules`, `GEMINI.md`, `.github/copilot-instructions.md`, `.opencode/instructions.md`)
4. Creates the `.ai/` directory structure
5. For Claude and Codex, creates config files if they don't exist; for all others (including `AGENTS.md`), injects only if the file already exists

Safe to re-run — skips files already injected, never overwrites existing content.

### Alternative: Direct install (without skills.sh)

If you don't use the skills.sh ecosystem, run from your **project root**:

```bash
curl -fsSL https://raw.githubusercontent.com/wecansync/agent-skills/main/skills/agent-handoff/install.sh | bash
```

> Note: this bypasses skills.sh, so installs won't be tracked on the [leaderboard](https://skills.sh/wecansync/agent-skills).

### Alternative: Manual installation

```bash
# Clone
git clone https://github.com/wecansync/agent-skills.git /tmp/agent-skills

# Copy skill files into your project
cd /path/to/your/project
mkdir -p .claude/skills/agent-handoff/references .agents/skills/agent-handoff/references
for dir in .claude/skills/agent-handoff .agents/skills/agent-handoff; do
  cp /tmp/agent-skills/skills/agent-handoff/SKILL.md "$dir/"
  cp /tmp/agent-skills/skills/agent-handoff/inject.md "$dir/"
  cp /tmp/agent-skills/skills/agent-handoff/install.sh "$dir/"
  cp /tmp/agent-skills/skills/agent-handoff/references/* "$dir/references/"
done

# Run the installer to inject into all agent configs and create .ai/
bash .claude/skills/agent-handoff/install.sh

# Clean up
rm -rf /tmp/agent-skills
```

## Available Skills

### [`agent-handoff`](./skills/agent-handoff/SKILL.md) — Cross-Agent Conversation Bridge

The core problem: **Agent A has no idea what Agent B did yesterday.** Every agent starts cold, re-reads the entire codebase, and has zero context about decisions, progress, or blockers from other agents' sessions.

Agent Handoff fixes this with a shared `.ai/` directory in your project:

```
.ai/
├── PROJECT.md              ← Tech stack, architecture, key documents
├── PATHS.md                ← Filesystem map + reference document index
├── PLAN.md                 ← Current feature status and task tracking
└── conversations/
    ├── HANDOFF.md           ← What's active, what's done, what's next
    ├── LOG.md               ← Chronological changelog (all agents)
    ├── decisions/           ← Architecture decisions that outlive sessions
    └── sessions/            ← Detailed per-session logs
```

### How it works (three layers)

**Layer 1: Always-active snippet** (injected into agent config files)
- ~25 lines added to each agent's config file (`CLAUDE.md`, `codex.md`, `.cursorrules`, etc.)
- Tells every agent: read `.ai/` files on start, write updates after every task
- Survives context compaction because agent config files are re-loaded each turn
- This is what makes the skill "always on" — no manual invocation needed

**Layer 2: Bootstrapper** (run once, then on-demand)
- Scans the project: package manifests, documentation, specs, architecture
- Generates `PROJECT.md`, `PATHS.md`, `PLAN.md` from detected structure
- Handles stale detection and refresh when handoff data is >7 days old

**Layer 3: Reference files** (read on-demand by agents)
- `references/templates.md` — file format templates for all `.ai/` files
- `references/examples.md` — real-world examples across project types

### Supported agents

| Agent | Config file | Auto-detected by install.sh |
|-------|------------|----------------------------|
| Claude Code | `CLAUDE.md` | Always (created if missing) |
| Codex (OpenAI) | `codex.md` | Always (created if missing) |
| Multi-agent | `AGENTS.md` | If file exists |
| Cursor | `.cursorrules` | If file or `.cursor/` dir exists |
| Windsurf | `.windsurfrules` | If file exists |
| Gemini CLI | `GEMINI.md` | If file exists |
| OpenCode | `.opencode/instructions.md` | If `.opencode/` dir exists |
| GitHub Copilot | `.github/copilot-instructions.md` | If `.github/` dir exists |
| Any other agent | Add manually | Append `inject.md` to its config |

**Adding an unsupported agent:** Copy the contents of `inject.md` into the agent's project-level instructions file. Any agent that reads a project instructions file on startup will work.

### Token cost

- **Startup:** ~800-1500 tokens to read the 4 context files
- **Per task:** ~500-1200 tokens to write updates
- Far cheaper than re-reading the codebase every time

## Usage

### Step 1: Bootstrap the project context (first run — required)

The install script creates the `.ai/` directory structure, but the context files (`PROJECT.md`, `PATHS.md`, `PLAN.md`) are empty until an agent scans your project. You need to bootstrap once with **any** agent.

**Universal prompt (works with any agent):**

```
Scan this project and populate the .ai/ context files (PROJECT.md, PATHS.md,
PLAN.md) following the templates in .agents/skills/agent-handoff/references/templates.md
```

**Agent-specific shortcuts:**

| Agent | How to bootstrap |
|-------|-----------------|
| Claude Code | Type `/agent-handoff` or say "initialize the project context" |
| Codex | Paste the universal prompt above — Codex reads `codex.md` automatically |
| Cursor | Paste the universal prompt — Cursor reads `.cursorrules` automatically |
| Windsurf | Paste the universal prompt — Windsurf reads `.windsurfrules` automatically |
| Gemini CLI | Paste the universal prompt — Gemini reads `GEMINI.md` automatically |
| Copilot | Paste the universal prompt — Copilot reads `.github/copilot-instructions.md` automatically |
| Any agent | Paste the universal prompt — as long as it can read/write project files |

After bootstrapping, the `.ai/` files are populated. Every subsequent agent session reads them automatically — no manual invocation needed.

### Step 2: Work normally

Once bootstrapped, the always-active snippet handles everything:
- **On conversation start:** the agent reads `.ai/PROJECT.md`, `PATHS.md`, `PLAN.md`, and `HANDOFF.md`
- **After completing a task:** the agent appends to `LOG.md` and updates `HANDOFF.md`
- **No manual invocation needed** — the snippet in each agent's config file drives this

### On-demand operations

You can ask any agent to perform these at any time:

#### Refresh stale context

```
The .ai/conversations/HANDOFF.md file may be stale. Cross-reference it with
git log --oneline --since="7 days ago" and update it to reflect current state.
Also check .ai/PATHS.md for any file references that no longer exist.
```

#### Resume another agent's work

```
Read .ai/conversations/HANDOFF.md, find the last active task, read the referenced
session file, then check the actual source files before continuing the work.
```

#### Re-scan project documentation

```
Scan the project for new documentation files (check docs/, specs/, rfcs/, adrs/,
and root *.md files). Update .ai/PATHS.md with anything not already indexed.
Follow the format in .agents/skills/agent-handoff/references/templates.md
```

### Verifying the setup

Start a new conversation with any agent and ask:

```
What do you know about this project from the handoff context?
```

The agent should respond with details from `.ai/PROJECT.md` — tech stack, architecture, active work. If it doesn't, check:

1. **Snippet is present** — open the agent's config file (`CLAUDE.md`, `codex.md`, `.cursorrules`, etc.) and confirm it contains `## Agent Handoff (always active)`
2. **Context files are populated** — `.ai/PROJECT.md` should not be empty (run the bootstrap if it is)
3. **Agent is restarted** — some agents cache the config file and need a new conversation

### Why project scope matters

The `.ai/` directory and agent config files **must** live inside your project because:

- **All agents need access.** User-scope files (`~/.claude/skills/`) are only visible to Claude. Codex reads `codex.md` from the project root. Cursor reads `.cursorrules` from the project root. The shared `.ai/` directory must be where all agents can see it.
- **Context is project-specific.** `PROJECT.md` describes *this* project's stack. `PATHS.md` maps *this* project's files. Installing at user scope would mix context across projects.
- **Team collaboration.** Commit the `.ai/` directory to git (optionally exclude `sessions/` for noise reduction) and the entire team's agents share context.

If you accidentally installed at user scope, move the files:

```bash
# Move from user scope to project scope
mv ~/.claude/skills/agent-handoff /path/to/your/project/.claude/skills/
cd /path/to/your/project
bash .claude/skills/agent-handoff/install.sh
```

## Project Structure

```
.claude-plugin/
  plugin.json             ← Skill registry for the skills.sh ecosystem
skills/
  agent-handoff/
    SKILL.md              ← Bootstrapper: project scanning, .ai/ generation
    inject.md             ← Always-active snippet injected into agent configs
    install.sh            ← Universal installer for all agents
    references/
      templates.md        ← File format templates for all .ai/ files
      examples.md         ← Real-world examples across project types
LICENSE
README.md
```

## Re-running the installer

Safe to re-run at any time — for example, after adding Cursor or Windsurf to an existing project:

```bash
bash .claude/skills/agent-handoff/install.sh
```

The script skips files already injected and never overwrites existing content.

## Contributing

PRs welcome. If you have a skill that solves a real multi-agent workflow problem, open a PR with:

1. A `skills/{skill-name}/SKILL.md` file
2. A `references/examples.md` with at least 2 real-world examples
3. An update to `.claude-plugin/plugin.json` registering the new skill
4. An update to this README listing the skill

## License

MIT
