# Tool Use

> Verified: Claude Code v2.1.78 | Haiku 3.5, Sonnet 4/4.6, Opus 4/4.6 | 2026-03-15

## The headline

Claude Code is a while loop. It sends your message to Claude, gets back either a text response or a tool call, executes the tool, sends the result back, and repeats until Claude responds with text. That's the entire agent architecture.

Every "turn" you see in the UI might involve 5-10 API calls under the hood as Claude reads files, runs commands, and iterates.

## Model behavior differences

We gave all three models the same bug-finding task and measured how they approached it:

| Model | Tool calls | Turns | Cost | Approach |
|---|---|---|---|---|
| Opus 4.6 | 38 | 22 | $0.73 | Exhaustive. Read every file, checked every path. |
| Sonnet 4.6 | 8 | 5 | $0.04 | Targeted. Went straight to the likely file, found the bug. |
| Haiku 4.5 | 13 | 8 | $0.02 | Systematic but shallow. Found the bug with moderate exploration. |

All three found the same bug. Opus was 37x more expensive and 4x slower, but produced a more thorough investigation. Whether that thoroughness is worth it depends on the task.

## Tool definitions eat context

Every tool available to Claude Code (Read, Write, Edit, Bash, Grep, Glob, etc.) has a definition that's sent on every API call. These add up:

- Built-in tools: ~17K tokens
- Each MCP server: ~5-15K tokens per server
- 5 MCP servers total: ~55K additional tokens

That's 28% of the 200K context window consumed by tool definitions alone.

## The agent loop

```
You type a message
       │
       ▼
┌─────────────────┐
│ Send to Claude   │◄──────────────────┐
│ (message +       │                   │
│  conversation +  │                   │
│  tools + system) │                   │
└────────┬────────┘                   │
         │                            │
         ▼                            │
   ┌───────────┐     ┌───────────┐   │
   │ Text      │     │ Tool call │   │
   │ response  │     │ response  │   │
   └─────┬─────┘     └─────┬─────┘   │
         │                  │          │
         ▼                  ▼          │
   Show to you        Execute tool    │
                           │          │
                           ▼          │
                     Send result ─────┘
```

Each loop iteration is one API call. A single "turn" from your perspective might be 10 iterations if Claude reads 5 files and runs 3 commands.

---

*Full deep dive with more experiments: [Tool Use Deep Dive](https://claudecodecamp.com/blog/tool-use-deep-dive?utm_source=github&utm_medium=findings&utm_campaign=field-guide)*
