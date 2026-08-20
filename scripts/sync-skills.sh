#!/usr/bin/env bash
set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"

CONFIG_FILE="distribution/sync-targets.yml"
BASE_BRANCH="develop"
SYNC_BRANCH="chore/sync-ai-skills"

# Prevent manual workflow runs from main/other branches.
if [[ "${GITHUB_ACTIONS:-}" == "true" && "${GITHUB_REF_NAME:-}" != "$BASE_BRANCH" ]]; then
  echo "ERROR: This workflow must run from '$BASE_BRANCH'. Current branch: ${GITHUB_REF_NAME:-unknown}"
  exit 1
fi

[[ -f "$CONFIG_FILE" ]] || {
  echo "ERROR: $CONFIG_FILE not found."
  exit 1
}

parse_projects() {
  awk '
    /^  [^[:space:]][^:]*\/[^:]*:[[:space:]]*$/ {
      if (repo != "") print repo "|" skills

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

      skills = skills == "" ? skill : skills "," skill
      next
    }

    END {
      if (repo != "") print repo "|" skills
    }
  ' "$CONFIG_FILE"
}

while IFS='|' read -r repo skills_csv; do
  [[ -n "$repo" ]] || continue

  echo "=================================================="
  echo "Processing: $repo"
  echo "Skills: $skills_csv"
  echo "=================================================="

  work_dir="$(mktemp -d)"

  git clone \
    --quiet \
    --depth 1 \
    --branch "$BASE_BRANCH" \
    "https://x-access-token:${GH_TOKEN}@github.com/${repo}.git" \
    "$work_dir"

  target_dir="$work_dir/.github/skills"
  manifest="$target_dir/.central-skills"

  mkdir -p "$target_dir"

  current_skills=()
  previous_skills=()

  [[ -z "$skills_csv" ]] || IFS=',' read -r -a current_skills <<< "$skills_csv"
  [[ ! -f "$manifest" ]] || mapfile -t previous_skills < "$manifest"

  # Remove centrally managed skills no longer assigned.
  for old_skill in "${previous_skills[@]}"; do
    [[ -n "$old_skill" ]] || continue

    keep=false

    for skill in "${current_skills[@]}"; do
      if [[ "$skill" == "$old_skill" ]]; then
        keep=true
        break
      fi
    done

    if [[ "$keep" == false ]]; then
      echo "Removing: $old_skill"
      rm -rf "$target_dir/$old_skill"
    fi
  done

  # Sync assigned skills.
  for skill in "${current_skills[@]}"; do
    [[ -n "$skill" ]] || continue

    source="skills/$skill"

    if [[ ! -d "$source" ]]; then
      echo "ERROR: Unknown skill: $skill"
      rm -rf "$work_dir"
      exit 1
    fi

    echo "Syncing: $skill"

    rm -rf "$target_dir/$skill"
    mkdir -p "$target_dir/$skill"
    cp -a "$source/." "$target_dir/$skill/"
  done

  printf "%s\n" "${current_skills[@]}" > "$manifest"

  git -C "$work_dir" add .github/skills

  if git -C "$work_dir" diff --cached --quiet; then
    echo "No changes for $repo"
    rm -rf "$work_dir"
    continue
  fi

  git -C "$work_dir" config user.name "github-actions[bot]"
  git -C "$work_dir" config \
    user.email "41898282+github-actions[bot]@users.noreply.github.com"

  # Always recreate the automation branch from develop.
  git -C "$work_dir" checkout -q -B "$SYNC_BRANCH"
  git -C "$work_dir" commit -q -m "chore: sync AI skills"

  # This branch is exclusively managed by this automation.
  git -C "$work_dir" push \
    --force \
    origin \
    "$SYNC_BRANCH"

  existing_pr="$(
    gh pr list \
      --repo "$repo" \
      --head "$SYNC_BRANCH" \
      --base "$BASE_BRANCH" \
      --state open \
      --json number \
      --jq '.[0].number'
  )"

  if [[ -n "$existing_pr" ]]; then
    echo "Updated PR #$existing_pr"
  else
    gh pr create \
      --repo "$repo" \
      --base "$BASE_BRANCH" \
      --head "$SYNC_BRANCH" \
      --title "chore: sync AI skills" \
      --body "Automatically synchronized AI Skills from the central AI Skill repository."
  fi

  rm -rf "$work_dir"

done < <(parse_projects)

echo "AI Skill synchronization completed."