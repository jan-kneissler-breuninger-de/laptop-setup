#!/bin/bash

# Install Claude Code CLI and Gemini CLI

set -e

# Install Claude Code
echo "Installing Claude Code..."
if command -v claude &> /dev/null; then
    echo "✅ Claude Code is already installed"
    claude --version || echo "(version check not available)"
else
    echo "📦 Installing Claude Code via npm..."
    npm install -g @anthropic-ai/claude-code
    echo "✅ Claude Code installed successfully"
fi

# Install Gemini CLI
echo ""
echo "Installing Gemini CLI..."
if command -v gemini &> /dev/null; then
    echo "✅ Gemini CLI is already installed"
    gemini --version || echo "(version check not available)"
else
    echo "📦 Installing Gemini CLI via npm..."
    npm install -g @google/gemini-cli
    echo "✅ Gemini CLI installed successfully"
fi
