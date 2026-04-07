#!/bin/bash

##############################################################################
# agent-pick.sh - Interactive AI Agent Picker CLI Tool
# A comprehensive tool for discovering, searching, and selecting from 122 agents
# Works with or without fzf (graceful degradation)
##############################################################################

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="${SCRIPT_DIR}/agents"
PREVIEW_SCRIPT="${SCRIPT_DIR}/agent-pick-fzf-preview.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

##############################################################################
# Utility Functions
##############################################################################

print_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_header() {
    echo -e "${BOLD}${BLUE}$1${NC}"
}

# Copy to clipboard (platform-agnostic)
copy_to_clipboard() {
    local text="$1"
    if command -v pbcopy &> /dev/null; then
        echo -n "$text" | pbcopy
    elif command -v xclip &> /dev/null; then
        echo -n "$text" | xclip -selection clipboard
    elif command -v xsel &> /dev/null; then
        echo -n "$text" | xsel --clipboard --input
    else
        print_error "No clipboard utility found (pbcopy, xclip, or xsel)"
        return 1
    fi
}

# Extract frontmatter YAML value
get_yaml_value() {
    local file="$1"
    local key="$2"
    grep "^${key}:" "$file" 2>/dev/null | sed "s/^${key}:[[:space:]]*//;s/^['\"]//;s/['\"]$//" | head -1
}

# Get agent name from filename
get_agent_name() {
    basename "$1" .md
}

# Check if fzf is installed
has_fzf() {
    command -v fzf &> /dev/null
}

# Infer category from agent name
infer_category() {
    local agent_name="$1"
    local prefix=$(echo "$agent_name" | cut -d'-' -f1)
    case "$prefix" in
        engineering) echo "Engineering" ;;
        design) echo "Design" ;;
        testing) echo "Testing" ;;
        marketing) echo "Marketing" ;;
        product) echo "Product" ;;
        operations) echo "Operations" ;;
        finance) echo "Finance" ;;
        blockchain) echo "Blockchain" ;;
        compliance) echo "Compliance" ;;
        infrastructure) echo "Infrastructure" ;;
        systems) echo "Systems" ;;
        data) echo "Data" ;;
        *) echo "Other" ;;
    esac
}

##############################################################################
# Agent Discovery Functions
##############################################################################

# Get all agent files sorted
get_all_agents() {
    find "$AGENTS_DIR" -maxdepth 1 -name "*.md" -type f | sort
}

# Get count of all agents
count_all_agents() {
    get_all_agents | wc -l
}

# Get agents by category
get_agents_by_category() {
    local target_cat="$1"
    get_all_agents | while read agent_file; do
        local name=$(get_agent_name "$agent_file")
        local category=$(infer_category "$name")
        if [[ "$category" == "$target_cat" ]]; then
            echo "$name"
        fi
    done
}

# Get unique categories
get_categories_with_counts() {
    get_all_agents | while read agent_file; do
        local name=$(get_agent_name "$agent_file")
        infer_category "$name"
    done | sort | uniq -c | awk '{print $2":"$1}' | sort
}

##############################################################################
# Search Functions
##############################################################################

# Fuzzy search (built-in fallback)
builtin_fuzzy_search() {
    local query="$1"
    get_all_agents | while read agent_file; do
        local name=$(get_agent_name "$agent_file")
        local desc=$(get_yaml_value "$agent_file" "description")
        local combined="${name} ${desc}"

        # Simple fuzzy matching: substring match (case-insensitive)
        if [[ "${combined,,}" == *"${query,,}"* ]]; then
            echo "$name"
        fi
    done
}

# Interactive selection from array
select_from_array() {
    local -n items=$1
    local prompt="${2:-Select an option}"

    if [[ ${#items[@]} -eq 0 ]]; then
        print_error "No items to select from"
        return 1
    fi

    # Display items with numbers
    echo ""
    local i=1
    for item in "${items[@]}"; do
        printf "  ${CYAN}%3d${NC}) %s\n" "$i" "$item"
        ((i++))
    done
    echo ""

    # Get user input
    read -p "$(echo -e "${YELLOW}Select an option (1-${#items[@]}):${NC} ")" choice

    # Validate input
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#items[@]} )); then
        echo "${items[$((choice-1))]}"
        return 0
    else
        print_error "Invalid selection"
        return 1
    fi
}

# Fuzzy search with fzf
fzf_search() {
    local query="$1"

    # Build list for fzf
    get_all_agents | while read agent_file; do
        local name=$(get_agent_name "$agent_file")
        local desc=$(get_yaml_value "$agent_file" "description")
        local emoji=$(get_yaml_value "$agent_file" "emoji")
        echo "$emoji $name | ${desc:0:60}..."
    done | fzf \
        --ansi \
        --query="$query" \
        --preview="${PREVIEW_SCRIPT} {2}" \
        --preview-window=right:50% \
        --bind='ctrl-l:preview-page-down,ctrl-h:preview-page-up' \
        --height=50% \
        --reverse \
        --header="Fuzzy search agents (Ctrl+L/H to scroll preview)" | \
        awk '{print $2}'
}

# Keyword search (grep-based)
keyword_search() {
    local query="$1"
    get_all_agents | while read agent_file; do
        local name=$(get_agent_name "$agent_file")
        local content=$(cat "$agent_file")

        # Case-insensitive grep
        if echo "$content" | grep -qi "$query"; then
            echo "$name"
        fi
    done
}

##############################################################################
# Display Functions
##############################################################################

show_agent_info() {
    local agent_name="$1"
    local agent_file="${AGENTS_DIR}/${agent_name}.md"

    if [[ ! -f "$agent_file" ]]; then
        print_error "Agent not found: $agent_name"
        return 1
    fi

    local name=$(get_yaml_value "$agent_file" "name")
    local desc=$(get_yaml_value "$agent_file" "description")
    local vibe=$(get_yaml_value "$agent_file" "vibe")
    local emoji=$(get_yaml_value "$agent_file" "emoji")
    local category=$(infer_category "$agent_name")

    echo ""
    print_header "$emoji $name"
    echo ""
    echo -e "${BOLD}Category:${NC} $category"
    echo -e "${BOLD}ID:${NC} $agent_name"
    echo ""
    echo -e "${BOLD}Description:${NC}"
    echo "  $desc"
    echo ""
    echo -e "${BOLD}Vibe:${NC}"
    echo "  ${MAGENTA}\"$vibe\"${NC}"
    echo ""
    echo -e "${BOLD}Mission (first 30 lines):${NC}"
    echo "---"
    sed -n '/^---$/,/^$/!p' "$agent_file" | head -30 | sed 's/^/  /'
    echo "---"
    echo ""
}

show_agent_selected() {
    local agent_name="$1"
    local agent_file="${AGENTS_DIR}/${agent_name}.md"

    local name=$(get_yaml_value "$agent_file" "name")
    local emoji=$(get_yaml_value "$agent_file" "emoji")

    echo ""
    echo -e "${BOLD}${GREEN}$emoji Selected: ${CYAN}$agent_name${NC}${NC}"
    echo ""

    # Copy to clipboard
    local cmd="@${agent_name}"
    if copy_to_clipboard "$cmd"; then
        print_success "Copied to clipboard! Use with:"
    else
        echo -e "${YELLOW}⚠ Couldn't copy to clipboard. Invocation command:${NC}"
    fi

    echo ""
    echo "  Codex:   ${CYAN}codex \"${cmd} ...\"${NC}"
    echo "  Claude:  ${CYAN}claude \"${cmd} ...\"${NC}"
    echo "  Copilot: ${CYAN}${cmd} in chat${NC}"
    echo "  Gemini:  ${CYAN}gemini \"${cmd} ...\"${NC}"
    echo ""
}

list_all_agents() {
    echo ""
    print_header "All Agents by Category"
    echo ""

    get_categories_with_counts | while IFS=: read -r cat count; do
        echo -e "${BOLD}${MAGENTA}$cat ($count agents)${NC}"
        get_agents_by_category "$cat" | sort | while read agent; do
            local agent_file="${AGENTS_DIR}/${agent}.md"
            local desc=$(get_yaml_value "$agent_file" "description")
            local emoji=$(get_yaml_value "$agent_file" "emoji")
            printf "  ${CYAN}%-40s${NC} %s ${YELLOW}%s${NC}\n" "$agent" "$emoji" "${desc:0:70}..."
        done
        echo ""
    done
}

##############################################################################
# Main Modes
##############################################################################

mode_list() {
    list_all_agents
}

mode_info() {
    local agent_name="$1"
    if [[ -z "$agent_name" ]]; then
        print_error "Usage: $0 info <agent-name>"
        exit 1
    fi

    show_agent_info "$agent_name"
}

mode_find() {
    local query="$1"
    if [[ -z "$query" ]]; then
        print_error "Usage: $0 find <query>"
        exit 1
    fi

    echo ""
    print_header "Search Results for: $query"
    echo ""

    local results=$(keyword_search "$query")
    local count=$(echo "$results" | grep -c . || true)

    if [[ $count -eq 0 ]]; then
        print_error "No agents found matching: $query"
        exit 1
    fi

    echo "$results" | while read agent; do
        local agent_file="${AGENTS_DIR}/${agent}.md"
        local desc=$(get_yaml_value "$agent_file" "description")
        local emoji=$(get_yaml_value "$agent_file" "emoji")
        printf "  ${CYAN}%-40s${NC} %s %s\n" "$agent" "$emoji" "$desc"
    done
    echo ""
}

mode_browse() {
    # Get categories
    echo ""
    print_header "Browse by Category"
    echo ""

    local categories=()
    while IFS=: read -r cat count; do
        categories+=("$cat ($count)")
    done < <(get_categories_with_counts)

    if [[ ${#categories[@]} -eq 0 ]]; then
        print_error "No categories found"
        exit 1
    fi

    # Display categories
    echo ""
    for i in "${!categories[@]}"; do
        printf "  ${CYAN}%3d${NC}) %s\n" "$((i+1))" "${categories[$i]}"
    done
    echo ""

    # Select category
    read -p "$(echo -e "${YELLOW}Select a category (1-${#categories[@]}):${NC} ")" choice
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#categories[@]} )); then
        print_error "Invalid selection"
        exit 1
    fi

    local selected_cat=$(echo "${categories[$((choice-1))]}" | cut -d' ' -f1)

    # Get agents in category
    local agents=()
    while read agent; do
        agents+=("$agent")
    done < <(get_agents_by_category "$selected_cat" | sort)

    echo ""
    print_header "$selected_cat Agents (${#agents[@]})"
    echo ""

    # Display agents with descriptions
    for i in "${!agents[@]}"; do
        local agent="${agents[$i]}"
        local agent_file="${AGENTS_DIR}/${agent}.md"
        local desc=$(get_yaml_value "$agent_file" "description")
        local emoji=$(get_yaml_value "$agent_file" "emoji")
        printf "  ${CYAN}%3d${NC}) ${YELLOW}%s${NC} %s ${BOLD}%s${NC}\n" "$((i+1))" "$emoji" "$agent" "${desc:0:60}..."
    done
    echo ""

    # Select agent
    read -p "$(echo -e "${YELLOW}Select an agent (1-${#agents[@]}):${NC} ")" choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#agents[@]} )); then
        local selected="${agents[$((choice-1))]}"
        show_agent_selected "$selected"
    else
        print_error "Invalid selection"
        exit 1
    fi
}

mode_search() {
    local query="${1:-}"

    echo ""
    print_header "Agent Picker (Fuzzy Search)"

    if has_fzf; then
        print_info "Using fzf for interactive search"
        local selected=$(fzf_search "$query")
        if [[ -z "$selected" ]]; then
            print_error "No agent selected"
            exit 1
        fi
        show_agent_selected "$selected"
    else
        print_info "fzf not installed - using built-in search"
        echo ""

        if [[ -z "$query" ]]; then
            echo "Enter search query (or leave blank to list all):"
            read -p "> " query
        fi

        local agents=()
        if [[ -z "$query" ]]; then
            # Show all agents
            while read agent_file; do
                agents+=("$(get_agent_name "$agent_file")")
            done < <(get_all_agents)
        else
            # Fuzzy search
            while read agent; do
                agents+=("$agent")
            done < <(builtin_fuzzy_search "$query")
        fi

        if [[ ${#agents[@]} -eq 0 ]]; then
            print_error "No agents found"
            exit 1
        fi

        echo ""
        print_header "Matching Agents:"
        echo ""

        local selected=$(select_from_array agents)
        if [[ -z "$selected" ]]; then
            exit 1
        fi

        show_agent_selected "$selected"
    fi
}

##############################################################################
# Help and Main Entry Point
##############################################################################

show_help() {
    cat << EOF
${BOLD}${CYAN}agent-pick.sh${NC} - Interactive AI Agent Picker CLI

${BOLD}USAGE:${NC}
  ./agent-pick.sh [MODE] [OPTIONS]

${BOLD}MODES:${NC}
  ${GREEN}search${NC} [QUERY]       Fuzzy search agents (default mode)
                    If fzf installed: interactive with preview
                    Otherwise: built-in fuzzy search
                    Example: ./agent-pick.sh search react

  ${GREEN}browse${NC}               Browse agents by category
                    Select category → Select agent

  ${GREEN}find${NC} <QUERY>         Non-interactive keyword search
                    Example: ./agent-pick.sh find "nextjs"

  ${GREEN}info${NC} <AGENT-NAME>    Show detailed agent information
                    Example: ./agent-pick.sh info engineering-nextjs-specialist

  ${GREEN}list${NC}                 List all agents grouped by category

  ${GREEN}help${NC}                 Show this help message

${BOLD}EXAMPLES:${NC}
  # Interactive fuzzy search (default)
  ./agent-pick.sh

  # Search for React-related agents
  ./agent-pick.sh search react
  ./agent-pick.sh find react

  # Browse by category
  ./agent-pick.sh browse

  # Show agent details
  ./agent-pick.sh info engineering-nextjs-specialist

  # List all agents
  ./agent-pick.sh list

${BOLD}FEATURES:${NC}
  ✓ 122 specialized AI agents
  ✓ Fuzzy search with fzf preview (if available)
  ✓ Category-based browsing
  ✓ Built-in search fallback (no dependencies)
  ✓ Copy agent reference to clipboard
  ✓ Works on macOS and Linux

${BOLD}CLIPBOARD:${NC}
  Selected agents are copied as '@agent-name' for use with:
  - Codex CLI/VSCode
  - Claude Code/CLI
  - GitHub Copilot
  - Gemini CLI
  - Cursor
  - OpenCode

EOF
}

main() {
    # Check agents directory
    if [[ ! -d "$AGENTS_DIR" ]]; then
        print_error "Agents directory not found: $AGENTS_DIR"
        exit 1
    fi

    # Check if we have any agents
    local agent_count=$(count_all_agents)
    if [[ $agent_count -eq 0 ]]; then
        print_error "No agents found in $AGENTS_DIR"
        exit 1
    fi

    # Default to search mode
    local mode="${1:-search}"
    shift || true

    case "$mode" in
        search)
            mode_search "$@"
            ;;
        browse)
            mode_browse "$@"
            ;;
        find)
            mode_find "$@"
            ;;
        info)
            mode_info "$@"
            ;;
        list)
            mode_list "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown mode: $mode"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
