# Recommended Tools for Project Setup

> Tools we've personally tested. Not comprehensive -- just what works.

## MCP Servers

### [Playwright MCP](https://github.com/anthropics/mcp-playwright)
**What it does:** Gives Claude Code a real browser. Navigate pages, click elements, take screenshots, run visual tests.
**Why we use it:** Claude Code can verify its own frontend work. Instead of "looks right to me," it actually opens the page and checks. This is the single biggest quality improvement for web projects.
**Gotcha:** Adds ~15K tokens to tool definitions. Worth it for web projects, skip it for backend-only work.

### [Context7 MCP](https://github.com/anthropics/mcp-context7)
**What it does:** Pulls up-to-date library documentation directly into Claude Code's context.
**Why we use it:** Claude Code's training data has a cutoff. When you're using a library that shipped a breaking change last month, Context7 gives it the current docs.
**Gotcha:** Can be slow on large documentation sets. Best for targeted lookups, not "read the entire React docs."

## Project scaffolding

### .claude/ directory structure

The minimal setup that gives you the most leverage:

```
.claude/
  rules/           # context-specific instructions
  commands/        # reusable slash commands
  settings.json    # permissions and hooks
```

You don't need `skills/`, `agents/`, or `plugins/` on day one. Start with rules, commands, and settings. Add the rest when you have a specific use case.

## CLAUDE.md generators

Honestly, we recommend writing your own. The generators we tested produce verbose output that costs tokens on every turn. A hand-written 10-line CLAUDE.md that captures your project's essentials beats a generated 100-line version every time.

If you want a starting point, use our [CLAUDE.md Starter Kit](claude-md-starter/).

---

*Know a tool that improved your setup? [Submit a PR](../CONTRIBUTING.md).*
