#!/bin/bash

# Install Helm - Kubernetes package manager

set -e

echo "Installing Helm..."

# Check if already installed
if command -v helm &> /dev/null; then
    echo "✅ Helm is already installed"
    helm version
else
    echo "📦 Installing Helm via Homebrew..."
    brew install helm
    echo "✅ Helm installed successfully"
fi

echo "✅ Helm setup complete"
