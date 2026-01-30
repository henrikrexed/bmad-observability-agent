# Phase 1: Observability Assessment

**Command:** `*assess-observability`

**Goal:** Understand the current state of observability and produce a maturity score with an improvement roadmap.

## What Gets Assessed

The assessment evaluates five dimensions:

### 1. Signal Coverage (30 points)

| Check | Points | Criteria |
|-------|--------|----------|
| Traces present | 15 | At least one service producing spans |
| Metrics present | 10 | Application and/or infrastructure metrics |
| Logs correlated | 5 | Logs include trace_id for correlation |

### 2. Semantic Convention Compliance (20 points)

| Check | Points | Criteria |
|-------|--------|----------|
| Standard attributes used | 10 | HTTP, DB, RPC conventions followed |
| Custom conventions documented | 5 | Custom attributes use namespaced naming |
| No deprecated attributes | 5 | Using current semconv version |

### 3. Collector Configuration (20 points)

| Check | Points | Criteria |
|-------|--------|----------|
| Collector deployed | 5 | OTel Collector running |
| Correct processor ordering | 5 | memory_limiter first, batch last |
| Resource enrichment | 5 | k8sattributes or resourcedetection |
| HA deployment | 5 | 3+ replicas for production |

### 4. Production Readiness (20 points)

| Check | Points | Criteria |
|-------|--------|----------|
| SLOs configured | 10 | At least one SLO defined |
| Alerting in place | 5 | Problem notifications configured |
| Dashboards created | 5 | Service overview dashboard exists |

### 5. Operational Maturity (10 points)

| Check | Points | Criteria |
|-------|--------|----------|
| Sampling strategy defined | 3 | Head or tail sampling configured |
| Cardinality managed | 3 | No unbounded attribute values |
| Runbooks exist | 2 | Documentation for common issues |
| On-call procedures | 2 | Escalation paths defined |

## Output

### Maturity Score

```
Overall Score: 78/100

Production Readiness: NEEDS IMPROVEMENT
Target for production: 90+
```

### Score Interpretation

| Score | Level | Meaning |
|-------|-------|---------|
| 0-30 | Initial | Minimal or no observability |
| 31-50 | Developing | Basic signals but significant gaps |
| 51-70 | Defined | Good coverage, missing production features |
| 71-85 | Managed | Near production-ready, minor improvements needed |
| 86-100 | Optimized | Production-grade observability |

### Improvement Roadmap

The assessment produces a prioritized list of actions, each with:

- **Priority** (CRITICAL / HIGH / MEDIUM / LOW)
- **Points gained** if addressed
- **Command to fix** (e.g., `*configure-pipeline`)
- **Effort estimate**

## Next Step

After assessment, proceed to [Phase 2: Observability Spec](phase-2-spec.md) to define what telemetry your services need.
