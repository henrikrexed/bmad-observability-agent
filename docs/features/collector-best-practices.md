# Collector Best Practices

The O11y Engineer enforces OpenTelemetry Collector best practices for production-grade pipelines.

## Processor Ordering

The OpenTelemetry project mandates this ordering:

```yaml
processors:
  - memory_limiter    # ALWAYS FIRST
  - k8sattributes     # Resource enrichment (K8s only)
  - resource           # Static attributes
  - transform          # PII cleanup, OTTL transformations
  - batch              # ALWAYS LAST
```

| Position | Processor | Reason |
|----------|-----------|--------|
| First | `memory_limiter` | Prevents OOM by applying backpressure before any processing |
| Middle | Resource enrichment | Adds metadata needed by downstream processors |
| Middle | `transform` | PII cleanup must happen after enrichment |
| Last | `batch` | Aggregates data for efficient network export |

!!! danger "Never Violate Ordering"
    `memory_limiter` must ALWAYS be first. `batch` must ALWAYS be last. This is an OpenTelemetry project mandate, not a suggestion.

## Resource Detection

Choose the right processor for your deployment:

| Deployment | Processor | What It Detects |
|-----------|-----------|-----------------|
| VM / Bare-metal | `resourcedetectionprocessor` | Host, OS, cloud provider metadata |
| Kubernetes | `k8sattributesprocessor` | Pod, namespace, node, deployment |
| Serverless | Neither | Use environment variables |

!!! warning
    Do NOT use `resourcedetectionprocessor` in Kubernetes. Use `k8sattributesprocessor` instead. Using both creates conflicts and duplicate attributes.

## Memory Limiter Configuration

```yaml
processors:
  memory_limiter:
    check_interval: 1s
    limit_mib: 512        # Hard limit
    spike_limit_mib: 128  # Spike allowance
```

- Set `limit_mib` to ~80% of the container memory limit
- `spike_limit_mib` handles temporary bursts
- `check_interval` of 1s provides responsive backpressure

## Batch Processor Configuration

```yaml
processors:
  batch:
    send_batch_size: 8192
    timeout: 200ms
    send_batch_max_size: 0  # No max (use send_batch_size)
```

- `timeout` controls maximum wait time before sending
- `send_batch_size` controls batch size for efficient export
- Lower timeout = lower latency, higher overhead

## High Availability

For production:

- Deploy 3+ collector replicas
- Use a load balancer in front of the collector
- Consider gateway pattern for cross-cluster telemetry
- Monitor collector health metrics

## Metric Conversion

Dynatrace requires delta metrics:

```yaml
processors:
  cumulativetodelta:
    include:
      metrics:
        - "http.server.request.duration"
      match_type: strict
```

## PII Cleanup

Use the transform processor with OTTL for PII redaction:

```yaml
processors:
  transform:
    log_statements:
      - context: log
        statements:
          - replace_pattern(body, "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b", "REDACTED_EMAIL")
```

See [PII Cleanup](pii-cleanup.md) for comprehensive guidance.

## Exporter Configuration

### Dynatrace (OTLP)

```yaml
exporters:
  otlp/dynatrace:
    endpoint: "https://{environment-id}.live.dynatrace.com/api/v2/otlp"
    headers:
      Authorization: "Api-Token ${DT_API_TOKEN}"
```

### Multi-Backend Fan-Out

```yaml
service:
  pipelines:
    traces:
      exporters: [otlp/dynatrace, otlp/backup]
    metrics:
      exporters: [otlp/dynatrace, prometheus]
```

## Collector Deployment Patterns

| Pattern | Use Case | Pros | Cons |
|---------|----------|------|------|
| DaemonSet | Per-node collection | Low overhead, simple | One per node |
| Deployment | Gateway | Centralized, scalable | Network hop |
| Sidecar | Per-pod | Isolation, per-app config | Resource overhead |
