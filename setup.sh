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

# Installation order
run_install_script "01_homebrew.sh"
run_install_script "02_git.sh"
run_install_script "03_development_tools.sh"
run_install_script "04_claude.sh"
run_install_script "05_docker.sh"
run_install_script "06_jetbrains_ides.sh"
run_install_script "07_brew_packages.sh"
run_install_script "08_clone_gitlab_repos.sh"
run_install_script "09_clone_github_repos.sh"
run_install_script "10_productivity_apps.sh"

# Add more scripts as needed
# run_install_script "11_python.sh"
# etc.

log "========================================="
log "Setup complete!"
log "========================================="
log "Check logs in: $LOG_DIR"
