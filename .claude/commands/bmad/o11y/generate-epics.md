Generate a complete set of observability epics for sprint planning.

This command produces 6 epics covering the full observability lifecycle:

1. **Assessment & Spec** — Maturity scoring + observability specification per service
2. **Collector Pipeline** — OTel Collector config, OTTL transforms, PII redaction, sampling
3. **Custom Collector** (optional) — Build optimized distribution with OCB
4. **Application Instrumentation** — Per-service OTel setup with validation
5. **Test Suite** — Trace/metric/PII test cases for the Test Architect (Murat)
6. **Last Mile** — SLI/SLO/KPI definition + Dynatrace dashboards, SLOs, workflows, alerting

Output: Epic YAML + sprint plan + test contract, ready for Bob (Scrum Master).

Usage: Provide project name, services list, backend, languages, and deployment model.

Reference: .bmad/workflows/generate-observability-epics.yaml
