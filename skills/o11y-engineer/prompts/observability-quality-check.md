Run comprehensive observability quality checks:
1. **Trace Coverage** — % of services with distributed tracing
2. **Metric Cardinality** — Check for dimensional explosion
3. **Log Correlation** — Verify trace IDs in structured logs
4. **Resource Attributes** — Consistency across all signals
5. **Sampling Configuration** — Evaluate sampling strategy effectiveness
6. **Collector Health** — Check otelcol_* metrics
7. **Backend Connectivity** — Verify data reaching observability platform

Provide a score (0-100) for each category and overall recommendations.
