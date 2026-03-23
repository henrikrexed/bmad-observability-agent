# Sensitive Data in Observability

Telemetry data can inadvertently capture personally identifiable information (PII), credentials, and other sensitive data. Once exported to observability backends, this data is difficult to remove and may violate privacy regulations or compliance policies. This guide provides comprehensive strategies for preventing sensitive data from entering your observability pipeline.

## Understanding Sensitive Data Categories

### Never Instrument (Zero Tolerance)

These data categories must never appear in any telemetry:

| Category | Examples | Risk | Regulation |
|----------|----------|------|------------|
| **Authentication credentials** | Passwords, API keys, JWT tokens, session cookies, OAuth secrets | Credential compromise | GDPR, SOX |
| **Financial data** | Credit card numbers, bank account numbers, CVV codes, payment tokens | Financial fraud | PCI DSS |
| **Government identifiers** | SSNs, passport numbers, tax IDs, driver's license numbers | Identity theft | HIPAA, GDPR |
| **Health records** | Medical diagnoses, prescription data, patient IDs | Privacy violation | HIPAA |
| **Biometric data** | Fingerprints, facial recognition data, voice prints | Irreversible exposure | GDPR, BIPA |

### High-Risk Fields (Evaluate Before Use)

These fields can be useful for debugging but require careful consideration:

| Field | Permitted Conditions | Recommended Alternative |
|-------|---------------------|-------------------------|
| **User IDs** | Only opaque identifiers (UUIDs), never usernames/emails | Hash with salt |
| **IP addresses** | Only for abuse detection; truncate when possible | Country/region codes |
| **Email addresses** | Never in attributes | Hash with keyed function |
| **Full URLs** | Only after sanitizing query parameters | Parameterized routes |
| **Database queries** | Only parameterized queries, never literal values | Query templates |
| **Request/response bodies** | Never log full bodies | Content hashes, sizes |

## Prevention Strategies

### Application-Level Prevention (First Line of Defense)

#### 1. SDK Configuration

**OpenTelemetry Instrumentation Rules:**

```javascript
// Node.js - Custom SpanProcessor for redaction
class SensitiveDataRedactingSpanProcessor {
  onEnd(span) {
    const SENSITIVE_ATTRIBUTES = [
      'http.request.header.authorization',
      'http.request.header.cookie',
      'http.response.header.set-cookie'
    ];
    
    SENSITIVE_ATTRIBUTES.forEach(attr => {
      if (span.attributes[attr] !== undefined) {
        span.attributes[attr] = 'REDACTED';
      }
    });
    
    // Sanitize URLs
    if (span.attributes['url.full']) {
      try {
        const url = new URL(span.attributes['url.full']);
        url.search = ''; // Remove query parameters
        span.attributes['url.full'] = url.toString();
      } catch (e) {
        // Leave as-is if not a valid URL
      }
    }
  }
}
```

```python
# Python - Custom processor
from opentelemetry.sdk.trace.export import SpanProcessor

class SensitiveDataRedactingProcessor(SpanProcessor):
    def on_end(self, span):
        sensitive_attrs = [
            'http.request.header.authorization',
            'http.request.header.cookie'
        ]
        
        for attr in sensitive_attrs:
            if hasattr(span, 'attributes') and attr in span.attributes:
                span.attributes[attr] = 'REDACTED'
```

#### 2. URL Sanitization

```javascript
function sanitizeUrl(url) {
  const sensitiveParams = ['token', 'api_key', 'session_id', 'auth', 'password'];
  const parsed = new URL(url);
  
  sensitiveParams.forEach(param => {
    if (parsed.searchParams.has(param)) {
      parsed.searchParams.set(param, 'REDACTED');
    }
  });
  
  return parsed.toString();
}

// Use in span attribution
span.setAttribute('url.full', sanitizeUrl(request.url));
```

#### 3. Database Query Sanitization

```go
// Go - Safe database span attribution
func setDBStatement(span trace.Span, query string) {
    // Remove string literals and numeric values
    sanitized := query
    sanitized = regexp.MustCompile(`'[^']*'`).ReplaceAllString(sanitized, `'?'`)
    sanitized = regexp.MustCompile(`\b\d+\b`).ReplaceAllString(sanitized, `?`)
    span.SetAttribute("db.statement", sanitized)
}
```

#### 4. Structured Logging Safeguards

```javascript
// BAD: Spreads entire request object
logger.info('user.signup', { ...req.body });

// GOOD: Explicitly select safe fields
logger.info('user.signup', {
  user_id: req.body.userId,
  plan: req.body.plan,
  timestamp: new Date().toISOString()
});
```

### Collector-Level Protection (Second Line of Defense)

#### 1. OTTL-Based Redaction

**Authorization Header Redaction:**
```yaml
processors:
  transform/redact-auth:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          - set(span.attributes["http.request.header.authorization"], "REDACTED") where span.attributes["http.request.header.authorization"] != nil
          - set(span.attributes["http.request.header.cookie"], "REDACTED") where span.attributes["http.request.header.cookie"] != nil
          - set(span.attributes["http.response.header.set-cookie"], "REDACTED") where span.attributes["http.response.header.set-cookie"] != nil
```

**Credit Card Masking:**
```yaml
processors:
  transform/mask-credit-cards:
    error_mode: ignore
    log_statements:
      - context: log
        statements:
          # Mask credit card numbers (keep first and last 4 digits)
          - replace_pattern(log.body["string"], "\\b(\\d{4})[\\d\\s-]{8,12}(\\d{4})\\b", "$1-****-****-$2")
```

**Email Address Hashing:**
```yaml
processors:
  transform/hash-emails:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          - set(span.attributes["user.email"], SHA256(span.attributes["user.email"])) where span.attributes["user.email"] != nil
    log_statements:
      - context: log
        statements:
          - set(log.attributes["user.email"], SHA256(log.attributes["user.email"])) where log.attributes["user.email"] != nil
```

#### 2. Comprehensive PII Redaction Pipeline

```yaml
processors:
  # Stage 1: Remove known sensitive attributes
  transform/delete-sensitive:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          - delete_key(span.attributes, "password")
          - delete_key(span.attributes, "api_key")
          - delete_key(span.attributes, "secret")
          - delete_matching_keys(span.attributes, "(?i).*(password|secret|token|key).*")
  
  # Stage 2: Redact headers
  transform/redact-headers:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          - set(span.attributes["http.request.header.authorization"], "REDACTED") where span.attributes["http.request.header.authorization"] != nil
          - set(span.attributes["http.request.header.cookie"], "REDACTED") where span.attributes["http.request.header.cookie"] != nil
  
  # Stage 3: Mask patterns in log bodies
  transform/mask-patterns:
    error_mode: ignore
    log_statements:
      - context: log
        statements:
          # Credit cards (various formats)
          - replace_pattern(log.body["string"], "\\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13}|3[0-9]{13}|6(?:011|5[0-9]{2})[0-9]{12})\\b", "****-****-****-****")
          # SSNs
          - replace_pattern(log.body["string"], "\\b\\d{3}-\\d{2}-\\d{4}\\b", "***-**-****")
          # Phone numbers
          - replace_pattern(log.body["string"], "\\b\\d{3}-\\d{3}-\\d{4}\\b", "***-***-****")
          # Email addresses
          - replace_pattern(log.body["string"], "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b", "****@****.***")
  
  # Stage 4: Hash user identifiers
  transform/hash-identifiers:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          - set(span.attributes["user.id"], SHA256(span.attributes["user.id"])) where span.attributes["user.id"] != nil and not IsMatch(span.attributes["user.id"], "^[0-9a-f-]{36}$")

service:
  pipelines:
    traces:
      processors: [transform/delete-sensitive, transform/redact-headers, transform/hash-identifiers]
    logs:
      processors: [transform/mask-patterns]
```

#### 3. Drop Sensitive Log Records

```yaml
processors:
  filter/drop-sensitive-logs:
    error_mode: ignore
    logs:
      log_record:
        # Drop logs containing private keys
        - 'IsMatch(log.body["string"], "(?i)-----BEGIN (RSA |EC )?PRIVATE KEY-----")'
        # Drop logs with tokens
        - 'IsMatch(log.body["string"], "(?i)(bearer|token)\\s+[a-zA-Z0-9+/=]{20,}")'
        # Drop SQL statements with literal values
        - 'IsMatch(log.body["string"], "(?i)INSERT INTO.*VALUES.*[0-9a-f-]{8,}")'
```

## Advanced Protection Patterns

### 1. Dynamic Attribute Allowlists

```yaml
processors:
  transform/allowlist-attributes:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          # Define allowed attributes
          - keep_keys(span.attributes, ["service.name", "http.method", "http.status_code", "http.route", "db.operation", "messaging.operation"])
```

### 2. Conditional Redaction Based on Service

```yaml
processors:
  transform/service-based-redaction:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          # More strict redaction for payment services
          - delete_matching_keys(span.attributes, "(?i).*(user|customer|payment|card).*") where resource.attributes["service.name"] == "payment-service"
          # Standard redaction for other services
          - set(span.attributes["http.request.header.authorization"], "REDACTED") where span.attributes["http.request.header.authorization"] != nil and resource.attributes["service.name"] != "payment-service"
```

### 3. Hash-Based Correlation

For situations where you need to correlate data across services without exposing PII:

```javascript
const crypto = require('crypto');

function createCorrelationId(email, salt) {
  return crypto.createHmac('sha256', salt)
    .update(email)
    .digest('hex')
    .substring(0, 16); // Use first 16 chars for shorter IDs
}

// Use in spans
span.setAttribute('user.correlation_id', createCorrelationId(user.email, process.env.CORRELATION_SALT));
```

## Compliance Frameworks

### GDPR Compliance

**Key Requirements:**
- Data minimization: Collect only necessary data
- Purpose limitation: Use data only for stated purposes
- Storage limitation: Retain data only as long as necessary
- Right to erasure: Support data deletion requests

**Implementation:**
```yaml
processors:
  transform/gdpr-compliance:
    error_mode: ignore
    trace_statements:
      - context: resource
        statements:
          # Add data classification
          - set(resource.attributes["data.classification"], "personal") where span.attributes["user.id"] != nil
          # Add retention policy markers
          - set(resource.attributes["data.retention_days"], "30") where resource.attributes["service.name"] == "web-analytics"
```

### PCI DSS Compliance

**Requirements for Payment Card Data:**

```yaml
processors:
  transform/pci-compliance:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          # Completely remove any potential card data
          - delete_matching_keys(span.attributes, "(?i).*(card|payment|cvv|pan).*")
    log_statements:
      - context: log
        statements:
          # Mask any card patterns
          - replace_pattern(log.body["string"], "\\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14})\\b", "****-****-****-****")
          # Remove CVV patterns
          - replace_pattern(log.body["string"], "\\b[0-9]{3,4}\\b", "***")
```

### HIPAA Compliance (Healthcare)

```yaml
processors:
  transform/hipaa-compliance:
    error_mode: ignore
    trace_statements:
      - context: span
        statements:
          # Remove all potential PHI identifiers
          - delete_matching_keys(span.attributes, "(?i).*(patient|medical|health|ssn|dob).*")
          # Hash any remaining user identifiers
          - set(span.attributes["patient.correlation_id"], SHA256(span.attributes["patient.id"])) where span.attributes["patient.id"] != nil
          - delete_key(span.attributes, "patient.id")
```

## Testing and Validation

### 1. Data Validation Scripts

```bash
#!/bin/bash
# validate-telemetry.sh - Check exported data for sensitive patterns

echo "Checking for credit card numbers..."
grep -E "\b[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}\b" telemetry-export.json && echo "⚠️  Credit card patterns found!"

echo "Checking for SSNs..."
grep -E "\b[0-9]{3}-[0-9]{2}-[0-9]{4}\b" telemetry-export.json && echo "⚠️  SSN patterns found!"

echo "Checking for email addresses..."
grep -E "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b" telemetry-export.json && echo "⚠️  Email addresses found!"

echo "Validation complete."
```

### 2. Unit Tests for Redaction Logic

```javascript
// test-redaction.js
const assert = require('assert');
const { redactSpan } = require('./redaction');

describe('Span Redaction', () => {
  it('should redact authorization headers', () => {
    const span = {
      attributes: {
        'http.request.header.authorization': 'Bearer secret-token'
      }
    };
    
    redactSpan(span);
    assert.equal(span.attributes['http.request.header.authorization'], 'REDACTED');
  });
  
  it('should mask credit card numbers', () => {
    const span = {
      attributes: {
        'payment.card': '4532-1234-5678-9012'
      }
    };
    
    redactSpan(span);
    assert.equal(span.attributes['payment.card'], '4532-****-****-9012');
  });
});
```

## Monitoring and Alerting

### 1. Sensitive Data Detection Alerts

```yaml
# Dynatrace DQL query for PII detection
fetch dt.entity.service
| filter contains(attributes["http.request.header.authorization"], "Bearer") and attributes["http.request.header.authorization"] != "REDACTED"
| summarize count = count(), by: {dt.entity.service}
```

### 2. Compliance Monitoring Dashboard

Create dashboards that track:
- Redaction processor success rates
- Failed redaction attempts
- Data classification compliance
- Retention policy adherence

## Emergency Response

### Data Leak Response Plan

1. **Immediate Actions:**
   - Stop data ingestion if possible
   - Identify affected time range
   - Document the incident

2. **Containment:**
   - Deploy emergency redaction rules
   - Contact backend administrators for data deletion
   - Review logs for exposed data patterns

3. **Recovery:**
   - Implement additional safeguards
   - Update redaction rules
   - Test new protections thoroughly

## Integration with Dynatrace

### DQL Queries for Compliance Monitoring

```dql
// Check for potential PII in spans
fetch dt.entity.service
| filter matchesPattern(span_attributes, "email|phone|ssn")
| summarize pii_spans = count(), by: {dt.entity.service}
| sort pii_spans desc

// Monitor redaction effectiveness
fetch spans
| filter span_attributes["http.request.header.authorization"] != "REDACTED" 
   and isNotNull(span_attributes["http.request.header.authorization"])
| summarize unredacted_auth_headers = count()

// Track sensitive data patterns
fetch logs
| filter matchesPattern(log.content, "\\b[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}\\b")
| summarize potential_credit_cards = count(), by: {dt.entity.service}
```

## Best Practices Summary

1. **Defense in Depth**: Implement protection at application, collector, and backend levels
2. **Fail Secure**: When in doubt, redact or drop the data
3. **Test Thoroughly**: Validate redaction rules against real data patterns
4. **Monitor Continuously**: Set up alerts for sensitive data detection
5. **Document Everything**: Maintain clear policies and incident response procedures
6. **Regular Audits**: Periodically review telemetry exports for compliance
7. **Least Privilege**: Only collect data that's absolutely necessary for observability

## References

- [OpenTelemetry Sensitive Data Specification](https://opentelemetry.io/docs/specs/otel/overview/#sensitive-data)
- [GDPR Compliance Guide](https://gdpr.eu/)
- [PCI DSS Requirements](https://www.pcisecuritystandards.org/)
- [HIPAA Privacy Rule](https://www.hhs.gov/hipaa/for-professionals/privacy/index.html)
- [OTTL Redaction Patterns](../ottl-guide/#redacting-sensitive-data)