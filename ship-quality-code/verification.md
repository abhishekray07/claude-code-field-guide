# Verification Workflows

> The single highest-engagement Claude Code topic on the internet. A viral CLAUDE.md with verification directives hit 15,987 bookmarks on X in March 2026. People want Claude to prove its work before saying "done."

## The problem

Claude Code's internal success metric for a file write is: did bytes hit disk? Not "does the code compile," not "do tests pass." Just: did the write complete?

This means Claude Code will cheerfully report "Done!" while leaving behind type errors, lint failures, and broken tests. Not because it's lazy -- because its definition of "done" doesn't include verification.

## The fix: forced verification in CLAUDE.md

Add this to your CLAUDE.md. These aren't suggestions -- they redefine what "done" means.

```markdown
## Verification

- You are FORBIDDEN from reporting a task as complete until you have:
  1. Run `bun test` (or the project's test command) and confirmed all tests pass
  2. Run `npx tsc --noEmit` and confirmed zero type errors
  3. Run `bun lint` and confirmed zero lint errors
- If any check fails, fix the errors before reporting completion
- If no test/lint/type-check is configured, state that explicitly
```

This works because it overrides Claude Code's default "try the simplest approach" directive with a concrete definition of done.

## Level up: hooks for 100% enforcement

CLAUDE.md directives are followed ~70% of the time. For 100% enforcement, use hooks.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hook": "cd \"$PROJECT_DIR\" && npx tsc --noEmit 2>&1 | tail -5; bun lint --quiet 2>&1 | tail -5 || true"
      }
    ]
  }
}
```

Now Claude Code sees type errors and lint failures on every file write, automatically. It self-corrects in the same turn.

## The verification ladder

Start with level 1. Move up as your project matures.

**Level 1: Type check + lint** (5 min setup)
```markdown
# CLAUDE.md
- Run `npx tsc --noEmit` and `bun lint` before claiming done
```

**Level 2: Tests must pass** (10 min setup)
```markdown
# CLAUDE.md  
- Run `bun test --bail` after every implementation change
- If tests fail, fix them before moving on
```

**Level 3: Visual verification** (requires Playwright MCP)
```markdown
# CLAUDE.md
- For UI changes, take a screenshot and verify the output looks correct
- Use Playwright to click through the flow, not just look at it
```

**Level 4: Cross-model review** (requires Codex plugin)
```markdown
# CLAUDE.md
- Before marking a PR ready, run /codex:review for an independent code review
- Address all findings before requesting human review
```

## Context-aware verification

Don't run every check on every file. Use hooks with matchers:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hook": "if echo \"$FILE_PATH\" | grep -qE '\\.(ts|tsx)$'; then cd \"$PROJECT_DIR\" && npx tsc --noEmit 2>&1 | tail -10 || true; fi"
      },
      {
        "matcher": "Write|Edit", 
        "hook": "if echo \"$FILE_PATH\" | grep -qE '\\.(test|spec)\\.(ts|tsx)$'; then cd \"$PROJECT_DIR\" && bun test \"$FILE_PATH\" 2>&1 | tail -20 || true; fi"
      }
    ]
  }
}
```

This runs type checking only on TypeScript files and test execution only on test files. Less noise, faster turns.

## The re-read-before-edit pattern

Claude Code's Edit tool fails silently when the `old_string` doesn't match due to stale context. After 10+ turns, Claude may be editing against a version of the file that no longer exists.

```markdown
# CLAUDE.md
- Before editing any file, re-read it first
- After editing, read the file again to confirm the change applied
- Never batch more than 3 edits to the same file without a verification read
```

## What this looks like in practice

**Without verification:**
```
You: "Add error handling to the API route"
Claude: "Done! I've added try-catch blocks to the route."
You: *opens file, finds 3 type errors and a missing import*
You: "There are type errors..."
Claude: "Sorry about that! Let me fix those."
← 2 extra turns wasted
```

**With verification:**
```
You: "Add error handling to the API route"
Claude: *writes code, runs tsc, finds 2 type errors, fixes them, 
        runs tests, all pass*
Claude: "Done. Added try-catch blocks. Type check and tests pass."
← 0 extra turns, code is correct
```

---

*Full deep dive on Claude Code's internal verification model: [Claude Code Camp newsletter](https://claudecodecamp.com?utm_source=github&utm_medium=findings&utm_campaign=field-guide)*
