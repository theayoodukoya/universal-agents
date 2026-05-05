# Universal Agents — Team Summary

We built a unified **123-agent AI system** that automatically selects the right expert for any coding task. Works across 7 development tools and IDEs without tool-specific configuration.

**Supported IDEs & Tools:**
- Claude Code (CLI and VS Code Extension)
- GitHub Copilot
- Cursor
- Visual Studio Code
- Gemini CLI / Code Assist
- Codex
- Antigravity
- OpenCode

**What You Get:**

**Agent Library (123 Total):**
- Engineering: 31 agents (architecture, backend, frontend, databases, DevOps, security, AI/ML)
- Design: 9 agents (UX/UI, visual design, accessibility, Figma-to-Code, design systems)
- Testing: 8 agents (QA, E2E testing, accessibility audits, performance)
- Marketing: 13 agents (content, SEO, growth, campaigns, analytics)
- Product & Operations: 11 agents (strategy, prioritization, analytics, compliance)
- Shopify Specialists: 3 agents (Liquid development, theme coding, platform expertise)
- Specialized: 18 agents (debugging, blockchain, AI, MCP, Salesforce, security)

**Core Capabilities:**
- Auto-dispatch system — describe your task, AI automatically selects the right agent
- Full-stack debugging agent — uses RIPF methodology with parallel hypothesis testing and binary search isolation
- Cross-platform support — consistent behavior across Mac, Linux, and Windows
- Merge-safe installation — doesn't overwrite existing project configurations
- Interactive agent discovery — fuzzy search, category browsing, and keyword lookup

**Installation:**
```bash
curl -fsSL https://raw.githubusercontent.com/theayoodukoya/universal-agents/main/install.sh | bash
```

**Maintenance Commands:**
```bash
update-agents   # Update to latest version
remove-agents   # Clean removal
./agent-pick.sh # Interactive agent discovery
```

**Transformation (113 → 123 Agents):**
- Sanitized all agents: removed security vulnerabilities (unsafe eval patterns), hardcoded paths, and model-specific fields
- Consolidated duplicates: merged 3 overlapping Shopify agents into unified specialist
- Added 12 new specialist agents including Next.js specialist, BigQuery analyst, AWS architect, React Native developer, Flutter developer, Figma-to-Code engineer, E2E testing specialist, semantic accessibility specialist, backend patterns architect, CI/CD pipeline architect, full-stack debugger, and ideation architect
- Built machine-readable agent manifest with keyword matching and context detection
- Created tool-specific configurations for seamless integration with each IDE
- Implemented merge-safe installer with automatic backups and conflict prevention

**Repository:** https://github.com/theayoodukoya/universal-agents

**Value Proposition:** Unified agent system eliminates tool-specific management overhead. Auto-dispatch removes the requirement to memorize or manually reference 120+ agent names. Teams can reference natural language task descriptions and the system automatically selects the appropriate specialized agent.
