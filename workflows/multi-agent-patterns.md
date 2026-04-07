# Multi-Agent Patterns

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

## The headline

Sub-agents are isolated Claude instances with their own context windows. They don't share your conversation history. Use them for parallel work and context protection, not for simple tasks you can do in one tool call.

For the full internals, see [Agent Teams](../under-the-hood/agent-teams.md). This article focuses on proven patterns.

## Pattern 1: Parallel research

**When to use:** You need information from 3+ different parts of the codebase.

```
You: "I need to understand how auth, billing, and notifications work"

  ├─ Explore agent: "How does auth work? Find auth middleware, session handling, token validation."
  ├─ Explore agent: "How does billing work? Find payment processing, subscription logic, invoicing."
  └─ Explore agent: "How does notifications work? Find email templates, push notifications, webhook handlers."

All 3 run in parallel → results come back in ~2 minutes instead of ~6 minutes
```

**Cost:** ~$0.15-0.45 for 3 Explore agents. Similar to doing it sequentially, but 3x faster.

**Why it works:** Each agent has a clean context window. They don't pollute each other's research with unrelated information. You get focused summaries back.

**Tips:**
- Use `Explore` agents for research (read-only, cheaper than `general-purpose`)
- Give each agent a specific, self-contained question
- Include file paths if you know them: "Start with src/auth/middleware.ts"

## Pattern 2: Divide and conquer

**When to use:** You have a well-planned feature with independent parts.

```
You: "Implement feature X" (you've already planned the approach)

  ├─ General agent: "Implement the API endpoint at src/api/users.ts (spec: ...)"
  ├─ General agent: "Write the React component at src/components/UserProfile.tsx (spec: ...)"
  └─ General agent: "Write tests at tests/user-profile.test.ts (spec: ...)"

Each agent implements independently → you review and integrate
```

**Cost:** Higher than single-agent (3x system prompt overhead). Worth it when tasks are truly independent and you want parallel execution.

**When it breaks:** If the tasks have dependencies (the test needs to import from the API endpoint, the component needs to call the API), the agents can't coordinate. They'll make assumptions that conflict. Only use this when the pieces are genuinely independent.

**Tips:**
- Plan the interface contracts first (what data shapes, what function signatures)
- Include the interface spec in each agent's task description
- Review the output for integration issues before committing

## Pattern 3: Specialist review

**When to use:** You just implemented something and want a fresh perspective.

```
You: "I just implemented user authentication"

  └─ Code reviewer agent: "Review the changes in the last 3 commits. Focus on security, error handling, and edge cases."

Reviewer returns findings → you address them in your session
```

**Cost:** ~$0.10-0.30 for a focused review.

**Why it works:** The reviewer starts with no context about your implementation decisions. It reads the code fresh, like a real code reviewer. It catches things you've become blind to after 30+ turns of implementation.

**Tips:**
- Give the reviewer specific scope: "last 3 commits" or "all files in src/auth/"
- Ask for specific focus areas: security, performance, edge cases, test coverage
- Consider using a different model for the review (see [Cross-Model Review](../ship-quality-code/cross-model-review.md))

## Pattern 4: Context protection

**When to use:** Your parent session is long (50+ turns) and you need to do exploratory work.

```
Your session: 55 turns in, context at ~75%

  └─ Explore agent: "Find all places where we handle rate limiting. Check middleware, API routes, and database queries."

Agent returns a 200-token summary → your parent session gains the information without the 15K tokens of file reads
```

**Cost:** ~$0.05-0.15 for the sub-agent vs ~15K tokens added to your already-long session.

**Why it works:** Without the sub-agent, the file reads would push your session closer to compaction. The sub-agent absorbs the token cost in its own context window and returns a compressed result.

**Tips:**
- Use this when your session is past turn 50 and you need research
- The sub-agent result is just text in your context — make sure to ask for concise summaries
- If you need detailed file contents (not just summaries), you might need to start a fresh session instead

## Anti-patterns

### Don't: Sub-agent for a single file read

```
BAD:  Agent(Explore): "Read src/config.ts and tell me what the database URL is"
GOOD: Read src/config.ts (one tool call, ~$0.01)
```

A sub-agent costs ~$0.05 minimum (system prompt + task + read + response). Reading a file directly costs ~$0.01. Don't pay 5x for something you can do in one tool call.

### Don't: Sequential dependent agents

```
BAD:
  Agent A: "What's the database schema?" → result
  Agent B: "Given this schema [paste A's result], what queries are slow?" → result
  Agent C: "Given these slow queries [paste B's result], write optimizations"
```

Each agent pays system prompt overhead. The context-passing duplicates tokens. Do this in a single session instead — it's cheaper and the session maintains continuity.

### Don't: Sub-agent for shared-context work

```
BAD: (after 30 turns of discussing auth requirements)
  Agent: "Implement the auth system"
  → Agent doesn't know any of your 30 turns of requirements discussion

GOOD: Implement it yourself, or write requirements to a file and reference it in the agent's task
```

Sub-agents start cold. If they need your conversation context, you have to include it in the task description, which duplicates tokens.

## Decision framework

| Situation | Use sub-agent? | Which type? |
|---|---|---|
| Read one file | No | Just use Read tool |
| Research 3+ areas in parallel | Yes | Explore |
| Independent implementation tasks | Yes (if truly independent) | General-purpose |
| Code review | Yes | Code-reviewer |
| Context protection (long session) | Yes | Explore |
| Task needs conversation context | No | Do it yourself |
| Sequential dependent tasks | No | Do it yourself |
| Simple lookup | No | Just use Grep/Glob |

## Orchestration tools

**Built-in Agent tool:** Ships with Claude Code. Spawns sub-agents with `subagent_type` parameter. Good for ad-hoc parallel research and review.

**TeamCreate (advanced):** Creates a team with a shared task list. Agents coordinate through tasks rather than direct messages. Good for large features where you want persistent tracking.

**External orchestrators (Conductor, etc.):** Third-party tools that add UI, persistence, and more sophisticated coordination on top of Claude Code's Agent tool.

For most workflows, the built-in Agent tool is sufficient. Graduate to teams when you have 3+ agents that need to coordinate on a shared plan.

---

*Related: [Agent Teams](../under-the-hood/agent-teams.md) for the internals (context isolation, cost model), [Context Management](../efficiency/context-management.md) for when to offload to sub-agents.*
