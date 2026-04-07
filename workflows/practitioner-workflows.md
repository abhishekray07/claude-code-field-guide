# Practitioner Workflows

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

## The headline

The difference between "Claude Code helped a bit" and "Claude Code shipped my feature" is almost always the workflow, not the tool. These are real workflows from people who use Claude Code daily in production.

## Workflow 1: Plan-Implement-Review loop

**Who:** Abhishek Ray ([Claude Code Camp](https://claudecodecamp.com))
**Setup:** Opus 4.6, CLAUDE.md with verification section, hooks for auto-format and lint
**Data source:** 518 sessions, 67,000+ API turns

**The workflow:**

```
Session 1: Plan (15-25 turns)
  → Describe the feature/bug
  → Claude explores the codebase
  → Agree on approach
  → Write plan to a file (docs/plans/YYYY-MM-DD-feature.md)
  → End session

Session 2: Implement (30-40 turns)
  → Reference the plan file in first message
  → Claude implements step by step
  → Hooks auto-format and lint on every write
  → Run verification: tests, types, lint
  → Commit working code
  → End session

Session 3: Review (10-20 turns)
  → Use cross-model review (Codex reviews Claude's output)
  → Fix findings
  → Run full test suite
  → Final commit
```

**What makes it work:**
- Plan file carries context between sessions without token overhead
- Each session stays in the 20-40 turn sweet spot (cheapest per-turn cost)
- Verification section in CLAUDE.md means "done" = tests pass, not just "code exists"
- Cross-model review catches what self-review misses

**Key insight:** A 120-turn session costs 3-4x what three 40-turn sessions cost, and produces lower quality in the second half. Breaking work into sessions is both cheaper and better.

## Workflow 2: TDD-first with Claude

**Who:** Community practitioners (aggregated from multiple sources)
**Setup:** Any model, test framework configured in CLAUDE.md

**The workflow:**

```
1. Write the test first (or tell Claude to write it)
   "Write a failing test for: user can reset password via email"

2. Run the test — confirm it fails
   Claude runs the test, sees RED

3. Ask Claude to implement
   "Make this test pass with the minimum code needed"

4. Run the test — confirm it passes
   Claude runs the test, sees GREEN

5. Refactor
   "Clean up the implementation. Tests must still pass."

6. Repeat for next feature slice
```

**What makes it work:**
- The test is the spec. No ambiguity about what "done" means.
- Claude sees test failures and self-corrects in the same turn.
- Refactoring is safe because tests catch regressions immediately.
- Each red-green-refactor cycle is 3-5 turns, keeping sessions focused.

**Key insight:** Claude is much better at "make this test pass" than "implement this feature." The test constrains the solution space and gives Claude a concrete success criterion.

## Workflow 3: Research-then-implement

**Who:** Community practitioners working on unfamiliar codebases
**Setup:** Opus or Sonnet, Explore sub-agents for research

**The workflow:**

```
Session 1: Research (Explore agents, 10-15 turns)
  → "How does auth work in this codebase?"
  → "What's the data model for billing?"
  → "Where are the API routes defined?"
  → Write findings to a research doc

Session 2: Implement with context
  → Reference research doc
  → Claude has the codebase map without re-exploring
  → Implement changes with knowledge of existing patterns
  → Tests and verification
```

**What makes it work:**
- Research sessions use Explore sub-agents (read-only, cheaper)
- Findings written to a file persist across sessions
- Implementation session starts informed, not cold
- Avoids the "explore for 40 turns then implement for 40 turns" mega-session

**Key insight:** Separating research from implementation keeps both sessions in the sweet spot. Research sessions are cheap (read-only). Implementation sessions are focused (no codebase exploration overhead).

## Common patterns across workflows

1. **Write to files, not memory.** Plans, research, decisions — put them in files. They persist across sessions without token cost.

2. **Stay in the sweet spot.** 20-40 turns per session. Every workflow above respects this boundary.

3. **Verification is non-negotiable.** Every workflow includes a verification step. "Done" means tests pass.

4. **Use the right model for the phase.** Research can use Sonnet (cheaper). Implementation often benefits from Opus (better at complex changes). Review benefits from a different model entirely (fresh perspective).

5. **End sessions deliberately.** Don't let sessions drag on. Finish a milestone, commit, start fresh.

---

*Related: [Context Management](../efficiency/context-management.md) for why session length matters, [Cross-Model Review](../ship-quality-code/cross-model-review.md) for review workflows.*
