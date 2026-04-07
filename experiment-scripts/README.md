# Experiment Scripts

> See the mechanics for yourself.

Runnable demonstration scripts that show how key Claude Code mechanics work. These scripts don't validate population-level statistics (that's what the 518-session dataset is for). They show you the ruler so you can measure your own sessions.

Each script:
- Runs without error on a standard Claude Code setup
- Prints the Claude Code version it was tested on
- Documents the expected output range (exact numbers vary by model version)
- Includes a freshness date

## Scripts

| Script | Demonstrates | Related finding |
|--------|-------------|-----------------|
| `token-counting.sh` | How to measure session token spend | [Session Cost Findings](../efficiency/findings.md) |
| `cache-break-detection.sh` | How small CLAUDE.md changes break the prompt cache | [Prompt Caching](../efficiency/prompt-caching.md) |
| `thinking-measurement.sh` | How to measure hidden thinking token overhead | [Extended Thinking](../under-the-hood/extended-thinking.md) |

## Running

```bash
# Make executable
chmod +x *.sh

# Run any script
./token-counting.sh
./cache-break-detection.sh
./thinking-measurement.sh
```

Each script prints instructions if dependencies are missing.

## A note on "reproducibility"

These scripts demonstrate mechanisms, not statistical claims. When we say "92% of spend happens in mega-sessions," that's a finding from 518 tracked sessions. You can't reproduce a population statistic from a single run. What you *can* do is run `token-counting.sh` and see exactly how token costs accelerate as your session grows, which shows you *why* the pattern exists.

---

*Have an experiment idea? [Submit a PR](../CONTRIBUTING.md).*
