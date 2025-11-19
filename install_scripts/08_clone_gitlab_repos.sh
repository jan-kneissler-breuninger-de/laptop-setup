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
if ! glab auth status --hostname "$GITLAB_HOST" &>/dev/null; then
    echo "⚠️  glab is not authenticated for $GITLAB_HOST"
    echo "Please authenticate with: glab auth login --hostname $GITLAB_HOST"
    exit 1
fi

echo "✅ glab is authenticated for $GITLAB_HOST"

if [ -f "$GITLAB_FILE" ]; then
    while IFS= read -r group_url || [ -n "$group_url" ]; do
        # Skip empty lines and comments
        [[ -z "$group_url" || "$group_url" =~ ^[[:space:]]*# ]] && continue

        # Extract group path from URL (e.g., https://gitlab.breuni.de/ace -> ace)
        group_path=$(echo "$group_url" | sed 's|https://gitlab.breuni.de/||' | sed 's|/$||')

        echo "📂 Processing group: $group_path"

        # Create directory for this group
        group_dir="$CLONE_BASE_DIR"
        mkdir -p "$group_dir"

        # List all repositories in the group and clone them
        echo "Fetching repositories from $group_path (including subgroups)..."

        # Use glab API to get all projects in the group including subgroups
        echo "Running API call: groups/$group_path/projects?per_page=100&include_subgroups=true"

        glab api --hostname "$GITLAB_HOST" "groups/$group_path/projects?per_page=100&include_subgroups=true" --paginate 2>&1 | \
        jq -r '.[] | .path_with_namespace' 2>&1 | while read -r repo_path; do
            # Skip empty lines
            [[ -z "$repo_path" ]] && continue

            echo "Found repository: $repo_path"
            repo_dir="$group_dir/$repo_path"

            if [ -d "$repo_dir/.git" ]; then
                echo "✅ $repo_path already cloned, pulling latest changes..."
                (cd "$repo_dir" && git pull --ff-only) || echo "⚠️  Could not update $repo_path"
            else
                echo "📦 Cloning $repo_path to $repo_dir..."
                # Use glab to clone, which handles authentication and host properly
                (cd "$group_dir" && glab repo clone "$repo_path" --hostname "$GITLAB_HOST") || echo "⚠️  Could not clone $repo_path"
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
