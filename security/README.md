# Security

What can go wrong when you give an AI shell access?

Claude Code runs commands on your machine, reads your files, and makes network requests. That power is exactly what makes it useful, and exactly what makes security non-optional.

This section covers Claude Code's threat model, permission system, prompt injection risks, and practical enforcement techniques. Everything here is Claude Code-specific, not generic AI security advice.

## What's here

| Resource | What it is |
|----------|-----------|
| [Threat Model](threat-model.md) | What can go wrong: prompt injection, data exfiltration, command injection, secrets exposure |
| [Permissions](permissions.md) | Claude Code's permission model: allow/deny, sandbox modes, how bubblewrap and seatbelt work |
| [Prompt Injection](prompt-injection.md) | How prompt injection works in Claude Code specifically, with real examples and mitigations |
| [Enforcement](enforcement.md) | Hook-based security: 100% enforcement vs ~70% CLAUDE.md compliance |
| [Secrets Management](secrets.md) | What NOT to put in CLAUDE.md, .env handling, credential hygiene |
| [CI Sandboxing](ci-sandboxing.md) | Running Claude Code safely in CI: cost controls, permissions, isolation |
