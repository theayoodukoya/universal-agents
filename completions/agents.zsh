#compdef codex claude gemini
#compdef agent-pick.sh=agent-pick

# Zsh completion for universal-agents system
# Provides completions for agent names across codex, claude, gemini commands
# and subcommands for agent-pick.sh

# Get all agent names
_list_agents() {
  ls /sessions/nifty-dazzling-allen/mnt/agents/universal-agents/agents/*.md 2>/dev/null | xargs -I{} basename {} .md
}

# Get agent descriptions
_agent_descriptions() {
  local agents=$(_list_agents)
  local -a agent_list
  while IFS= read -r agent; do
    local desc_file="/sessions/nifty-dazzling-allen/mnt/agents/universal-agents/agents/${agent}.md"
    local desc=""
    if [[ -f "$desc_file" ]]; then
      desc=$(sed -n '/^description:/s/^description:[[:space:]]*//p' "$desc_file" | head -1)
    fi
    # Truncate long descriptions
    if [[ ${#desc} -gt 80 ]]; then
      desc="${desc:0:77}..."
    fi
    agent_list+=("@${agent}:${desc}")
  done <<< "$agents"
  echo "${agent_list[@]}"
}

# Main completion function for codex, claude, gemini
_agents_main() {
  local -a args
  args=($(_agent_descriptions))
  _describe 'agents' args
}

# Completion for agent-pick.sh subcommands
_agent_pick_subcommands() {
  local -a subcmds
  subcmds=(
    'search:Search agents by keyword'
    'browse:Browse all agents interactively'
    'find:Find specific agent by name'
    'info:Display agent information'
    'list:List all agents'
  )
  _describe 'subcommand' subcmds
}

# Completion function for agent-pick.sh
_agent_pick() {
  _arguments \
    '1: :_agent_pick_subcommands' \
    '*: :_agents_main'
}

# Register completions for each command
_agents_main
_agent_pick
