# Ship Quality Code

Configs, hooks, and workflows that make Claude Code produce code you'd actually merge.

The difference between "Claude Code wrote some code" and "Claude Code shipped a feature" comes down to your setup. A 30-minute investment here pays off on every session.

## The mental model

Claude Code is a 4-layer system. Most people only use layer 1.

| Layer | What it is | Enforcement level |
|-------|-----------|-------------------|
| **CLAUDE.md** | Project memory. Stack, commands, rules. | Advisory (~70% followed) |
| **Skills** | Reusable workflows Claude auto-invokes. | Advisory (triggered by context) |
| **Hooks** | Shell commands that run on every tool use. | **100% enforced** |
| **Agents** | Sub-agents with independent context windows. | Parallel execution |

The quality gap comes from layers 3 and 4. Hooks are the enforcement layer. Agents let you run review and implementation in parallel.

## What's here

| Resource | What it is |
|----------|-----------|
| [CLAUDE.md Starter Kit](claude-md-starter/) | Battle-tested templates for real projects |
| [Verification Workflows](verification.md) | Force Claude to verify before claiming "done" |
| [Cross-Model Review](cross-model-review.md) | Use Codex to review Claude's code (and vice versa) |
| [Hook Recipes](hooks.md) | Auto-format, auto-lint, block dangerous commands, run tests on every edit |
| [MCP Configs](mcp-configs.md) | Working .mcp.json setups for web, database, and docs projects |
| [Before/After Showcases](before-after.md) | What these configs actually change (with data) |
| [Recommended Tools](recommendations.md) | MCP servers, skills, and tools we've tested |
