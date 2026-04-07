#!/usr/bin/env bash
# check-links.sh — Validate all markdown links in the handbook
# Run before each phase ships.
#
# Checks:
# 1. Internal links (relative paths) point to files that exist
# 2. External URLs return HTTP 200 (with timeout)
#
# Usage: ./check-links.sh [--external]
#   Default: internal links only (fast)
#   --external: also check external URLs (slow, requires curl)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
CHECK_EXTERNAL=false
ERRORS=0
WARNINGS=0

if [[ "${1:-}" == "--external" ]]; then
    CHECK_EXTERNAL=true
fi

echo "Checking markdown links in: $REPO_ROOT"
echo "External URL checks: $CHECK_EXTERNAL"
echo "---"

# Find all markdown files (skip .context/, .git/, node_modules/)
MD_FILES=()
while IFS= read -r f; do
    MD_FILES+=("$f")
done < <(find "$REPO_ROOT" -name '*.md' \
    -not -path '*/.context/*' \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*' \
    | sort)

echo "Found ${#MD_FILES[@]} markdown files"
echo ""

# Check internal links
for file in "${MD_FILES[@]}"; do
    rel_file="${file#$REPO_ROOT/}"
    file_dir="$(dirname "$file")"

    # Extract markdown links: [text](path)
    # Use grep -E for macOS compatibility (no -P)
    while IFS= read -r match; do
        # Extract the URL part from [text](url)
        link=$(echo "$match" | sed 's/.*](//' | sed 's/)$//')

        # Skip empty
        if [[ -z "$link" ]]; then
            continue
        fi

        # Skip external URLs
        if [[ "$link" == http://* ]] || [[ "$link" == https://* ]] || [[ "$link" == mailto:* ]]; then
            if [[ "$CHECK_EXTERNAL" == true ]] && [[ "$link" == http* ]]; then
                # Strip anchor from URL
                url="${link%%#*}"
                status=$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 10 "$url" 2>/dev/null || echo "000")
                if [[ "$status" != "200" ]] && [[ "$status" != "301" ]] && [[ "$status" != "302" ]]; then
                    echo "WARN: $rel_file → $link (HTTP $status)"
                    WARNINGS=$((WARNINGS + 1))
                fi
            fi
            continue
        fi

        # Skip pure anchors (#section-name)
        if [[ "$link" == \#* ]]; then
            continue
        fi

        # Strip anchor from path
        path="${link%%#*}"
        # Strip query params
        path="${path%%\?*}"

        # Skip empty after stripping
        if [[ -z "$path" ]]; then
            continue
        fi

        # Resolve relative path
        target="$file_dir/$path"

        if [[ ! -e "$target" ]]; then
            echo "ERROR: $rel_file → $link (file not found)"
            ERRORS=$((ERRORS + 1))
        fi
    done < <(grep -oE '\[[^]]*\]\([^)]+\)' "$file" 2>/dev/null || true)
done

echo ""
echo "---"
echo "Results: $ERRORS errors, $WARNINGS warnings"

if [[ "$ERRORS" -gt 0 ]]; then
    echo "FAIL: $ERRORS broken internal links found"
    exit 1
fi

if [[ "$WARNINGS" -gt 0 ]]; then
    echo "PASS with warnings: $WARNINGS external URLs may be broken"
    exit 0
fi

echo "PASS: All links valid"
exit 0
