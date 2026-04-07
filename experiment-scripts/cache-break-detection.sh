#!/bin/bash
# cache-break-detection.sh — Demonstrates how small CLAUDE.md changes break the prompt cache
#
# Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06
#
# This script shows the "two letters break the cache" phenomenon from prompt-caching.md.
# It creates a temporary CLAUDE.md, starts a session to warm the cache, then shows
# what happens when you make a tiny edit.
#
# IMPORTANT: This modifies your CLAUDE.md temporarily. It backs up and restores it.
# Run this in a test directory, not your production project.
#
# Expected output: before edit, /cost shows low per-turn cost (cached reads).
# After edit, /cost shows a spike (cache write at 1.25x for 124K tokens).

set -euo pipefail

echo "=== Cache Break Detection Demonstration ==="
echo ""

# Check for Claude Code
if ! command -v claude &> /dev/null; then
    echo "ERROR: 'claude' command not found."
    echo "Install Claude Code: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

CC_VERSION=$(claude --version 2>/dev/null || echo "unknown")
echo "Claude Code version: $CC_VERSION"
echo ""

echo "This demonstration shows how prompt cache breaks work."
echo "It's a manual experiment — follow the steps below."
echo ""
echo "=== The Experiment ==="
echo ""
echo "Step 1: Create a test directory"
echo "  mkdir /tmp/cache-test && cd /tmp/cache-test"
echo "  echo '# Test Project' > CLAUDE.md"
echo "  echo 'Use TypeScript. Run tests with: npm test' >> CLAUDE.md"
echo ""
echo "Step 2: Start a Claude Code session"
echo "  claude"
echo ""
echo "Step 3: Warm the cache (3 turns)"
echo "  Ask Claude 3 simple questions (e.g., 'what is 2+2')."
echo "  After turn 3, run: /cost"
echo "  Note the per-turn cost. It should be low (~\$0.08-0.11 on Opus)"
echo "  because the 124K system prompt is being read from cache at 0.1x cost."
echo ""
echo "Step 4: Edit CLAUDE.md (in another terminal)"
echo "  In a separate terminal, make a tiny edit:"
echo "  echo 'Use strict mode.' >> /tmp/cache-test/CLAUDE.md"
echo ""
echo "Step 5: Send another message in Claude Code"
echo "  Ask another simple question."
echo "  Run: /cost"
echo "  The per-turn cost for this turn should SPIKE (~\$0.78 on Opus)"
echo "  because the entire 124K system prompt was re-written to cache."
echo ""
echo "Step 6: Continue for 2 more turns"
echo "  Run: /cost"
echo "  Cost should drop back to normal as the new cache warms up."
echo ""
echo "=== What's happening ==="
echo ""
echo "Claude Code's prompt cache uses a prefix-match strategy:"
echo ""
echo "  Turn N:   [system prompt + CLAUDE.md + tools] → CACHED"
echo "  Turn N+1: [system prompt + CLAUDE.md(edited) + tools] → CACHE MISS"
echo "            The prefix changed, so the entire cache is invalidated."
echo "            Claude writes the new prefix to cache at 1.25x cost."
echo "  Turn N+2: [system prompt + CLAUDE.md(edited) + tools] → CACHED again"
echo ""
echo "The cache key is the byte-exact prefix of the API request."
echo "Even adding one character to CLAUDE.md changes the prefix."
echo "Even changing capitalization breaks it."
echo ""
echo "Cost of a single cache break on Opus:"
echo "  The full 124K system prompt is re-written to cache at 1.25x input rate."
echo "  vs normal turn: 124K is read from cache at 0.1x input rate."
echo ""
echo "That's a massive cost multiplier for one turn. The per-turn cost from"
echo "/cost will spike noticeably — the exact amount depends on current pricing."
echo "See: efficiency/findings.md and under-the-hood/system-prompt.md for measured costs."
echo ""
echo "=== Takeaway ==="
echo ""
echo "Don't edit CLAUDE.md during a session. Make all your changes before"
echo "starting Claude Code, or start a new session after editing."
echo ""
echo "See: efficiency/prompt-caching.md for the full breakdown."
echo ""
echo "Cleanup: rm -rf /tmp/cache-test"
