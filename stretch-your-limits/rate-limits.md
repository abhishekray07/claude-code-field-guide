# Rate Limit Survival Guide

> Verified with Claude Code v2.1.87, Pro and Max plans. April 2026.

## Why you hit limits in 13 minutes

The #1 complaint on Reddit: "I used 100% of my session in 13 minutes." Here's what's actually happening.

Your rate limit is based on **tokens consumed**, not time or number of messages. A single complex request can burn through 50% of your limit if it triggers a long chain of tool calls with large context.

The three biggest token sinks:

1. **Mega-sessions** -- by turn 80, every message sends the entire conversation history. One turn can cost as much as your first 10 turns combined.
2. **MCP server tool definitions** -- 5 MCP servers add ~55K tokens to every single API call. That's 28% of the 200K context window consumed before you type anything.
3. **Extended thinking on Opus** -- thinking tokens bill at the output rate ($15/MTok on Opus 4.6). Opus with "high" effort can generate thousands of thinking tokens you never see.

## How to detect you're burning fast

Watch for these signals:
- **Session percentage jumping in large increments** (10-20% per message)
- **"Conversation compacted" message** -- this means you've filled the context window and Claude Code compressed it. Your per-turn cost just spiked.
- **Long pauses before responses** -- large context = more processing time

## Session structuring strategies

### Break sessions by task

Don't: one mega-session for "build the entire feature."
Do: separate sessions for "plan the approach," "implement the core logic," "write tests," "refactor."

Each new session starts with a fresh, small context. Turns 4-40 are the cheapest range.

### Use the right model for the job

| Task | Model | Why |
|---|---|---|
| Architecture, complex debugging | Opus | Worth the cost for hard reasoning |
| Day-to-day coding | Sonnet | 3x cheaper, fast, good enough for most work |
| Boilerplate, formatting, lookups | Haiku | 26x cheaper than Opus |

Switching Opus to Sonnet for routine work saves more than any other single change.

### Manage MCP servers

If you have 10+ MCP servers configured, each API call includes all their tool definitions. Options:

- **Use `ENABLE_TOOL_SEARCH=true`** -- Claude Code will lazy-load tools instead of sending all definitions upfront
- **Keep project `.mcp.json` minimal** -- only the servers you actually need for this project
- **Use global `~/.claude/.mcp.json` for personal tools** and project-level for shared ones

### Understand compaction

When your conversation fills the context window, Claude Code "compacts" it -- compressing the history into a summary. After compaction:

- Cache is broken (the prefix changed)
- Per-turn cost spikes (~$0.29/turn vs $0.11 pre-compaction)
- Some context is lost in the summary

If you see "Conversation compacted," consider whether it's cheaper to start a new session.

## The session sweet spot

Based on our data across 518 sessions:

```
Turns 1-3:     Expensive (cache warming)
Turns 4-40:    Cheapest range ($0.08-0.11/turn on Opus 4.6)
Turns 40-60:   Still good, costs rising
Turns 60-80:   Getting expensive, watch closely
Turns 80+:     Mega-session territory. 92% of spend happens here.
```

Target 40-60 turns per session. Start fresh for new tasks.

---

*Full data and methodology: [The Economics of a Claude Code Session](https://claudecodecamp.com/blog/context-management-deep-dive?utm_source=github&utm_medium=findings&utm_campaign=field-guide)*
