#!/bin/bash

# Clone all repositories from GitLab groups listed in gitlab.txt

set -e

echo "Cloning GitLab repositories..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GITLAB_FILE="$SCRIPT_DIR/../gitlab.txt"
CLONE_BASE_DIR="$HOME/git"

# Create base directory for cloned repos
mkdir -p "$CLONE_BASE_DIR"

# Check if glab is installed
if ! command -v glab &> /dev/null; then
    echo "❌ glab is not installed. Please install it first."
    exit 1
fi

# Check if glab is authenticated
if ! glab auth status &>/dev/null; then
    echo "⚠️  glab is not authenticated"
    echo "Please authenticate with: glab auth login"
    exit 1
fi

if [ -f "$GITLAB_FILE" ]; then
    while IFS= read -r group_url || [ -n "$group_url" ]; do
        # Skip empty lines and comments
        [[ -z "$group_url" || "$group_url" =~ ^[[:space:]]*# ]] && continue

        # Extract group path from URL (e.g., https://gitlab.breuni.de/ace -> ace)
        group_path=$(echo "$group_url" | sed 's|https://gitlab.breuni.de/||' | sed 's|/$||')

        echo "📂 Processing group: $group_path"

        # Create directory for this group
        group_dir="$CLONE_BASE_DIR/$group_path"
        mkdir -p "$group_dir"

        # List all repositories in the group and clone them
        echo "Fetching repositories from $group_path..."

        # Use glab to list repos in the group and clone each one
        glab repo list --group "$group_path" --per-page 100 2>/dev/null | while read -r repo; do
            # Skip empty lines
            [[ -z "$repo" ]] && continue

            repo_name=$(basename "$repo")
            repo_dir="$group_dir/$repo_name"

            if [ -d "$repo_dir/.git" ]; then
                echo "✅ $repo already cloned, pulling latest changes..."
                (cd "$repo_dir" && git pull --ff-only 2>/dev/null) || echo "⚠️  Could not update $repo"
            else
                echo "📦 Cloning $repo..."
                glab repo clone "$repo" "$repo_dir" 2>/dev/null || echo "⚠️  Could not clone $repo"
            fi
        done

        echo "✅ Completed processing group: $group_path"
    done < "$GITLAB_FILE"
else
    echo "⚠️  gitlab.txt file not found at $GITLAB_FILE"
    exit 1
fi

echo "✅ All GitLab repositories processed successfully"
echo "Repositories cloned to: $CLONE_BASE_DIR"
