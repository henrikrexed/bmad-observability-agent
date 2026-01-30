# Dynatrace Assets

The O11y Engineer provides comprehensive Dynatrace asset management through two complementary approaches: **dtctl-based** (configuration as code) and **MCP-powered** (AI-driven discovery).

## Dashboards

### dtctl-Based: `create-dt-dashboard`

Generate dashboard YAML files deployed with `dtctl apply`.

```
*create-dt-dashboard
```

### MCP-Powered: `build-project-dashboard`

Auto-discover metrics in your environment and build dashboards from real data.

```
*build-project-dashboard
```

### Dashboard YAML Format

```yaml
type: dashboard
name: "Service Overview"
content:
  version: 7
  variables: []
  tiles:
    - title: "Request Rate"
      type: data
      query:
        type: dql
        value: |
          timeseries requests=sum(http_requests_total), interval:5m
      visualization: lineChart
      visualizationSettings:
        chartSettings:
          fieldMapping:
            leftAxisValues: [requests]
            timestamp: timeframe
      querySettings:
        maxResultRecords: 1000
        defaultScanLimitGbytes: 500
        maxResultMegaBytes: 1
        defaultSamplingRatio: 10
        enableSampling: false
      davis: {}
      layout:
        x: 0
        y: 0
        w: 12
        h: 6
```

### Common DQL Patterns for Dashboards

=== "Success Rate"

    ```dql
    timeseries {
      success=sum(http_requests_total, filter:{status_code < 500}),
      total=sum(http_requests_total)
    }, interval:5m
    | fieldsAdd success_rate=(success[]/total[])*100
    ```

=== "Latency Percentiles"

    ```dql
    fetch spans
    | filter service.name == "my-service"
    | makeTimeseries {
        p50=percentile(duration, 50),
        p95=percentile(duration, 95),
        p99=percentile(duration, 99)
      }, interval:5m
    | fieldsAdd p50_ms=p50[]/1000000, p95_ms=p95[]/1000000, p99_ms=p99[]/1000000
    ```

=== "Error Analysis"

    ```dql
    fetch spans
    | filter service.name == "my-service"
    | filter status.code == "ERROR"
    | summarize count=count(), by:{span.name, error.message}
    | sort count desc
    ```

### Visualization Types

| Type | Use Case |
|------|----------|
| `singleValue` | KPI display (error rate, latency) |
| `lineChart` | Time series trends |
| `areaChart` | Stacked area (capacity) |
| `barChart` | Categorical comparisons |
| `pieChart` | Proportional breakdown |
| `table` | Tabular data (traces, logs) |
| `honeycomb` | Entity health overview |

### Deploy

```bash
dtctl apply -f dashboard.yaml --dry-run   # Validate first
dtctl apply -f dashboard.yaml             # Deploy
```

---

## Notebooks

Notebooks are interactive investigation documents combining markdown, DQL queries, and visualizations.

### dtctl-Based: `create-dt-notebook`

```
*create-dt-notebook
```

### MCP-Powered: `build-diagnostic-notebook`

Auto-discover data schema and generate contextually accurate notebooks.

```
*build-diagnostic-notebook
```

### Notebook YAML Format

```yaml
type: notebook
name: "Service Diagnosis"
content:
  version: "7"          # String, not integer
  defaultTimeframe:
    from: now()-2h
    to: now()
  sections:             # Array of section objects
    - id: "section-1"
      type: markdown
      markdown: |
        # Service Diagnosis
        Investigation notebook for troubleshooting.

    - id: "section-2"
      type: dql
      state:
        input:
          value: |
            fetch spans
            | filter service.name == "my-service"
            | filter status.code == "ERROR"
            | sort start_time desc
            | limit 50
          timeframe:
            from: now()-2h
            to: now()
        visualization: table
        querySettings:
          maxResultRecords: 1000
          defaultScanLimitGbytes: 500
          maxResultMegaBytes: 1
          defaultSamplingRatio: 10
          enableSampling: false
      davis:
        includeLogs: true
        davisVisualization:
          isAvailable: true
```

!!! note "Important Differences from Dashboards"
    - `content.version` is a **string** (`"7"`), not an integer
    - `content.sections` is an **array**, not an object
    - Each section has a unique `id`

### Recommended Notebook Sections

1. **Service Overview** (markdown) -- Description, SLIs
2. **Error Analysis** (dql) -- Recent errors
3. **Error Traces** (dql) -- Spans with errors
4. **Latency Analysis** (dql) -- P50/P95/P99 percentiles
5. **Slow Requests** (dql) -- Spans exceeding duration threshold
6. **Trace-Log Correlation** (markdown) -- How to use trace_id
7. **Logs for Trace** (dql) -- Look up logs by trace ID

### When to Use Notebooks vs Dashboards

| Aspect | Dashboard | Notebook |
|--------|-----------|----------|
| Purpose | Ongoing monitoring | Investigation |
| Audience | Operations, on-call | Incident responders |
| Content | Fixed visualizations | Interactive queries |
| Lifecycle | Long-lived | Per incident or review |

---

## Workflows

Dynatrace workflows automate incident response, remediation, and reporting.

### dtctl-Based: `create-dt-workflow`

```
*create-dt-workflow
```

### MCP-Powered: `suggest-workflows`

Analyze your environment and recommend automation opportunities.

```
*suggest-workflows
```

### Workflow YAML Format

```yaml
title: "Auto-Remediation: High Error Rate"
description: "Detect high error rates and notify via Slack"
trigger:
  event:
    type: events
    query: event.type == "PROBLEM"
tasks:
  get_data:
    action: dynatrace.automations:execute-dql-query
    input:
      query: |
        fetch spans, from:-30m
        | filter service.name == "my-service"
        | filter status.code == "ERROR"
        | summarize error_count=count(), by:{span.name}
  process_data:
    action: dynatrace.automations:run-javascript
    input:
      script: |
        import { execution } from '@dynatrace-sdk/automation-utils';
        export default async function ({ execution_id }) {
          const ex = await execution(execution_id);
          const result = await ex.result('get_data');
          const errors = result.records.filter(r => r.error_count > 10);
          return { high_error_spans: errors };
        }
    conditions:
      states:
        get_data: OK
    predecessors:
      - get_data
  send_notification:
    action: dynatrace.slack:slack-send-message
    input:
      channel: alerts-channel
      message: |
        High error rate detected:
        {{ result('process_data').high_error_spans | join('\n') }}
    conditions:
      custom: "{{ result('process_data').high_error_spans | length > 0 }}"
      states:
        process_data: OK
    predecessors:
      - process_data
```

### Trigger Types

| Type | Description | Example |
|------|-------------|---------|
| Event-based | Problem or custom event | `event.type == "PROBLEM"` |
| Schedule-based | Cron schedule | `"0 9 * * *"` (daily 9 AM) |
| Manual | No trigger | Run on demand |

### Task Actions

| Action | Description |
|--------|-------------|
| `dynatrace.automations:execute-dql-query` | Execute DQL |
| `dynatrace.automations:run-javascript` | Run TypeScript |
| `dynatrace.automations:http-request` | HTTP request |
| `dynatrace.slack:slack-send-message` | Slack message |
| `dynatrace.jira:jira-create-issue` | Create Jira issue |
| `dynatrace.davis:davis-analyze` | Davis AI analysis |

---

## MCP vs dtctl Comparison

| Capability | dtctl Command | MCP Command |
|-----------|---------------|-------------|
| Dashboards | `create-dt-dashboard` | `build-project-dashboard` |
| Notebooks | `create-dt-notebook` | `build-diagnostic-notebook` |
| Workflows | `create-dt-workflow` | `suggest-workflows` |
| Discovery | Manual input | `discover-services` (auto) |
| Best for | CI/CD, GitOps | Interactive, prototyping |

### Using Both Together

1. **MCP** to explore and prototype dashboards interactively
2. **Export** with `dtctl get dashboard <id> -o yaml`
3. **Store** in version control
4. **Deploy** via CI/CD with `dtctl apply -f dashboards/`

---

## dtctl Command Reference

| Command | Description |
|---------|-------------|
| `dtctl apply -f <file>` | Deploy a resource |
| `dtctl apply -f <file> --dry-run` | Validate without deploying |
| `dtctl get dashboards` | List all dashboards |
| `dtctl get dashboard <id> -o yaml` | Export dashboard |
| `dtctl get notebooks` | List all notebooks |
| `dtctl get workflows` | List all workflows |
| `dtctl execute workflow <id>` | Run workflow manually |
| `dtctl query "<dql>"` | Run DQL query |
| `dtctl config set-context <name>` | Configure environment |
| `dtctl config use-context <name>` | Switch environment |
