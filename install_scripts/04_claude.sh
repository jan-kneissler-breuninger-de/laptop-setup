#!/bin/bash

# Install Claude CLI and run onboarding script

set -e

echo "Installing Claude CLI..."

# Check if Claude CLI is already installed
if command -v claude &> /dev/null; then
    echo "✅ Claude CLI is already installed"
    claude --version || echo "(version check not available)"
else
    echo "📦 Installing Claude CLI via npm..."
    npm install -g @anthropic-ai/claude-code
    echo "✅ Claude CLI installed successfully"
fi

# Check if Claude settings already exist
if [ -f "$HOME/.claude/settings.json" ]; then
    echo "✅ Claude is already configured (settings.json found)"
else
    echo ""
    echo "⚠️  Claude is not yet configured."
    echo "   Please add a Claude onboarding script and reference it here."
    echo "   Onboarding should create: $HOME/.claude/settings.json"
fi
