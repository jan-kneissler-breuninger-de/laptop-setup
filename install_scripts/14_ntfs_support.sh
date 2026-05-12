#!/bin/bash

# Install NTFS write support for macOS
# This allows writing to NTFS-formatted external drives (common on Windows drives)

set -e

echo "Installing NTFS write support..."

# Install macFUSE
if [ -d "/Library/Filesystems/macfuse.fs" ]; then
    echo "✅ macFUSE is already installed"
else
    echo "📦 Installing macFUSE..."
    brew install --cask macfuse
    echo "✅ macFUSE installed successfully"
    echo "⚠️  You may need to allow the system extension in System Settings > Privacy & Security"
fi

# Install ntfs-3g-mac
if command -v ntfs-3g &>/dev/null; then
    echo "✅ ntfs-3g is already installed"
else
    echo "📦 Installing ntfs-3g-mac..."
    brew install gromgit/fuse/ntfs-3g-mac
    echo "✅ ntfs-3g-mac installed successfully"
fi

echo ""
echo "✅ NTFS write support installed"
echo "   Unmount and remount any NTFS drives, or restart your Mac for changes to take effect"
echo "   You can now write to NTFS-formatted external drives"
