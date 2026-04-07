# Enforcement

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

## The headline

CLAUDE.md instructions are followed ~70% of the time. Hooks enforce at 100%. If a rule matters for security, it needs to be a hook, not a CLAUDE.md instruction.

## The enforcement gap

CLAUDE.md is a suggestion layer. Claude reads it, tries to follow it, but can drift, forget, or be overridden by context (including prompt injection). In testing across 500+ sessions, CLAUDE.md compliance for specific formatting rules and command requirements averaged ~70%.

Hooks are a guarantee layer. They execute code before or after specific events. If a hook rejects an action, it doesn't happen. No amount of conversation context, prompt injection, or model confusion changes this.

| Mechanism | Enforcement rate | Can be bypassed by injection | Runs on |
|---|---|---|---|
| CLAUDE.md | ~70% | Yes | Model reasoning |
| Deny rules | 100% | No | Permission layer |
| Pre-write hooks | 100% | No | Code execution |
| Post-write hooks | 100% | No | Code execution |

## Hook-based security recipes

### Auto-format on every file write

```json
// .claude/settings.json
{
  "hooks": {
    "postWrite": [
      {
        "pattern": "**/*.{ts,tsx,js,jsx}",
        "command": "npx prettier --write $FILE"
      }
    ]
  }
}
```

Claude sees the reformatted file on the next read. No formatting issues survive to commit.

### Lint check on every file write

```json
{
  "hooks": {
    "postWrite": [
      {
        "pattern": "**/*.{ts,tsx}",
        "command": "npx eslint --fix $FILE && npx eslint $FILE"
      }
    ]
  }
}
```

If lint fails after auto-fix, the hook returns non-zero. Claude sees the failure and self-corrects.

### Block dangerous commands

```json
{
  "hooks": {
    "preBash": [
      {
        "command": "echo \"$COMMAND\" | grep -qE '(rm -rf|git push --force|drop table|truncate)' && exit 1 || exit 0"
      }
    ]
  }
}
```

This catches dangerous patterns before execution. Combined with deny rules for double protection.

### Audit logging

```json
{
  "hooks": {
    "preBash": [
      {
        "command": "echo \"$(date -u +%Y-%m-%dT%H:%M:%SZ) BASH: $COMMAND\" >> .claude/audit.log"
      }
    ],
    "postWrite": [
      {
        "command": "echo \"$(date -u +%Y-%m-%dT%H:%M:%SZ) WRITE: $FILE\" >> .claude/audit.log"
      }
    ]
  }
}
```

Every command and file write gets logged. Review the audit log after sessions to catch unexpected behavior.

### Prevent secrets in committed files

```json
{
  "hooks": {
    "preCommit": [
      {
        "command": "git diff --cached --diff-filter=d | grep -qEi '(api_key|secret|password|token)\\s*=\\s*['\"]?[a-zA-Z0-9]' && echo 'BLOCKED: Possible secret in commit' && exit 1 || exit 0"
      }
    ]
  }
}
```

This is a basic pattern match. For production use, consider dedicated secret scanning tools (git-secrets, gitleaks, truffleHog).

## Layering enforcement

The most secure configuration layers all mechanisms:

```
1. Deny rules: Block known-dangerous commands
   (rm -rf, git push --force, curl, wget)

2. Hooks: Enforce quality and catch edge cases
   (auto-format, lint, secret scanning, audit logging)

3. CLAUDE.md: Guide behavior for things that can't be mechanically enforced
   (code style preferences, architecture decisions, testing strategy)

4. Approval prompts: Human checkpoint for everything else
   (new dependencies, config changes, unusual commands)
```

Each layer catches what the others miss. Deny rules are absolute. Hooks catch patterns. CLAUDE.md guides judgment. Approval prompts are the last line.

## When hooks hurt

Hooks run on every event. A slow hook (e.g., running a full test suite on every file write) will make Claude Code painfully slow.

**Good hooks:** Fast (< 1 second), focused (one file), non-blocking for reads
**Bad hooks:** Slow (full build), broad (scan entire project), blocking reads

If a hook takes more than 2 seconds, Claude will appear to hang after every write. Move slow checks to pre-commit hooks instead of post-write hooks.

## What to take away

1. **If it matters for security, make it a hook.** Not a CLAUDE.md instruction.
2. **Layer your enforcement.** Deny rules + hooks + CLAUDE.md + approval prompts.
3. **Auto-format and lint hooks eliminate entire categories of issues.** Zero formatting commits in PR review.
4. **Audit log everything.** Review after sessions to catch unexpected behavior.
5. **Keep hooks fast.** Under 1 second per execution. Move slow checks to pre-commit.

---

*Related: [Hook Recipes](../ship-quality-code/hooks.md) for the full recipe collection, [Permissions](permissions.md) for deny rules, [Prompt Injection](prompt-injection.md) for what you're defending against.*
