#!/bin/bash

# Universal Agents Uninstall & Rollback Script
# This script safely removes universal-agents from a project while preserving
# original user files and providing a dry-run preview before deletion.

set -e

DRY_RUN=true
PROJECT_PATH="${PROJECT_PATH:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Help text
show_help() {
    cat << EOF
Universal Agents Uninstall Script

Usage: ./uninstall.sh [OPTIONS]

Options:
  --project PATH    Path to project root (default: current directory)
  --confirm         Actually delete files (dry-run by default)
  --help            Show this help message

Examples:
  # Dry-run preview (default, shows what would be deleted)
  ./uninstall.sh --project /path/to/project

  # Actually uninstall
  ./uninstall.sh --project /path/to/project --confirm

Notes:
  - Dry-run is always performed by default
  - Use --confirm flag to actually delete files
  - Original user files (CLAUDE.md, AGENTS.md, etc.) are preserved
  - Backup directories are automatically skipped
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            PROJECT_PATH="$2"
            shift 2
            ;;
        --confirm)
            DRY_RUN=false
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Verify project path exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Project path does not exist: $PROJECT_PATH${NC}"
    exit 1
fi

# Helper function to safely remove files/directories
safe_remove() {
    local path="$1"
    local full_path="$PROJECT_PATH/$path"

    if [ -e "$full_path" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Would remove: $path"
        else
            rm -rf "$full_path"
            echo -e "${GREEN}[REMOVED]${NC} $path"
        fi
    fi
}

# Helper function to remove block markers from files
remove_markers() {
    local file="$1"
    local full_path="$PROJECT_PATH/$file"

    if [ ! -f "$full_path" ]; then
        return
    fi

    if grep -q "<!-- universal-agents-begin -->" "$full_path" 2>/dev/null; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY-RUN]${NC} Would clean markers from: $file"
        else
            # Create backup
            cp "$full_path" "$full_path.backup"

            # Remove marker blocks using sed
            sed -i.bak '/<!-- universal-agents-begin -->/,/<!-- universal-agents-end -->/d' "$full_path"
            rm -f "$full_path.bak"

            echo -e "${GREEN}[CLEANED]${NC} Removed markers from: $file (backup: $file.backup)"
        fi
    fi
}

echo -e "${BLUE}===== Universal Agents Uninstall Script =====${NC}"
echo ""
echo -e "Project Path: ${BLUE}$PROJECT_PATH${NC}"
echo -e "Mode: $([ "$DRY_RUN" = true ] && echo -e "${YELLOW}DRY-RUN${NC} (preview only)" || echo -e "${RED}CONFIRM${NC} (will delete)")"
echo ""

# Step 1: Remove marker blocks from tool-specific config files
echo -e "${BLUE}Step 1: Cleaning marker blocks from tool configs${NC}"
remove_markers ".claude/claude.md"
remove_markers ".codex/AGENTS.md"
remove_markers ".github/copilot-instructions.md"
remove_markers ".cursor/rules/universal-agents.mdc"
remove_markers ".gemini/agents.md"
echo ""

# Step 2: Remove tool-specific files that were added
echo -e "${BLUE}Step 2: Removing tool-specific agent files${NC}"
safe_remove ".github/agents/universal-agents.agent.md"
safe_remove ".claude/universal-agents.agent.md"
safe_remove ".codex/universal-agents.agent.md"
safe_remove ".cursor/rules/universal-agents.mdc"
safe_remove ".gemini/universal-agents.agent.md"
echo ""

# Step 3: Remove agents directory
echo -e "${BLUE}Step 3: Removing agents directory${NC}"
safe_remove "agents"
echo ""

# Step 4: Remove backup directory if it exists
echo -e "${BLUE}Step 4: Removing backup directory${NC}"
safe_remove ".universal-agents-backup"
echo ""

# Step 5: Information about preserved files
echo -e "${BLUE}Step 5: Files preserved (not removed)${NC}"
for file in "AGENTS.md" "CLAUDE.md" "GEMINI.md" "README.md"; do
    full_path="$PROJECT_PATH/$file"
    if [ -f "$full_path" ]; then
        echo -e "${GREEN}[PRESERVED]${NC} $file (original user file)"
    fi
done
echo ""

# Summary
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}=== DRY-RUN PREVIEW ===${NC}"
    echo ""
    echo "This is a preview of what would be deleted. To actually uninstall, run:"
    echo ""
    echo -e "${BLUE}./uninstall.sh --project $PROJECT_PATH --confirm${NC}"
    echo ""
else
    echo -e "${GREEN}=== UNINSTALL COMPLETE ===${NC}"
    echo ""
    echo "Universal Agents have been successfully removed from your project."
    echo "Your original configuration files have been preserved."
    echo ""
fi
