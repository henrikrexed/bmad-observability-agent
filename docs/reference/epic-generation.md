# Epic Generation Reference

The O11y Engineer generates observability epics dynamically based on your project's assessment. Run `*generate-epics` to produce sprint-ready stories.

## Epic Overview

| Epic | Title | Sprint | Owner |
|------|-------|--------|-------|
| E1 | Assessment & Observability Spec | 1 | O11y Architect |
| E2 | Collector Pipeline Configuration | 1-2 | O11y Architect → Amelia |
| E3 | Custom Collector Distribution (OCB) | 2 | O11y Architect → Amelia |
| E4 | Application Instrumentation | 2-3 | Amelia |
| E5 | Observability Test Suite | 3 | Murat |
| E6 | Last Mile: SLI/SLO/KPI + Dynatrace | 4 | O11y Architect |

## How Epics Are Generated

Epics are **not static templates** — the agent generates them based on what it discovers during assessment:

- No collector found → generates collector pipeline epic (E2)
- PII concerns identified → adds PII redaction stories to E2
- Custom collector needed → generates OCB build epic (E3)
- Services discovered → generates instrumentation stories per service (E4)
- Test suite always generated → handoff to Murat (E5)
- Last Mile always generated → quality gate before Dynatrace config (E6)

## Quality Gate

Epic 6 (Last Mile) only starts after Epic 5 tests pass with a quality score ≥ 90.

If the quality score is below 90, the O11y Engineer generates fix stories that go back to Bob for sprint planning.

## Story Format

All stories use BMAD standard format:

```yaml
title: "Instrument checkout service with OTel spans"
type: instrumentation
acceptance_criteria:
  - "POST /checkout produces a SERVER span"
  - "Span includes http.route, http.method, http.status_code"
spec_reference: "observability-specs/checkout-spec.yaml"
test_criteria:
  assertion: "span.name == 'POST /checkout'"
  dql_query: |
    fetch spans
    | filter service.name == "checkout"
    | filter span.name == "POST /checkout"
assignee: amelia
points: 3
```

## Last Mile Stories

The Last Mile epic (E6) is executed directly by the O11y Architect using dtctl:

| Story | Tool | Output |
|-------|------|--------|
| Define SLIs/KPIs | Assessment data | SLI definitions with DQL queries |
| Set SLO targets | SLI analysis | SLO YAML with error budgets |
| Create dashboard | `dtctl apply` | Dynatrace dashboard |
| Configure SLOs | `dtctl apply` | Dynatrace SLO tiles |
| Create alert workflow | `dtctl apply` | Alerting on SLO breach |
| Create diagnostic notebook | `dtctl apply` | Troubleshooting notebook |
