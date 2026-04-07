# Configs That Save Tokens

> Copy-paste these into your CLAUDE.md or settings. Each one has been tested with before/after data.

## Keep CLAUDE.md concise

Every token in your CLAUDE.md is sent on every API call. A 2,000-token CLAUDE.md costs ~$0.003/turn on Opus. Sounds small, but over 100 turns that's $0.30 just for your instructions.

**Before:** A 3-page CLAUDE.md with coding style guides, project history, and team norms.

**After:** Move verbose content to `.claude/rules/` files. CLAUDE.md stays under 500 tokens with high-signal instructions only.

```markdown
# CLAUDE.md (lean version)

## Project
Next.js 15 app with TypeScript. Uses shadcn/ui, Tailwind, Drizzle ORM.

## Rules
- Run `bun test` before claiming anything works
- Never modify migration files directly
- Use server components by default
```

Why this works: `.claude/rules/` files are loaded selectively based on context. CLAUDE.md is loaded on every single turn.

## Limit MCP servers per project

**Before:** 12 MCP servers in `.mcp.json` -- Slack, GitHub, Sentry, Firecrawl, Playwright, etc. Every API call sends all 12 tool definitions (~120K tokens).

**After:** Only 3-4 servers that this project actually needs. Personal tools go in `~/.claude/.mcp.json`.

```json
// .mcp.json (project-level, lean)
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-playwright"]
    }
  }
}
```

Or use lazy loading:

```bash
export ENABLE_TOOL_SEARCH=true
```

This tells Claude Code to lazy-load tool definitions instead of sending them all upfront. Saves ~55K tokens per call if you have 5+ MCP servers.

## Use .claude/rules/ for context-specific instructions

**Before:** Everything in CLAUDE.md (1,500 tokens, sent on every turn).

**After:** CLAUDE.md has 200 tokens of essentials. Detailed rules split into files:

```
.claude/
  rules/
    testing.md       # only loaded when working on tests
    api-patterns.md  # only loaded when editing API routes
    database.md      # only loaded when touching migrations
```

Each rule file is loaded only when Claude Code detects it's relevant. This can reduce per-turn overhead by 60-80% compared to a monolithic CLAUDE.md.

## Set thinking effort appropriately

If you're on Opus, thinking tokens are expensive. For routine tasks, low or medium effort produces identical results to high effort but runs 3.5x faster.

In your CLAUDE.md:

```markdown
## Thinking
- Use low effort for file reads, formatting, and simple edits
- Use medium effort for implementation and debugging  
- Reserve high effort for architecture decisions and complex reasoning
```

Or configure it globally in settings:

```json
{
  "thinking": {
    "effort": "medium"
  }
}
```

---

*Data behind these recommendations: [Session Economics](https://claudecodecamp.com/blog/context-management-deep-dive?utm_source=github&utm_medium=findings&utm_campaign=field-guide) and [Extended Thinking Deep Dive](https://claudecodecamp.com/blog/extended-thinking-deep-dive?utm_source=github&utm_medium=findings&utm_campaign=field-guide)*
