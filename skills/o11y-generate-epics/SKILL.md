---
name: o11y-generate-epics
description: Generate observability epics and stories for BMAD sprint planning. Use when the user says 'generate epics', 'create observability stories', or 'plan observability sprint'.
---

# Generate Observability Epics

## Overview

Generate a complete set of observability epics for sprint planning. Epics are created dynamically based on assessment findings — NOT from a static template. The epics reflect what THIS project actually needs.

## On Activation

1. Load config from `{project-root}/_bmad/config.yaml` — read the `o11y` section for `observability_backend`, `collector_deployment`, `primary_language`, and `o11y_artifacts`.
2. Load and execute the workflow file at `{project-root}/.claude/skills/o11y-engineer/assets/workflows/generate-observability-epics.yaml`.
3. If the workflow file is not available, follow the epic generation structure below.

## Epic Structure

This command produces 6 epics covering the full observability lifecycle:

1. **Assessment & Spec** — Maturity scoring + observability specification per service
2. **Collector Pipeline** — OTel Collector config, OTTL transforms, PII redaction, sampling
3. **Custom Collector** (optional) — Build optimized distribution with OCB
4. **Application Instrumentation** — Per-service OTel setup with validation
5. **Test Suite** — Trace/metric/PII test cases for the Test Architect (Murat)
6. **Last Mile** — SLI/SLO/KPI definition + Dynatrace dashboards, SLOs, workflows, alerting

## Dynamic Epic Generation Rules

- If the assessment finds no collector → generate collector epic
- If PII is a concern → generate PII redaction stories
- If custom collector needed → generate OCB build epic
- Always generate instrumentation epics per discovered service
- Always generate test suite epic for Murat
- Always generate Last Mile epic (SLI/SLO + Dynatrace) as the final gate

## Output

- Epic YAML files saved to `{o11y_artifacts}` directory
- Sprint plan with assignments (Bob, Amelia, Murat)
- Test contract for the Test Architect
- Stories in BMAD standard format (assignee, acceptance criteria, DQL assertions)

## Usage

Provide: project name, services list, backend, languages, and deployment model.

## Sprint Assignment

| Sprint | Epic | Owner |
|--------|------|-------|
| 1 | Assessment & Observability Spec | O11y Architect |
| 1-2 | Collector Pipeline (OTTL, PII, sampling) | O11y Architect → Amelia |
| 2 | Custom Collector Distribution (OCB) | O11y Architect → Amelia |
| 2-3 | Application Instrumentation (per-service) | Amelia |
| 3 | Observability Test Suite | Murat |
| 4 | **Last Mile**: SLI/SLO/KPI + Dynatrace | O11y Architect (direct) |

The Last Mile epic is a **quality gate** — it only starts after all tests pass (score >= 90).
