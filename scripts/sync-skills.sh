#!/usr/bin/env bash
set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"

CONFIG_FILE="distribution/sync-targets.yml"
BRANCH="chore/sync-ai-skills"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: $CONFIG_FILE not found."
  exit 1
fi

# Parse the intentionally simple sync-targets.yml structure:
#
# projects:
#   owner/repo:
#     skills:
#       - skill-a
#       - skill-b
#
# Output format:
# owner/repo|skill-a,skill-b
parse_projects() {
  awk '
    /^  [^[:space:]][^:]*\/[^:]*:[[:space:]]*$/ {
      if (repo != "") {
        print repo "|" skills
      }

      repo=$0
      sub(/^  /, "", repo)
      sub(/:[[:space:]]*$/, "", repo)

      skills=""
      in_skills=0
      next
    }

    /^    skills:[[:space:]]*$/ {
      in_skills=1
      next
    }

    in_skills && /^      - / {
      skill=$0
      sub(/^      - /, "", skill)

      if (skills == "") {
        skills=skill
      } else {
        skills=skills "," skill
      }
      next
    }

    /^  [^[:space:]]/ {
      in_skills=0
    }

    END {
      if (repo != "") {
        print repo "|" skills
      }
    }
  ' "$CONFIG_FILE"
}

while IFS='|' read -r repo skills_csv; do
  [ -n "$repo" ] || continue

  echo "=================================================="
  echo "Processing: $repo"
  echo "Skills: $skills_csv"
  echo "=================================================="

  repo_name="${repo##*/}"
  work_dir="$(mktemp -d)"

  git clone \
    "https://x-access-token:${GH_TOKEN}@github.com/${repo}.git" \
    "$work_dir"

  target_skills_dir="$work_dir/.github/skills"
  manifest_file="$target_skills_dir/.central-skills"

  mkdir -p "$target_skills_dir"

  current_skills=()
  if [ -n "$skills_csv" ]; then
    IFS=',' read -r -a current_skills <<< "$skills_csv"
  fi

  previous_skills=()
  if [ -f "$manifest_file" ]; then
    mapfile -t previous_skills < "$manifest_file"
  fi

  # Remove skills that were previously centrally managed
  # but are no longer assigned to this repository.
  for old_skill in "${previous_skills[@]}"; do
    [ -n "$old_skill" ] || continue

    found=0
    for skill in "${current_skills[@]}"; do
      if [ "$skill" = "$old_skill" ]; then
        found=1
        break
      fi
    done

    if [ "$found" -eq 0 ]; then
      echo "Removing: $old_skill"
      rm -rf "$target_skills_dir/$old_skill"
    fi
  done

  # Copy current centrally managed skills.
  for skill in "${current_skills[@]}"; do
    [ -n "$skill" ] || continue

    source="skills/$skill"
    target="$target_skills_dir/$skill"

    if [ ! -d "$source" ]; then
      echo "ERROR: Unknown skill: $skill"
      exit 1
    fi

    echo "Syncing: $skill"

    rm -rf "$target"
    mkdir -p "$target"
    cp -a "$source/." "$target/"
  done

  # Save central ownership manifest.
  printf "%s\n" "${current_skills[@]}" > "$manifest_file"

  git -C "$work_dir" add .github/skills

  if git -C "$work_dir" diff --cached --quiet; then
    echo "No changes for $repo"
    rm -rf "$work_dir"
    continue
  fi

  git -C "$work_dir" config user.name "github-actions[bot]"
  git -C "$work_dir" config \
    user.email \
    "41898282+github-actions[bot]@users.noreply.github.com"

  git -C "$work_dir" checkout -B "$BRANCH"
  git -C "$work_dir" commit -m "chore: sync AI skills"
  git -C "$work_dir" push --force origin "$BRANCH"

  existing_pr="$(
    gh pr list \
      --repo "$repo" \
      --head "$BRANCH" \
      --base develop \
      --state open \
      --json number \
      --jq '.[0].number'
  )"

  if [ -n "$existing_pr" ]; then
    echo "Updated existing PR #$existing_pr for $repo"
  else
    gh pr create \
      --repo "$repo" \
      --base develop \
      --head "$BRANCH" \
      --title "chore: sync AI skills" \
      --body "Automatically synchronized AI Skills from the central AI Skill repository."
  fi

  rm -rf "$work_dir"
done < <(parse_projects)
