# /write-ottl - OTTL Expression Helper

Generate OpenTelemetry Transformation Language (OTTL) expressions for common observability use cases.

## Usage

```
/write-ottl [use_case] [context] [details]
```

## Parameters

- `use_case` - The transformation purpose (required)
- `context` - Signal context (traces/metrics/logs) (optional)
- `details` - Specific requirements or patterns (optional)

## Use Cases

### PII Redaction
```
/write-ottl pii_redaction traces "redact authorization headers and email addresses"
```

**Example Output:**
```yaml
processors:
  transform/redact_pii:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          - set(span.attributes["http.request.header.authorization"], "REDACTED") where span.attributes["http.request.header.authorization"] != nil
          - replace_pattern(span.attributes["user.email"], "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b", "****@****.***")
```

### Kubernetes Enrichment
```
/write-ottl enrichment traces "add cluster and environment metadata"
```

**Example Output:**
```yaml
processors:
  transform/k8s_enrichment:
    error_mode: ignore
    trace_statements:
      - context: resource
        statements:
          - set(resource.attributes["k8s.cluster.name"], "production-us-west-2")
          - set(resource.attributes["deployment.environment"], "production") where IsMatch(resource.attributes["k8s.namespace.name"], "^prod-")
          - set(resource.attributes["deployment.environment"], "staging") where IsMatch(resource.attributes["k8s.namespace.name"], "^staging-")
```

### Cardinality Control
```
/write-ottl cardinality metrics "limit user attributes to prevent explosion"
```

**Example Output:**
```yaml
processors:
  transform/cardinality_control:
    error_mode: ignore
    metric_statements:
      - context: datapoint
        statements:
          - delete_matching_keys(attributes, "^user\\.(id|email|session)")
          - limit(attributes, 20, ["service.name", "http.method", "http.status_code"])
```

### HTTP Enhancement
```
/write-ottl http_enhancement traces "normalize methods and extract routes"
```

**Example Output:**
```yaml
processors:
  transform/http_enhancement:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          - set(span.attributes["http.method"], ToUpperCase(span.attributes["http.method"])) where span.attributes["http.method"] != nil
          - set(span.status.code, STATUS_CODE_ERROR) where Int(span.attributes["http.status_code"]) >= 400
          - replace_pattern(span.attributes["http.target"], "/\\d+", "/{id}")
```

### Database Query Sanitization
```
/write-ottl db_sanitization traces "remove literal values from SQL statements"
```

**Example Output:**
```yaml
processors:
  transform/db_sanitization:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          - replace_pattern(span.attributes["db.statement"], "'[^']*'", "?") where span.attributes["db.statement"] != nil
          - replace_pattern(span.attributes["db.statement"], "\\b\\d+\\b", "?") where span.attributes["db.statement"] != nil
          - set(span.attributes["db.statement"], Substring(span.attributes["db.statement"], 0, 1000))
```

### Error Classification
```
/write-ottl error_classification traces "categorize errors by type and severity"
```

**Example Output:**
```yaml
processors:
  transform/error_classification:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          - set(span.attributes["error.category"], "client") where Int(span.attributes["http.status_code"]) >= 400 and Int(span.attributes["http.status_code"]) < 500
          - set(span.attributes["error.category"], "server") where Int(span.attributes["http.status_code"]) >= 500
          - set(span.attributes["error.severity"], "high") where Int(span.attributes["http.status_code"]) == 500
          - set(span.attributes["error.type"], "timeout") where IsMatch(span.status.message, "(?i)timeout")
```

### Log Parsing and Enrichment
```
/write-ottl log_parsing logs "parse structured application logs"
```

**Example Output:**
```yaml
processors:
  transform/log_parsing:
    error_mode: ignore
    log_statements:
      - context: log
        statements:
          - set(cache["parsed"], ParseJSON(log.body["string"])) where IsString(log.body["string"])
          - set(log.attributes["level"], cache["parsed"]["level"]) where cache["parsed"] != nil
          - set(log.attributes["component"], cache["parsed"]["logger"]) where cache["parsed"] != nil
          - set(log.attributes["user.id"], cache["parsed"]["user_id"]) where cache["parsed"] != nil
          - delete_key(cache, "parsed")
```

### Routing Configuration
```
/write-ottl routing traces "route errors to different backends"
```

**Example Output:**
```yaml
connectors:
  routing/error_routing:
    error_mode: ignore
    table:
      - statement: span.status.code == STATUS_CODE_ERROR
        pipelines: [traces/errors]
      - statement: resource.attributes["service.name"] == "critical-service"
        pipelines: [traces/critical]
      - pipelines: [traces/default]
```

## Advanced Examples

### Multi-Step PII Redaction
```
/write-ottl pii_redaction traces "comprehensive protection with temp variables"
```

**Example Output:**
```yaml
processors:
  transform/advanced_pii:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          # Step 1: Parse and redact URLs
          - set(cache["url"], ParseURL(span.attributes["http.url"])) where span.attributes["http.url"] != nil
          - delete_key(cache["url"]["query"], "token") where cache["url"] != nil
          - delete_key(cache["url"]["query"], "api_key") where cache["url"] != nil
          - set(span.attributes["http.url"], BuildURL(cache["url"])) where cache["url"] != nil
          
          # Step 2: Hash user identifiers
          - set(span.attributes["user.id"], SHA256(span.attributes["user.id"])) where span.attributes["user.id"] != nil and not IsMatch(span.attributes["user.id"], "^[0-9a-f]{64}$")
          
          # Step 3: Redact headers
          - set(span.attributes["http.request.header.authorization"], "REDACTED") where span.attributes["http.request.header.authorization"] != nil
          - set(span.attributes["http.request.header.cookie"], "REDACTED") where span.attributes["http.request.header.cookie"] != nil
          
          # Cleanup
          - delete_key(cache, "url")
```

### Performance Optimization
```
/write-ottl performance traces "optimize spans for high-throughput systems"
```

**Example Output:**
```yaml
processors:
  transform/performance:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          # Limit attribute count and size
          - limit(span.attributes, 25, ["service.name", "http.method", "http.status_code"])
          - truncate_all(span.attributes, 256)
          
          # Simplify span names for high-volume operations
          - set(span.name, "http.request") where IsMatch(span.name, "^(GET|POST|PUT|DELETE) /")
          - set(span.name, "db.query") where IsMatch(span.name, "^(SELECT|INSERT|UPDATE|DELETE)")
          
          # Drop noisy attributes
          - delete_matching_keys(span.attributes, "^(thread|request)\\.(id|uuid)")
```

## Context Reference

### Span Context
```yaml
span.name                          # Span name
span.kind                          # Span kind (server, client, etc.)
span.status.code                   # Status code
span.status.message               # Status message
span.attributes["key"]            # Span attributes
span.events[0].name               # Event name
span.events[0].attributes["key"]  # Event attributes
```

### Resource Context
```yaml
resource.attributes["service.name"]     # Service name
resource.attributes["k8s.pod.name"]     # Pod name
resource.attributes["deployment.environment"] # Environment
```

### Log Context
```yaml
log.body["string"]                # Log message (string)
log.body["map"]                   # Log message (structured)
log.attributes["key"]             # Log attributes
log.severity_text                 # Severity level
log.time                          # Timestamp
```

### Metric Context
```yaml
metric.name                       # Metric name
metric.description               # Description
metric.unit                      # Unit
datapoint.attributes["key"]      # Data point attributes
```

## Common Functions

### Editors (modify data)
- `set(path, value)` - Set a field
- `delete_key(map, key)` - Remove a key
- `delete_matching_keys(map, pattern)` - Remove matching keys
- `replace_pattern(string, pattern, replacement)` - Regex replace
- `merge_maps(map1, map2, strategy)` - Merge maps
- `limit(map, count, keep_keys)` - Limit map size
- `truncate_all(map, length)` - Truncate all strings

### Converters (return values)
- `String(value)` - Convert to string
- `Int(value)` - Convert to integer
- `Double(value)` - Convert to double
- `Bool(value)` - Convert to boolean
- `IsString(value)` - Check if string
- `IsMatch(string, pattern)` - Regex match
- `ToUpperCase(string)` - Uppercase
- `Substring(string, start, end)` - Extract substring
- `SHA256(string)` - Hash string
- `ParseJSON(string)` - Parse JSON

## Best Practices

1. **Use `error_mode: ignore`** for production resilience
2. **Check for `nil` values** to avoid creating empty attributes
3. **Use temp variables (`cache`)** for complex transformations
4. **Order statements** logically (parse → transform → cleanup)
5. **Test expressions** in development before production
6. **Document complex logic** with comments
7. **Consider performance impact** of regex and complex functions

## Performance Tips

- Use simple comparisons over complex regex when possible
- Avoid nested function calls in tight loops
- Limit the number of transformation statements
- Use `IsMatch` instead of `replace_pattern` for checks
- Cache parsed values in temp variables for reuse

## Security Considerations

- Always redact sensitive data before enrichment
- Use hashing for correlation while preserving privacy
- Validate that redaction patterns are comprehensive
- Test with real data to ensure coverage
- Monitor for new sensitive data patterns

## Related Commands

- `/configure-ottl` - Full OTTL processor configuration
- `/redact-pii` - Specialized PII protection setup
- `/debug-ottl` - Debug and troubleshoot OTTL expressions