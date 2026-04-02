# Claude Code Field Guide

Battle-tested findings, configs, and scripts from 500+ hours of experiments with Claude Code.

This is not another awesome list. Every finding here has data behind it, every config has been tested in production, and every recommendation comes with an opinion on why it matters.

## What we found

After running experiments across 500+ sessions and 67,000+ API turns, here's what surprised us:

- **92% of your spend happens in mega-sessions.** Sessions over 80 turns consume almost all your budget. The top 15 sessions alone accounted for 25% of total cost. ([details](stretch-your-limits/findings.md))
- **Prompt caching saves ~$80 per 100-turn session.** Without caching: $50-100. With caching: $10-19. But changing two letters in your CLAUDE.md can break the entire cache. ([details](stretch-your-limits/prompt-caching.md))
- **5 MCP servers eat 28% of your context window.** Each tool definition costs ~150 tokens. Five MCP servers add ~55K tokens before you type anything. ([details](setup-your-project/mcp-configs.md))
- **Opus uses 37x more tool calls than Sonnet for the same result.** Same bug, same fix. Opus: 38 tool calls, $0.73. Sonnet: 8 tool calls, $0.04. ([details](understand-the-internals/tool-use.md))
- **"High" thinking effort is 3.5x slower with no quality gain.** Low, medium, and high effort produced identical code. High just took 210% longer. ([details](understand-the-internals/extended-thinking.md))

## Get more findings like these

We publish weekly deep dives with new experiments, data, and practical takeaways.

**[Subscribe to Claude Code Camp](https://claudecodecamp.com?utm_source=github&utm_medium=readme&utm_campaign=field-guide)** -- short, practical, no filler.

---

## Table of Contents

### [Stretch Your Limits](stretch-your-limits/)
How to get more out of every session before you hit the wall.
- [Session Cost Findings](stretch-your-limits/findings.md) -- where your tokens actually go
- [Prompt Caching](stretch-your-limits/prompt-caching.md) -- how it works, what breaks it
- [Rate Limit Survival Guide](stretch-your-limits/rate-limits.md) -- why you hit limits fast and how to fix it
- [Configs That Save Tokens](stretch-your-limits/configs.md) -- copy-paste CLAUDE.md snippets with before/after data
- [Recommended Tools](stretch-your-limits/recommendations.md) -- tools we actually use for token management

### [Setup Your Project](setup-your-project/)
Get Claude Code working well from the first session.
- [CLAUDE.md Starter Kit](setup-your-project/claude-md-starter/) -- battle-tested templates
- [Hook Recipes](setup-your-project/hooks.md) -- copy-paste hooks for formatting, safety, and automation
- [MCP Configs](setup-your-project/mcp-configs.md) -- working .mcp.json setups we use daily
- [Before/After Showcases](setup-your-project/before-after.md) -- what these configs actually change
- [Recommended Tools](setup-your-project/recommendations.md) -- MCP servers and tools we've tested

### [Understand the Internals](understand-the-internals/)
How Claude Code actually works under the hood.
- [Tool Use](understand-the-internals/tool-use.md) -- Claude Code is just a while loop
- [Extended Thinking](understand-the-internals/extended-thinking.md) -- what you're paying for (and what's hidden)
- [System Prompt](understand-the-internals/system-prompt.md) -- what Claude Code sends before you type anything
- [Experiment Scripts](understand-the-internals/scripts/) -- reproduce our findings yourself

---

## Freshness

Every finding is tagged with the Claude Code version and date it was verified. If something says "Verified with Claude Code v2.1.87 on 2026-04-01" that means we tested it on that version on that date. Claude Code ships updates weekly, so findings may drift. If you spot something outdated, [open an issue](../../issues) or send a PR.

## Contributing

We welcome contributions -- findings with data, tested configs, and honest tool reviews. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## About

This repo is maintained by [Abhishek Ray](https://x.com/abhishekray), who runs [Claude Code Camp](https://claudecodecamp.com?utm_source=github&utm_medium=readme&utm_campaign=field-guide) -- a weekly newsletter with experiment-driven deep dives into Claude Code internals.

## License

[MIT](LICENSE)
