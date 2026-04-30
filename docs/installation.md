# Installation Guide

## Prerequisites

1. **BMad Method v6.3+** installed in your project
   - See [Install BMad](https://docs.bmad-method.org/how-to/install-bmad/)
2. **AI Assistant** with BMad support
   - Claude Code
   - Cursor
   - Windsurf
3. **Git** for cloning the repository

## Repository Structure

```
bmad-observability-agent/
├── .claude-plugin/
│   └── marketplace.json          # Distribution manifest
├── skills/
│   ├── o11y-setup/               # Module setup and configuration
│   │   ├── SKILL.md
│   │   ├── scripts/              # Config merge scripts
│   │   └── assets/
│   │       ├── module.yaml       # Module identity and config variables
│   │       └── module-help.csv   # Capability registry
│   ├── o11y-engineer/            # Main agent skill (28 menu items)
│   │   ├── SKILL.md
│   │   ├── customize.toml        # Persona, menu, persistent facts
│   │   ├── prompts/              # 13 action prompts
│   │   └── assets/
│   │       ├── workflows/        # 18 workflow YAML files
│   │       └── knowledge/        # Dynatrace format reference
│   ├── o11y-write-ottl/          # OTTL expression helper
│   │   └── SKILL.md
│   ├── o11y-generate-epics/      # Epic generation for sprints
│   │   └── SKILL.md
│   ├── o11y-instrument-app/      # App instrumentation guidance
│   │   └── SKILL.md
│   └── o11y-redact-pii/          # PII redaction configuration
│       └── SKILL.md
├── docs/                          # MkDocs documentation
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

## Installation

### Custom Module Installation (Recommended)

```bash
# Install via BMad CLI
npx bmad-method install --custom-source https://github.com/henrikrexed/bmad-observability-agent
```

The installer will:
1. Detect the `.claude-plugin/marketplace.json` manifest
2. List the O11y Engineer module for selection
3. Install 6 skills to `.claude/skills/`
4. Run the `o11y-setup` skill to configure your preferences:
   - Observability backend (Dynatrace, Datadog, New Relic, Grafana Cloud, Self-hosted)
   - Collector deployment model (DaemonSet, Deployment, Sidecar, Docker, VM)
   - Primary application language (Java, Python, Node.js, Go, .NET, Mixed)
   - Artifact output location
5. Register capabilities in the BMad help system

### Local Installation

```bash
# Clone the repository
git clone https://github.com/henrikrexed/bmad-observability-agent.git

# Install from local path
npx bmad-method install --custom-source /path/to/bmad-observability-agent
```

## Verify Installation

### Check Skills Exist
```bash
# All 6 skills should be installed
ls .claude/skills/o11y-*
# Should show: o11y-setup, o11y-engineer, o11y-generate-epics,
#              o11y-instrument-app, o11y-redact-pii, o11y-write-ottl
```

### Test in AI Assistant

```
# Invoke the full agent with menu
/o11y-engineer

# Or run a specific skill directly
/o11y-write-ottl
/o11y-generate-epics
```

## Module Skills

| Skill | Menu Code | Description |
|-------|-----------|-------------|
| `o11y-setup` | SO | Install or reconfigure module settings |
| `o11y-engineer` | OA | Full agent with 28 menu items |
| `o11y-write-ottl` | WO | Generate OTTL expressions |
| `o11y-generate-epics` | GE | Create observability epics |
| `o11y-instrument-app` | IA | Add OpenTelemetry to apps |
| `o11y-redact-pii` | RP | Configure PII redaction |

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

```bash
# Re-run the installer to update to the latest version
npx bmad-method install --custom-source https://github.com/henrikrexed/bmad-observability-agent
```

The installer will update skills and re-run setup if the module configuration has changed.

## Uninstallation

Remove the installed skills:
```bash
rm -rf .claude/skills/o11y-*
```

Remove module configuration from `_bmad/config.yaml` (delete the `o11y` section).

## Troubleshooting

### Skills Not Loading

1. Check skills are installed:
```bash
ls .claude/skills/o11y-engineer/SKILL.md
```

2. Verify BMad Method is v6.3+:
```bash
npx bmad-method --version
```

### Module Config Missing

Run the setup skill to reconfigure:
```
/o11y-setup
```

### Workflows Not Found

The 18 workflow YAML files live inside the agent skill:
```bash
ls .claude/skills/o11y-engineer/assets/workflows/
```

## Next Steps

After installation:

1. **Invoke the agent** — Run `/o11y-engineer` to see the full menu
2. **Quick Start** — Select `QS` for new observability setup
3. **Assessment** — Select `AM` for existing setups
4. **Quality Check** — Select `QC` for scoring

See the [Home page](index.md) for full documentation.
