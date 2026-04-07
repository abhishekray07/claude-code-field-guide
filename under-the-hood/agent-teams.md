# Agent Teams Under the Hood

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

## The headline

Sub-agents in Claude Code are separate Claude instances with their own context windows. They don't share conversation history with the parent. Each sub-agent is an independent API call chain that costs tokens separately.

Understanding this isolation model explains when sub-agents help and when they waste money.

## How the Agent tool works

When Claude Code spawns a sub-agent (via the Agent tool), here's what happens:

```
Parent agent (your session)
       │
       ├─ Sends: task description + subagent_type
       │
       ▼
Sub-agent created:
  1. Fresh system prompt (same as parent)
  2. Fresh context window (empty conversation)
  3. Tools: depends on subagent_type
  4. Gets ONLY the task description as first message
       │
       ▼
Sub-agent works independently:
  - Makes its own API calls
  - Uses its own tool calls
  - Builds its own conversation context
       │
       ▼
Sub-agent returns: single text result to parent
       │
       ▼
Parent receives result as tool output
```

The critical detail: the sub-agent doesn't see your conversation history. It starts cold. This is both the strength (fresh context, no inherited bias) and the weakness (can't reference what you already discussed).

## Context isolation

Each sub-agent gets:
- The full system prompt (~124K tokens, same cost as parent)
- Tool definitions (same set or restricted, depending on type)
- Only the task description you provide
- Its own conversation history (starts empty)

What it does NOT get:
- Your conversation history
- Files you've already read (it re-reads them)
- Decisions you've already made
- Previous sub-agent results (unless you include them in the task description)

This means a sub-agent doing research will re-read files your parent session already read. That's duplicate token spend. For a 50-turn parent session that's already read 20 files, spawning a sub-agent to "look at the codebase" repeats that work.

## Sub-agent types and their tools

| Type | Tools available | Good for |
|---|---|---|
| `general-purpose` | All tools (Read, Write, Edit, Bash, etc.) | Full implementation tasks |
| `Explore` | Read-only tools (Read, Grep, Glob, Bash for reading) | Codebase research, finding files |
| `Plan` | Read-only tools | Architecture planning |
| `code-reviewer` | All tools | Code review with fix capabilities |

The `Explore` agent is cheaper per turn because it can't write files, so Claude doesn't waste tokens planning edits. Use it when you just need information.

## Cost model

Sub-agent costs are additive with the parent session. A parent + 3 sub-agents = 4 separate billing streams.

Typical cost breakdown for a sub-agent:

| Component | Cost (Opus) |
|---|---|
| System prompt (first turn) | ~$0.015 (124K cached input tokens) |
| Task description turn | ~$0.002-0.01 |
| Each subsequent turn | ~$0.03-0.08 |
| Typical 5-10 turn sub-agent | ~$0.15-0.60 |

A quick Explore sub-agent (3-5 turns) costs ~$0.05-0.15 on Opus. A full implementation sub-agent (10-20 turns) costs ~$0.30-1.50.

The system prompt cost is largely offset by prompt caching. If the parent and sub-agent share the same system prompt (and they do), the cached portion is billed at 90% discount. But the sub-agent still pays full price for its own conversation context.

## When sub-agents help

**Parallel research.** You need information from 3 different parts of the codebase. Instead of reading them sequentially (30 turns in one session), spawn 3 Explore agents in parallel (10 turns each, running concurrently). Wall clock time drops from ~5 minutes to ~2 minutes.

**Context protection.** Your parent session is at 60% context fill. A complex research task would push it past compaction. Offload the research to a sub-agent, get the summary back (a few hundred tokens), and keep your parent session clean.

**Fresh perspective.** After 40+ turns on a problem, your session has accumulated context bias. A sub-agent starts fresh and might approach the problem differently.

## When sub-agents hurt

**Simple lookups.** "Read this one file and tell me what function X does" costs ~$0.05 as a sub-agent (system prompt + task + read + response). Doing it yourself costs ~$0.01 (one Read tool call). Don't use a sub-agent for something you can do in one tool call.

**Shared context work.** If the sub-agent needs to know about decisions made earlier in your conversation, you have to include that context in the task description. If the context is long, you're paying to send it twice.

**Sequential dependencies.** Sub-agent A needs the result of sub-agent B. Running them in parallel doesn't work. Running them sequentially still costs more than doing both in the parent (because of duplicated system prompt overhead).

## Orchestration patterns

### Pattern 1: Parallel research

```
Parent: "I need to understand auth, billing, and notifications"
  ├─ Agent(Explore): "How does auth work in this codebase?"
  ├─ Agent(Explore): "How does billing work?"
  └─ Agent(Explore): "How does notifications work?"
→ 3 results come back, parent synthesizes
```

Cost: ~$0.15-0.45 for 3 Explore agents vs ~$0.30-0.90 for sequential research in parent. Similar cost, but 3x faster.

### Pattern 2: Divide and conquer

```
Parent: "Implement feature X" (plans the approach)
  ├─ Agent(general): "Implement the API endpoint"
  ├─ Agent(general): "Write the frontend component"
  └─ Agent(general): "Write the tests"
→ Each agent implements independently, parent reviews
```

Cost: Higher than single-agent (3x system prompt overhead). Worth it when the tasks are truly independent and you want parallel execution.

### Pattern 3: Specialist review

```
Parent: "I just implemented this feature"
  └─ Agent(code-reviewer): "Review the changes in the last 3 commits"
→ Reviewer returns findings, parent addresses them
```

Cost: ~$0.10-0.30 for a focused review. Worth it for the fresh perspective.

## What to take away

1. **Sub-agents are isolated.** They don't share your context. Design tasks to be self-contained.
2. **Use Explore agents for research.** They're cheaper than general-purpose agents and can't accidentally modify files.
3. **Parallel beats sequential.** Spawn 3 agents at once instead of doing 3 research tasks in series.
4. **Protect your parent context.** If your session is getting long, offload exploratory work to sub-agents.
5. **Don't sub-agent simple tasks.** One file read is cheaper in the parent than spawning an agent for it.

---

*Related: [Tool Use](tool-use.md) for how the agent loop works, [Session Cost Findings](../efficiency/findings.md) for session economics.*
