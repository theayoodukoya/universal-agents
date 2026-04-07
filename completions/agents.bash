#!/bin/bash

# Bash completion for universal-agents system
# Provides completions for agent names across codex, claude, gemini commands
# and subcommands for ./agent-pick.sh

# Get agent names from the filesystem
_get_agents() {
  ls /sessions/nifty-dazzling-allen/mnt/agents/universal-agents/agents/*.md 2>/dev/null | xargs -I{} basename {} .md
}

# Get description for an agent
_get_agent_desc() {
  local agent="$1"
  local file="/sessions/nifty-dazzling-allen/mnt/agents/universal-agents/agents/${agent}.md"
  if [[ -f "$file" ]]; then
    # Extract description from frontmatter
    sed -n '/^description:/s/^description:[[:space:]]*//p' "$file" | head -1
  fi
}

# Completion function for codex, claude, gemini commands
_agents_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Check if we're completing an @ agent reference
  if [[ "$cur" == @* ]]; then
    local prefix="${cur#@}"
    local agents=$(_get_agents)

    COMPREPLY=()
    while IFS= read -r agent; do
      if [[ "$agent" == "$prefix"* ]]; then
        COMPREPLY+=("@$agent")
      fi
    done <<< "$agents"
  fi
}

# Completion function for agent-pick.sh subcommands
_agent_pick_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  # If first argument, complete with subcommands
  if [[ $COMP_CWORD -eq 1 ]]; then
    local subcommands="search browse find info list"
    COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
  # If completing agent name after subcommand
  elif [[ "$cur" == @* || "$cur" == "" ]]; then
    local prefix="${cur#@}"
    local agents=$(_get_agents)

    COMPREPLY=()
    while IFS= read -r agent; do
      if [[ "$agent" == "$prefix"* ]]; then
        COMPREPLY+=("@$agent")
      fi
    done <<< "$agents"
  fi
}

# Register completions
complete -F _agents_complete codex
complete -F _agents_complete claude
complete -F _agents_complete gemini
complete -F _agent_pick_complete ./agent-pick.sh
complete -F _agent_pick_complete agent-pick.sh
