##############################################################################
# agent-pick.ps1 - Interactive AI Agent Picker CLI Tool (Windows PowerShell)
# A comprehensive tool for discovering, searching, and selecting from 122 agents
##############################################################################

param(
    [string]$Mode = "search",
    [string]$Query = "",
    [switch]$List,
    [switch]$Help
)

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AgentsDir = Join-Path $ScriptDir "agents"

# Colors for output
$colors = @{
    Red      = "Red"
    Green    = "Green"
    Yellow   = "Yellow"
    Blue     = "Blue"
    Cyan     = "Cyan"
    Magenta  = "Magenta"
    White    = "White"
    Gray     = "DarkGray"
}

##############################################################################
# Utility Functions
##############################################################################

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "Error: " -ForegroundColor $colors.Red -NoNewline
    Write-Host $Message
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ " -ForegroundColor $colors.Green -NoNewline
    Write-Host $Message
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ " -ForegroundColor $colors.Cyan -NoNewline
    Write-Host $Message
}

function Write-Header {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $colors.Blue -BackgroundColor $null
}

# Copy to clipboard (Windows)
function Copy-ToClipboard {
    param([string]$Text)

    try {
        $Text | Set-Clipboard -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Extract frontmatter YAML value
function Get-YamlValue {
    param(
        [string]$FilePath,
        [string]$Key
    )

    $content = Get-Content $FilePath -Raw
    # Simple YAML parsing: look for "key: value"
    $pattern = "^${Key}:\s*(.*)$"
    if ($content -match $pattern) {
        $value = $matches[1].Trim().TrimStart('"').TrimEnd('"').TrimStart("'").TrimEnd("'")
        return $value
    }
    return ""
}

# Get agent name from filename
function Get-AgentName {
    param([string]$FilePath)
    [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
}

# Infer category from agent name
function Infer-Category {
    param([string]$AgentName)

    $prefix = $AgentName.Split('-')[0]
    switch ($prefix) {
        "engineering" { return "Engineering" }
        "design" { return "Design" }
        "testing" { return "Testing" }
        "marketing" { return "Marketing" }
        "product" { return "Product" }
        "operations" { return "Operations" }
        "finance" { return "Finance" }
        "blockchain" { return "Blockchain" }
        "compliance" { return "Compliance" }
        "infrastructure" { return "Infrastructure" }
        "systems" { return "Systems" }
        "data" { return "Data" }
        default { return "Other" }
    }
}

##############################################################################
# Agent Discovery Functions
##############################################################################

# Get all agent files sorted
function Get-AllAgents {
    Get-ChildItem (Join-Path $AgentsDir "*.md") -ErrorAction SilentlyContinue |
        Sort-Object Name |
        ForEach-Object { $_.FullName }
}

# Get count of all agents
function Count-AllAgents {
    @(Get-AllAgents).Count
}

# Get agents by category
function Get-AgentsByCategory {
    param([string]$TargetCategory)

    Get-AllAgents | ForEach-Object {
        $name = Get-AgentName $_
        $category = Infer-Category $name
        if ($category -eq $TargetCategory) {
            $name
        }
    }
}

# Get unique categories with counts
function Get-CategoriesWithCounts {
    $categories = @{}

    Get-AllAgents | ForEach-Object {
        $name = Get-AgentName $_
        $category = Infer-Category $name
        if ($categories.ContainsKey($category)) {
            $categories[$category]++
        } else {
            $categories[$category] = 1
        }
    }

    $categories.GetEnumerator() | Sort-Object Name | ForEach-Object {
        "$($_.Key):$($_.Value)"
    }
}

##############################################################################
# Search Functions
##############################################################################

# Fuzzy search (built-in fallback)
function Builtin-FuzzySearch {
    param([string]$SearchQuery)

    Get-AllAgents | ForEach-Object {
        $name = Get-AgentName $_
        $desc = Get-YamlValue $_ "description"
        $combined = "$name $desc".ToLower()

        if ($combined -like "*$($SearchQuery.ToLower())*") {
            $name
        }
    }
}

# Keyword search (content-based)
function Keyword-Search {
    param([string]$SearchQuery)

    Get-AllAgents | ForEach-Object {
        $name = Get-AgentName $_
        $content = Get-Content $_ -Raw

        if ($content -match [regex]::Escape($SearchQuery)) {
            $name
        }
    }
}

# Interactive selection from array
function Select-FromArray {
    param(
        [array]$Items,
        [string]$Prompt = "Select an option"
    )

    if ($Items.Count -eq 0) {
        Write-Error-Custom "No items to select from"
        return $null
    }

    Write-Host ""
    for ($i = 0; $i -lt $Items.Count; $i++) {
        $num = $i + 1
        Write-Host "  " -NoNewline
        Write-Host ("{0:D3}" -f $num) -ForegroundColor $colors.Cyan -NoNewline
        Write-Host ") " -NoNewline
        Write-Host $Items[$i]
    }
    Write-Host ""

    # Get user input
    $choice = Read-Host "Select an option (1-$($Items.Count))"

    # Validate input
    if ($choice -match '^\d+$' -and $choice -ge 1 -and $choice -le $Items.Count) {
        return $Items[$choice - 1]
    } else {
        Write-Error-Custom "Invalid selection"
        return $null
    }
}

##############################################################################
# Display Functions
##############################################################################

function Show-AgentInfo {
    param([string]$AgentName)

    $agentFile = Join-Path $AgentsDir "$AgentName.md"

    if (-not (Test-Path $agentFile -PathType Leaf)) {
        Write-Error-Custom "Agent not found: $AgentName"
        return
    }

    $name = Get-YamlValue $agentFile "name"
    $desc = Get-YamlValue $agentFile "description"
    $vibe = Get-YamlValue $agentFile "vibe"
    $emoji = Get-YamlValue $agentFile "emoji"
    $category = Infer-Category $AgentName

    Write-Host ""
    Write-Host "$emoji $name" -ForegroundColor $colors.Blue
    Write-Host ""
    Write-Host "Category: " -NoNewline -ForegroundColor $colors.White
    Write-Host $category
    Write-Host "ID: " -NoNewline -ForegroundColor $colors.White
    Write-Host $AgentName
    Write-Host ""
    Write-Host "Description:" -ForegroundColor $colors.White
    Write-Host "  $desc"
    Write-Host ""
    Write-Host "Vibe:" -ForegroundColor $colors.White
    Write-Host "  " -NoNewline
    Write-Host "`"$vibe`"" -ForegroundColor $colors.Magenta
    Write-Host ""
    Write-Host "Mission (first 20 lines):" -ForegroundColor $colors.White
    Write-Host "---"

    $content = Get-Content $agentFile -Raw
    $lines = $content -split "`n"
    $inContent = $false
    $lineCount = 0

    foreach ($line in $lines) {
        if ($line -match "^---$") {
            if ($inContent) { break }
            $inContent = $true
            continue
        }

        if ($inContent -and $line.Trim() -ne "") {
            Write-Host "  $line"
            $lineCount++
            if ($lineCount -ge 20) { break }
        }
    }

    Write-Host "---"
    Write-Host ""
}

function Show-AgentSelected {
    param([string]$AgentName)

    $agentFile = Join-Path $AgentsDir "$AgentName.md"
    $name = Get-YamlValue $agentFile "name"
    $emoji = Get-YamlValue $agentFile "emoji"

    Write-Host ""
    Write-Host "$emoji Selected: " -ForegroundColor $colors.Green -NoNewline
    Write-Host $AgentName -ForegroundColor $colors.Cyan
    Write-Host ""

    # Copy to clipboard
    $cmd = "@$AgentName"
    if (Copy-ToClipboard $cmd) {
        Write-Success "Copied to clipboard! Use with:"
    } else {
        Write-Host "⚠ " -ForegroundColor $colors.Yellow -NoNewline
        Write-Host "Couldn't copy to clipboard. Invocation command:"
    }

    Write-Host ""
    Write-Host "  Codex:   " -NoNewline
    Write-Host "codex '$cmd ...'" -ForegroundColor $colors.Cyan
    Write-Host "  Claude:  " -NoNewline
    Write-Host "claude '$cmd ...'" -ForegroundColor $colors.Cyan
    Write-Host "  Copilot: " -NoNewline
    Write-Host "$cmd in chat" -ForegroundColor $colors.Cyan
    Write-Host "  Gemini:  " -NoNewline
    Write-Host "gemini '$cmd ...'" -ForegroundColor $colors.Cyan
    Write-Host ""
}

function List-AllAgents {
    Write-Host ""
    Write-Header "All Agents by Category"
    Write-Host ""

    Get-CategoriesWithCounts | ForEach-Object {
        $cat, $count = $_ -split ":"
        Write-Host "$cat ($count agents)" -ForegroundColor $colors.Magenta
        Get-AgentsByCategory $cat | Sort-Object | ForEach-Object {
            $agentFile = Join-Path $AgentsDir "$_.md"
            $desc = Get-YamlValue $agentFile "description"
            $emoji = Get-YamlValue $agentFile "emoji"

            $agentDisplay = "{0,-40}" -f $_
            $descDisplay = if ($desc.Length -gt 70) { $desc.Substring(0, 70) + "..." } else { $desc }

            Write-Host "  " -NoNewline
            Write-Host $agentDisplay -ForegroundColor $colors.Cyan -NoNewline
            Write-Host " $emoji " -NoNewline
            Write-Host $descDisplay -ForegroundColor $colors.Yellow
        }
        Write-Host ""
    }
}

##############################################################################
# Main Modes
##############################################################################

function Mode-List {
    List-AllAgents
}

function Mode-Info {
    param([string]$AgentName)

    if ([string]::IsNullOrWhiteSpace($AgentName)) {
        Write-Error-Custom "Usage: .\agent-pick.ps1 -Mode info -Query <agent-name>"
        exit 1
    }

    Show-AgentInfo $AgentName
}

function Mode-Find {
    param([string]$SearchQuery)

    if ([string]::IsNullOrWhiteSpace($SearchQuery)) {
        Write-Error-Custom "Usage: .\agent-pick.ps1 -Mode find -Query <query>"
        exit 1
    }

    Write-Host ""
    Write-Header "Search Results for: $SearchQuery"
    Write-Host ""

    $results = @(Keyword-Search $SearchQuery)
    $count = $results.Count

    if ($count -eq 0) {
        Write-Error-Custom "No agents found matching: $SearchQuery"
        exit 1
    }

    $results | ForEach-Object {
        $agentFile = Join-Path $AgentsDir "$_.md"
        $desc = Get-YamlValue $agentFile "description"
        $emoji = Get-YamlValue $agentFile "emoji"

        $agentDisplay = "{0,-40}" -f $_
        Write-Host "  " -NoNewline
        Write-Host $agentDisplay -ForegroundColor $colors.Cyan -NoNewline
        Write-Host " $emoji " -NoNewline
        Write-Host $desc
    }

    Write-Host ""
}

function Mode-Browse {
    Write-Host ""
    Write-Header "Browse by Category"
    Write-Host ""

    $categories = @(Get-CategoriesWithCounts | ForEach-Object { $_ -split ":" | Select-Object -First 1 })

    if ($categories.Count -eq 0) {
        Write-Error-Custom "No categories found"
        exit 1
    }

    Write-Host ""
    for ($i = 0; $i -lt $categories.Count; $i++) {
        $catInfo = $categories[$i]
        $fullInfo = (Get-CategoriesWithCounts | Where-Object { $_ -like "$catInfo*" })[0]
        $parts = $fullInfo -split ":"
        Write-Host "  " -NoNewline
        Write-Host ("{0:D3}" -f ($i + 1)) -ForegroundColor $colors.Cyan -NoNewline
        Write-Host ") " -NoNewline
        Write-Host "$($parts[0]) ($($parts[1]))"
    }
    Write-Host ""

    $choice = Read-Host "Select a category (1-$($categories.Count))"

    if (-not ($choice -match '^\d+$' -and $choice -ge 1 -and $choice -le $categories.Count)) {
        Write-Error-Custom "Invalid selection"
        exit 1
    }

    $selectedCat = $categories[$choice - 1]

    # Get agents in category
    $agents = @(Get-AgentsByCategory $selectedCat | Sort-Object)

    Write-Host ""
    Write-Header "$selectedCat Agents ($($agents.Count))"
    Write-Host ""

    # Display agents with descriptions
    for ($i = 0; $i -lt $agents.Count; $i++) {
        $agent = $agents[$i]
        $agentFile = Join-Path $AgentsDir "$agent.md"
        $desc = Get-YamlValue $agentFile "description"
        $emoji = Get-YamlValue $agentFile "emoji"

        $descDisplay = if ($desc.Length -gt 60) { $desc.Substring(0, 60) + "..." } else { $desc }

        Write-Host "  " -NoNewline
        Write-Host ("{0:D3}" -f ($i + 1)) -ForegroundColor $colors.Cyan -NoNewline
        Write-Host ") " -NoNewline
        Write-Host "$emoji " -NoNewline
        Write-Host $agent -ForegroundColor $colors.Yellow -NoNewline
        Write-Host " $descDisplay"
    }
    Write-Host ""

    $choice = Read-Host "Select an agent (1-$($agents.Count))"

    if ($choice -match '^\d+$' -and $choice -ge 1 -and $choice -le $agents.Count) {
        $selected = $agents[$choice - 1]
        Show-AgentSelected $selected
    } else {
        Write-Error-Custom "Invalid selection"
        exit 1
    }
}

function Mode-Search {
    param([string]$InitialQuery = "")

    Write-Host ""
    Write-Header "Agent Picker (Fuzzy Search)"
    Write-Host ""

    Write-Info "Using built-in search"
    Write-Host ""

    $query = $InitialQuery
    if ([string]::IsNullOrWhiteSpace($query)) {
        $query = Read-Host "Enter search query (or leave blank to list all)"
    }

    $agents = @()
    if ([string]::IsNullOrWhiteSpace($query)) {
        # Show all agents
        $agents = @(Get-AllAgents | ForEach-Object { Get-AgentName $_ })
    } else {
        # Fuzzy search
        $agents = @(Builtin-FuzzySearch $query)
    }

    if ($agents.Count -eq 0) {
        Write-Error-Custom "No agents found"
        exit 1
    }

    Write-Host ""
    Write-Header "Matching Agents:"
    Write-Host ""

    $selected = Select-FromArray $agents

    if ([string]::IsNullOrWhiteSpace($selected)) {
        exit 1
    }

    Show-AgentSelected $selected
}

##############################################################################
# Help
##############################################################################

function Show-Help {
    $helpText = @"
agent-pick.ps1 - Interactive AI Agent Picker CLI

USAGE:
  .\agent-pick.ps1 [MODE] [OPTIONS]

MODES:
  search [QUERY]       Fuzzy search agents (default mode)
                       Example: .\agent-pick.ps1 -Mode search -Query react

  browse               Browse agents by category
                       Select category → Select agent

  find <QUERY>         Non-interactive keyword search
                       Example: .\agent-pick.ps1 -Mode find -Query nextjs

  info <AGENT-NAME>    Show detailed agent information
                       Example: .\agent-pick.ps1 -Mode info -Query engineering-nextjs-specialist

  list                 List all agents grouped by category

  help                 Show this help message

EXAMPLES:
  # Interactive fuzzy search (default)
  .\agent-pick.ps1

  # Search for React-related agents
  .\agent-pick.ps1 -Mode search -Query react
  .\agent-pick.ps1 -Mode find -Query react

  # Browse by category
  .\agent-pick.ps1 -Mode browse

  # Show agent details
  .\agent-pick.ps1 -Mode info -Query engineering-nextjs-specialist

  # List all agents
  .\agent-pick.ps1 -Mode list

FEATURES:
  ✓ 122 specialized AI agents
  ✓ Fuzzy search with filtering
  ✓ Category-based browsing
  ✓ Keyword search across content
  ✓ Copy agent reference to clipboard
  ✓ Works on Windows PowerShell 5.1+ and PowerShell 7+

CLIPBOARD:
  Selected agents are copied as '@agent-name' for use with:
  - Codex CLI/VSCode
  - Claude Code/CLI
  - GitHub Copilot
  - Gemini CLI
  - Cursor
  - OpenCode

"@
    Write-Host $helpText
}

##############################################################################
# Main Entry Point
##############################################################################

# Check agents directory
if (-not (Test-Path $AgentsDir -PathType Container)) {
    Write-Error-Custom "Agents directory not found: $AgentsDir"
    exit 1
}

# Check if we have any agents
$agentCount = Count-AllAgents
if ($agentCount -eq 0) {
    Write-Error-Custom "No agents found in $AgentsDir"
    exit 1
}

# Handle special arguments
if ($Help) {
    Show-Help
    exit 0
}

# Determine mode from positional argument or named parameter
$actualMode = $Mode
if ($actualMode -eq "search" -and -not [string]::IsNullOrWhiteSpace($Query)) {
    # search with query
    Mode-Search $Query
} elseif ($actualMode -eq "search") {
    # search without query (interactive)
    Mode-Search
} elseif ($actualMode -eq "browse") {
    Mode-Browse
} elseif ($actualMode -eq "find") {
    if ([string]::IsNullOrWhiteSpace($Query)) {
        Write-Error-Custom "Usage: .\agent-pick.ps1 -Mode find -Query <query>"
        exit 1
    }
    Mode-Find $Query
} elseif ($actualMode -eq "info") {
    if ([string]::IsNullOrWhiteSpace($Query)) {
        Write-Error-Custom "Usage: .\agent-pick.ps1 -Mode info -Query <agent-name>"
        exit 1
    }
    Mode-Info $Query
} elseif ($actualMode -eq "list") {
    Mode-List
} elseif ($actualMode -eq "help") {
    Show-Help
} else {
    # Default to search mode
    Mode-Search
}
