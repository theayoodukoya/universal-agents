# Claude Code Project Instructions

## Universal Agents System

This project contains a system of **122 specialized AI agents** designed to assist with every aspect of software development, design, marketing, operations, and more.

### What Are Agents?

Agents are **prompt-based experts** that embody specific expertise and personality traits. Each agent is a detailed Markdown file that Claude Code loads to become a specialized assistant. They're designed for:

- Focused, expertise-driven conversations
- Consistent personality and approach
- Domain-specific best practices and methodologies
- Rapid context-switching between specialties

### How to Use Agents in Claude Code

#### Method 1: Direct Reference
```
@agent-name

Your task or question here. The agent system will load the appropriate agent.
```

**Example:**
```
@engineering-code-reviewer

Here's the PR to review: [paste code]
```

#### Method 2: File Path Reference
```
I need help with this. Reference ./agents/engineering-code-reviewer.md for context.
```

#### Method 3: Ask Claude to Load an Agent
```
I need a code review. Can you use the code-reviewer agent?
```

### Available Agent Categories

Browse the full list in **AGENTS.md**:

- **Engineering** (26) — All aspects of software development, DevOps, infra, databases, and specialized tech
- **Design** (9) — UI/UX, visual design, brand, accessibility, and design-to-code
- **Testing** (8) — QA, accessibility audits, performance, and test automation
- **Marketing** (13) — Content, social, SEO, growth, and campaign strategies
- **Product** (6) — Strategy, prioritization, research, feedback synthesis
- **Project Management** (5) — Planning, tracking, studio operations, executive leadership
- **Support & Operations** (7) — Analytics, finance, compliance, legal, infrastructure, support
- **Shopify** (3) — Shopify-specific development and theme management
- **Specialized** (16) — Security, blockchain, AI, MCP, Salesforce, and cultural intelligence
- **XR & Spatial** (6) — Apple Vision Pro, spatial computing, immersive experiences
- **Gaming** (5) — Game design, level design, narrative, audio, technical art
- **Paid Media** (7) — Advertising, programmatic buying, creative strategy, analytics
- **Other** (2) — Specialized domains like identity graphs and zero-knowledge proofs

### Quick Reference: Popular Agents

**For coding tasks:**
- `@engineering-code-reviewer` — Code review and quality feedback
- `@engineering-senior-developer` — Architecture and mentorship
- `@engineering-security-engineer` — Security review and hardening
- `@engineering-backend-architect` — Backend system design
- `@engineering-frontend-developer` — React, Vue, web development
- `@engineering-nextjs-specialist` — Full-stack Next.js development

**For design & UX:**
- `@design-ux-architect` — User experience and information architecture
- `@design-ui-designer` — Interface design and visual design
- `@design-figma-to-code-engineer` — Convert Figma to production code

**For product & growth:**
- `@product-manager` — Product strategy and roadmaps
- `@marketing-growth-hacker` — Growth strategies and tactics
- `@marketing-seo-specialist` — SEO and organic growth

**For testing & quality:**
- `@testing-accessibility-auditor` — Accessibility compliance
- `@testing-api-tester` — API testing and test automation
- `@testing-performance-benchmarker` — Performance optimization

**For operations:**
- `@support-infrastructure-maintainer` — System maintenance and monitoring
- `@support-legal-compliance-checker` — Legal and compliance review

### Agent Capabilities

Each agent has:

1. **Defined expertise** — Deep knowledge in their domain
2. **Consistent personality** — Predictable communication style (mentoring, no-nonsense, collaborative, etc.)
3. **Best practices** — Current industry standards and methodologies
4. **Edge case handling** — Guidance for complex or ambiguous scenarios
5. **Clear constraints** — What they will and won't do

### When to Use an Agent vs. Regular Claude

**Use an agent when:**
- You need focused, expert guidance in a specific domain
- You want consistent approach and methodology
- You're switching between different types of tasks
- You need to match a specific communication style
- You want domain-specific best practices applied

**Use regular Claude when:**
- You're doing general conversation or quick questions
- You're combining multiple domains (agents are focused)
- You need maximum flexibility in approach

### Creating New Agents

To create a new agent:

1. Create a `.md` file in `./agents/` with naming: `{category}-{agent-name}.md`
2. Include YAML frontmatter:
   ```yaml
   ---
   name: Display Name
   description: What this agent specializes in
   tools: []
   emoji: 🎯
   vibe: Brief personality note
   ---
   ```
3. Add detailed system prompt and instructions
4. Update **AGENTS.md** with the new entry
5. Commit and immediately available in Claude Code

See **AGENTS.md** for full agent list and format specification.

### Agent System Settings

All configuration is in `.claude/settings.json`:

- `agentsDir` — Path to agents directory (./agents)
- `registry` — Main agent registry file (AGENTS.md)
- `projectInstructions` — This file (CLAUDE.md)
- `capabilities.agentCount` — Current count (122)
- `invocationPatterns` — How to invoke agents

### Tips for Best Results

1. **Be specific** — Tell the agent exactly what you're working with
2. **Provide context** — Paste code, designs, or requirements the agent needs
3. **Follow their style** — Each agent has a preferred way of working; work with it
4. **Ask for methodology** — Agents often include specific processes; ask about them
5. **Combine agents** — For complex work, use multiple agents in sequence

Example workflow:
```
1. @product-manager — Define requirements
2. @design-ux-architect — Design the user experience
3. @engineering-backend-architect — Design backend
4. @engineering-frontend-developer — Build the interface
5. @testing-e2e-testing-specialist — Plan testing strategy
6. @engineering-code-reviewer — Review completed code
```

### Support & Troubleshooting

If an agent isn't loading or responding as expected:

1. Check that the agent file exists in `./agents/`
2. Verify the YAML frontmatter is correct
3. Ensure agent name matches the file name (without .md)
4. Try referencing the full file path: `./agents/{agent-name}.md`

For feedback or agent improvements, check AGENTS.md for the version and report issues accordingly.

---

**Version**: 1.0.0
**Last Updated**: 2026-04-07
**Total Agents**: 122
**Compatible Tools**: Claude Code, GitHub Copilot, Gemini CLI, Cursor, VS Code, Antigravity, OpenCode
