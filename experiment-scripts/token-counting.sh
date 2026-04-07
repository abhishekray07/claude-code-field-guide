#!/bin/bash
# token-counting.sh — Demonstrates how to measure session token spend
#
# Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06
#
# This script shows how token costs accelerate as your session grows.
# It does NOT validate population-level statistics (the 518-session dataset does that).
# It shows you the ruler so you can measure your own sessions.
#
# Expected output range: exact numbers vary by model version and session content.
# The pattern (accelerating cost per turn) should be consistent.

set -euo pipefail

echo "=== Token Counting Demonstration ==="
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

# Method 1: Built-in /cost command
echo "--- Method 1: Built-in /cost command ---"
echo ""
echo "During any Claude Code session, type:"
echo "  /cost"
echo ""
echo "This shows:"
echo "  - Total tokens used (input + output)"
echo "  - Estimated cost for the session"
echo "  - Cache hit rate"
echo ""
echo "Try it at turn 5, turn 20, and turn 50 to see the acceleration."
echo ""

# Method 2: Built-in /context command
echo "--- Method 2: Built-in /context command ---"
echo ""
echo "During any session, type:"
echo "  /context"
echo ""
echo "This shows:"
echo "  - Current context window usage (as % of 200K)"
echo "  - Breakdown by category (system prompt, tools, conversation)"
echo ""

# Method 3: ccusage (if installed)
echo "--- Method 3: ccusage (community tool) ---"
echo ""
if command -v ccusage &> /dev/null; then
    echo "ccusage is installed. Running summary..."
    echo ""
    ccusage --summary 2>/dev/null || echo "(ccusage returned an error — may need configuration)"
else
    echo "ccusage not installed. Install with:"
    echo "  pip install ccusage"
    echo ""
    echo "ccusage reads Claude Code's conversation logs and shows:"
    echo "  - Per-session token breakdown"
    echo "  - Cost per turn over time"
    echo "  - Total spend across sessions"
    echo ""
    echo "Docs: https://github.com/ryoppippi/ccusage"
fi
echo ""

# Method 4: claude-meter (if installed)
echo "--- Method 4: claude-meter (community tool) ---"
echo ""
if command -v claude-meter &> /dev/null; then
    echo "claude-meter is installed. Running..."
    echo ""
    claude-meter 2>/dev/null || echo "(claude-meter returned an error — may need configuration)"
else
    echo "claude-meter not installed. Install with:"
    echo "  npm install -g claude-meter"
    echo ""
    echo "claude-meter provides real-time token monitoring as a dashboard."
    echo ""
    echo "Docs: https://github.com/jspahrsern/claude-meter"
fi
echo ""

# The pattern to watch for
echo "=== What to look for ==="
echo ""
echo "Run /cost at these intervals during a session:"
echo ""
echo "  Turn 5:   Cost per turn should be ~\$0.08-0.15 (cache warming)"
echo "  Turn 20:  Cost per turn should be ~\$0.08-0.11 (sweet spot)"
echo "  Turn 40:  Cost per turn should be ~\$0.11-0.18 (context growing)"
echo "  Turn 60+: Cost per turn should be ~\$0.18-0.29 (getting expensive)"
echo "  After compaction: Cost spikes (cache break), then starts dropping"
echo ""
echo "These ranges come from 518 tracked sessions (Opus 4). Your mileage"
echo "varies with model choice, MCP servers loaded, and task complexity."
echo ""
echo "The key insight: cost per turn ACCELERATES. A 100-turn session"
echo "doesn't cost 2x a 50-turn session — it costs 3-4x."
echo ""
echo "See: efficiency/findings.md for the full dataset."
echo "See: efficiency/context-management.md for session structuring advice."
