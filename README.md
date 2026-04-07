# Claude Code Engineering Handbook

How to ship production-quality code with Claude Code.

Most people use Claude Code like a chatbot and get chatbot-quality output. This handbook is for people who want to ship real code -- tested, formatted, reviewed, and production-ready -- using Claude Code as a serious engineering tool.

Every finding here is backed by data from 500+ sessions and 67,000+ API turns. Every config has been tested in production. Every recommendation comes with an opinion on why it matters. Key claims include scripts so you can see the mechanics for yourself.

## What we learned the hard way

- **Add a "Verification" section to your CLAUDE.md.** Without it, Claude's definition of "done" is "bytes hit disk." With it, "done" means tests pass, types check, and lint is clean. This single change eliminates most back-and-forth. ([verification workflows](ship-quality-code/verification.md))
- **Use a different model to review Claude's code.** Claude reviewing its own output misses the same things twice. The Codex plugin catches critical issues on every run. Two models > one model reviewing itself. ([cross-model review](ship-quality-code/cross-model-review.md))
- **Hooks enforce quality at 100%, CLAUDE.md at ~70%.** Auto-format and lint on every file write. Claude sees failures and self-corrects in the same turn. Zero formatting commits in PR review. ([hook recipes](ship-quality-code/hooks.md))
- **Your CLAUDE.md is the single biggest lever on output quality.** A lean CLAUDE.md with verification directives beats a verbose style guide. Rules in `.claude/rules/` load only when relevant. ([starter kit](ship-quality-code/claude-md-starter/))
- **92% of your spend happens in mega-sessions (80+ turns).** Long sessions don't just cost more -- quality degrades as context fills up. Break work into focused sessions. ([data](efficiency/findings.md))

## Get more findings like these

We publish weekly deep dives with new experiments, data, and practical takeaways.

**[Subscribe to Claude Code Camp](https://claudecodecamp.com?utm_source=github&utm_medium=readme&utm_campaign=field-guide)** -- short, practical, no filler.

---

## Table of Contents

### [Ship Quality Code](ship-quality-code/)
Configs, hooks, and workflows that make Claude Code produce code you'd actually merge.
- [CLAUDE.md Starter Kit](ship-quality-code/claude-md-starter/) -- battle-tested templates with verification built in
- [Verification Workflows](ship-quality-code/verification.md) -- force Claude to prove its work before saying "done"
- [Cross-Model Review](ship-quality-code/cross-model-review.md) -- use Codex to review Claude's code (and vice versa)
- [Hook Recipes](ship-quality-code/hooks.md) -- auto-format, auto-lint, block dangerous commands, run tests
- [MCP Configs](ship-quality-code/mcp-configs.md) -- working .mcp.json setups for web, database, and docs
- [Before/After Showcases](ship-quality-code/before-after.md) -- what these configs actually change (with data)
- [Recommended Tools](ship-quality-code/recommendations.md) -- curated tools ranked by real community engagement

### [Under the Hood](under-the-hood/)
How Claude Code actually works. Understanding the mechanics helps you use it better.
- [Tool Use](under-the-hood/tool-use.md) -- Claude Code is just a while loop
- [Extended Thinking](under-the-hood/extended-thinking.md) -- what you're paying for (and what's hidden)
- [System Prompt](under-the-hood/system-prompt.md) -- what Claude Code sends before you type anything
- [MCP Internals](under-the-hood/mcp-internals.md) -- every MCP server costs tokens every turn
- [Agent Teams](under-the-hood/agent-teams.md) -- sub-agents are isolated instances with their own cost
- [Experiment Scripts](experiment-scripts/) -- see the mechanics for yourself

### [Efficiency](efficiency/)
Get more done per session. Spend your tokens on code, not overhead.
- [Session Cost Findings](efficiency/findings.md) -- where your tokens actually go
- [Context Management](efficiency/context-management.md) -- manage your ~55K usable context window
- [Prompt Caching](efficiency/prompt-caching.md) -- how it works, what breaks it
- [Rate Limit Survival Guide](efficiency/rate-limits.md) -- why you hit limits fast and how to fix it
- [Configs That Save Tokens](efficiency/configs.md) -- copy-paste CLAUDE.md snippets with before/after data
- [Recommended Tools](efficiency/recommendations.md) -- tools we actually use for token management

---

## Freshness

Every finding is tagged with the Claude Code version and date it was verified (format: `Verified: Claude Code vX.X.XX | Model | YYYY-MM-DD`). Claude Code ships updates weekly, so findings may drift. If you spot something outdated, open an issue or send a PR.

## Contributing

We welcome contributions -- findings with data, tested configs, and honest tool reviews. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## About

This repo is maintained by [Abhishek Ray](https://x.com/abhishekray), who runs [Claude Code Camp](https://claudecodecamp.com?utm_source=github&utm_medium=readme&utm_campaign=field-guide) -- a weekly newsletter with experiment-driven deep dives into Claude Code internals.

## License

[MIT](LICENSE)
