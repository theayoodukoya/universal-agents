#!/bin/bash

# Universal Agents Validation Script
# Validates the integrity of the agent system by checking:
# - All agent .md files have valid frontmatter
# - No hardcoded paths
# - AGENTS.md registry matches actual files
# - No model: field in frontmatter

set -e

AGENTS_DIR="./agents"
AGENTS_MD="./AGENTS.md"
EXIT_CODE=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== Universal Agents Validation =====${NC}"
echo ""

# Helper function to print errors
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    EXIT_CODE=1
}

# Helper function to print warnings
warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Helper function to print success
success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

# Check if agents directory exists
if [ ! -d "$AGENTS_DIR" ]; then
    error "Agents directory not found: $AGENTS_DIR"
    exit 1
fi

# Check if AGENTS.md exists
if [ ! -f "$AGENTS_MD" ]; then
    error "AGENTS.md not found"
    exit 1
fi

# ===== Check 1: Valid frontmatter in all agent files =====
echo -e "${BLUE}Check 1: Validating frontmatter in agent files${NC}"
FRONTMATTER_ERRORS=0

for agent_file in "$AGENTS_DIR"/*.md; do
    if [ ! -f "$agent_file" ]; then
        continue
    fi

    agent_name=$(basename "$agent_file" .md)

    # Check if file starts with frontmatter
    if ! head -1 "$agent_file" | grep -q "^---"; then
        error "$agent_name: Missing opening frontmatter delimiter (---)"
        FRONTMATTER_ERRORS=$((FRONTMATTER_ERRORS + 1))
        continue
    fi

    # Extract frontmatter
    frontmatter=$(sed -n '/^---$/,/^---$/p' "$agent_file" | head -n -1)

    # Check required fields
    for required_field in "name" "description" "emoji" "vibe"; do
        if ! echo "$frontmatter" | grep -q "^${required_field}:"; then
            error "$agent_name: Missing required field: $required_field"
            FRONTMATTER_ERRORS=$((FRONTMATTER_ERRORS + 1))
        fi
    done

    # Check for forbidden model: field
    if echo "$frontmatter" | grep -q "^model:"; then
        error "$agent_name: Contains forbidden 'model:' field in frontmatter"
        FRONTMATTER_ERRORS=$((FRONTMATTER_ERRORS + 1))
    fi
done

if [ $FRONTMATTER_ERRORS -eq 0 ]; then
    success "All agent files have valid frontmatter"
else
    error "$FRONTMATTER_ERRORS frontmatter issues found"
fi
echo ""

# ===== Check 2: No hardcoded paths =====
echo -e "${BLUE}Check 2: Checking for hardcoded paths${NC}"
HARDCODED_PATHS=0

for agent_file in "$AGENTS_DIR"/*.md; do
    if [ ! -f "$agent_file" ]; then
        continue
    fi

    agent_name=$(basename "$agent_file" .md)

    # Check for common hardcoded paths
    if grep -q "/Users/" "$agent_file"; then
        error "$agent_name: Contains hardcoded /Users/ path"
        HARDCODED_PATHS=$((HARDCODED_PATHS + 1))
    fi

    if grep -q "/home/" "$agent_file"; then
        error "$agent_name: Contains hardcoded /home/ path"
        HARDCODED_PATHS=$((HARDCODED_PATHS + 1))
    fi

    if grep -q "C:\\\\" "$agent_file"; then
        error "$agent_name: Contains hardcoded Windows path"
        HARDCODED_PATHS=$((HARDCODED_PATHS + 1))
    fi
done

if [ $HARDCODED_PATHS -eq 0 ]; then
    success "No hardcoded paths found"
else
    error "$HARDCODED_PATHS hardcoded paths found"
fi
echo ""

# ===== Check 3: AGENTS.md registry completeness =====
echo -e "${BLUE}Check 3: Verifying AGENTS.md registry${NC}"
REGISTRY_ERRORS=0

# Extract agents listed in AGENTS.md
listed_agents=$(grep -o '\*\*[a-z-]*\*\*' "$AGENTS_MD" | sed 's/\*\*//g' | sort -u)

# Get actual agents on disk
actual_agents=$(ls "$AGENTS_DIR"/*.md | xargs -I{} basename {} .md | sort)

# Check for agents in AGENTS.md but not on disk
for agent in $listed_agents; do
    if ! grep -q "^${agent}\.md\$" <(ls "$AGENTS_DIR"/*.md | xargs -I{} basename {}); then
        # Check if agent file exists at all
        if [ ! -f "$AGENTS_DIR/$agent.md" ]; then
            # Only error if it looks like an agent name (contains hyphen)
            if [[ "$agent" == *"-"* ]]; then
                error "AGENTS.md lists '$agent' but file not found: $AGENTS_DIR/$agent.md"
                REGISTRY_ERRORS=$((REGISTRY_ERRORS + 1))
            fi
        fi
    fi
done

# Check for agents on disk but not in AGENTS.md
for agent_file in "$AGENTS_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    if ! echo "$listed_agents" | grep -q "^${agent_name}\$"; then
        warning "Agent file exists but not listed in AGENTS.md: $agent_name"
    fi
done

if [ $REGISTRY_ERRORS -eq 0 ]; then
    success "AGENTS.md registry is complete and accurate"
else
    error "$REGISTRY_ERRORS registry issues found"
fi
echo ""

# ===== Check 4: Agent count verification =====
echo -e "${BLUE}Check 4: Verifying agent counts${NC}"
AGENT_COUNT=$(ls "$AGENTS_DIR"/*.md 2>/dev/null | wc -l)

# Extract count from AGENTS.md
CLAIMED_COUNT=$(grep "^**Agents Count**:" "$AGENTS_MD" | grep -o '[0-9]\+' | head -1)

if [ -z "$CLAIMED_COUNT" ]; then
    warning "Could not find Agents Count in AGENTS.md"
else
    if [ "$AGENT_COUNT" -eq "$CLAIMED_COUNT" ]; then
        success "Agent count matches: $AGENT_COUNT agents"
    else
        error "Agent count mismatch: AGENTS.md claims $CLAIMED_COUNT but found $AGENT_COUNT actual files"
    fi
fi
echo ""

# ===== Summary =====
echo -e "${BLUE}===== Validation Summary =====${NC}"
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}All validations passed!${NC}"
    echo ""
    echo "The agent system is healthy and ready to use."
    exit 0
else
    echo -e "${RED}Validation failed with errors.${NC}"
    echo ""
    echo "Please fix the issues listed above and run validation again."
    exit 1
fi
