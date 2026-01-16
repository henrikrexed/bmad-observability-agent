# Installation Guide

## Prerequisites

1. **B-MAD Method** (v6 or later)
```bash
   npx bmad-method@alpha install
```

2. **Node.js** v20 or later
```bash
   node --version  # Should be >= 20.0.0
```

3. **AI Assistant** with B-MAD support
   - Claude Code
   - Cursor
   - Windsurf
   - Claude.ai (web interface)

## Installation Steps

### 1. Clone the Repository
```bash
git clone https://github.com/henrikrexed/bmad-observability-agent.git
cd bmad-observability-agent
```

### 2. Locate Your B-MAD Project
```bash
# Find your B-MAD project directory
cd /path/to/your/bmad-project

# Verify it's a B-MAD project
ls .bmad/  # Should contain workflows directory
```

### 3. Copy Agent Files
```bash
# Create agent directory
mkdir -p my-custom-stuff/agents/o11y-engineer

# Copy agent configuration
cp /path/to/bmad-observability-agent/agent/o11y-engineer.agent.yaml \
   my-custom-stuff/agents/o11y-engineer/

# Copy workflows
cp -r /path/to/bmad-observability-agent/workflows/* \
   .bmad/workflows/
```

### 4. Build the Agent
```bash
# Build the O11y Engineer agent
npx bmad-method@alpha build o11y-engineer

# Or rebuild all agents
npx bmad-method@alpha install
# Select "compile all agents" option
```

Expected output:
```
✓ Building agent: o11y-engineer
✓ Validating configuration
✓ Compiling workflows
✓ Agent ready to use
```

### 5. Verify Installation

In your AI assistant:
```bash
# List available agents
*help

# Should see o11y-engineer in the list

# Activate the agent
*o11y-engineer

# You should see the agent menu
```

## Troubleshooting

### Agent Not Found
```bash
# Check agent file exists
ls my-custom-stuff/agents/o11y-engineer/o11y-engineer.agent.yaml

# Rebuild
npx bmad-method@alpha build o11y-engineer
```

### Workflows Not Loading
```bash
# Check workflows exist
ls .bmad/workflows/

# Should see:
# - observability-quick-start.yaml
# - assess-observability-maturity.yaml
# - configure-collector-pipeline.yaml
# - etc.

# Check YAML syntax
npx js-yaml .bmad/workflows/observability-quick-start.yaml
```

### Permission Issues
```bash
# Ensure files are readable
chmod 644 my-custom-stuff/agents/o11y-engineer/*.yaml
chmod 644 .bmad/workflows/*.yaml
```

## Optional Dependencies

### For OpenTelemetry Collector Building
```bash
# Install Go (for OCB)
# macOS
brew install go

# Linux
sudo apt-get install golang-go

# Install OpenTelemetry Collector Builder
go install go.opentelemetry.io/collector/cmd/builder@latest
```

### For Semantic Convention Management
```bash
# Install Weaver
go install github.com/open-telemetry/weaver/cmd/weaver@latest

# Verify
weaver version
```

### For Dynatrace Automation
```bash
# Install Monaco
# macOS
brew install dynatrace/dynatrace/monaco

# Linux
wget https://github.com/dynatrace/dynatrace-configuration-as-code/releases/latest/download/monaco-linux-amd64
chmod +x monaco-linux-amd64
sudo mv monaco-linux-amd64 /usr/local/bin/monaco

# Verify
monaco version
```

## Next Steps

- Read the [Quick Start Guide](quick-start.md)
- Explore [Workflows Guide](workflows-guide.md)
- Check out [Examples](examples/)

## Updating
```bash
# Pull latest changes
cd /path/to/bmad-observability-agent
git pull

# Copy updated files
cp agent/o11y-engineer.agent.yaml \
   /path/to/your/bmad-project/my-custom-stuff/agents/o11y-engineer/

cp -r workflows/* \
   /path/to/your/bmad-project/.bmad/workflows/

# Rebuild
cd /path/to/your/bmad-project
npx bmad-method@alpha build o11y-engineer
```

## Uninstallation
```bash
# Remove agent
rm -rf my-custom-stuff/agents/o11y-engineer/

# Remove workflows (optional - may be shared)
rm .bmad/workflows/observability-*.yaml
rm .bmad/workflows/assess-*.yaml
rm .bmad/workflows/configure-*.yaml
rm .bmad/workflows/build-*.yaml
rm .bmad/workflows/setup-*.yaml
rm .bmad/workflows/create-*.yaml
rm .bmad/workflows/validate-*.yaml

# Rebuild B-MAD
npx bmad-method@alpha install
```
