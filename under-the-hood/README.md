# Under the Hood

How Claude Code actually works. Understanding the mechanics helps you use it better.

These are condensed findings from experiments we ran by intercepting API traffic, analyzing token flows, and testing edge cases. Each links to the full deep dive with methodology and raw data.

## What's here

| Resource | What it is |
|----------|-----------|
| [Tool Use](tool-use.md) | Claude Code is just a while loop. How tool calls work and why Opus uses 37x more than Sonnet. |
| [Extended Thinking](extended-thinking.md) | What you're paying for with thinking tokens, and what's hidden from you. |
| [System Prompt](system-prompt.md) | What Claude Code sends before you type anything -- and why it's 124K tokens. |
| [Experiment Scripts](../experiment-scripts/) | See the mechanics for yourself with runnable demo scripts. |
