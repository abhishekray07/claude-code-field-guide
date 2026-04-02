# MCP Configs

> Working .mcp.json configs we use daily. Copy-paste and customize.

## What is .mcp.json?

MCP (Model Context Protocol) lets Claude Code use external tools -- browsers, databases, APIs, file systems. The `.mcp.json` file in your project root configures which MCP servers are available.

**Important:** Each MCP server adds ~150 tokens of tool definitions to every API call. Five servers = ~55K tokens = 28% of your 200K context window. Only add servers you'll actually use in this project.

## Project-level config (.mcp.json)

Place this in your project root. Only include servers this project needs.

### Web development (Playwright for testing)

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-playwright"]
    }
  }
}
```

Use for: visual testing, clicking through UI flows, taking screenshots to verify frontend work.

### Database projects (PostgreSQL)

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    }
  }
}
```

Use for: exploring schema, running queries, debugging data issues. Don't use in production.

### Documentation projects (Context7)

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-context7"]
    }
  }
}
```

Use for: pulling up-to-date library documentation without Claude Code having to search the web.

## Global config (~/.claude/.mcp.json)

Servers you want available in every project. Keep this minimal.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-filesystem", "/Users/you/Projects"]
    }
  }
}
```

## Managing context costs

If you have 5+ MCP servers, use lazy loading:

```bash
export ENABLE_TOOL_SEARCH=true
```

This tells Claude Code to only load tool definitions when they're needed, instead of sending all of them on every API call. Saves significant context.

## Common mistake

Don't copy-paste a `.mcp.json` with 10 servers from a tutorial. Each server you add costs tokens on every turn, even if you never use it. Start with zero and add servers only when you hit a task that needs one.

---

*Have a working MCP config for a common use case? [Submit a PR](../CONTRIBUTING.md).*
