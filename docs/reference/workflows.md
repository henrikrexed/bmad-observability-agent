# Workflows

The O11y Engineer provides workflows that can be invoked through the B-MAD framework. These are the structured, multi-step processes available.

## Available Workflows

### observability-quick-start

Interactive guide to set up comprehensive observability from scratch.

**Trigger:** `*quick-start`

**Steps:**

1. Assess current state
2. Design observability architecture
3. Instrument applications
4. Configure collector
5. Set up dashboards and alerts
6. Define SLOs

### assess-observability-maturity

Assess current observability maturity and get improvement roadmap.

**Trigger:** `*assess-observability`

**Output:** Maturity score (0-100), gap analysis, prioritized roadmap

### configure-collector-pipeline

Design and configure OpenTelemetry Collector pipeline.

**Trigger:** `*configure-pipeline`

**Output:** Complete collector YAML with correct processor ordering

### build-collector-distro

Build custom OpenTelemetry Collector distribution using OCB.

**Trigger:** `*build-collector-distro`

**Output:** OCB manifest, Dockerfile, deployment configs

### validate-semantic-conventions

Validate telemetry data against OpenTelemetry semantic conventions using Weaver.

**Trigger:** `*validate-semconv`

**Output:** Compliance report, Weaver configuration

### create-custom-semconv

Create custom semantic conventions using Weaver schema format.

**Trigger:** `*create-custom-semconv`

**Output:** Weaver schema files, generated code

### validate-observability

Validate observability setup against vendor requirements and best practices.

**Trigger:** `*validate-observability`

**Output:** Validation report with pass/fail per check

### setup-dynatrace

Set up Dynatrace integration with OpenTelemetry.

**Trigger:** `*setup-dynatrace`

**Output:** dtctl context configuration, token setup

### create-dynatrace-dashboard

Create Dynatrace dashboards for observability metrics.

**Trigger:** `*create-dt-dashboard`

**Output:** Dashboard YAML file for dtctl

### create-dynatrace-workflow

Create Dynatrace automation workflows.

**Trigger:** `*create-dt-workflow`

**Output:** Workflow YAML file for dtctl

### build-project-dashboard

Build project-specific observability dashboards using MCP discovery.

**Trigger:** `*build-project-dashboard`

**Output:** Dashboard based on actual environment metrics

### build-diagnostic-notebook

Build Dynatrace diagnostic notebooks for troubleshooting.

**Trigger:** `*build-diagnostic-notebook`

**Output:** Notebook with service-specific investigation queries

### suggest-dynatrace-workflows

Get AI-powered suggestions for Dynatrace automation workflows.

**Trigger:** `*suggest-workflows`

**Output:** Top 5 recommended automation workflows

## Workflow Invocation

### Claude Code

```bash
# Via slash commands
/bmad:o11y:workflows:observability-quick-start
/bmad:o11y:workflows:assess-observability-maturity
/bmad:o11y:workflows:configure-collector-pipeline

# Via agent triggers
*quick-start
*assess-observability
*configure-pipeline
```

### Other AI Assistants

```
# Via agent triggers
*quick-start
*assess-observability
*configure-pipeline
```

## Recommended Order

For new projects, follow the [8-Phase Workflow](../workflow/recommended-workflow.md):

1. `*assess-observability`
2. `*generate-observability-spec`
3. `*configure-pipeline`
4. `*validate-semconv`
5. `*define-slos`
6. `*configure-mcp-rules`
7. Sprint planning handoff
8. `*validate-traces`
