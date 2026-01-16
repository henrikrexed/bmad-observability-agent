#!/bin/bash

# Script to append Part 6 (OCB Prompts) to the agent file
# This adds all OpenTelemetry Collector Builder prompts

AGENT_FILE="agent/o11y-engineer.agent.yaml"

# Check if agent file exists
if [ ! -f "$AGENT_FILE" ]; then
    echo "Error: $AGENT_FILE not found"
    echo "Please run this script from the repository root"
    exit 1
fi

echo "Appending Part 6 (OCB Prompts) to $AGENT_FILE..."

# Append Part 6 content
cat >> "$AGENT_FILE" << 'YAML_EOF'
  # ═══════════════════════════════════════════════════════
  # OPENTELEMETRY COLLECTOR BUILDER (OCB) PROMPTS
  # ═══════════════════════════════════════════════════════

  - id: ocb-add-component
    content: |
      Add receiver/processor/exporter/extension to OpenTelemetry Collector Builder manifest.
      
      ## Component Categories
      
      ### Receivers (Data Input)
      
      **Popular Receivers:**
      - `otlpreceiver` - OTLP protocol (gRPC + HTTP)
      - `prometheusreceiver` - Scrape Prometheus metrics
      - `jaegerreceiver` - Jaeger traces
      - `zipkinreceiver` - Zipkin traces
      - `kafkareceiver` - Consume from Kafka
      - `filelogreceiver` - Read log files
      - `hostmetricsreceiver` - Host system metrics
      - `k8sclusterreceiver` - Kubernetes cluster metrics
      - `kubeletstatsreceiver` - Kubelet metrics
      - `prometheusremotewritereceiver` - Prometheus remote write
      
      **Database Receivers:**
      - `postgresqlreceiver` - PostgreSQL metrics
      - `mysqlreceiver` - MySQL metrics
      - `mongodbreceiver` - MongoDB metrics
      - `redisreceiver` - Redis metrics
      
      **Infrastructure Receivers:**
      - `dockerstatsreceiver` - Docker container stats
      - `awscontainerinsightsreceiver` - ECS/EKS insights
      - `nginxreceiver` - NGINX metrics
      - `apachereceiver` - Apache metrics
      
      ### Processors (Data Transformation)
      
      **Essential Processors:**
      - `batchprocessor` - Batch data for performance
      - `memorylimiterprocessor` - Prevent OOM
      - `resourceprocessor` - Add/modify resource attributes
      - `attributesprocessor` - Add/modify/delete attributes
      - `filterprocessor` - Filter telemetry data
      - `transformprocessor` - OTTL transformations
      
      **Advanced Processors:**
      - `tailsamplingprocessor` - Intelligent sampling
      - `probabilisticsamplerprocessor` - Head-based sampling
      - `spanprocessor` - Modify span attributes
      - `metricstransformprocessor` - Transform metrics
      - `k8sattributesprocessor` - Add K8s metadata
      - `resourcedetectionprocessor` - Detect cloud metadata
      - `spanmetricsprocessor` - Generate metrics from spans
      - `servicegraphprocessor` - Build service graphs
      
      ### Exporters (Data Output)
      
      **OTLP Exporters:**
      - `otlpexporter` - OTLP gRPC
      - `otlphttpexporter` - OTLP HTTP
      
      **Metrics Exporters:**
      - `prometheusexporter` - Prometheus exposition
      - `prometheusremotewriteexporter` - Prometheus remote write
      
      **Traces Exporters:**
      - `jaegerexporter` - Jaeger
      - `zipkinexporter` - Zipkin
      
      **Logs Exporters:**
      - `lokiexporter` - Grafana Loki
      - `elasticsearchexporter` - Elasticsearch
      
      **Vendor Exporters:**
      - `datadogexporter` - Datadog
      - `newrelicexporter` - New Relic
      - `honeycombexporter` - Honeycomb
      - `awsxrayexporter` - AWS X-Ray
      - `googlecloudexporter` - Google Cloud
      - `azuremonitorexporter` - Azure Monitor
      
      **Other Exporters:**
      - `fileexporter` - Export to file
      - `kafkaexporter` - Send to Kafka
      - `loadbalancingexporter` - Load balance across backends
      
      ### Extensions (Extra Functionality)
      
      - `healthcheckextension` - Health check endpoint
      - `pprofextension` - Performance profiling
      - `zpagesextension` - Debugging pages
      - `filestorage` - Persistent storage
      - `bearertokenauthextension` - Bearer token auth
      - `oauth2clientauthextension` - OAuth2 auth
      - `headerssetterextension` - Set HTTP headers
      
      ## Adding Components to Manifest
      
      ### Step 1: Locate Component
```bash
      # Search for component in contrib
      # Format: github.com/open-telemetry/opentelemetry-collector-contrib/<type>/<name>
      
      # Example component paths:
      # Receiver: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/prometheusreceiver
      # Processor: github.com/open-telemetry/opentelemetry-collector-contrib/processor/tailsamplingprocessor
      # Exporter: github.com/open-telemetry/opentelemetry-collector-contrib/exporter/datadogexporter
```
      
      ### Step 2: Find Version
```bash
      # Check latest version
      go list -m -versions github.com/open-telemetry/opentelemetry-collector-contrib/receiver/prometheusreceiver
      
      # Or use same version as collector core
      COLLECTOR_VERSION="v0.93.0"
```
      
      ### Step 3: Add to Manifest
```yaml
      # builder-config.yaml
      dist:
        name: otelcol-custom
        description: Custom OpenTelemetry Collector
        output_path: ./dist
        otelcol_version: 0.93.0
      
      receivers:
        # Core receiver (always include)
        - gomod: go.opentelemetry.io/collector/receiver/otlpreceiver v0.93.0
        
        # Add Prometheus receiver
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/prometheusreceiver v0.93.0
        
        # Add Jaeger receiver
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/jaegerreceiver v0.93.0
        
        # Add Kafka receiver
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/kafkareceiver v0.93.0
      
      processors:
        # Core processors
        - gomod: go.opentelemetry.io/collector/processor/batchprocessor v0.93.0
        - gomod: go.opentelemetry.io/collector/processor/memorylimiterprocessor v0.93.0
        
        # Add tail sampling
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/processor/tailsamplingprocessor v0.93.0
        
        # Add K8s attributes
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/processor/k8sattributesprocessor v0.93.0
        
        # Add transform processor
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/processor/transformprocessor v0.93.0
      
      exporters:
        # Core exporter
        - gomod: go.opentelemetry.io/collector/exporter/otlpexporter v0.93.0
        
        # Add Prometheus exporter
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/exporter/prometheusexporter v0.93.0
        
        # Add Datadog exporter
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/exporter/datadogexporter v0.93.0
      
      extensions:
        # Add health check
        - gomod: go.opentelemetry.io/collector/extension/healthcheckextension v0.93.0
        
        # Add pprof
        - gomod: go.opentelemetry.io/collector/extension/pprofextension v0.93.0
        
        # Add file storage
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/extension/storage/filestorage v0.93.0
```
      
      ### Step 4: Add Custom Components
      
      For your own custom receivers/processors/exporters:
```yaml
      receivers:
        # ... other receivers ...
        
        # Custom receiver (local development)
        - gomod: github.com/mycompany/myreceiver v1.0.0
          path: /path/to/local/myreceiver  # Optional: use local copy
      
      # OR use replace directive
      replaces:
        - github.com/mycompany/myreceiver => /path/to/local/myreceiver
```
      
      ### Step 5: Validate Manifest
```bash
      # Validate before building
      builder --config builder-config.yaml --skip-compilation
      
      # Check for version conflicts
      go list -m all
```
      
      ## Common Component Combinations
      
      ### Kubernetes Monitoring
```yaml
      receivers:
        - gomod: go.opentelemetry.io/collector/receiver/otlpreceiver v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/k8sclusterreceiver v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/kubeletstatsreceiver v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/k8seventsreceiver v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/filelogreceiver v0.93.0
      
      processors:
        - gomod: go.opentelemetry.io/collector/processor/batchprocessor v0.93.0
        - gomod: go.opentelemetry.io/collector/processor/memorylimiterprocessor v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/processor/k8sattributesprocessor v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/processor/resourcedetectionprocessor v0.93.0
```
      
      ### Database Monitoring
```yaml
      receivers:
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/postgresqlreceiver v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/mysqlreceiver v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/mongodbreceiver v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/redisreceiver v0.93.0
```
      
      ### Multi-Backend Export
```yaml
      exporters:
        - gomod: go.opentelemetry.io/collector/exporter/otlpexporter v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/exporter/prometheusremotewriteexporter v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/exporter/lokiexporter v0.93.0
        - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/exporter/datadogexporter v0.93.0
```
      
      Generate component selection and manifest configuration.

  - id: ocb-list-components
    content: |
      List all available OpenTelemetry Collector Contrib components with descriptions.
      
      Provide comprehensive catalog of receivers, processors, exporters, and extensions
      with use cases, protocols, and configuration examples.
      
      See full implementation in ocb-add-component prompt for complete component list.

  - id: ocb-validate-manifest
    content: |
      Validate OpenTelemetry Collector Builder manifest configuration.
      
      Run comprehensive validation checks:
      1. YAML syntax validation
      2. Required fields check
      3. Version compatibility verification
      4. Component existence validation
      5. Duplicate detection
      6. Dependency conflict checks
      7. Platform-specific component validation
      8. Security vulnerability scanning
      9. Size estimation
      10. Complete validation script execution
      
      Generate validation report with pass/fail status for each check.

  - id: ocb-build-binary
    content: |
      Build custom OpenTelemetry Collector as standalone binary using OCB.
      
      Complete build workflow:
      1. Install OCB
      2. Create optimized builder configuration
      3. Build for current platform
      4. Cross-compile for multiple platforms (Linux, macOS, Windows, ARM)
      5. Apply build optimizations (static linking, size reduction)
      6. Package releases with documentation
      7. Set up CI/CD for automated builds
      8. Deploy to production (systemd, Docker)
      
      Generate binaries for all target platforms with release packaging.

  - id: ocb-build-image
    content: |
      Build custom OpenTelemetry Collector as container image.
      
      Multi-stage Docker build strategies:
      1. Optimized multi-stage Dockerfile (Alpine, Distroless, Scratch)
      2. BuildKit with cache optimization
      3. Multi-architecture builds (amd64, arm64)
      4. Layer caching for faster builds
      5. Image testing and vulnerability scanning
      6. Docker Compose deployment
      7. Kubernetes deployment manifests
      8. CI/CD with GitHub Actions
      
      Image size comparison:
      - Alpine: ~50 MB
      - Distroless: ~35 MB  
      - Scratch: ~30 MB
      
      Generate complete container build and deployment workflow.

  - id: ocb-optimize-build
    content: |
      Optimize OpenTelemetry Collector build for size and performance.
      
      Size optimization strategies:
      1. Minimize components (only include what's needed)
      2. Build flags optimization (-s -w ldflags)
      3. UPX compression (~70% reduction)
      4. Multi-stage Docker builds
      
      Performance optimization:
      1. Memory ballast configuration
      2. Batch processor tuning
      3. Queue sizing for throughput
      4. Compression strategy selection
      
      Results:
      - Default build: 150 MB
      - Optimized: 65 MB (57% reduction)
      - With UPX: 28 MB (81% reduction)
      - Container (Distroless): 35 MB
      
      Generate optimization guide with benchmarks and trade-off analysis.

  - id: ocb-version-comparison
    content: |
      Compare OpenTelemetry Collector component versions and track changes.
      
      Version management workflow:
      1. List current component versions
      2. Check for available updates
      3. Generate upgrade plan
      4. Compare two configurations (diff)
      5. Track breaking changes from release notes
      6. Generate version compatibility matrix
      7. Automated update PRs via GitHub Actions
      
      Provides detailed comparison showing:
      - Added components
      - Removed components
      - Updated versions (old → new)
      - Unchanged components
      
      Generate complete version tracking and upgrade automation.

YAML_EOF

echo "✅ Part 6 (OCB Prompts) appended successfully!"
echo ""
echo "Part 6 includes:"
echo "  - ocb-add-component"
echo "  - ocb-list-components"
echo "  - ocb-validate-manifest"
echo "  - ocb-build-binary"
echo "  - ocb-build-image"
echo "  - ocb-optimize-build"
echo "  - ocb-version-comparison"

