# Agent Skills

[![skills.sh](https://skills.sh/b/wecansync/agent-skills)](https://skills.sh/wecansync/agent-skills)

Open skills for multi-agent development workflows.

## Agent Handoff

`agent-handoff` lets Claude, Codex, OpenCode, Antigravity, Cursor, Windsurf,
Gemini, Copilot, and other agents share project context through a `.ai/`
directory inside your repo.

It helps agents answer:

- What is this project?
- What did the last agent do?
- What is currently in progress?
- Which files, plans, and docs matter?
- What should I continue next?

## Installation

Install from your project root:

```bash
npx skills@latest add wecansync/agent-skills
bash .claude/skills/agent-handoff/install.sh
```

That creates:

```text
.ai/
├── PROJECT.md
├── PATHS.md
├── PLAN.md
└── conversations/
    ├── HANDOFF.md
    ├── LOG.md
    ├── decisions/
    └── sessions/
```

It also injects handoff instructions into supported agent config files:

- `CLAUDE.md`
- `codex.md`
- `AGENTS.md`
- `.opencode/instructions.md`
- `.cursorrules`
- `.windsurfrules`
- `GEMINI.md`
- `.github/copilot-instructions.md`

### Direct Install

Use this if you do not use `skills.sh`:

```bash
cd /path/to/project
curl -fsSL https://raw.githubusercontent.com/wecansync/agent-skills/main/skills/agent-handoff/install.sh | bash
```

Install into a specific project:

```bash
curl -fsSL https://raw.githubusercontent.com/wecansync/agent-skills/main/skills/agent-handoff/install.sh | bash -s -- --project-dir /path/to/project
```

### Re-run Installer

Safe to run again after adding a new agent or upgrading the skill:

```bash
bash .claude/skills/agent-handoff/install.sh
```

The installer skips current snippets, upgrades old snippets, and does not
overwrite your existing project instructions.

## Usage

### 1. Bootstrap The Project

After installation, bootstrap once. Ask any agent:

```text
Scan this project and populate the .ai context files.
```

Claude Code shortcut:

```text
/agent-handoff
```

Do this once per project. The agent scans your repo and fills:

- `.ai/PROJECT.md` — project overview, stack, conventions
- `.ai/PATHS.md` — important files and docs
- `.ai/PLAN.md` — current work and task status
- `.ai/conversations/HANDOFF.md` — latest agent handoff

### 2. Work Normally

After bootstrap, start any agent and work as usual. You do not need to mention
`agent-handoff` in every prompt.

The installed always-active snippet tells each agent to:

- Read `.ai/PROJECT.md`, `.ai/PATHS.md`, `.ai/PLAN.md`, and `.ai/conversations/HANDOFF.md` before work.
- Append to `.ai/conversations/LOG.md` after work.
- Update `.ai/conversations/HANDOFF.md` when work changes.
- Create session files in `.ai/conversations/sessions/YYYY-MM-DD/`.

Example normal prompt:

```text
Continue implementing the dashboard filters and run the relevant tests.
```

### 3. Resume Another Agent's Work

Ask:

```text
Read the handoff files, summarize the last active task, then continue from there.
```

### 4. Check What Happened Recently

Ask:

```text
What did the last agent do, and what should happen next?
```

### 5. Repair Or Refresh Context

Ask:

```text
Check whether the .ai files are missing, empty, stale, or placeholder-only, then repair them.
```

## Example Workflow

```bash
cd /path/to/project
npx skills@latest add wecansync/agent-skills
bash .claude/skills/agent-handoff/install.sh
```

Then in Claude, Codex, OpenCode, Antigravity, or another agent:

```text
Scan this project and populate the .ai context files.
```

Later, in another agent:

```text
Read the handoff files and continue the current task.
```

## Verify Setup

Start a new agent session and ask:

```text
What do you know about this project from the handoff context?
```

If setup worked, the agent should mention details from `.ai/PROJECT.md`,
`.ai/PATHS.md`, `.ai/PLAN.md`, or `.ai/conversations/HANDOFF.md`.

If it does not:

1. Check that the agent config contains `## Agent Handoff (always active)`.
2. Check that `.ai/PROJECT.md` is populated.
3. Restart the agent session.

## Important

Install this skill inside the project, not globally.

Do not install only into `~/.claude/skills/`, because Codex, OpenCode,
Antigravity, Cursor, and other agents need project-local files they can read.

## Project Structure

```text
.claude-plugin/
  plugin.json
skills/
  agent-handoff/
    SKILL.md
    inject.md
    install.sh
    references/
      templates.md
      examples.md
LICENSE
README.md
```

## License

MIT
