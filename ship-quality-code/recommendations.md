# Recommended Tools for Shipping Quality Code

> Tools and resources ranked by real community engagement. We've tested what we could and noted what we haven't.

## Code Review

### [Codex Plugin for Claude Code](https://github.com/openai/codex-plugin-cc)
**What it does:** Run Codex code reviews directly from Claude Code. Three modes: standard review, adversarial review, and rescue (hand off to Codex when stuck).
**Why it matters:** Cross-model review catches what self-review misses. David Marcus says it finds critical issues 100% of the time.
**Engagement:** 5,378 likes / 3,795 bookmarks on the launch tweet. OpenAI official.
**Setup:** `/plugin marketplace add openai/codex-plugin-cc && /plugin install codex@openai-codex`

### [code-review-graph](https://github.com/nicepkg/code-review-graph)
**What it does:** Builds a persistent knowledge graph of your codebase in local SQLite. Claude reads only what's relevant instead of re-scanning everything.
**Why it matters:** 6.8x fewer tokens on reviews, up to 49x reduction on daily coding tasks. Better context = better quality output.
**Engagement:** 1,204 likes / 2,175 bookmarks on X.

## Verification & Quality

### [research-mode](https://github.com/assafkip/research-mode)
**What it does:** A Claude Code command that forces structured research before answering. Dramatically reduces hallucination by making Claude verify claims against docs.
**Why it matters:** Found via a Reddit post with 2,288 upvotes: "3 instructions in Anthropic's docs that dramatically reduce hallucination."
**Setup:** Install as a slash command in your `.claude/commands/` directory.

### [prompt-master](https://github.com/)
**What it does:** A Claude skill that writes better prompts for any AI tool. Scores and iterates on prompt quality.
**Engagement:** 1,271 Reddit upvotes, 600+ GitHub stars.

### [/simplify command](https://docs.anthropic.com/en/docs/claude-code)
**What it does:** Built-in Claude Code command. Runs parallel agents to improve code quality, tune efficiency, and ensure CLAUDE.md compliance.
**Gotcha:** Heavy on tokens (~37% session usage on Pro) and slow (~7 min). Worth it for code you're about to ship, not for exploratory work.

## Workflow Orchestration

### [Cook CLI](https://rjcorwin.github.io/cook/)
**What it does:** Simple CLI for orchestrating multiple Claude Code sessions. Define recipes (sequences of tasks) and run them.
**Engagement:** 307 HN points.
**Good for:** Multi-step workflows where each step needs a fresh context window.

### [oh-my-claudecode](https://github.com/)
**What it does:** Zero-config multi-agent orchestration. 32 specialized agents, 8 orchestration modes, smart model routing that saves 30-50% on tokens.
**Engagement:** 236 likes / 225 bookmarks on X.

## Visual Verification

### [Playwright MCP](https://github.com/anthropics/mcp-playwright)
**What it does:** Gives Claude Code a real browser. Navigate, click, screenshot, test.
**Why it matters:** Claude Code can verify its own frontend work instead of guessing. The single biggest quality improvement for web projects.
**Gotcha:** Adds ~15K tokens to tool definitions. Worth it for web projects.

### [Chrome Extension](https://chromewebstore.google.com/)
**What it does:** Boris Cherny's recommended tool for frontend work. "Give Claude a way to verify its output. Once you do that, Claude will iterate until the result is great."
**Engagement:** 1,226 likes / 1,376 bookmarks.

## Context & Documentation

### [Context7 MCP](https://github.com/anthropics/mcp-context7)
**What it does:** Pulls up-to-date library documentation into Claude Code's context.
**Good for:** When you're using a library that shipped breaking changes after Claude's training cutoff.

### [nah — Permission Guard](https://github.com/manuelschipper/nah/)
**What it does:** Context-aware permission guard for Claude Code. Smarter than default permissions.
**Engagement:** 127 HN points.

## Learning Resources

### [Claude Code Unpacked](https://ccunpacked.dev/)
**What it is:** Visual guide to Claude Code internals. 1,046 HN points.
**Good for:** Understanding how the system works before configuring it.

### [Claude Code Cheat Sheet](https://cc.storyfox.cz)
**What it is:** Quick reference for commands, flags, and shortcuts. 699 HN points.

### [How I'm Productive with Claude Code](https://neilkakkar.com/productive-with-claude-code.html)
**What it is:** Practical workflow writeup from a working engineer. 281 HN points.
**Good for:** Seeing how someone structures their day around Claude Code.

### [Learn Claude Code by Doing](https://claude.nagdy.me/)
**What it is:** Interactive tutorial that simulates a Claude Code project in your browser. 275 HN points.
**Good for:** Hands-on learning without burning tokens.

## Skills Worth Installing

### [Self-Improving Skills Pattern](https://x.com/mikefutia/)
**What it is:** A meta-skill that runs your skill 10 times, scores against eval criteria, rewrites the prompt, retests, and keeps the winner. 823 likes / 1,357 bookmarks.
**Good for:** Any skill that's inconsistent -- great 70% of the time, unusable the other 30%.

### [Golang Production Skills](https://github.com/)
**What it is:** Claude Code skills specifically for production-ready Go projects. 401 likes / 526 bookmarks.

### [Boris Cherny's /loop workflows](https://x.com/bcherny/)
**What they are:** Automated loops for PR babysitting, Slack feedback collection, stale PR cleanup. 1,567 likes / 1,492 bookmarks.
**Key commands:** `/loop 5m /babysit` (auto-rebase and address review), `/loop 30m /slack-feedback` (auto-PR from Slack), `/loop 1h /pr-pruner` (close stale PRs).

---

*Know a tool that improved your code quality? [Submit a PR](../CONTRIBUTING.md).*
