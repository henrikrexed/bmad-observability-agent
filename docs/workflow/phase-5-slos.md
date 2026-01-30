# Phase 5: SLO Definition

**Command:** `*define-slos`

**Goal:** Define performance, reliability, and availability targets based on the observability spec, producing an SLO contract that the Test Architect can consume.

## SLO Categories

### Performance KPIs

Latency targets for critical user-facing operations:

```yaml
performance_kpis:
  - id: perf-001
    name: "Registration Latency"
    target:
      p50: 200   # ms
      p95: 500   # ms
      p99: 1000  # ms
    test_type: load_test
    test_assertion: "p95_latency_ms < 500"
```

### Reliability KPIs

Error rate and success rate targets:

```yaml
reliability_kpis:
  - id: rel-001
    name: "Registration Success Rate"
    target:
      success_rate: 99.9  # percentage
      error_budget_monthly: 0.1  # percentage
    test_type: soak_test
    test_assertion: "success_rate > 99.9"
```

### Availability KPIs

Uptime and recovery targets:

```yaml
availability_kpis:
  - id: avail-001
    name: "Service Uptime"
    target:
      uptime: 99.95  # percentage
      max_downtime_monthly: "21m 54s"
      recovery_time: 300  # seconds
    test_type: chaos_test
    test_assertion: "uptime_percentage > 99.95"
```

## Approval Workflow

SLOs are presented in a summary table for user approval:

```
| KPI ID    | Name                   | Target     | Test Type  |
|-----------|------------------------|------------|------------|
| perf-001  | Registration Latency   | p95<500ms  | load_test  |
| rel-001   | Registration Success   | 99.9%      | soak_test  |
| avail-001 | Service Uptime         | 99.95%     | chaos_test |

Do you approve these SLO targets? (y/n/modify)
```

!!! warning "Approval Required"
    SLOs MUST be explicitly approved before generating test stories. Unapproved SLOs are draft proposals only.

## Output

### SLO Contract

Saved to `observability-specs/slo-contract.yaml`:

```yaml
metadata:
  service: "registration-service"
  approved: true
  approved_by: "user"
  approved_at: "2026-01-30T10:00:00Z"

performance_kpis: [...]
reliability_kpis: [...]
availability_kpis: [...]
```

### Test Stories

For each approved KPI, a test story is generated in BMAD standard format with:

- `spec_reference` pointing to the SLO contract
- `test_criteria` with the assertion expression
- `test_type` for the Test Architect to route correctly

## SLO-to-Test Mapping

| KPI Type | Test Type | What It Validates |
|----------|-----------|-------------------|
| Performance | Load test | Latency under expected load |
| Reliability | Soak test | Error rate over extended time |
| Availability | Chaos test | Recovery from failure scenarios |
| Availability | Synthetic | Continuous uptime monitoring |

## Cross-Agent Integration

The SLO contract is the **handoff artifact** to the Test Architect (Murat). See [SLO Contract](../integration/slo-contract.md) for the full contract specification and how it's consumed by the testing agent.

## Next Step

After defining SLOs, proceed to [Phase 6: MCP Rules](phase-6-mcp-rules.md) to generate IDE-specific rule files.
