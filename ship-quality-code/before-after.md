# Before/After Showcases

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

Real examples showing what these configs actually change.

## 1. Monolithic CLAUDE.md vs Lean + Rules

**Before:** Everything in one CLAUDE.md (2,100 tokens)
```markdown
# My Project
[... 80 lines of coding standards, project history, team norms,
API patterns, database conventions, testing requirements ...]
```
- Cost per 100 turns (Opus 4.6): ~$0.32 just for CLAUDE.md overhead
- Claude Code loads all of it on every turn, even when editing CSS

**After:** Lean CLAUDE.md (280 tokens) + `.claude/rules/` files
```markdown
# My Project
Next.js 15, TypeScript, Tailwind, Drizzle ORM.
- Run `bun test` before claiming anything works
- Server components by default
```
With detailed rules split into context-specific files:
```
.claude/rules/
  api-patterns.md    # loaded only when editing API routes
  database.md        # loaded only when touching migrations
  testing.md         # loaded only when writing tests
```
- Cost per 100 turns: ~$0.04 for CLAUDE.md + selective rule loading
- **87% reduction in per-turn CLAUDE.md overhead**

## 2. All MCP servers vs Project-scoped

**Before:** 8 MCP servers in `.mcp.json` (every project gets everything)
```json
{
  "mcpServers": {
    "playwright": { "..." },
    "postgres": { "..." },
    "filesystem": { "..." },
    "slack": { "..." },
    "sentry": { "..." },
    "github": { "..." },
    "firecrawl": { "..." },
    "context7": { "..." }
  }
}
```
- ~120K tokens of tool definitions sent on every API call
- 60% of context window consumed before typing anything

**After:** 2 servers for this project + ENABLE_TOOL_SEARCH
```json
{
  "mcpServers": {
    "playwright": { "..." },
    "context7": { "..." }
  }
}
```
```bash
export ENABLE_TOOL_SEARCH=true
```
- ~30K tokens of tool definitions (with lazy loading)
- **75% reduction in tool definition overhead**
- More context available for your actual conversation

## 3. No hooks vs Auto-format + lint

**Before:** Write code, discover formatting issues in PR review, go back and fix.
- Extra round-trip session just for formatting
- 5-10 extra turns per session on formatting fixes

**After:** PostToolUse hooks auto-format and lint on every file write.
- Zero formatting turns needed
- Lint errors caught and fixed in the same turn they're introduced
- Cleaner git diffs (no mixed logic + formatting commits)

Typical session comparison:
| Metric | Without hooks | With hooks |
|---|---|---|
| Turns for a feature | 45 | 38 |
| Formatting fix turns | 7 | 0 |
| Lint issues in PR | 3-5 | 0 |

---

*Have a before/after to share? [Submit a PR](../CONTRIBUTING.md).*
