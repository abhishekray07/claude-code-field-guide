# Recommended Tools for Token Management

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06
>
> These are tools we've personally used or verified. Not a comprehensive list -- just what actually helped.

## Monitoring & Cost Tracking

### [claude-meter](https://github.com/opslane/claude-meter)
Our own tool. Shows your real-time token usage that Anthropic tracks but doesn't surface in the UI. Useful for understanding where your limits actually go.

### [ccusage](https://github.com/ryoppippi/ccusage)
**What it does:** CLI tool that analyzes your Claude Code usage from local JSONL files. Daily, monthly, and session-based reports with cost tracking.
**Why it matters:** The best way to see where your tokens actually went after a session. Supports 5-hour billing window reports so you can see exactly how close you are to limits.
**Setup:** `npm install -g ccusage && ccusage`

### [Claude-Code-Usage-Monitor](https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor)
**What it does:** Real-time terminal monitor with burn rate tracking and ML-based predictions for when you'll hit limits.
**Why it matters:** Shows a live chart of token consumption, cost estimate, and time-to-limit predictions. The Custom plan mode analyzes your last 8 days of sessions to calculate personalized limits.

### [ccost](https://github.com/toolsu/ccost)
**What it does:** Blazing fast Rust CLI for analyzing Claude Code token usage and costs from conversation logs. Powers the CC Dashboard desktop app.
**Why it matters:** Faster than ccusage for large log volumes. Good complement if you have hundreds of sessions.

### [ClaudeCodeLog](https://x.com/ClaudeCodeLog)
Not a tool, but the best changelog tracker. Follows every Claude Code release and documents flag changes, CLI changes, and hidden features. Worth following if you want to know when behavior changes that might affect your token usage.

## Session Management

### ENABLE_TOOL_SEARCH=true
Not a separate tool -- a built-in flag that lazy-loads MCP tool definitions instead of sending them all upfront. If you have 5+ MCP servers, this can save ~55K tokens per API call. Set it in your shell profile:

```bash
export ENABLE_TOOL_SEARCH=true
```

### /cost and /context commands
Built into Claude Code. `/cost` shows total session cost, API duration, and code changes. `/context` breaks down token usage by category and shows how much context window you have left. Use `/context` mid-session to decide whether to continue or start fresh.

### Model switching
Built into Claude Code. Use `/model` to switch between Opus, Sonnet, and Haiku mid-session. Switching from Opus to Sonnet saves ~60% per turn ($0.078 → $0.030 avg). The cheapest optimization is using the right model for the task.

## Observability

### [claude-code-otel](https://github.com/ColeMurray/claude-code-otel)
**What it does:** Full observability solution using OpenTelemetry. Tracks spending across models, API requests, token breakdown by type, tool performance metrics.
**Good for:** Teams running multiple Claude Code sessions who want centralized monitoring. Overkill for solo use.

---

*Know a tool that helped you manage Claude Code costs? [Submit a PR](../CONTRIBUTING.md).*
