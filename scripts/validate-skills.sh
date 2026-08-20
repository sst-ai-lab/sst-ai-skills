#!/usr/bin/env bash
set -euo pipefail

failed=0
count=0

for skill_dir in skills/*/; do
  [ -d "$skill_dir" ] || continue

  count=$((count + 1))
  skill_name="$(basename "$skill_dir")"
  skill_file="${skill_dir}SKILL.md"

  if [ ! -f "$skill_file" ]; then
    echo "ERROR: Missing $skill_file"
    failed=1
    continue
  fi

  frontmatter_name="$(
    awk '
      BEGIN { in_frontmatter=0 }
      /^---[[:space:]]*$/ {
        if (in_frontmatter == 0) {
          in_frontmatter=1
          next
        } else {
          exit
        }
      }
      in_frontmatter && /^name:[[:space:]]*/ {
        sub(/^name:[[:space:]]*/, "")
        print
        exit
      }
    ' "$skill_file"
  )"

  description="$(
    awk '
      BEGIN { in_frontmatter=0 }
      /^---[[:space:]]*$/ {
        if (in_frontmatter == 0) {
          in_frontmatter=1
          next
        } else {
          exit
        }
      }
      in_frontmatter && /^description:[[:space:]]*/ {
        sub(/^description:[[:space:]]*/, "")
        print
        exit
      }
    ' "$skill_file"
  )"

  if [ "$frontmatter_name" != "$skill_name" ]; then
    echo "ERROR: Skill name mismatch: folder=$skill_name frontmatter=$frontmatter_name"
    failed=1
  fi

  if [ -z "$description" ]; then
    echo "ERROR: Missing description in $skill_file"
    failed=1
  fi
done

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "Validated $count skill(s)."
