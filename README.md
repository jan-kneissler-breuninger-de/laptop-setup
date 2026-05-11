# MacBook Setup

Automated scripts to set up a new MacBook with all necessary development tools.

## Install

Run this single command on your new Mac (only Homebrew required — everything else is handled automatically):

```bash
curl -fsSL https://raw.githubusercontent.com/jan-kneissler-breuninger-de/laptop-setup/main/install.sh | bash
```

This will:
1. Install Homebrew (if not already installed)
2. Install git (if not already installed)
3. Clone this repository to `~/laptop-setup`
4. Run the full setup

On first run you will be asked for:

- **GitLab URL** — your company GitLab instance (e.g. `https://gitlab.example.com`)
- **GitLab Personal Access Token** — required to clone repos and install internal tools. Create one at `<your-gitlab>/-/user_settings/personal_access_tokens` with scope `api`
- **Team ID** and **Department ID** — used for telemetry attribution in Cloud Monitoring

These are saved locally in `config.local` (gitignored) and reused on subsequent runs.

## What Gets Installed

- Homebrew package manager
- Git
- Node.js and npm
- Google Cloud CLI (gcloud) with components
- Claude Code CLI
- Gemini CLI
- Podman Desktop
- breuni-agentic-code (telemetry daemon — configures Claude Code and Gemini CLI with Vertex AI + OTEL)
- JetBrains IDEs (IntelliJ IDEA, GoLand, PyCharm)
- Additional tools (terraform, kubectl, glab, gh, jq, graphviz, tfswitch, helm)
- Productivity apps (AnyDesk, AltTab, BitWarden, DaisyDisk, draw.io, Postman)
- GitLab repositories from configured groups
- GitHub repositories from configured users/orgs
- Python (via Homebrew)

All installation steps are logged in the `logs/` directory.

## Configuration

### GitLab groups to clone (`gitlab.txt`)

Add the GitLab groups whose repositories you want cloned:

```
https://your-gitlab.example.com/your-group
https://your-gitlab.example.com/another-group
```

### Additional Homebrew packages (`brew-install.txt`)

Add any extra packages to install via Homebrew, one per line.

### breuni-agentic-code (`install_scripts/13_breuni_agentic_code.sh`)

The final setup step installs the `breuni-agentic-code` daemon from your company GitLab. It:
- Downloads and installs the binary using your GitLab token
- Runs `breuni-agentic-code setup` which configures Claude Code and Gemini CLI with Vertex AI and OTEL telemetry
- Installs the daemon as a system service so it auto-starts on login

## Re-running

The scripts are idempotent — safe to run multiple times. Already-installed tools are skipped.

To update an existing installation:

```bash
cd ~/laptop-setup && git pull && ./setup.sh
```

## Directory Structure

```
laptop-setup/
├── install.sh                  # Bootstrap script (curl | bash entry point)
├── setup.sh                    # Main orchestration script
├── gitlab.txt                  # GitLab groups to clone
├── brew-install.txt            # Additional Homebrew packages
├── config.local                # Local config (git-ignored, created on first run)
├── install_scripts/            # Modular installation scripts
│   ├── 00_template.sh
│   ├── 01_homebrew.sh
│   ├── 02_git.sh
│   ├── 03_development_tools.sh
│   ├── 04_claude.sh
│   ├── 05_docker.sh
│   ├── 06_helm.sh
│   ├── 07_jetbrains_ides.sh
│   ├── 08_brew_packages.sh
│   ├── 09_clone_gitlab_repos.sh
│   ├── 10_clone_github_repos.sh
│   ├── 11_productivity_apps.sh
│   └── 12_python.sh
└── logs/                       # Installation logs (git-ignored)
```

## Adding New Software

1. Copy the template: `cp install_scripts/00_template.sh install_scripts/13_yourname.sh`
2. Edit the new script
3. Add it to `setup.sh` in the appropriate order
