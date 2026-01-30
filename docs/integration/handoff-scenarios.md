# Handoff Scenarios

This page documents common scenarios where the O11y Engineer hands off work to other B-MAD agents or receives inputs from them.

## Scenario 1: Greenfield Observability Setup

**Flow:** O11y Engineer -> Bob -> Amelia -> O11y Engineer

1. User runs `*assess-observability` (score: 0)
2. O11y Engineer runs `*generate-observability-spec` -- produces spec + companion epic
3. O11y Engineer runs `*configure-pipeline` -- produces collector YAML
4. O11y Engineer runs `*define-slos` -- produces SLO contract
5. **Handoff to Bob:** Epic with instrumentation stories at `_bmad-output/epics/`
6. **Bob plans sprint:** Assigns stories to Amelia
7. **Amelia implements:** Uses `spec_reference` for guidance
8. **Handoff back to O11y:** User runs `*validate-traces`
9. If failures: fix stories generated, sent back to Bob

## Scenario 2: Existing Project Improvement

**Flow:** O11y Engineer -> Bob -> Amelia

1. User runs `*assess-observability` (score: 65)
2. Assessment identifies gaps (missing SLOs, incomplete traces)
3. O11y Engineer generates improvement stories
4. **Handoff to Bob:** Improvement stories appended to existing epic
5. **Bob prioritizes:** Based on SLO impact and point value
6. **Amelia implements:** Targeted fixes per story

## Scenario 3: SLO-Driven Test Design

**Flow:** O11y Engineer -> Murat

1. User runs `*define-slos` -- produces SLO contract
2. User approves SLO targets
3. **Handoff to Murat:** SLO contract at `observability-specs/slo-contract.yaml`
4. **Murat designs tests:**
   - Performance KPIs -> load tests
   - Reliability KPIs -> soak tests
   - Availability KPIs -> chaos tests

## Scenario 4: Observability Change Request

**Flow:** User -> O11y Engineer -> John -> O11y Engineer -> Bob -> Amelia

1. User asks to add new metrics or change instrumentation
2. O11y Engineer detects change management intent
3. O11y Engineer creates impact analysis
4. **Handoff to John:** PRD request with impact analysis
5. **John approves PRD:** Saved at `_bmad-output/prd/`
6. O11y Engineer generates companion epic
7. **Handoff to Bob:** Change stories for sprint planning
8. **Amelia implements:** Changes per approved PRD

## Scenario 5: Post-Validation Fix Cycle

**Flow:** O11y Engineer -> Bob -> Amelia -> O11y Engineer (iterative)

1. User runs `*validate-traces` after initial implementation
2. Validation finds 4 failures (2 HIGH, 2 MEDIUM)
3. O11y Engineer generates 4 fix stories with:
   - `spec_reference` to failed contract
   - `test_criteria` with DQL query
   - Language-specific fix suggestions
4. **Handoff to Bob:** Fix stories appended to epic
5. **Amelia fixes:** Implements per fix story
6. User runs `*validate-traces` again
7. Repeat until all pass

## Scenario 6: Architecture Consultation

**Flow:** O11y Engineer <-> Winston

1. During `*configure-pipeline`, a topology decision arises
2. O11y Engineer presents options to Winston:
   - DaemonSet (agent) pattern
   - Deployment (gateway) pattern
   - Sidecar pattern
3. **Winston decides:** Based on overall system architecture
4. O11y Engineer configures collector per Winston's decision

## Handoff Artifact Summary

| From | To | Artifact | Location |
|------|----|----------|----------|
| O11y | Bob | Companion epic | `_bmad-output/epics/` |
| O11y | Bob | Fix stories | Appended to existing epic |
| O11y | Amelia | Observability spec | `observability-specs/` |
| O11y | Murat | SLO contract | `observability-specs/slo-contract.yaml` |
| O11y | John | Impact analysis | `_bmad-output/prd/` |
| O11y | Winston | Architecture options | Interactive discussion |
| O11y | Mary | Use case templates | Interactive discussion |

## Story Format

All stories use BMAD standard format with observability-specific fields:

```yaml
title: "Instrument registration endpoint"
type: instrumentation
acceptance_criteria:
  - "POST /api/register produces SERVER span"
  - "Span includes required attributes"
spec_reference: "observability-specs/registration-spec.yaml#trace_contracts.spans[0]"
test_criteria:
  assertion: "span.name == 'POST /api/register'"
  dql_query: "fetch spans | filter service.name == 'registration-service' | filter span.name == 'POST /api/register'"
```
