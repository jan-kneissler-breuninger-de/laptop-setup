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
    echo "📦 Installing gh (GitHub CLI)..."
    brew install gh
fi

# Token file location
GITHUB_TOKEN_FILE="$HOME/.github/token"

# Check if gh is authenticated
echo "Checking gh authentication..."
if ! gh auth status &>/dev/null; then
    echo "⚠️  gh is not authenticated"

    # Check if token file exists
    if [ -f "$GITHUB_TOKEN_FILE" ]; then
        echo "📝 Found token file at $GITHUB_TOKEN_FILE, authenticating..."
        GITHUB_TOKEN=$(cat "$GITHUB_TOKEN_FILE")
        if echo "$GITHUB_TOKEN" | gh auth login --with-token 2>&1; then
            echo "✅ Authenticated using token from $GITHUB_TOKEN_FILE"
        else
            echo "❌ Token from $GITHUB_TOKEN_FILE is invalid"
            echo "   Removing invalid token file..."
            rm -f "$GITHUB_TOKEN_FILE"
            exit 1
        fi
    else
        echo ""
        echo "GitHub token not found. Please provide a GitHub Personal Access Token."
        echo "You can create one at: https://github.com/settings/tokens"
        echo "Required scopes: repo, read:org"
        echo ""
        read -sp "GitHub Token: " GITHUB_TOKEN
        echo ""

        if [ -z "$GITHUB_TOKEN" ]; then
            echo "❌ No token provided. Exiting."
            exit 1
        fi

        # Save token to file
        mkdir -p "$(dirname "$GITHUB_TOKEN_FILE")"
        echo "$GITHUB_TOKEN" > "$GITHUB_TOKEN_FILE"
        chmod 600 "$GITHUB_TOKEN_FILE"
        echo "💾 Token saved to $GITHUB_TOKEN_FILE"

        # Authenticate with gh
        if echo "$GITHUB_TOKEN" | gh auth login --with-token 2>&1; then
            echo "✅ Authenticated with GitHub"
        else
            echo "❌ Failed to authenticate. Please check your token is valid."
            echo "   Create a new token at: https://github.com/settings/tokens"
            echo "   Required scopes: repo, read:org"
            rm -f "$GITHUB_TOKEN_FILE"
            exit 1
        fi
    fi
else
    echo "✅ gh is already authenticated"
fi

# Configure git to use gh as credential helper
echo "Configuring git to use GitHub CLI for authentication..."
gh auth setup-git

if [ -f "$GITHUB_FILE" ]; then
    users_found=0
    while IFS= read -r user_or_org || [ -n "$user_or_org" ]; do
        # Skip empty lines and comments
        [[ -z "$user_or_org" || "$user_or_org" =~ ^[[:space:]]*# ]] && continue

        users_found=$((users_found + 1))

        echo "📂 Processing GitHub user/org: $user_or_org"

        # Create directory for this user/org
        user_dir="$CLONE_BASE_DIR/$user_or_org"
        mkdir -p "$user_dir"

        # List all repositories (public and private) and clone them
        echo "Fetching repositories from $user_or_org..."

        # Use gh to list repos and clone each one (includes both public and private repos when authenticated)
        gh repo list "$user_or_org" --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' | while read -r repo_full_name; do
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

    if [ "$users_found" -eq 0 ]; then
        echo "⚠️  No GitHub users/orgs found in $GITHUB_FILE"
        echo "   Add GitHub usernames or organizations to github.txt (one per line)"
    else
        echo "✅ All GitHub repositories processed successfully"
        echo "Repositories cloned to: $CLONE_BASE_DIR"
    fi
else
    echo "⚠️  github.txt file not found at $GITHUB_FILE"
    exit 1
fi
