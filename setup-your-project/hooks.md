# Hook Recipes

> Copy-paste these into your `.claude/settings.json`. Each hook has been tested in real projects.

Hooks run shell commands before or after Claude Code takes actions. They're the enforcement layer -- unlike CLAUDE.md instructions (which Claude can ignore), hooks are guaranteed to run.

## Auto-format on file write

Format code every time Claude Code writes a file. Prevents formatting commits and keeps diffs clean.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hook": "cd \"$PROJECT_DIR\" && npx prettier --write \"$FILE_PATH\" 2>/dev/null || true"
      }
    ]
  }
}
```

**Why:** Claude Code sometimes writes code with inconsistent formatting. This catches it automatically instead of needing a follow-up "please format this" message.

## Lint check after edits

Run your linter after every file edit. Claude sees the lint output and self-corrects.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hook": "cd \"$PROJECT_DIR\" && npx eslint \"$FILE_PATH\" --no-error-on-unmatched-pattern 2>&1 | head -20 || true"
      }
    ]
  }
}
```

**Why:** Claude Code will see lint errors in the hook output and fix them in the same turn. Without this, lint errors often go unnoticed until you run CI.

## Block dangerous commands

Prevent Claude Code from running commands that could cause damage.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hook": "if echo \"$COMMAND\" | grep -qE 'rm -rf|drop table|force push|reset --hard'; then echo 'BLOCKED: Dangerous command detected' >&2; exit 1; fi"
      }
    ]
  }
}
```

**Why:** Even in auto-accept mode, you want guardrails. This catches the obvious dangerous patterns. Customize the regex for your project.

## Test runner after implementation

Run tests automatically after Claude Code makes changes.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hook": "cd \"$PROJECT_DIR\" && bun test --bail 2>&1 | tail -20 || true"
      }
    ]
  }
}
```

**Why:** Claude Code sees failing tests immediately and fixes them in the same session. Without this, you often discover failures after the session is done.

## How hooks work

- **PreToolUse**: Runs before Claude Code uses a tool. Exit code 1 blocks the action.
- **PostToolUse**: Runs after a tool completes. Output is shown to Claude Code.
- **matcher**: Regex matching tool names (`Write`, `Edit`, `Bash`, etc.)
- **$FILE_PATH**: The file being written/edited.
- **$PROJECT_DIR**: Your project root.
- **$COMMAND**: The bash command being run (for Bash matcher).

Hooks run as your user. They have full access to your system. Keep them simple and auditable.

---

*Have a hook recipe that works well? [Submit a PR](../CONTRIBUTING.md).*
