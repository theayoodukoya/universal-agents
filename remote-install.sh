#!/usr/bin/env bash
# ╔═══════════════════════════════════════════════════════════════════╗
# ║  Universal Agents — Remote Installer / Updater / Uninstaller     ║
# ║                                                                  ║
# ║  Install:   install-agents                                       ║
# ║  Update:    update-agents                                        ║
# ║  Remove:    remove-agents                                        ║
# ╚═══════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ---- Configuration ----
REPO_URL="${UNIVERSAL_AGENTS_REPO:-https://github.com/theayoodukoya/universal-agents.git}"
BRANCH="${UNIVERSAL_AGENTS_BRANCH:-main}"
CLONE_DIR="${TMPDIR:-/tmp}/universal-agents-$$"

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${BLUE}ℹ${NC}  $*"; }
ok()    { echo -e "${GREEN}✓${NC}  $*"; }
warn()  { echo -e "${YELLOW}⚠${NC}  $*"; }
error() { echo -e "${RED}✗${NC}  $*" >&2; }

# ---- Cleanup on exit ----
cleanup() {
  if [ -d "$CLONE_DIR" ]; then
    rm -rf "$CLONE_DIR" 2>/dev/null || true
  fi
}
trap cleanup EXIT

# ---- Detect mode from command name or first arg ----
ACTION="install"
MODE="merge"
DRY_RUN=""
PROJECT_DIR=""

# Check if called as update-agents or remove-agents (via alias)
case "${0##*/}" in
  *update*) ACTION="update" ;;
  *remove*|*uninstall*) ACTION="uninstall" ;;
esac

while [[ $# -gt 0 ]]; do
  case $1 in
    install)     ACTION="install"; shift ;;
    update)      ACTION="update"; shift ;;
    remove|uninstall) ACTION="uninstall"; shift ;;
    --merge)     MODE="merge"; shift ;;
    --replace)   MODE="replace"; shift ;;
    --skip)      MODE="skip"; shift ;;
    --dry-run)   DRY_RUN="--dry-run"; shift ;;
    --target|--project|-p) PROJECT_DIR="$2"; shift 2 ;;
    --repo)      REPO_URL="$2"; shift 2 ;;
    --branch)    BRANCH="$2"; shift 2 ;;
    --help|-h)
      cat << 'EOF'
Universal Agents — Install / Update / Remove

Usage:
  install-agents [PROJECT_PATH]     Install agents into a project
  update-agents  [PROJECT_PATH]     Update agents to latest version
  remove-agents  [PROJECT_PATH]     Remove agents from a project

  Or explicitly:
  curl -fsSL <url> | bash -s -- install [PROJECT_PATH]
  curl -fsSL <url> | bash -s -- update  [PROJECT_PATH]
  curl -fsSL <url> | bash -s -- remove  [PROJECT_PATH]

Options:
  --merge     (default) Merge with existing configs
  --replace   Overwrite existing configs (backs up first)
  --skip      Skip files that already exist
  --dry-run   Preview without making changes
  --target    Path to project (same as positional arg)
  --repo      Override the Git repo URL
  --branch    Override the branch (default: main)
  --help      Show this help

Examples:
  install-agents                          # Install into current directory
  install-agents ~/code/my-project        # Install into specific project
  update-agents                           # Pull latest and re-install
  remove-agents                           # Remove agents from current dir
  install-agents --dry-run                # Preview without changes
EOF
      exit 0
      ;;
    -*)  error "Unknown option: $1"; exit 1 ;;
    *)   PROJECT_DIR="$1"; shift ;;
  esac
done

[ -z "$PROJECT_DIR" ] && PROJECT_DIR="$(pwd)"
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd || echo "$PROJECT_DIR")"

# ---- Preflight checks ----
echo ""
ACTION_LABEL="$(echo "$ACTION" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')"
echo -e "${BOLD}Universal Agents — ${ACTION_LABEL}${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==================================================================
# UNINSTALL
# ==================================================================
if [ "$ACTION" = "uninstall" ]; then
  if [ ! -d "${PROJECT_DIR}/agents" ]; then
    error "No agents found in ${PROJECT_DIR}. Nothing to remove."
    exit 1
  fi

  info "Removing universal agents from: ${PROJECT_DIR}"
  echo ""

  if [ -n "$DRY_RUN" ]; then
    echo -e "${YELLOW}DRY RUN — nothing will be deleted${NC}\n"
  fi

  # Remove agent files and folders
  REMOVED=0
  for item in \
    "agents" \
    "agents-manifest.json" \
    "completions" \
    "agent-pick.sh" \
    "agent-pick.ps1" \
    "agent-pick-fzf-preview.sh" \
    "validate.sh" \
    "uninstall.sh" \
    "AGENTS.md" \
    "CLAUDE.md" \
    "GEMINI.md" \
    "CONTRIBUTING.md" \
    ".claude" \
    ".codex" \
    ".cursor/rules/agents.mdc" \
    ".vscode/agents.code-snippets" \
    ".github/agents/universal-agents.agent.md"
  do
    target="${PROJECT_DIR}/${item}"
    if [ -e "$target" ]; then
      if [ -z "$DRY_RUN" ]; then
        rm -rf "$target"
      fi
      ok "Removed: $item"
      REMOVED=$((REMOVED + 1))
    fi
  done

  # Clean merged content from files with markers
  for file in ".github/copilot-instructions.md"; do
    target="${PROJECT_DIR}/${file}"
    if [ -f "$target" ] && grep -q "<!-- universal-agents-begin -->" "$target" 2>/dev/null; then
      if [ -z "$DRY_RUN" ]; then
        sed -i.bak '/<!-- universal-agents-begin -->/,/<!-- universal-agents-end -->/d' "$target"
        rm -f "${target}.bak"
      fi
      ok "Cleaned merged content from: $file"
      REMOVED=$((REMOVED + 1))
    fi
  done

  # Clean .gitignore markers
  GITIGNORE="${PROJECT_DIR}/.gitignore"
  if [ -f "$GITIGNORE" ] && grep -q ">>> universal-agents-gitignore" "$GITIGNORE" 2>/dev/null; then
    if [ -z "$DRY_RUN" ]; then
      sed -i.bak '/# >>> universal-agents-gitignore/,/# <<< universal-agents-gitignore/d' "$GITIGNORE"
      rm -f "${GITIGNORE}.bak"
    fi
    ok "Cleaned .gitignore entries"
    REMOVED=$((REMOVED + 1))
  fi

  echo ""
  echo -e "${GREEN}${BOLD}Done!${NC} Removed $REMOVED items from ${PROJECT_DIR}"
  exit 0
fi

# ==================================================================
# INSTALL / UPDATE
# ==================================================================
if ! command -v git &>/dev/null; then
  error "git is required but not installed."
  echo "  Install it from https://git-scm.com/downloads"
  exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
  warn "Project directory doesn't exist: $PROJECT_DIR"
  read -rp "Create it? [Y/n] " answer
  if [[ "$answer" =~ ^[Nn] ]]; then
    error "Aborted."
    exit 1
  fi
  mkdir -p "$PROJECT_DIR"
  ok "Created $PROJECT_DIR"
fi

# Clone latest
info "Cloning universal-agents from ${REPO_URL} (branch: ${BRANCH})..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$CLONE_DIR" 2>/dev/null
ok "Cloned to temporary directory"

if [ "$ACTION" = "update" ]; then
  # Update mode: only refresh agent .md files, manifest, and scripts
  # Does NOT re-install tool configs (.cursor, .github, .claude, .vscode, etc.)
  info "Updating agent files and manifest only (tool configs untouched)..."
  echo ""

  if [ -z "$DRY_RUN" ]; then
    # Update agent .md files
    UPDATED=0
    for agent_file in "$CLONE_DIR/agents/"*.md; do
      fname="$(basename "$agent_file")"
      target="${PROJECT_DIR}/agents/${fname}"
      mkdir -p "${PROJECT_DIR}/agents"
      cp "$agent_file" "$target"
      UPDATED=$((UPDATED + 1))
    done
    ok "Updated $UPDATED agent files in agents/"

    # Update manifest
    if [ -f "$CLONE_DIR/agents-manifest.json" ]; then
      cp "$CLONE_DIR/agents-manifest.json" "${PROJECT_DIR}/agents-manifest.json"
      ok "Updated agents-manifest.json"
    fi

    # Update AGENTS.md registry
    if [ -f "$CLONE_DIR/AGENTS.md" ]; then
      cp "$CLONE_DIR/AGENTS.md" "${PROJECT_DIR}/AGENTS.md"
      ok "Updated AGENTS.md"
    fi

    # Update Claude Code extension agent
    if [ -f "$CLONE_DIR/.claude/agents/universal-agents.md" ]; then
      mkdir -p "${PROJECT_DIR}/.claude/agents"
      cp "$CLONE_DIR/.claude/agents/universal-agents.md" "${PROJECT_DIR}/.claude/agents/universal-agents.md"
      ok "Updated .claude/agents/universal-agents.md"
    fi

    # Update Copilot agent
    if [ -f "$CLONE_DIR/.github/agents/universal-agents.agent.md" ]; then
      mkdir -p "${PROJECT_DIR}/.github/agents"
      cp "$CLONE_DIR/.github/agents/universal-agents.agent.md" "${PROJECT_DIR}/.github/agents/universal-agents.agent.md"
      ok "Updated .github/agents/universal-agents.agent.md"
    fi

    # Update scripts
    for script in agent-pick.sh agent-pick.ps1 agent-pick-fzf-preview.sh validate.sh uninstall.sh; do
      if [ -f "$CLONE_DIR/$script" ]; then
        cp "$CLONE_DIR/$script" "${PROJECT_DIR}/$script"
        chmod +x "${PROJECT_DIR}/$script" 2>/dev/null || true
      fi
    done
    ok "Updated scripts"

    # Update completions
    if [ -d "$CLONE_DIR/completions" ]; then
      mkdir -p "${PROJECT_DIR}/completions"
      cp "$CLONE_DIR/completions/"* "${PROJECT_DIR}/completions/" 2>/dev/null || true
      ok "Updated completions"
    fi
  else
    info "[DRY RUN] Would update agent files, manifest, and scripts"
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "${GREEN}${BOLD}Updated!${NC} Agents in ${PROJECT_DIR} are now at the latest version."
  echo -e "${DIM}Tool configs (.cursor, .github, .claude, etc.) were not changed.${NC}"
  echo -e "${DIM}To fully re-install everything, run: install-agents --replace${NC}"
  echo ""
  exit 0
fi

# Run the full installer for fresh installs
info "Running installer → ${PROJECT_DIR}"
echo ""

chmod +x "$CLONE_DIR/install.sh"
"$CLONE_DIR/install.sh" --"$MODE" $DRY_RUN --target "$PROJECT_DIR"

# Done
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}${BOLD}Installed!${NC} Agents ready in ${PROJECT_DIR}"
echo ""
echo "Quick start:"
echo "  cd $PROJECT_DIR"
echo "  ./agent-pick.sh           # Find an agent"
echo "  Just describe your task   # Auto-dispatch picks the right agent"
echo ""
