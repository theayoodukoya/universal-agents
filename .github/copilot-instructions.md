# GitHub Copilot Agent Instructions

This repository contains **122 specialized AI agents** that work with GitHub Copilot to provide focused expertise across software development, design, product, marketing, and operations.

## Quick Start with Copilot

### Using Custom Agents (GitHub Copilot Custom Agents)

GitHub Copilot now supports custom agents via `.github/agents/` files:

**Router Agent:**
```
@universal-agents

I need help with [your task]. What agent should I use?
```

The `@universal-agents` agent is a router that helps you find the right specialist for any task. It will:
- Understand your problem
- Recommend the best agent(s) for your work
- Show you how to invoke them

**Individual Agents:**
```
@engineering-code-reviewer: Review this function for security issues

function processPayment(amount, token) {
  // ... code here
}
```

See `.github/agents/universal-agents.agent.md` for the complete routing system.

### Using Agents in Copilot Chat

Reference an agent in your Copilot chat with the `@` symbol:

```
@agent-name: [Your task or question]
```

Or mention the agent in a comment:

```
// @agent-name
// Task description
```

Copilot will load the agent's specialized knowledge for focused assistance.

### Examples

**Code Review:**
```
@engineering-code-reviewer

Please review this authentication function for security issues:
[paste code]
```

**Design Feedback:**
```
@design-ux-architect

How would you improve the user flow for this checkout process?
[describe current flow]
```

**Performance Optimization:**
```
@engineering-database-optimizer

We're seeing slow queries on this table with 10M rows. Help optimize:
[paste query and schema]
```

## Available Agents by Domain

### Engineering (26 agents)
Code review, architecture, backend, frontend, DevOps, databases, testing, security, AI/ML, and more.

**Key agents:**
- `@engineering-code-reviewer` — Code quality and best practices
- `@engineering-senior-developer` — Architecture and mentorship
- `@engineering-security-engineer` — Security hardening
- `@engineering-backend-architect` — Backend design
- `@engineering-frontend-developer` — Web development
- `@engineering-nextjs-specialist` — Next.js full-stack
- `@engineering-devops-automator` — Infrastructure automation
- `@engineering-database-optimizer` — Query and schema optimization

### Design (9 agents)
UI/UX design, visual design, accessibility, brand consistency, design-to-code conversion.

**Key agents:**
- `@design-ux-architect` — User experience and flows
- `@design-ui-designer` — Visual interface design
- `@design-figma-to-code-engineer` — Figma to production code
- `@design-inclusive-visuals-specialist` — Accessibility and inclusive design

### Testing (8 agents)
QA, accessibility audits, performance testing, API testing, test automation.

**Key agents:**
- `@testing-accessibility-auditor` — WCAG compliance and accessibility
- `@testing-api-tester` — API testing strategies
- `@testing-performance-benchmarker` — Performance measurement
- `@testing-e2e-testing-specialist` — End-to-end test design

### Product (6 agents)
Strategy, prioritization, research, feedback synthesis, trend analysis.

**Key agents:**
- `@product-manager` — Product strategy and roadmaps
- `@product-sprint-prioritizer` — Feature prioritization (RICE, etc.)
- `@product-feedback-synthesizer` — Customer feedback analysis

### Marketing (13 agents)
Content, social media, SEO, growth, creative strategy, app store optimization.

**Key agents:**
- `@marketing-growth-hacker` — Growth strategies
- `@marketing-seo-specialist` — SEO and organic growth
- `@marketing-content-creator` — Content production
- `@marketing-social-media-strategist` — Social media strategy

### Project Management (5 agents)
Planning, tracking, leadership, resource management, operations.

**Key agents:**
- `@project-manager-senior` — Executive leadership and strategy
- `@project-management-project-shepherd` — Project execution

### Support & Operations (7 agents)
Analytics, finance, compliance, infrastructure, legal.

**Key agents:**
- `@support-infrastructure-maintainer` — System maintenance
- `@support-legal-compliance-checker` — Compliance and legal

### Specialized (16 agents)
Security auditing, blockchain, AI, MCP integration, Salesforce, cultural intelligence.

### XR & Spatial (6 agents)
Apple Vision Pro, spatial computing, immersive experiences, visionOS.

**Key agents:**
- `@visionos-spatial-engineer` — Vision Pro development
- `@xr-immersive-developer` — XR/AR/VR experiences

### Gaming (5 agents)
Game design, level design, narrative, audio, technical art.

**Key agents:**
- `@game-designer` — Game mechanics and systems
- `@level-designer` — Level and environment design
- `@narrative-designer` — Story and dialogue

### Paid Media (7 agents)
Ad strategy, creative development, PPC, programmatic buying, attribution.

**Key agents:**
- `@paid-media-ppc-strategist` — Search and pay-per-click
- `@paid-media-creative-strategist` — Ad creative development

### Shopify (3 agents)
Theme development, sections, liquid templates, Shopify optimization.

**Key agents:**
- `@shopify-impulse-section-steward` — Dynamic Shopify sections

## Accessing the Full Agent Registry

See the complete list with descriptions:

**`AGENTS.md`** — All 122 agents with categories, descriptions, and invocation patterns

**`CLAUDE.md`** — Detailed instructions for using agents in Claude Code

**`CODEX.md`** — Detailed instructions for using agents with Codex (CLI + VSCode)

**`.github/agents/` directory** — Custom agent files including the universal-agents router

**`agents/` directory** — Individual agent files (e.g., `agents/engineering-code-reviewer.md`)

## Using with Codex (Claude's CLI)

Codex automatically reads `AGENTS.md` from your project root. No additional setup needed!

**Reference agents in Codex:**
```bash
codex "@engineering-code-reviewer Review this code for security"
codex "@product-manager Define requirements for a notification system"
```

Or use Codex interactively:
```bash
codex
# Then reference @agent-name in the chat
```

See `CODEX.md` for comprehensive Codex documentation.

## Invocation Patterns in Copilot

### Pattern 1: Direct Chat Reference
```
@agent-name [your prompt]
```

Best for: Interactive dialogue with an agent

### Pattern 2: Comment-Based (for code)
```javascript
// @engineering-code-reviewer
// Review this function for security issues

function processPayment(amount, token) {
  // ... code here
}
```

### Pattern 3: Copilot Inline
Use Copilot inline suggestions with agent context:
```
// @design-ui-designer
// Generate component for user profile card
const UserProfile = () => {
  // Copilot suggestions with design expertise
}
```

## Best Practices

1. **Be specific** — Include code, designs, or requirements the agent needs
2. **One domain per chat** — Keep conversations focused on the agent's expertise
3. **Provide context** — Explain the background and constraints
4. **Ask follow-ups** — Agents can dive deeper; ask for methodology or alternatives
5. **Reference agents consistently** — Use the same agent name format

## Common Workflows

### Code Review Pipeline
```
1. @engineering-code-reviewer — Review code quality
2. @engineering-security-engineer — Review security
3. @testing-accessibility-auditor — Check accessibility
```

### Feature Development
```
1. @product-manager — Define requirements
2. @design-ux-architect — Design user flow
3. @engineering-backend-architect — Design backend
4. @engineering-frontend-developer — Build frontend
5. @testing-e2e-testing-specialist — Plan tests
6. @engineering-code-reviewer — Final review
```

### Performance Optimization
```
1. @testing-performance-benchmarker — Measure baseline
2. @engineering-database-optimizer — Optimize queries
3. @engineering-backend-architect — Optimize architecture
4. @testing-performance-benchmarker — Verify improvement
```

## Troubleshooting

**Agent not responding?**
- Make sure you're using the exact agent name (check AGENTS.md)
- Use the format: `@agent-name` (with hyphen, no underscores)
- Provide clear context and task description

**Getting generic responses?**
- Agent works better with specific code/design examples
- Include constraints and requirements
- Ask follow-up questions to dig deeper

**Need a custom agent?**
- Create a new `.md` file in `agents/` directory
- Use the format from existing agents
- Add entry to AGENTS.md
- Commit and available immediately in Copilot

## Configuration

This agent system is designed for seamless integration across tools:

- **Compatible**: GitHub Copilot, Claude Code, Gemini CLI, Cursor, VS Code, Antigravity, OpenCode
- **Format**: Markdown with YAML frontmatter
- **Location**: `agents/` directory
- **Registry**: `AGENTS.md`
- **Version**: 1.0.0

## For More Information

- **Full agent list**: See `AGENTS.md`
- **Agent format**: Check existing files in `agents/` directory
- **Tool-specific instructions**: See `CLAUDE.md` for Claude Code, `GEMINI.md` for Gemini
- **Setup & installation**: See main `README.md`

---

**Last Updated**: 2026-04-07
**Total Agents**: 122
**Version**: 1.0.0
