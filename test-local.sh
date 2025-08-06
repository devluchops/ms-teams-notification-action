#!/bin/bash

set -euo pipefail

# Load .env file if it exists
if [[ -f .env ]]; then
    echo "📄 Loading configuration from .env file..."
    while IFS= read -r line; do
        if [[ $line && $line != \#* ]]; then
            export "$line"
        fi
    done < .env
fi

export TEAMS_WEBHOOK_URL="${TEAMS_WEBHOOK_URL:-https://example.com/webhook}"
export TITLE="${TITLE:-Test Notification}"
export MESSAGE="${MESSAGE:-This is a test message from the local development script}"
export URL="${URL:-https://github.com}"
export CREATOR="${CREATOR:-local-user}"
export REPO_NAME="${REPO_NAME:-DevLuchOps/ms-teams-notification-action}"
export WORKFLOW_URL="${WORKFLOW_URL:-https://github.com/DevLuchOps/ms-teams-notification-action/actions/runs/123456}"
export MENTION_USER="${MENTION_USER:-}"
export STATUS="${STATUS:-success}"
export DRY_RUN="${DRY_RUN:-true}"

echo "🚀 Testing MS Teams Notification Action locally..."
echo ""
echo "Configuration:"
echo "  - Title: $TITLE"
echo "  - Creator: $CREATOR"
echo "  - Repository: $REPO_NAME"
echo "  - Status: $STATUS"
echo "  - Dry Run: $DRY_RUN"
echo ""

if [[ "$DRY_RUN" != "true" ]]; then
    echo "⚠️  WARNING: Dry run is disabled. This will send a real notification!"
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

./send-notification.sh