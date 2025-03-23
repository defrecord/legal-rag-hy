#!/bin/bash
# git-commit-with-trailers.sh - Helper script for git commits with attribution trailers
# 
# Usage: ./scripts/git-commit-with-trailers.sh "feat(component): your commit message" [files to add]
#
# This script helps ensure all commits include the required attribution trailers
# for the LITCon 2025 project.

set -euo pipefail

# Default values
DEFAULT_DRIVING_AGENT="aygp-dr"
DEFAULT_LLM_AGENT="claude-code"
DEFAULT_LLM_MODEL="claude-3-7-sonnet-20250219"
DEFAULT_REVIEWED_BY="jwalsh"

# Generate a session ID if not present
USER=$(whoami)
DATE=$(date +%Y%m%d)
RANDOM_ID=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 4 | head -n 1)
SESSION_ID="SESSION-${DATE}-${USER}-${RANDOM_ID}"

# Check if we have a commit message
if [ $# -lt 1 ]; then
  echo "Error: Missing commit message"
  echo "Usage: ./scripts/git-commit-with-trailers.sh \"feat(component): your commit message\" [files to add]"
  exit 1
fi

COMMIT_MSG="$1"
shift

# Add files if specified
if [ $# -gt 0 ]; then
  git add "$@"
fi

# Execute the commit with trailers
git commit --no-gpg-sign \
  --trailer="Driving-Agent: ${DRIVING_AGENT:-$DEFAULT_DRIVING_AGENT}" \
  --trailer="LLM-Agent: ${LLM_AGENT:-$DEFAULT_LLM_AGENT}" \
  --trailer="LLM-Model: ${LLM_MODEL:-$DEFAULT_LLM_MODEL}" \
  --trailer="Reviewed-by: ${REVIEWED_BY:-$DEFAULT_REVIEWED_BY}" \
  --trailer="Session-id: ${SESSION_ID}" \
  -m "$COMMIT_MSG"

echo "Commit created successfully with trailers"