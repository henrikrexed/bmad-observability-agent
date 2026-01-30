# Phase 3: Collector Configuration

**Command:** `*configure-pipeline`

**Goal:** Design and configure the OpenTelemetry Collector pipeline with correct processor ordering, resource enrichment, PII cleanup, and exporter configuration.

## Collector Pipeline Design

The O11y Engineer guides you through a structured pipeline design process covering receivers, processors, and exporters.

## Sub-Steps

### 3a: Resource Detection

The agent determines the right resource detection strategy based on your deployment:

| Deployment Type | Processor | Purpose |
|----------------|-----------|---------|
| VM / Bare-metal | `resourcedetectionprocessor` | Detect host, OS, cloud metadata |
| Kubernetes | `k8sattributesprocessor` | Enrich with K8s metadata (pod, namespace, node) |
| Serverless | Neither | Resource attributes from environment variables |

!!! warning "Important"
    `resourcedetectionprocessor` is ONLY for VM/bare-metal deployments. Do NOT use it in Kubernetes -- use `k8sattributesprocessor` instead.

### 3b: Static Resources

The agent asks if additional static resource attributes are needed:

```yaml
processors:
  resource:
    attributes:
      - key: deployment.environment
        value: "production"
        action: upsert
      - key: service.version
        value: "1.2.3"
        action: upsert
```

### 3c: PII Cleanup

If the agent detects potential PII in logs or traces, it suggests transform processor rules using OTTL:

```yaml
processors:
  transform:
    log_statements:
      - context: log
        statements:
          # Redact email addresses
          - replace_pattern(body, "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b", "REDACTED_EMAIL")
          # Redact IP addresses
          - replace_pattern(body, "\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b", "REDACTED_IP")
          # Redact credit card numbers
          - replace_pattern(body, "\\b\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}\\b", "REDACTED_CC")
    trace_statements:
      - context: span
        statements:
          - replace_pattern(attributes["user.email"], ".*", "REDACTED")
```

All cleanup rules are documented in the project's observability documentation.

See [PII Cleanup](../features/pii-cleanup.md) for detailed guidance.

### 3d: Log Collection

The agent asks about log collection strategy:

| Receiver | Use Case |
|----------|----------|
| `filelog` | Container logs, application log files |
| `otlp` | SDK-instrumented structured logs |
| `journald` | systemd journal on Linux VMs |
| `windowseventlog` | Windows Event Log |

### 3e: Metric Conversion

The agent detects if the observability backend requires metric conversion:

```yaml
processors:
  cumulativetodelta:
    include:
      metrics:
        - "http.server.request.duration"
      match_type: strict
```

!!! note
    Dynatrace requires delta metrics. The `cumulativetodeltaprocessor` converts cumulative counters to delta format.

### 3f: Processor Ordering

**This is mandatory.** The OpenTelemetry project mandates this processor ordering:

```yaml
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors:
        - memory_limiter    # ALWAYS FIRST
        - k8sattributes     # or resourcedetection (VM only)
        - resource           # static attributes
        - transform          # PII cleanup
        - batch              # ALWAYS LAST
      exporters: [otlp/dynatrace]
```

| Position | Processor | Reason |
|----------|-----------|--------|
| First | `memory_limiter` | Prevents OOM by dropping data before processing |
| Middle | Resource enrichment | Adds metadata before filtering/transforming |
| Middle | `transform` | PII cleanup after enrichment |
| Last | `batch` | Batches data for efficient export |

### 3g: Attribute Ownership Documentation

The agent documents which attributes are set by the application vs the collector:

```yaml
attribute_ownership:
  app_managed:
    - http.route
    - http.method
    - db.system
    - db.operation
    - user.type  # custom business attribute
  collector_managed:
    - k8s.pod.name
    - k8s.namespace.name
    - k8s.deployment.name
    - k8s.node.name
    - deployment.environment
    - service.version
  redacted:
    - user.email  # -> REDACTED by transform processor
    - client.ip   # -> REDACTED_IP by transform processor
```

## Output

- Complete collector configuration YAML
- Documentation of processor ordering rationale
- PII cleanup rules documentation
- Attribute ownership map

## Next Step

After configuring the collector, proceed to [Phase 4: CI/CD with Weaver](phase-4-cicd.md) to automate semantic convention validation.
