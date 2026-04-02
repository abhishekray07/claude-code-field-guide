# CLAUDE.md Starter Kit

A minimal, tested CLAUDE.md template you can customize.

## Philosophy

Your CLAUDE.md is sent on **every single API call**. Every token in it costs money on every turn. Keep it lean.

| Approach | Tokens | Cost per 100 turns (Opus 4.6) |
|---|---|---|
| Everything in CLAUDE.md | ~2,000 | ~$0.30 |
| Lean CLAUDE.md + .claude/rules/ | ~300 | ~$0.05 |

The starter template is ~300 tokens. It includes what Claude Code needs to make good decisions: your stack, your commands, and your rules.

## Files

- **[CLAUDE.md](CLAUDE.md)** -- the starter template. Copy this to your project root and customize.

## What goes where

| Content | Where | Why |
|---|---|---|
| Stack, commands, critical rules | `CLAUDE.md` (project root) | Sent every turn. Keep it essential. |
| Detailed coding patterns | `.claude/rules/` | Loaded selectively based on context. |
| Personal preferences | `~/.claude/CLAUDE.md` | Global, applies to all projects. |
| Team-shared configs | `.claude/settings.json` | Permissions, hooks, MCP servers. |

## Common mistake

Don't put your entire coding style guide in CLAUDE.md. Claude Code already reads your existing code to learn patterns. CLAUDE.md is for things it can't infer: commands to run, rules to follow, and architectural decisions.
