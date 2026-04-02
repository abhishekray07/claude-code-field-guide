# Claude Code Field Guide

How to ship production-quality code with Claude Code.

Most people use Claude Code like a chatbot and get chatbot-quality output. This guide is for people who want to ship real code -- tested, formatted, reviewed, and production-ready -- using Claude Code as a serious engineering tool.

Every finding here is backed by data from 500+ sessions and 67,000+ API turns. Every config has been tested in production. Every recommendation comes with an opinion on why it matters.

## What we learned the hard way

- **Hooks are the difference between "works on my machine" and production-ready.** Auto-format and lint on every file write. Claude Code sees failures and self-corrects in the same turn. Zero formatting commits, zero lint surprises in PR review. ([setup](ship-quality-code/hooks.md))
- **Your CLAUDE.md is the single biggest lever on output quality.** A 10-line CLAUDE.md with your stack, commands, and rules beats a 100-line style guide. The rules in `.claude/rules/` load only when relevant -- no wasted context. ([starter kit](ship-quality-code/claude-md-starter/))
- **5 MCP servers eat 28% of your context window.** That's less room for your actual conversation and code. Fewer, better-chosen tools = better output. ([configs](ship-quality-code/mcp-configs.md))
- **92% of your spend happens in mega-sessions (80+ turns).** Long sessions don't just cost more -- quality degrades as context fills up. Break work into focused sessions. ([data](stretch-your-limits/findings.md))
- **Opus uses 37x more tool calls than Sonnet for the same bug fix.** More thorough, but not always better. Match the model to the task. ([data](under-the-hood/tool-use.md))

## Get more findings like these

We publish weekly deep dives with new experiments, data, and practical takeaways.

**[Subscribe to Claude Code Camp](https://claudecodecamp.com?utm_source=github&utm_medium=readme&utm_campaign=field-guide)** -- short, practical, no filler.

---

## Table of Contents

### [Ship Quality Code](ship-quality-code/)
Configs, hooks, and workflows that make Claude Code produce code you'd actually merge.
- [CLAUDE.md Starter Kit](ship-quality-code/claude-md-starter/) -- battle-tested templates for real projects
- [Hook Recipes](ship-quality-code/hooks.md) -- auto-format, auto-lint, block dangerous commands, run tests
- [MCP Configs](ship-quality-code/mcp-configs.md) -- working .mcp.json setups for web, database, and docs
- [Before/After Showcases](ship-quality-code/before-after.md) -- what these configs actually change (with data)
- [Recommended Tools](ship-quality-code/recommendations.md) -- MCP servers and tools we've actually tested

### [Stretch Your Limits](stretch-your-limits/)
Get more done per session. Spend your tokens on code, not overhead.
- [Session Cost Findings](stretch-your-limits/findings.md) -- where your tokens actually go
- [Prompt Caching](stretch-your-limits/prompt-caching.md) -- how it works, what breaks it
- [Rate Limit Survival Guide](stretch-your-limits/rate-limits.md) -- why you hit limits fast and how to fix it
- [Configs That Save Tokens](stretch-your-limits/configs.md) -- copy-paste CLAUDE.md snippets with before/after data
- [Recommended Tools](stretch-your-limits/recommendations.md) -- tools we actually use for token management

### [Under the Hood](under-the-hood/)
How Claude Code actually works. Understanding the mechanics helps you use it better.
- [Tool Use](under-the-hood/tool-use.md) -- Claude Code is just a while loop
- [Extended Thinking](under-the-hood/extended-thinking.md) -- what you're paying for (and what's hidden)
- [System Prompt](under-the-hood/system-prompt.md) -- what Claude Code sends before you type anything
- [Experiment Scripts](under-the-hood/scripts/) -- reproduce our findings yourself

---

## Freshness

Every finding is tagged with the Claude Code version and date it was verified. Claude Code ships updates weekly, so findings may drift. If you spot something outdated, [open an issue](../../issues) or send a PR.

## Contributing

We welcome contributions -- findings with data, tested configs, and honest tool reviews. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## About

This repo is maintained by [Abhishek Ray](https://x.com/abhishekray), who runs [Claude Code Camp](https://claudecodecamp.com?utm_source=github&utm_medium=readme&utm_campaign=field-guide) -- a weekly newsletter with experiment-driven deep dives into Claude Code internals.

## License

[MIT](LICENSE)
