#!/usr/bin/env bash
set -euo pipefail

# Agent Handoff — Universal Installer
# Installs the agent-handoff skill for ALL detected agents in a project.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/wecansync/agent-skills/main/skills/agent-handoff/install.sh | bash
#   # or
#   bash install.sh [--project-dir /path/to/project]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR=""
INJECT_MARKER="## Agent Handoff (always active)"

# Parse flags
while [[ $# -gt 0 ]]; do
  case $1 in
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --help|-h)
      echo "Agent Handoff — Universal Installer"
      echo ""
      echo "Usage:"
      echo "  bash install.sh                          # install in current directory"
      echo "  bash install.sh --project-dir /path/to   # install in specific project"
      echo ""
      echo "This script MUST be run from your project root (or use --project-dir)."
      echo "Do NOT install at user scope (~/.claude/skills/) — the .ai/ context"
      echo "files and agent config snippets must live inside the project."
      exit 0
      ;;
    *) shift ;;
  esac
done

# Resolve project directory
if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR="$(pwd)"
fi
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[info]${NC} $1"; }
success() { echo -e "${GREEN}[done]${NC} $1"; }
warn()    { echo -e "${YELLOW}[skip]${NC} $1"; }
err()     { echo -e "${RED}[error]${NC} $1"; }
step()    { echo -e "${GREEN}  +${NC} $1"; }

echo ""
echo "============================================"
echo "  Agent Handoff — Universal Installer"
echo "============================================"
echo ""

# ---------------------------------------------------------------------------
# Pre-flight: Validate project scope
# ---------------------------------------------------------------------------

# Detect if running inside a user home config directory (wrong scope)
case "$PROJECT_DIR" in
  "$HOME/.claude"*|"$HOME/.config"*|"$HOME/.local"*|"$HOME/Library"*)
    err "Detected user-scope directory: $PROJECT_DIR"
    echo ""
    echo "  Agent Handoff must be installed at PROJECT scope, not user scope."
    echo "  The .ai/ context files and agent config snippets must live inside"
    echo "  your project so all agents (Claude, Codex, Cursor, etc.) can access them."
    echo ""
    echo "  Run this script from your project root instead:"
    echo ""
    echo "    cd /path/to/your/project"
    echo "    bash install.sh"
    echo ""
    echo "  Or specify the project directory:"
    echo ""
    echo "    bash install.sh --project-dir /path/to/your/project"
    echo ""
    exit 1
    ;;
esac

# Check for signs this is actually a project root
IS_PROJECT=false
if [[ -d "$PROJECT_DIR/.git" ]]; then
  IS_PROJECT=true
elif [[ -f "$PROJECT_DIR/package.json" ]] || [[ -f "$PROJECT_DIR/composer.json" ]] || \
     [[ -f "$PROJECT_DIR/go.mod" ]] || [[ -f "$PROJECT_DIR/Cargo.toml" ]] || \
     [[ -f "$PROJECT_DIR/pyproject.toml" ]] || [[ -f "$PROJECT_DIR/requirements.txt" ]] || \
     [[ -f "$PROJECT_DIR/Gemfile" ]] || [[ -f "$PROJECT_DIR/pom.xml" ]] || \
     [[ -f "$PROJECT_DIR/build.gradle" ]] || [[ -f "$PROJECT_DIR/Makefile" ]] || \
     [[ -f "$PROJECT_DIR/README.md" ]]; then
  IS_PROJECT=true
fi

if [[ "$IS_PROJECT" == false ]]; then
  warn "No project markers found (no .git, package.json, composer.json, etc.)"
  echo ""
  echo -e "  ${YELLOW}Are you sure this is your project root?${NC}"
  echo "  Directory: $PROJECT_DIR"
  echo ""
  echo "  Agent Handoff must be installed at project scope — the .ai/ directory"
  echo "  and agent config files (CLAUDE.md, codex.md, etc.) must live in the"
  echo "  project so all agents can read them."
  echo ""
  read -r -p "  Continue anyway? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY]) echo "" ;;
    *)
      echo ""
      echo "  Aborted. Run from your project root:"
      echo "    cd /path/to/your/project && bash install.sh"
      exit 1
      ;;
  esac
fi

info "Project directory: $PROJECT_DIR"
echo ""

# ---------------------------------------------------------------------------
# Step 1: Resolve the inject snippet
# ---------------------------------------------------------------------------

INJECT_FILE=""
if [[ -f "$SCRIPT_DIR/inject.md" ]]; then
  INJECT_FILE="$SCRIPT_DIR/inject.md"
elif [[ -f "$PROJECT_DIR/.claude/skills/agent-handoff/inject.md" ]]; then
  INJECT_FILE="$PROJECT_DIR/.claude/skills/agent-handoff/inject.md"
elif [[ -f "$PROJECT_DIR/.agents/skills/agent-handoff/inject.md" ]]; then
  INJECT_FILE="$PROJECT_DIR/.agents/skills/agent-handoff/inject.md"
fi

if [[ -z "$INJECT_FILE" ]]; then
  # Download inject.md from GitHub
  INJECT_FILE="/tmp/agent-handoff-inject.md"
  info "Downloading inject.md..."
  curl -fsSL "https://raw.githubusercontent.com/wecansync/agent-skills/main/skills/agent-handoff/inject.md" \
    -o "$INJECT_FILE" 2>/dev/null || {
    echo -e "${RED}[error]${NC} Could not find or download inject.md"
    exit 1
  }
fi

INJECT_CONTENT=$(cat "$INJECT_FILE")

# ---------------------------------------------------------------------------
# Step 2: Copy skill files to .claude/skills/ and .agents/skills/
# ---------------------------------------------------------------------------

info "Installing skill files..."

SKILL_SOURCE=""
if [[ -f "$SCRIPT_DIR/SKILL.md" ]]; then
  SKILL_SOURCE="$SCRIPT_DIR"
fi

for TARGET_BASE in ".claude/skills/agent-handoff" ".agents/skills/agent-handoff"; do
  TARGET_DIR="$PROJECT_DIR/$TARGET_BASE"
  mkdir -p "$TARGET_DIR/references"

  if [[ -n "$SKILL_SOURCE" ]]; then
    cp "$SKILL_SOURCE/SKILL.md" "$TARGET_DIR/"
    cp "$SKILL_SOURCE/inject.md" "$TARGET_DIR/"
    [[ -f "$SKILL_SOURCE/references/templates.md" ]] && cp "$SKILL_SOURCE/references/templates.md" "$TARGET_DIR/references/"
    [[ -f "$SKILL_SOURCE/references/examples.md" ]] && cp "$SKILL_SOURCE/references/examples.md" "$TARGET_DIR/references/"
    step "Copied skill files to $TARGET_BASE/"
  else
    # Download from GitHub
    for FILE in SKILL.md inject.md; do
      curl -fsSL "https://raw.githubusercontent.com/wecansync/agent-skills/main/skills/agent-handoff/$FILE" \
        -o "$TARGET_DIR/$FILE" 2>/dev/null || true
    done
    for FILE in templates.md examples.md; do
      curl -fsSL "https://raw.githubusercontent.com/wecansync/agent-skills/main/skills/agent-handoff/references/$FILE" \
        -o "$TARGET_DIR/references/$FILE" 2>/dev/null || true
    done
    step "Downloaded skill files to $TARGET_BASE/"
  fi
done

# ---------------------------------------------------------------------------
# Step 3: Inject snippet into agent config files
# ---------------------------------------------------------------------------

inject_into_file() {
  local file="$1"
  local label="$2"

  if [[ -f "$file" ]]; then
    if grep -qF "$INJECT_MARKER" "$file" 2>/dev/null; then
      warn "$label — already injected"
      return
    fi
    echo "" >> "$file"
    echo "$INJECT_CONTENT" >> "$file"
    step "$label — snippet injected"
  else
    echo "$INJECT_CONTENT" > "$file"
    step "$label — created with snippet"
  fi
}

echo ""
info "Injecting handoff instructions into agent config files..."

INJECTED=0

# Claude Code
if [[ -f "$PROJECT_DIR/CLAUDE.md" ]] || [[ -d "$PROJECT_DIR/.claude" ]]; then
  inject_into_file "$PROJECT_DIR/CLAUDE.md" "CLAUDE.md (Claude Code)"
  INJECTED=$((INJECTED + 1))
else
  inject_into_file "$PROJECT_DIR/CLAUDE.md" "CLAUDE.md (Claude Code)"
  INJECTED=$((INJECTED + 1))
fi

# Codex (OpenAI)
if [[ -f "$PROJECT_DIR/codex.md" ]] || [[ -f "$PROJECT_DIR/AGENTS.md" ]]; then
  if [[ -f "$PROJECT_DIR/AGENTS.md" ]]; then
    inject_into_file "$PROJECT_DIR/AGENTS.md" "AGENTS.md (Codex/multi-agent)"
    INJECTED=$((INJECTED + 1))
  fi
  if [[ -f "$PROJECT_DIR/codex.md" ]]; then
    inject_into_file "$PROJECT_DIR/codex.md" "codex.md (Codex)"
    INJECTED=$((INJECTED + 1))
  fi
else
  inject_into_file "$PROJECT_DIR/codex.md" "codex.md (Codex)"
  INJECTED=$((INJECTED + 1))
fi

# Cursor
if [[ -f "$PROJECT_DIR/.cursorrules" ]] || [[ -d "$PROJECT_DIR/.cursor" ]]; then
  inject_into_file "$PROJECT_DIR/.cursorrules" ".cursorrules (Cursor)"
  INJECTED=$((INJECTED + 1))
fi

# Windsurf
if [[ -f "$PROJECT_DIR/.windsurfrules" ]]; then
  inject_into_file "$PROJECT_DIR/.windsurfrules" ".windsurfrules (Windsurf)"
  INJECTED=$((INJECTED + 1))
fi

# Gemini CLI
if [[ -f "$PROJECT_DIR/GEMINI.md" ]]; then
  inject_into_file "$PROJECT_DIR/GEMINI.md" "GEMINI.md (Gemini CLI)"
  INJECTED=$((INJECTED + 1))
fi

# OpenCode
if [[ -d "$PROJECT_DIR/.opencode" ]]; then
  mkdir -p "$PROJECT_DIR/.opencode"
  inject_into_file "$PROJECT_DIR/.opencode/instructions.md" ".opencode/instructions.md (OpenCode)"
  INJECTED=$((INJECTED + 1))
fi

# Copilot
if [[ -f "$PROJECT_DIR/.github/copilot-instructions.md" ]] || [[ -d "$PROJECT_DIR/.github" ]]; then
  mkdir -p "$PROJECT_DIR/.github"
  inject_into_file "$PROJECT_DIR/.github/copilot-instructions.md" ".github/copilot-instructions.md (Copilot)"
  INJECTED=$((INJECTED + 1))
fi

# ---------------------------------------------------------------------------
# Step 4: Create .ai/ directory structure
# ---------------------------------------------------------------------------

echo ""
info "Creating .ai/ directory structure..."

mkdir -p "$PROJECT_DIR/.ai/conversations/decisions" \
         "$PROJECT_DIR/.ai/conversations/sessions"

for FILE in PROJECT.md PATHS.md PLAN.md; do
  if [[ ! -f "$PROJECT_DIR/.ai/$FILE" ]]; then
    step ".ai/$FILE — created (empty, will be populated on first agent run)"
    touch "$PROJECT_DIR/.ai/$FILE"
  else
    warn ".ai/$FILE — already exists"
  fi
done

if [[ ! -f "$PROJECT_DIR/.ai/conversations/HANDOFF.md" ]]; then
  cat > "$PROJECT_DIR/.ai/conversations/HANDOFF.md" <<'HANDOFF_EOF'
# Agent Handoff
Last updated: —

## Active Work
No prior agent activity recorded.

## Recent Completions
(empty)

## Pending Decisions
None

## Key Context
- Agent handoff system initialized — awaiting first agent session
HANDOFF_EOF
  step ".ai/conversations/HANDOFF.md — created"
else
  warn ".ai/conversations/HANDOFF.md — already exists"
fi

if [[ ! -f "$PROJECT_DIR/.ai/conversations/LOG.md" ]]; then
  echo "# Agent Activity Log" > "$PROJECT_DIR/.ai/conversations/LOG.md"
  step ".ai/conversations/LOG.md — created"
else
  warn ".ai/conversations/LOG.md — already exists"
fi

# ---------------------------------------------------------------------------
# Step 5: Add .ai/ to .gitignore guidance
# ---------------------------------------------------------------------------

echo ""
if [[ -f "$PROJECT_DIR/.gitignore" ]]; then
  if grep -qF ".ai/conversations/sessions/" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
    warn ".gitignore — already configured"
  else
    info "Consider adding to .gitignore (session files can be noisy):"
    echo "    .ai/conversations/sessions/"
    echo "    .ai/conversations/LOG-archive-*.md"
  fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "============================================"
echo -e "  ${GREEN}Installation complete${NC}"
echo "============================================"
echo ""
echo "  Skill files:  .claude/skills/agent-handoff/"
echo "                .agents/skills/agent-handoff/"
echo "  Context dir:  .ai/"
echo "  Injected into: $INJECTED agent config file(s)"
echo ""
echo "  Next steps:"
echo ""
echo "    1. Open your project in any AI agent"
echo ""
echo "    2. Bootstrap the project context by asking the agent:"
echo ""
echo "         Scan this project and populate the .ai/ context files"
echo "         (PROJECT.md, PATHS.md, PLAN.md) following the templates"
echo "         in .agents/skills/agent-handoff/references/templates.md"
echo ""
echo "       Or in Claude Code, use: /agent-handoff"
echo ""
echo "    3. Done — every agent will now read .ai/ on start and"
echo "       write updates after each task automatically."
echo ""
echo "  To add more agents later, re-run this script."
echo ""
