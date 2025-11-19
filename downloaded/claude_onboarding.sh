#!/bin/bash

# Claude Onboarding Script - Simple setup for Claude CLI with OpenTelemetry

set -e

# Configuration
CLAUDE_DIR="$HOME/.claude"
DEFAULT_PROJECT_ID="breuni-genai-nexus"
DEFAULT_REGION="europe-west1"

echo "🚀 Setting up Claude with OpenTelemetry telemetry..."

# Check Google Cloud authentication first
echo "1️⃣ Verifying Google Cloud authentication..."
if gcloud auth print-identity-token &>/dev/null; then
  echo "✅ Google Cloud authentication verified"
else
  echo "⚠️  Google Cloud authentication required. Please run:"
  echo "   gcloud auth login --update-adc"
  echo ""
  echo "Then run this script again."
  exit 1
fi

# Check if gcloud cloud-run-proxy is installed
install_state=$(gcloud components list --filter="id:cloud-run-proxy" --format="value(state.name)" 2>/dev/null)
if [ "$install_state" = "Installed" ]; then
    echo "✅ gcloud component cloud-run-proxy is installed"
else
    echo "❌ gcloud component cloud-run-proxy is not installed. Please run:"
    echo "gcloud components install cloud-run-proxy"
    echo "Then run this script again."
    exit 1
fi

# Check if Claude CLI is installed
if ! command -v claude &>/dev/null; then
  echo "❌ Claude CLI is not installed."
  echo "Please install Claude CLI first:"
  echo "  npm install -g @anthropic-ai/claude-cli"
  exit 1
fi
echo "✅ Claude CLI found"

# Get user configuration
read -r -p "Enter Google Cloud Project ID [$DEFAULT_PROJECT_ID]: " PROJECT_ID
PROJECT_ID=${PROJECT_ID:-$DEFAULT_PROJECT_ID}
read -r -p "Enter Cloud ML Region [$DEFAULT_REGION]: " REGION
REGION=${REGION:-$DEFAULT_REGION}


read -r -n 10 -p "Enter your Team abbreviation: " TEAM_ID
TEAM_ID=$(echo "$TEAM_ID" | tr '[:upper:]' '[:lower:]')
if [[ -z "$TEAM_ID" ]]; then
    echo "Team abbreviation is required. Exiting."
    exit 1
fi

read -r -n 10 -p "Enter your Department abbreviation: " DEPARTMENT_ID
DEPARTMENT_ID=$(echo "$DEPARTMENT_ID" | tr '[:upper:]' '[:lower:]')
if [[ -z "$DEPARTMENT_ID" ]]; then
    echo "Department abbreviation is required. Exiting."
    exit 1
fi

echo ""
echo "📋 Configuration:"
echo "  Project ID: $PROJECT_ID"
echo "  Region: $REGION"
echo "  Team abbv: $TEAM_ID"
echo "  Department abbv: $DEPARTMENT_ID"
echo ""

# Create .claude directory
echo "2️⃣ Setting up Claude directory..."
mkdir -p "$CLAUDE_DIR"

# Create settings.json
echo "3️⃣ Creating settings.json file..."
cat > "$CLAUDE_DIR/settings.json" <<EOF
{
  "env": {
    "CLAUDE_CODE_USE_VERTEX": "1",
    "CLOUD_ML_REGION": "$REGION",
    "ANTHROPIC_VERTEX_PROJECT_ID": "$PROJECT_ID",
    "VERTEX_REGION_CLAUDE_4_0_SONNET": "$REGION",
    "DISABLE_PROMPT_CACHING": "0",
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_LOG_USER_PROMPTS": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "http/json",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://127.0.0.1:9000",
    "OTEL_METRIC_EXPORT_INTERVAL": "10000",
    "OTEL_LOGS_EXPORT_INTERVAL": "5000",
    "OTEL_RESOURCE_ATTRIBUTES": "team_id=$TEAM_ID,department_id=$DEPARTMENT_ID"
  }
}
EOF

# Create proxy wrapper script
echo "4️⃣ Creating proxy wrapper script..."
cat > "$CLAUDE_DIR/claude-proxy-wrapper.sh" <<'EOF'
#!/bin/sh

PORT=9000

if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "Error: Port $PORT is already in use."
  exit 1
fi

gcloud beta run services proxy otel-gateway \
  --project=breuninger-core-monitoring \
  --region=europe-west3 \
  --port=$PORT &
PROXY_PID=$!

if [ $? -ne 0 ]; then
  echo "Error: gcloud command failed to start. Exiting."
  exit 1
fi

trap 'echo "Stopping Claude..."; kill $PROXY_PID' EXIT
command claude "$@"
EOF

# Set permissions
echo "5️⃣ Setting script permissions..."
chmod 755 "$CLAUDE_DIR/claude-proxy-wrapper.sh"

# Setup shell alias
echo "6️⃣ Setting up shell alias..."
USER_SHELL=$(basename "$SHELL")
ALIAS_LINE="alias claude='$HOME/.claude/claude-proxy-wrapper.sh'"

case "$USER_SHELL" in
"bash")
  SHELL_CONFIG="$HOME/.bashrc"
  ;;
"zsh")
  SHELL_CONFIG="$HOME/.zshrc"
  ;;
*)
  echo "⚠️  Unsupported shell: $USER_SHELL. Defaulting to .bashrc"
  SHELL_CONFIG="$HOME/.bashrc"
  ;;
esac

# Create shell config file if it doesn't exist
if [ ! -f "$SHELL_CONFIG" ]; then
  touch "$SHELL_CONFIG"
fi

# Add or update alias
if grep -q "alias claude=" "$SHELL_CONFIG"; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|alias claude=.*|$ALIAS_LINE|" "$SHELL_CONFIG"
  else
    sed -i "s|alias claude=.*|$ALIAS_LINE|" "$SHELL_CONFIG"
  fi
  echo "✅ Updated existing claude alias"
else
  echo "" >> "$SHELL_CONFIG"
  echo "# Claude telemetry alias" >> "$SHELL_CONFIG"
  echo "$ALIAS_LINE" >> "$SHELL_CONFIG"
  echo "✅ Added claude alias"
fi

# Source the shell configuration to make alias available immediately
echo "7️⃣ Reloading shell configuration..."
if source "$SHELL_CONFIG" 2>/dev/null; then
  echo "✅ Shell configuration reloaded successfully"
else
  echo "⚠️  Could not reload shell configuration automatically"
fi

# Verify setup
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  echo "✅ Settings file created"
else
  echo "❌ Settings file creation failed"
  exit 1
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📝 Next steps:"
echo "Test Claude with telemetry:"
echo "   claude"
