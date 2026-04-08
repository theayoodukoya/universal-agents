#!/bin/bash
# ============================================================
# Universal Agents — Merge-Safe Installer
# ============================================================
# Safely installs 122 AI agents into any project WITHOUT
# overwriting existing CLAUDE.md, AGENTS.md, GEMINI.md,
# .github/copilot-instructions.md, or any other configs.
#
# Merge strategy:
#   --merge (default)   Append agent instructions to existing files
#   --replace           Overwrite existing files (backs up first)
#   --skip              Skip any file that already exists
#   --dry-run           Show what would happen without changing anything
#
# Supports: Codex, GitHub Copilot, Claude Code/CLI, Gemini CLI,
#           Gemini Code Assist, Cursor, Antigravity, OpenCode
# ============================================================

set -e

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ---- Config ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SRC="${SCRIPT_DIR}/agents"
PROJECT_DIR=""
MODE="merge"        # merge | replace | skip
DRY_RUN=false
BACKUP_DIR=""
FILES_CREATED=0
FILES_MERGED=0
FILES_SKIPPED=0
FILES_BACKED_UP=0

# ---- Helpers ----
info()    { echo -e "  ${BLUE}ℹ${NC} $1"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
error()   { echo -e "  ${RED}✗${NC} $1"; }
dry()     { echo -e "  ${DIM}[dry-run]${NC} $1"; }

show_help() {
  cat << 'EOF'
Usage: ./install.sh [OPTIONS] [PROJECT_PATH]

OPTIONS:
  --merge     (default) Append agent config to existing files; create if missing
  --replace   Overwrite existing files (auto-backs up to .backup/)
  --skip      Skip any file that already exists
  --dry-run   Preview what would happen without making changes
  --help      Show this help

EXAMPLES:
  ./install.sh                           # Merge into current directory
  ./install.sh --target ~/code/myapp      # Merge into specific project
  ./install.sh --project ~/code/myapp    # Same as --target
  ./install.sh --skip ~/code/myapp       # Only add missing files
  ./install.sh --replace ~/code/myapp    # Full overwrite (backs up first)
  ./install.sh --dry-run ~/code/myapp    # Preview without changes

MERGE STRATEGY:
  When your project already has CLAUDE.md, AGENTS.md, GEMINI.md, etc.,
  the installer uses smart merging:

  CLAUDE.md / GEMINI.md / AGENTS.md:
    → Appends a "## Universal Agents" section to the END of the file
    → Your existing instructions stay untouched at the top
    → The agent system is additive, not destructive

  .github/copilot-instructions.md:
    → Appends agent reference section to the end
    → Your existing Copilot instructions remain intact

  .github/agents/*.agent.md:
    → Adds the universal-agents.agent.md router alongside existing agents
    → Never touches your existing custom agents

  .cursor/rules/*.mdc:
    → Adds agents.mdc alongside existing rules
    → Never touches your existing cursor rules

  .claude/settings.json:
    → SKIPPED if exists (JSON merging is fragile)
    → Prints instructions for manual merge

  .codex/config.toml:
    → SKIPPED if exists (TOML merging is fragile)
    → Prints instructions for manual merge

  agents/*.md:
    → Copies agent files into agents/ directory
    → Skips any agent that already exists with same filename
    → Never overwrites your custom agents
EOF
  exit 0
}

# ---- Parse args ----
while [[ $# -gt 0 ]]; do
  case $1 in
    --merge)     MODE="merge"; shift ;;
    --replace)   MODE="replace"; shift ;;
    --skip)      MODE="skip"; shift ;;
    --dry-run)   DRY_RUN=true; shift ;;
    --project|-p|--target) PROJECT_DIR="$2"; shift 2 ;;
    --help|-h)   show_help ;;
    -*)          error "Unknown option: $1"; show_help ;;
    *)           PROJECT_DIR="$1"; shift ;;
  esac
done

[ -z "$PROJECT_DIR" ] && PROJECT_DIR="$(pwd)"
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd || echo "$PROJECT_DIR")"

if [ ! -d "$PROJECT_DIR" ]; then
  error "Directory does not exist: $PROJECT_DIR"
  exit 1
fi

BACKUP_DIR="${PROJECT_DIR}/.universal-agents-backup/$(date +%Y%m%d-%H%M%S)"

# ============================================================
# CORE: Safe file operations
# ============================================================

# backup_file <path>
# Creates a timestamped backup before any modification
backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    if $DRY_RUN; then
      dry "Would back up: $(basename "$file")"
      return
    fi
    mkdir -p "$BACKUP_DIR"
    local rel_path="${file#$PROJECT_DIR/}"
    local backup_path="${BACKUP_DIR}/${rel_path}"
    mkdir -p "$(dirname "$backup_path")"
    cp "$file" "$backup_path"
    FILES_BACKED_UP=$((FILES_BACKED_UP + 1))
  fi
}

# install_file <source> <destination>
# Copies a file only if destination doesn't exist
install_new_file() {
  local src="$1" dst="$2" label="$3"
  if [ -f "$dst" ]; then
    return 1  # File exists
  fi
  if $DRY_RUN; then
    dry "Would create: ${label:-$(basename "$dst")}"
    FILES_CREATED=$((FILES_CREATED + 1))
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  FILES_CREATED=$((FILES_CREATED + 1))
  success "Created: ${label:-$(basename "$dst")}"
  return 0
}

# merge_markdown <source> <destination> <section_header>
# Appends content from source to destination under a header,
# but only if the section doesn't already exist
merge_markdown() {
  local src="$1" dst="$2" header="$3" label="$4"

  # If destination doesn't exist, just copy
  if [ ! -f "$dst" ]; then
    install_new_file "$src" "$dst" "$label"
    return
  fi

  # Check if already merged (look for our marker)
  if grep -q "<!-- universal-agents-begin -->" "$dst" 2>/dev/null; then
    if $DRY_RUN; then
      dry "Already merged: ${label:-$(basename "$dst")} (skip)"
    else
      info "Already merged: ${label:-$(basename "$dst")} — skipping"
    fi
    FILES_SKIPPED=$((FILES_SKIPPED + 1))
    return
  fi

  case "$MODE" in
    merge)
      if $DRY_RUN; then
        dry "Would merge into existing: ${label:-$(basename "$dst")}"
        FILES_MERGED=$((FILES_MERGED + 1))
        return
      fi
      backup_file "$dst"
      # Append with clear section markers
      cat >> "$dst" << MERGE_EOF

<!-- universal-agents-begin -->
---

${header}

$(cat "$src")

<!-- universal-agents-end -->
MERGE_EOF
      FILES_MERGED=$((FILES_MERGED + 1))
      success "Merged into existing: ${label:-$(basename "$dst")}"
      ;;
    replace)
      if $DRY_RUN; then
        dry "Would replace: ${label:-$(basename "$dst")} (backup first)"
        FILES_CREATED=$((FILES_CREATED + 1))
        return
      fi
      backup_file "$dst"
      cp "$src" "$dst"
      FILES_CREATED=$((FILES_CREATED + 1))
      success "Replaced: ${label:-$(basename "$dst")} (backup saved)"
      ;;
    skip)
      if $DRY_RUN; then
        dry "Would skip (exists): ${label:-$(basename "$dst")}"
      else
        info "Skipped (exists): ${label:-$(basename "$dst")}"
      fi
      FILES_SKIPPED=$((FILES_SKIPPED + 1))
      ;;
  esac
}

# install_config_file <source> <destination> <label>
# For non-mergeable files (JSON, TOML) — skip if exists, with guidance
install_config_file() {
  local src="$1" dst="$2" label="$3"

  if [ ! -f "$dst" ]; then
    install_new_file "$src" "$dst" "$label"
    return
  fi

  case "$MODE" in
    merge|skip)
      if $DRY_RUN; then
        dry "Would skip config (exists): ${label}"
      else
        info "Skipped: ${label} (already exists — manual merge recommended)"
        info "  Reference config: ${src}"
      fi
      FILES_SKIPPED=$((FILES_SKIPPED + 1))
      ;;
    replace)
      if $DRY_RUN; then
        dry "Would replace: ${label} (backup first)"
        return
      fi
      backup_file "$dst"
      cp "$src" "$dst"
      FILES_CREATED=$((FILES_CREATED + 1))
      success "Replaced: ${label} (backup saved)"
      ;;
  esac
}

# install_alongside <source> <destination> <label>
# For files that go alongside existing ones (don't conflict)
install_alongside() {
  local src="$1" dst="$2" label="$3"
  if [ -f "$dst" ]; then
    case "$MODE" in
      merge)
        if $DRY_RUN; then
          dry "Would update: ${label}"
        else
          backup_file "$dst"
          cp "$src" "$dst"
          success "Updated: ${label}"
        fi
        FILES_MERGED=$((FILES_MERGED + 1))
        ;;
      replace)
        if $DRY_RUN; then
          dry "Would replace: ${label}"
        else
          backup_file "$dst"
          cp "$src" "$dst"
          success "Replaced: ${label}"
        fi
        FILES_CREATED=$((FILES_CREATED + 1))
        ;;
      skip)
        if $DRY_RUN; then dry "Would skip: ${label}"; else info "Skipped: ${label}"; fi
        FILES_SKIPPED=$((FILES_SKIPPED + 1))
        ;;
    esac
  else
    install_new_file "$src" "$dst" "$label"
  fi
}

# ============================================================
# MAIN
# ============================================================

echo -e "${BOLD}${BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║    Universal Agents — Merge-Safe Installer v2.0      ║"
echo "║    122 specialized AI coding agents                   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  Target:  ${BOLD}${PROJECT_DIR}${NC}"
echo -e "  Mode:    ${BOLD}${MODE}${NC}"
$DRY_RUN && echo -e "  ${YELLOW}DRY RUN — no files will be modified${NC}"
echo ""

# ---- Detect existing configs ----
echo -e "${YELLOW}[1/7]${NC} Scanning for existing configurations...\n"

EXISTING=()
for f in AGENTS.md CLAUDE.md GEMINI.md .github/copilot-instructions.md .cursor/rules .claude/settings.json .codex/config.toml; do
  if [ -e "${PROJECT_DIR}/${f}" ]; then
    EXISTING+=("$f")
    warn "Found existing: ${f}"
  fi
done

if [ ${#EXISTING[@]} -eq 0 ]; then
  success "No existing configs found — clean install"
else
  echo ""
  info "${#EXISTING[@]} existing config(s) detected. Mode '${MODE}' will be used."
  if [ "$MODE" = "merge" ]; then
    info "Your existing instructions will be preserved. Agent config will be appended."
  fi
fi
echo ""

# ---- Step 2: Install agent files ----
echo -e "${YELLOW}[2/7]${NC} Installing agent files...\n"

if $DRY_RUN; then
  dry "Would create agents/ directory and copy agent .md files"
else
  mkdir -p "${PROJECT_DIR}/agents"
fi

AGENT_NEW=0
AGENT_SKIP=0
for agent_file in "${AGENTS_SRC}"/*.md; do
  agent_name=$(basename "$agent_file")
  dst="${PROJECT_DIR}/agents/${agent_name}"
  if [ -f "$dst" ]; then
    # Agent already exists — never overwrite custom agents
    AGENT_SKIP=$((AGENT_SKIP + 1))
  else
    if ! $DRY_RUN; then
      cp "$agent_file" "$dst"
    fi
    AGENT_NEW=$((AGENT_NEW + 1))
  fi
done

AGENT_TOTAL=$(ls "${AGENTS_SRC}"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$AGENT_SKIP" -gt 0 ]; then
  success "${AGENT_NEW} new agents installed, ${AGENT_SKIP} existing agents preserved"
else
  success "${AGENT_NEW} agents installed to ./agents/"
fi
echo ""

# ---- Step 3: Install universal configs (merge-safe) ----
echo -e "${YELLOW}[3/7]${NC} Installing tool configurations (merge-safe)...\n"

# AGENTS.md — universal entry point (Codex, Antigravity, OpenCode)
merge_markdown \
  "${SCRIPT_DIR}/AGENTS.md" \
  "${PROJECT_DIR}/AGENTS.md" \
  "## Universal Agents (auto-installed)" \
  "AGENTS.md (Codex, Antigravity, OpenCode)"

# CLAUDE.md — Claude Code / CLI
merge_markdown \
  "${SCRIPT_DIR}/CLAUDE.md" \
  "${PROJECT_DIR}/CLAUDE.md" \
  "## Universal Agents System (auto-installed)" \
  "CLAUDE.md (Claude Code/CLI)"

# GEMINI.md — Gemini CLI / Code Assist
merge_markdown \
  "${SCRIPT_DIR}/GEMINI.md" \
  "${PROJECT_DIR}/GEMINI.md" \
  "## Universal Agents System (auto-installed)" \
  "GEMINI.md (Gemini CLI/Code Assist)"

# .github/copilot-instructions.md — GitHub Copilot
mkdir -p "${PROJECT_DIR}/.github" 2>/dev/null || true
merge_markdown \
  "${SCRIPT_DIR}/.github/copilot-instructions.md" \
  "${PROJECT_DIR}/.github/copilot-instructions.md" \
  "## Universal Agents System (auto-installed)" \
  ".github/copilot-instructions.md (GitHub Copilot)"

# .github/agents/universal-agents.agent.md — Copilot Custom Agent (goes alongside)
mkdir -p "${PROJECT_DIR}/.github/agents" 2>/dev/null || true
install_alongside \
  "${SCRIPT_DIR}/.github/agents/universal-agents.agent.md" \
  "${PROJECT_DIR}/.github/agents/universal-agents.agent.md" \
  ".github/agents/universal-agents.agent.md (Copilot Custom Agent)"

# .cursor/rules/agents.mdc — Cursor (goes alongside existing rules)
mkdir -p "${PROJECT_DIR}/.cursor/rules" 2>/dev/null || true
install_alongside \
  "${SCRIPT_DIR}/.cursor/rules/agents.mdc" \
  "${PROJECT_DIR}/.cursor/rules/agents.mdc" \
  ".cursor/rules/agents.mdc (Cursor)"

# .claude/settings.json — skip if exists (JSON is not safely mergeable)
mkdir -p "${PROJECT_DIR}/.claude/agents" 2>/dev/null || true
install_config_file \
  "${SCRIPT_DIR}/.claude/settings.json" \
  "${PROJECT_DIR}/.claude/settings.json" \
  ".claude/settings.json"

# .claude/agents/ — Claude Code extension auto-dispatch router
if [ -f "${SCRIPT_DIR}/.claude/agents/universal-agents.md" ]; then
  if [ ! -f "${PROJECT_DIR}/.claude/agents/universal-agents.md" ] || [ "$MODE" = "replace" ]; then
    if ! $DRY_RUN; then
      cp "${SCRIPT_DIR}/.claude/agents/universal-agents.md" "${PROJECT_DIR}/.claude/agents/universal-agents.md"
    fi
    success ".claude/agents/universal-agents.md (Claude Code extension auto-dispatch)"
    FILES_CREATED=$((FILES_CREATED + 1))
  else
    info ".claude/agents/universal-agents.md already exists (skipped)"
    FILES_SKIPPED=$((FILES_SKIPPED + 1))
  fi
fi

# .codex/config.toml — skip if exists (TOML is not safely mergeable)
mkdir -p "${PROJECT_DIR}/.codex" 2>/dev/null || true
install_config_file \
  "${SCRIPT_DIR}/.codex/config.toml" \
  "${PROJECT_DIR}/.codex/config.toml" \
  ".codex/config.toml"

echo ""

# ---- Step 4: Install discovery & maintenance tools ----
echo -e "${YELLOW}[4/7]${NC} Installing agent discovery & maintenance tools...\n"

# Agent picker (fuzzy search) — Mac/Linux
if [ -f "${SCRIPT_DIR}/agent-pick.sh" ]; then
  install_alongside \
    "${SCRIPT_DIR}/agent-pick.sh" \
    "${PROJECT_DIR}/agent-pick.sh" \
    "agent-pick.sh (fuzzy agent search — Mac/Linux)"
  if ! $DRY_RUN && [ -f "${PROJECT_DIR}/agent-pick.sh" ]; then
    chmod +x "${PROJECT_DIR}/agent-pick.sh"
  fi
fi

# Agent picker fzf preview helper
if [ -f "${SCRIPT_DIR}/agent-pick-fzf-preview.sh" ]; then
  install_alongside \
    "${SCRIPT_DIR}/agent-pick-fzf-preview.sh" \
    "${PROJECT_DIR}/agent-pick-fzf-preview.sh" \
    "agent-pick-fzf-preview.sh (fzf preview helper)"
  if ! $DRY_RUN && [ -f "${PROJECT_DIR}/agent-pick-fzf-preview.sh" ]; then
    chmod +x "${PROJECT_DIR}/agent-pick-fzf-preview.sh"
  fi
fi

# Agent picker — Windows PowerShell
if [ -f "${SCRIPT_DIR}/agent-pick.ps1" ]; then
  install_alongside \
    "${SCRIPT_DIR}/agent-pick.ps1" \
    "${PROJECT_DIR}/agent-pick.ps1" \
    "agent-pick.ps1 (fuzzy agent search — Windows)"
fi

# Validation script
if [ -f "${SCRIPT_DIR}/validate.sh" ]; then
  install_alongside \
    "${SCRIPT_DIR}/validate.sh" \
    "${PROJECT_DIR}/validate.sh" \
    "validate.sh (agent system health check)"
  if ! $DRY_RUN && [ -f "${PROJECT_DIR}/validate.sh" ]; then
    chmod +x "${PROJECT_DIR}/validate.sh"
  fi
fi

# Uninstall script
if [ -f "${SCRIPT_DIR}/uninstall.sh" ]; then
  install_alongside \
    "${SCRIPT_DIR}/uninstall.sh" \
    "${PROJECT_DIR}/uninstall.sh" \
    "uninstall.sh (clean removal)"
  if ! $DRY_RUN && [ -f "${PROJECT_DIR}/uninstall.sh" ]; then
    chmod +x "${PROJECT_DIR}/uninstall.sh"
  fi
fi

# VSCode snippets (agent autocomplete in editor)
if [ -f "${SCRIPT_DIR}/.vscode/agents.code-snippets" ]; then
  mkdir -p "${PROJECT_DIR}/.vscode" 2>/dev/null || true
  install_alongside \
    "${SCRIPT_DIR}/.vscode/agents.code-snippets" \
    "${PROJECT_DIR}/.vscode/agents.code-snippets" \
    ".vscode/agents.code-snippets (editor autocomplete)"
fi

# Shell completions
if [ -d "${SCRIPT_DIR}/completions" ]; then
  mkdir -p "${PROJECT_DIR}/completions" 2>/dev/null || true
  for comp_file in "${SCRIPT_DIR}/completions"/*; do
    [ -f "$comp_file" ] || continue
    comp_name=$(basename "$comp_file")
    install_alongside \
      "$comp_file" \
      "${PROJECT_DIR}/completions/${comp_name}" \
      "completions/${comp_name}"
  done
fi

# CONTRIBUTING guide
if [ -f "${SCRIPT_DIR}/CONTRIBUTING.md" ]; then
  install_alongside \
    "${SCRIPT_DIR}/CONTRIBUTING.md" \
    "${PROJECT_DIR}/CONTRIBUTING.md" \
    "CONTRIBUTING.md (how to add/modify agents)"
fi

echo ""

# ---- Step 5: Global configs ----
echo -e "${YELLOW}[5/7]${NC} Global configurations...\n"

# Codex global AGENTS.md
if command -v codex &>/dev/null || [ -d "$HOME/.codex" ]; then
  if [ ! -f "$HOME/.codex/AGENTS.md" ]; then
    if ! $DRY_RUN; then
      mkdir -p "$HOME/.codex"
      cp "${SCRIPT_DIR}/AGENTS.md" "$HOME/.codex/AGENTS.md"
    fi
    success "Codex global: ~/.codex/AGENTS.md installed"
  else
    info "Codex global: ~/.codex/AGENTS.md already exists (skipped)"
  fi
else
  info "Codex not detected — skipping global config"
fi
echo ""

# ---- Step 6: Update .gitignore ----
echo -e "${YELLOW}[6/7]${NC} Updating .gitignore...\n"

GITIGNORE="${PROJECT_DIR}/.gitignore"
GITIGNORE_ENTRIES="
# Universal Agents — auto-added by installer
# Agent files and tool configs that are installed per-developer.
# These do NOT need to be committed to your repo.
agents/
agents-manifest.json
completions/
.codex/
.cursor/rules/agents.mdc
.vscode/agents.code-snippets
.universal-agents-backup/
agent-pick.sh
agent-pick.ps1
agent-pick-fzf-preview.sh
validate.sh
uninstall.sh
AGENTS.md
CLAUDE.md
GEMINI.md
CONTRIBUTING.md

# NOTE: These are NOT gitignored because the tools need them committed:
# .github/agents/  — GitHub Copilot requires this on the default branch
# .claude/agents/  — Claude Code extension reads agents from here
"

MARKER_START="# >>> universal-agents-gitignore"
MARKER_END="# <<< universal-agents-gitignore"

if [ -f "$GITIGNORE" ]; then
  if grep -q "$MARKER_START" "$GITIGNORE"; then
    info ".gitignore already has universal-agents entries (skipped)"
  else
    if ! $DRY_RUN; then
      printf "\n%s\n%s\n%s\n" "$MARKER_START" "$GITIGNORE_ENTRIES" "$MARKER_END" >> "$GITIGNORE"
    fi
    success ".gitignore updated (appended agent entries)"
    FILES_MERGED=$((FILES_MERGED + 1))
  fi
else
  if ! $DRY_RUN; then
    printf "%s\n%s\n%s\n" "$MARKER_START" "$GITIGNORE_ENTRIES" "$MARKER_END" > "$GITIGNORE"
  fi
  success ".gitignore created with agent entries"
  FILES_CREATED=$((FILES_CREATED + 1))
fi

echo -e "  ${DIM}Note: All agent-related files are gitignored by default.${NC}"
echo -e "  ${DIM}Edit .gitignore to un-ignore any file you want to share with your team.${NC}"
echo ""

# ---- Step 7: Summary ----
echo -e "${YELLOW}[7/7]${NC} Summary\n"

TOTAL_OPS=$((FILES_CREATED + FILES_MERGED + FILES_SKIPPED))

echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════╗"
echo "║              Installation Complete!                   ║"
echo -e "╚══════════════════════════════════════════════════════╝${NC}\n"

echo -e "  ${GREEN}Created:${NC}    ${FILES_CREATED} new files"
echo -e "  ${BLUE}Merged:${NC}     ${FILES_MERGED} files (appended to existing)"
echo -e "  ${YELLOW}Skipped:${NC}    ${FILES_SKIPPED} files (already exist)"
echo -e "  ${DIM}Backed up:${NC}  ${FILES_BACKED_UP} files"
[ "$FILES_BACKED_UP" -gt 0 ] && echo -e "  ${DIM}Backups at:${NC} ${BACKUP_DIR}"

echo -e "\n${BOLD}Agents:${NC} ${AGENT_NEW} new + ${AGENT_SKIP} existing = ${AGENT_TOTAL} total available"

[ -f "${PROJECT_DIR}/agent-pick.sh" ] && echo -e "  🔍 agent-pick.sh (find agents by name, category, or keyword)"
[ -f "${PROJECT_DIR}/agent-pick.ps1" ] && echo -e "  🔍 agent-pick.ps1 (Windows agent finder)"
[ -f "${PROJECT_DIR}/validate.sh" ] && echo -e "  ✅ validate.sh (check agent system health)"
[ -f "${PROJECT_DIR}/uninstall.sh" ] && echo -e "  🗑️  uninstall.sh (clean removal)"
[ -d "${PROJECT_DIR}/.vscode" ] && echo -e "  📝 .vscode/agents.code-snippets (editor autocomplete)"

echo -e "\n${BOLD}Can't remember an agent name? Start here:${NC}"
echo -e "  ${BLUE}./agent-pick.sh${NC}              fuzzy search all 122 agents"
echo -e "  ${BLUE}./agent-pick.sh browse${NC}       browse by category"
echo -e "  ${BLUE}./agent-pick.sh find react${NC}   keyword search"

echo -e "\n${BOLD}Then use the agent in your tool:${NC}"
echo -e "  ${BLUE}Codex:${NC}     codex \"@engineering-nextjs-specialist help with SSR\""
echo -e "  ${BLUE}Copilot:${NC}   @universal-agents in Copilot Chat"
echo -e "  ${BLUE}Claude:${NC}    @engineering-code-reviewer review this PR"
echo -e "  ${BLUE}Gemini:${NC}    @design-figma-to-code-engineer convert this"
echo -e "  ${BLUE}Cursor:${NC}    @engineering-backend-architect in Cursor chat"

if [ "$FILES_MERGED" -gt 0 ]; then
  echo -e "\n${BOLD}${YELLOW}Merge notes:${NC}"
  echo -e "  Your existing configs were preserved. Agent instructions were"
  echo -e "  appended between <!-- universal-agents-begin/end --> markers."
  echo -e "  To remove: delete content between those markers."
  echo -e "  To update: re-run installer (it detects existing markers and skips)."
fi

if [ "$FILES_SKIPPED" -gt 0 ] && [ "$MODE" != "skip" ]; then
  echo -e "\n${BOLD}${YELLOW}Config files skipped (manual merge recommended):${NC}"
  [ -f "${PROJECT_DIR}/.claude/settings.json" ] && echo -e "  • .claude/settings.json — add agents directory to your existing config"
  [ -f "${PROJECT_DIR}/.codex/config.toml" ] && echo -e "  • .codex/config.toml — add CLAUDE.md/GEMINI.md to project_doc_fallback_filenames"
fi

echo ""
