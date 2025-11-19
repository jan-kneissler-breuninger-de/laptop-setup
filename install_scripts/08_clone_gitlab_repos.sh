#!/bin/bash

# Clone all repositories from GitLab groups listed in gitlab.txt

set -e

echo "Cloning GitLab repositories..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GITLAB_FILE="$SCRIPT_DIR/../gitlab.txt"
CLONE_BASE_DIR="$HOME/git"
GITLAB_HOST="gitlab.breuni.de"

# Create base directory for cloned repos
mkdir -p "$CLONE_BASE_DIR"

# Check if glab is installed
if ! command -v glab &> /dev/null; then
    echo "❌ glab is not installed. Please install it first."
    exit 1
fi

# Check if glab is authenticated for the custom host
echo "Checking glab authentication for $GITLAB_HOST..."
if ! glab auth status -h "$GITLAB_HOST" &>/dev/null; then
    echo "⚠️  glab is not authenticated for $GITLAB_HOST"
    echo "Please authenticate with: glab auth login -h $GITLAB_HOST"
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

        # Use glab API to get all projects in the group
        glab api -h "$GITLAB_HOST" "groups/$group_path/projects?per_page=100&include_subgroups=true" --paginate 2>/dev/null | \
        jq -r '.[].ssh_url_to_repo' 2>/dev/null | while read -r ssh_url; do
            # Skip empty lines
            [[ -z "$ssh_url" ]] && continue

            # Extract repo name from SSH URL (e.g., git@gitlab.breuni.de:ace/repo.git -> repo)
            repo_name=$(basename "$ssh_url" .git)
            repo_dir="$group_dir/$repo_name"

            if [ -d "$repo_dir/.git" ]; then
                echo "✅ $repo_name already cloned, pulling latest changes..."
                (cd "$repo_dir" && git pull --ff-only 2>/dev/null) || echo "⚠️  Could not update $repo_name"
            else
                echo "📦 Cloning $repo_name..."
                git clone "$ssh_url" "$repo_dir" 2>/dev/null || echo "⚠️  Could not clone $repo_name"
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
