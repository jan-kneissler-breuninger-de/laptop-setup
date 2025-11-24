#!/bin/bash

# Install Python and pip via Homebrew

set -e

echo "Installing Python and pip..."

# Check if python3 is already installed
if command -v python3 &> /dev/null; then
    echo "✅ Python is already installed"
    python3 --version
else
    echo "📦 Installing Python via Homebrew..."
    brew install python
    echo "✅ Python installed successfully"
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

# Update pip to latest version
echo "Updating pip to latest version..."
python3 -m pip install --upgrade pip

echo "✅ Python and pip setup complete"