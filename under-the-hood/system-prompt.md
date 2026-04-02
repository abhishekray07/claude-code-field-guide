# System Prompt

> Verified with Claude Code v2.1.78, Opus 4.6. Tested March 2026.

## The headline

Before you type anything, Claude Code sends 124,402 tokens to the API. That first call costs $0.78 on Opus to write to cache. Every subsequent call reads from cache at $0.07 -- a 92% discount.

The system prompt itself is only 2,500 tokens. Tool definitions are 14-17K tokens. The rest is your CLAUDE.md, rules, and conversation scaffolding.

## What's in the system prompt

Claude Code's system prompt is surprisingly small. It contains:
- Your identity and environment info (OS, shell, working directory)
- Instructions for how to use each tool
- Rules about safety, permissions, and file handling
- Your CLAUDE.md content
- Any `.claude/rules/` files relevant to the current context

The big surprise: **tool definitions are 5.6x larger than the system prompt.** The Bash tool alone costs 1,558 tokens because it contains detailed instructions for git commit formatting, safety rules, and output handling. This is why Claude Code writes good commit messages without being asked -- the instructions are baked into the tool definition.

## Token breakdown (first call)

| Component | Tokens | % of first call |
|---|---|---|
| System prompt | ~2,500 | 2% |
| Built-in tool definitions | ~14,000-17,000 | 13% |
| MCP tool definitions | varies (~5-15K per server) | varies |
| CLAUDE.md + rules | varies | varies |
| Cache write overhead | 1.25x | -- |

## Why this matters

1. **Your first message is always expensive.** $0.78 on Opus just for the system prompt cache write. Don't abandon sessions after one turn -- you've already paid the entry fee.
2. **CLAUDE.md is a recurring cost.** Whatever you put in CLAUDE.md gets sent on every turn. A 2,000-token CLAUDE.md costs ~$0.003/turn, which adds up over 100+ turns.
3. **Tool definitions are the hidden tax.** You can't control built-in tool definitions, but you can control MCP servers. Each server you add increases the per-turn overhead permanently.

## The interesting detail

Claude Code writes surprisingly good git commits because the commit formatting instructions are embedded in the Bash tool definition (1,558 tokens). It also knows how to create PRs, handle merge conflicts, and follow conventional commit patterns -- all from tool definitions, not from your CLAUDE.md.

This means: don't duplicate git workflow instructions in your CLAUDE.md. Claude Code already has them.

---

*Full deep dive with intercepted API traffic: [System Prompt Deep Dive](https://claudecodecamp.com/blog/system-prompt-deep-dive?utm_source=github&utm_medium=findings&utm_campaign=field-guide)*
