# Cross-Model Review

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06
>
> "Every time you run a Codex code review from Claude Code, it finds critical issues. Not 95% of the times, 100%." — David Marcus (2,869 likes)

## The idea

Having Claude review its own code is like proofreading your own writing. You'll miss the same things twice. A different model catches different patterns.

The emerging workflow: **Claude writes, Codex reviews.** Or the reverse. Two models with different training, different blind spots, different strengths.

## Setup: Codex plugin for Claude Code

OpenAI open-sourced an official plugin that lets you call Codex directly from Claude Code.

```bash
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

This gives you three commands:

| Command | What it does | When to use |
|---------|-------------|-------------|
| `/codex:review` | Standard code review | After implementing a feature, before PR |
| `/codex:adversarial-review` | Actively tries to break your code | High-risk changes (auth, billing, migrations) |
| `/codex:rescue` | Hands the task to Codex entirely | When Claude is stuck or going in circles |

## The workflow

### Basic: review before PR

```
1. Claude implements the feature
2. Run /codex:review
3. Codex reviews the diff and flags issues
4. Claude fixes the issues Codex found
5. Open PR with confidence
```

This catches issues that Claude's self-review misses. Different model = different perspective.

### Advanced: adversarial review for high-risk changes

For changes that touch auth, payments, data deletion, or infrastructure:

```
1. Claude implements the change
2. Run /codex:adversarial-review
3. Codex specifically tries to find:
   - Hidden assumptions that could break in production
   - Edge cases the implementation doesn't handle
   - Security implications the author might not see
4. Claude addresses each finding
5. Run /codex:review one more time for a clean pass
```

### Rescue mode: when Claude is stuck

If Claude has been going in circles on a problem (3+ attempts, same failure):

```
1. Run /codex:rescue
2. Codex gets the full context and takes a fresh approach
3. Compare Codex's solution with Claude's attempts
4. Pick the better approach or combine insights
```

## Without the plugin: manual cross-model review

If you don't have the Codex plugin, you can still do cross-model review manually.

**Option 1: Codex CLI**

```bash
# From your project root, ask Codex to review the current diff
codex exec "Review this git diff for bugs, security issues, and edge cases. Be brutally honest." -s read-only
```

**Option 2: Different Claude session**

Open a second Claude Code session and ask it to review the first session's output:

```
Review the changes in the last 3 commits. Look for:
- Type safety issues
- Missing error handling
- Edge cases not covered by tests
- Security concerns
```

A fresh session has no context bias from the implementation conversation.

## Why this works

Each model has blind spots shaped by its training:
- Claude tends to be thorough but can over-engineer
- Codex tends to be concise but can miss edge cases
- A fresh Claude session doesn't have the implementation conversation biasing its review

Cross-model review exploits the gap between blind spots. What one model misses, the other catches.

## Cost

The Codex plugin uses your existing ChatGPT subscription. No additional API costs beyond what you're already paying for Claude Code and ChatGPT.

For manual review with Codex CLI: typically $0.01-0.05 per review depending on diff size.

---

*Have a cross-model workflow that works well? [Submit a PR](../CONTRIBUTING.md).*
