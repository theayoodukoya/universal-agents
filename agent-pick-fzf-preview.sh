#!/bin/bash

##############################################################################
# agent-pick-fzf-preview.sh - FZF Preview Helper
# Displays agent details in the fzf preview pane
# Called by fzf with the selected agent name as argument
##############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Get the directory where the agent-pick script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="${SCRIPT_DIR}/agents"

# Extract frontmatter YAML value
get_yaml_value() {
    local file="$1"
    local key="$2"
    grep "^${key}:" "$file" 2>/dev/null | sed "s/^${key}:[[:space:]]*//;s/^['\"]//;s/['\"]$//" | head -1
}

# Main preview function
show_preview() {
    local agent_name="$1"
    local agent_file="${AGENTS_DIR}/${agent_name}.md"

    if [[ ! -f "$agent_file" ]]; then
        echo -e "${RED}Agent not found: $agent_name${NC}"
        return 1
    fi

    local name=$(get_yaml_value "$agent_file" "name")
    local desc=$(get_yaml_value "$agent_file" "description")
    local vibe=$(get_yaml_value "$agent_file" "vibe")
    local emoji=$(get_yaml_value "$agent_file" "emoji")

    # Header
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${MAGENTA}$emoji $name${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # ID
    echo -e "${BOLD}ID:${NC}"
    echo -e "  ${CYAN}$agent_name${NC}"
    echo ""

    # Description (wrapped)
    echo -e "${BOLD}Description:${NC}"
    echo "$desc" | fold -w 70 -s | sed 's/^/  /'
    echo ""

    # Vibe
    echo -e "${BOLD}Vibe:${NC}"
    echo -e "  ${MAGENTA}\"$vibe\"${NC}"
    echo ""

    # Core Mission (first 20 lines after frontmatter)
    echo -e "${BOLD}Core Mission:${NC}"
    echo -e "${DIM}───────────────────────────────────────────────${NC}"

    # Extract content after frontmatter (after the closing ---)
    local in_content=0
    local line_count=0
    while IFS= read -r line; do
        if [[ "$line" == "---" ]]; then
            ((in_content++))
            continue
        fi

        if [[ $in_content -gt 1 ]]; then
            # Skip empty lines at the start
            if [[ -z "$line" && $line_count -eq 0 ]]; then
                continue
            fi

            # Print with indentation
            echo "  $line"

            ((line_count++))
            if [[ $line_count -ge 18 ]]; then
                break
            fi
        fi
    done < "$agent_file"

    echo ""
    echo -e "${DIM}───────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${YELLOW}Press${NC} ${BOLD}Enter${NC} ${YELLOW}to select, or continue browsing...${NC}"
}

# Entry point
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <agent-name>"
    exit 1
fi

show_preview "$1"
