#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="awesome-ai-agents-free-courses"
DESCRIPTION="A curated list of free online courses and academic lecture series for learning AI agents, LLM agents, and agentic AI."

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "Set GITHUB_TOKEN first. Example: export GITHUB_TOKEN=ghp_..." >&2
  exit 1
fi

USER_LOGIN=$(curl -fsS \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user | python3 -c 'import json,sys; print(json.load(sys.stdin)["login"])')

CREATE_OUTPUT=$(curl -sS -w "\n%{http_code}" -X POST \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"${REPO_NAME}\",\"description\":\"${DESCRIPTION}\",\"private\":false,\"has_issues\":true,\"has_projects\":false,\"has_wiki\":false}")

HTTP_CODE=$(printf "%s" "$CREATE_OUTPUT" | tail -n1)
if [ "$HTTP_CODE" != "201" ] && [ "$HTTP_CODE" != "422" ]; then
  printf "%s\n" "$CREATE_OUTPUT" >&2
  exit 1
fi

REMOTE="https://github.com/${USER_LOGIN}/${REPO_NAME}.git"
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE"
git push -u origin main

echo "Published: https://github.com/${USER_LOGIN}/${REPO_NAME}"
