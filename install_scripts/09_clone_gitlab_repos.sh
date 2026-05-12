#!/bin/bash

# Clone all repositories from GitLab groups listed in gitlab.txt

set -e

echo "Cloning GitLab repositories..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GITLAB_FILE="$SCRIPT_DIR/../gitlab.txt"
CLONE_BASE_DIR="$HOME/git/gitlab"
# Load GitLab URL from local config
CONFIG_FILE="$SCRIPT_DIR/../config.local"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ config.local not found. Please run setup.sh first to configure your GitLab URL."
    exit 1
fi
# shellcheck source=config.local
source "$CONFIG_FILE"

if [ -z "$GITLAB_URL" ]; then
    echo "❌ GITLAB_URL is not set in config.local."
    exit 1
fi

GITLAB_HOST=$(echo "$GITLAB_URL" | sed 's|https://||' | cut -d'/' -f1)
echo "GitLab host: $GITLAB_HOST"

# Create base directory for cloned repos
mkdir -p "$CLONE_BASE_DIR"

# Check if glab is installed
if ! command -v glab &> /dev/null; then
    echo "📦 Installing glab..."
    brew install glab
fi

# Check if glab is authenticated for the custom host
echo "Checking glab authentication for $GITLAB_HOST..."
if ! glab auth status --hostname "$GITLAB_HOST" &>/dev/null; then
    GLAB_TOKEN_FILE="$HOME/.gitlab/glab-token"
    if [ ! -f "$GLAB_TOKEN_FILE" ]; then
        echo "❌ Token file not found at $GLAB_TOKEN_FILE. Please re-run setup.sh."
        exit 1
    fi
    echo "Authenticating glab with $GITLAB_HOST..."
    cat "$GLAB_TOKEN_FILE" | glab auth login --hostname "$GITLAB_HOST" --stdin
    echo "✅ glab authenticated"
else
    echo "✅ glab is already authenticated for $GITLAB_HOST"
fi

# Create gitlab.txt if it doesn't exist (from example or blank)
if [ ! -f "$GITLAB_FILE" ]; then
    GITLAB_EXAMPLE="$SCRIPT_DIR/../gitlab.txt.example"
    if [ -f "$GITLAB_EXAMPLE" ]; then
        cp "$GITLAB_EXAMPLE" "$GITLAB_FILE"
        echo "Created $GITLAB_FILE from gitlab.txt.example"
    else
        echo "# GitLab groups to clone all repositories from" > "$GITLAB_FILE"
        echo "# One group URL per line, comments starting with # are ignored" >> "$GITLAB_FILE"
        echo "" >> "$GITLAB_FILE"
        echo "Created $GITLAB_FILE"
    fi
fi

# Check if gitlab.txt has any non-comment, non-empty lines
groups_count=$(grep -v '^[[:space:]]*#' "$GITLAB_FILE" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' ')

if [ "$groups_count" -eq 0 ]; then
    echo ""
    echo "⚠️  No GitLab groups configured in gitlab.txt"
    echo ""
    echo "Please enter GitLab group names to clone (one per line, empty line to finish):"
    echo "Example: ace (will be converted to $GITLAB_URL/ace)"
    echo ""

    while true; do
        read -p "GitLab group name (or press Enter to finish): " group_input

        # If empty, break
        if [ -z "$group_input" ]; then
            break
        fi

        # If input doesn't start with http, prepend the GitLab URL
        if [[ "$group_input" != http* ]]; then
            group_url="$GITLAB_URL/$group_input"
        else
            group_url="$group_input"
        fi

        # Add to file
        echo "$group_url" >> "$GITLAB_FILE"
        echo "✅ Added: $group_url"
    done

    # Re-count after adding
    groups_count=$(grep -v '^[[:space:]]*#' "$GITLAB_FILE" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' ')

    if [ "$groups_count" -eq 0 ]; then
        echo "No groups added. Skipping GitLab repository cloning."
        exit 0
    fi
    echo ""
fi

if [ -f "$GITLAB_FILE" ]; then
    groups_found=0
    while IFS= read -r group_url || [ -n "$group_url" ]; do
        # Skip empty lines and comments
        [[ -z "$group_url" || "$group_url" =~ ^[[:space:]]*# ]] && continue

        groups_found=$((groups_found + 1))

        # Extract group path from URL (e.g., https://gitlab.breuni.de/ace -> ace)
        group_path=$(echo "$group_url" | sed "s|https://$GITLAB_HOST/||" | sed 's|/$||')

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
                # Use glab to clone with GITLAB_HOST environment variable and preserve namespace
                (cd "$group_dir" && GITLAB_HOST="$GITLAB_HOST" glab repo clone "$repo_path" --preserve-namespace) || echo "⚠️  Could not clone $repo_path"
            fi
        done

        echo "✅ Completed processing group: $group_path"
    done < "$GITLAB_FILE"

    if [ "$groups_found" -eq 0 ]; then
        echo "⚠️  No GitLab groups were processed"
    else
        echo "✅ All GitLab repositories processed successfully"
        echo "Repositories cloned to: $CLONE_BASE_DIR"
    fi
fi
