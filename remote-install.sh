#!/usr/bin/env bash
# ╔═══════════════════════════════════════════════════════════════════╗
# ║  Universal Agents — Remote Installer                             ║
# ║  One command to clone + install into your project                ║
# ║                                                                  ║
# ║  Usage:                                                          ║
# ║    curl -fsSL https://raw.githubusercontent.com/OWNER/universal-agents/main/remote-install.sh | bash -s -- /path/to/project ║
# ║                                                                  ║
# ║  Or with options:                                                ║
# ║    curl -fsSL <url> | bash -s -- --target /path/to/project       ║
# ║    curl -fsSL <url> | bash -s -- --replace /path/to/project      ║
# ╚═══════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ---- Configuration ----
# UPDATE THIS to your actual GitHub repo URL
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

# ---- Parse args ----
MODE="merge"
DRY_RUN=""
PROJECT_DIR=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --merge)     MODE="merge"; shift ;;
    --replace)   MODE="replace"; shift ;;
    --skip)      MODE="skip"; shift ;;
    --dry-run)   DRY_RUN="--dry-run"; shift ;;
    --target|--project|-p) PROJECT_DIR="$2"; shift 2 ;;
    --repo)      REPO_URL="$2"; shift 2 ;;
    --branch)    BRANCH="$2"; shift 2 ;;
    --help|-h)
      cat << 'EOF'
Universal Agents — Remote Installer

Usage:
  curl -fsSL <url> | bash -s -- [OPTIONS] [PROJECT_PATH]

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
  # Install into current directory
  curl -fsSL <url> | bash

  # Install into a specific project
  curl -fsSL <url> | bash -s -- ~/code/my-project

  # Dry run first
  curl -fsSL <url> | bash -s -- --dry-run ~/code/my-project

  # Use a fork
  curl -fsSL <url> | bash -s -- --repo https://github.com/you/universal-agents.git ~/code/my-project

Environment Variables:
  UNIVERSAL_AGENTS_REPO     Override the Git repo URL
  UNIVERSAL_AGENTS_BRANCH   Override the branch (default: main)
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
echo -e "${BOLD}Universal Agents — Remote Installer${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

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

# ---- Step 1: Clone ----
info "Cloning universal-agents from ${REPO_URL} (branch: ${BRANCH})..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$CLONE_DIR" 2>/dev/null
ok "Cloned to temporary directory"

# ---- Step 2: Run the real installer ----
info "Running installer → ${PROJECT_DIR}"
echo ""

chmod +x "$CLONE_DIR/install.sh"
"$CLONE_DIR/install.sh" --"$MODE" $DRY_RUN --target "$PROJECT_DIR"

# ---- Done ----
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}${BOLD}Done!${NC} Agents installed into:"
echo -e "  ${BOLD}$PROJECT_DIR${NC}"
echo ""
echo "Quick start:"
echo "  cd $PROJECT_DIR"
echo "  ./agent-pick.sh           # Find an agent"
echo "  @agent-name: your request # Use it in any AI tool"
echo ""
