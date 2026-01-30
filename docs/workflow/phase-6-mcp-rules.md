# Phase 6: MCP Rules

**Command:** `*configure-mcp-rules`

**Goal:** Generate IDE-specific rule files that embed Dynatrace DQL queries and observability context directly into the developer's AI assistant.

## What Are MCP Rules?

MCP (Model Context Protocol) rules are configuration files that provide AI assistants with project-specific observability context. They embed DQL queries, service mappings, and debugging instructions so that developers can query telemetry directly from their IDE.

## Supported IDEs

| IDE | Rule File Location | Format |
|-----|-------------------|--------|
| Claude Code | `.claude/commands/o11y/` | Markdown |
| Cursor | `.cursor/rules/` | `.mdc` |
| Windsurf | `.windsurfrules/` | Markdown |
| Copilot | `.github/copilot-instructions.md` | Markdown |
| Amazon Q | `.amazonq/rules/` | Markdown |

## Workflow

### Step 1: Detect IDE

The agent asks which IDE you use and configures the output format accordingly.

### Step 2: Scan Project

The agent scans your project to discover:

- Service names (from package files, Dockerfiles)
- Framework types (Express, Spring Boot, Gin, etc.)
- Kubernetes manifests (deployments, namespaces)
- Helm chart values
- Existing OpenTelemetry SDK usage

### Step 3: Collect Context

You provide:

- Kubernetes cluster name (if applicable)
- Namespace where services run
- Dynatrace environment URL

### Step 4: Generate DQL Queries

For each discovered service, the agent generates:

- **Health overview** -- Request count, error count, avg/p95 latency
- **Error analysis** -- Recent errors with trace IDs
- **Log correlation** -- Error logs with trace context
- **Latency breakdown** -- Percentiles by route/operation

### Step 5: Write Rule Files

Rule files are written to the IDE-specific location in your project directory.

### Step 6: Document

A manifest of generated rules is saved at `observability-specs/mcp-rules-manifest.yaml`.

## Prerequisites

MCP rules work best with the [Dynatrace MCP server](https://github.com/dynatrace-oss/dynatrace-mcp) configured in your AI assistant. See [Dynatrace Setup](../features/dynatrace-setup.md) for configuration instructions.

## Next Step

After generating MCP rules, proceed to [Phase 7: Implementation](phase-7-implementation.md) to hand off to the B-MAD agent ecosystem.
