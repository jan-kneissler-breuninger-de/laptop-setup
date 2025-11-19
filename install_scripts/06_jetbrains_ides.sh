#!/bin/bash

# Install JetBrains IDEs (IntelliJ IDEA, GoLand, PyCharm)

set -e

echo "Installing JetBrains IDEs..."

# Install IntelliJ IDEA
if [ -d "/Applications/IntelliJ IDEA.app" ]; then
    echo "✅ IntelliJ IDEA is already installed"
else
    echo "📦 Installing IntelliJ IDEA (Professional)..."
    brew install --cask intellij-idea
    echo "✅ IntelliJ IDEA installed successfully"
fi

# Install GoLand
if [ -d "/Applications/GoLand.app" ]; then
    echo "✅ GoLand is already installed"
else
    echo "📦 Installing GoLand..."
    brew install --cask goland
    echo "✅ GoLand installed successfully"
fi

# Install PyCharm
if [ -d "/Applications/PyCharm.app" ]; then
    echo "✅ PyCharm is already installed"
else
    echo "📦 Installing PyCharm (Professional)..."
    brew install --cask pycharm
    echo "✅ PyCharm installed successfully"
fi

echo "✅ All JetBrains IDEs installed successfully"
