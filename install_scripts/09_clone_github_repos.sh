#!/bin/bash

# Clone all public repositories from GitHub users/orgs listed in github.txt

set -e

echo "Cloning GitHub repositories..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GITHUB_FILE="$SCRIPT_DIR/../github.txt"
CLONE_BASE_DIR="$HOME/git/github"

# Create base directory for cloned repos
mkdir -p "$CLONE_BASE_DIR"

# Check if gh (GitHub CLI) is installed
if ! command -v gh &> /dev/null; then
    echo "❌ gh (GitHub CLI) is not installed. Please install it first."
    exit 1
fi

# Check if gh is authenticated
echo "Checking gh authentication..."
if ! gh auth status &>/dev/null; then
    echo "⚠️  gh is not authenticated"
    echo "Please authenticate with: gh auth login"
    exit 1
fi

echo "✅ gh is authenticated"

if [ -f "$GITHUB_FILE" ]; then
    while IFS= read -r user_or_org || [ -n "$user_or_org" ]; do
        # Skip empty lines and comments
        [[ -z "$user_or_org" || "$user_or_org" =~ ^[[:space:]]*# ]] && continue

        echo "📂 Processing GitHub user/org: $user_or_org"

        # Create directory for this user/org
        user_dir="$CLONE_BASE_DIR/$user_or_org"
        mkdir -p "$user_dir"

        # List all public repositories and clone them
        echo "Fetching repositories from $user_or_org..."

        # Use gh to list repos and clone each one
        gh repo list "$user_or_org" --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' 2>&1 | while read -r repo_full_name; do
            # Skip empty lines
            [[ -z "$repo_full_name" ]] && continue

            echo "Found repository: $repo_full_name"

            # Extract repo name (e.g., k-pipe/repo-name -> repo-name)
            repo_name=$(basename "$repo_full_name")
            repo_dir="$user_dir/$repo_name"

            if [ -d "$repo_dir/.git" ]; then
                echo "✅ $repo_name already cloned, pulling latest changes..."
                (cd "$repo_dir" && git pull --ff-only) || echo "⚠️  Could not update $repo_name"
            else
                echo "📦 Cloning $repo_full_name to $repo_dir..."
                gh repo clone "$repo_full_name" "$repo_dir" || echo "⚠️  Could not clone $repo_full_name"
            fi
        done

        echo "✅ Completed processing user/org: $user_or_org"
    done < "$GITHUB_FILE"
else
    echo "⚠️  github.txt file not found at $GITHUB_FILE"
    exit 1
fi

echo "✅ All GitHub repositories processed successfully"
echo "Repositories cloned to: $CLONE_BASE_DIR"
