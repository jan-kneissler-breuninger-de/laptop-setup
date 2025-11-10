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
    echo "Installing gcloud components..."

    # Check and install beta component
    if gcloud components list --filter="id:beta" --format="value(state.name)" 2>/dev/null | grep -q "Installed"; then
        echo "✅ gcloud beta component already installed"
    else
        echo "📦 Installing gcloud beta component..."
        gcloud components install beta --quiet
    fi

    # Check and install cloud-run-proxy component
    if gcloud components list --filter="id:cloud-run-proxy" --format="value(state.name)" 2>/dev/null | grep -q "Installed"; then
        echo "✅ gcloud cloud-run-proxy component already installed"
    else
        echo "📦 Installing gcloud cloud-run-proxy component..."
        gcloud components install cloud-run-proxy --quiet
    fi
fi
