#!/usr/bin/env bash

VERSION="1.0.1"

set -euo pipefail

GITLAB_TOKEN="${GITLAB_TOKEN:-}"
PROJECT_URLS=()

usage() {
  echo "Usage: $0 [ --token <token> ] <gitlab_project_url...>"
  echo
  echo "Options:"
  echo "  --token <token>  GitLab API token. Can also be set with GITLAB_TOKEN env var."
  echo "  -h, --help       Display this help message."
  echo "  -v, --version    Display the version number."
}

# --- Argument Parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --token)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --token requires an argument." >&2
        exit 1
      fi
      GITLAB_TOKEN="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -v|--version)
      echo "$VERSION"
      exit 0
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      PROJECT_URLS+=("$1")
      shift
      ;;
  esac
done

if [[ ${#PROJECT_URLS[@]} -eq 0 ]]; then
  echo "Error: At least one GitLab project URL is required." >&2
  usage
  exit 1
fi

if [[ -z "$GITLAB_TOKEN" ]]; then
  echo "Error: GitLab token is required." >&2
  usage
  exit 1
fi

# --- Main Logic ---
FINAL_JSON="{}"
SUCCESS_COUNT=0

for URL in "${PROJECT_URLS[@]}"; do
  PROJECT_PATH=$(echo "${URL%/}" | sed 's|^https://gitlab.com/||')
  PROJECT_ID=$(echo "$PROJECT_PATH" | sed 's|/|%2F|g')

  BODY_FILE=$(mktemp)

  HTTP_CODE=$(curl --silent --output "$BODY_FILE" --write-out "%{http_code}" --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.com/api/v4/projects/$PROJECT_ID/events")

  if [ "$HTTP_CODE" -ne 200 ]; then
    ERROR_MESSAGE=$(jq -r .message < "$BODY_FILE" 2>/dev/null) || ERROR_MESSAGE="Failed with HTTP code $HTTP_CODE"
    echo "Error fetching data for project $PROJECT_PATH: $ERROR_MESSAGE" >&2
    rm -f "$BODY_FILE"
    continue # Skip to the next project
  fi

  # Use jq to process the data for the current project
  PROJECT_JSON=$(jq --arg project_path "$PROJECT_PATH" '{
    ($project_path): {
      historical: (map(select(type == "object" and has("created_at"))) | group_by(.created_at | split("T")[0]) | map({date: .[0].created_at | split("T")[0], fetches: length})),
      total: (map(select(type == "object" and has("created_at"))) | length)
    }
  }' < "$BODY_FILE")

  rm -f "$BODY_FILE"

  # Merge the current project's JSON into the final result
  FINAL_JSON=$(jq -n --argjson current "$FINAL_JSON" --argjson new "$PROJECT_JSON" '$current * $new')
  SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
done

# If no projects were successfully processed, exit with an error code.
if [ "$SUCCESS_COUNT" -eq 0 ]; then
  exit 1
fi

echo "$FINAL_JSON"
