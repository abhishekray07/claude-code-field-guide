# Debugging Playbook

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

## The headline

When Claude Code goes wrong, it falls into predictable patterns. This playbook covers the most common failure modes with concrete symptoms, root causes, and fixes.

## Failure mode: Context exhaustion

**Symptoms:**
- Claude repeats explanations or suggestions from earlier in the conversation
- Instructions from CLAUDE.md get ignored
- Claude re-reads files it already read
- Responses get shorter and less detailed
- Claude references wrong file names or paths

**Root cause:** The 200K context window is mostly full. System prompt (124K) + tools (17K) + conversation history leaves little room for reasoning.

**Fix:**
1. Check context usage: `/context`
2. If above 80%: start a new session
3. If mid-task and can't restart: run `/compact` to free space (costs a cache break)
4. Going forward: keep sessions to 40-60 turns

**Prevention:**
- Structure work into focused sessions (see [Context Management](../efficiency/context-management.md))
- Offload research to Explore sub-agents to keep parent context clean
- Write decisions to files instead of relying on conversation memory

## Failure mode: Stuck loop

**Symptoms:**
- Claude tries the same fix repeatedly (3+ attempts)
- Each attempt is slightly different but fundamentally the same approach
- Token spend accelerates with no progress
- Claude says "Let me try a different approach" but doesn't

**Root cause:** Claude is following a reasoning path that can't succeed. The conversation context reinforces the failing approach because all the recent turns show variations of the same strategy.

**Fix:**
1. Interrupt the session (Ctrl+C or Escape)
2. Describe what's failing and why the current approach doesn't work
3. Suggest a specific alternative: "Instead of X, try Y"
4. If Claude is deeply stuck: start a new session and describe the problem fresh

**Prevention:**
- After 2 failed attempts at the same approach, explicitly redirect
- Use verification commands so Claude sees concrete failure signals, not just "it doesn't work"
- Include debugging hints in CLAUDE.md for common pitfalls in your codebase

## Failure mode: "Done!" when broken

**Symptoms:**
- Claude declares the task complete
- Tests aren't run (or aren't configured)
- Types don't check
- Lint fails
- Code compiles but doesn't do what was asked

**Root cause:** Without verification directives, Claude's definition of "done" is "I wrote code to disk." It optimizes for completing the turn, not correctness.

**Fix:**
1. Add a Verification section to CLAUDE.md:
   ```
   ## Verification
   After ANY code change, run:
   1. npm run build (must pass)
   2. npm test (must pass)
   3. npm run lint (must pass)
   Do NOT say "done" until all 3 pass.
   ```
2. Use hooks to enforce format and lint on every file write
3. Re-run verification manually: "Run the tests. All of them."

**Prevention:**
- [Verification Workflows](../ship-quality-code/verification.md) — the definitive guide
- [Hook Recipes](../ship-quality-code/hooks.md) — enforce at 100% vs CLAUDE.md at ~70%

## Failure mode: Hallucinated paths

**Symptoms:**
- Claude references files or functions that don't exist
- Import paths are wrong
- API endpoints use incorrect URLs
- Claude confidently describes code that isn't there

**Root cause:** Claude is generating plausible paths from patterns rather than reading the actual filesystem. This happens more in long sessions where Claude has seen many files and starts confusing them.

**Fix:**
1. Ask Claude to verify: "Does src/utils/auth.ts actually exist? Read it."
2. Use Glob to search: "Find all files matching **/auth*"
3. If hallucination is persistent: start a new session (context pollution)

**Prevention:**
- In CLAUDE.md: "Always verify file paths exist before importing or referencing them"
- Keep sessions focused on one area of the codebase
- Use Explore sub-agents for research (they read the actual filesystem)

## Failure mode: Hook failures

**Symptoms:**
- Claude's file writes trigger hook errors
- Hook blocks an operation Claude needs to do
- Infinite loop: Claude writes → hook rejects → Claude rewrites → hook rejects
- Claude tries to bypass the hook

**Root cause:** Hooks enforce rules that Claude's output doesn't meet. Usually formatting or lint issues that Claude didn't account for.

**Fix:**
1. Read the hook error message — it usually says exactly what's wrong
2. Ask Claude to fix the specific issue: "The pre-write hook says line 42 has an unused import"
3. If the hook is too strict for this task: temporarily disable it (but re-enable after)

**Prevention:**
- Auto-format hooks should fix issues silently, not just report them
- Lint hooks should run auto-fix mode where possible
- Include hook expectations in CLAUDE.md: "All files must pass ESLint before commit"

## Failure mode: MCP connection issues

**Symptoms:**
- MCP tool calls fail with timeout or connection errors
- Claude retries the same MCP call repeatedly
- "Server not found" or "Server disconnected" errors
- Session becomes very slow (waiting for MCP responses)

**Root cause:** The MCP server subprocess crashed, timed out, or is resource-starved.

**Fix:**
1. Check server status: `claude mcp list`
2. Restart the server: exit and restart Claude Code
3. If a specific server keeps crashing: check its logs and resource usage
4. If `npx`-based: pre-install the package globally to avoid download timeouts

**Prevention:**
- Pre-install MCP server packages: `npm install -g @package/name`
- Monitor MCP server count — each one costs tokens and memory
- Use `ENABLE_TOOL_SEARCH=true` with 3+ servers
- See [MCP Internals](../under-the-hood/mcp-internals.md) for connection lifecycle details

## Failure mode: Extended thinking waste

**Symptoms:**
- Simple questions cost surprisingly many output tokens
- `/cost` shows high output token counts for short visible responses
- Session cost is much higher than expected for the work done

**Root cause:** Thinking tokens (invisible to you, billed at output rates) are 3-10x the visible response. Claude "thinks" extensively even for simple tasks.

**Fix:**
1. Use Sonnet for simple tasks (37x fewer tool calls, less thinking overhead)
2. Break complex prompts into smaller steps (bounds thinking per turn)
3. Be specific: "Read auth.ts line 47" vs "look at the auth system"

**Prevention:**
- Switch models for different phases: Sonnet for research, Opus for implementation
- See [Extended Thinking](../under-the-hood/extended-thinking.md) for the full breakdown
- Use [token monitoring tools](../efficiency/recommendations.md) to spot waste early

## Quick reference

| Symptom | Likely cause | Quick fix |
|---|---|---|
| Repeating itself | Context exhaustion | New session |
| Same fix 3+ times | Stuck loop | Redirect or new session |
| Says "done", tests fail | No verification | Add verification to CLAUDE.md |
| Wrong file paths | Hallucination | Ask to verify paths exist |
| Hook errors looping | Format/lint mismatch | Fix the specific issue |
| MCP timeouts | Server crash | Restart Claude Code |
| High cost, simple task | Thinking overhead | Switch to Sonnet |

---

*Related: [Context Management](../efficiency/context-management.md) for session structuring, [Verification Workflows](../ship-quality-code/verification.md) for preventing "done when broken."*
