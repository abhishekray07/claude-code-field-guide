# Prompt Caching

> Verified with Claude Sonnet 4.6, Anthropic SDK v0.69.0. Tested March 2026.

## The headline

Prompt caching reduces the cost of a 100-turn session from $50-100 to $10-19. That's an ~$80 savings per session. It's the single biggest reason Claude Code Pro at $20/month is economically viable.

But it's fragile. Changing two letters in your CLAUDE.md can break the entire cache.

## How it works

When you send a message to Claude, the system prompt, tools, and conversation history get sent as input. On the first call, Anthropic caches this input. On subsequent calls, if the prefix hasn't changed, the cached portion is read at 90% discount.

- **Cache write:** 1.25x the normal input cost (first time only)
- **Cache read:** 0.1x the normal input cost (every subsequent turn)
- **Cache TTL:** 5 minutes (resets on each hit)

In practice, turns 1-3 are expensive (writing the cache). Turns 4+ are cheap (reading from cache). A session that stays active gets a ~90% cache hit rate.

## What breaks the cache

The cache matches on an exact prefix. If anything in the prefix changes, the cache breaks from that point forward.

Things that break it:
- **Any edit to CLAUDE.md** -- even capitalization changes. We tested changing "Code" to "code" (two characters) and it broke 2,727 tokens of cached computation.
- **Adding or removing MCP servers** -- tool definitions are part of the prefix
- **Timestamps or dynamic content in system prompt** -- a HN user found they were busting cache every request because of a timestamp
- **Changing Claude Code settings mid-session** -- permission changes modify the system prompt

Things that don't break it:
- Your messages (they're appended, not prepended)
- File edits in your project
- Git operations
- New tool results

## What to do

1. **Don't edit CLAUDE.md mid-session.** Make changes, then start a new session.
2. **Keep CLAUDE.md stable.** Avoid dynamic content. No timestamps, no variables.
3. **Batch MCP server changes.** Add all your servers at once, not one at a time across sessions.
4. **Let sessions warm up.** The first 3 turns are expensive. Don't abandon sessions after 1-2 turns.

## The math

| Turn | Without caching | With caching (90% hit) | Savings |
|---|---|---|---|
| 1 | $1.00 | $1.25 (cache write) | -$0.25 |
| 10 | $10.00 | $2.15 | $7.85 |
| 50 | $50.00 | $8.50 | $41.50 |
| 100 | $100.00 | $14.50 | $85.50 |

The break-even point is around turn 3-4. After that, caching saves money on every turn.

---

*Full deep dive with cache behavior experiments: [Prompt Caching Deep Dive](https://claudecodecamp.com/blog/prompt-caching-deep-dive?utm_source=github&utm_medium=findings&utm_campaign=field-guide)*
