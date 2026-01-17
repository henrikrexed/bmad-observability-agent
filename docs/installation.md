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
│       ├── build-project-dashboard.yaml
│       ├── build-diagnostic-notebook.yaml
│       ├── suggest-dynatrace-workflows.yaml
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
| Total Prompts | 40 |
| Menu Commands | 47 |
| Workflows | 13 |
| File Size | ~210KB |
| Lines | ~6,500 |

### Prompt Categories

| Category | Count | Description |
|----------|-------|-------------|
| BMAD Collaboration | 4 | Handoff, epics, status, sync |
| Core Orchestration | 4 | Intent detection, quality, remediation |
| Instrumentation | 9 | Auto/manual instrumentation, scoring |
| Weaver (Semconv) | 5 | Docs, code gen, validation |
| OCB (Collector) | 7 | Build custom collectors |
| Dynatrace | 11 | dtctl + MCP automation |

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

#### dtctl CLI (Required for applying configurations)

```bash
# Install dtctl (kubectl-style CLI for Dynatrace)
# Download from releases
# https://github.com/dynatrace-oss/dtctl/releases/latest

# macOS/Linux - download and install binary
curl -LO https://github.com/dynatrace-oss/dtctl/releases/latest/download/dtctl-$(uname -s | tr '[:upper:]' '[:lower:]')-amd64
chmod +x dtctl-*
sudo mv dtctl-* /usr/local/bin/dtctl

# Verify
dtctl version

# Configure your environment
dtctl config set-context my-env \
  --environment "https://abc12345.apps.dynatrace.com" \
  --token-ref my-token
dtctl config set-credentials my-token --token "dt0s16.YOUR_TOKEN"
```

#### Dynatrace MCP Server (Recommended for AI-powered features)

The Dynatrace MCP server enables the agent to discover your environment and generate context-aware DQL queries, dashboards, notebooks, and workflows.

**Benefits:**
- Discovers actual services, metrics, and entities in your environment
- Generates accurate DQL queries based on real data schema
- Creates dashboards with metrics that exist in your environment
- Builds diagnostic notebooks with relevant log/trace attributes

**Installation:**

For **Claude Code** (`~/.claude/settings.json`):
```json
{
  "mcpServers": {
    "dynatrace": {
      "command": "npx",
      "args": ["-y", "@dynatrace-oss/dynatrace-mcp-server"],
      "env": {
        "DT_ENVIRONMENT": "https://abc12345.apps.dynatrace.com",
        "DT_PLATFORM_TOKEN": "dt0s16.YOUR_TOKEN"
      }
    }
  }
}
```

For **Cursor** (`~/.cursor/mcp.json`):
```json
{
  "mcpServers": {
    "dynatrace": {
      "command": "npx",
      "args": ["-y", "@dynatrace-oss/dynatrace-mcp-server"],
      "env": {
        "DT_ENVIRONMENT": "https://abc12345.apps.dynatrace.com",
        "DT_PLATFORM_TOKEN": "dt0s16.YOUR_TOKEN"
      }
    }
  }
}
```

For **VS Code** (`.vscode/mcp.json` in your project):
```json
{
  "servers": {
    "dynatrace": {
      "command": "npx",
      "args": ["-y", "@dynatrace-oss/dynatrace-mcp-server"],
      "env": {
        "DT_ENVIRONMENT": "https://abc12345.apps.dynatrace.com",
        "DT_PLATFORM_TOKEN": "dt0s16.YOUR_TOKEN"
      }
    }
  }
}
```

**Required Token Scopes:**
- `app-engine:apps:run` (required)
- `storage:logs:read` (for log queries)
- `storage:metrics:read` (for metric queries)
- `storage:spans:read` (for trace queries)
- `storage:entities:read` (for entity discovery)
- `document:documents:read` (for existing dashboards/notebooks)
- `automation:workflows:read` (for workflow discovery)

**Optional Environment Variables:**
- `DT_GRAIL_QUERY_BUDGET_GB`: Limit data scanning (default: unlimited)

**Verify MCP Connection:**
```
# In your AI assistant, ask:
"List the services monitored in Dynatrace"

# If MCP is working, it will query your environment
# If not configured, it will provide generic guidance
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
