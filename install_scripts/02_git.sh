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

# Load GitLab URL from config if available
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/../config.local"
GITLAB_URL=""
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi
GITLAB_HOST=$(echo "$GITLAB_URL" | sed 's|https://||' | cut -d'/' -f1)

# Generate SSH key if none exists
if [ -f ~/.ssh/id_ed25519.pub ] || [ -f ~/.ssh/id_rsa.pub ]; then
    echo "✅ SSH key already exists"
else
    echo "Generating SSH key..."
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
    echo "✅ SSH key generated"

    # Determine which public key to use
    if [ -f ~/.ssh/id_ed25519.pub ]; then
        PUBLIC_KEY_FILE=~/.ssh/id_ed25519.pub
    else
        PUBLIC_KEY_FILE=~/.ssh/id_rsa.pub
    fi

    # Print public key and instructions
    echo ""
    echo "========================================="
    echo "Your SSH public key:"
    echo "========================================="
    cat "$PUBLIC_KEY_FILE"
    echo "========================================="
    echo ""

    # Copy to clipboard on macOS
    if command -v pbcopy &>/dev/null; then
        pbcopy < "$PUBLIC_KEY_FILE"
        echo "✅ Public key copied to clipboard"
    fi

    echo ""
    echo "Add this key to your GitLab instance:"
    if [ -n "$GITLAB_URL" ]; then
        echo "  → $GITLAB_URL/-/user_settings/ssh_keys"
    fi
    echo ""
    read -r -p "Press Enter once you have added the SSH key to GitLab..."

    # Test SSH connection
    if [ -n "$GITLAB_HOST" ]; then
        echo ""
        echo "Testing SSH connection to $GITLAB_HOST..."
        SSH_OUTPUT=$(ssh -T -o StrictHostKeyChecking=no "git@$GITLAB_HOST" 2>&1 || true)
        if echo "$SSH_OUTPUT" | grep -qi "welcome"; then
            echo "✅ SSH connection to $GITLAB_HOST successful"
        else
            echo "❌ SSH connection failed. Output: $SSH_OUTPUT"
            echo "   Check that the key was added correctly and try manually:"
            echo "   ssh -T git@$GITLAB_HOST"
        fi
    fi
fi
