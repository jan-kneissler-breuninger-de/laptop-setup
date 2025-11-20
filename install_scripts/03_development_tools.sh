#!/bin/bash

# Install development tools (npm, node, etc.)

set -e

echo "Installing development tools..."

# Install npm
if command -v npm &> /dev/null; then
    echo "✅ npm is already installed"
    npm --version
else
    echo "📦 Installing npm via Homebrew..."
    brew install npm
    echo "✅ npm installed successfully"
fi

# Install gcloud CLI
if command -v gcloud &> /dev/null; then
    echo "✅ gcloud CLI is already installed"
    gcloud --version
else
    echo "📦 Installing gcloud CLI via Homebrew..."
    brew install --cask google-cloud-sdk
    echo "✅ gcloud CLI installed successfully"
fi

# Check gcloud authentication
echo "Checking gcloud authentication..."
if gcloud auth print-identity-token &>/dev/null; then
    echo "✅ gcloud is authenticated"
else
    echo "⚠️  gcloud is not authenticated"
    echo "To authenticate, run: gcloud auth login --update-adc"
fi

# Install gcloud components if authenticated
if gcloud auth print-identity-token &>/dev/null; then
    echo "Updating gcloud components..."
    gcloud components update --quiet

    echo "Installing required gcloud components..."

    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    COMPONENTS_FILE="$SCRIPT_DIR/../gcloud_components.txt"

    if [ -f "$COMPONENTS_FILE" ]; then
        while IFS= read -r component || [ -n "$component" ]; do
            # Skip empty lines and comments
            [[ -z "$component" || "$component" =~ ^[[:space:]]*# ]] && continue

            # Check if component is already installed
            component_status=$(gcloud components list --filter="id:$component" --format="value(state.name)" 2>/dev/null)

            if [ "$component_status" = "Installed" ]; then
                echo "✅ gcloud $component component already installed"
            else
                echo "📦 Installing gcloud $component component..."
                gcloud components install "$component" --quiet
                echo "✅ gcloud $component component installed successfully"
            fi
        done < "$COMPONENTS_FILE"
    else
        echo "⚠️  gcloud_components.txt file not found at $COMPONENTS_FILE"
    fi
fi
