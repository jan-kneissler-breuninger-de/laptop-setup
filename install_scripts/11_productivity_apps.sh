#!/bin/bash

# Install productivity and utility applications

set -e

echo "Installing productivity applications..."

# Install Google Chrome
if [ -d "/Applications/Google Chrome.app" ]; then
    echo "✅ Google Chrome is already installed"
else
    echo "📦 Installing Google Chrome..."
    brew install --cask google-chrome
    echo "✅ Google Chrome installed successfully"
fi

# Install AnyDesk
if [ -d "/Applications/AnyDesk.app" ]; then
    echo "✅ AnyDesk is already installed"
else
    echo "📦 Installing AnyDesk..."
    brew install --cask anydesk
    echo "✅ AnyDesk installed successfully"
fi

# Install AltTab
if [ -d "/Applications/AltTab.app" ]; then
    echo "✅ AltTab is already installed"
else
    echo "📦 Installing AltTab..."
    brew install --cask alt-tab
    echo "✅ AltTab installed successfully"
fi

# Install BitWarden
if [ -d "/Applications/Bitwarden.app" ]; then
    echo "✅ BitWarden is already installed"
else
    echo "📦 Installing BitWarden..."
    brew install --cask bitwarden
    echo "✅ BitWarden installed successfully"
fi

# Install DiskSpaceAnalyzer (DaisyDisk is a popular alternative)
if [ -d "/Applications/DaisyDisk.app" ]; then
    echo "✅ DaisyDisk is already installed"
else
    echo "📦 Installing DaisyDisk (Disk Space Analyzer)..."
    brew install --cask daisydisk
    echo "✅ DaisyDisk installed successfully"
fi

# Install Disk Space Analyzer Inspector from Mac App Store
if mas list | grep -q "446243721"; then
    echo "✅ Disk Space Analyzer Inspector is already installed"
else
    echo "📦 Installing Disk Space Analyzer Inspector..."
    mas install 446243721
    echo "✅ Disk Space Analyzer Inspector installed successfully"
fi

# Install draw.io
if [ -d "/Applications/draw.io.app" ]; then
    echo "✅ draw.io is already installed"
else
    echo "📦 Installing draw.io..."
    brew install --cask drawio
    echo "✅ draw.io installed successfully"
fi

# Install Postman
if [ -d "/Applications/Postman.app" ]; then
    echo "✅ Postman is already installed"
else
    echo "📦 Installing Postman..."
    brew install --cask postman
    echo "✅ Postman installed successfully"
fi

echo "✅ All productivity applications installed successfully"
