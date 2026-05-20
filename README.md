# Agent Skills

[![skills.sh](https://skills.sh/b/wecansync/agent-skills)](https://skills.sh/wecansync/agent-skills)

Open agent skills for multi-agent development workflows. Built for real teams that use multiple AI agents (Claude, OpenCode, Codex, Gemini, Cursor, Windsurf, Copilot, etc.) on the same codebase.

## Quick Install

### Option 1: Universal install script (recommended)

One command installs the skill for **all** agents in your project:

```bash
curl -fsSL https://raw.githubusercontent.com/wecansync/agent-skills/main/skills/agent-handoff/install.sh | bash
```

This will:
1. Copy skill files to `.claude/skills/` and `.agents/skills/`
2. Inject the always-active handoff snippet into every detected agent config file (`CLAUDE.md`, `codex.md`, `.cursorrules`, `.windsurfrules`, `GEMINI.md`, `.github/copilot-instructions.md`, `.opencode/instructions.md`)
3. Create the `.ai/` directory structure
4. For agents not yet configured, create their config file with the snippet

### Option 2: Via skills.sh

```bash
npx skills@latest add wecansync/agent-skills
```

Then run the install script to inject into all agent config files:

```bash
bash .claude/skills/agent-handoff/install.sh
```

### Option 3: Manual installation

```bash
# Clone
git clone https://github.com/wecansync/agent-skills.git /tmp/agent-skills

# Copy skill files
mkdir -p .claude/skills/agent-handoff/references .agents/skills/agent-handoff/references
cp /tmp/agent-skills/skills/agent-handoff/SKILL.md .claude/skills/agent-handoff/
cp /tmp/agent-skills/skills/agent-handoff/inject.md .claude/skills/agent-handoff/
cp /tmp/agent-skills/skills/agent-handoff/references/* .claude/skills/agent-handoff/references/
cp /tmp/agent-skills/skills/agent-handoff/SKILL.md .agents/skills/agent-handoff/
cp /tmp/agent-skills/skills/agent-handoff/inject.md .agents/skills/agent-handoff/
cp /tmp/agent-skills/skills/agent-handoff/references/* .agents/skills/agent-handoff/references/

# Create .ai/ directory
mkdir -p .ai/conversations/decisions .ai/conversations/sessions

# IMPORTANT: Append inject.md to each agent's config file
cat .claude/skills/agent-handoff/inject.md >> CLAUDE.md
cat .claude/skills/agent-handoff/inject.md >> codex.md
# ... repeat for each agent config file in your project

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
- ~25 lines added to `CLAUDE.md`, `codex.md`, `.cursorrules`, etc.
- Tells every agent: read `.ai/` files on start, write updates after every task
- Survives context compaction because agent config files are re-loaded each turn
- This is what makes the skill "always on" — no skill invocation needed

**Layer 2: Bootstrapper skill** (`/agent-handoff` or manual invocation)
- Scans the project: package manifests, documentation, specs, architecture
- Generates `PROJECT.md`, `PATHS.md`, `PLAN.md` from detected structure
- Handles stale detection and refresh when handoff data is >7 days old
- Run once on first setup, then on-demand when needed

**Layer 3: Reference files** (read on-demand)
- `references/templates.md` — file format templates for all `.ai/` files
- `references/examples.md` — real-world examples across project types

### Supported agents

| Agent | Config file | Auto-detected by install.sh |
|-------|------------|----------------------------|
| Claude Code | `CLAUDE.md` | Always (created if missing) |
| Codex (OpenAI) | `codex.md` | Always (created if missing) |
| Cursor | `.cursorrules` | If file or `.cursor/` dir exists |
| Windsurf | `.windsurfrules` | If file exists |
| Gemini CLI | `GEMINI.md` | If file exists |
| OpenCode | `.opencode/instructions.md` | If `.opencode/` dir exists |
| GitHub Copilot | `.github/copilot-instructions.md` | If `.github/` dir exists |
| Any other agent | Add manually | Append `inject.md` to its config |

### Token cost

- **Startup:** ~800-1500 tokens to read 4 context files
- **Per task:** ~500-1200 tokens to write updates
- Far cheaper than re-reading the codebase every time

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

## After Installation

1. **Start any agent** in your project — it will automatically read `.ai/` files
2. **First run:** Ask the agent to "initialize the project context" or run `/agent-handoff` in Claude Code — it will scan your project and populate the `.ai/` files
3. **Every subsequent run:** The agent reads context on start and writes updates when done — no manual invocation needed
4. **Switch agents freely** — Codex, Claude, Cursor, Gemini all share the same `.ai/` context

## Re-running the installer

Safe to re-run at any time. The script:
- Skips injection if the snippet is already present in a config file
- Skips `.ai/` files that already exist
- Only adds — never overwrites existing content

```bash
# Add support for a newly installed agent
bash .claude/skills/agent-handoff/install.sh
```

## Contributing

PRs welcome. If you have a skill that solves a real multi-agent workflow problem, open a PR with:

1. A `skills/{skill-name}/SKILL.md` file
2. A `references/examples.md` with at least 2 real-world examples
3. An update to `.claude-plugin/plugin.json` registering the new skill
4. An update to this README listing the skill

## License

MIT
