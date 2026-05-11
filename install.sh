#!/bin/bash

# Bootstrap script - installs prerequisites and runs the full laptop setup
# Usage: curl -fsSL https://raw.githubusercontent.com/jan-kneissler-breuninger-de/laptop-setup/main/install.sh | bash

set -e

REPO_URL="https://github.com/jan-kneissler-breuninger-de/laptop-setup.git"
INSTALL_DIR="$HOME/laptop-setup"

echo "========================================="
echo "MacBook Setup Bootstrap"
echo "========================================="

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "✅ Homebrew installed"
else
    echo "✅ Homebrew already installed"
fi

# Install git if not present
if ! command -v git &>/dev/null; then
    echo "Installing git..."
    brew install git
    echo "✅ git installed"
else
    echo "✅ git already installed"
fi

# Clone or update the repo
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Updating existing installation at $INSTALL_DIR..."
    git -C "$INSTALL_DIR" pull
else
    echo "Cloning laptop-setup to $INSTALL_DIR..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

echo ""
cd "$INSTALL_DIR"
bash setup.sh
