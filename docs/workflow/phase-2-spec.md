# Phase 2: Observability Spec

**Command:** `*generate-observability-spec`

**Goal:** Define use-case-driven observability specifications that serve as contracts between development and operations teams.

## What Is an Observability Spec?

An observability spec answers the question: **"What telemetry should this service produce, and why?"**

It is structured around **use cases** -- questions that telemetry data should be able to answer. Each use case drives the definition of trace, log, and metric contracts.

## Spec Structure

```yaml
metadata:
  service: "registration-service"
  version: "1.0"
  created_by: "o11y-engineer"

use_cases:
  - id: uc-001
    question: "What is the p95 latency for user registration?"
    signal: traces
    slo_boundary: "p95 < 500ms"
    priority: critical

trace_contracts:
  # Expected spans and attributes

log_contracts:
  # Structured log requirements

metric_contracts:
  # Expected metrics and dimensions

correlation_contracts:
  # How signals link together

attribute_ownership:
  app_managed: [...]        # Set in application code
  collector_managed: [...]  # Set by collector pipeline
  redacted: [...]           # PII cleaned by transform processor
```

## Key Concepts

### Use-Case-Driven Design

Every trace, log, and metric contract traces back to a use case. If a piece of telemetry doesn't answer a question, it shouldn't exist.

### Attribute Ownership

Attributes are categorized into three ownership types:

| Type | Who Sets It | Examples |
|------|------------|---------|
| `app_managed` | Application code | `http.route`, `user.type`, custom business attributes |
| `collector_managed` | OTel Collector pipeline | `k8s.pod.name`, `deployment.environment` |
| `redacted` | Transform processor | `user.email` -> REDACTED |

This prevents developers from setting attributes that the collector will set (creating duplicates) and ensures PII is handled consistently.

### Boundary Types

Spans are categorized by boundary type:

- **Internal** -- Between services within the same system
- **Cross-cluster** -- Between services in different clusters
- **External** -- Between your service and external APIs

## Output

The spec is saved to `observability-specs/{service}-spec.yaml`.

A **companion epic** with instrumentation stories is generated at `_bmad-output/epics/`. Each story includes:

- `spec_reference` -- Points to the relevant spec section
- `test_criteria` -- Testable assertions for validation

## Next Step

After defining specs, proceed to [Phase 3: Collector Configuration](phase-3-collector.md) to build the collector pipeline that supports the spec requirements.
