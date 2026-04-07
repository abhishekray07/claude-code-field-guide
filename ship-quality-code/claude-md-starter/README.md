# CLAUDE.md Starter Kit

A minimal, tested CLAUDE.md template you can customize.

## Philosophy

Your CLAUDE.md is sent on **every single API call**. Every token in it costs money on every turn. Keep it lean.

| Approach | Tokens | Cost per 100 turns (Opus 4.6) |
|---|---|---|
| Everything in CLAUDE.md | ~2,000 | ~$0.30 |
| Lean CLAUDE.md + .claude/rules/ | ~300 | ~$0.05 |

The starter template is ~400 tokens. It includes what Claude Code needs to make good decisions: your stack, your commands, your rules, and a **verification section** that redefines what "done" means.

## The key section most people miss

The `## Verification` block is the highest-leverage addition to any CLAUDE.md. Without it, Claude's success metric is "did bytes hit disk." With it, "done" means type check passes, tests pass, and lint is clean. See [verification workflows](../verification.md) for the full breakdown.

## Files

- **[CLAUDE.md](CLAUDE.md)** -- the starter template. Copy this to your project root and customize.

**Want more templates?** The [claude-md-templates](https://github.com/abhishekray07/claude-md-templates) repo has stack-specific CLAUDE.md templates for Next.js, Python, Go, Rust, and more.

## What goes where

| Content | Where | Why |
|---|---|---|
| Stack, commands, critical rules | `CLAUDE.md` (project root) | Sent every turn. Keep it essential. |
| Detailed coding patterns | `.claude/rules/` | Loaded selectively based on context. |
| Personal preferences | `~/.claude/CLAUDE.md` | Global, applies to all projects. |
| Team-shared configs | `.claude/settings.json` | Permissions, hooks, MCP servers. |

## Common mistake

Don't put your entire coding style guide in CLAUDE.md. Claude Code already reads your existing code to learn patterns. CLAUDE.md is for things it can't infer: commands to run, rules to follow, and architectural decisions.
