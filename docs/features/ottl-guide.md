# OpenTelemetry Transformation Language (OTTL) Guide

The OpenTelemetry Transformation Language (OTTL) is a powerful language for transforming, filtering, and enriching telemetry data inside the OpenTelemetry Collector. This guide covers everything you need to know to write effective OTTL expressions for production observability.

## Overview

OTTL allows you to manipulate telemetry data without changing application code. You can:

- **Transform** data by setting attributes, renaming fields, or converting values
- **Filter** data by dropping unwanted telemetry based on conditions
- **Enrich** data by adding metadata from external sources
- **Redact** sensitive information to ensure compliance
- **Route** data to different backends based on content

## Where OTTL is Used

OTTL expressions can be used in multiple OpenTelemetry Collector components:

### Processors
- **transform**: Modify, enrich, or redact telemetry data
- **filter**: Drop telemetry entirely based on conditions
- **attributes**: Manage resource and record attributes
- **tailsampling**: Sample traces based on OTTL conditions
- **span**: Rename spans and set status based on attributes

### Connectors
- **routing**: Route telemetry to different pipelines
- **count**: Count signals matching conditions and emit as metrics
- **signaltometrics**: Generate metrics from spans or logs

### Receivers
- **hostmetrics**: Filter host metrics at collection time

## OTTL Syntax Fundamentals

### Path Expressions

Navigate telemetry data using dot notation:

```ottl
span.name
span.attributes["http.method"]
resource.attributes["service.name"]
log.body["message"]
metric.name
```

### Contexts

The first segment in a path expression defines the context:

| Context | Description | Use With |
|---------|-------------|----------|
| `resource` | Resource-level attributes | All signal types |
| `scope` | Instrumentation scope | All signal types |
| `span` | Span data | Traces |
| `spanevent` | Span events | Traces |
| `metric` | Metric metadata | Metrics |
| `datapoint` | Metric data points | Metrics |
| `log` | Log records | Logs |

### Operators

| Category | Operators | Example |
|----------|-----------|---------|
| Assignment | `=` | `set(span.attributes["env"], "prod")` |
| Comparison | `==`, `!=`, `>`, `<`, `>=`, `<=` | `span.status.code == STATUS_CODE_ERROR` |
| Logical | `and`, `or`, `not` | `IsMatch(metric.name, "^http") and resource.attributes["env"] == "prod"` |

### Conditional Statements

Use `where` clauses to apply transformations conditionally:

```ottl
set(span.attributes["region"], "us-east-1") where resource.attributes["cloud.provider"] == "aws"
```

### Nil Checks

Always check for `nil` to avoid creating attributes that don't exist:

```ottl
span.attributes["user.id"] != nil
```

## OTTL Functions

### Editors (lowercase functions that modify data)

| Function | Purpose | Example |
|----------|---------|---------|
| `set` | Set a field to a value | `set(span.attributes["env"], "production")` |
| `delete_key` | Remove a key from a map | `delete_key(span.attributes, "internal.key")` |
| `delete_matching_keys` | Remove keys matching a pattern | `delete_matching_keys(span.attributes, "^temp\\.")` |
| `replace_pattern` | Replace text matching regex | `replace_pattern(log.body["string"], "\\d{4}-\\d{4}-\\d{4}-\\d{4}", "****-****-****-****")` |
| `merge_maps` | Merge two maps | `merge_maps(span.attributes, resource.attributes, "upsert")` |
| `flatten` | Flatten nested structures | `flatten(span.attributes, "nested.", 2)` |
| `limit` | Limit map size | `limit(span.attributes, 50, ["user.id", "trace.id"])` |
| `truncate_all` | Truncate string values | `truncate_all(span.attributes, 1024)` |

### Converters (uppercase functions that return values)

#### Type Checking
| Function | Purpose | Example |
|----------|---------|---------|
| `IsString` | Check if value is string | `IsString(span.attributes["user.id"])` |
| `IsInt` | Check if value is integer | `IsInt(span.attributes["http.status_code"])` |
| `IsMap` | Check if value is map | `IsMap(span.attributes["metadata"])` |
| `IsMatch` | Check if string matches regex | `IsMatch(metric.name, "^k8s\\.")` |

#### Type Conversion
| Function | Purpose | Example |
|----------|---------|---------|
| `String` | Convert to string | `String(span.attributes["http.status_code"])` |
| `Int` | Convert to integer | `Int(span.attributes["duration_ms"])` |
| `Double` | Convert to float | `Double(span.attributes["cpu_usage"])` |
| `Bool` | Convert to boolean | `Bool(span.attributes["is_error"])` |

#### String Manipulation
| Function | Purpose | Example |
|----------|---------|---------|
| `Concat` | Join strings | `Concat([resource.attributes["service.name"], span.name], ".")` |
| `Substring` | Extract substring | `Substring(log.body["string"], 0, 100)` |
| `ToLowerCase` | Convert to lowercase | `ToLowerCase(span.attributes["http.method"])` |
| `Split` | Split string into array | `Split(span.attributes["tags"], ",")` |
| `Trim` | Remove whitespace | `Trim(log.body["message"])` |

#### Parsing and Extraction
| Function | Purpose | Example |
|----------|---------|---------|
| `ParseJSON` | Parse JSON string | `ParseJSON(log.body["json_data"])` |
| `ExtractPatterns` | Extract regex groups | `ExtractPatterns(log.body["string"], "user=(?P<user>\\w+)")` |
| `ParseKeyValue` | Parse key-value pairs | `ParseKeyValue(log.body["kv_data"], "=", " ")` |

#### Hashing
| Function | Purpose | Example |
|----------|---------|---------|
| `SHA256` | SHA256 hash | `SHA256(span.attributes["user.email"])` |
| `MD5` | MD5 hash | `MD5(span.attributes["session.id"])` |

#### Time and Date
| Function | Purpose | Example |
|----------|---------|---------|
| `Now` | Current time | `Now()` |
| `UnixNano` | Convert to nanoseconds | `UnixNano(Now())` |
| `FormatTime` | Format time string | `FormatTime(log.time, "2006-01-02")` |

## Common OTTL Patterns

### Setting Attributes

```ottl
# Set static value
set(resource.attributes["deployment.environment"], "production")

# Set based on condition
set(span.status.code, STATUS_CODE_ERROR) where span.attributes["http.status_code"] >= 500

# Copy from another field
set(span.attributes["region"], resource.attributes["cloud.region"])
```

### Redacting Sensitive Data

```ottl
# Redact authorization headers
set(span.attributes["http.request.header.authorization"], "REDACTED") where span.attributes["http.request.header.authorization"] != nil

# Mask credit card numbers
replace_pattern(log.body["string"], "\\b(\\d{4})\\d{8,12}(\\d{4})\\b", "$1****$2")

# Hash email addresses
set(span.attributes["user.email"], SHA256(span.attributes["user.email"])) where span.attributes["user.email"] != nil
```

### Kubernetes Enrichment

```ottl
# Add cluster information
set(resource.attributes["k8s.cluster.name"], "prod-cluster-us-west-2")

# Extract namespace from pod name
set(resource.attributes["k8s.namespace.name"], Split(resource.attributes["k8s.pod.name"], "-")[0])

# Set environment based on namespace
set(resource.attributes["deployment.environment"], "production") where IsMatch(resource.attributes["k8s.namespace.name"], "^prod-")
set(resource.attributes["deployment.environment"], "staging") where IsMatch(resource.attributes["k8s.namespace.name"], "^staging-")
```

### Cardinality Control

```ottl
# Limit attribute count to prevent cardinality explosion
limit(span.attributes, 20, ["service.name", "http.method", "http.status_code"])

# Delete high-cardinality attributes
delete_matching_keys(span.attributes, "^user\\.(id|email)")

# Truncate long strings
truncate_all(span.attributes, 256)
```

### Routing Based on Content

```ottl
# Route errors to separate pipeline
span.status.code == STATUS_CODE_ERROR

# Route specific services
resource.attributes["service.name"] == "critical-service"

# Route by metric name pattern
IsMatch(metric.name, "^system\\.")
```

## Advanced Patterns

### The Temp Map Pattern

For complex parsing operations, use a temporary map to store intermediate results:

```ottl
# Parse complex log message into temp map
set(cache["parsed"], ParseJSON(log.body["string"]))

# Extract specific fields
set(span.attributes["user.id"], cache["parsed"]["userId"])
set(span.attributes["request.id"], cache["parsed"]["requestId"])

# Clean up temp map
delete_key(cache, "parsed")
```

### Multi-Step Transformations

```ottl
# Step 1: Parse URL
set(cache["url"], URL(span.attributes["http.url"]))

# Step 2: Extract host and path
set(span.attributes["http.host"], cache["url"]["host"])
set(span.attributes["http.route"], cache["url"]["path"])

# Step 3: Clean query parameters
set(span.attributes["http.url"], Concat([cache["url"]["scheme"], "://", cache["url"]["host"], cache["url"]["path"]], ""))

# Step 4: Clean up
delete_key(cache, "url")
```

### Error Handling

```ottl
# Safe parsing with error handling
set(span.attributes["parsed_data"], ParseJSON(span.attributes["json_string"])) where IsString(span.attributes["json_string"])

# Defensive attribute access
set(span.attributes["method"], span.attributes["http.request.method"]) where span.attributes["http.request.method"] != nil
```

## Real-World Use Cases

### 1. PII Redaction

```yaml
processors:
  transform/redact-pii:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          # Redact authorization headers
          - set(span.attributes["http.request.header.authorization"], "REDACTED") where span.attributes["http.request.header.authorization"] != nil
          - set(span.attributes["http.request.header.cookie"], "REDACTED") where span.attributes["http.request.header.cookie"] != nil
          # Hash user identifiers
          - set(span.attributes["user.email"], SHA256(span.attributes["user.email"])) where span.attributes["user.email"] != nil
    log_statements:
      - context: log
        statements:
          # Mask credit card numbers in log bodies
          - replace_pattern(log.body["string"], "\\b(\\d{4})[\\d\\s-]{8,12}(\\d{4})\\b", "$1-****-****-$2")
          # Remove social security numbers
          - replace_pattern(log.body["string"], "\\b\\d{3}-\\d{2}-\\d{4}\\b", "***-**-****")
```

### 2. Kubernetes Enrichment

```yaml
processors:
  transform/k8s-enrichment:
    error_mode: ignore
    trace_statements:
      - context: resource
        statements:
          # Add cluster information
          - set(resource.attributes["k8s.cluster.name"], "prod-us-west-2")
          # Set environment based on namespace
          - set(resource.attributes["deployment.environment"], "production") where IsMatch(resource.attributes["k8s.namespace.name"], "^prod-")
          - set(resource.attributes["deployment.environment"], "staging") where IsMatch(resource.attributes["k8s.namespace.name"], "^(staging|test)-")
          - set(resource.attributes["deployment.environment"], "development") where IsMatch(resource.attributes["k8s.namespace.name"], "^dev-")
```

### 3. HTTP Request Enhancement

```yaml
processors:
  transform/http-enhancement:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          # Normalize HTTP methods
          - set(span.attributes["http.method"], ToUpperCase(span.attributes["http.method"]))
          # Set span status based on HTTP status code
          - set(span.status.code, STATUS_CODE_ERROR) where span.attributes["http.status_code"] >= 400
          # Extract route pattern from URL
          - set(span.attributes["http.route"], replace_pattern(span.attributes["http.target"], "/\\d+", "/{id}"))
```

### 4. Database Query Sanitization

```yaml
processors:
  transform/db-sanitization:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          # Sanitize SQL queries by removing literal values
          - replace_pattern(span.attributes["db.statement"], "'[^']*'", "'?'")
          - replace_pattern(span.attributes["db.statement"], "\\b\\d+\\b", "?")
          # Limit query length
          - set(span.attributes["db.statement"], Substring(span.attributes["db.statement"], 0, 1000))
```

## Error Handling and Debugging

### Error Mode Configuration

Always set `error_mode` explicitly in your processor configuration:

```yaml
processors:
  transform:
    error_mode: ignore  # Recommended for production
    trace_statements:
      - context: span
        statements:
          - set(span.attributes["env"], "production")
```

| Mode | Behavior | When to Use |
|------|----------|-------------|
| `propagate` | Stops processing on error | Development and testing |
| `ignore` | Logs error, continues processing | **Production** (recommended) |
| `silent` | Ignores errors without logging | High-volume pipelines |

### Debugging OTTL Expressions

1. **Enable debug logging**: Set `log_level: debug` in your collector configuration
2. **Use console exporter**: Route output to console to see transformed data
3. **Start simple**: Test basic expressions before building complex ones
4. **Check nil values**: Always guard optional attributes with nil checks

### Common Gotchas

1. **Type mismatches**: Ensure you're comparing compatible types
   ```ottl
   # BAD: comparing string to int
   span.attributes["status_code"] == 200
   
   # GOOD: convert to int first
   Int(span.attributes["status_code"]) == 200
   ```

2. **Context isolation**: Variables don't persist across statement contexts
   ```ottl
   # This won't work - temp variables don't cross contexts
   - context: span
     statements:
       - set(cache["temp"], "value")
   - context: resource
     statements:
       - set(resource.attributes["data"], cache["temp"])  # cache["temp"] is undefined here
   ```

3. **Performance considerations**: Avoid expensive operations in tight loops
   ```ottl
   # BAD: expensive regex in inner loop
   IsMatch(span.attributes["trace_id"], "^[a-f0-9]{32}$") 
   
   # GOOD: use simpler checks when possible
   Len(span.attributes["trace_id"]) == 32
   ```

## Integration with Dynatrace

When using OTTL with Dynatrace, consider these patterns:

### DQL Query Enhancement

Enrich spans with metadata that makes DQL queries more effective:

```ottl
# Add query-friendly tags
set(span.attributes["dt.service_tier"], "frontend") where IsMatch(span.name, "^(http|web|ui)")
set(span.attributes["dt.service_tier"], "backend") where IsMatch(span.name, "^(db|sql|mongo)")
set(span.attributes["dt.error_type"], "timeout") where IsMatch(span.status.message, "(?i)timeout")
```

### Resource Attribution

```ottl
# Standardize resource attributes for Dynatrace dashboards
set(resource.attributes["dt.entity.host"], resource.attributes["host.name"])
set(resource.attributes["dt.entity.service"], resource.attributes["service.name"])
```

## Best Practices

1. **Place processors correctly**: Redaction after enrichment, before export
2. **Use defensive programming**: Always check for nil values
3. **Set error_mode to ignore**: For production resilience
4. **Keep expressions simple**: Break complex logic into multiple statements
5. **Document your transformations**: Include comments explaining business logic
6. **Test thoroughly**: Validate expressions in non-production environments first
7. **Monitor performance**: Watch for processing latency increases

## Examples Repository

For more examples and patterns, see the [BMAD OTTL Examples](../examples/ottl/) directory.

## References

- [OpenTelemetry OTTL Specification](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/pkg/ottl)
- [OTTL Functions Reference](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/pkg/ottl/ottlfuncs)
- [OTTL Playground](https://ottl.run)
- [Transform Processor Documentation](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/transformprocessor)