#!/bin/bash

# Install additional brew packages from brew-install.txt

set -e

echo "Installing additional brew packages..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BREW_PACKAGES_FILE="$SCRIPT_DIR/../brew-install.txt"

if [ -f "$BREW_PACKAGES_FILE" ]; then
    while IFS= read -r package || [ -n "$package" ]; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue

        # Extract tap if package is in format "tap/package"
        if [[ "$package" == *"/"*"/"* ]]; then
            tap="${package%/*}"
            if ! brew tap | grep -q "^${tap}$" 2>/dev/null; then
                echo "📦 Adding tap: $tap"
                brew tap "$tap" || true
            fi
        fi

        # Check if package is already installed
        if brew list "$package" &>/dev/null; then
            echo "✅ $package is already installed"
        else
            echo "📦 Installing $package..."
            if brew install "$package"; then
                echo "✅ $package installed successfully"
            else
                echo "⚠️  Failed to install $package, continuing..."
            fi
        fi
    done < "$BREW_PACKAGES_FILE"
else
    echo "⚠️  brew-install.txt file not found at $BREW_PACKAGES_FILE"
fi

echo "✅ All brew packages processed successfully"
