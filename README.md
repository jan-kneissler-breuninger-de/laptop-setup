## Setup New MacBook Instructions

This repository contains automated scripts to set up a new MacBook with all necessary development tools.

## Quick Start (Automated Setup)

After cloning this repository, run:

```bash
./setup.sh
```

This will install and configure:
- Homebrew package manager
- Git version control
- Node.js and npm
- Google Cloud CLI (gcloud) with components
- Claude CLI with telemetry configuration
- Docker Desktop
- JetBrains IDEs (IntelliJ IDEA, GoLand, PyCharm)
- Additional tools (terraform, kubectl, glab, gh, jq, graphviz, tfswitch)
- Productivity apps (AnyDesk, AltTab, BitWarden, DaisyDisk, draw.io, Postman)
- Clone GitLab repositories from configured groups
- Clone GitHub repositories from configured users/orgs
- Python (via Homebrew) with pip

All installation steps are logged in the `logs/` directory.

## Manual Steps

### 1. Chrome Browser

Download from https://www.google.com/intl/de/chrome/

### 2. Initial Git Setup (before cloning this repo)

```bash
# Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install Git
brew install git

# Generate SSH key
ssh-keygen
```

Go to https://gitlab.breuni.de/-/user_settings/ssh_keys and register your SSH key.

### 3. Clone This Repository

```bash
git clone git@gitlab.breuni.de:jan-kneissler/laptop-setup.git
cd laptop-setup
```

### 4. Run Automated Setup

```bash
./setup.sh
```

## Adding New Software

To add new software installations:

1. Copy the template: `cp install_scripts/00_template.sh install_scripts/05_yourname.sh`
2. Edit the new script to install your software
3. Add the script to `setup.sh` in the appropriate order
4. Commit the changes

## Directory Structure

```
laptop-setup/
├── setup.sh                    # Main orchestration script
├── claude_onboarding.sh        # Claude-specific configuration
├── install_scripts/            # Modular installation scripts
│   ├── 00_template.sh         # Template for new scripts
│   ├── 01_homebrew.sh         # Homebrew installation
│   ├── 02_git.sh              # Git installation
│   ├── 03_development_tools.sh # npm, gcloud, etc.
│   ├── 04_claude.sh           # Claude CLI installation
│   └── 05_docker.sh           # Docker Desktop installation
├── logs/                       # Installation logs (git-ignored)
└── README.md                   # This file
```

## Features

- **Idempotent**: Scripts can be run multiple times safely
- **Modular**: Each software has its own installation script
- **Logged**: All installations are logged with timestamps
- **Version Controlled**: Track what software is installed over time

## Notes

**Docker Installation**: The Docker installation script requires sudo access to create necessary directories. When running `./setup.sh`, you'll be prompted for your password during the Docker installation step. After installation, remember to:
1. Open Docker Desktop from Applications
2. Accept the license agreement
3. Wait for Docker to fully start (whale icon appears in menu bar)
