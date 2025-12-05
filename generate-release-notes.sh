#!/usr/bin/env bash
set -e

OUTPUT_FILE="release-notes.txt"

# GitHub URL
GITHUB_URL=$(git remote get-url origin | sed -E 's#(git@|https://)([^/:]+)[:/](.+)\.git#https://\2/\3#')

# Get tags
LAST_TAG=$(git describe --tags --abbrev=0)
PREVIOUS_TAG=$(git tag --sort=-creatordate --merged HEAD | sed -n '2p' || echo "")

# Header
echo "## What's changed" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Get commits
if [ -z "$PREVIOUS_TAG" ]; then
    # No previous tag, include all commits
    COMMITS=$(git log --pretty=format:"%h %s")
else
    COMMITS=$(git log "$PREVIOUS_TAG"..HEAD --pretty=format:"%h %s")
fi

# Write commits as - msg [hash]
while IFS= read -r line; do
    HASH=$(echo "$line" | awk '{print $1}')
    MSG=$(echo "$line" | cut -d' ' -f2-)
    echo "- $MSG [$HASH]($GITHUB_URL/commit/$HASH)" >> "$OUTPUT_FILE"
done <<< "$COMMITS"

# Append full changelog link
if [ -n "$PREVIOUS_TAG" ]; then
    echo "" >> "$OUTPUT_FILE"
    echo "**Full Changelog**: $GITHUB_URL/compare/$PREVIOUS_TAG...$LAST_TAG" >> "$OUTPUT_FILE"
fi

echo "Release notes written to $OUTPUT_FILE"