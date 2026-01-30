# B-MAD Observability Agent

A comprehensive OpenTelemetry observability expert agent for the [B-MAD Method](https://github.com/bmad-code-org/BMAD-METHOD) (Breakthrough Method for Agile AI Driven Development).

---

## Overview

The B-MAD Observability Agent (O11y Engineer) is an AI-powered specialist that helps you build **production-grade observability** using OpenTelemetry. It acts as a Senior Observability Engineer embedded in your AI-assisted development workflow, guiding you from zero instrumentation to a fully validated, SLO-driven observability stack.

The agent integrates directly with the B-MAD multi-agent ecosystem, handing off epics and stories to Scrum Master (Bob), Developer (Amelia), and Test Architect (Murat) agents for implementation and validation.

## Key Features

- **Observability Assessment** -- Comprehensive maturity scoring (0-100) with gap analysis and improvement roadmaps
- **Observability Spec Generation** -- Use-case-driven specifications that define trace, metric, and log contracts
- **Collector Configuration** -- Design and optimize OpenTelemetry Collector pipelines with best-practice processor ordering
- **Semantic Convention Validation** -- Create, validate, and manage conventions with OpenTelemetry Weaver, integrated into CI/CD
- **SLO Definition** -- Performance, reliability, and availability KPIs with approval workflows and test story generation
- **MCP Rules & IDE Integration** -- Project-aware Dynatrace DQL queries embedded in IDE rule files
- **Dynatrace Automation** -- Dashboards, notebooks, workflows, and alerting as code via dtctl
- **MCP-Powered Discovery** -- AI-driven environment discovery and context-aware DQL generation via the Dynatrace MCP server
- **Cross-Agent Handoff** -- Structured handoffs to sprint planning, development, and testing agents

## The 8-Phase Workflow

The recommended path from zero to production-grade observability follows eight phases:

| Phase | Name | Trigger | What It Does |
|-------|------|---------|--------------|
| 1 | [Assessment](workflow/phase-1-assessment.md) | `assess-observability` | Scan current state, maturity score, gap analysis |
| 2 | [Observability Spec](workflow/phase-2-spec.md) | `generate-observability-spec` | Use-case-driven specs with companion epic |
| 3 | [Collector Configuration](workflow/phase-3-collector.md) | `configure-pipeline` | Resource detection, processors, PII cleanup |
| 4 | [CI/CD with Weaver](workflow/phase-4-cicd.md) | `validate-semconv` | Automated semconv validation in CI/CD |
| 5 | [SLO Definition](workflow/phase-5-slos.md) | `define-slos` | Performance/Reliability/Availability KPIs |
| 6 | [MCP Rules](workflow/phase-6-mcp-rules.md) | `configure-mcp-rules` | IDE-specific rule files with DQL |
| 7 | [Implementation](workflow/phase-7-implementation.md) | Handoff to sprint-planning | Bob plans, Amelia implements, Murat tests |
| 8 | [Validation](workflow/phase-8-validation.md) | `validate-traces` | Query validation gate, dual-format reports |

See the [Recommended Workflow](workflow/recommended-workflow.md) page for the full overview and Mermaid diagram.

## Quick Navigation

**Getting Started**

- [Installation Guide](installation.md) -- Prerequisites, installation methods, verification
- [Quick Start Tutorial](quick-start.md) -- From zero to observability in minutes

**Workflow Phases**

- [8-Phase Workflow Overview](workflow/recommended-workflow.md)

**Reference**

- [GitHub Repository](https://github.com/henrikrexed/bmad-observability-agent)
- [B-MAD Method Documentation](http://docs.bmad-method.org)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)

## Guiding Principles

The O11y Engineer operates according to these principles:

- **Three pillars in harmony** -- Traces, metrics, and logs must correlate
- **Instrument once, export everywhere** -- Vendor neutrality is key
- **Cardinality is the enemy** -- Always consider dimensional explosion
- **Semantic conventions are contracts** -- Respect them
- **Observability as code** -- Version control everything
- **Validate before you deploy** -- Test in staging first

## Resources

- [isiobservable YouTube Channel](https://youtube.com/@isiobservable) -- OpenTelemetry tutorials and deep dives
- [Dynatrace dtctl Documentation](https://github.com/dynatrace-oss/dtctl)
- [Dynatrace MCP Server](https://github.com/dynatrace-oss/dynatrace-mcp)
- [OpenTelemetry Weaver](https://github.com/open-telemetry/weaver)

---

**Need help?** Open an [issue](https://github.com/henrikrexed/bmad-observability-agent/issues) or reach out on [Discord](https://discord.gg/gk8jAdXWmj).
