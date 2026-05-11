#!/bin/bash

# Main setup script for MacBook laptop
# This script orchestrates all installation steps

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
INSTALL_SCRIPTS_DIR="$SCRIPT_DIR/install_scripts"

# Create log directory
mkdir -p "$LOG_DIR"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/setup.log"
}

log "========================================="
log "Starting MacBook setup"
log "========================================="

# Load or create local config
CONFIG_FILE="$SCRIPT_DIR/config.local"

# Source existing config if present
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Pick up GITLAB_TOKEN from ~/.gitlab/glab-token if not already in environment
# (setup.sh runs as bash and does not source ~/.zshrc)
if [ -z "${GITLAB_TOKEN:-}" ] && [ -f "$HOME/.gitlab/glab-token" ]; then
    GITLAB_TOKEN=$(cat "$HOME/.gitlab/glab-token")
    export GITLAB_TOKEN
    export BRAC_GITLAB_TOKEN="$GITLAB_TOKEN"
fi

CONFIG_CHANGED=false

# GitLab URL
if [ -z "${GITLAB_URL:-}" ]; then
    echo "========================================="
    echo "Setup: configuring local settings"
    echo "========================================="
    echo ""
    read -r -p "Enter your company GitLab URL (e.g. https://gitlab.example.com): " GITLAB_URL
    GITLAB_URL="${GITLAB_URL%/}"
    if [ -z "$GITLAB_URL" ]; then echo "❌ GitLab URL is required. Exiting."; exit 1; fi
    CONFIG_CHANGED=true
fi

# GitLab Personal Access Token
if [ -z "${GITLAB_TOKEN:-}" ]; then
    echo ""
    echo "A GitLab Personal Access Token is required to clone repositories"
    echo "and install internal tools. To create one:"
    echo "  1. Open: $GITLAB_URL/-/user_settings/personal_access_tokens"
    echo "  2. Click 'Add new token'"
    echo "  3. Name: laptop-setup (or any name)"
    echo "  4. Expiration: set according to your policy (e.g. 1 year)"
    echo "  5. Scopes: select 'api'"
    echo "  6. Click 'Create personal access token'"
    echo "  7. Copy the token — it won't be shown again!"
    echo ""
    read -rs -p "Paste your GitLab Personal Access Token: " GITLAB_TOKEN
    echo ""
    if [ -z "$GITLAB_TOKEN" ]; then echo "❌ GitLab token is required. Exiting."; exit 1; fi

    # 1. Save to ~/.zshrc as GITLAB_TOKEN and BRAC_GITLAB_TOKEN for terminal sessions
    ZSHRC="$HOME/.zshrc"
    touch "$ZSHRC"
    for VAR in GITLAB_TOKEN BRAC_GITLAB_TOKEN; do
        if grep -q "export $VAR=" "$ZSHRC"; then
            sed -i '' "s|export $VAR=.*|export $VAR=\"$GITLAB_TOKEN\"|" "$ZSHRC"
        else
            echo "" >> "$ZSHRC"
            echo "export $VAR=\"$GITLAB_TOKEN\"  # added by laptop-setup" >> "$ZSHRC"
        fi
    done
    echo "✅ Saved GITLAB_TOKEN and BRAC_GITLAB_TOKEN to $ZSHRC"

    # 2. Save to ~/.gitlab/glab-token (used by glab CLI)
    mkdir -p "$HOME/.gitlab"
    echo "$GITLAB_TOKEN" > "$HOME/.gitlab/glab-token"
    chmod 600 "$HOME/.gitlab/glab-token"
    echo "✅ Saved token to ~/.gitlab/glab-token"

    export GITLAB_TOKEN
    export BRAC_GITLAB_TOKEN="$GITLAB_TOKEN"
    CONFIG_CHANGED=true
fi

# Team ID
if [ -z "${TEAM_ID:-}" ]; then
    echo ""
    read -r -p "Enter your team abbreviation (e.g. arch): " TEAM_ID
    if [ -z "$TEAM_ID" ]; then echo "❌ Team ID is required. Exiting."; exit 1; fi
    CONFIG_CHANGED=true
fi

# Department ID
if [ -z "${DEPARTMENT_ID:-}" ]; then
    read -r -p "Enter your department abbreviation (e.g. cons): " DEPARTMENT_ID
    if [ -z "$DEPARTMENT_ID" ]; then echo "❌ Department ID is required. Exiting."; exit 1; fi
    CONFIG_CHANGED=true
fi

# Save / update config.local (no token stored here — it lives in ~/.zshrc)
if [ "$CONFIG_CHANGED" = true ]; then
    cat > "$CONFIG_FILE" <<EOF
# Local configuration - not committed to git
GITLAB_URL="$GITLAB_URL"
TEAM_ID="$TEAM_ID"
DEPARTMENT_ID="$DEPARTMENT_ID"
EOF
    echo ""
    echo "✅ Config saved to config.local"
    echo ""
fi

# Run installation scripts in order
run_install_script() {
    local script=$1
    local script_path="$INSTALL_SCRIPTS_DIR/$script"

    if [ -f "$script_path" ]; then
        log "Running $script..."
        bash "$script_path" 2>&1 | tee -a "$LOG_DIR/$(basename $script .sh).log"
        log "✅ Completed $script"
    else
        log "⚠️  Script not found: $script_path"
    fi
}

# Add more scripts as needed
# run_install_script "12_custom.sh"
# etc.

log "========================================="
log "Setting up PATH for kubernetes-utils"
log "========================================="

# Make kubernetes-utils scripts executable
chmod +x "$SCRIPT_DIR/kubernetes-utils"/*

# Add ~/.local/bin and kubernetes-utils to PATH in shell configuration files
for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$rc_file" ]; then
        if ! grep -q "\.local/bin" "$rc_file"; then
            echo "" >> "$rc_file"
            echo "# Added by laptop-setup" >> "$rc_file"
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$rc_file"
            log "✅ Added ~/.local/bin to PATH in $rc_file"
        fi
        if ! grep -q "kubernetes-utils" "$rc_file"; then
            echo "export PATH=\"\$PATH:$SCRIPT_DIR/kubernetes-utils\"" >> "$rc_file"
            log "✅ Added kubernetes-utils to PATH in $rc_file"
        fi
    fi
done

# Make ~/.local/bin available in the current session too
export PATH="$HOME/.local/bin:$PATH"

# Ensure Homebrew is in PATH if already installed (e.g. re-run scenario)
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Installation order
run_install_script "01_homebrew.sh"

# Ensure Homebrew is in PATH for all subsequent scripts (covers fresh install)
eval "$(/opt/homebrew/bin/brew shellenv)"

run_install_script "02_git.sh"
run_install_script "03_development_tools.sh"

# Ensure gcloud is in PATH for subsequent scripts
GCLOUD_PATH_SCRIPT="$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"
if [ -f "$GCLOUD_PATH_SCRIPT" ]; then
    source "$GCLOUD_PATH_SCRIPT"
fi
run_install_script "04_claude.sh"
run_install_script "05_docker.sh"
run_install_script "06_helm.sh"
run_install_script "07_jetbrains_ides.sh"
run_install_script "08_brew_packages.sh"
run_install_script "09_clone_gitlab_repos.sh"
run_install_script "10_clone_github_repos.sh"
run_install_script "11_productivity_apps.sh"
run_install_script "12_python.sh"
run_install_script "13_breuni_agentic_code.sh"

log "========================================="
log "Setup complete!"
log "========================================="
log "Check logs in: $LOG_DIR"
log ""
log "Note: Run 'source ~/.zshrc' or 'source ~/.bashrc' to activate PATH changes"
