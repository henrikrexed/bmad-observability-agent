# MCP Rules Generation

MCP rules embed Dynatrace DQL queries and observability context into IDE-specific configuration files, enabling AI assistants to provide context-aware monitoring from within the developer's editor.

## Supported IDEs

| IDE | Rule Location | Format |
|-----|--------------|--------|
| Claude Code | `.claude/commands/o11y/` | Markdown |
| Cursor | `.cursor/rules/` | `.mdc` |
| Windsurf | `.windsurfrules/` | Markdown |
| Copilot | `.github/copilot-instructions.md` | Markdown |
| Amazon Q | `.amazonq/rules/` | Markdown |

## What Gets Generated

For each discovered service, the agent generates DQL queries covering:

- **Health overview** -- Request count, error count, avg/p95 latency
- **Error analysis** -- Recent errors with trace IDs for correlation
- **Log correlation** -- Error logs filtered by service and namespace
- **Latency breakdown** -- Percentile distribution by route

## How It Works

1. **Scan project** -- Discover services from package files, Dockerfiles, K8s manifests
2. **Collect context** -- Ask for cluster name, namespace, environment URL
3. **Generate DQL** -- Create service-specific queries with actual names
4. **Write rules** -- Place files in the correct IDE location
5. **Document** -- Create manifest at `observability-specs/mcp-rules-manifest.yaml`

## Prerequisites

For live query execution, configure the [Dynatrace MCP server](https://github.com/dynatrace-oss/dynatrace-mcp) in your AI assistant. See [Dynatrace Setup](dynatrace-setup.md).

Without MCP, the rules serve as reference documentation with pre-built DQL queries.

## Regeneration

Regenerate rules when:

- New services are added
- Services are renamed
- Namespace or cluster changes
- DQL queries need updating

Run `*configure-mcp-rules` to regenerate.
