# Universal Agents

You have **122 expert prompt files**. Copy them into your project, and your AI coding tool loads them automatically. Done.

## What Is This?

This folder contains 122 specialized system prompts — we call them "agents" — that teach AI coding tools like Claude Code, GitHub Copilot, Cursor, and Gemini to be experts in different domains.

Instead of asking Claude "Can you review this code for security?", you ask the **Code Reviewer agent** — a prompt that's been fine-tuned specifically for that task. You get faster, more focused responses because the agent knows exactly what to do and how to do it.

Each agent is just a Markdown file. When you install them into your project, your AI tool picks them up automatically and uses them when you reference them.

## How It Works (30 seconds)

```
┌─────────────────────────┐
│  universal-agents/      │
│  ├── agents/            │  ← 122 agent files (prompts)
│  ├── install.sh         │
│  ├── validate.sh        │
│  └── agent-pick.sh      │
└──────────┬──────────────┘
           │
           │ ./install.sh --target /path/to/my-project
           │
           ▼
┌─────────────────────────┐
│  my-project/            │
│  ├── .claude/           │  ← Claude Code agents
│  ├── .github/           │  ← GitHub Copilot agents
│  ├── .cursor/           │  ← Cursor agents
│  ├── .gemini/           │  ← Gemini agents
│  ├── AGENTS.md          │  ← Universal registry
│  ├── CLAUDE.md          │  ← Claude Code config
│  └── agents/            │  ← Your copies of all 122 agents
└─────────────────────────┘
           │
           │ Now use them: @agent-name in your tool
           │
           ▼
    Tool loads the agent
    and uses it as a system prompt
```

## Getting The Agents

### Option 1: Clone from GitHub (Recommended)

```bash
git clone https://github.com/theayoodukoya/universal-agents.git
```

Replace `OWNER` with the actual GitHub username or org. Once cloned, the folder lives wherever you put it — Desktop, Documents, a dev tools folder, anywhere.

### Option 2: One-Command Remote Install

Don't even need to clone first. This downloads, installs into your project, and cleans up:

```bash
curl -fsSL https://raw.githubusercontent.com/theayoodukoya/universal-agents/main/remote-install.sh | bash -s -- ~/code/my-project
```

Options work the same as the local installer:

```bash
# Dry run first
curl -fsSL <url> | bash -s -- --dry-run ~/code/my-project

# Replace mode
curl -fsSL <url> | bash -s -- --replace ~/code/my-project
```

### Option 3: Download ZIP

Go to the GitHub repo → **Code** → **Download ZIP**. Unzip it anywhere on your computer.

### Where To Put The Folder

The `universal-agents/` folder can live **anywhere**:

- `~/Desktop/universal-agents`
- `~/Documents/universal-agents`
- `/opt/universal-agents`
- `C:\Users\YourName\Desktop\universal-agents` (Windows)

When you install, you point the script at your project. That's it.

```bash
# Mac/Linux
~/Desktop/universal-agents/install.sh --target /path/to/my-project

# Windows PowerShell
& "C:\Users\YourName\Desktop\universal-agents\install.ps1" -Target "C:\path\to\my-project"
```

### Staying Up To Date

If you cloned from GitHub, pull to get new agents and fixes:

```bash
cd ~/Desktop/universal-agents
git pull
```

Then re-run the installer on your project — it merges by default, so your existing configs stay intact:

```bash
./install.sh --target ~/code/my-project
```

## Setup

You have 4 ways to install. Pick one.

### Option A: Automatic Install (Recommended — Mac/Linux)

The simplest path. One command does everything.

```bash
# If you cloned from GitHub
git clone https://github.com/theayoodukoya/universal-agents.git
cd universal-agents

# Run the installer
./install.sh --target /path/to/my-project

# That's it. Agents are now in my-project/
```

**What it does:**
- Copies all 122 agent files to `my-project/agents/`
- Creates tool-specific configs (`.claude/`, `.github/`, `.cursor/`, `.gemini/`)
- Creates `AGENTS.md` (central registry)
- Creates `CLAUDE.md` (Claude Code instructions)
- Installs discovery & maintenance tools into your project:
  - `./agent-pick.sh` / `.\agent-pick.ps1` (fuzzy agent search — pick which agent to use)
  - `./validate.sh` (health check)
  - `./uninstall.sh` (clean removal)
  - `.vscode/agents.code-snippets` (editor autocomplete)
  - `./completions/` (shell tab completions)
  - `CONTRIBUTING.md` (how to add your own agents)
- Does NOT overwrite existing config files (uses merge strategy by default)

**Flags:**
```bash
./install.sh --target /path/to/my-project    # (default) Merge with existing configs
./install.sh --target /path/to/my-project --replace  # Overwrite existing configs (backs up first)
./install.sh --target /path/to/my-project --skip     # Skip any file that already exists
./install.sh --target /path/to/my-project --dry-run  # Show what would happen without changing anything
```

### Option B: Automatic Install (Windows PowerShell)

On Windows, use the PowerShell version:

```powershell
# Open PowerShell in the universal-agents folder
cd C:\Users\YourName\Desktop\universal-agents

# Run the installer
.\install.ps1 -Target "C:\path\to\my-project"

# That's it.
```

**Flags:**
```powershell
.\install.ps1 -Target "C:\path\to\my-project" -Merge      # (default) Merge with existing configs
.\install.ps1 -Target "C:\path\to\my-project" -Replace    # Overwrite existing configs
.\install.ps1 -Target "C:\path\to\my-project" -Skip       # Skip existing files
.\install.ps1 -Target "C:\path\to\my-project" -DryRun     # Show what would happen
```

Once installed, use the agent picker to find agents:
```powershell
.\agent-pick.ps1
```

### Option C: Ask Your AI Tool (Easiest for Claude Code)

If you use Claude Code, Copilot, or any AI coding tool, just ask it to install:

```
Hey Claude, install universal-agents from ~/Desktop/universal-agents into this project.

Here's what I want:
- Copy all 122 agents to ./agents/
- Set up .claude/ for Claude Code
- Set up .github/ for GitHub Copilot
- Create AGENTS.md and CLAUDE.md
- Merge with existing configs, don't overwrite
```

The AI tool can do the entire installation for you. It's actually the fastest path if your tool is already open.

### Option D: Manual Setup (If You Know What You're Doing)

If you want granular control or need to customize:

**For Claude Code:**
```bash
mkdir -p .claude
cp universal-agents/.claude/* .claude/
cp universal-agents/CLAUDE.md .
cp universal-agents/agents .  # or symlink: ln -s /path/to/universal-agents/agents agents
```

**For GitHub Copilot:**
```bash
mkdir -p .github/agents
cp universal-agents/.github/agents/* .github/agents/
cp universal-agents/.github/copilot-instructions.md .github/
```

**For Cursor:**
```bash
mkdir -p .cursor/rules
cp universal-agents/.cursor/rules/* .cursor/rules/
```

**For Gemini:**
```bash
mkdir -p .gemini
cp universal-agents/.gemini/* .gemini/
cp universal-agents/GEMINI.md .
```

**For all tools (recommended):**
```bash
cp -r universal-agents/agents .
cp universal-agents/AGENTS.md .
cp universal-agents/CLAUDE.md .
cp universal-agents/GEMINI.md .
mkdir -p .claude .github/agents .cursor/rules .gemini
cp universal-agents/.claude/* .claude/
cp universal-agents/.github/agents/* .github/agents/
cp universal-agents/.github/copilot-instructions.md .github/
cp universal-agents/.cursor/rules/* .cursor/rules/
cp universal-agents/.gemini/* .gemini/
```

## Using Agents

### Auto-Dispatch: The AI Picks the Right Agent For You

Once installed, **you don't need to remember any agent names**. Just describe your task naturally and the AI automatically selects the best agent.

```
You: "This checkout flow is slow, can you optimize it?"

AI: [Agent: engineering-database-optimizer — detected performance/query optimization task]
    Let me analyze your checkout flow...
```

Auto-dispatch works across Claude Code, Gemini CLI, Cursor, GitHub Copilot, and Codex. Each tool's config file contains instructions that tell the AI to read `agents-manifest.json`, match your task to the best agent, and load it — all before responding.

**How it decides:**

1. **Project context** — It checks what's in your project (package.json deps, file types, config files) to narrow the field. A Next.js project auto-weights frontend agents; a project with `.sql` files boosts database agents.
2. **Task keywords** — Your request is matched against each agent's keywords, description, and category.
3. **Confidence check** — If there's a clear winner, it loads that agent and proceeds. If it's ambiguous, it asks you to pick between the top candidates.

**For complex tasks, it chains agents automatically:**

```
You: "Build me a user authentication system"

AI: [Chain: build_feature]
    Step 1 — [Agent: engineering-backend-architect] Designing the auth architecture...
    Step 2 — [Agent: engineering-security-engineer] Reviewing for vulnerabilities...
    Step 3 — [Agent: engineering-code-reviewer] Final quality check...
```

Pre-built chains include: `build_feature`, `code_review`, `new_api`, `launch_prep`, `design_to_code`, `shopify_theme`, `mobile_app`, and `data_pipeline`.

**You can always override** by naming an agent directly — `@engineering-code-reviewer` skips auto-dispatch and uses that agent immediately.

### Manual Agent Selection (Still Works)

Once installed, reference them by name in your tool's chat interface.

### Claude Code (VS Code Extension)

```
@engineering-code-reviewer: Review this function for security issues

[paste code]
```

Or load an agent file directly:
```
Reference ./agents/engineering-database-optimizer.md

[paste your database problem]
```

See `CLAUDE.md` for detailed instructions and examples.

### GitHub Copilot (in Copilot Chat)

```
@engineering-security-engineer: Check this authentication flow for vulnerabilities

[paste code]
```

Use the router agent to discover which agent you need:
```
@universal-agents: I need to optimize a slow query. Which agent should I use?
```

See `.github/copilot-instructions.md` for details.

### Cursor (Command Palette or Chat)

```
@engineering-backend-architect: Design the architecture for a real-time collaboration system

[describe your requirements]
```

Rules are loaded automatically from `.cursor/rules/agents.mdc`.

### Gemini CLI or Gemini Code Assist

```bash
gemini "@design-ux-architect: Design a checkout flow for an e-commerce site"
```

Or in chat:
```
@testing-accessibility-auditor: Check this component for a11y issues

[paste code]
```

See `GEMINI.md` for comprehensive reference.

### Claude CLI / Codex (Not Recommended But Supported)

If you use Codex (Claude's CLI):
```bash
codex "@engineering-database-optimizer: Optimize these queries"
```

Works, but most people prefer the web/IDE interfaces above.

## Finding the Right Agent

There are 122 agents. Here's how to find the right one:

### 1. Use the Interactive Picker (Best)

After you install with `./install.sh`, the agent picker is right there in your project:

```bash
./agent-pick.sh          # On Mac/Linux
.\agent-pick.ps1         # On Windows PowerShell
```

This interactive CLI searches agents by name, description, and category. With fzf installed, you get live preview. Without fzf, you get a searchable menu.

```
$ ./agent-pick.sh

Universal Agents Picker (122 agents)

[Search]: database
  ► engineering-database-optimizer — Optimizes database queries, indexing, and schema design
    engineering-data-engineer — Builds data pipelines, ETL systems, and data infrastructure

[Pick an agent to see full description]
```

**No need to go back to the source folder.** The picker is copied into your project during installation, so you can discover agents whenever you need to.

### 2. Browse `AGENTS.md`

Open `AGENTS.md` in your project. It's a complete registry organized by category.

### 3. Browse by Category

**Common starting points:**

| Task | Category | Top Agents |
|------|----------|-----------|
| Code quality | Engineering | `@engineering-code-reviewer`, `@engineering-security-engineer` |
| API design | Engineering | `@engineering-backend-architect`, `@engineering-senior-developer` |
| Frontend/React | Engineering | `@engineering-nextjs-specialist`, `@engineering-frontend-developer` |
| Database | Engineering | `@engineering-database-optimizer`, `@engineering-data-engineer` |
| Infrastructure | Engineering | `@engineering-devops-automator`, `@engineering-aws-ecosystem-architect` |
| UX Design | Design | `@design-ux-architect`, `@design-ux-researcher` |
| Visual Design | Design | `@design-ui-designer`, `@design-visual-storyteller` |
| Testing | Testing | `@testing-accessibility-auditor`, `@testing-performance-benchmarker` |
| Product | Product | `@product-manager`, `@product-sprint-prioritizer` |
| Marketing | Marketing | `@marketing-seo-specialist`, `@marketing-growth-hacker` |
| Project Management | PM | `@project-manager-senior`, `@project-management-project-shepherd` |

See `AGENTS.md` for the full list of 122 agents.

## The @ Autocomplete Question: Why Not 122 Entries?

You might ask: "If I use GitHub Copilot or Claude Code, won't I see 122 agents in the autocomplete dropdown?"

**Answer: No.** Here's why.

Most tools (especially Copilot and Claude Code) show a small curated list of agents in autocomplete — usually 5–10. Adding 122 would be overwhelming.

**Solution: Router Pattern**

Instead of 122 autocomplete entries, there's **one entry per tool**: `@universal-agents` (Copilot), `@project-agents` (Claude Code), etc. You ask the router which agent to use:

```
@universal-agents: I need to optimize a slow database query. Which agent should I use?
```

The router tells you to use `@engineering-database-optimizer`. Then you invoke it directly:

```
@engineering-database-optimizer: [your query problem]
```

**How it works under the hood:**
- `.github/agents/universal-agents.agent.md` (Copilot) — a router that knows all 122 agents
- `.claude/agents.json` (Claude Code) — configuration that points to all agents
- `AGENTS.md` — universal registry that all tools reference

You get the best of both worlds: **clean autocomplete** + **full access to 122 agents**.

## Agent Categories (Quick Reference)

```
Engineering (31)          — Code review, architecture, backend, frontend, databases, DevOps, security, AI/ML, testing
Design (9)               — UI/UX, visual design, accessibility, brand, design systems
Testing (8)              — QA, accessibility, performance, API testing, automation
Marketing (13)           — Content, SEO, social media, growth, app store optimization
Product (6)              — Strategy, roadmaps, prioritization, research, feedback
Project Management (5)   — Planning, execution, resource management, operations
Support & Operations (7) — Analytics, finance, infrastructure, legal, compliance, support
Specialized (16)         — Security auditing, blockchain, AI systems, MCP, Salesforce, etc.
XR & Spatial (6)         — Vision Pro, visionOS, spatial computing, immersive experiences
Gaming (5)               — Game design, level design, narrative design, audio, art
Paid Media (7)           — Ad strategy, creative, PPC, programmatic, attribution
Shopify (3)              — Theme development, section design, optimization

TOTAL: 122 agents
```

See `AGENTS.md` for the complete list with descriptions.

## Agent Picker Reference

The agent picker (`agent-pick.sh` on Mac/Linux, `agent-pick.ps1` on Windows) has 5 modes. All examples below use the bash version — the PowerShell version works identically with `.\agent-pick.ps1`.

### Mode 1: Fuzzy Search (Default)

Run with no arguments. Type to search across agent names, descriptions, and categories. If you have [fzf](https://github.com/junegunn/fzf) installed, you get a live preview panel; otherwise, a built-in fuzzy matcher kicks in.

```bash
./agent-pick.sh
```

```
Universal Agents Picker (122 agents)

[Search]: database
  ► engineering-database-optimizer — Optimizes database queries, indexing, and schema design
    engineering-data-engineer — Builds data pipelines, ETL systems, and data infrastructure
    engineering-bigquery-analyst — Expert in Google BigQuery, data warehousing, and analytical SQL

Select an agent (1-3, or q to quit):
```

When you pick one, it copies `@agent-name` to your clipboard and shows how to use it in every supported tool.

### Mode 2: Browse by Category

Presents a menu of all categories so you can drill into the one you need.

```bash
./agent-pick.sh browse
```

```
Categories:
  1. Engineering (31 agents)
  2. Design (9 agents)
  3. Testing (8 agents)
  4. Marketing (13 agents)
  5. Product (6 agents)
  6. Project Management (5 agents)
  7. Support & Operations (7 agents)
  8. Specialized (18 agents)
  9. XR & Spatial (6 agents)
 10. Gaming (5 agents)
 11. Paid Media (7 agents)
 12. Shopify (3 agents)

Select a category (1-12):
```

Pick a category to see every agent in it, then pick one to copy to clipboard.

### Mode 3: Keyword Search

Search for agents matching a keyword without entering interactive mode. Useful when you roughly know what you need.

```bash
./agent-pick.sh find security
```

```
Agents matching "security":
  1. engineering-security-engineer — Focuses on application security, vulnerability assessment, and secure coding
  2. engineering-threat-detection-engineer — Designs threat detection systems and anomaly detection mechanisms
  3. blockchain-security-auditor — Audits blockchain security and smart contract vulnerabilities

Select an agent (1-3, or q to quit):
```

### Mode 4: Agent Info

Get full details about a specific agent — its description, emoji, vibe, core mission, and the first section of its prompt.

```bash
./agent-pick.sh info engineering-code-reviewer
```

```
╔══════════════════════════════════════════════════╗
  engineering-code-reviewer
  Provides constructive code reviews focusing on
  correctness, security, maintainability
╚══════════════════════════════════════════════════╝

  Emoji: 🔍
  Vibe:  Senior engineer who's seen it all
  File:  agents/engineering-code-reviewer.md

  Use in Claude Code:
    @engineering-code-reviewer: [your request]

  Use in GitHub Copilot:
    @engineering-code-reviewer: [your request]

  Use in Gemini CLI:
    @engineering-code-reviewer [your request]
```

### Mode 5: List All

Prints every agent grouped by category. Handy for a quick scan or when piping to `grep`.

```bash
./agent-pick.sh list
```

```
Engineering (31 agents)
  engineering-ai-engineer — Expert in LLM integration, prompt engineering, and AI system design
  engineering-backend-architect — Designs scalable, maintainable backend systems and APIs
  ...

Design (9 agents)
  design-brand-guardian — Ensures design consistency and brand integrity
  design-ui-designer — Creates user interfaces with attention to usability
  ...

(all 12 categories listed)
```

Tip: Pipe to grep for a quick filter — `./agent-pick.sh list | grep "testing"`.

---

## Adding Your Own Agents

Create custom agents for your specific needs:

1. **Create a new file** in `agents/`:
   ```bash
   agents/your-category-your-agent-name.md
   ```

2. **Use this template** (copy from any existing agent):
   ```yaml
   ---
   name: Your Agent Name
   description: One-line description of what this agent does
   tools: []
   emoji: 🎯
   vibe: Brief note on personality (mentor, partner, expert, etc.)
   ---

   # Your Agent Name

   ## Your Identity & Memory
   - Role and specialty
   - Personality and communication style
   - Key experiences or background

   ## Your Core Mission
   - What you do
   - What matters most
   - Your focus areas

   ## Critical Rules
   - What you will/won't do
   - Important constraints
   - Non-negotiables

   ## Methodology (Optional)
   - Frameworks you use
   - Step-by-step approach
   - Questions you ask

   ## How to Handle Edge Cases
   - Ambiguous situations
   - Trade-offs and priorities
   - When to ask for clarification
   ```

3. **Update `AGENTS.md`** to include your new agent in the registry

4. **Use it immediately** — No restart needed. Reference it with `@your-category-your-agent-name`

**Best practices:**
- Be specific about expertise (not "I can do anything")
- Define clear rules and constraints (500–1500 words is ideal)
- Use the same structure as existing agents
- Test with your AI tool to verify it works

See `agents/engineering-code-reviewer.md` for a full example.

## Maintenance Scripts

The folder includes three useful scripts:

### `./validate.sh` (Mac/Linux)

Checks that all agents are properly formatted and installed:

```bash
./validate.sh
```

Output:
```
✓ 122 agents found in agents/
✓ All agents have YAML frontmatter
✓ No hardcoded paths found
✓ AGENTS.md registry is complete
✓ agents-manifest.json is in sync (122 agents)
✓ All validations passed!
```

**Rebuild the auto-dispatch manifest** after adding or removing agents:

```bash
./validate.sh --rebuild
```

This regenerates `agents-manifest.json` from all agent files' YAML frontmatter. You never need to edit the manifest by hand.

### `./validate.ps1` (Windows PowerShell)

Same as above for Windows:

```powershell
.\validate.ps1
```

### `./uninstall.sh` (Mac/Linux)

Removes agents from your project (but keeps other configs safe):

```bash
./uninstall.sh /path/to/my-project
```

Removes:
- `agents/` folder
- Removes agent references from `.claude/`, `.github/`, `.cursor/`, `.gemini/`
- Keeps backup of original files just in case

### `./uninstall.ps1` (Windows PowerShell)

```powershell
.\uninstall.ps1 -Target "C:\path\to\my-project"
```

### Dry-Run Before Install

Preview what will be installed without making changes:

```bash
./install.sh --target /path/to/my-project --dry-run
```

```powershell
.\install.ps1 -Target "C:\path\to\my-project" -DryRun
```

## Folder Structure

After installation, your project looks like this:

```
my-project/
├── README.md                    # Your project readme
├── package.json                 # (or equivalent)
│
├── agents/                      # All 122 universal agents (copied here)
│   ├── engineering-code-reviewer.md
│   ├── engineering-security-engineer.md
│   ├── design-ux-architect.md
│   ├── marketing-seo-specialist.md
│   └── ... (118 more agents)
│
├── AGENTS.md                    # Universal agent registry
├── CLAUDE.md                    # Claude Code instructions
├── GEMINI.md                    # Gemini CLI instructions
│
├── .claude/                     # Claude Code configuration
│   ├── settings.json
│   └── agents.json
│
├── .github/                     # GitHub Copilot configuration
│   ├── copilot-instructions.md
│   └── agents/
│       └── universal-agents.agent.md (router)
│
├── .cursor/                     # Cursor configuration
│   └── rules/
│       └── agents.mdc
│
├── .gemini/                     # Gemini configuration
│   ├── agents/
│   └── config.json
│
└── src/                         # Your actual code
    └── ...
```

## Common Workflows

### Workflow 1: Code Review

```
@engineering-code-reviewer: Review this function for security, performance, and style

[paste code]
```

Agent provides detailed feedback with priorities (blocker, suggestion, nit).

### Workflow 2: Design System

```
@design-brand-guardian: Review this component design against our brand guidelines

[paste design]
```

Agent checks consistency, accessibility, and brand alignment.

### Workflow 3: Database Optimization

```
@engineering-database-optimizer: These queries are timing out. How do I optimize them?

Current runtime: 45 seconds
Target runtime: < 2 seconds
Query: [paste SQL]
Schema: [describe your schema]
```

Agent provides indexing strategy, query rewrite, and caching recommendations.

### Workflow 4: Product Strategy

```
@product-manager: We're planning Q3 roadmap. Here's what we're considering:
- Feature A (requested by 20% of users)
- Feature B (solves a critical pain point)
- Feature C (is technically simpler)

What should we prioritize?
```

Agent helps you think through trade-offs and decide.

### Workflow 5: Complex Project (Multi-Agent)

Chain multiple agents for a complete workflow:

```
Step 1: Define Requirements
@product-manager: What features should a real-time notification system have?

Step 2: Design UX
@design-ux-architect: Design the user experience for these features

Step 3: Design Backend
@engineering-backend-architect: Design the backend architecture for this UX

Step 4: Build Frontend
@engineering-nextjs-specialist: Build the frontend using Next.js

Step 5: Test
@testing-api-tester: Design API testing strategy for this system

Step 6: Security Review
@engineering-security-engineer: Review this architecture for security issues

Step 7: Final Review
@engineering-code-reviewer: Review the final code for quality and best practices
```

## Compatibility

Works with:
- **Claude Code** (VS Code extension) ✓
- **GitHub Copilot** (with custom agents) ✓
- **Cursor** ✓
- **Gemini CLI** ✓
- **Gemini Code Assist** ✓
- **Claude CLI** (Codex) ✓
- **VS Code with Claude extension** ✓
- **Antigravity** (v1.20.3+) ✓
- **OpenCode** ✓

All tools read from the same `agents/` folder and `AGENTS.md` registry.

## Security & Privacy

- **Runs locally** — No external calls to remote services
- **Agents are pure text** — No tracking, telemetry, or data collection
- **Your code never leaves your machine** — Unless you choose to share it
- **Works offline** — Agents load from local files
- **No account required** — Everything is just files on your computer

Create custom agents with confidence — they're just Markdown files.

## FAQ

**Q: Do I need all 122 agents?**
A: No. Start with agents relevant to your work. Ignore the rest. You can browse with `./agent-pick.sh`.

**Q: Can I modify agents?**
A: Yes! Edit agent files in `agents/` directory. Changes take effect immediately in your next chat.

**Q: Can I create my own agents?**
A: Absolutely. Create new files in `agents/` and follow the template. They'll work immediately.

**Q: What if I already have `.claude/` or `CLAUDE.md`?**
A: By default, the installer uses merge mode — it appends agent config to your existing files and doesn't overwrite. Use `--replace` flag if you want to overwrite.

**Q: Can I use this with multiple projects?**
A: Yes. Install into each project separately. Each project gets its own `agents/` folder and config files.

**Q: Do agents work offline?**
A: The agent files work offline (they're just Markdown). Your AI tool (Claude, Copilot, Gemini) needs internet to run, but the agents themselves are local.

**Q: Which tool should I use?**
A: Use whatever AI coding tool you already have. All three major tools (Claude Code, GitHub Copilot, Gemini) are fully supported. Pick based on preference.

**Q: Can I use agents in production?**
A: Agents are for development and planning. Don't commit agent outputs directly to production without human review.

**Q: What's the difference between agents and system prompts?**
A: Agents are system prompts. We just call them "agents" because they represent specialized experts, not generic system instructions.

**Q: Can I use this with multiple AI tools at once?**
A: Yes. Install once, use with all your tools. Each tool reads the same `agents/` folder.

**Q: How do I know if an agent is working?**
A: Run `./validate.sh` (Mac/Linux) or `.\validate.ps1` (Windows). It checks that all agents are properly installed and formatted.

**Q: How do I discover which agent to use?**
A: Three ways: (1) Run `./agent-pick.sh`, (2) Read `AGENTS.md`, (3) Ask the router agent (`@universal-agents`).

## Getting Help

1. **Find an agent**: Run `./agent-pick.sh` or read `AGENTS.md`
2. **Check tool docs**:
   - Claude Code: See `CLAUDE.md`
   - GitHub Copilot: See `.github/copilot-instructions.md`
   - Cursor: See `.cursor/rules/agents.mdc`
   - Gemini: See `GEMINI.md`
3. **Look at examples**: Browse agent files in `agents/` to see the format
4. **Create a custom agent**: For your specific use case, add a new agent file

## Next Steps

1. **Install agents** into your project:
   ```bash
   ./install.sh --target /path/to/my-project
   ```

2. **Discover agents**:
   ```bash
   ./agent-pick.sh
   ```

3. **Try one**: Open Claude Code (or your AI tool) and reference an agent:
   ```
   @engineering-code-reviewer: Review this code for security issues
   [paste code]
   ```

4. **Explore**: Browse `AGENTS.md` for all 122 agents

5. **Create custom agents** as you discover new needs

---

**Version**: 1.0
**Total Agents**: 122
**Last Updated**: 2026-04-07
**License**: MIT

**Happy coding!** Each agent is here to help you do your best work.
