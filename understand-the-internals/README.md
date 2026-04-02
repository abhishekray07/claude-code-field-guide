# Understand the Internals

How Claude Code actually works under the hood.

These are condensed findings from experiments we ran by intercepting API traffic, analyzing token flows, and testing edge cases. Each links to the full deep dive with methodology and raw data.

## What's here

| Resource | What it is |
|----------|-----------|
| [Tool Use](tool-use.md) | Claude Code is just a while loop. How tool calls work and why Opus uses 37x more than Sonnet. |
| [Extended Thinking](extended-thinking.md) | What you're paying for with thinking tokens, and what's hidden from you. |
| [System Prompt](system-prompt.md) | What Claude Code sends before you type anything -- and why it's 124K tokens. |
| [Experiment Scripts](scripts/) | Reproduce our findings yourself. |

## Coming soon

- Prompt injection resistance (we tested 17 attack vectors)
- Channel/MCP internals
- Agent teams under the hood
