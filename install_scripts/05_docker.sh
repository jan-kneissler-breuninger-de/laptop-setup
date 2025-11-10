#!/bin/bash

# Install Docker Desktop for macOS

echo "Installing Docker Desktop..."

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo "✅ Docker is already installed"
    docker --version
    docker compose version || echo "Note: docker compose may require Docker Desktop to be running"
else
    echo "📦 Installing Docker Desktop via Homebrew..."
    echo "⚠️  Note: This installation requires sudo - you will be prompted for your password"
    echo ""

    # Create the cli-plugins directory with sudo if it doesn't exist
    if [ ! -d /usr/local/cli-plugins ]; then
        echo "Creating /usr/local/cli-plugins directory (requires sudo)..."
        sudo mkdir -p /usr/local/cli-plugins
        sudo chown -R $(whoami):admin /usr/local/cli-plugins
    fi

    echo "Installing Docker Desktop..."
    brew install --cask docker

    if [ $? -eq 0 ]; then
        echo "✅ Docker Desktop installed successfully"
        echo ""
        echo "⚠️  Important: Docker Desktop needs to be started manually"
        echo "   1. Open Docker Desktop from Applications"
        echo "   2. Accept the license agreement"
        echo "   3. Wait for Docker to start (whale icon in menu bar)"
    else
        echo "❌ Docker Desktop installation failed"
        echo "You can install manually with: brew install --cask docker"
        exit 1
    fi
fi

# Check if Docker daemon is running
echo ""
echo "Checking Docker daemon status..."
if docker info &> /dev/null; then
    echo "✅ Docker daemon is running"
    docker --version
    docker compose version
else
    echo "⚠️  Docker daemon is not running"
    echo "   Please start Docker Desktop from Applications"
    echo "   Look for the Docker.app in /Applications"
fi
