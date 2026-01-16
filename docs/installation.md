# Installation Guide

## Prerequisites

1. **AI Assistant** with BMAD support
   - Claude Code
   - Cursor
   - Windsurf
   - Claude.ai (web interface)

2. **Git** for cloning the repository

## Repository Structure

```
bmad-observability-agent/
├── .bmad/
│   ├── agents/
│   │   └── o11y-engineer.agent.yaml    # Main agent file (37 prompts)
│   └── workflows/
│       ├── observability-quick-start.yaml
│       ├── assess-observability-maturity.yaml
│       ├── configure-collector-pipeline.yaml
│       ├── build-collector-distro.yaml
│       ├── create-custom-semconv.yaml
│       ├── validate-semantic-conventions.yaml
│       ├── setup-dynatrace.yaml
│       ├── create-dynatrace-dashboard.yaml
│       ├── create-dynatrace-workflow.yaml
│       └── validate-observability.yaml
├── docs/
│   └── installation.md
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

## Installation Methods

### Method 1: Copy to Existing BMAD Project (Recommended)

```bash
# Clone the observability agent repository
git clone https://github.com/henrikrexed/bmad-observability-agent.git

# Navigate to your existing BMAD project
cd /path/to/your/bmad-project

# Copy the agent
cp bmad-observability-agent/.bmad/agents/o11y-engineer.agent.yaml .bmad/agents/

# Copy all workflows
cp bmad-observability-agent/.bmad/workflows/*.yaml .bmad/workflows/
```

### Method 2: Use as Standalone Project

```bash
# Clone and use directly
git clone https://github.com/henrikrexed/bmad-observability-agent.git
cd bmad-observability-agent

# The .bmad directory is ready to use with your AI assistant
```

### Method 3: Git Submodule (for version tracking)

```bash
# Add as submodule to your project
cd /path/to/your/project
git submodule add https://github.com/henrikrexed/bmad-observability-agent.git .bmad-o11y

# Create symlinks to your .bmad directory
mkdir -p .bmad/agents .bmad/workflows
ln -s ../.bmad-o11y/.bmad/agents/o11y-engineer.agent.yaml .bmad/agents/
for f in .bmad-o11y/.bmad/workflows/*.yaml; do
  ln -s "../$f" .bmad/workflows/
done
```

## Verify Installation

### Check Files Exist
```bash
# Agent file
ls -la .bmad/agents/o11y-engineer.agent.yaml
# Should show ~196KB file

# Workflows
ls -la .bmad/workflows/
# Should show 10 workflow files
```

### Test in AI Assistant

In Claude Code or your AI assistant:
```
# Load the agent
Read the file .bmad/agents/o11y-engineer.agent.yaml and use it as your persona.

# Or reference a specific action
*quick-start
*check-quality
*generate-handoff
```

## Agent Statistics

| Metric | Value |
|--------|-------|
| Total Prompts | 37 |
| Menu Commands | 44 |
| Workflows | 10 |
| File Size | ~196KB |
| Lines | ~6,151 |

### Prompt Categories

| Category | Count | Description |
|----------|-------|-------------|
| BMAD Collaboration | 4 | Handoff, epics, status, sync |
| Core Orchestration | 4 | Intent detection, quality, remediation |
| Instrumentation | 9 | Auto/manual instrumentation, scoring |
| Weaver (Semconv) | 5 | Docs, code gen, validation |
| OCB (Collector) | 7 | Build custom collectors |
| Dynatrace | 8 | Monaco automation |

## Optional Dependencies

### For OpenTelemetry Collector Building

```bash
# Install Go (required for OCB)
# macOS
brew install go

# Linux
sudo apt-get install golang-go

# Install OpenTelemetry Collector Builder
go install go.opentelemetry.io/collector/cmd/builder@latest
```

### For Semantic Convention Management

```bash
# Install Weaver (Rust-based)
cargo install weaver-cli

# Or download pre-built binary
# https://github.com/open-telemetry/weaver/releases
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

## Updating

### From Git Repository

```bash
cd bmad-observability-agent
git pull origin main

# If using as submodule
git submodule update --remote
```

### Copy Updated Files

```bash
# Copy updated agent
cp bmad-observability-agent/.bmad/agents/o11y-engineer.agent.yaml .bmad/agents/

# Copy updated workflows
cp bmad-observability-agent/.bmad/workflows/*.yaml .bmad/workflows/
```

## Uninstallation

```bash
# Remove agent
rm .bmad/agents/o11y-engineer.agent.yaml

# Remove workflows
rm .bmad/workflows/observability-*.yaml
rm .bmad/workflows/assess-*.yaml
rm .bmad/workflows/configure-*.yaml
rm .bmad/workflows/build-*.yaml
rm .bmad/workflows/setup-*.yaml
rm .bmad/workflows/create-*.yaml
rm .bmad/workflows/validate-*.yaml

# If using submodule
git submodule deinit .bmad-o11y
git rm .bmad-o11y
```

## Troubleshooting

### Agent Not Loading

1. Check file path is correct:
```bash
cat .bmad/agents/o11y-engineer.agent.yaml | head -20
```

2. Verify YAML syntax:
```bash
python3 -c "import yaml; yaml.safe_load(open('.bmad/agents/o11y-engineer.agent.yaml'))"
```

### Workflows Not Found

1. Check workflows directory:
```bash
ls .bmad/workflows/*.yaml | wc -l
# Should return 10
```

2. Verify workflow references in agent match file names

### Permission Issues

```bash
chmod 644 .bmad/agents/*.yaml
chmod 644 .bmad/workflows/*.yaml
```

## Next Steps

After installation:

1. **Quick Start** - Run `*quick-start` for new observability setup
2. **Assessment** - Run `*assess-observability` for existing setups
3. **Quality Check** - Run `*check-quality` for scoring
4. **Handoff** - Run `*generate-handoff` for multi-agent collaboration

See [README.md](../README.md) for full documentation.
