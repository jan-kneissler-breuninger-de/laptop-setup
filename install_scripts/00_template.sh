#!/bin/bash

# Template for new installation scripts
# Copy this file and modify for new software installations

set -e

echo "Installing [SOFTWARE_NAME]..."

# Check if already installed
if command -v [COMMAND_NAME] &> /dev/null; then
    echo "✅ [SOFTWARE_NAME] is already installed"
    [COMMAND_NAME] --version
else
    echo "📦 Installing [SOFTWARE_NAME]..."

    # Installation method (choose one):

    # Option 1: Homebrew
    # brew install [PACKAGE_NAME]

    # Option 2: Homebrew Cask (for GUI apps)
    # brew install --cask [PACKAGE_NAME]

    # Option 3: npm
    # npm install -g [PACKAGE_NAME]

    # Option 4: Manual download
    # curl -L [URL] -o /tmp/installer
    # Run installer commands...

    echo "✅ [SOFTWARE_NAME] installed successfully"
fi

# Post-installation configuration (if needed)
# echo "Configuring [SOFTWARE_NAME]..."
# Configuration commands here...
