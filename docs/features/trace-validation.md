# Trace Validation

Trace validation compares actual telemetry against the observability spec using Dynatrace MCP for live data queries.

## The 5-Step Query Validation Gate

Before concluding ANY span, metric, or log is missing, this mandatory gate must pass:

### Step 1: Verify Service Name

```dql
fetch spans
| summarize count(), by:{service.name}
| sort count desc
| limit 20
```

Service names may differ due to prefixes, suffixes, or casing.

### Step 2: Verify Namespace

```dql
fetch spans
| filter service.name == "{service_name}"
| summarize count(), by:{k8s.namespace.name}
```

### Step 3: Verify Time Window

```dql
fetch spans
| filter service.name == "{service_name}"
| summarize first_seen=min(start_time), last_seen=max(start_time)
```

If `last_seen` is more than 1 hour ago, the service may not be receiving traffic.

### Step 4: Verify Span Names

```dql
fetch spans
| filter service.name == "{service_name}"
| summarize count(), by:{span.name}
| sort count desc
```

### Step 5: Verify Attribute Existence

```dql
fetch spans
| filter service.name == "{service_name}"
| filter isNotNull({attribute_name})
| summarize count()
```

## Validation Process

After the gate passes:

1. **Trace contracts** -- Check each expected span exists with required attributes
2. **Log contracts** -- Check structured fields and trace_id correlation
3. **Metric contracts** -- Check metric existence and dimensions
4. **Correlation contracts** -- Check trace-to-log correlation percentage

## Reports

Two report formats are generated:

**Human-readable** (`_bmad-output/o11y-artifacts/reports/{service}-validation-{date}.md`):

- Summary table with pass/fail per contract
- Failure details with severity rating
- Recommendations with fix commands

**Machine-readable** (`_bmad-output/o11y-artifacts/reports/{service}-validation-{date}.yaml`):

- Structured data for automation
- Fix story references
- DQL queries for re-validation

## Fix Stories

For each failure, a fix story is generated in BMAD standard format:

- `spec_reference` pointing to the failed contract
- `test_criteria` with the DQL query that should pass
- Language-specific fix suggestions
- Severity rating (CRITICAL, HIGH, MEDIUM)

## Failure Severity

| Severity | Meaning | Action |
|----------|---------|--------|
| CRITICAL | SLO-impacting | Immediate fix, blocks release |
| HIGH | Spec violation | Fix in current sprint |
| MEDIUM | Best practice | Fix in next sprint |
| LOW | Minor improvement | Backlog |
