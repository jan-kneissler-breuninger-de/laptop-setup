#!/bin/bash

# Install Podman Desktop for macOS

echo "Installing Podman..."

# Install podman CLI if not already installed
if command -v podman &>/dev/null; then
    echo "✅ Podman CLI is already installed"
else
    echo "📦 Installing Podman CLI..."
    brew install podman
    echo "✅ Podman CLI installed successfully"
fi

# Check if Podman Desktop is already installed
if [ -d "/Applications/Podman Desktop.app" ]; then
    echo "✅ Podman Desktop is already installed"
else
    echo "📦 Installing Podman Desktop via Homebrew..."
    brew install --cask podman-desktop

    if [ $? -eq 0 ]; then
        echo "✅ Podman Desktop installed successfully"
        echo ""
        echo "⚠️  Important: Podman Desktop needs to be started manually"
        echo "   1. Open Podman Desktop from Applications"
        echo "   2. Follow the onboarding to initialize the Podman machine"
    else
        echo "❌ Podman Desktop installation failed"
        echo "You can install manually with: brew install --cask podman-desktop"
        exit 1
    fi
fi

# Check if podman CLI is available and machine is running
echo ""
echo "Checking Podman status..."
if command -v podman &>/dev/null && podman info &>/dev/null 2>&1; then
    echo "✅ Podman is running"
    podman --version
else
    echo "⚠️  Podman machine is not running"

    # Check if podman CLI is available
    if command -v podman &>/dev/null; then
        # Check if machine exists
        if ! podman machine list 2>/dev/null | grep -q "podman-machine-default"; then
            echo "📦 Initializing Podman machine..."
            podman machine init
        fi

        # Start the machine
        echo "🚀 Starting Podman machine..."
        podman machine start

        if [ $? -eq 0 ]; then
            echo "✅ Podman machine started successfully"
            podman --version
        else
            echo "❌ Failed to start Podman machine"
            echo "   You may need to start it manually from Podman Desktop"
        fi
    fi
fi
