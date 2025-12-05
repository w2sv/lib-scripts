#!/usr/bin/env bash
set -e

OUTPUT_FILE="release-notes.txt"

# Fix GitHub URL
GITHUB_URL=$(git remote get-url origin | sed -E 's#(git@|https://)([^/:]+)[:/](.+)\.git#https://\2/\3#')

# Previous tag
LAST_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")

# Header
echo "# Changes since last release" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Commits
if [ -z "$LAST_TAG" ]; then
    COMMITS=$(git log --pretty=format:"%h %s")
else
    COMMITS=$(git log "$LAST_TAG"..HEAD --pretty=format:"%h %s")
fi

# Write markdown links
while IFS= read -r line; do
    HASH=$(echo "$line" | awk '{print $1}')
    MSG=$(echo "$line" | cut -d' ' -f2-)
    echo "- [$MSG]($GITHUB_URL/commit/$HASH)" >> "$OUTPUT_FILE"
done <<< "$COMMITS"

echo "Release notes written to $OUTPUT_FILE"
