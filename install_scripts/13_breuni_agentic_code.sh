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

if [ -z "$GITLAB_URL" ] || [ -z "$GITLAB_TOKEN" ]; then
    echo "❌ GITLAB_URL and GITLAB_TOKEN are required in config.local."
    exit 1
fi

if [ -z "$TEAM_ID" ] || [ -z "$DEPARTMENT_ID" ]; then
    echo "❌ TEAM_ID and DEPARTMENT_ID are required in config.local."
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
    INSTALL_URL="${GITLAB_URL}/beam/go-breuni-agentic-code/-/raw/main/scripts/install.sh"

    TMP_SCRIPT=$(mktemp)
    curl -fsSL --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$INSTALL_URL" -o "$TMP_SCRIPT" \
        || { echo "❌ Failed to download installer. Check your token and VPN connection."; rm -f "$TMP_SCRIPT"; exit 1; }

    export BRAC_GITLAB_TOKEN="$GITLAB_TOKEN"
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
