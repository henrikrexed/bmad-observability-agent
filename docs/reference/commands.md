# All Commands

Complete reference of O11y Engineer commands organized by category.

## Observability Assessment

| Command | Description |
|---------|-------------|
| `*assess-observability` | Comprehensive maturity assessment (0-100 score) |
| `*check-quality` | Run quality checks with pass/fail per criterion |

## Observability Specs & Validation

| Command | Description |
|---------|-------------|
| `*generate-observability-spec` | Create use-case-driven observability specification |
| `*validate-traces` | Validate telemetry against spec using Dynatrace MCP |
| `*define-slos` | Define SLOs and generate test-consumable KPIs |

## Collector Configuration

| Command | Description |
|---------|-------------|
| `*configure-pipeline` | Design OTel Collector pipeline |
| `*build-collector-distro` | Build custom collector with OCB |
| `*diagnose-pipeline` | Troubleshoot collector issues |

## Instrumentation

| Command | Description |
|---------|-------------|
| `*adjust-instrumentation` | Configure or improve instrumentation |
| `*auto-instrumentation` | Set up K8s auto-instrumentation operator |
| `*score-instrumentation` | Score instrumentation quality (0-100) |

## Semantic Conventions

| Command | Description |
|---------|-------------|
| `*validate-semconv` | Validate against OpenTelemetry semantic conventions |
| `*create-custom-semconv` | Create custom conventions with Weaver |
| `*validate-observability` | Full observability setup validation |

## IDE Integration

| Command | Description |
|---------|-------------|
| `*configure-mcp-rules` | Generate IDE-specific MCP rule files with DQL |

## Dynatrace (dtctl)

| Command | Description |
|---------|-------------|
| `*setup-dynatrace` | Initial dtctl setup and configuration |
| `*create-dt-dashboard` | Create dashboard YAML for dtctl |
| `*create-dt-notebook` | Create notebook YAML for dtctl |
| `*create-dt-workflow` | Create workflow YAML for dtctl |
| `*configure-dt-alerting` | Configure SLOs, alerting, management zones |
| `*run-dt-query` | Execute DQL queries |
| `*export-dt-config` | Export Dynatrace configuration |
| `*validate-dt-config` | Validate configuration before deployment |
| `*dt-synthetic-monitoring` | Configure synthetic monitors |

## Dynatrace (MCP-Powered)

| Command | Description |
|---------|-------------|
| `*check-mcp` | Verify MCP server connection |
| `*discover-services` | Discover services via MCP |
| `*discover-metrics` | Discover available metrics via MCP |
| `*analyze-logs` | Analyze log patterns via MCP |
| `*build-project-dashboard` | Build dashboard from real metrics |
| `*build-diagnostic-notebook` | Build diagnostic notebook from real data |
| `*suggest-workflows` | Get AI-suggested automation workflows |

## Change Management

| Command | Description |
|---------|-------------|
| `*request-semconv-change` | Request semantic convention change |
| `*request-instrumentation-change` | Request instrumentation change |
| `*request-logging-change` | Request logging change |
| `*request-metrics-change` | Request metrics change |
| `*plan-observability-change` | Plan multi-area observability change |

## Cross-Agent (BMAD)

| Command | Description |
|---------|-------------|
| `*generate-handoff` | Generate handoff document for next agent |
| `*create-epic` | Create epic with stories |
| `*status-report` | Machine-readable status report |
| `*sync-status` | Sync from previous agent session |

## Utility

| Command | Description |
|---------|-------------|
| `*export-configuration` | Export complete observability config as IaC |
| `*vendor-check` | Check vendor compatibility |
| `*cardinality-check` | Analyze attribute cardinality |
| `*quick-start` | Full guided setup from scratch |
