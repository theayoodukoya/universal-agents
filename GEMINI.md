# Gemini Code Assist & CLI Agent Instructions

This repository contains **122 specialized AI agents** designed to work seamlessly with Google's Gemini Code Assist and Gemini CLI to provide focused expertise across all software development and operations domains.

## Quick Start with Gemini

### Using Agents in Gemini CLI

Reference an agent directly in your prompt:

```
@agent-name [your task or question]
```

The Gemini CLI will load the specialized agent for focused assistance.

### Examples

**Code Review with Gemini:**
```
@engineering-code-reviewer

Review this authentication function for security issues:
[paste code]
```

**API Design:**
```
@engineering-backend-architect

Design a REST API for a real-time notification system with these requirements:
- 1M+ users
- Sub-second latency
- PostgreSQL + Redis
```

**UI Implementation:**
```
@design-figma-to-code-engineer

Convert this Figma design to React/Next.js:
[share design specs/link]
```

## Agent Categories & Quick Reference

### Engineering (26 agents)
Full-stack development, architecture, DevOps, databases, security, AI/ML

```
@engineering-code-reviewer              Code quality and reviews
@engineering-senior-developer           Architecture and mentorship
@engineering-security-engineer          Application security
@engineering-backend-architect          Backend systems design
@engineering-frontend-developer         Web development (React, Vue, etc.)
@engineering-nextjs-specialist          Next.js full-stack
@engineering-devops-automator           Infrastructure automation
@engineering-database-optimizer         Query and schema optimization
@engineering-ai-engineer                LLM integration and AI systems
@engineering-incident-response-commander Incident management
@engineering-ci-cd-pipeline-architect   CI/CD design
@engineering-aws-ecosystem-architect    AWS architecture
@engineering-data-engineer              Data pipelines and ETL
@engineering-embedded-firmware-engineer Embedded systems
@engineering-git-workflow-master        Git workflows
@engineering-software-architect         System architecture
@engineering-sre                        Site reliability
@engineering-mobile-app-builder         Mobile development
@engineering-flutter-developer          Flutter cross-platform
@engineering-react-native-developer     React Native
@engineering-rapid-prototyper           MVP and prototyping
@engineering-shopify-liquid-expert      Shopify theme development
@engineering-bigquery-analyst           BigQuery and data warehousing
@engineering-autonomous-optimization-architect  Self-tuning systems
@engineering-ai-data-remediation-engineer      ML data preparation
@engineering-threat-detection-engineer Threat detection and monitoring
@engineering-semantic-accessibility-specialist Accessibility implementation
@engineering-e2e-testing-specialist     End-to-end testing
```

### Design (9 agents)
UI/UX, visual design, accessibility, brand, design systems

```
@design-ux-architect                User experience and flows
@design-ui-designer                 Visual interface design
@design-figma-to-code-engineer      Figma to production code
@design-ux-researcher               User research and testing
@design-inclusive-visuals-specialist Accessibility and inclusive design
@design-brand-guardian              Brand consistency
@design-visual-storyteller          Visual communication
@design-image-prompt-engineer       AI image generation prompts
@design-whimsy-injector             Personality and delight
```

### Testing (8 agents)
QA, accessibility, performance, test automation

```
@testing-accessibility-auditor          WCAG compliance
@testing-api-tester                     API testing
@testing-e2e-testing-specialist         E2E test design
@testing-performance-benchmarker        Performance measurement
@testing-test-results-analyzer          Test analysis
@testing-workflow-optimizer             Testing workflow
@testing-tool-evaluator                 Tool comparison
@testing-evidence-collector             Test documentation
```

### Product (6 agents)
Strategy, prioritization, research, feedback

```
@product-manager                    Strategy and roadmaps
@product-sprint-prioritizer         Feature prioritization
@product-feedback-synthesizer       Customer feedback analysis
@product-ideation-brainstorm-architect  Brainstorming
@product-trend-researcher           Market research
@product-behavioral-nudge-engine    User behavior optimization
```

### Marketing (13 agents)
Content, SEO, social, growth, advertising

```
@marketing-growth-hacker            Growth strategies
@marketing-seo-specialist           SEO and organic search
@marketing-content-creator          Content production
@marketing-social-media-strategist  Social strategy
@marketing-app-store-optimizer      App store optimization
@marketing-tiktok-strategist        TikTok strategy
@marketing-linkedin-content-creator B2B content
@marketing-instagram-curator        Instagram strategy
@marketing-twitter-engager          Twitter engagement
@marketing-reddit-community-builder Community building
@marketing-carousel-growth-engine   Carousel content
@marketing-book-co-author           Long-form content
@marketing-cross-border-ecommerce   International commerce
@marketing-ai-citation-strategist   AI content strategy
@marketing-short-video-editing-coach Short-form video
```

### Project Management (5 agents)
Leadership, planning, operations, producer

```
@project-manager-senior                    Executive leadership
@project-management-project-shepherd       Project execution
@project-management-jira-workflow-steward  Workflow optimization
@project-management-experiment-tracker     Experiment tracking
@project-management-studio-operations      Studio operations
@project-management-studio-producer        Creative production
```

### Support & Operations (7 agents)
Analytics, finance, infrastructure, legal, compliance

```
@support-infrastructure-maintainer   System maintenance
@support-analytics-reporter          Analytics and reporting
@support-finance-tracker             Financial tracking
@support-legal-compliance-checker    Legal and compliance
@support-executive-summary-generator Report generation
@support-support-responder           Customer support
@report-distribution-agent           Report distribution
```

### Specialized (16 agents)
Security, blockchain, AI, MCP, Salesforce, culture

```
@agentic-identity-trust              Identity verification
@agents-orchestrator                 Agent coordination
@automation-governance-architect     Governance frameworks
@blockchain-security-auditor         Blockchain security
@compliance-auditor                  Compliance audits
@data-consolidation-agent            Data consolidation
@identity-graph-operator             Identity graphs
@lsp-index-engineer                  LSP implementation
@specialized-cultural-intelligence-strategist  Cultural insights
@specialized-developer-advocate      Developer relations
@specialized-document-generator      Documentation
@specialized-french-consulting-market French market expertise
@specialized-korean-business-navigator Korean business
@specialized-mcp-builder             MCP development
@specialized-model-qa                Model quality assurance
@specialized-salesforce-architect    Salesforce design
@specialized-workflow-architect      Workflow automation
@accounts-payable-agent              AP management
@sales-data-extraction-agent         Sales data
@zk-steward                          Zero-knowledge proofs
```

### XR & Spatial (6 agents)
Apple Vision Pro, visionOS, spatial computing, immersive

```
@visionos-spatial-engineer           Vision Pro development
@xr-immersive-developer              XR/AR/VR experiences
@xr-interface-architect              Spatial UI design
@xr-cockpit-interaction-specialist   Cockpit interfaces
@macos-spatial-metal-engineer        macOS spatial computing
@terminal-integration-specialist     Terminal integration
```

### Gaming (5 agents)
Game design, levels, narrative, audio, technical art

```
@game-designer                  Game mechanics
@level-designer                 Level and environment design
@narrative-designer             Story and dialogue
@game-audio-engineer            Audio design
@technical-artist               Technical art tools
```

### Paid Media (7 agents)
Advertising, creative, PPC, programmatic

```
@paid-media-ppc-strategist              Search advertising
@paid-media-creative-strategist         Ad creative
@paid-media-paid-social-strategist      Social advertising
@paid-media-auditor                     Campaign audits
@paid-media-programmatic-buyer          Programmatic buying
@paid-media-tracking-specialist         Attribution and tracking
@paid-media-search-query-analyst        Search analysis
```

### Shopify (3 agents)
Theme development, sections, optimization

```
@shopify-impulse-section-steward        Dynamic sections
@shopify-impulse-theme-regression-reviewer  Theme testing
```

### Other (2 agents)
```
@identity-graph-operator        Identity management
@zk-steward                     Zero-knowledge proofs
```

## Invocation Patterns

### Pattern 1: Direct Agent Call
```
@agent-name: [your request]
```

Best for interactive dialogue. Example:
```
@engineering-database-optimizer: These queries are slow. Can you help?
[paste queries and schema]
```

### Pattern 2: Multi-Agent Workflow
Chain agents for complex tasks:

```
@product-manager: Define requirements for a real-time collaboration feature
[requirements description]

Then:
@design-ux-architect: Design the user experience
[use requirements from product manager]

Then:
@engineering-backend-architect: Design the backend
[use design from UX architect]

Then:
@engineering-frontend-developer: Implement the frontend
[use design from UX architect]
```

### Pattern 3: Specific Problem
Reference agent with problem context:

```
@engineering-security-engineer: Review this for vulnerabilities
[paste code]

The system handles: [describe data/access]
Threat model: [describe threats]
```

## Common Gemini CLI Workflows

### Security Hardening
```bash
# Step 1: Find vulnerabilities
@engineering-security-engineer

Review this codebase for security issues:
[paste code or describe architecture]

# Step 2: Get detection strategy
@engineering-threat-detection-engineer

Design monitoring and alerting for identified threats

# Step 3: Verify implementation
@engineering-security-engineer

Review this hardening implementation:
[paste code]
```

### API Development
```bash
# Step 1: Design the API
@engineering-backend-architect

Design a REST API for [purpose] with these constraints:
[list requirements and constraints]

# Step 2: Implement
@engineering-backend-patterns-architect

Design the implementation using best patterns

# Step 3: Test
@testing-api-tester

How should we test this API design?
```

### Performance Optimization
```bash
# Step 1: Measure
@testing-performance-benchmarker

Establish baseline performance for:
[describe system and metrics]

# Step 2: Optimize
@engineering-database-optimizer

These queries are slow:
[paste queries]

# Step 3: Verify
@testing-performance-benchmarker

Did our optimization work?
[paste new metrics]
```

## Best Practices

1. **Use exact agent names** from the list above (lowercase, hyphens)
2. **Include context** — Code, requirements, constraints, current state
3. **Be specific** — What problem are you solving? What constraints exist?
4. **Follow methodology** — Ask agents about their process/framework
5. **Iterate** — Use follow-up prompts to dig deeper
6. **Combine agents** — Use multiple agents for complex problems

### Example: Good Context

```
@engineering-nextjs-specialist

Building a real-time dashboard with:
- 10K+ concurrent users
- Live data updates (< 500ms latency)
- PostgreSQL backend with Prisma ORM
- WebSocket connections

Current issues:
1. Page load takes 5 seconds
2. WebSocket memory leaks after 24h

Here's the current architecture:
[describe or paste]

Can you help optimize?
```

### Example: Poor Context

```
@engineering-nextjs-specialist

My app is slow, help fix it
```

Better context → better solutions.

## Tips for Different Tasks

### Code Review
Provide:
- Actual code
- What it's supposed to do
- Any concerns you have
- Performance/security context

### Architecture Design
Provide:
- System requirements
- Scale/performance goals
- Technology constraints
- Current architecture (if exists)

### Performance Optimization
Provide:
- Current metrics/benchmarks
- Problem symptoms
- Code or queries involved
- Target metrics

### Security Assessment
Provide:
- Code or description
- Type of data handled
- User access patterns
- Threat model

## Finding Agents

Complete registry with descriptions:

**AGENTS.md** — All 122 agents organized by category

Agents directory:
```
agents/
├── engineering-*.md          (26 agents)
├── design-*.md              (9 agents)
├── testing-*.md             (8 agents)
├── marketing-*.md           (13 agents)
├── product-*.md             (6 agents)
├── project-management-*.md  (5 agents)
├── support-*.md             (7 agents)
├── paid-media-*.md          (7 agents)
├── shopify-*.md             (3 agents)
├── xr-*.md                  (6 agents)
├── game-*.md                (5 agents)
├── specialized-*.md         (16 agents)
└── other-*.md               (2 agents)
```

## Configuration for Gemini

This agent system integrates with Gemini:

- **Location**: `agents/` directory
- **Registry**: `AGENTS.md`
- **Format**: Markdown with YAML frontmatter
- **Version**: 1.0.0
- **Total agents**: 122
- **Compatible with**: Gemini Code Assist, Gemini CLI, and all major AI tools

## Tool Integration

Agents work with Gemini's capabilities:

- **Code understanding** — Analyze and review code
- **API documentation** — Design and document APIs
- **Architecture design** — System and solution design
- **Security review** — Vulnerability and threat assessment
- **Performance optimization** — Profiling and tuning
- **Testing strategy** — QA and test design
- **Documentation** — Technical writing and specs

## Troubleshooting

**Agent not found:**
- Check spelling and use hyphens (not underscores)
- Refer to `AGENTS.md` for correct names
- All agent names are lowercase

**Generic response:**
- Add more context (code, requirements, constraints)
- Be specific about the problem
- Ask follow-up questions

**Need different expertise:**
- Browse agents by category in quick reference
- Try related agents in the same domain
- Create a custom agent if needed

## Creating Custom Agents

To create a new agent for Gemini:

1. Create `agents/{category}-{name}.md`
2. Add YAML frontmatter:
   ```yaml
   ---
   name: Display Name
   description: Brief description
   tools: []
   emoji: 🎯
   vibe: Personality trait
   ---
   ```
3. Add detailed system prompt and instructions
4. Update `AGENTS.md` registry
5. Commit and available in Gemini CLI immediately

See `AGENTS.md` for agent format specification.

## For More Information

- **Full list & categories**: `AGENTS.md`
- **Claude Code instructions**: `CLAUDE.md`
- **GitHub Copilot instructions**: `.github/copilot-instructions.md`
- **Cursor rules**: `.cursor/rules/agents.mdc`
- **Setup & installation**: `README.md`
- **Individual agents**: See `agents/` directory

---

**Last Updated**: 2026-04-07
**Total Agents**: 122
**Version**: 1.0.0
**Compatible Tools**: Gemini CLI, Gemini Code Assist, Claude Code, GitHub Copilot, Cursor, VS Code, Antigravity, OpenCode
