# CI Sandboxing

> Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06

## The headline

Running Claude Code in CI means running AI-generated commands in an automated pipeline with no human approval. The default security model (approval prompts) doesn't apply. You need explicit cost controls, permission restrictions, and isolation.

## The CI security model

In interactive use, the security model is:

```
Claude proposes action → Human approves/denies → Action executes
```

In CI, there's no human:

```
Claude proposes action → Action executes
```

This means every defense that relies on human judgment (approval prompts, reviewing commands) is gone. What remains: deny rules, sandbox, and pipeline-level controls.

## Cost controls

Without cost controls, a single buggy CI workflow can spend hundreds of dollars:

### Timeout

```yaml
- name: Claude Code review
  timeout-minutes: 5
  run: |
    timeout 120 claude --print "Review this diff: $(git diff origin/main...HEAD | head -5000)"
```

Double-layer timeout: GitHub Actions `timeout-minutes` kills the job, `timeout` command kills Claude specifically.

### Input size limits

```yaml
# Limit diff size sent to Claude
DIFF=$(git diff origin/main...HEAD | head -5000)
if [ ${#DIFF} -gt 50000 ]; then
  echo "Diff too large for automated review"
  exit 0
fi
```

Large diffs = large input tokens = large cost. Cap the input.

### Model selection

```yaml
# Use Sonnet (5x cheaper) for CI review tasks
claude --print --model sonnet "Review: $DIFF"
```

Opus costs $15/M input tokens. Sonnet costs $3/M. For automated review, Sonnet is usually sufficient.

### Conditional execution

```yaml
- name: Check if review needed
  id: check
  run: |
    # Skip for docs-only changes
    if git diff --name-only origin/main...HEAD | grep -qvE '\.(md|txt|json)$'; then
      echo "needs_review=true" >> $GITHUB_OUTPUT
    else
      echo "needs_review=false" >> $GITHUB_OUTPUT
    fi

- name: Claude review
  if: steps.check.outputs.needs_review == 'true'
  run: claude --print --model sonnet "Review: $(git diff origin/main...HEAD | head -5000)"
```

Don't pay for AI review on README changes.

## Permission restrictions

### Minimal GitHub permissions

```yaml
permissions:
  contents: read        # Read code only
  pull-requests: write  # Post comments only
```

Claude should never have write access to repository contents in CI. It reads code and posts comments. That's it.

### API key isolation

Use a separate Anthropic API key for CI:

```yaml
env:
  ANTHROPIC_API_KEY: ${{ secrets.CI_ANTHROPIC_API_KEY }}
```

Benefits:
- Separate billing and usage tracking
- Can set lower rate limits on the CI key
- Revoking the CI key doesn't affect local development
- Easier to audit CI-specific usage

### No other secrets

The Claude Code step should not have access to:
- Database credentials
- AWS/GCP/Azure keys
- Deployment tokens
- Other service API keys

```yaml
# BAD: Claude step inherits all secrets
- name: Review
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
    DATABASE_URL: ${{ secrets.DATABASE_URL }}       # Don't do this
    AWS_SECRET_KEY: ${{ secrets.AWS_SECRET_KEY }}    # Don't do this

# GOOD: Claude step only gets what it needs
- name: Review
  env:
    ANTHROPIC_API_KEY: ${{ secrets.CI_ANTHROPIC_API_KEY }}
```

## Network isolation

CI runners have outbound network access by default. Claude Code needs to reach the Anthropic API, but nothing else.

For GitHub Actions, you can use a network policy or firewall rule:

```yaml
- name: Review with network restriction
  run: |
    # Allow only Anthropic API
    # (Implementation depends on your CI infrastructure)
    claude --print "Review: $(git diff origin/main...HEAD | head -5000)"
```

If your CI infrastructure supports network policies (Kubernetes-based runners, custom infrastructure), restrict outbound to `api.anthropic.com` only.

## Pipeline design

### Isolated step

Run Claude Code in its own job, separate from deployment steps:

```yaml
jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      - name: Claude review
        # ... review step

  deploy:
    needs: [review]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      # ... deployment steps (Claude has no access here)
```

The review job can't affect the deploy job. Even if Claude Code is compromised, it can't trigger a deployment.

### Non-blocking review

```yaml
- name: Claude review
  continue-on-error: true  # Don't block the pipeline
  run: claude --print --model sonnet "Review: $DIFF" > review.md
```

Make AI review informational, not blocking. Humans make the merge decision.

## What to take away

1. **CI has no human checkpoint.** Every defense must be automated.
2. **Budget everything.** Timeout, input limits, model selection, conditional execution.
3. **Isolate the API key.** Separate key for CI with lower limits.
4. **Minimal permissions.** Read code, write comments. Nothing else.
5. **Non-blocking review.** AI review informs, humans decide.

---

*Related: [GitHub Actions](../workflows/github-actions.md) for workflow recipes, [Permissions](permissions.md) for the permission model, [Secrets Management](secrets.md) for credential handling.*
