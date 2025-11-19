#!/bin/bash

# Install Claude CLI and run onboarding script

set -e

echo "Installing Claude CLI..."

# Check if Claude CLI is already installed
if command -v claude &> /dev/null; then
    echo "✅ Claude CLI is already installed"
    claude --version || echo "(version check not available)"

    # Check if Claude settings already exist
    if [ -f "$HOME/.claude/settings.json" ]; then
        echo "✅ Claude is already configured (settings.json found)"
        echo "Skipping onboarding script"
    else
        echo "⚠️  Claude is installed but not configured"
        echo "Running onboarding script..."

        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
        ONBOARDING_SCRIPT="$SCRIPT_DIR/downloaded/claude_onboarding.sh"

        if [ -f "$ONBOARDING_SCRIPT" ]; then
            bash "$ONBOARDING_SCRIPT"
        else
            echo "⚠️  Claude onboarding script not found at: $ONBOARDING_SCRIPT"
            echo "Please run it manually to configure Claude"
        fi
    fi
else
    echo "📦 Installing Claude CLI via npm..."
    npm install -g @anthropic-ai/claude-code
    echo "✅ Claude CLI installed successfully"

    # Run Claude onboarding script after fresh installation
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    ONBOARDING_SCRIPT="$SCRIPT_DIR/downloaded/claude_onboarding.sh"

    if [ -f "$ONBOARDING_SCRIPT" ]; then
        echo ""
        echo "Running Claude onboarding script..."
        bash "$ONBOARDING_SCRIPT"
    else
        echo "⚠️  Claude onboarding script not found at: $ONBOARDING_SCRIPT"
        echo "Please configure Claude manually"
    fi
fi
