#!/usr/bin/env bash
set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"

CONFIG_FILE="distribution/sync-targets.yml"

BASE_BRANCH="develop"
SYNC_BRANCH="chore/sync-ai-skills"

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

  echo
  echo "=================================================="
  echo "Processing: $repo"
  echo "Base branch: $BASE_BRANCH"
  echo "Skills: $skills_csv"
  echo "=================================================="

  work_dir="$(mktemp -d)"

  cleanup() {
    rm -rf "$work_dir"
  }

  trap cleanup RETURN

  #
  # Clone explicitly from develop.
  #
  # This is important because the repository default branch might still
  # be main. The sync branch must always be created from develop.
  #
  git clone \
    --branch "$BASE_BRANCH" \
    --single-branch \
    "https://x-access-token:${GH_TOKEN}@github.com/${repo}.git" \
    "$work_dir"

  #
  # Create/reset sync branch from origin/develop.
  #
  git -C "$work_dir" checkout \
    -B "$SYNC_BRANCH" \
    "origin/$BASE_BRANCH"

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

  #
  # Remove centrally managed skills that are no longer assigned
  # to this repository.
  #
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

  #
  # Copy currently assigned centrally managed skills.
  #
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

  #
  # Save the list of skills managed by the central repository.
  #
  # This allows the next sync to distinguish centrally managed
  # skills from project-local skills.
  #
  if [ "${#current_skills[@]}" -gt 0 ]; then
    printf "%s\n" "${current_skills[@]}" > "$manifest_file"
  else
    : > "$manifest_file"
  fi

  git -C "$work_dir" add .github/skills

  #
  # Nothing changed -> do not create/update a PR.
  #
  if git -C "$work_dir" diff --cached --quiet; then
    echo "No changes for $repo"
    rm -rf "$work_dir"
    trap - RETURN
    continue
  fi

  git -C "$work_dir" config \
    user.name \
    "github-actions[bot]"

  git -C "$work_dir" config \
    user.email \
    "41898282+github-actions[bot]@users.noreply.github.com"

  git -C "$work_dir" commit \
    -m "chore: sync AI skills"

  #
  # The branch is generated automatically, so force push is intentional.
  #
  # --force-with-lease is preferred over --force because it avoids
  # overwriting unexpected remote changes.
  #
  git -C "$work_dir" push \
    --force-with-lease \
    origin \
    "$SYNC_BRANCH"

  #
  # Check whether a sync PR already exists.
  #
  existing_pr="$(
    gh pr list \
      --repo "$repo" \
      --head "$SYNC_BRANCH" \
      --base "$BASE_BRANCH" \
      --state open \
      --json number \
      --jq '.[0].number'
  )"

  if [ -n "$existing_pr" ]; then

    echo "Updated existing PR #$existing_pr for $repo"

  else

    echo "Creating PR for $repo"

    gh pr create \
      --repo "$repo" \
      --base "$BASE_BRANCH" \
      --head "$SYNC_BRANCH" \
      --title "chore: sync AI skills" \
      --body "Automatically synchronized AI Skills from the central AI Skill repository."

  fi

  rm -rf "$work_dir"
  trap - RETURN

done < <(parse_projects)

echo
echo "=================================================="
echo "AI Skill synchronization completed."
echo "=================================================="