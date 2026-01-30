# Dynatrace Setup

Guide for configuring dtctl and the Dynatrace MCP server for use with the O11y Engineer.

## dtctl Setup

[dtctl](https://github.com/dynatrace-oss/dtctl) is a kubectl-style CLI for managing Dynatrace configuration as code.

### Installation

```bash
# Install via npm
npm install -g @dynatrace-oss/dtctl

# Or via brew
brew install dynatrace-oss/tap/dtctl
```

### Configure a Context

```bash
# Set up a Dynatrace environment context
dtctl config set-context production \
  --url "https://abc12345.live.dynatrace.com" \
  --token "dt0s16.YOUR_API_TOKEN"

# Switch to the context
dtctl config use-context production

# Verify connection
dtctl get dashboards
```

### Required Token Permissions

| Scope | Purpose |
|-------|---------|
| `ReadConfig` | Read dashboards, settings |
| `WriteConfig` | Create/update dashboards, settings |
| `entities.read` | Read entity data |
| `metrics.read` | Read metrics |
| `logs.read` | Read log data |
| `openpipeline.events` | Read events |
| `automation.workflows.read` | Read workflows |
| `automation.workflows.write` | Create workflows |
| `slo.read` | Read SLOs |
| `slo.write` | Create SLOs |
| `syntheticMonitoring.read` | Read synthetic monitors |
| `syntheticMonitoring.write` | Create synthetic monitors |

### Project Structure

```
project/
  dynatrace/
    dashboards/
      service-overview.yaml
    notebooks/
      incident-analysis.yaml
    workflows/
      auto-remediation.yaml
    slos/
      service-slos.yaml
```

### Deploy

```bash
# Validate
dtctl apply -f dynatrace/ --dry-run

# Deploy all
dtctl apply -f dynatrace/

# Deploy specific
dtctl apply -f dynatrace/dashboards/service-overview.yaml
```

---

## Dynatrace MCP Server Setup

The [Dynatrace MCP server](https://github.com/dynatrace-oss/dynatrace-mcp) enables AI-driven discovery and context-aware DQL generation.

### Configuration

Add to your AI assistant's MCP configuration:

=== "Claude Code"

    Add to `~/.claude/settings.json` or project `.claude/settings.json`:

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

=== "Cursor"

    Add to `.cursor/settings.json`:

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

=== "Windsurf"

    Add to `.windsurfrules/mcp.json`:

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

### Verify MCP Connection

After configuring, restart your AI assistant and run:

```
*check-mcp
```

If MCP is available, you'll see:

```
Dynatrace MCP server is configured and connected.
Available capabilities:
- Execute DQL queries
- Discover services and entities
- Analyze logs, metrics, and traces
- Create dashboards and notebooks
```

### MCP-Powered Commands

| Command | Purpose |
|---------|---------|
| `*discover-services` | Find services in Dynatrace |
| `*discover-metrics` | Find available metrics |
| `*analyze-logs` | Analyze log patterns |
| `*build-project-dashboard` | Build dashboard from real metrics |
| `*build-diagnostic-notebook` | Build troubleshooting notebook |
| `*suggest-workflows` | Get AI-suggested automations |

### Required Token Scopes for MCP

| Scope | Purpose |
|-------|---------|
| `storage:logs:read` | Query logs |
| `storage:spans:read` | Query spans |
| `storage:metrics:read` | Query metrics |
| `storage:entities:read` | Discover entities |
| `storage:events:read` | Query events |
| `automation:workflows:read` | Read workflows |

---

## Using the O11y Engineer Command

Run `*setup-dynatrace` to get an interactive guide through the complete setup process:

```
*setup-dynatrace
```

This covers:

1. dtctl installation and context configuration
2. Token creation with correct scopes
3. MCP server configuration for your IDE
4. Connection verification
5. First dashboard or notebook creation
