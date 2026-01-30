# PII Cleanup

The O11y Engineer detects potential PII (Personally Identifiable Information) in telemetry data and suggests cleanup rules using the OpenTelemetry Collector transform processor with OTTL (OpenTelemetry Transformation Language).

## Why PII Cleanup Matters

Telemetry data often contains sensitive information:

- Email addresses in log messages
- IP addresses in span attributes
- Credit card numbers in request bodies
- User names in trace attributes
- Phone numbers in structured logs

Sending PII to observability backends creates compliance risks (GDPR, CCPA, HIPAA).

## Transform Processor Configuration

### Log Cleanup

```yaml
processors:
  transform:
    log_statements:
      - context: log
        statements:
          # Redact email addresses
          - replace_pattern(body, "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b", "REDACTED_EMAIL")

          # Redact IPv4 addresses
          - replace_pattern(body, "\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b", "REDACTED_IP")

          # Redact credit card numbers (with spaces or dashes)
          - replace_pattern(body, "\\b\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}\\b", "REDACTED_CC")

          # Redact phone numbers (various formats)
          - replace_pattern(body, "\\b\\+?\\d{1,3}[- ]?\\(?\\d{3}\\)?[- ]?\\d{3}[- ]?\\d{4}\\b", "REDACTED_PHONE")

          # Redact SSN
          - replace_pattern(body, "\\b\\d{3}-\\d{2}-\\d{4}\\b", "REDACTED_SSN")
```

### Trace Cleanup

```yaml
processors:
  transform:
    trace_statements:
      - context: span
        statements:
          # Redact email attributes
          - replace_pattern(attributes["user.email"], ".*", "REDACTED")

          # Redact IP from client address
          - replace_pattern(attributes["client.address"], "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}", "REDACTED_IP")

          # Remove sensitive query parameters from URLs
          - replace_pattern(attributes["url.full"], "password=[^&]*", "password=REDACTED")
          - replace_pattern(attributes["url.full"], "token=[^&]*", "token=REDACTED")
          - replace_pattern(attributes["url.full"], "api_key=[^&]*", "api_key=REDACTED")
```

## Pipeline Placement

PII cleanup MUST happen in the correct position:

```yaml
service:
  pipelines:
    traces:
      processors:
        - memory_limiter    # First
        - k8sattributes     # Resource enrichment
        - resource           # Static attributes
        - transform          # PII cleanup HERE (after enrichment)
        - batch              # Last
```

The transform processor must come AFTER resource enrichment (so all attributes are present for cleanup) and BEFORE batch (so PII is removed before export).

## Documentation Requirements

All cleanup rules MUST be documented. The O11y Engineer creates documentation including:

### Cleanup Rules Manifest

```yaml
# observability-specs/pii-cleanup-rules.yaml
rules:
  - id: pii-001
    type: log_body
    pattern: "email addresses"
    action: "replace_pattern -> REDACTED_EMAIL"
    reason: "GDPR compliance"
    added_date: "2026-01-30"

  - id: pii-002
    type: span_attribute
    attribute: "user.email"
    action: "replace_pattern -> REDACTED"
    reason: "PII in trace attributes"
    added_date: "2026-01-30"
```

### Attribute Ownership

PII-related attributes appear in the `redacted` section of attribute ownership:

```yaml
attribute_ownership:
  redacted:
    - user.email      # -> REDACTED by transform processor
    - client.address   # -> REDACTED_IP by transform processor
    - user.phone       # -> REDACTED_PHONE by transform processor
```

## Detection

The O11y Engineer scans for potential PII by:

1. Analyzing code for user-facing attributes (email, phone, address fields)
2. Scanning log format strings for PII patterns
3. Reviewing span attribute definitions
4. Checking database query patterns

When PII risk is detected, the agent suggests cleanup rules and explains the compliance implications.

## Testing PII Cleanup

After implementing cleanup rules, validate they work:

```dql
-- Check no emails leak through
fetch logs
| filter matchesPhrase(body, "@")
| filter NOT matchesPhrase(body, "REDACTED")
| limit 10

-- Check span attributes are redacted
fetch spans
| filter isNotNull(user.email)
| filter user.email != "REDACTED"
| limit 10
```
