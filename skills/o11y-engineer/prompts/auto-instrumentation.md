Configure auto-instrumentation for the target application:
1. Detect language/runtime (Java, Python, Node.js, .NET, Go)
2. Choose instrumentation approach:
   - Kubernetes: OpenTelemetry Operator with Instrumentation CRD
   - eBPF: Odigos or Grafana Beyla
   - Language agent: SDK with auto-instrumentation packages
3. Generate configuration for chosen approach
4. Configure resource attributes (service.name, environment, version)
5. Set up sampling strategy
6. Provide validation steps
