# ============================================================
# Universal Agents - Merge-Safe Installer (Windows PowerShell)
# ============================================================
# Safely installs 122 AI agents into any project WITHOUT
# overwriting existing CLAUDE.md, AGENTS.md, GEMINI.md,
# .github/copilot-instructions.md, or any other configs.
#
# Merge strategy:
#   -Merge (default)   Append agent instructions to existing files
#   -Replace           Overwrite existing files (backs up first)
#   -Skip              Skip any file that already exists
#   -DryRun            Show what would happen without changing anything
#
# Supports: Codex, GitHub Copilot, Claude Code/CLI, Gemini CLI,
#           Gemini Code Assist, Cursor, Antigravity, OpenCode
# ============================================================

param(
    [switch]$Merge = $true,
    [switch]$Replace,
    [switch]$Skip,
    [switch]$DryRun,
    [string]$Project = (Get-Location).Path,
    [switch]$Help
)

# Force the -Merge flag if -Replace or -Skip aren't specified
if ($Replace -or $Skip) {
    $Merge = $false
}

# ---- Colors ----
$colors = @{
    Red     = "Red"
    Green   = "Green"
    Yellow  = "Yellow"
    Blue    = "Cyan"
    Dim     = "DarkGray"
    Bold    = "White"
}

# ---- Functions ----
function Write-Info {
    param([string]$Message)
    Write-Host "  " -NoNewline
    Write-Host "ℹ " -ForegroundColor $colors.Blue -NoNewline
    Write-Host $Message
}

function Write-Success {
    param([string]$Message)
    Write-Host "  " -NoNewline
    Write-Host "✓ " -ForegroundColor $colors.Green -NoNewline
    Write-Host $Message
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  " -NoNewline
    Write-Host "⚠ " -ForegroundColor $colors.Yellow -NoNewline
    Write-Host $Message
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "  " -NoNewline
    Write-Host "✗ " -ForegroundColor $colors.Red -NoNewline
    Write-Host $Message -ForegroundColor $colors.Red
}

function Write-Dry {
    param([string]$Message)
    Write-Host "  " -NoNewline
    Write-Host "[dry-run] " -ForegroundColor $colors.Dim -NoNewline
    Write-Host $Message -ForegroundColor $colors.Dim
}

function Show-Help {
    $help = @"
Usage: .\install.ps1 [OPTIONS] [PROJECT_PATH]

OPTIONS:
  -Merge      (default) Append agent config to existing files; create if missing
  -Replace    Overwrite existing files (auto-backs up to .backup/)
  -Skip       Skip any file that already exists
  -DryRun     Preview what would happen without making changes
  -Project    Specify target project directory
  -Help       Show this help

EXAMPLES:
  .\install.ps1                              # Merge into current directory
  .\install.ps1 -Project C:\code\myapp       # Merge into specific project
  .\install.ps1 -Skip -Project C:\code\myapp # Only add missing files
  .\install.ps1 -Replace -Project C:\code\myapp  # Full overwrite (backs up first)
  .\install.ps1 -DryRun -Project C:\code\myapp   # Preview without changes

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
"@
    Write-Host $help
    exit 0
}

if ($Help) {
    Show-Help
}

# ---- Config ----
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AgentsSrc = Join-Path $ScriptDir "agents"
$ProjectDir = $Project
$Mode = "merge"
if ($Replace) { $Mode = "replace" }
elseif ($Skip) { $Mode = "skip" }

$BackupDir = ""
$FilesCreated = 0
$FilesMerged = 0
$FilesSkipped = 0
$FilesBackedUp = 0

# Validate project directory
if (-not (Test-Path $ProjectDir -PathType Container)) {
    Write-Error-Custom "Directory does not exist: $ProjectDir"
    exit 1
}

# Resolve to absolute path
$ProjectDir = (Resolve-Path $ProjectDir).Path

# Create backup directory with timestamp
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupDir = Join-Path $ProjectDir ".universal-agents-backup" $timestamp

# ---- Core Functions ----

function Backup-File {
    param([string]$Path)

    if ((Test-Path $Path -PathType Leaf)) {
        if ($DryRun) {
            Write-Dry "Would back up: $(Split-Path -Leaf $Path)"
            return
        }

        $relPath = $Path -replace [regex]::Escape($ProjectDir + '\'), ""
        $backupPath = Join-Path $BackupDir $relPath
        $backupPathDir = Split-Path $backupPath

        if (-not (Test-Path $backupPathDir)) {
            New-Item -ItemType Directory -Path $backupPathDir -Force | Out-Null
        }

        Copy-Item $Path $backupPath -Force
        $script:FilesBackedUp++
    }
}

function Install-NewFile {
    param([string]$Source, [string]$Destination, [string]$Label)

    if (Test-Path $Destination -PathType Leaf) {
        return $false  # File exists
    }

    if ($DryRun) {
        if ($Label) {
            Write-Dry "Would create: $Label"
        } else {
            Write-Dry "Would create: $(Split-Path -Leaf $Destination)"
        }
        $script:FilesCreated++
        return $true
    }

    $destDir = Split-Path $Destination
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Copy-Item $Source $Destination -Force
    $script:FilesCreated++

    if ($Label) {
        Write-Success "Created: $Label"
    } else {
        Write-Success "Created: $(Split-Path -Leaf $Destination)"
    }
    return $true
}

function Merge-Markdown {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Header,
        [string]$Label
    )

    # If destination doesn't exist, just copy
    if (-not (Test-Path $Destination -PathType Leaf)) {
        Install-NewFile $Source $Destination $Label
        return
    }

    # Check if already merged
    $content = Get-Content $Destination -Raw
    if ($content -match "<!-- universal-agents-begin -->") {
        if ($DryRun) {
            Write-Dry "Already merged: $(if ($Label) { $Label } else { Split-Path -Leaf $Destination }) (skip)"
        } else {
            Write-Info "Already merged: $(if ($Label) { $Label } else { Split-Path -Leaf $Destination }) — skipping"
        }
        $script:FilesSkipped++
        return
    }

    switch ($Mode) {
        "merge" {
            if ($DryRun) {
                Write-Dry "Would merge into existing: $(if ($Label) { $Label } else { Split-Path -Leaf $Destination })"
                $script:FilesMerged++
                return
            }

            Backup-File $Destination

            $sourceContent = Get-Content $Source -Raw
            $mergeContent = @"

<!-- universal-agents-begin -->
---

$Header

$sourceContent

<!-- universal-agents-end -->
"@

            Add-Content $Destination $mergeContent -Encoding UTF8
            $script:FilesMerged++
            Write-Success "Merged into existing: $(if ($Label) { $Label } else { Split-Path -Leaf $Destination })"
        }
        "replace" {
            if ($DryRun) {
                Write-Dry "Would replace: $(if ($Label) { $Label } else { Split-Path -Leaf $Destination }) (backup first)"
                $script:FilesCreated++
                return
            }

            Backup-File $Destination
            Copy-Item $Source $Destination -Force
            $script:FilesCreated++
            Write-Success "Replaced: $(if ($Label) { $Label } else { Split-Path -Leaf $Destination }) (backup saved)"
        }
        "skip" {
            if ($DryRun) {
                Write-Dry "Would skip (exists): $(if ($Label) { $Label } else { Split-Path -Leaf $Destination })"
            } else {
                Write-Info "Skipped (exists): $(if ($Label) { $Label } else { Split-Path -Leaf $Destination })"
            }
            $script:FilesSkipped++
        }
    }
}

function Install-ConfigFile {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Label
    )

    if (-not (Test-Path $Destination -PathType Leaf)) {
        Install-NewFile $Source $Destination $Label
        return
    }

    switch ($Mode) {
        "merge" {
            if ($DryRun) {
                Write-Dry "Would skip config (exists): $Label"
            } else {
                Write-Info "Skipped: $Label (already exists — manual merge recommended)"
                Write-Info "  Reference config: $Source"
            }
            $script:FilesSkipped++
        }
        "skip" {
            if ($DryRun) {
                Write-Dry "Would skip config (exists): $Label"
            } else {
                Write-Info "Skipped: $Label (already exists — manual merge recommended)"
                Write-Info "  Reference config: $Source"
            }
            $script:FilesSkipped++
        }
        "replace" {
            if ($DryRun) {
                Write-Dry "Would replace: $Label (backup first)"
                return
            }

            Backup-File $Destination
            Copy-Item $Source $Destination -Force
            $script:FilesCreated++
            Write-Success "Replaced: $Label (backup saved)"
        }
    }
}

function Install-Alongside {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Label
    )

    if (Test-Path $Destination -PathType Leaf) {
        switch ($Mode) {
            "merge" {
                if ($DryRun) {
                    Write-Dry "Would update: $Label"
                } else {
                    Backup-File $Destination
                    Copy-Item $Source $Destination -Force
                    Write-Success "Updated: $Label"
                }
                $script:FilesMerged++
            }
            "replace" {
                if ($DryRun) {
                    Write-Dry "Would replace: $Label"
                } else {
                    Backup-File $Destination
                    Copy-Item $Source $Destination -Force
                    Write-Success "Replaced: $Label"
                }
                $script:FilesCreated++
            }
            "skip" {
                if ($DryRun) {
                    Write-Dry "Would skip: $Label"
                } else {
                    Write-Info "Skipped: $Label"
                }
                $script:FilesSkipped++
            }
        }
    } else {
        Install-NewFile $Source $Destination $Label
    }
}

# ---- Detect tools ----

function Test-Tool {
    param([string]$Command)

    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Test-ToolPath {
    param([string]$Path)
    return Test-Path $Path
}

# ============================================================
# MAIN
# ============================================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor $colors.Blue
Write-Host "║    Universal Agents — Merge-Safe Installer v2.0      ║" -ForegroundColor $colors.Blue
Write-Host "║    122 specialized AI coding agents                   ║" -ForegroundColor $colors.Blue
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor $colors.Blue
Write-Host ""

Write-Host "  Target:  " -NoNewline
Write-Host $ProjectDir -ForegroundColor $colors.Bold
Write-Host "  Mode:    " -NoNewline
Write-Host $Mode -ForegroundColor $colors.Bold

if ($DryRun) {
    Write-Host "  " -NoNewline
    Write-Host "DRY RUN — no files will be modified" -ForegroundColor $colors.Yellow
}

Write-Host ""

# ---- Step 1: Detect existing configs ----
Write-Host "[1/6] " -NoNewline -ForegroundColor $colors.Yellow
Write-Host "Scanning for existing configurations...`n"

$existingConfigs = @()
$configsToCheck = @(
    "AGENTS.md",
    "CLAUDE.md",
    "GEMINI.md",
    ".github/copilot-instructions.md",
    ".cursor/rules",
    ".claude/settings.json",
    ".codex/config.toml"
)

foreach ($f in $configsToCheck) {
    if (Test-Path (Join-Path $ProjectDir $f)) {
        $existingConfigs += $f
        Write-Warn "Found existing: $f"
    }
}

if ($existingConfigs.Count -eq 0) {
    Write-Success "No existing configs found — clean install"
} else {
    Write-Host ""
    Write-Info "$($existingConfigs.Count) existing config(s) detected. Mode '$Mode' will be used."
    if ($Mode -eq "merge") {
        Write-Info "Your existing instructions will be preserved. Agent config will be appended."
    }
}

Write-Host ""

# ---- Step 2: Install agent files ----
Write-Host "[2/6] " -NoNewline -ForegroundColor $colors.Yellow
Write-Host "Installing agent files...`n"

if ($DryRun) {
    Write-Dry "Would create agents/ directory and copy agent .md files"
} else {
    $agentsDir = Join-Path $ProjectDir "agents"
    if (-not (Test-Path $agentsDir)) {
        New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
    }
}

$agentNew = 0
$agentSkip = 0
$agentFiles = Get-ChildItem (Join-Path $AgentsSrc "*.md") -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -eq $false }

foreach ($agentFile in $agentFiles) {
    $agentName = $agentFile.Name
    $dst = Join-Path $ProjectDir "agents" $agentName

    if (Test-Path $dst -PathType Leaf) {
        $agentSkip++
    } else {
        if (-not $DryRun) {
            Copy-Item $agentFile.FullName $dst -Force
        }
        $agentNew++
    }
}

$agentTotal = $agentFiles.Count
if ($agentSkip -gt 0) {
    Write-Success "$agentNew new agents installed, $agentSkip existing agents preserved"
} else {
    Write-Success "$agentNew agents installed to ./agents/"
}

Write-Host ""

# ---- Step 3: Install universal configs (merge-safe) ----
Write-Host "[3/6] " -NoNewline -ForegroundColor $colors.Yellow
Write-Host "Installing tool configurations (merge-safe)...`n"

# AGENTS.md
Merge-Markdown `
    (Join-Path $ScriptDir "AGENTS.md") `
    (Join-Path $ProjectDir "AGENTS.md") `
    "## Universal Agents (auto-installed)" `
    "AGENTS.md (Codex, Antigravity, OpenCode)"

# CLAUDE.md
Merge-Markdown `
    (Join-Path $ScriptDir "CLAUDE.md") `
    (Join-Path $ProjectDir "CLAUDE.md") `
    "## Universal Agents System (auto-installed)" `
    "CLAUDE.md (Claude Code/CLI)"

# GEMINI.md
Merge-Markdown `
    (Join-Path $ScriptDir "GEMINI.md") `
    (Join-Path $ProjectDir "GEMINI.md") `
    "## Universal Agents System (auto-installed)" `
    "GEMINI.md (Gemini CLI/Code Assist)"

# .github/copilot-instructions.md
$githubDir = Join-Path $ProjectDir ".github"
if (-not (Test-Path $githubDir)) {
    New-Item -ItemType Directory -Path $githubDir -Force | Out-Null
}

Merge-Markdown `
    (Join-Path $ScriptDir ".github" "copilot-instructions.md") `
    (Join-Path $ProjectDir ".github" "copilot-instructions.md") `
    "## Universal Agents System (auto-installed)" `
    ".github/copilot-instructions.md (GitHub Copilot)"

# .github/agents/universal-agents.agent.md
$githubAgentsDir = Join-Path $ProjectDir ".github" "agents"
if (-not (Test-Path $githubAgentsDir)) {
    New-Item -ItemType Directory -Path $githubAgentsDir -Force | Out-Null
}

Install-Alongside `
    (Join-Path $ScriptDir ".github" "agents" "universal-agents.agent.md") `
    (Join-Path $ProjectDir ".github" "agents" "universal-agents.agent.md") `
    ".github/agents/universal-agents.agent.md (Copilot Custom Agent)"

# .cursor/rules/agents.mdc
$cursorRulesDir = Join-Path $ProjectDir ".cursor" "rules"
if (-not (Test-Path $cursorRulesDir)) {
    New-Item -ItemType Directory -Path $cursorRulesDir -Force | Out-Null
}

Install-Alongside `
    (Join-Path $ScriptDir ".cursor" "rules" "agents.mdc") `
    (Join-Path $ProjectDir ".cursor" "rules" "agents.mdc") `
    ".cursor/rules/agents.mdc (Cursor)"

# .claude/settings.json
$claudeDir = Join-Path $ProjectDir ".claude"
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}

Install-ConfigFile `
    (Join-Path $ScriptDir ".claude" "settings.json") `
    (Join-Path $ProjectDir ".claude" "settings.json") `
    ".claude/settings.json"

# .codex/config.toml
$codexDir = Join-Path $ProjectDir ".codex"
if (-not (Test-Path $codexDir)) {
    New-Item -ItemType Directory -Path $codexDir -Force | Out-Null
}

Install-ConfigFile `
    (Join-Path $ScriptDir ".codex" "config.toml") `
    (Join-Path $ProjectDir ".codex" "config.toml") `
    ".codex/config.toml"

Write-Host ""

# ---- Step 4: Install discovery & maintenance tools ----
Write-Host "[4/6] " -NoNewline -ForegroundColor $colors.Yellow
Write-Host "Installing agent discovery & maintenance tools...`n"

# Agent picker — Windows PowerShell
if (Test-Path (Join-Path $ScriptDir "agent-pick.ps1") -PathType Leaf) {
    Install-Alongside `
        (Join-Path $ScriptDir "agent-pick.ps1") `
        (Join-Path $ProjectDir "agent-pick.ps1") `
        "agent-pick.ps1 (fuzzy agent search — Windows)"
}

# Agent picker — Mac/Linux
if (Test-Path (Join-Path $ScriptDir "agent-pick.sh") -PathType Leaf) {
    Install-Alongside `
        (Join-Path $ScriptDir "agent-pick.sh") `
        (Join-Path $ProjectDir "agent-pick.sh") `
        "agent-pick.sh (fuzzy agent search — Mac/Linux)"
}

# Agent picker fzf preview helper
if (Test-Path (Join-Path $ScriptDir "agent-pick-fzf-preview.sh") -PathType Leaf) {
    Install-Alongside `
        (Join-Path $ScriptDir "agent-pick-fzf-preview.sh") `
        (Join-Path $ProjectDir "agent-pick-fzf-preview.sh") `
        "agent-pick-fzf-preview.sh (fzf preview helper)"
}

# Validation script
if (Test-Path (Join-Path $ScriptDir "validate.sh") -PathType Leaf) {
    Install-Alongside `
        (Join-Path $ScriptDir "validate.sh") `
        (Join-Path $ProjectDir "validate.sh") `
        "validate.sh (agent system health check)"
}

# Uninstall script
if (Test-Path (Join-Path $ScriptDir "uninstall.sh") -PathType Leaf) {
    Install-Alongside `
        (Join-Path $ScriptDir "uninstall.sh") `
        (Join-Path $ProjectDir "uninstall.sh") `
        "uninstall.sh (clean removal)"
}

# VSCode snippets (agent autocomplete in editor)
$vscodeSnippetsPath = Join-Path $ScriptDir ".vscode" "agents.code-snippets"
if (Test-Path $vscodeSnippetsPath -PathType Leaf) {
    $vscodeDir = Join-Path $ProjectDir ".vscode"
    if (-not (Test-Path $vscodeDir)) {
        New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
    }
    Install-Alongside `
        $vscodeSnippetsPath `
        (Join-Path $ProjectDir ".vscode" "agents.code-snippets") `
        ".vscode/agents.code-snippets (editor autocomplete)"
}

# Shell completions
$completionsPath = Join-Path $ScriptDir "completions"
if (Test-Path $completionsPath -PathType Container) {
    $projCompletionsDir = Join-Path $ProjectDir "completions"
    if (-not (Test-Path $projCompletionsDir)) {
        New-Item -ItemType Directory -Path $projCompletionsDir -Force | Out-Null
    }
    $compFiles = Get-ChildItem $completionsPath -File -ErrorAction SilentlyContinue
    foreach ($compFile in $compFiles) {
        Install-Alongside `
            $compFile.FullName `
            (Join-Path $projCompletionsDir $compFile.Name) `
            "completions/$($compFile.Name)"
    }
}

# CONTRIBUTING guide
$contributingPath = Join-Path $ScriptDir "CONTRIBUTING.md"
if (Test-Path $contributingPath -PathType Leaf) {
    Install-Alongside `
        $contributingPath `
        (Join-Path $ProjectDir "CONTRIBUTING.md") `
        "CONTRIBUTING.md (how to add/modify agents)"
}

Write-Host ""

# ---- Step 5: Global configs ----
Write-Host "[5/6] " -NoNewline -ForegroundColor $colors.Yellow
Write-Host "Global configurations...`n"

# Codex global AGENTS.md
$codexGlobalPath = Join-Path $env:USERPROFILE ".codex"
$codexGlobalAgents = Join-Path $codexGlobalPath "AGENTS.md"

if ((Test-Tool "codex") -or (Test-Path $codexGlobalPath)) {
    if (-not (Test-Path $codexGlobalAgents -PathType Leaf)) {
        if (-not $DryRun) {
            if (-not (Test-Path $codexGlobalPath)) {
                New-Item -ItemType Directory -Path $codexGlobalPath -Force | Out-Null
            }
            Copy-Item (Join-Path $ScriptDir "AGENTS.md") $codexGlobalAgents -Force
        }
        Write-Success "Codex global: ~/.codex/AGENTS.md installed"
    } else {
        Write-Info "Codex global: ~/.codex/AGENTS.md already exists (skipped)"
    }
} else {
    Write-Info "Codex not detected — skipping global config"
}

Write-Host ""

# ---- Step 6: Summary ----
Write-Host "[6/6] " -NoNewline -ForegroundColor $colors.Yellow
Write-Host "Summary`n"

$totalOps = $FilesCreated + $FilesMerged + $FilesSkipped

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor $colors.Green
Write-Host "║              Installation Complete!                   ║" -ForegroundColor $colors.Green
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor $colors.Green
Write-Host ""

Write-Host "  " -NoNewline
Write-Host "Created:   " -NoNewline -ForegroundColor $colors.Green
Write-Host "$FilesCreated new files"

Write-Host "  " -NoNewline
Write-Host "Merged:    " -NoNewline -ForegroundColor $colors.Blue
Write-Host "$FilesMerged files (appended to existing)"

Write-Host "  " -NoNewline
Write-Host "Skipped:   " -NoNewline -ForegroundColor $colors.Yellow
Write-Host "$FilesSkipped files (already exist)"

Write-Host "  " -NoNewline
Write-Host "Backed up: " -NoNewline -ForegroundColor $colors.Dim
Write-Host "$FilesBackedUp files"

if ($FilesBackedUp -gt 0) {
    Write-Host "  " -NoNewline
    Write-Host "Backups at:" -NoNewline -ForegroundColor $colors.Dim
    Write-Host " $BackupDir" -ForegroundColor $colors.Dim
}

Write-Host ""
Write-Host "Agents: " -NoNewline -ForegroundColor $colors.Bold
Write-Host "$agentNew new + $agentSkip existing = $agentTotal total available"

Write-Host ""
Write-Host "Discovery & Maintenance Tools:" -ForegroundColor $colors.Bold
if (Test-Path (Join-Path $ProjectDir "agent-pick.ps1") -PathType Leaf) {
    Write-Host "  Agent Picker:  " -NoNewline -ForegroundColor $colors.Blue
    Write-Host ".\agent-pick.ps1 (fuzzy search all agents)"
}
if (Test-Path (Join-Path $ProjectDir "validate.sh") -PathType Leaf) {
    Write-Host "  Health Check:  " -NoNewline -ForegroundColor $colors.Blue
    Write-Host "./validate.sh (check agent system)"
}
if (Test-Path (Join-Path $ProjectDir "uninstall.sh") -PathType Leaf) {
    Write-Host "  Uninstall:     " -NoNewline -ForegroundColor $colors.Blue
    Write-Host "./uninstall.sh (clean removal)"
}
if (Test-Path (Join-Path $ProjectDir ".vscode" "agents.code-snippets") -PathType Leaf) {
    Write-Host "  VS Code:       " -NoNewline -ForegroundColor $colors.Blue
    Write-Host ".vscode/agents.code-snippets (editor autocomplete)"
}
if (Test-Path (Join-Path $ProjectDir "completions") -PathType Container) {
    Write-Host "  Completions:   " -NoNewline -ForegroundColor $colors.Blue
    Write-Host "./completions/ (shell tab completions)"
}

Write-Host ""
Write-Host "Can't remember an agent name? Start here:" -ForegroundColor $colors.Bold
Write-Host "  " -NoNewline
Write-Host ".\agent-pick.ps1" -ForegroundColor $colors.Blue

Write-Host ""
Write-Host "Then use the agent in your tool:" -ForegroundColor $colors.Bold
Write-Host "  Codex:     " -NoNewline -ForegroundColor $colors.Blue
Write-Host "codex '@engineering-nextjs-specialist help with SSR'"
Write-Host "  Copilot:   " -NoNewline -ForegroundColor $colors.Blue
Write-Host "@universal-agents in Copilot Chat"
Write-Host "  Claude:    " -NoNewline -ForegroundColor $colors.Blue
Write-Host "claude '@engineering-code-reviewer review this PR'"
Write-Host "  Gemini:    " -NoNewline -ForegroundColor $colors.Blue
Write-Host "gemini '@design-figma-to-code-engineer convert this'"
Write-Host "  Cursor:    " -NoNewline -ForegroundColor $colors.Blue
Write-Host "Reference agents in chat"

if ($FilesMerged -gt 0) {
    Write-Host ""
    Write-Host "Merge notes:" -ForegroundColor $colors.Yellow
    Write-Host "  Your existing configs were preserved. Agent instructions were"
    Write-Host "  appended between <!-- universal-agents-begin/end --> markers."
    Write-Host "  To remove: delete content between those markers."
    Write-Host "  To update: re-run installer (it detects existing markers and skips)."
}

if ($FilesSkipped -gt 0 -and $Mode -ne "skip") {
    Write-Host ""
    Write-Host "Config files skipped (manual merge recommended):" -ForegroundColor $colors.Yellow
    if (Test-Path (Join-Path $ProjectDir ".claude" "settings.json") -PathType Leaf) {
        Write-Host "  • .claude/settings.json — add agents directory to your existing config"
    }
    if (Test-Path (Join-Path $ProjectDir ".codex" "config.toml") -PathType Leaf) {
        Write-Host "  • .codex/config.toml — add CLAUDE.md/GEMINI.md to project_doc_fallback_filenames"
    }
}

Write-Host ""
