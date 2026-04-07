# MCP Internals

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

## The headline

Every MCP server you add sends its full tool definitions on every API call. A single server like Playwright adds ~15K tokens. Five servers consume ~55K tokens -- 28% of your 200K context window -- before you type anything.

Understanding how MCP works under the hood explains why "just add another server" is never free.

## How MCP connections work

When Claude Code starts (or when you run `/mcp`), it reads your `.mcp.json` files (project-level and global) and launches each configured server as a subprocess.

```
Claude Code starts
       │
       ▼
Read .mcp.json (project) + ~/.claude/.mcp.json (global)
       │
       ▼
For each server:
  1. Spawn subprocess (npx, node, python, etc.)
  2. Handshake via JSON-RPC over stdio
  3. Server sends: list of tools (name, description, schema)
  4. Claude Code caches tool definitions in memory
       │
       ▼
All tool definitions → added to system prompt
       │
       ▼
Every API call sends: system prompt + tools + conversation
```

The key detail: tool definitions from MCP servers are appended to the system prompt and sent on **every single API call**, not just when you use that tool. Adding a Playwright MCP server costs ~15K tokens per turn whether you use the browser or not.

## What a tool definition actually costs

Each MCP tool has a name, description, and input schema. These are serialized as JSON and included in the API request. Here's what real servers cost:

| MCP Server | # of tools | Token cost | What you get |
|---|---|---|---|
| Playwright | ~20 tools | ~15K tokens | Browser automation, screenshots, clicks |
| Context7 | ~3 tools | ~3K tokens | Library documentation lookup |
| Filesystem | ~5 tools | ~5K tokens | File read/write/search outside project |
| PostgreSQL | ~8 tools | ~8K tokens | Database queries, schema inspection |
| Slack | ~15 tools | ~12K tokens | Channel read, message send, search |

These numbers come from measuring actual API requests with `tool_use` definitions included. They scale roughly linearly with the number of tools and the verbosity of their schemas.

## The math that matters

Claude Code's built-in tools cost ~17K tokens. Your system prompt (CLAUDE.md, rules, context) adds ~2-5K. The model's own system prompt adds ~124K tokens (see [system-prompt.md](system-prompt.md)).

That leaves roughly 50-55K tokens for your actual conversation before hitting the 200K context window.

Now add MCP servers:

| Configuration | Tool definition overhead | Context remaining for conversation |
|---|---|---|
| No MCP servers | ~17K (built-in only) | ~55K |
| 1 server (Context7) | ~20K | ~52K |
| 3 servers | ~35K | ~40K |
| 5 servers | ~55K | ~20K |
| 8 servers | ~80K | ~0K (barely functional) |

At 5 servers, you've cut your usable conversation context by 64%. At 8 servers, Claude Code is essentially running on fumes.

## Lazy loading with ENABLE_TOOL_SEARCH

Setting `ENABLE_TOOL_SEARCH=true` changes the behavior:

```
Without ENABLE_TOOL_SEARCH:
  Every API call → all tool definitions sent (full cost every turn)

With ENABLE_TOOL_SEARCH:
  API call → minimal tool index sent (~2K tokens)
  Claude decides which tools it needs
  Follow-up call → only requested tool definitions loaded
```

This trades one extra API round-trip for massive token savings. If you have 5 MCP servers, you go from ~55K overhead per turn to ~2K overhead per turn (plus the full cost only on turns where Claude actually uses an MCP tool).

The tradeoff: Claude might not know a tool exists if it doesn't appear in the index. In practice, the index includes tool names and one-line descriptions, which is usually enough for Claude to decide when to load the full definition.

## Connection lifecycle

MCP servers run as long-lived subprocesses. They don't restart between turns.

```
Session start → servers launched → servers alive for entire session
                                          │
Turn 1: tools loaded ────────────────────►│
Turn 2: tools loaded ────────────────────►│  (same process)
Turn N: tools loaded ────────────────────►│
                                          │
Session end → servers killed ◄────────────┘
```

If a server crashes mid-session, Claude Code will attempt to restart it on the next tool call. You'll see a brief delay but no data loss.

Common crash causes:
- **npx timeout**: The server package takes too long to download on first run. Fix: pre-install with `npm install -g @package/name`.
- **Port conflicts**: Two servers trying to bind the same port. Fix: configure different ports or use stdio transport.
- **Memory**: Long-running servers (especially browser-based) can leak memory. Fix: restart Claude Code sessions periodically.

## Project vs global scope

```
.mcp.json (project root)        → loaded only in this project
~/.claude/.mcp.json (global)    → loaded in every project
```

**Best practice:** Keep global config minimal (maybe just filesystem). Put project-specific servers in the project `.mcp.json`. This way a web project gets Playwright but a CLI tool doesn't pay the token cost.

## What to take away

1. **Count your servers.** Run `claude /mcp` to see what's loaded. Each one costs tokens every turn.
2. **Use ENABLE_TOOL_SEARCH** if you have 3+ servers. The round-trip cost is worth the token savings.
3. **Scope servers to projects.** Don't put Playwright in your global config unless every project needs a browser.
4. **Measure, don't guess.** Use `ccusage` or `claude-meter` to see actual token costs with and without your MCP servers.

---

*Related: [Tool Use](tool-use.md) for how built-in tools work, [MCP Configs](../ship-quality-code/mcp-configs.md) for copy-paste setup.*
