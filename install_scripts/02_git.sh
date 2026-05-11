#!/bin/bash

# Install and configure Git

set -e

echo "Installing Git..."

# Check if Git is already installed
if command -v git &> /dev/null; then
    echo "✅ Git is already installed"
    git --version
else
    echo "📦 Installing Git via Homebrew..."
    brew install git
    echo "✅ Git installed successfully"
fi

# Check if SSH key exists
if [ -f ~/.ssh/id_rsa.pub ] || [ -f ~/.ssh/id_ed25519.pub ]; then
    echo "✅ SSH key already exists"
else
    echo "⚠️  No SSH key found"
    echo "To generate an SSH key, run: ssh-keygen"
    echo "Then add the public key to your GitLab instance under: Settings > SSH Keys"
fi
