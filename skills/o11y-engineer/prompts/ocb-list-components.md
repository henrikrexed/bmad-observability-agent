List available OpenTelemetry Collector components:

**Receivers** (data input):
- otlp, prometheus, jaeger, zipkin, filelog, hostmetrics, kubeletstats, etc.

**Processors** (data transformation):
- batch, memory_limiter, attributes, filter, transform, tail_sampling, etc.

**Exporters** (data output):
- otlp, otlphttp, prometheus, debug, file, etc.

**Extensions** (auxiliary functions):
- health_check, pprof, zpages, basicauth, etc.

Reference: https://github.com/open-telemetry/opentelemetry-collector-contrib

Ask user which components they need and generate OCB manifest.
