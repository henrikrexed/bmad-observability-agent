#!/bin/bash

# Create all workflow files for B-MAD Observability Agent

set -e

WORKFLOWS_DIR="workflows"

echo "Creating all workflow files in $WORKFLOWS_DIR..."
echo ""

mkdir -p "$WORKFLOWS_DIR"

# We already have:
# - observability-quick-start.yaml
# - assess-observability-maturity.yaml

# Now create the remaining workflows

echo "✅ observability-quick-start.yaml (already created)"
echo "✅ assess-observability-maturity.yaml (already created)"

# The remaining workflows will be simpler/shorter
# Create placeholder workflows that reference the prompts

cat > "$WORKFLOWS_DIR/configure-collector-pipeline.yaml" << 'EOF'
name: Configure Collector Pipeline
version: 1.0.0
description: Design and configure OpenTelemetry Collector pipeline

steps:
  - step: gather-requirements
    ask: |
      Let's configure your OpenTelemetry Collector pipeline!
      
      1. **What data sources do you have?**
         - OTLP (from applications)
         - Prometheus metrics (scraping)
         - Jaeger traces
         - Log files
         - Other (specify)
      
      2. **What processing do you need?**
         - Add resource attributes (environment, region, etc.)
         - Filter/drop data
         - Transform attributes
         - Sampling
         - Enrichment (K8s metadata, etc.)
      
      3. **Where should data go?**
         - Backend(s): Dynatrace, Datadog, Jaeger, Prometheus, etc.
         - Protocols: OTLP, Prometheus Remote Write, etc.
      
      4. **Deployment environment?**
         - Kubernetes
         - Docker
         - VM
         - Bare metal
    
    save_to: requirements

  - step: design-pipeline
    prompt: |
      Design complete collector pipeline based on:
      
      {{requirements}}
      
      Generate collector configuration with:
      
      1. **Receivers** - Data input
      2. **Processors** - Data transformation (always include batch + memory_limiter)
      3. **Exporters** - Data output
      4. **Extensions** - Health check, pprof, etc.
      5. **Service pipelines** - Connect receivers → processors → exporters
      
      Include resource limits, health checks, and best practices.
      Provide both YAML config and deployment manifests (K8s/Docker).
    
    save_to: collector_config

  - step: validate-config
    prompt: |
      Validate the collector configuration:
      
      {{collector_config}}
      
      Check for:
      - Syntax errors
      - Missing required processors (memory_limiter, batch)
      - Inappropriate configurations
      - Security issues
      - Performance concerns
      
      Provide validation report and corrected configuration if needed.

EOF

cat > "$WORKFLOWS_DIR/validate-observability.yaml" << 'EOF'
name: Validate Observability Setup
version: 1.0.0
description: Validate observability against vendor requirements and best practices

steps:
  - step: select-vendor
    ask: |
      Which observability vendor are you validating against?
      
      - Dynatrace
      - Datadog
      - New Relic
      - Grafana Cloud
      - AWS X-Ray
      - Google Cloud Operations
      - Azure Monitor
      - Custom/Self-hosted
    
    save_to: vendor

  - step: run-validation
    prompt: |
      Run comprehensive validation for {{vendor}}:
      
      Execute: #vendor-compatibility
      
      Check:
      1. Required attributes present
      2. Correct data format
      3. Authentication configured
      4. Network connectivity
      5. Data flowing correctly
      6. Vendor-specific requirements
      
      Generate validation report with pass/fail for each check.
    
    save_to: validation_results

  - step: remediation
    prompt: |
      Based on validation results:
      
      {{validation_results}}
      
      For each failed check, provide:
      - What's wrong
      - How to fix it
      - Configuration example
      - Verification steps
      
      Generate remediation plan.

EOF

cat > "$WORKFLOWS_DIR/validate-semantic-conventions.yaml" << 'EOF'
name: Validate Semantic Conventions
version: 1.0.0
description: Validate telemetry data against OpenTelemetry semantic conventions using Weaver

steps:
  - step: export-telemetry
    prompt: |
      Export sample telemetry data from your applications for validation.
      
      Methods:
      1. From Jaeger: Export traces as JSON
      2. From collector: Add file exporter temporarily
      3. From backend API: Download recent data
      
      Provide export commands based on your setup.
    
    save_to: export_method

  - step: validate-with-weaver
    prompt: |
      Execute Weaver validation:
```bash
      weaver registry validate \
        --registry=./semconv/registry \
        --telemetry=./exported-telemetry.json \
        --output=validation-report.json
```
      
      Parse results and generate compliance report showing:
      - Compliance rate (%)
      - Missing required attributes
      - Incorrect attribute types
      - Non-standard attributes
      - Deprecated attributes
      
      Target: 95%+ compliance for production readiness.
    
    save_to: validation_report

  - step: generate-fixes
    prompt: |
      Based on violations found:
      
      {{validation_report}}
      
      Generate specific code fixes for each violation type:
      - Add missing attributes
      - Fix attribute types
      - Replace deprecated attributes
      - Standardize custom attributes
      
      Provide language-specific code examples (Go, Python, Java, etc.).

EOF

cat > "$WORKFLOWS_DIR/create-custom-semconv.yaml" << 'EOF'
name: Create Custom Semantic Conventions
version: 1.0.0
description: Create custom semantic conventions using Weaver schema format

steps:
  - step: define-namespace
    ask: |
      Let's create custom semantic conventions!
      
      1. **What's your namespace?**
         Example: mycompany, myproduct, feature-name
         This prevents conflicts with standard conventions.
      
      2. **What type of data are you instrumenting?**
         - Business transactions
         - Domain-specific metrics
         - Custom events
         - Application-specific attributes
      
      3. **What attributes do you need?**
         List attributes with:
         - Name
         - Type (string, int, double, boolean)
         - Description
         - Examples
         - Required or optional
    
    save_to: custom_requirements

  - step: create-schema
    prompt: |
      Create Weaver schema definition for:
      
      {{custom_requirements}}
      
      Generate complete schema YAML files with:
      - Proper namespace
      - Attribute definitions
      - Type specifications
      - Documentation
      - Examples
      - Requirement levels
      
      Follow OpenTelemetry schema format exactly.
    
    save_to: schema_files

  - step: generate-code
    prompt: |
      Generate type-safe instrumentation code from schemas:
      
      {{schema_files}}
      
      Create code for these languages:
      - Go
      - Python
      - Java
      - TypeScript
      
      Include:
      - Constants for attribute keys
      - Helper functions
      - Type definitions
      - Usage examples
    
    save_to: generated_code

  - step: create-docs
    prompt: |
      Generate documentation from schemas:
      
      {{schema_files}}
      
      Create:
      - Markdown reference docs
      - HTML documentation site
      - Migration guides
      - Usage examples
      
      Using Weaver docs generation.

EOF

cat > "$WORKFLOWS_DIR/build-collector-distro.yaml" << 'EOF'
name: Build Collector Distribution
version: 1.0.0
description: Build custom OpenTelemetry Collector distribution using OCB

steps:
  - step: select-components
    ask: |
      Which components do you need in your custom collector?
      
      **Receivers** (select all that apply):
      - OTLP (required)
      - Prometheus
      - Jaeger
      - Kafka
      - Kubernetes (k8scluster, kubeletstats)
      - Host metrics
      - File logs
      - Database (PostgreSQL, MySQL, MongoDB, Redis)
      - Other (specify)
      
      **Processors** (select all that apply):
      - Batch (required)
      - Memory Limiter (required)
      - Tail Sampling
      - K8s Attributes
      - Resource Detection
      - Transform
      - Filter
      - Other (specify)
      
      **Exporters** (select all that apply):
      - OTLP (required)
      - Prometheus
      - Prometheus Remote Write
      - Jaeger
      - Datadog
      - Dynatrace
      - Loki
      - Other (specify)
    
    save_to: component_selection

  - step: generate-manifest
    prompt: |
      Generate OCB builder manifest for:
      
      {{component_selection}}
      
      Create builder-config.yaml with:
      - Correct component versions
      - All selected components
      - Optimization flags (-s -w)
      - Static linking options
      
      Include version: v0.93.0 (or latest)
    
    save_to: ocb_manifest

  - step: build-options
    ask: |
      How would you like to build?
      
      1. **Platforms** (select all):
         - Linux AMD64
         - Linux ARM64
         - macOS AMD64 (Intel)
         - macOS ARM64 (Apple Silicon)
         - Windows AMD64
      
      2. **Output format**:
         - Binary only
         - Container image (Docker)
         - Both
      
      3. **Optimizations**:
         - Size optimization (UPX compression)
         - Multi-arch image
    
    save_to: build_options

  - step: execute-build
    prompt: |
      Execute build with:
      
      Manifest: {{ocb_manifest}}
      Options: {{build_options}}
      
      Generate:
      1. Build commands for all selected platforms
      2. Dockerfile for container image
      3. CI/CD pipeline (GitHub Actions)
      4. Testing procedure
      5. Deployment manifests (K8s)
      
      Provide complete build and deployment workflow.

EOF

cat > "$WORKFLOWS_DIR/setup-dynatrace.yaml" << 'EOF'
name: Setup Dynatrace
version: 1.0.0
description: Configure Dynatrace integration using Monaco

steps:
  - step: install-monaco
    prompt: |
      Install Dynatrace Monaco (configuration as code tool):
      
      # macOS
      brew install dynatrace/dynatrace/monaco
      
      # Linux
      wget https://github.com/dynatrace/dynatrace-configuration-as-code/releases/latest/download/monaco-linux-amd64
      chmod +x monaco-linux-amd64
      sudo mv monaco-linux-amd64 /usr/local/bin/monaco
      
      # Verify
      monaco version
      
      Provide installation commands for user's OS.

  - step: configure-environments
    ask: |
      Dynatrace environment details:
      
      **Development:**
      - Environment URL: https://[your-id].live.dynatrace.com
      - API Token: (will be set as env var DT_DEV_TOKEN)
      
      **Staging:**
      - Environment URL:
      - API Token: (env var DT_STAGING_TOKEN)
      
      **Production:**
      - Environment URL:
      - API Token: (env var DT_PROD_TOKEN)
      
      Required token scopes:
      - Read/Write configuration
      - Read/Write settings
      - Read/Write SLO
    
    save_to: dt_environments

  - step: create-project-structure
    prompt: |
      Create Monaco project structure with:
      
      {{dt_environments}}
      
      Generate:
      1. environments.yaml
      2. manifest.yaml
      3. Project directories:
         - dashboards/
         - notebooks/
         - workflows/
         - alerting/
         - synthetic/
         - management-zones/
      
      Provide complete directory structure and config files.

EOF

cat > "$WORKFLOWS_DIR/create-dynatrace-dashboard.yaml" << 'EOF'
name: Create Dynatrace Dashboard
version: 1.0.0
description: Create Dynatrace dashboard using Monaco

steps:
  - step: choose-template
    ask: |
      What type of dashboard do you want to create?
      
      1. **RED Metrics** - Rate, Errors, Duration for services
      2. **Kubernetes Overview** - Cluster health, pod status, resources
      3. **Database Performance** - Query duration, connections, errors
      4. **Infrastructure** - Host CPU, memory, disk, network
      5. **SLO Tracking** - Error budget, compliance over time
      6. **Custom** - Build from scratch
    
    save_to: dashboard_type

  - step: gather-details
    ask: |
      Dashboard details:
      
      - Name:
      - Owner:
      - Timeframe: (Last hour, Last day, Last week)
      - Management Zone: (optional, for filtering)
      - Sharing: (Private or Team)
    
    save_to: dashboard_details

  - step: define-tiles
    ask: |
      What tiles/widgets should be included?
      
      For each tile specify:
      - Title
      - Type: (Graph, Pie Chart, Table, Single Value)
      - Metric(s): (e.g., builtin:service.response.time)
      - Filters
      - Visualization preferences
    
    save_to: tile_definitions

  - step: generate-dashboard
    prompt: |
      Generate dashboard JSON for:
      
      Type: {{dashboard_type}}
      Details: {{dashboard_details}}
      Tiles: {{tile_definitions}}
      
      Create complete dashboard JSON and Monaco configuration.
      Provide deployment commands.

EOF

cat > "$WORKFLOWS_DIR/create-dynatrace-workflow.yaml" << 'EOF'
name: Create Dynatrace Workflow
version: 1.0.0
description: Create Dynatrace workflow for automation

steps:
  - step: choose-workflow-type
    ask: |
      What type of workflow do you need?
      
      1. **Auto-Remediation**
         - Restart failing pods
         - Scale up overloaded services
         - Clear caches
         - Rollback deployments
      
      2. **Incident Response**
         - Create tickets (Jira, ServiceNow)
         - Notify teams (Slack, PagerDuty)
         - Create war rooms
         - Gather diagnostics
      
      3. **Scheduled Reports**
         - Daily SLO compliance
         - Weekly performance reports
         - Cost analysis
      
      4. **Deployment Validation**
         - Post-deployment health checks
         - Performance validation
         - Auto-rollback on issues
      
      5. **Security Response**
         - Block malicious IPs
         - Rotate credentials
         - Isolate services
    
    save_to: workflow_type

  - step: define-trigger
    ask: |
      How should this workflow be triggered?
      
      **Event-based:**
      - Problem detected
      - Anomaly detected
      - Threshold exceeded
      - Deployment event
      
      **Schedule-based:**
      - Daily at X time
      - Weekly on X day
      - Every X hours
      
      **Manual:**
      - On-demand execution
    
    save_to: trigger_config

  - step: design-workflow
    ask: |
      Define workflow tasks (in order):
      
      Available task types:
      - JavaScript code
      - DQL query
      - HTTP request
      - Send Slack message
      - Create Jira ticket
      - Call PagerDuty
      - Update ServiceNow
      - Run kubectl command
      
      For each task provide:
      - Task name
      - Type
      - Configuration/code
      - Error handling
    
    save_to: workflow_tasks

  - step: generate-workflow
    prompt: |
      Generate Dynatrace workflow JSON for:
      
      Type: {{workflow_type}}
      Trigger: {{trigger_config}}
      Tasks: {{workflow_tasks}}
      
      Include:
      - Complete workflow definition
      - Error handling
      - Retry logic
      - Notifications
      - Monaco configuration
      - Testing procedure

EOF

echo "✅ configure-collector-pipeline.yaml"
echo "✅ validate-observability.yaml"
echo "✅ validate-semantic-conventions.yaml"
echo "✅ create-custom-semconv.yaml"
echo "✅ build-collector-distro.yaml"
echo "✅ setup-dynatrace.yaml"
echo "✅ create-dynatrace-dashboard.yaml"
echo "✅ create-dynatrace-workflow.yaml"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All workflow files created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total workflows: 10"
echo "Location: $WORKFLOWS_DIR/"
echo ""
echo "Next: Review and customize workflows as needed"

