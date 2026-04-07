# Recommended Tools for Token Management

> These are tools we've personally used. Not a comprehensive list -- just what actually helped.

## Monitoring

### [claude-meter](https://github.com/opslane/claude-meter)
Our own tool. Shows your real-time token usage that Anthropic tracks but doesn't surface in the UI. Useful for understanding where your limits actually go.

### [ClaudeCodeLog](https://x.com/ClaudeCodeLog)
Not a tool, but the best changelog tracker. Follows every Claude Code release and documents flag changes, CLI changes, and hidden features. Worth following if you want to know when behavior changes that might affect your token usage.

## Session management

### ENABLE_TOOL_SEARCH=true
Not a separate tool -- a built-in flag that lazy-loads MCP tool definitions instead of sending them all upfront. If you have 5+ MCP servers, this can save ~55K tokens per API call. Set it in your shell profile:

```bash
export ENABLE_TOOL_SEARCH=true
```

### Model switching
Built into Claude Code. Use `/model` to switch between Opus, Sonnet, and Haiku mid-session. The cheapest optimization is using the right model for the task.

---

*Know a tool that helped you manage Claude Code costs? [Submit a PR](../CONTRIBUTING.md).*
