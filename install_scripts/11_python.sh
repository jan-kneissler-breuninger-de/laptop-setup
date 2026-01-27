#!/bin/bash

# Install Python 3.14 (latest stable) and pip via Homebrew

set -e

echo "Installing Python 3.14 and pip..."

# Check if python3.14 is already installed
if command -v python3.14 &> /dev/null; then
    echo "✅ Python 3.14 is already installed"
    python3.14 --version
else
    echo "📦 Installing Python 3.14 via Homebrew..."
    brew install python@3.14
    echo "✅ Python 3.14 installed successfully"
fi

# Install pip if not already present
if command -v pip3 &> /dev/null; then
    echo "✅ pip3 is already installed"
    pip3 --version
else
    echo "📦 Installing pip via Homebrew..."
    brew install pip
    echo "✅ pip installed successfully"
fi

echo "✅ Python 3.14 and pip setup complete"