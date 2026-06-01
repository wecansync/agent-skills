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

Run these steps from your project root.

### Step 1: Download The Skill

```bash
npx skills@latest add wecansync/agent-skills
```

This downloads the skill into:

```text
.claude/skills/agent-handoff/
```

### Step 2: Install It Into The Project

```bash
bash .claude/skills/agent-handoff/install.sh
```

This creates the shared handoff files:

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

It also injects the always-active handoff instructions into supported agent
config files:

- `CLAUDE.md`
- `codex.md`
- `AGENTS.md`
- `.opencode/instructions.md`
- `.cursorrules`
- `.windsurfrules`
- `GEMINI.md`
- `.github/copilot-instructions.md`

The installer is safe to re-run. It skips current snippets, upgrades old
snippets, and does not overwrite your existing project instructions.

### Step 3: Bootstrap Context Once

In Claude Code, run:

```text
/agent-handoff
```

Or ask any agent:

```text
Scan this project and populate the .ai context files.
```

This fills:

- `.ai/PROJECT.md`
- `.ai/PATHS.md`
- `.ai/PLAN.md`
- `.ai/conversations/HANDOFF.md`

After this, agents should read and update handoff automatically.

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

If `CLAUDE.md`, `AGENTS.md`, or `codex.md` are missing, re-run the installer from
the project root. The installer creates those files when needed.

## Usage

### 1. Work Normally

After bootstrap, start any agent and work as usual. You do not need to mention
`agent-handoff` in every prompt.

The installed always-active snippet tells each agent to:

- Read `.ai/PROJECT.md`, `.ai/PATHS.md`, `.ai/PLAN.md`, and `.ai/conversations/HANDOFF.md` before work.
- Append to `.ai/conversations/LOG.md` after work.
- Update `.ai/conversations/HANDOFF.md` when work changes.
- Create session files in `.ai/conversations/sessions/YYYY-MM-DD/`.

Optional safety nudge: if an agent does not reliably load project instructions,
or you want to be extra sure the handoff context is read and updated, add a short
phrase like `use handoff`, `check handoff`, or `use agent-handoff` to your prompt.

If an agent reads handoff but forgets to update it, use the stronger force
pattern below. This tells the agent to read at the start and write before it
finishes:

```text
Use handoff. Read the handoff context before starting. Before your final response, update LOG.md, HANDOFF.md, and a session file if you changed files or made decisions.
```

Example normal prompt:

```text
Continue implementing the dashboard filters and run the relevant tests.
```

Example with the optional nudge:

```text
Use handoff, then continue implementing the dashboard filters and run the relevant tests.
```

Example with forced read/write:

```text
Use handoff. Read the handoff context first. Continue implementing the dashboard filters and run the relevant tests. Before your final response, update LOG.md, HANDOFF.md, and a session file for this work.
```

### 2. Resume Another Agent's Work

Ask:

```text
Read the handoff files, summarize the last active task, then continue from there.
```

### 3. Check What Happened Recently

Ask:

```text
What did the last agent do, and what should happen next?
```

### 4. Repair Or Refresh Context

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

Then in Claude Code:

```text
/agent-handoff
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
