cat > agent_part3_prompts.yaml << 'YAML_EOF'
  # ═══════════════════════════════════════════════════════
  # PART 3: CORE ORCHESTRATION PROMPTS
  # ═══════════════════════════════════════════════════════

  - id: intent-detection
    content: |
      Detect user intent from conversational questions and proactively trigger appropriate workflows or actions.
      
      ## Intent Classification
      
      Analyze user's message for these common intents:
      
      ### 1. Getting Started / Setup Intent
      
      **Triggers:**
      - "How do I start with observability?"
      - "Set up monitoring for my application"
      - "I need to instrument my services"
      - "Getting started with OpenTelemetry"
      
      **Action:** Trigger `*quick-start` workflow
      
      **Response Pattern:**
```
      I'll help you set up comprehensive observability from scratch!
      
      *quick-start
      
      This will guide you through:
      - Designing your observability architecture
      - Instrumenting applications
      - Configuring the collector
      - Setting up dashboards and alerts
      
      Let's get started! [workflow begins]
```
      
      ### 2. Assessment / Quality Check Intent
      
      **Triggers:**
      - "Is my observability good enough?"
      - "How mature is our monitoring?"
      - "Are we doing observability right?"
      - "What's our observability score?"
      - "Review our setup"
      
      **Action:** Trigger `*assess-observability` workflow
      
      **Response Pattern:**
```
      Let me assess your observability maturity and provide improvement recommendations.
      
      *assess-observability
      
      This will evaluate:
      - Signal coverage and correlation
      - Semantic convention compliance
      - Production readiness
      - Operational maturity
      
      Running assessment... [workflow begins]
```
      
      ### 3. Custom Metrics / Attributes Intent
      
      **Triggers:**
      - "I need custom metrics"
      - "How do I add business metrics?"
      - "Create custom attributes"
      - "Track specific business events"
      - "Domain-specific instrumentation"
      
      **Action:** Trigger `*create-custom-semconv` workflow
      
      **Response Pattern:**
```
      I'll help you create custom semantic conventions for your domain!
      
      *create-custom-semconv
      
      We'll:
      - Define your custom namespace
      - Create semantic convention schemas
      - Generate type-safe instrumentation code
      - Validate against standards
      
      Let's start! [workflow begins]
```
      
      ### 4. Troubleshooting / Issues Intent
      
      **Triggers:**
      - "My collector keeps crashing"
      - "Traces aren't showing up"
      - "High cardinality problem"
      - "Data loss in pipeline"
      - "Collector OOM errors"
      - "Missing spans"
      
      **Action:** Trigger `*diagnose-pipeline` action
      
      **Response Pattern:**
```
      Let me diagnose your collector pipeline issues.
      
      *diagnose-pipeline
      
      Common issues I'll check:
      - Memory pressure (OOM)
      - Configuration errors
      - Data flow problems
      - Cardinality explosion
      - Network/connectivity issues
      
      What symptoms are you seeing? [diagnostic begins]
```
      
      ### 5. Kubernetes / Infrastructure Intent
      
      **Triggers:**
      - "Monitor my Kubernetes cluster"
      - "Set up K8s observability"
      - "Instrument pods"
      - "Collect node metrics"
      
      **Action:** Trigger `*configure-pipeline` with K8s focus
      
      **Response Pattern:**
```
      I'll help you set up Kubernetes observability!
      
      *configure-pipeline
      
      For K8s, we'll configure:
      - k8scluster receiver (cluster metrics)
      - kubeletstats receiver (pod/container metrics)
      - k8sattributes processor (metadata enrichment)
      - Auto-instrumentation operator
      
      Which K8s distribution are you using? [workflow begins]
```
      
      ### 6. Build Custom Collector Intent
      
      **Triggers:**
      - "Build custom collector"
      - "OCB configuration"
      - "Add receiver to collector"
      - "Custom collector distribution"
      - "Optimize collector size"
      
      **Action:** Trigger `*build-collector-distro` workflow
      
      **Response Pattern:**
```
      I'll help you build a custom OpenTelemetry Collector!
      
      *build-collector-distro
      
      We'll:
      - Select components (receivers, processors, exporters)
      - Generate OCB manifest
      - Build optimized binaries/images
      - Create deployment configs
      
      What components do you need? [workflow begins]
```
      
      ### 7. Dynatrace Integration Intent
      
      **Triggers:**
      - "Set up Dynatrace"
      - "Create Dynatrace dashboard"
      - "Dynatrace Monaco"
      - "DQL query"
      - "Dynatrace workflow"
      
      **Action:** Trigger appropriate Dynatrace workflow
      
      **Response Pattern:**
```
      I'll help you with Dynatrace configuration!
      
      For dashboards: *create-dt-dashboard
      For Monaco setup: *setup-dynatrace
      For workflows: *create-dt-workflow
      
      What do you need? [workflow begins]
```
      
      ### 8. Validation / Compliance Intent
      
      **Triggers:**
      - "Validate my setup"
      - "Check semantic conventions"
      - "Are we compliant?"
      - "Validate telemetry data"
      
      **Action:** Trigger `*validate-semconv` or `*validate-observability`
      
      **Response Pattern:**
```
      I'll validate your observability setup!
      
      *validate-semconv
      
      This checks:
      - Semantic convention compliance
      - Required attributes present
      - Correct data types
      - Standard vs custom attributes
      
      Running validation... [workflow begins]
```
      
      ## Proactive Recommendations
      
      Based on context, proactively suggest actions:
      
      ### New Service Context
      
      If user mentions starting a new service:
```
      Since you're starting a new service, I recommend:
      
      1. *adjust-instrumentation - Set up proper instrumentation
      2. *score-instrumentation - Validate quality (target: 85+)
      3. *configure-pipeline - Configure collector for new service
      
      Would you like to start with instrumentation?
```
      
      ### Production Deployment Context
      
      If user mentions production deployment:
```
      Before deploying to production, let's ensure quality:
      
      *check-quality
      
      Target: 90+ score for production readiness
      
      Key checks:
      - SLOs configured
      - Alerting in place
      - Dashboards created
      - Collector HA (3+ replicas)
      - Sampling strategy defined
      
      Running checks...
```
      
      ### Migration Context
      
      If user mentions migrating from another platform:
```
      For migration from [Datadog/Prometheus/Jaeger], I recommend:
      
      1. *assess-observability - Baseline current state
      2. *configure-pipeline - Design new architecture
      3. *vendor-check - Validate compatibility
      4. *quick-start - Implement step-by-step
      
      Let's start with assessment!
```
      
      ## Response Guidelines
      
      **Always:**
      - Detect intent even from vague questions
      - Suggest the most relevant workflow/action
      - Explain WHY you're recommending it
      - Provide clear next steps
      - Ask clarifying questions if intent is ambiguous
      
      **Never:**
      - Just answer the question without offering to help further
      - Miss opportunities to trigger workflows
      - Assume user knows about available workflows
      - Leave user without actionable next steps
      
      ## Example Interactions
      
      **Example 1:**
```
      User: "My traces are missing some spans"
      
      Claude: "Missing spans often indicate instrumentation gaps or sampling issues.
      
      Let me run diagnostics:
      *diagnose-pipeline
      
      I'll check for:
      - Incomplete instrumentation (missing HTTP/DB calls)
      - Aggressive sampling dropping spans
      - Collector data loss
      - Context propagation issues
      
      Also, let's validate your instrumentation quality:
      *score-instrumentation
      
      This will identify specific gaps to fix."
```
      
      **Example 2:**
```
      User: "How do I know if our observability is production-ready?"
      
      Claude: "Great question! Let's assess your observability maturity.
      
      *assess-observability
      
      This comprehensive assessment will:
      1. Calculate maturity score (0-5 scale)
      2. Evaluate production readiness (target: 90+ quality score)
      3. Identify gaps and risks
      4. Provide prioritized improvement roadmap
      
      I'll also run quality checks:
      *check-quality
      
      Starting assessment..."
```
      
      **Example 3:**
```
      User: "What's the best way to monitor our microservices?"
      
      Claude: "For microservices, you need comprehensive distributed tracing,
      service-level metrics, and correlated logs.
      
      Let me guide you through the complete setup:
      *quick-start
      
      This will help you:
      1. Design observability architecture for microservices
      2. Implement distributed tracing with context propagation
      3. Set up RED metrics per service
      4. Configure log correlation
      5. Create service dependency dashboards
      6. Define SLOs for each service
      
      It's a 4-week plan - we'll start with Week 1: Foundation.
      
      Ready to begin?"
```

  - id: observability-quality-check
    content: |
      Run comprehensive quality assessment of observability setup and provide actionable recommendations.
      
      ## Quality Assessment Framework
      
      Total Score: 100 points across 6 categories
      
      ### Category 1: Signal Coverage (40 points)
      
      **Traces (15 points):**
      - ✅ Traces present and flowing to backend (5 pts)
      - ✅ Distributed tracing with context propagation (5 pts)
      - ✅ All critical paths instrumented (5 pts)
      
      **Metrics (15 points):**
      - ✅ RED metrics (Rate, Errors, Duration) for all services (5 pts)
      - ✅ Infrastructure metrics (CPU, memory, disk, network) (5 pts)
      - ✅ Custom business metrics (5 pts)
      
      **Logs (5 points):**
      - ✅ Structured logging in place (3 pts)
      - ✅ Appropriate log levels used (2 pts)
      
      **Profiling (5 points):**
      - ✅ Continuous profiling enabled (5 pts)
      - ⚠️  Optional but recommended for production
      
      ### Category 2: Signal Correlation (25 points)
      
      **Trace Context in Logs (10 points):**
      - ✅ Trace ID in all log entries (5 pts)
      - ✅ Span ID in log entries (3 pts)
      - ✅ Service name in logs (2 pts)
      
      **Exemplars (Metrics → Traces) (5 points):**
      - ✅ Exemplars enabled on key metrics (5 pts)
      - Allows jumping from metric spike to specific trace
      
      **Resource Attributes (5 points):**
      - ✅ Consistent resource attributes across all signals (5 pts)
      - service.name, service.version, deployment.environment
      
      **Span Links (5 points):**
      - ✅ Links between related traces (async operations, messaging) (5 pts)
      
      ### Category 3: Semantic Conventions (25 points)
      
      **Compliance Score (15 points):**
      - ✅ 95-100% compliant (15 pts)
      - ⚠️  85-94% compliant (10 pts)
      - ⚠️  75-84% compliant (5 pts)
      - ❌ <75% compliant (0 pts)
      
      **Required Attributes (10 points):**
      - ✅ http.method, http.status_code for HTTP spans (3 pts)
      - ✅ db.system, db.statement for database spans (3 pts)
      - ✅ messaging.system for messaging spans (2 pts)
      - ✅ rpc.system for RPC spans (2 pts)
      
      ### Category 4: Cardinality Management (15 points)
      
      **Total Cardinality (5 points):**
      - ✅ <100k total unique series (5 pts)
      - ⚠️  100k-500k series (3 pts)
      - ❌ >500k series (0 pts)
      
      **Per-Metric Cardinality (5 points):**
      - ✅ No metric >10k unique series (5 pts)
      - ⚠️  Some metrics 10k-50k series (2 pts)
      - ❌ Metrics >50k series (0 pts)
      
      **Unbounded Attributes (5 points):**
      - ✅ No unbounded attributes (user_id, trace_id in metrics) (5 pts)
      - ⚠️  1-2 unbounded attributes identified (2 pts)
      - ❌ 3+ unbounded attributes (0 pts)
      
      ### Category 5: Production Readiness (45 points)
      
      **Collector HA (10 points):**
      - ✅ 3+ collector replicas (10 pts)
      - ⚠️  2 replicas (5 pts)
      - ❌ Single replica (0 pts)
      
      **Memory Management (5 points):**
      - ✅ memory_limiter processor configured (5 pts)
      - ❌ No memory_limiter (0 pts) - 🚨 CRITICAL
      
      **Batching (5 points):**
      - ✅ Batch processor configured (5 pts)
      - ❌ No batching (0 pts)
      
      **Sampling Strategy (10 points):**
      - ✅ Tail-based sampling configured (10 pts)
      - ⚠️  Head-based/probabilistic sampling (5 pts)
      - ❌ No sampling (100% traces) (0 pts) - 🚨 Cost risk
      
      **SLOs Defined (10 points):**
      - ✅ SLOs for all critical services (10 pts)
      - ⚠️  SLOs for some services (5 pts)
      - ❌ No SLOs (0 pts) - 🚨 CRITICAL
      
      **Alerting (3 points):**
      - ✅ Alerts configured for SLO violations (3 pts)
      - ❌ No alerting (0 pts)
      
      **Dashboards (2 points):**
      - ✅ Service dashboards exist (2 pts)
      - ❌ No dashboards (0 pts)
      
      ### Category 6: Operational Maturity (15 points)
      
      **Runbooks (5 points):**
      - ✅ Runbooks for common issues (5 pts)
      - ⚠️  Basic documentation (2 pts)
      - ❌ No runbooks (0 pts)
      
      **Configuration as Code (5 points):**
      - ✅ All config in version control (5 pts)
      - ⚠️  Partial (2 pts)
      - ❌ Manual configuration (0 pts)
      
      **CI/CD Integration (3 points):**
      - ✅ Automated deployment and validation (3 pts)
      - ❌ Manual deployment (0 pts)
      
      **Documentation (2 points):**
      - ✅ Complete documentation (2 pts)
      - ⚠️  Partial (1 pt)
      - ❌ None (0 pts)
      
      ## Quality Check Execution
      
      Run these checks:
```bash
      # 1. Check for traces
      curl http://backend/api/traces?limit=1
      
      # 2. Check for metrics
      curl http://collector:8888/metrics | grep -c "^[a-z]"
      
      # 3. Validate semantic conventions
      weaver registry validate --telemetry=./exported-data.json
      
      # 4. Check cardinality
      # Query backend for unique series count
      
      # 5. Inspect collector config
      kubectl get configmap otelcol-config -o yaml
      
      # 6. Check collector replicas
      kubectl get deployment otelcol -o jsonpath='{.spec.replicas}'
```
      
      ## Report Generation
      
      Generate report in this format:
```markdown
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      OBSERVABILITY QUALITY REPORT
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      
      Overall Score: 78/100 ⚠️  NEEDS IMPROVEMENT
      
      Grade: C (70-79)
      - A: 90-100 (Excellent - Production Ready)
      - B: 80-89  (Good - Minor improvements needed)
      - C: 70-79  (Fair - Significant improvements needed)
      - D: 60-69  (Poor - Major gaps)
      - F: <60    (Failing - Critical issues)
      
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      CATEGORY BREAKDOWN
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      
      1. Signal Coverage:           35/40  ████████████████░░ 88%
      2. Signal Correlation:        18/25  ██████████████░░░░ 72%
      3. Semantic Conventions:      12/25  █████████░░░░░░░░░ 48%
      4. Cardinality Management:    10/15  █████████████░░░░░ 67%
      5. Production Readiness:      25/45  ███████████░░░░░░░ 56%
      6. Operational Maturity:       8/15  ██████████░░░░░░░░ 53%
      
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      DETAILED RESULTS
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      
      ✅ PASSED (18 checks):
        ✓ Traces present and flowing (5/5 pts)
        ✓ Distributed tracing enabled (5/5 pts)
        ✓ Critical paths instrumented (5/5 pts)
        ✓ RED metrics configured (5/5 pts)
        ✓ Infrastructure metrics (5/5 pts)
        ✓ Structured logging (3/3 pts)
        ✓ Trace ID in logs (5/5 pts)
        ✓ Span ID in logs (3/3 pts)
        ✓ Resource attributes consistent (5/5 pts)
        ✓ HTTP semantic conventions (3/3 pts)
        ✓ Total cardinality <100k (5/5 pts)
        ✓ Per-metric cardinality <10k (5/5 pts)
        ✓ No unbounded attributes (5/5 pts)
        ✓ Collector HA - 3 replicas (10/10 pts)
        ✓ memory_limiter configured (5/5 pts)
        ✓ Batch processor configured (5/5 pts)
        ✓ Basic dashboards exist (2/2 pts)
        ✓ Config in Git (5/5 pts)
      
      ⚠️  WARNINGS (5 checks):
        ! Custom business metrics - partial (3/5 pts)
          Current: Basic metrics only
          Target: Add domain-specific metrics
        
        ! Exemplars not enabled (0/5 pts)
          Missing: Metrics → Traces correlation
          Fix: Enable exemplars in SDK and collector
        
        ! Semantic convention compliance - 87% (10/15 pts)
          Target: 95%+ for production
          Issues: Missing db.statement, incorrect types
          Fix: *validate-semconv to get detailed report
        
        ! Head-based sampling only (5/10 pts)
          Current: 10% probabilistic sampling
          Recommended: Tail-based sampling (100% errors, 100% slow, 10% normal)
          Fix: *configure-pipeline with tail sampling
        
        ! Partial runbooks (2/5 pts)
          Current: Basic troubleshooting docs
          Needed: Complete runbooks for all failure modes
      
      ❌ FAILURES (3 checks):
        ✗ Continuous profiling not enabled (0/5 pts) 🚨 CRITICAL
          Impact: Cannot debug CPU/memory issues effectively
          Fix: Enable continuous profiling in production
          Effort: 1 day
        
        ✗ SLOs not configured (0/10 pts) 🚨 CRITICAL
          Impact: No objective reliability targets
          Fix: *configure-dt-alerting to define SLOs
          Critical for production readiness
          Effort: 2-3 days
        
        ✗ Alerting not configured (0/3 pts) 🚨 CRITICAL
          Impact: Issues not detected proactively
          Fix: Configure alerts for SLO violations, errors, latency
          Effort: 1 day
      
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      PRIORITY ACTIONS TO REACH 90+ (PRODUCTION-READY)
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      
      1. [CRITICAL] Configure SLOs (+10 pts)
         Action: *configure-dt-alerting
         Define SLOs: Availability 99.9%, Latency p95 <200ms, Error rate <1%
         Effort: 2-3 days
         Impact: Foundation for reliability engineering
      
      2. [CRITICAL] Set up alerting (+3 pts)
         Action: Configure PagerDuty/Slack alerts for SLO violations
         Effort: 1 day
         Impact: Proactive incident detection
      
      3. [HIGH] Enable continuous profiling (+5 pts)
         Action: Deploy profiling agent, configure collector
         Effort: 1 day
         Impact: Debug production performance issues
      
      4. [HIGH] Improve semantic convention compliance to 95% (+5 pts)
         Action: *validate-semconv for detailed violations
         Fix missing db.statement, correct attribute types
         Effort: 2 days
         Impact: Better data consistency and vendor compatibility
      
      5. [MEDIUM] Enable exemplars (+5 pts)
         Action: Enable in SDK config, add exemplar processor
         Effort: 1 day
         Impact: Jump from metric spike to specific trace
      
      6. [MEDIUM] Implement tail-based sampling (+5 pts)
         Action: *configure-pipeline with tail sampling config
         Policy: 100% errors + slow traces, 10% normal
         Effort: 1 day
         Impact: Better trace quality, cost optimization
      
      TOTAL POTENTIAL GAIN: +33 points → 111/100 → Capped at 100 (Grade A)
      
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      PROJECTED SCORES AFTER FIXES
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      
      After Critical Fixes (SLOs + Alerting):      91/100 (Grade A)
      After All High Priority Fixes:               96/100 (Grade A)
      After All Recommended Fixes:                100/100 (Grade A+)
      
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      NEXT STEPS
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      
      Week 1: Critical Fixes
      - Configure SLOs: *configure-dt-alerting
      - Set up alerting
      
      Week 2: High Priority
      - Enable profiling
      - Fix semantic conventions: *validate-semconv
      
      Week 3: Complete Improvements
      - Enable exemplars
      - Implement tail-based sampling
      
      Target: Production-ready (90+) in 3 weeks
      
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
      
      After generating report, ask:
```
      Would you like me to help you fix these issues? I can:
      
      1. *fix-issues - Auto-generate fixes for common problems
      2. *configure-dt-alerting - Set up SLOs and alerting (addresses 13 pts)
      3. *validate-semconv - Detailed semantic convention report
      4. *configure-pipeline - Implement tail-based sampling
      
      Which would you like to start with?
```

  - id: observability-issue-remediation
    content: |
      Automatically detect and fix common observability issues.
      
      ## Issue Detection & Remediation Matrix
      
      ### Issue 1: Missing or Incomplete Signals
      
      **Symptoms:**
      - No traces in backend
      - Gaps in metrics
      - Logs not flowing
      
      **Root Causes:**
      1. Instrumentation not configured
      2. Collector not receiving data
      3. Exporter misconfigured
      4. Network connectivity issues
      
      **Diagnostic Steps:**
```bash
      # Check if app is instrumented
      kubectl logs <pod> | grep -i "otel\|telemetry"
      
      # Check collector receiving data
      kubectl logs -l app=otelcol | grep "TracesReceived\|MetricsReceived"
      
      # Check exporter connectivity
      kubectl exec -it <otelcol-pod> -- wget -O- http://backend:4317
```
      
      **Auto-Fix:**
```yaml
      # Add missing instrumentation
      apiVersion: opentelemetry.io/v1alpha1
      kind: Instrumentation
      metadata:
        name: app-instrumentation
      spec:
        exporter:
          endpoint: http://otelcol:4317
        propagators:
          - tracecontext
          - baggage
        sampler:
          type: parentbased_traceidratio
          argument: "0.1"
        java:
          image: ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-java:latest
        python:
          image: ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-python:latest
```
      
      ### Issue 2: High Cardinality Explosion
      
      **Symptoms:**
      - Backend storage growing rapidly
      - Query performance degrading
      - Cost spike
      - Metric series count >100k
      
      **Root Causes:**
      - Unbounded attributes (user_id, trace_id in metrics)
      - Too many label combinations
      - No drop rules for high-cardinality metrics
      
      **Diagnostic:**
```bash
      # Identify high-cardinality metrics
      # Query backend for series count by metric
      
      # Check for unbounded attributes
      # Look for user IDs, trace IDs, timestamps in metric labels
```
      
      **Auto-Fix:**
```yaml
      # Add filter processor to drop high-cardinality attributes
      processors:
        filter/drop-high-cardinality:
          metrics:
            metric:
              # Drop metrics with unbounded attributes
              - 'HasAttrKeyOnDatapoint("user.id")'
              - 'HasAttrKeyOnDatapoint("trace.id")'
              - 'HasAttrKeyOnDatapoint("request.id")'
        
        # Or transform to aggregate
        transform/aggregate-users:
          metric_statements:
            - context: datapoint
              statements:
                - delete_key(attributes, "user.id") where IsMatch(metric.name, ".*request.*")
                - set(attributes["user.type"], "authenticated") where attributes["user.id"] != nil
      
      service:
        pipelines:
          metrics:
            processors: [filter/drop-high-cardinality, transform/aggregate-users, batch]
```
      
      ### Issue 3: Semantic Convention Violations
      
      **Symptoms:**
      - Data not showing up correctly in backend
      - Inconsistent attribute names
      - Missing required attributes
      - Wrong attribute types
      
      **Diagnostic:**
```bash
      # Validate with Weaver
      weaver registry validate \
        --registry=./semconv/registry \
        --telemetry=./exported-telemetry.json
```
      
      **Common Violations & Fixes:**
      
      **Missing http.method:**
```go
      // ❌ Before
      span.SetAttributes(
          attribute.String("method", "GET"),  // Wrong name
      )
      
      // ✅ After
      import semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
      
      span.SetAttributes(
          semconv.HTTPMethod("GET"),  // Correct
          semconv.HTTPStatusCode(200),
      )
```
      
      **Wrong attribute type:**
```python
      # ❌ Before
      span.set_attribute("http.status_code", "200")  # String, should be int
      
      # ✅ After
      span.set_attribute("http.status_code", 200)  # Int
```
      
      **Deprecated attributes:**
```go
      // ❌ Before - Deprecated
      attribute.String("net.peer.name", "api.example.com")
      attribute.Int("net.peer.port", 443)
      
      // ✅ After - Current
      attribute.String("server.address", "api.example.com")
      attribute.Int("server.port", 443)
```
      
      ### Issue 4: Collector Crashes / OOM
      
      **Symptoms:**
      - Collector pods restarting frequently
      - OOMKilled events
      - High memory usage
      
      **Root Causes:**
      - No memory_limiter processor
      - Batch size too large
      - Memory leak in processor
      - Insufficient resource limits
      
      **Auto-Fix:**
```yaml
      processors:
        # CRITICAL: Always first processor
        memory_limiter:
          check_interval: 1s
          limit_mib: 512      # 80% of pod memory limit
          spike_limit_mib: 128
        
        batch:
          timeout: 10s
          send_batch_size: 1024    # Reduce if OOM
          send_batch_max_size: 2048
      
      service:
        pipelines:
          traces:
            # memory_limiter MUST be first
            processors: [memory_limiter, batch, ...]
      
      ---
      # Increase pod resources
      apiVersion: apps/v1
      kind: Deployment
      spec:
        template:
          spec:
            containers:
            - name: otelcol
              resources:
                requests:
                  memory: "512Mi"
                  cpu: "200m"
                limits:
                  memory: "2Gi"    # Increased
                  cpu: "1000m"
```
      
      ### Issue 5: Data Loss / Dropped Spans
      
      **Symptoms:**
      - Missing traces in backend
      - Gaps in service map
      - Incomplete distributed traces
      
      **Root Causes:**
      - Queue size too small
      - No retry logic
      - Backend unreachable
      - Collector overwhelmed
      
      **Auto-Fix:**
```yaml
      exporters:
        otlp:
          endpoint: backend:4317
          
          # Enable queue for buffering
          sending_queue:
            enabled: true
            num_consumers: 10
            queue_size: 5000  # Increased from default 1000
          
          # Enable retry logic
          retry_on_failure:
            enabled: true
            initial_interval: 5s
            max_interval: 30s
            max_elapsed_time: 300s  # 5 minutes
          
          # Timeout configuration
          timeout: 30s
      
      # Also scale up collectors
      kubectl scale deployment otelcol --replicas=5
```
      
      ### Issue 6: Poor Sampling Strategy
      
      **Symptoms:**
      - 100% of traces being sent (cost explosion)
      - OR missing important traces (errors, slow requests)
      - Inconsistent sampling across services
      
      **Auto-Fix - Tail-Based Sampling:**
```yaml
      processors:
        tail_sampling:
          decision_wait: 10s
          num_traces: 100
          expected_new_traces_per_sec: 10
          
          policies:
            # Always sample errors
            - name: errors-policy
              type: status_code
              status_code:
                status_codes: [ERROR]
            
            # Always sample slow requests (p95)
            - name: latency-policy
              type: latency
              latency:
                threshold_ms: 500
            
            # Always sample specific endpoints
            - name: critical-endpoints
              type: string_attribute
              string_attribute:
                key: http.target
                values:
                  - /api/checkout
                  - /api/payment
            
            # Sample 10% of normal traffic
            - name: probabilistic-policy
              type: probabilistic
              probabilistic:
                sampling_percentage: 10
      
      service:
        pipelines:
          traces:
            processors: [memory_limiter, tail_sampling, batch]
```
      
      ### Issue 7: Missing Trace Context in Logs
      
      **Symptoms:**
      - Cannot correlate logs with traces
      - Logs missing trace_id/span_id
      
      **Auto-Fix:**
      
      **Go (logrus):**
```go
      import (
          "github.com/sirupsen/logrus"
          "go.opentelemetry.io/otel/trace"
      )
      
      func logWithTraceContext(ctx context.Context, msg string) {
          span := trace.SpanFromContext(ctx)
          
          logrus.WithFields(logrus.Fields{
              "trace_id": span.SpanContext().TraceID().String(),
              "span_id":  span.SpanContext().SpanID().String(),
          }).Info(msg)
      }
```
      
      **Python:**
```python
      import logging
      from opentelemetry import trace
      
      # Configure logging format
      logging.basicConfig(
          format='%(asctime)s %(levelname)s [%(name)s] [trace_id=%(otelTraceID)s span_id=%(otelSpanID)s] %(message)s'
      )
      
      # Use OpenTelemetry log hook
      from opentelemetry.instrumentation.logging import LoggingInstrumentor
      LoggingInstrumentor().instrument(set_logging_format=True)
```
      
      ### Issue 8: Collector Configuration Errors
      
      **Common Errors:**
      
      **Missing required processor:**
```yaml
      # ❌ Error: No batch processor
      service:
        pipelines:
          traces:
            processors: []  # Will cause performance issues
      
      # ✅ Fix
      service:
        pipelines:
          traces:
            processors: [memory_limiter, batch]
```
      
      **Invalid receiver config:**
```yaml
      # ❌ Error: Wrong port format
      receivers:
        otlp:
          protocols:
            grpc:
              endpoint: 4317  # Missing host
      
      # ✅ Fix
      receivers:
        otlp:
          protocols:
            grpc:
              endpoint: 0.0.0.0:4317
```
      
      **Circular pipeline:**
```yaml
      # ❌ Error: Pipeline loops back to itself
      service:
        pipelines:
          traces:
            receivers: [otlp]
            exporters: [otlp]  # Same as receiver!
      
      # ✅ Fix
      service:
        pipelines:
          traces:
            receivers: [otlp]
            exporters: [otlp/backend]  # Different endpoint
```
      
      ## Remediation Workflow
      
      When user reports an issue:
      
      1. **Classify the issue** (use symptoms above)
      2. **Run diagnostic commands** to confirm
      3. **Generate fix** (configuration changes)
      4. **Provide validation steps** to verify fix
      5. **Suggest preventive measures**
      
      ## Example Output
Issue Detected: Collector OOM (Out of Memory)
  
  Symptoms observed:
  - Collector pods restarting every 2 hours
  - Memory usage climbing to 100%
  - OOMKilled events in pod logs
  
  Root Cause: No memory_limiter processor configured
  
  Fix:
  
  1. Add memory_limiter processor (CRITICAL):
processors:
        memory_limiter:
          check_interval: 1s
          limit_mib: 1536  # 80% of 2Gi pod limit
          spike_limit_mib: 384
      
      service:
        pipelines:
          traces:
            processors: [memory_limiter, batch, ...]  # memory_limiter first!
2. Increase pod memory limit:
kubectl set resources deployment otelcol \
        --limits=memory=2Gi \
        --requests=memory=512Mi
3. Reduce batch size if still seeing OOM:
processors:
        batch:
          send_batch_size: 512  # Reduced from 1024
Validation:
# 1. Apply changes
      kubectl apply -f collector-config.yaml
      kubectl rollout restart deployment/otelcol
      
      # 2. Monitor memory usage
      kubectl top pod -l app=otelcol
      
      # 3. Check for OOM events (should be none)
      kubectl get events | grep OOM
      
      # 4. Verify data still flowing
      kubectl logs -l app=otelcol | grep "TracesReceived"
```
      
      Expected result: Memory usage stabilizes at ~80%, no more restarts
      
      Prevention:
      - Always include memory_limiter as first processor
      - Set memory limits to 2-3x requests
      - Monitor collector memory usage
      - Set up alerts for high memory (>80%)
```

  - id: observability-best-practices
    content: |
      Comprehensive guide to observability best practices across instrumentation, collection, and operations.
      
      ## 1. Instrumentation Best Practices
      
      ### Use Semantic Conventions
      
      **Why:** Ensures consistency, vendor compatibility, and data correlation
      
      **✅ DO:**
```go
      import semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
      
      span.SetAttributes(
          semconv.HTTPMethod("GET"),
          semconv.HTTPStatusCode(200),
          semconv.HTTPRoute("/api/users/{id}"),
          semconv.ServerAddress("api.example.com"),
      )
```
      
      **❌ DON'T:**
```go
      span.SetAttributes(
          attribute.String("method", "GET"),        // Non-standard name
          attribute.String("status", "200"),        // Wrong type
          attribute.String("endpoint", "/api/users/123"),  // Includes ID
      )
```
      
      ### Avoid Unbounded Cardinality
      
      **Why:** Prevents dimensional explosion and cost/performance issues
      
      **✅ DO:**
```go
      // Use bounded attributes
      span.SetAttributes(
          attribute.String("http.route", "/api/users/{id}"),  // Template
          attribute.String("user.type", "premium"),            // Enum
          attribute.Int("http.status_code", 200),              // Limited range
      )
```
      
      **❌ DON'T:**
```go
      // Unbounded attributes
      span.SetAttributes(
          attribute.String("http.target", "/api/users/12345"),  // Unique per request
          attribute.String("user.id", "user_12345"),            // Unique
          attribute.String("trace.id", "abc123..."),            // Unique
          attribute.String("timestamp", time.Now().String()),   // Unique
      )
```
      
      ### Implement Intelligent Sampling
      
      **Why:** Balance cost with trace quality
      
      **✅ DO - Tail-based sampling:**
```yaml
      # Sample: 100% errors + 100% slow + 10% normal
      tail_sampling:
        policies:
          - name: errors
            type: status_code
            status_code: {status_codes: [ERROR]}
          - name: slow
            type: latency
            latency: {threshold_ms: 500}
          - name: normal
            type: probabilistic
            probabilistic: {sampling_percentage: 10}
```
      
      **❌ DON'T - Sample everything:**
```yaml
      # 100% sampling = cost explosion
      sampler:
        type: always_on
```
      
      ### Enable Exemplars
      
      **Why:** Links metrics to traces for root cause analysis
      
      **✅ DO:**
```go
      import (
          "go.opentelemetry.io/otel/metric"
          "go.opentelemetry.io/otel/sdk/metric"
      )
      
      // Configure meter provider with exemplar filter
      mp := metric.NewMeterProvider(
          metric.WithReader(
              metric.NewPeriodicReader(exporter),
          ),
          metric.WithView(
              metric.NewView(
                  metric.Instrument{Kind: metric.InstrumentKindHistogram},
                  metric.Stream{
                      Aggregation: metric.AggregationExplicitBucketHistogram{
                          Boundaries: []float64{0, 5, 10, 25, 50, 75, 100, 250, 500, 1000},
                      },
                  },
              ),
          ),
      )
      
      // Exemplars automatically attached to histograms/counters
```
      
      ### Add Trace Context to Logs
      
      **Why:** Correlate logs with traces for complete picture
      
      **✅ DO:**
```python
      import logging
      from opentelemetry import trace
      from opentelemetry.instrumentation.logging import LoggingInstrumentor
      
      # Auto-inject trace context
      LoggingInstrumentor().instrument(set_logging_format=True)
      
      logger = logging.getLogger(__name__)
      logger.info("Processing request")  
      # Output: [trace_id=abc123 span_id=def456] Processing request
```
      
      ## 2. Collector Best Practices
      
      ### Always Use memory_limiter (First Processor)
      
      **Why:** Prevents OOM crashes
      
      **✅ DO:**
```yaml
      processors:
        memory_limiter:  # MUST be first
          check_interval: 1s
          limit_mib: 512
          spike_limit_mib: 128
        batch:
          timeout: 10s
        # other processors...
      
      service:
        pipelines:
          traces:
            processors: [memory_limiter, batch, ...]  # Order matters!
```
      
      **❌ DON'T:**
```yaml
      processors:
        batch: {}
        # No memory_limiter = OOM risk!
      
      service:
        pipelines:
          traces:
            processors: [batch]  # Missing memory_limiter
```
      
      ### Deploy Collectors in HA
      
      **Why:** Resilience and load distribution
      
      **✅ DO:**
```yaml
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: otelcol
      spec:
        replicas: 3  # HA deployment
        strategy:
          type: RollingUpdate
          rollingUpdate:
            maxUnavailable: 1
        template:
          spec:
            containers:
            - name: otelcol
              resources:
                requests:
                  memory: "512Mi"
                  cpu: "200m"
                limits:
                  memory: "2Gi"
                  cpu: "1000m"
```
      
      **❌ DON'T:**
```yaml
      replicas: 1  # Single point of failure!
```
      
      ### Use Batch Processor
      
      **Why:** Reduces network overhead, improves throughput
      
      **✅ DO:**
```yaml
      processors:
        batch:
          timeout: 10s              # Send every 10s
          send_batch_size: 8192     # Or when batch reaches 8192 spans
          send_batch_max_size: 16384
```
      
      **❌ DON'T:**
```yaml
      # No batching = many small network requests
      processors: {}
```
      
      ### Configure Resource Limits
      
      **Why:** Prevent resource exhaustion
      
      **✅ DO:**
```yaml
      resources:
        requests:
          memory: "512Mi"   # Guaranteed
          cpu: "200m"
        limits:
          memory: "2Gi"     # Max allowed (2-3x requests)
          cpu: "1000m"
```
      
      ## 3. Semantic Convention Best Practices
      
      ### Namespace Custom Conventions
      
      **Why:** Avoid conflicts with standard conventions
      
      **✅ DO:**
```yaml
      # Custom semantic conventions
      groups:
        - id: mycompany.payment
          prefix: mycompany.payment
          attributes:
            - id: mycompany.payment.transaction_id
              type: string
            - id: mycompany.payment.amount
              type: double
            - id: mycompany.payment.currency
              type: string
```
      
      **❌ DON'T:**
```yaml
      # Don't use names that might conflict
      attributes:
        - id: payment.id  # Too generic, might conflict
        - id: amount      # No namespace
```
      
      ### Use Weaver for Schema Management
      
      **Why:** Type-safe code generation, validation, versioning
      
      **✅ DO:**
```bash
      # 1. Define schema
      vim semconv/registry/mycompany/payment.yaml
      
      # 2. Validate
      weaver registry check --registry=./semconv/registry
      
      # 3. Generate code
      weaver registry generate \
        --registry=./semconv/registry \
        go ./internal/semconv/
      
      # 4. Use in application
      import "myapp/internal/semconv"
      
      span.SetAttributes(
          semconv.PaymentTransactionID("txn_123"),
          semconv.PaymentAmount(99.99),
          semconv.PaymentCurrency("USD"),
      )
```
      
      ### Version Your Schemas
      
      **Why:** Manage breaking changes, enable migrations
      
      **✅ DO:**
```yaml
      # semconv/v1.0.0/registry/payment.yaml
      schema_url: https://mycompany.com/schemas/1.0.0
      
      # When making breaking changes, create new version
      # semconv/v2.0.0/registry/payment.yaml
      schema_url: https://mycompany.com/schemas/2.0.0
```
      
      ## 4. Cost Optimization Best Practices
      
      ### Monitor Cardinality
      
      **Why:** High cardinality = high costs
      
      **✅ DO:**
```bash
      # Regularly check cardinality
      # Target: <100k total unique series
      
      # Alert when metric exceeds threshold
      # Alert: metric_cardinality > 10000 for any single metric
```
      
      ### Drop Low-Value Metrics
      
      **Why:** Not all metrics provide value
      
      **✅ DO:**
```yaml
      processors:
        filter/drop-noisy:
          metrics:
            metric:
              # Drop internal health checks
              - 'IsMatch(name, ".*healthcheck.*")'
              # Drop zero-value metrics
              - 'value == 0 and IsMatch(name, ".*count")'
```
      
      ### Aggregate Where Possible
      
      **Why:** Reduce data volume while keeping insights
      
      **✅ DO:**
```yaml
      processors:
        transform/aggregate:
          metric_statements:
            - context: datapoint
              statements:
                # Aggregate user_id to user_type
                - set(attributes["user_type"], "premium") where attributes["user_tier"] == "gold"
                - delete_key(attributes, "user_id")
```
      
      ### Use Appropriate Sampling Rates
      
      **Why:** 100% tracing is usually unnecessary and expensive
      
      **✅ DO:**
      - Production: 10-20% sampling for normal traffic
      - Errors: 100% sampling
      - Slow requests (p95+): 100% sampling
      - Critical endpoints: 100% sampling
      
      **❌ DON'T:**
      - Sample 100% of all traffic in production
      - Sample errors (you need all errors!)
      
      ## 5. Production Readiness Best Practices
      
      ### Define SLOs
      
      **Why:** Objective reliability targets
      
      **✅ DO:**
```yaml
      slos:
        - name: "API Availability"
          target: 99.9%
          error_budget_burn_rate: 10
          metric: |
            (sum(http_requests_total{status!~"5.."}) /
             sum(http_requests_total)) * 100
        
        - name: "API Latency"
          target: 95%  # 95% of requests < 200ms
          metric: |
            histogram_quantile(0.95,
              http_request_duration_seconds_bucket) < 0.2
```
      
      ### Create Actionable Dashboards
      
      **Why:** Quick incident triage
      
      **✅ DO - RED Method:**
      - **R**ate: Requests per second
      - **E**rrors: Error rate %
      - **D**uration: p50, p95, p99 latency
      
      Plus:
      - Saturation: CPU, memory, queue depth
      - Service dependencies (service map)
      - Error rate by endpoint
      
      ### Set Up Alerts
      
      **Why:** Proactive incident detection
      
      **✅ DO:**
```yaml
      alerts:
        - name: "High Error Rate"
          condition: error_rate > 1%
          duration: 5m
          severity: critical
          
        - name: "SLO Burn Rate"
          condition: error_budget_burn_rate > 10
          duration: 1h
          severity: warning
          
        - name: "High Latency"
          condition: p95_latency > 500ms
          duration: 10m
          severity: warning
```
      
      **❌ DON'T:**
      - Alert on every single error (alert fatigue)
      - Set thresholds too low (false positives)
      - Forget to define SLOs first
      
      ### Maintain Runbooks
      
      **Why:** Faster incident resolution
      
      **✅ DO - Each alert should have:**
      1. What it means (symptom)
      2. Impact on users
      3. Common causes
      4. Investigation steps
      5. Remediation steps
      6. When to escalate
      
      ## 6. Dynatrace-Specific Best Practices
      
      ### Use Monaco for Config as Code
      
      **Why:** Version control, reproducibility, automation
      
      **✅ DO:**
```bash
      # All Dynatrace config in Git
      dynatrace-config/
      ├── environments.yaml
      ├── manifest.yaml
      └── projects/
          └── default/
              ├── dashboards/
              ├── slos/
              ├── alerting/
              └── workflows/
      
      # Deploy via CI/CD
      monaco deploy --environments production
```
      
      **❌ DON'T:**
      - Manually configure via UI (not reproducible)
      - Skip version control
      
      ### Organize with Management Zones
      
      **Why:** Scope monitoring, control access
      
      **✅ DO:**
```json
      {
        "name": "Production - Payment Service",
        "rules": [
          {
            "type": "SERVICE",
            "enabled": true,
            "propagation": "SERVICE_TO_PROCESS_GROUP_INSTANCE",
            "conditions": [
              {
                "key": "SERVICE_TAGS",
                "operator": "EQUALS",
                "value": "app:payment"
              },
              {
                "key": "ENVIRONMENT",
                "operator": "EQUALS",
                "value": "production"
              }
            ]
          }
        ]
      }
```
      
      ### Use DQL for Advanced Queries
      
      **Why:** More powerful than UI filters
      
      **✅ DO:**
```dql
      fetch logs
      | filter status == "ERROR"
      | filter contains(content, "payment")
      | join [
          fetch spans
          | filter span.kind == "SERVER"
        ], on: trace.id == trace_id
      | summarize 
          error_count = count(),
          affected_users = countDistinct(user.id),
          by: {service.name, error.type}
      | sort error_count desc
```
      
      ## 7. Team & Organizational Best Practices
      
      ### Create Observability Center of Excellence
      
      **Why:** Shared expertise, consistency
      
      **✅ DO:**
      - Central team owns standards and tooling
      - Shared semantic convention registry
      - Reusable dashboards and alerts
      - Regular training and reviews
      
      ### Regular Observability Reviews
      
      **Why:** Continuous improvement
      
      **✅ DO - Monthly:**
      - Review quality score: *check-quality
      - Analyze cardinality trends
      - Check cost vs budget
      - Update SLOs based on reality
      
      **✅ DO - Quarterly:**
      - Assess maturity: *assess-observability
      - Update to latest OTel Collector
      - Review and update semantic conventions
      - Incident retrospectives
      
      ## Summary Checklist
      
      ✅ Instrumentation:
      - [ ] Use semantic conventions
      - [ ] Avoid unbounded cardinality
      - [ ] Implement sampling strategy
      - [ ] Enable exemplars
      - [ ] Add trace context to logs
      
      ✅ Collection:
      - [ ] memory_limiter processor (first)
      - [ ] Batch processor configured
      - [ ] HA deployment (3+ replicas)
      - [ ] Resource limits set
      - [ ] Health checks enabled
      
      ✅ Semantic Conventions:
      - [ ] Custom conventions namespaced
      - [ ] Using Weaver for management
      - [ ] Schemas versioned
      - [ ] CI/CD validation
      
      ✅ Cost:
      - [ ] Cardinality monitored
      - [ ] Low-value metrics dropped
      - [ ] Appropriate sampling rates
      - [ ] Regular cost reviews
      
      ✅ Production:
      - [ ] SLOs defined
      - [ ] Dashboards created
      - [ ] Alerts configured
      - [ ] Runbooks maintained
      - [ ] Config as code
      
      ✅ Organization:
      - [ ] Center of excellence
      - [ ] Regular reviews
      - [ ] Shared standards
      - [ ] Team training

YAML_EOF

echo "✅ Created agent_part3_prompts.yaml with all 4 core prompts"
echo ""
echo "This file contains:"
echo "  ✅ intent-detection"
echo "  ✅ observability-quality-check"
echo "  ✅ observability-issue-remediation"
echo "  ✅ observability-best-practices"
echo ""
echo "Copy this content and paste it into your agent file after the menu section."
