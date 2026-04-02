# Project Name

## Stack
<!-- Replace with your actual stack. Be specific -- Claude uses this to make better tool choices. -->
Next.js 15 with App Router, TypeScript, Tailwind CSS, shadcn/ui, Drizzle ORM, PostgreSQL.

## Commands
<!-- List the commands Claude should use. This prevents it from guessing wrong. -->
- `bun dev` -- start dev server
- `bun test` -- run tests
- `bun lint` -- lint check
- `bun db:push` -- push schema changes

## Rules
<!-- Keep these short and high-signal. Verbose rules go in .claude/rules/ files. -->
- Run tests before claiming anything works
- Never modify existing migration files
- Use server components by default, client components only when needed
- Prefer existing patterns in the codebase over introducing new ones

## Verification
<!-- This is the highest-leverage section. It redefines what "done" means. -->
- You are FORBIDDEN from reporting a task as complete until you have:
  1. Run `bun test` and confirmed all tests pass
  2. Run `npx tsc --noEmit` and confirmed zero type errors
  3. Run `bun lint` and confirmed zero lint errors
- If any check fails, fix the errors before reporting completion
- Before editing any file, re-read it first to avoid stale context
- After editing, read the file again to confirm the change applied

## Quality
<!-- Override Claude's default "try the simplest approach" when quality matters. -->
- If architecture is flawed or patterns are inconsistent, propose fixes -- don't just patch around them
- For tasks touching more than 5 files, use sub-agents to avoid context decay
- After 10+ turns, re-read any file before editing it -- your memory of it may be stale

## Style
<!-- Only include if Claude keeps getting it wrong. Most style is learned from context. -->
- Use named exports, not default exports
- Error messages should be user-friendly, not technical
