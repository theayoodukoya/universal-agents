# Universal Agents Registry

This is the universal agent system recognized by Codex (CLI + VSCode), GitHub Copilot, Claude Code, Gemini CLI, Cursor, Antigravity, OpenCode, and all major AI coding tools. The current agent count is always in `agents-manifest.json` → `total`.

**Agent discovery**: Read `agents-manifest.json` once to select the right agent, then load only that agent's `.md` file. Do NOT scan the `agents/` folder directly — it contains 100+ files and reading them all wastes significant context and tokens.

**Full agent path**: `./agents/{agent-name}.md` (all files are at the repo root in `agents/`)

## Quick Start

**Agents are specialized prompt-based experts** located in `./agents/` directory. To invoke an agent:
- **Codex (CLI + VSCode plugin)**: Reads this AGENTS.md automatically at startup. Reference agents with `@agent-name`. Supports `~/.codex/AGENTS.md` for global config and `AGENTS.override.md` for overrides.
- **GitHub Copilot (Custom Agents)**: Uses `.github/agents/*.agent.md` files. Invoke with `@agent-name` in Copilot Chat.
- **Claude Code / Claude CLI**: Reference with `@agent-name` or load from `.claude/agents/`. Supports `CLAUDE.md` for project instructions.
- **Gemini CLI / Gemini Code Assist**: Reads `GEMINI.md` and `.gemini/agents/`. Use `@agent-name` in chat.
- **Cursor**: Uses `.cursor/rules/*.mdc` rule files. Agents load contextually based on glob patterns.
- **Antigravity**: Reads this AGENTS.md automatically (v1.20.3+). Also supports GEMINI.md.
- **OpenCode**: Reads this AGENTS.md from project root. Use `@agent-name` in chat.

---

## Engineering (31 agents)

- **engineering-ai-engineer** — Expert in LLM integration, prompt engineering, and AI system design
- **engineering-ai-data-remediation-engineer** — Specializes in cleaning, validating, and preparing data for ML/AI systems
- **engineering-autonomous-optimization-architect** — Designs self-tuning systems that optimize performance without manual intervention
- **engineering-aws-ecosystem-architect** — AWS expert covering infrastructure, services, and cloud-native patterns
- **engineering-backend-architect** — Designs scalable, maintainable backend systems and APIs
- **engineering-backend-patterns-architect** — Focuses on architectural patterns, SOLID principles, and system design
- **engineering-bigquery-analyst** — Expert in Google BigQuery, data warehousing, and analytical SQL
- **engineering-ci-cd-pipeline-architect** — Designs and optimizes continuous integration and deployment pipelines
- **engineering-code-reviewer** — Provides constructive code reviews focusing on correctness, security, maintainability
- **engineering-data-engineer** — Builds data pipelines, ETL systems, and data infrastructure
- **engineering-database-optimizer** — Optimizes database queries, indexing, and schema design
- **engineering-devops-automator** — Automates infrastructure, deployment, and operational tasks
- **engineering-e2e-testing-specialist** — Designs and implements end-to-end testing strategies
- **engineering-embedded-firmware-engineer** — Develops embedded systems, firmware, and hardware integration
- **engineering-flutter-developer** — Expert in Flutter framework for cross-platform mobile development
- **engineering-fullstack-debugger** — Elite debugging specialist that systematically isolates root causes across the entire stack using binary search methodology, parallel hypothesis testing, and reproduction-first principles
- **engineering-frontend-developer** — Full-stack frontend expertise across web technologies
- **engineering-git-workflow-master** — Expert in Git workflows, branching strategies, and version control
- **engineering-incident-response-commander** — Leads incident response, post-mortems, and reliability improvements
- **engineering-mobile-app-builder** — Specializes in native and cross-platform mobile application development
- **engineering-nextjs-specialist** — Expert in Next.js, React, and modern full-stack web development
- **engineering-rapid-prototyper** — Builds MVPs and prototypes quickly to validate ideas
- **engineering-react-native-developer** — Expert in React Native for cross-platform mobile development
- **engineering-security-engineer** — Focuses on application security, vulnerability assessment, and secure coding
- **engineering-semantic-accessibility-specialist** — Ensures products are accessible and semantically correct
- **engineering-senior-developer** — Expert technical leadership, mentoring, and architectural guidance
- **engineering-shopify-liquid-expert** — Specializes in Shopify theme development using Liquid templates
- **engineering-software-architect** — Designs overall software systems, scalability, and technical strategy
- **engineering-solidity-smart-contract-engineer** — Expert in Solidity development and smart contract programming
- **engineering-sre** — Site Reliability Engineer focused on system reliability, monitoring, and operational excellence
- **engineering-technical-writer** — Creates technical documentation, specifications, and guides
- **engineering-threat-detection-engineer** — Designs threat detection systems and anomaly detection mechanisms

---

## Design (9 agents)

- **design-brand-guardian** — Ensures design consistency and brand integrity across all touchpoints
- **design-figma-to-code-engineer** — Converts Figma designs into production-ready code
- **design-image-prompt-engineer** — Creates detailed prompts for AI image generation and design iteration
- **design-inclusive-visuals-specialist** — Designs accessible, inclusive visual content for all users
- **design-ui-designer** — Creates user interfaces with attention to usability and aesthetics
- **design-ux-architect** — Designs user experiences and information architecture
- **design-ux-researcher** — Conducts user research and translates insights into design decisions
- **design-visual-storyteller** — Crafts compelling visual narratives and brand storytelling
- **design-whimsy-injector** — Adds personality, delight, and unexpected moments to products

---

## Testing (8 agents)

- **testing-accessibility-auditor** — Audits accessibility compliance and creates remediation strategies
- **testing-api-tester** — Specializes in API testing, integration testing, and test automation
- **testing-evidence-collector** — Gathers and documents test evidence for compliance and reporting
- **testing-performance-benchmarker** — Measures, analyzes, and optimizes system performance
- **testing-reality-checker** — Validates ideas, assumptions, and features in real-world conditions
- **testing-test-results-analyzer** — Analyzes test results and identifies root causes of failures
- **testing-tool-evaluator** — Evaluates testing tools, frameworks, and compares their strengths
- **testing-workflow-optimizer** — Optimizes testing workflows and development processes

---

## Marketing (13 agents)

- **marketing-ai-citation-strategist** — Develops AI content strategies with proper attribution and sourcing
- **marketing-app-store-optimizer** — Optimizes app listings on Apple App Store and Google Play
- **marketing-book-co-author** — Collaborates on long-form content and book writing
- **marketing-carousel-growth-engine** — Creates carousel content strategies for social media growth
- **marketing-content-creator** — Produces high-quality written and multimedia content
- **marketing-cross-border-ecommerce** — Specializes in international ecommerce marketing and localization
- **marketing-growth-hacker** — Develops rapid growth strategies and unconventional marketing tactics
- **marketing-instagram-curator** — Strategizes and creates content for Instagram engagement
- **marketing-linkedin-content-creator** — Creates B2B thought leadership and LinkedIn content
- **marketing-reddit-community-builder** — Builds and nurtures communities on Reddit and similar platforms
- **marketing-seo-specialist** — Optimizes content for search engines and organic visibility
- **marketing-short-video-editing-coach** — Coaches on creating short-form video content (TikTok, Reels, Shorts)
- **marketing-social-media-strategist** — Develops comprehensive social media strategies and campaigns
- **marketing-tiktok-strategist** — Specializes in TikTok trends, virality, and audience engagement
- **marketing-twitter-engager** — Creates Twitter content strategies and engagement tactics

---

## Product (6 agents)

- **product-behavioral-nudge-engine** — Designs subtle product nudges that improve user behavior
- **product-feedback-synthesizer** — Synthesizes customer feedback into actionable insights
- **product-ideation-brainstorm-architect** — Facilitates creative brainstorming and ideation sessions
- **product-manager** — Strategic product management with focus on market fit and roadmaps
- **product-sprint-prioritizer** — Prioritizes features using frameworks like RICE and value mapping
- **product-trend-researcher** — Researches trends and translates them into product strategy

---

## Project Management (5 agents)

- **project-management-experiment-tracker** — Tracks experiments, variants, and A/B testing results
- **project-management-jira-workflow-steward** — Optimizes Jira workflows and project management practices
- **project-management-project-shepherd** — Guides projects through planning, execution, and delivery
- **project-management-studio-operations** — Manages studio operations, resources, and capacity planning
- **project-management-studio-producer** — Produces content, oversees creative projects, and quality assurance
- **project-manager-senior** — Executive-level project leadership, stakeholder management, and strategy

---

## Support & Operations (7 agents)

- **support-analytics-reporter** — Creates analytics dashboards and reports for business insights
- **support-executive-summary-generator** — Generates executive summaries and high-level reports
- **support-finance-tracker** — Tracks finances, budgets, and financial reporting
- **support-infrastructure-maintainer** — Maintains infrastructure, monitors systems, and handles maintenance
- **support-legal-compliance-checker** — Ensures legal compliance and reviews compliance requirements
- **support-support-responder** — Responds to customer support requests and issues
- **report-distribution-agent** — Distributes reports and coordinates information flow

---

## Shopify (3 agents)

- **shopify-impulse-section-steward** — Designs and manages dynamic Shopify sections for product experience
- **shopify-impulse-theme-regression-reviewer** — Tests and ensures theme quality across Shopify updates

---

## Paid Media (7 agents)

- **paid-media-auditor** — Audits paid media campaigns for performance and optimization
- **paid-media-creative-strategist** — Develops creative strategies for paid media campaigns
- **paid-media-paid-social-strategist** — Specializes in paid social media advertising
- **paid-media-ppc-strategist** — Expert in pay-per-click advertising and search marketing
- **paid-media-programmatic-buyer** — Specializes in programmatic advertising and ad buying
- **paid-media-search-query-analyst** — Analyzes search queries and improves search campaign performance
- **paid-media-tracking-specialist** — Implements and manages conversion tracking and attribution

---

## Specialized (18 agents)

- **accounts-payable-agent** — Manages accounts payable processes and invoice handling
- **agentic-identity-trust** — Establishes identity verification and trust frameworks for systems
- **agents-orchestrator** — Orchestrates multiple agents and coordinates their interactions
- **automation-governance-architect** — Designs governance frameworks for automation systems
- **blockchain-security-auditor** — Audits blockchain security and smart contract vulnerabilities
- **compliance-auditor** — Conducts compliance audits and creates remediation plans
- **data-consolidation-agent** — Consolidates data from multiple sources for unified insights
- **lsp-index-engineer** — Designs and optimizes LSP (Language Server Protocol) implementations
- **sales-data-extraction-agent** — Extracts and processes sales data for analysis
- **specialized-cultural-intelligence-strategist** — Provides cultural insights for global products
- **specialized-developer-advocate** — Advocates for developers and builds developer communities
- **specialized-document-generator** — Generates documentation, specifications, and technical guides
- **specialized-french-consulting-market** — Specializes in French consulting market dynamics
- **specialized-korean-business-navigator** — Expert in Korean business practices and culture
- **specialized-mcp-builder** — Develops MCP (Model Context Protocol) integrations and servers
- **specialized-model-qa** — Conducts quality assurance for AI models and LLM outputs
- **specialized-salesforce-architect** — Designs and builds Salesforce implementations
- **specialized-workflow-architect** — Designs workflow automation and process optimization

---

## XR & Spatial (6 agents)

- **macos-spatial-metal-engineer** — Expert in spatial computing on macOS using Metal and SwiftUI
- **terminal-integration-specialist** — Integrates spatial computing with terminal and CLI tools
- **visionos-spatial-engineer** — Develops spatial experiences for Apple Vision Pro and visionOS
- **xr-cockpit-interaction-specialist** — Designs cockpit-style interactions for XR interfaces
- **xr-immersive-developer** — Develops immersive XR/AR/VR experiences and applications
- **xr-interface-architect** — Designs user interfaces optimized for spatial computing

---

## Gaming (5 agents)

- **game-audio-engineer** — Designs and implements audio for games and interactive experiences
- **game-designer** — Designs gameplay mechanics, systems, and player experiences
- **level-designer** — Creates levels, environments, and play spaces for games
- **narrative-designer** — Designs narratives, dialogue, and storytelling for games
- **technical-artist** — Creates tools, shaders, and technical solutions for game development

---

## Other (2 agents)

- **identity-graph-operator** — Manages identity graphs and relationship mapping systems
- **zk-steward** — Manages zero-knowledge proofs and privacy-preserving systems

---

## How to Use Agents

### In Claude Code
```
@agent-name: I need help with [task]
```
Or reference directly:
```
I need help with code review. Reference ./agents/engineering-code-reviewer.md
```

### In GitHub Copilot
```
// @agent-name
// Task description
```

### In Gemini CLI
```
@agent-name [your prompt]
```

### In Cursor
Use the command palette or chat interface to reference agents by name.

### In VS Code
Use the Claude extension chat to reference agents by name.

---

## Adding New Agents

To add a new agent:

1. Create a markdown file in `./agents/` with the naming convention: `{category}-{agent-name}.md`
2. Include YAML frontmatter with: `name`, `description`, `tools`, `emoji`, `vibe`
3. Include detailed instructions and system prompt content
4. Update this AGENTS.md file with the new agent entry
5. Commit and the agent is immediately available

Example frontmatter:
```yaml
---
name: Agent Name
description: One-sentence description of what this agent does
tools: []
emoji: 🎯
vibe: Brief personality description
---
```

---

## Agent Format Specification

Each agent is a Markdown file containing:

```
---
name: Display Name
description: Concise description
tools: [optional list of tools]
emoji: 🔤
vibe: Personality note
---

# Agent Name

[Detailed instructions and system prompt]

## Your Identity & Memory
[Role and personality description]

## Your Core Mission
[Primary objectives]

## Critical Rules
[Important constraints and behaviors]

## How to Handle Edge Cases
[Guidance for complex scenarios]
```

---

## Version & Updates

**Current Version**: 1.0.0
**Last Updated**: 2026-04-07
**Agents Count**: 123 (31 Engineering, 9 Design, 8 Testing, 13 Marketing, 6 Product, 6 Project Management, 7 Support & Operations, 2 Shopify, 7 Paid Media, 18 Specialized, 6 XR & Spatial, 5 Gaming, 2 Other)

This agent system is designed for maximum interoperability and portability across all major AI coding tools. All agents follow consistent formatting and can be used across platforms seamlessly.
