#!/bin/bash

# Script to append Part 7 (Dynatrace Prompts) to the agent file
# This adds all Dynatrace automation and Monaco prompts

AGENT_FILE="agent/o11y-engineer.agent.yaml"

# Check if agent file exists
if [ ! -f "$AGENT_FILE" ]; then
    echo "Error: $AGENT_FILE not found"
    echo "Please run this script from the repository root"
    exit 1
fi

echo "Appending Part 7 (Dynatrace Prompts) to $AGENT_FILE..."

# Append Part 7 content
cat >> "$AGENT_FILE" << 'YAML_EOF'
  # ═══════════════════════════════════════════════════════
  # DYNATRACE CONFIGURATION & MANAGEMENT PROMPTS
  # ═══════════════════════════════════════════════════════

  - id: dtctl-setup
    content: |
      Set up Dynatrace integration and Monaco (configuration as code).
      
      ## Step 1: Install Monaco
```bash
      # macOS
      brew install dynatrace/dynatrace/monaco
      
      # Linux
      wget https://github.com/dynatrace/dynatrace-configuration-as-code/releases/latest/download/monaco-linux-amd64
      chmod +x monaco-linux-amd64
      sudo mv monaco-linux-amd64 /usr/local/bin/monaco
      
      # Windows
      # Download from: https://github.com/dynatrace/dynatrace-configuration-as-code/releases
      
      # Verify installation
      monaco version
```
      
      ## Step 2: Create Project Structure
```bash
      mkdir -p dynatrace-config
      cd dynatrace-config
      
      # Create directory structure
      mkdir -p projects/default/{dashboards,notebooks,workflows,alerting,synthetic,auto-tags,management-zones}
```
      
      ## Step 3: Configure Environments
```yaml
      # environments.yaml
      development:
        name: "Development"
        url:
          type: environment
          value: "https://abc12345.live.dynatrace.com"
        auth:
          token:
            type: environment
            name: DT_DEV_TOKEN
      
      staging:
        name: "Staging"
        url:
          type: environment
          value: "https://def67890.live.dynatrace.com"
        auth:
          token:
            type: environment
            name: DT_STAGING_TOKEN
      
      production:
        name: "Production"
        url:
          type: environment
          value: "https://ghi11121.live.dynatrace.com"
        auth:
          token:
            type: environment
            name: DT_PROD_TOKEN
```
      
      ## Step 4: Create API Tokens
```bash
      # Required token scopes:
      # - Read configuration
      # - Write configuration
      # - Read settings
      # - Write settings
      # - Read SLO
      # - Write SLO
      
      # Set environment variables
      export DT_DEV_TOKEN="dt0c01.xxx..."
      export DT_STAGING_TOKEN="dt0c01.yyy..."
      export DT_PROD_TOKEN="dt0c01.zzz..."
```
      
      ## Step 5: Initialize Manifest
```yaml
      # manifest.yaml
      manifestVersion: "1.0"
      
      projects:
        - name: default
          path: projects/default
      
      environmentGroups:
        - name: all
          environments:
            - name: development
            - name: staging
            - name: production
```
      
      ## Step 6: Validate Configuration
```bash
      # Dry-run validation
      monaco deploy --dry-run --environments environments.yaml manifest.yaml
      
      # Deploy to development
      monaco deploy --environments environments.yaml manifest.yaml development
```
      
      Generate complete Dynatrace + Monaco setup.

  - id: dtctl-create-dashboard
    content: |
      Create Dynatrace dashboard using Monaco configuration as code.
      
      ## Dashboard Templates
      
      ### Template 1: RED Metrics Dashboard
```json
      {
        "dashboardMetadata": {
          "name": "{{ .name }}",
          "shared": true,
          "owner": "{{ .owner }}",
          "dashboardFilter": {
            "timeframe": "{{ .timeframe }}",
            "managementZone": {
              "id": "{{ .managementZone }}"
            }
          }
        },
        "tiles": [
          {
            "name": "Request Rate",
            "tileType": "DATA_EXPLORER",
            "configured": true,
            "bounds": {
              "top": 0,
              "left": 0,
              "width": 304,
              "height": 304
            },
            "tileFilter": {},
            "queries": [
              {
                "id": "A",
                "metric": "builtin:service.request.count",
                "spaceAggregation": "SUM",
                "timeAggregation": "DEFAULT",
                "splitBy": ["dt.entity.service"]
              }
            ],
            "visualConfig": {
              "type": "GRAPH_CHART",
              "global": {},
              "rules": []
            }
          },
          {
            "name": "Error Rate",
            "tileType": "DATA_EXPLORER",
            "configured": true,
            "bounds": {
              "top": 0,
              "left": 304,
              "width": 304,
              "height": 304
            },
            "queries": [
              {
                "id": "A",
                "metric": "builtin:service.errors.total.rate",
                "spaceAggregation": "AVG",
                "timeAggregation": "DEFAULT",
                "splitBy": ["dt.entity.service"]
              }
            ],
            "visualConfig": {
              "type": "GRAPH_CHART"
            }
          },
          {
            "name": "Response Time (p95)",
            "tileType": "DATA_EXPLORER",
            "configured": true,
            "bounds": {
              "top": 0,
              "left": 608,
              "width": 304,
              "height": 304
            },
            "queries": [
              {
                "id": "A",
                "metric": "builtin:service.response.time",
                "spaceAggregation": "PERCENTILE",
                "percentile": 95,
                "timeAggregation": "DEFAULT",
                "splitBy": ["dt.entity.service"]
              }
            ]
          }
        ]
      }
```
      
      ### Template 2: Kubernetes Dashboard
```json
      {
        "dashboardMetadata": {
          "name": "Kubernetes Cluster Overview",
          "shared": true
        },
        "tiles": [
          {
            "name": "Cluster Health",
            "tileType": "DATA_EXPLORER",
            "queries": [
              {
                "id": "A",
                "metric": "builtin:kubernetes.cluster.memory.available",
                "splitBy": ["dt.entity.kubernetes_cluster"]
              }
            ]
          },
          {
            "name": "Pod Status",
            "tileType": "DATA_EXPLORER",
            "queries": [
              {
                "id": "A",
                "metric": "builtin:kubernetes.pods",
                "splitBy": ["phase"]
              }
            ]
          },
          {
            "name": "Node CPU",
            "tileType": "DATA_EXPLORER",
            "queries": [
              {
                "id": "A",
                "metric": "builtin:kubernetes.node.cpu.usage",
                "splitBy": ["dt.entity.kubernetes_node"]
              }
            ]
          }
        ]
      }
```
      
      ## Monaco Configuration
```yaml
      # projects/default/dashboards/config.yaml
      config:
        - red-metrics:
            - name: "RED Metrics - {{ .Env.SERVICE_NAME }}"
          
        - kubernetes-overview:
            - name: "K8s Cluster - {{ .Env.CLUSTER_NAME }}"
      
      red-metrics:
        - name: "{{ .name }}"
          template: red-metrics.json
          skip: false
      
      kubernetes-overview:
        - name: "{{ .name }}"
          template: kubernetes-dashboard.json
          skip: false
```
      
      ## Deploy Dashboard
```bash
      # Deploy to development
      SERVICE_NAME="payment-service" \
        monaco deploy --environments environments.yaml manifest.yaml development
      
      # Deploy to all environments
      monaco deploy --environments environments.yaml manifest.yaml
```
      
      Generate dashboard JSON and Monaco configuration.

  - id: dtctl-create-notebook
    content: |
      Create Dynatrace notebook for analysis and documentation.
      
      Notebook templates:
      1. Incident Analysis - Root cause investigation
      2. Performance Investigation - Deep dive into latency
      3. Security Analysis - Security event correlation
      4. Capacity Planning - Resource trend analysis
      
      Sections include:
      - Markdown documentation
      - Data Explorer queries
      - Log queries
      - Distributed traces
      - Code blocks (DQL)
      - User input parameters
      
      Generate notebook JSON with interactive sections.

  - id: dtctl-run-query
    content: |
      Execute DQL (Dynatrace Query Language) queries for advanced observability.
      
      ## DQL Query Examples
      
      ### Query Logs
```dql
      fetch logs
      | filter status == "ERROR"
      | filter timestamp >= now() - 1h
      | summarize count(), by: {service.name}
      | sort count desc
      | limit 10
```
      
      ### Query Metrics
```dql
      fetch dt.metrics
      | filter metric.key == "builtin:service.response.time"
      | filter dt.entity.service == "SERVICE-123"
      | summarize avg(metric.value), by: {1h}
```
      
      ### Query Spans
```dql
      fetch spans
      | filter span.name == "POST /api/checkout"
      | filter duration > 1s
      | summarize p95 = percentile(duration, 95), by: {span.name}
```
      
      ### Complex Join Query
```dql
      fetch logs
      | filter status == "ERROR"
      | join [
          fetch spans
          | filter span.kind == "SERVER"
        ], on: trace.id == trace_id
      | summarize error_count = count(), by: {service.name, span.name}
```
      
      Execute query via API and format results.

  - id: dtctl-configure-alerting
    content: |
      Configure Dynatrace alerting, SLOs, and problem notifications.
      
      ## Components
      
      1. Management Zones - Organize monitoring scope
      2. Alerting Profiles - Route alerts to teams
      3. Custom Metric Events - Define alert conditions
      4. SLO Configuration - Service level objectives
      5. Problem Notifications - Slack, PagerDuty, email
      
      ## SLO Example
```json
      {
        "name": "Payment Service Availability",
        "enabled": true,
        "target": 99.9,
        "warning": 99.95,
        "errorBudgetBurnRate": {
          "fastBurnThreshold": 10
        },
        "evaluationType": "AGGREGATE",
        "filter": "type(SERVICE),tag(\"app:payment\")",
        "metricExpression": "(builtin:service.errors.total.count:splitBy())/(builtin:service.request.count:splitBy())*100",
        "evaluationWindow": "-1w"
      }
```
      
      Generate complete alerting and SLO configuration.

  - id: dtctl-export-config
    content: |
      Export Dynatrace configuration as code using Monaco.
      
      Export all configuration types:
      - Dashboards
      - Notebooks  
      - Alerting profiles
      - Management zones
      - SLOs
      - Synthetic monitors
      - Workflows
      - Auto-tags
```bash
      # Download all configuration
      monaco download \
        --environment-url "https://abc12345.live.dynatrace.com" \
        --token "$DT_TOKEN" \
        --output-folder ./backup-$(date +%Y%m%d)
      
      # Convert to parameterized Monaco config
      monaco convert \
        --source ./backup-20250117 \
        --target ./dynatrace-config/projects/default
```
      
      Generate backup and version control workflow.

  - id: dtctl-validate-config
    content: |
      Validate Dynatrace configuration before deployment.
      
      Validation steps:
      1. Monaco dry-run deployment
      2. JSON schema validation
      3. Lint for common issues (hardcoded values, deprecated APIs)
      4. Pre-deployment checks (connectivity, token permissions)
      5. CI/CD validation pipeline
```bash
      # Validate configuration
      monaco deploy --dry-run --environments environments.yaml manifest.yaml
      
      # Check for issues
      - Hardcoded environment URLs
      - Missing required fields
      - Deprecated metric keys
      - Invalid DQL syntax
```
      
      Generate validation report with actionable fixes.

  - id: dtctl-synthetic-monitoring
    content: |
      Configure Dynatrace synthetic monitors for proactive monitoring.
      
      Monitor types:
      
      1. HTTP Monitors - API health checks
      2. Browser Monitors - Multi-step user journeys
      3. Location Selection - Global monitoring points
      
      ## HTTP Monitor Example
```json
      {
        "name": "API Health Check",
        "enabled": true,
        "type": "HTTP",
        "script": {
          "version": "1.0",
          "requests": [
            {
              "description": "Check API endpoint",
              "url": "https://api.example.com/health",
              "method": "GET",
              "validation": {
                "rules": [
                  {
                    "type": "httpStatusesList",
                    "acceptedValues": [200],
                    "passIfFound": true
                  }
                ]
              }
            }
          ]
        },
        "locations": ["GEOLOCATION-1", "GEOLOCATION-2"],
        "frequency": 5,
        "anomalyDetection": {
          "outageHandling": {
            "globalOutage": true,
            "localOutage": false
          },
          "loadingTimeThresholds": {
            "enabled": true,
            "thresholds": [
              {
                "type": "TOTAL",
                "valueMs": 1000
              }
            ]
          }
        }
      }
```
      
      Generate synthetic monitoring configuration with alerting.

YAML_EOF

echo "✅ Part 7 (Dynatrace Prompts) appended successfully!"
echo ""
echo "Part 7 includes:"
echo "  - dtctl-setup"
echo "  - dtctl-create-dashboard"
echo "  - dtctl-create-notebook"
echo "  - dtctl-run-query"
echo "  - dtctl-configure-alerting"
echo "  - dtctl-export-config"
echo "  - dtctl-validate-config"
echo "  - dtctl-synthetic-monitoring"

