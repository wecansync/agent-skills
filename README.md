# Agent Skills

Open agent skills for multi-agent development workflows. Built for real teams that use multiple AI agents (Claude, OpenCode, Codex, Gemini, Kilo, Antigravity, etc.) on the same codebase.

## Quick Install

```bash
npx skills@latest add wecansync/agent-skills
```

Pick the skills you want and which agents to install them on. Done.

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

**How it works:**
1. Agent starts a conversation → reads 4 small context files (~1000 tokens)
2. Agent finishes a task → appends to LOG.md, updates HANDOFF.md, writes session file
3. Next agent starts → instantly knows what was done, what's in progress, what's blocked

**Features:**
- Automatic documentation discovery — scans for docs/, specs/, rfcs/, ADRs, OpenAPI specs, Postman collections, and indexes them in PATHS.md
- Smart bootstrapping — detects project type from package manifests (composer.json, package.json, go.mod, Cargo.toml, etc.) and generates PROJECT.md automatically
- Version-aware document indexing — distinguishes current from archived docs (e.g., TRD-v5 vs TRD-v3)
- Decision records — promotes architectural decisions to standalone files that outlive sessions
- Stale detection — warns when HANDOFF.md is >7 days old and cross-references git history
- Concurrent agent safety — guidance for when two agents work simultaneously
- Monorepo support — `.ai/` at repo root, covers all packages
- Works with any agent — plain markdown files that any tool can read/write

**Token cost:** ~1500 tokens on startup, ~1000 tokens per task write. Cheaper than re-reading the codebase every time.

## How Skills Work

Skills are markdown instruction files that agents load to get specialized capabilities. They live in:
- `.claude/skills/` — Claude Code reads from here
- `.agents/skills/` — Universal format for other agents

When you install via `npx skills`, the files are placed in both locations automatically.

## Project Structure

```
.claude-plugin/
  plugin.json           ← Skill registry for the skills.sh ecosystem
skills/
  agent-handoff/
    SKILL.md             ← Skill definition (triggers, rules, templates)
    references/
      examples.md        ← Real-world examples across project types
LICENSE
README.md
```

## Manual Installation

If you prefer not to use the skills.sh installer:

```bash
# Clone into your project
git clone https://github.com/wecansync/agent-skills.git /tmp/agent-skills

# Copy the skill you want
mkdir -p .claude/skills/agent-handoff/references
cp /tmp/agent-skills/skills/agent-handoff/SKILL.md .claude/skills/agent-handoff/
cp /tmp/agent-skills/skills/agent-handoff/references/* .claude/skills/agent-handoff/references/

# For non-Claude agents, also copy to .agents/skills/
mkdir -p .agents/skills/agent-handoff/references
cp /tmp/agent-skills/skills/agent-handoff/SKILL.md .agents/skills/agent-handoff/
cp /tmp/agent-skills/skills/agent-handoff/references/* .agents/skills/agent-handoff/references/

# Clean up
rm -rf /tmp/agent-skills
```

## Integrating with Non-Claude Agents

The `.ai/` directory is plain markdown — any agent can participate. For agents that don't auto-discover skills, add this to their project config:

> Read `.ai/PROJECT.md`, `.ai/PATHS.md`, `.ai/PLAN.md`, and `.ai/conversations/HANDOFF.md` before starting work. After completing a task, update HANDOFF.md and append to LOG.md following the format in those files.

This single instruction captures 80% of the value even without the full skill installed.

## Contributing

PRs welcome. If you have a skill that solves a real multi-agent workflow problem, open a PR with:

1. A `skills/{skill-name}/SKILL.md` file
2. A `references/examples.md` with at least 2 real-world examples
3. An update to `.claude-plugin/plugin.json` registering the new skill
4. An update to this README listing the skill

## License

MIT
