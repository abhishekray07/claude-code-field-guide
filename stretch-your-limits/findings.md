# Session Cost Findings

> Verified with Claude Code v2.1.78-87 on Opus 4.5/4.6 and Sonnet 4.5/4.6. Data from 518 sessions, 67,000+ turns.

## The headline

92% of your Claude Code spend happens in mega-sessions (80+ turns). The top 15 sessions alone -- each running 300 to 1,400 turns -- accounted for 25% of total cost.

If you do nothing else, break long sessions into shorter ones.

## The data

We tracked 518 real Claude Code sessions across multiple projects over several weeks:

| Session type | Sessions | % of total sessions | % of total cost |
|---|---|---|---|
| Short (< 20 turns) | 178 | 34% | 3% |
| Medium (20-79 turns) | 122 | 24% | 5% |
| Mega (80+ turns) | 218 | 42% | 92% |

## Why mega-sessions cost so much

Every turn sends the entire conversation history back to the API. Turn 1 sends a small payload. Turn 80 sends everything from turns 1-79 plus the new message. The cost per turn accelerates as the session grows.

- **Mid-session turns** (turns 20-60): ~$0.11/turn
- **Late-session turns** (turns 60+): ~$0.18/turn
- **Post-compaction turns** (after context is compressed): ~$0.29/turn

Compaction (when Claude Code compresses your conversation to fit the context window) is the most expensive restart. The compressed summary still costs tokens, and you lose the cached conversation prefix.

## What to do

1. **Start new sessions for new tasks.** Don't reuse a session across unrelated work.
2. **Target 40-60 turns per session.** This is the sweet spot for cost per turn.
3. **Watch for compaction.** When Claude Code says "Conversation compacted," your costs per turn just jumped. Consider starting fresh.
4. **Use Sonnet for exploratory work.** Opus costs 3x more per turn ($0.24 vs $0.08 on 4.6). Switch to Opus for complex reasoning, not for "read this file."

## Model comparison

| Model | Avg cost/turn | Best for |
|---|---|---|
| Opus 4.6 | $0.078 | Complex reasoning, architecture decisions |
| Sonnet 4.6 | $0.030 | Day-to-day coding, file edits, exploration |
| Haiku 4.5 | $0.003 | Simple lookups, formatting, boilerplate |

Switching from Opus to Sonnet saves more than any other optimization.

---

*Full deep dive with methodology and charts: [The Economics of a Claude Code Session](https://claudecodecamp.com/blog/context-management-deep-dive?utm_source=github&utm_medium=findings&utm_campaign=field-guide)*
