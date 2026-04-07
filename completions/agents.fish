#!/usr/bin/env fish
# Fish completion for universal-agents system
# Provides completions for agent names across codex, claude, gemini commands
# and subcommands for agent-pick

# Get all agent names
function _list_agents
    ls /sessions/nifty-dazzling-allen/mnt/agents/universal-agents/agents/*.md 2>/dev/null | xargs -I{} basename {} .md
end

# Get description for a specific agent
function _get_agent_desc
    set -l agent $argv[1]
    set -l file "/sessions/nifty-dazzling-allen/mnt/agents/universal-agents/agents/$agent.md"
    if test -f $file
        sed -n 's/^description:[[:space:]]*//p' $file | head -1
    end
end

# Register completions for codex command
complete -c codex -f -d "Universal agents"
for agent in (_list_agents)
    set -l desc (_get_agent_desc $agent)
    if test -z $desc
        set desc "Agent"
    end
    # Truncate long descriptions
    if test (string length $desc) -gt 80
        set desc (string sub -l 77 $desc)"..."
    end
    complete -c codex -a "@$agent" -d "$desc"
end

# Register completions for claude command
complete -c claude -f -d "Universal agents"
for agent in (_list_agents)
    set -l desc (_get_agent_desc $agent)
    if test -z $desc
        set desc "Agent"
    end
    if test (string length $desc) -gt 80
        set desc (string sub -l 77 $desc)"..."
    end
    complete -c claude -a "@$agent" -d "$desc"
end

# Register completions for gemini command
complete -c gemini -f -d "Universal agents"
for agent in (_list_agents)
    set -l desc (_get_agent_desc $agent)
    if test -z $desc
        set desc "Agent"
    end
    if test (string length $desc) -gt 80
        set desc (string sub -l 77 $desc)"..."
    end
    complete -c gemini -a "@$agent" -d "$desc"
end

# Register completions for agent-pick subcommands
complete -c agent-pick -n "__fish_use_subcommand_from_list" -f
complete -c agent-pick -f -n "__fish_seen_subcommand_from_list search browse find info list" -a "(_list_agents)" -d "Agent name"

# Subcommands
complete -c agent-pick -f -n "__fish_use_subcommand_from_list" -a 'search' -d 'Search agents by keyword'
complete -c agent-pick -f -n "__fish_use_subcommand_from_list" -a 'browse' -d 'Browse all agents interactively'
complete -c agent-pick -f -n "__fish_use_subcommand_from_list" -a 'find' -d 'Find specific agent by name'
complete -c agent-pick -f -n "__fish_use_subcommand_from_list" -a 'info' -d 'Display agent information'
complete -c agent-pick -f -n "__fish_use_subcommand_from_list" -a 'list' -d 'List all agents'
