#!/bin/bash

# Install Homebrew package manager

set -e

echo "Installing Homebrew..."

# Check if Homebrew is already installed
if command -v brew &> /dev/null; then
    echo "✅ Homebrew is already installed"
    brew --version
else
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    echo "Adding Homebrew to shell profile..."
    echo >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

    echo "✅ Homebrew installed successfully"
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update
