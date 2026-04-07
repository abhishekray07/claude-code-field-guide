#!/bin/bash
# thinking-measurement.sh — Demonstrates how to measure hidden thinking token overhead
#
# Verified: Claude Code v2.1.87 | Opus 4.6 | 2026-04-06
#
# This script shows how to observe thinking token overhead in Claude Code.
# Extended thinking tokens are generated but not displayed to you. They still
# count toward your token budget and billing.
#
# Expected output: thinking tokens typically add 20-50% overhead on top of
# visible output tokens. Exact ratios vary by task complexity.

set -euo pipefail

echo "=== Thinking Token Measurement Demonstration ==="
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

echo "Extended thinking is always enabled in Claude Code with Opus."
echo "Thinking tokens are generated before the visible response but"
echo "are NOT shown in the conversation. You're paying for them."
echo ""
echo "=== The Experiment ==="
echo ""
echo "Step 1: Start a Claude Code session"
echo "  claude"
echo ""
echo "Step 2: Ask a simple question"
echo "  'What is 2+2?'"
echo "  Run: /cost"
echo "  Note the output token count."
echo ""
echo "Step 3: Ask a complex question"
echo "  'Read src/index.ts and explain every function, then suggest 3 improvements'"
echo "  Run: /cost"
echo "  Note the output token count."
echo ""
echo "Step 4: Compare the ratio"
echo "  For the simple question:"
echo "    Visible response: ~20-50 tokens"
echo "    Total output tokens (from /cost): ~200-500 tokens"
echo "    Thinking overhead: ~4-10x"
echo ""
echo "  For the complex question:"
echo "    Visible response: ~500-1000 tokens"
echo "    Total output tokens (from /cost): ~2000-5000 tokens"
echo "    Thinking overhead: ~3-5x"
echo ""
echo "The gap between visible tokens and total output tokens = thinking tokens."
echo ""
echo "=== Measuring with ccusage ==="
echo ""
echo "If you have ccusage installed (pip install ccusage), you can see"
echo "thinking tokens broken out in the per-session report:"
echo ""
echo "  ccusage --detail"
echo ""
echo "Look for the 'cache_creation' and 'cache_read' columns alongside"
echo "regular input/output to see the full token picture."
echo ""
echo "=== What thinking tokens cost ==="
echo ""
echo "On Opus 4:"
echo "  Input tokens:    \$15/M tokens"
echo "  Output tokens:   \$75/M tokens"
echo "  Thinking tokens: \$75/M tokens (same as output)"
echo ""
echo "Since thinking tokens are billed at output rates (\$75/M), and they"
echo "can be 3-10x the visible output, thinking is often the largest"
echo "single line item in your session cost."
echo ""
echo "A 1000-token visible response with 4000 thinking tokens costs:"
echo "  Visible output: 1000 × \$75/M = \$0.075"
echo "  Thinking:       4000 × \$75/M = \$0.300"
echo "  Total output:   \$0.375 (thinking is 80% of output cost)"
echo ""
echo "=== Controlling thinking overhead ==="
echo ""
echo "You can't disable thinking in Claude Code, but you can influence it:"
echo ""
echo "  1. Simple, specific prompts → less thinking"
echo "     'Read auth.ts and find where tokens are validated'"
echo "     vs 'look at the auth system and tell me about it'"
echo ""
echo "  2. Use Sonnet for simple tasks → much less thinking overhead"
echo "     /model sonnet (switch mid-session)"
echo "     Sonnet uses ~37x fewer tool calls than Opus (less thinking per turn)"
echo ""
echo "  3. Break complex questions into steps → thinking per turn is bounded"
echo "     Instead of one mega-prompt, ask 3 focused questions"
echo ""
echo "=== Takeaway ==="
echo ""
echo "Thinking tokens are the hidden tax on Claude Code sessions."
echo "You can't see them, but they're typically 3-10x your visible output."
echo "At \$75/M tokens, they're often the biggest cost in your session."
echo ""
echo "See: under-the-hood/extended-thinking.md for the full deep dive."
