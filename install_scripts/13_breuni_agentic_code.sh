#!/bin/bash

# Install and set up breuni-agentic-code
# This daemon collects OpenTelemetry metrics from Claude Code and Gemini CLI
# and exports them to Google Cloud Monitoring.
# It also configures Claude Code and Gemini CLI with the correct Vertex AI settings.

set -e

echo "Installing breuni-agentic-code..."

# Load config
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/../config.local"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ config.local not found. Please run setup.sh first."
    exit 1
fi
source "$CONFIG_FILE"

# Token lives in ~/.gitlab/glab-token (written by setup.sh); fall back to env var
if [ -z "${GITLAB_TOKEN:-}" ]; then
    GLAB_TOKEN_FILE="$HOME/.gitlab/glab-token"
    if [ -f "$GLAB_TOKEN_FILE" ]; then
        GITLAB_TOKEN=$(cat "$GLAB_TOKEN_FILE")
    else
        echo "❌ GitLab token not found. Please re-run setup.sh."
        exit 1
    fi
fi
export GITLAB_TOKEN
export BRAC_GITLAB_TOKEN="$GITLAB_TOKEN"

if [ -z "${GITLAB_URL:-}" ] || [ -z "${TEAM_ID:-}" ] || [ -z "${DEPARTMENT_ID:-}" ]; then
    echo "❌ GITLAB_URL, TEAM_ID and DEPARTMENT_ID are required in config.local."
    exit 1
fi

# Ensure ~/.local/bin is in PATH (install location of breuni-agentic-code)
export PATH="$HOME/.local/bin:$PATH"

# Install breuni-agentic-code if not already installed
if command -v breuni-agentic-code &>/dev/null; then
    echo "✅ breuni-agentic-code is already installed"
    breuni-agentic-code --version 2>/dev/null || true
else
    echo "📦 Downloading breuni-agentic-code installer..."
    INSTALL_URL="${GITLAB_URL}/api/v4/projects/beam%2Fgo-breuni-agentic-code/repository/files/scripts%2Finstall.sh/raw?ref=main"

    TMP_SCRIPT=$(mktemp)
    HTTP_STATUS=$(curl -sSL --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        -o "$TMP_SCRIPT" -w "%{http_code}" "$INSTALL_URL")

    if [ "$HTTP_STATUS" != "200" ]; then
        echo "❌ Failed to download installer (HTTP $HTTP_STATUS)."
        echo "   URL: $INSTALL_URL"
        echo "   Check your GitLab token and VPN connection."
        rm -f "$TMP_SCRIPT"
        exit 1
    fi

    if ! head -1 "$TMP_SCRIPT" | grep -q "^#!"; then
        echo "❌ Downloaded file is not a shell script (got HTTP $HTTP_STATUS but content looks wrong)."
        echo "   First line: $(head -1 "$TMP_SCRIPT")"
        rm -f "$TMP_SCRIPT"
        exit 1
    fi

    bash "$TMP_SCRIPT"
    rm -f "$TMP_SCRIPT"

    echo "✅ breuni-agentic-code installed"
fi

# Run breuni-agentic-code setup
# This configures Claude Code and Gemini CLI with Vertex AI + telemetry settings
# and installs the daemon as a system service (auto-starts on login)
echo ""
echo "Running breuni-agentic-code setup..."
echo "This will configure Claude Code and Gemini CLI and install the telemetry daemon."
echo ""
breuni-agentic-code setup --service --team-id "$TEAM_ID" --department-id "$DEPARTMENT_ID"

echo ""
echo "✅ breuni-agentic-code setup complete"
echo "   Run 'breuni-agentic-code status' to verify everything is running."
