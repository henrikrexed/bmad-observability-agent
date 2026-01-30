# Observability Specs

Observability specs are use-case-driven documents that define what telemetry a service should produce. They serve as contracts between development and operations.

## Structure

An observability spec contains:

- **Use cases** -- Questions telemetry should answer
- **Trace contracts** -- Expected spans and attributes
- **Log contracts** -- Structured log requirements
- **Metric contracts** -- Expected metrics and dimensions
- **Correlation contracts** -- How signals link together
- **Attribute ownership** -- Who sets which attributes

## Use Cases

Every contract traces back to a use case:

```yaml
use_cases:
  - id: uc-001
    question: "What is the p95 latency for user registration?"
    signal: traces
    answer_method: "Filter spans by service + operation, compute p95"
    slo_boundary: "p95 < 500ms"
    priority: critical
```

## Attribute Ownership

| Type | Set By | Examples |
|------|--------|---------|
| `app_managed` | Application code | `http.route`, `user.type` |
| `collector_managed` | OTel Collector | `k8s.pod.name`, `deployment.environment` |
| `redacted` | Transform processor | `user.email` -> REDACTED |

This separation prevents:

- Developers setting attributes the collector already sets (duplicates)
- PII leaking because no one handles redaction
- Confusion about who is responsible for what

## Generating a Spec

Run `*generate-observability-spec` to start the guided process:

1. Identify services
2. Define use cases per service
3. Define trace contracts
4. Define log contracts
5. Define metric contracts
6. Define correlation contracts
7. Generate companion epic with stories
8. Save spec to `observability-specs/{service}-spec.yaml`

## Companion Epic

When a spec is generated, a companion epic with instrumentation stories is created at `_bmad-output/epics/`. Each story includes:

- `spec_reference` -- Points to the relevant spec section
- `test_criteria` -- DQL query that should pass after implementation

## Validating Against Specs

After implementation, run `*validate-traces` to compare actual telemetry against the spec. See [Trace Validation](trace-validation.md).
