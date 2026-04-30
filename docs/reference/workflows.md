# Workflows

The O11y Engineer provides 18 workflows accessible through the agent menu (`/o11y-engineer`). Workflows are structured, multi-step processes that guide you through complex observability tasks.

## Available Workflows

### observability-quick-start

Interactive guide to set up comprehensive observability from scratch.

**Menu Code:** `QS`

**Steps:**

1. Assess current state
2. Design observability architecture
3. Instrument applications
4. Configure collector
5. Set up dashboards and alerts
6. Define SLOs

### assess-observability-maturity

Assess current observability maturity and get improvement roadmap.

**Menu Code:** `AM`

**Output:** Maturity score (0-100), gap analysis, prioritized roadmap

### configure-collector-pipeline

Design and configure OpenTelemetry Collector pipeline.

**Menu Code:** `CP`

**Output:** Complete collector YAML with correct processor ordering

### build-collector-distro

Build custom OpenTelemetry Collector distribution using OCB.

**Menu Code:** `BC`

**Output:** OCB manifest, Dockerfile, deployment configs

### validate-semantic-conventions

Validate telemetry data against OpenTelemetry semantic conventions using Weaver.

**Menu Code:** `VS`

**Output:** Compliance report, Weaver configuration

### create-custom-semconv

Create custom semantic conventions using Weaver schema format.

**Menu Code:** `CS`

**Output:** Weaver schema files, generated code

### validate-observability

Validate observability setup against vendor requirements and best practices.

**Menu Code:** `VO`

**Output:** Validation report with pass/fail per check

### configure-ottl

Interactive OTTL transform processor configuration.

**Menu Code:** `OT`

**Output:** Complete transform processor YAML with OTTL statements

### configure-pii-redaction

Comprehensive PII/sensitive data protection workflow.

**Menu Code:** `PR`

**Output:** PII redaction processor configuration, compliance validation

### instrument-application

Add OpenTelemetry instrumentation to applications across languages.

**Menu Code:** `IA` (via skill)

**Output:** Per-language instrumentation configuration

### generate-observability-epics

Generate complete observability epics for sprint planning.

**Menu Code:** `GE` (via skill)

**Output:** Epic YAML, sprint plan, test contract

### observability-change-management

Manage changes to semantic conventions, instrumentation, logging, metrics.

**Menu Code:** `CM`

**Output:** Impact analysis, change checklist, PRD update request

### setup-dynatrace

Set up Dynatrace integration with OpenTelemetry.

**Menu Code:** `SD`

**Output:** dtctl context configuration, token setup

### create-dynatrace-dashboard

Create Dynatrace dashboards for observability metrics.

**Menu Code:** `CD`

**Output:** Dashboard YAML file for dtctl

### create-dynatrace-workflow

Create Dynatrace automation workflows.

**Menu Code:** `CW`

**Output:** Workflow YAML file for dtctl

### build-project-dashboard

Build project-specific observability dashboards using MCP discovery.

**Menu Code:** `PD`

**Output:** Dashboard based on actual environment metrics

### build-diagnostic-notebook

Build Dynatrace diagnostic notebooks for troubleshooting.

**Menu Code:** `DB`

**Output:** Notebook with service-specific investigation queries

### suggest-dynatrace-workflows

Get AI-powered suggestions for Dynatrace automation workflows.

**Menu Code:** `SW`

**Output:** Top 5 recommended automation workflows

## Workflow Invocation

All workflows are accessed through the O11y Engineer agent:

```
# Invoke the agent
/o11y-engineer

# Then select a workflow by code or number
QS    # Quick Start
AM    # Assess Maturity
CP    # Configure Pipeline
```

Or invoke specific skills directly:

```
/o11y-write-ottl        # OTTL expressions
/o11y-generate-epics    # Epic generation
/o11y-instrument-app    # App instrumentation
/o11y-redact-pii        # PII redaction
```

## Recommended Order

For new projects, follow the [8-Phase Workflow](../workflow/recommended-workflow.md):

1. `AM` — Assess observability maturity
2. Design observability spec
3. `CP` — Configure collector pipeline
4. `VS` — Validate semantic conventions
5. Define SLOs
6. Configure MCP rules
7. Sprint planning handoff (`GE`)
8. `VO` — Validate observability setup
