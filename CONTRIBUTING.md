# Contributing to Universal Agents

This guide explains how the Universal Agents system is structured and how to safely add new agents without accidentally flooding autocomplete dropdowns in Copilot Chat, Claude Code, or Cursor.

## The Router Pattern: Why We Use It

Universal Agents uses a **single-router-per-tool** architecture instead of scattering 122+ individual agent files across autocomplete directories.

### Problem It Solves

Without this pattern:
- **Copilot Chat dropdown** would show 122 separate `.agent.md` files → unusable
- **Claude Code dropdown** would show 122 separate agents → unusable
- **Cursor dropdown** would show 122 separate rules → unusable
- **New contributors** would accidentally add files to the wrong directories

### Solution: Centralized Routers

Each tool has **ONE entry point** that routes to specialized agents:

| Tool | Router File | Purpose |
|------|-------------|---------|
| **Copilot Chat** | `.github/agents/universal-agents.agent.md` | Single Copilot Chat command |
| **Claude Code** | `CLAUDE.md` | Instructions for Claude Code (direct URL reference) |
| **Cursor** | `.cursor/rules/agents.mdc` | Single Cursor rules file |

Individual agents live in `agents/` directory only. These are NOT auto-scanned by any tool—they exist as a reference library accessed by the routers.

## Directory Structure

```
universal-agents/
├── .github/
│   └── agents/
│       └── universal-agents.agent.md    ← Copilot Chat router (ONLY file here)
│
├── .cursor/
│   └── rules/
│       └── agents.mdc                   ← Cursor router (ONLY file here)
│
├── agents/                              ← Individual agent definitions
│   ├── engineering-code-reviewer.md
│   ├── engineering-backend-architect.md
│   ├── design-figma-to-code-engineer.md
│   └── ... 118 more agents
│
├── AGENTS.md                            ← Master list of all agents
├── CLAUDE.md                            ← Claude Code instructions
├── README.md                            ← Project overview
└── CONTRIBUTING.md                      ← This file
```

## The Rule: One File Per Directory

### NEVER Do This

❌ Don't add individual agent files to `.github/agents/`:
```
.github/agents/
  ├── universal-agents.agent.md
  ├── engineering-code-reviewer.agent.md    ← WRONG! This floods Copilot Chat dropdown
  ├── design-figma-to-code.agent.md         ← WRONG!
  └── ...
```

❌ Don't add individual rule files to `.cursor/rules/`:
```
.cursor/rules/
  ├── agents.mdc
  ├── engineering-code-reviewer.mdc         ← WRONG! This floods Cursor dropdown
  ├── design-figma-to-code.mdc              ← WRONG!
  └── ...
```

### DO This Instead

✅ Individual agents go ONLY in `agents/`:
```
agents/
  ├── engineering-code-reviewer.md
  ├── design-figma-to-code-engineer.md
  ├── engineering-backend-architect.md
  └── ... all individual agents
```

✅ Update the routers to link to them:
- `.github/agents/universal-agents.agent.md` — Add agent name to its list
- `.cursor/rules/agents.mdc` — Add agent name to its list
- `AGENTS.md` — Add agent to the master list

## How to Add a New Agent

### Step 1: Create the Agent File

Create a new file in `agents/` named `{category}-{name}.md`:

```bash
agents/engineering-new-tool-specialist.md
```

### Step 2: Write the Agent Definition

Use this template:

```markdown
---
name: engineering-new-tool-specialist
description: "Brief description of what this agent does"
tools: ['codebase', 'editFiles', 'runCommands']
---

# Agent Name

Your detailed agent instructions and expertise here.

## Responsibilities
- Task 1
- Task 2
- Task 3

## Approach
- How you approach problems
- Methodology
- Best practices
```

### Step 3: Update AGENTS.md

Add your new agent to the appropriate category in `AGENTS.md`:

```markdown
### Engineering (27 agents)

**Code Quality & Architecture:**
- `engineering-code-reviewer` — Constructive code reviews
- `engineering-new-tool-specialist` — [Your new agent description]  ← Add here
```

### Step 4: Update the Routers (Optional)

**For Copilot Chat:** Add to `.github/agents/universal-agents.agent.md` agent list (if user-facing)

**For Cursor:** Add to `.cursor/rules/agents.mdc` agent list (if user-facing)

**Note:** The routers pull from `AGENTS.md` dynamically in their instructions, so basic updates to `AGENTS.md` often suffice. Only update the router files if you want to prominently feature the agent in their dropdowns.

### Step 5: Test Your Changes

Run validation to ensure your agent is properly documented:

```bash
./validate.sh
```

This checks:
- ✅ Agent file exists in `agents/` directory
- ✅ Agent is listed in `AGENTS.md`
- ✅ Agent frontmatter is valid YAML
- ✅ No `.md` files accidentally in `.github/agents/` or `.cursor/rules/`

## What Gets Auto-Scanned

| Directory | Auto-Scanned By | Files | What Appears |
|-----------|-----------------|-------|--------------|
| `.github/agents/` | Copilot Chat | **1 file only** → `universal-agents.agent.md` | Single `@universal-agents` command |
| `.cursor/rules/` | Cursor | **1 file only** → `agents.mdc` | Single agent rules context |
| `agents/` | **None** | 122+ individual agent files | Reference library only |
| `AGENTS.md` | Manual reference | Master list | For documentation |

## Common Mistakes to Avoid

### Mistake 1: Adding to `.github/agents/`

❌ **Wrong:**
```bash
touch .github/agents/my-new-agent.agent.md
```

✅ **Right:**
```bash
touch agents/my-new-agent.md
# Then update AGENTS.md with a reference
```

### Mistake 2: Creating Multiple Cursor Rules Files

❌ **Wrong:**
```bash
touch .cursor/rules/my-rule.mdc
touch .cursor/rules/another-rule.mdc
```

✅ **Right:**
- Single file: `.cursor/rules/agents.mdc`
- All agents defined in this ONE file
- Keep it as the only `.mdc` file in `.cursor/rules/`

### Mistake 3: Not Updating AGENTS.md

❌ **Wrong:**
```bash
# Create agent but forget to document it
touch agents/new-agent.md
git commit -m "Add new agent"  # Incomplete!
```

✅ **Right:**
```bash
# 1. Create agent
touch agents/new-agent.md

# 2. Update documentation
vim AGENTS.md  # Add to appropriate category

# 3. Test
./validate.sh

# 4. Commit
git commit -m "Add new-agent: [description]"
```

## Testing Your Changes

### Manual Verification

Before committing:

1. **Check file locations:**
   ```bash
   ls -la agents/ | grep your-agent-name
   # Should exist in agents/ directory

   ls -la .github/agents/ | grep your-agent-name
   # Should NOT appear here

   ls -la .cursor/rules/ | grep your-agent-name
   # Should NOT appear here
   ```

2. **Verify AGENTS.md:**
   ```bash
   grep "your-agent-name" AGENTS.md
   # Should appear in appropriate category
   ```

3. **Run validation:**
   ```bash
   ./validate.sh
   # Should pass all checks
   ```

### Automated Validation (if available)

The repository includes `validate.sh` which checks:

```bash
./validate.sh
```

This ensures:
- ✅ No accidental `.md` files in `.github/agents/`
- ✅ No accidental `.mdc` files in `.cursor/rules/` (except `agents.mdc`)
- ✅ All agents in `AGENTS.md` have corresponding files
- ✅ All agent files have valid YAML frontmatter
- ✅ Routers point to `agents/` directory only

## Safety Warnings in Code

The router files contain safety warnings at the top:

```markdown
<!--
  ⚠️  AUTOCOMPLETE PROTECTION: This is the ONLY file in .github/agents/.
  Individual agent files live in ../agents/ (not here).
  Adding more .agent.md files here floods Copilot Chat's @ dropdown.
  See CONTRIBUTING.md for details.
-->
```

**If you see this warning, DO NOT add more files to this directory.** The warning is there to protect the experience for all tool users.

## Questions?

- **How do I check what agents exist?** → Read `AGENTS.md`
- **How do I use an agent?** → See `README.md` for usage instructions
- **Where does my agent code go?** → `agents/{category}-{name}.md`
- **My agent should appear in the dropdown, right?** → Probably not! The dropdown shows only the router. Your agent is accessed through the router's instructions.
- **Can I add another router?** → Not recommended. Instead, enhance the existing routers to include your agent.

## Summary

| Do | Don't |
|----|-------|
| ✅ Create agents in `agents/` | ❌ Create agents in `.github/agents/` |
| ✅ Create agents in `agents/` | ❌ Create agents in `.cursor/rules/` |
| ✅ Update `AGENTS.md` | ❌ Forget to update `AGENTS.md` |
| ✅ Use routers to access agents | ❌ Add files to auto-scan directories |
| ✅ Run `validate.sh` before committing | ❌ Skip validation |

The golden rule: **Individual agents in `agents/`, routers only in auto-scan directories.**
