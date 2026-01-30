# Quick Start

Get from zero to production-grade observability using the B-MAD O11y Engineer agent.

## Prerequisites

- [B-MAD Method](https://github.com/bmad-code-org/BMAD-METHOD) installed (v6+)
- Node.js v20+
- AI assistant (Claude Code, Cursor, Windsurf, etc.)
- A project with at least one service to instrument

## Step 1: Install the Agent

See the [Installation Guide](installation.md) for detailed instructions. The quickest path:

```bash
npx bmad install https://github.com/henrikrexed/bmad-observability-agent
```

## Step 2: Start the Agent

=== "Claude Code"

    ```bash
    /bmad:o11y:agents:o11y-engineer
    ```

=== "Other AI Assistants"

    ```
    *o11y-engineer
    ```

## Step 3: Run the Assessment

Start by understanding your current observability state:

```
*assess-observability
```

The assessment evaluates:

- Signal coverage (traces, metrics, logs)
- Semantic convention compliance
- Collector configuration
- Production readiness
- Operational maturity

You'll receive a score from 0-100 with a prioritized improvement roadmap.

## Step 4: Follow the 8-Phase Workflow

Based on your assessment, follow the [recommended 8-phase workflow](workflow/recommended-workflow.md):

1. **Assessment** (done) -- You know where you stand
2. **Observability Spec** -- Define what telemetry your services need
3. **Collector Configuration** -- Build the OTel Collector pipeline
4. **CI/CD with Weaver** -- Automate semconv validation
5. **SLO Definition** -- Set performance/reliability/availability targets
6. **MCP Rules** -- Generate IDE integration for your team
7. **Implementation** -- Hand off to dev agents for instrumentation
8. **Validation** -- Verify everything works against the spec

## Step 5: Validate

After implementation, validate that your telemetry matches the spec:

```
*validate-traces
```

This runs the mandatory 5-step Query Validation Gate and produces a detailed report.

## Common First Commands

| Command | Purpose |
|---------|---------|
| `*assess-observability` | Evaluate current observability maturity |
| `*generate-observability-spec` | Create observability specifications |
| `*configure-pipeline` | Design OTel Collector pipeline |
| `*define-slos` | Define SLOs and KPIs |
| `*check-quality` | Run quality checks (0-100 score) |
| `*quick-start` | Full guided setup from scratch |

## Next Steps

- Read the [Recommended Workflow](workflow/recommended-workflow.md) for the full process
- Explore [Collector Best Practices](features/collector-best-practices.md)
- Learn about [Cross-Agent Integration](integration/bmad-agents.md)
- Set up [Dynatrace Assets](features/dynatrace-assets.md)
