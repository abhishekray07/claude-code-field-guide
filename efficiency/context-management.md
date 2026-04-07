# Context Management

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

## The headline

Your session has ~55-75K usable tokens for conversation, depending on MCP servers loaded. The cached prefix (system prompt, tool definitions, CLAUDE.md) consumes ~124K of the 200K context window. Every turn sends the entire conversation history. By turn 60, you're spending more on history than on actual work.

Managing context is the single biggest lever on both cost and output quality.

## How context fills up

Every API call in Claude Code sends:

```
First API call payload (~124K tokens total, cached after turn 1):
  System prompt text     ~2.5K tokens
  Built-in tool defs     ~14-17K tokens
  MCP tool defs          ~5-15K per server
  CLAUDE.md + rules      varies
  ─────────────────────────────────
  Total cached prefix    ~124K tokens (with default MCP setup)

+ Full conversation history (grows every turn)
+ Current message
= Total context per call
```

The 124K figure includes everything in the cached prefix: system prompt, tool definitions, MCP tools, and CLAUDE.md. It's all sent together on every call.

The 200K context window is the hard ceiling. Here's where you actually are at different points:

| Turn | Conversation history | Total context | Usable headroom |
|---|---|---|---|
| 1 | ~0K | ~145K | ~55K |
| 20 | ~15K | ~160K | ~40K |
| 40 | ~30K | ~175K | ~25K |
| 60 | ~45K | ~190K | ~10K |
| 80 | ~55K+ | ~200K | Compaction triggers |

These numbers assume no MCP servers. Each MCP server adds 5-15K tokens per turn (see [MCP Internals](../under-the-hood/mcp-internals.md)), which pushes you toward compaction faster.

## The cost curve

Token costs accelerate as context fills because Claude Code sends the full history on every call:

| Session phase | Turns | Cost per turn (Opus) | Why |
|---|---|---|---|
| Cache warming | 1-3 | ~$0.15-0.20 | Paying cache write cost |
| Sweet spot | 4-40 | ~$0.08-0.11 | Cached prefix, moderate history |
| Getting expensive | 40-60 | ~$0.11-0.18 | History growing, still cached |
| Mega-session | 60-80 | ~$0.18-0.29 | Large history, cache less effective |
| Post-compaction | 80+ | ~$0.29+ | Cache broken, rebuilding context |

The sweet spot is turns 4-40. This is where you get the most value per dollar: the system prompt is cached, and your conversation history is still small enough that each turn is cheap.

From [Session Cost Findings](findings.md): 92% of total spend across 518 tracked sessions came from mega-sessions (80+ turns). The remaining 8% covered all normal sessions.

## Compaction: what actually happens

When your context approaches the 200K limit, Claude Code triggers automatic compaction. Here's the sequence:

```
Context hits ~190K tokens
       │
       ▼
Claude Code summarizes conversation history
       │
       ▼
Summary replaces full history (~45K → ~3K)
       │
       ▼
Prompt cache breaks (cached prefix changes)
       │
       ▼
Next turn: full cache write cost again (~$0.78 on Opus)
       │
       ▼
Some context lost in summarization
```

After compaction:
- **Cost spikes.** The prompt cache breaks because the conversation prefix changed. You pay the full cache write cost again (~$0.78 on Opus), and subsequent turns run at higher rates until the cache warms back up.
- **Quality can degrade.** The summary is lossy. Specific decisions, file paths, and nuanced instructions from earlier in the session may be lost or simplified. Claude may re-read files it already read, or forget constraints you established.
- **It's not a reset.** Compaction keeps you in the same session with a compressed history. It's not the same as starting fresh, which gives you a clean context window and full prompt cache.

## /compact vs starting fresh

You have two options when context pressure builds:

**`/compact` (manual compaction)**
- Triggers the same compaction process, but on your terms
- Use it when you want to keep the session alive but free up space
- Good for: mid-task when you're 60+ turns in and still need the current conversation thread
- Cost: cache break (~$0.78) + some context loss

**Starting a new session**
- Clean 200K context window
- Fresh prompt cache (write cost on turn 1, then cheap reads)
- Good for: switching tasks, after completing a milestone, when quality is degrading
- Cost: cache write on turn 1 (~$0.78), but then cheap turns 2-40

**The decision framework:**

| Situation | Do this | Why |
|---|---|---|
| Completed a feature/milestone | Start fresh | Clean context, new task gets full attention |
| 60+ turns, still mid-task | /compact | Keep the thread, free up space |
| Quality noticeably degrading | Start fresh | Compaction won't fix accumulated confusion |
| About to start research | Start fresh | Research is better with clean context |
| Just need 10 more turns | /compact | Not worth the fresh-session overhead |

## Context degradation signals

Watch for these signs that your context is getting crowded:

1. **Repetitive output.** Claude starts repeating explanations or suggestions it already made. The conversation history is too long for it to track what's been said.

2. **Missed instructions.** Rules from your CLAUDE.md or earlier messages get ignored. They're still in context but buried under conversation history.

3. **Re-reading files.** Claude reads files it already read in the session. It lost track of what it learned earlier.

4. **Simplified responses.** Answers get shorter and less detailed. Claude is spending more output budget on processing the long context.

5. **Wrong file references.** Claude references files by incorrect names or paths, confusing details from different parts of the conversation.

If you see 2+ of these signals, start a new session. Compaction rarely fixes context degradation because the problem is accumulated noise, not just token count.

## Session structuring for maximum quality

Structure your work into focused sessions of 20-40 turns each:

**Session 1: Plan**
- Describe the feature/bug
- Let Claude explore the codebase
- Agree on an approach
- End session with a clear plan (write it to a file)

**Session 2: Implement**
- Reference the plan file
- Implement the changes
- Run verification (tests, types, lint)
- Commit working code

**Session 3: Review and refine**
- Review the implementation
- Fix edge cases
- Run full test suite
- Clean up

Each session starts with a clean context and full prompt cache. The plan file carries context between sessions without token overhead.

**Why this beats one long session:** A 120-turn implementation session costs ~$15-25 and produces lower-quality output in the second half. Three 40-turn sessions cost ~$8-12 total and maintain quality throughout. You save money AND get better results.

## The 124K system prompt impact

Claude Code's system prompt is ~124K tokens. This is the biggest chunk of your context window and it's non-negotiable: it's sent on every API call.

The good news: prompt caching handles this. After turn 1, the system prompt is cached and costs 90% less per turn. The bad news: anything that breaks the cache (editing CLAUDE.md mid-session, changing MCP servers) forces a full re-write of this 124K block.

Rules for protecting the cache:
- Don't edit CLAUDE.md during a session
- Don't add/remove MCP servers mid-session
- Don't change Claude Code settings during a session
- Let the first 3 turns "warm up" before judging cost

See [Prompt Caching](prompt-caching.md) for the full breakdown.

## MCP servers and context pressure

Each MCP server adds its tool definitions to every API call. Five servers can consume ~55K tokens per turn, cutting your usable conversation context by 64%.

If you're hitting context limits faster than expected, check how many MCP servers are loaded:

```bash
# See active MCP servers
claude mcp list
```

Mitigations:
- **Scope servers to projects.** Use `.mcp.json` per project, not global config.
- **Use `ENABLE_TOOL_SEARCH=true`** with 3+ servers. Trades one API round-trip for massive token savings.
- **Unload servers you don't need.** A web project doesn't need the PostgreSQL MCP server.

See [MCP Internals](../under-the-hood/mcp-internals.md) for the full cost breakdown.

## What to take away

1. **Your usable context is ~55K, not 200K.** The system prompt, tools, and CLAUDE.md take the rest.
2. **Turns 4-40 are your sweet spot.** Cheapest per-turn cost, best quality output.
3. **Start fresh over compacting** when you're switching tasks or quality is degrading.
4. **Structure work into focused sessions.** Plan → Implement → Review, each in its own session.
5. **Watch for degradation signals.** Repetition, missed instructions, and re-reading files mean it's time for a new session.
6. **Protect the prompt cache.** Don't edit CLAUDE.md or change MCP servers mid-session.

---

*Related: [Session Cost Findings](findings.md) for the raw data, [Prompt Caching](prompt-caching.md) for cache mechanics, [Rate Limit Survival Guide](rate-limits.md) for managing limits.*
