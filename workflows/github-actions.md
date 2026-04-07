# GitHub Actions

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

## The headline

Claude Code works in CI. You can automate PR reviews, test generation, and code generation as GitHub Actions workflows. The main considerations are cost control, sandboxing, and model selection.

## Automated PR review

Use Claude Code to review pull requests on every push or PR event.

```yaml
# .github/workflows/claude-review.yml
name: Claude Code PR Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Review PR
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude --print "Review the changes in this PR. Focus on:
          1. Correctness: logic errors, edge cases, off-by-ones
          2. Security: injection, auth bypass, secrets exposure
          3. Performance: N+1 queries, unnecessary allocations
          4. Tests: missing coverage, flaky patterns

          Output your review as a markdown checklist.
          $(git diff origin/main...HEAD)" > review.md

      - name: Post review comment
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('review.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: review
            });
```

**Tips:**
- Use `--print` flag for non-interactive output
- Pipe the diff directly into the prompt for context
- Set `fetch-depth: 0` so Claude can see the full diff against main
- Use Sonnet for reviews to save cost ($3/M input vs $15/M for Opus)

## Cost controls in CI

CI runs can get expensive fast. Every PR push triggers a review, and costs are per-token.

**Model selection:**

| Task | Recommended model | Why |
|---|---|---|
| PR review | Sonnet | Reads code well, 5x cheaper than Opus |
| Test generation | Opus | Better at complex test logic |
| Code generation | Opus | Higher quality for implementation |
| Lint/format check | Don't use Claude | Use ESLint/Prettier directly |

**Budget limits:**

```yaml
- name: Review PR (with budget)
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
  run: |
    timeout 120 claude --print --model sonnet \
      "Review the changes: $(git diff origin/main...HEAD | head -5000)" \
      > review.md || echo "Review timed out or failed" > review.md
```

- Use `timeout` to cap wall clock time
- Pipe diff through `head -5000` to limit input size for large PRs
- Use Sonnet for most CI tasks (5x cheaper, good enough for review)
- Skip Claude entirely for PRs that only change docs or config

**Conditional execution:**

```yaml
- name: Check if code changed
  id: changes
  run: |
    if git diff --name-only origin/main...HEAD | grep -qE '\.(ts|tsx|js|jsx|py|go|rs)$'; then
      echo "code_changed=true" >> $GITHUB_OUTPUT
    else
      echo "code_changed=false" >> $GITHUB_OUTPUT
    fi

- name: Review PR
  if: steps.changes.outputs.code_changed == 'true'
  # ... review step
```

## Sandboxing in CI

CI environments are already sandboxed (ephemeral containers), but you should still restrict Claude's access.

**Principle of least privilege:**

```yaml
permissions:
  contents: read        # Read code, not write
  pull-requests: write  # Post comments, not merge
```

**Network restrictions:**

Claude Code doesn't have a `--no-network` flag. To restrict network access, use your CI infrastructure:

- **GitHub Actions:** Use a self-hosted runner with firewall rules allowing only `api.anthropic.com`
- **Kubernetes runners:** Use NetworkPolicy to restrict egress
- **Docker-based CI:** Use `--network` flags to limit outbound connections

**Secrets:**
- Store `ANTHROPIC_API_KEY` as a GitHub secret, never in code
- Don't expose other secrets (database URLs, AWS keys) to the Claude step
- Use separate API keys for CI vs local development (easier to rotate and audit)

## Test generation

Generate tests for new or changed code on each PR.

```yaml
- name: Generate missing tests
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
  run: |
    CHANGED_FILES=$(git diff --name-only origin/main...HEAD | grep -E '\.(ts|tsx)$' | grep -v '\.test\.')
    for file in $CHANGED_FILES; do
      TEST_FILE="${file%.ts}.test.ts"
      if [ ! -f "$TEST_FILE" ]; then
        claude --print "Write unit tests for $file. Use vitest. Cover happy path and edge cases." > "$TEST_FILE"
      fi
    done
```

**Caution:** Auto-generated tests can be superficial. Use this to create test stubs that humans review and refine, not as a replacement for thoughtful test design.

## What to take away

1. **Use Sonnet in CI.** 5x cheaper than Opus, good enough for review tasks.
2. **Budget everything.** Timeout, line limits, conditional execution.
3. **Sandbox by default.** Read-only permissions, no unnecessary secrets.
4. **Don't automate what tools do better.** Linting, formatting, and type checking should use their native tools, not Claude.
5. **Human in the loop.** Auto-generated reviews and tests are starting points, not final outputs.

---

*Related: [Cross-Model Review](../ship-quality-code/cross-model-review.md) for using different models in review, [Hook Recipes](../ship-quality-code/hooks.md) for local enforcement that complements CI.*
