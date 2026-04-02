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

## Style
<!-- Only include if Claude keeps getting it wrong. Most style is learned from context. -->
- Use named exports, not default exports
- Error messages should be user-friendly, not technical
