# Extended Thinking

> Verified: Claude Code v2.1.81 | Sonnet 4.6, Opus 4.6 | 2026-03-20

## The headline

Thinking tokens bill at the output rate -- $15/MTok on Opus 4.6. And you can't see most of them. Opus redacts its thinking entirely, showing an empty `thinking` field while still charging you for the tokens.

High thinking effort is 3.5x slower than low effort with no measurable quality improvement on routine coding tasks.

## What thinking effort actually does

Claude Code has three thinking effort levels: low, medium, and high.

We ran the same coding task at all three levels:

| Effort | Time | Cost | Code quality |
|---|---|---|---|
| Low | 17s | $0.015 | Correct, clean |
| Medium | 19.9s | $0.016 | Correct, clean |
| High | 60s | $0.016 | Correct, clean |

High effort took 3.5x longer and produced identical code. The cost difference was negligible because thinking tokens are cheap relative to the full context window. But the time cost is real -- 43 extra seconds per turn adds up across a session.

## Hidden thinking on Opus

When Opus thinks, the API returns an empty `thinking` field with a valid signature. You're charged for `output_tokens` that include the thinking, but you never see the content.

On moderate tasks, ~15-17% of billed output tokens are hidden thinking. On complex reasoning tasks, this can be 3-10x the visible output.

This means:
- Your rate limit burns faster than the visible output suggests
- You can't debug Opus's reasoning when it makes mistakes
- Switching from "high" to "low" effort has minimal impact on Opus because it tends to think deeply regardless

## What to do

1. **Use medium effort as default.** Low is fine for simple tasks. High is rarely worth the time cost.
2. **Use Sonnet when thinking transparency matters.** Sonnet shows its thinking; Opus doesn't.
3. **Watch for Opus rate limit burn.** If Opus hits limits faster than expected, hidden thinking tokens are likely the cause.
4. **Don't assume high effort = better code.** On routine coding (file edits, implementations, test writing), low and high produce the same result.

Reserve high effort for genuinely complex reasoning: architectural decisions, debugging race conditions, security analysis.

---

*Full deep dive with API traffic analysis: [Extended Thinking Deep Dive](https://claudecodecamp.com/blog/extended-thinking-deep-dive?utm_source=github&utm_medium=findings&utm_campaign=field-guide)*
