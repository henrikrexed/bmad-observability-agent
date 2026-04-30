# B-MAD Observability Agent

A comprehensive OpenTelemetry observability expert agent for B-MAD (Breakthrough Method for Agile AI Driven Development).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![B-MAD](https://img.shields.io/badge/B--MAD-Agent-blue)](https://github.com/bmad-code-org/BMAD-METHOD)
[![Documentation](https://img.shields.io/badge/docs-MkDocs-blue)](https://henrikrexed.github.io/bmad-observability-agent/)

## 🎯 What is this?

The B-MAD Observability Agent is an AI-powered expert that helps you build production-grade observability using OpenTelemetry. It provides:

- **🚀 Quick Start**: Interactive setup for observability from scratch
- **📊 Quality Assessment**: Comprehensive maturity scoring and improvement roadmaps
- **⚙️ Collector Configuration**: Design and optimize OpenTelemetry Collector pipelines
- **🎯 Instrumentation**: Configure auto-instrumentation and semantic conventions
- **🏗️ Custom Builds**: Build optimized collector distributions with OCB
- **📋 Semantic Conventions**: Create, validate, and manage conventions with Weaver
- **🔧 Dynatrace Integration**: Full automation with dtctl (dashboards, workflows, alerting)
- **🤖 MCP-Powered Discovery**: AI-driven environment discovery and context-aware DQL generation
- **✅ Quality Checks**: Automated validation and issue remediation
- **🔄 OTTL Transformations**: Expert guidance for writing OTTL expressions (transform, filter, routing)
- **🔒 PII & Sensitive Data**: Redaction strategies for telemetry pipelines (emails, credentials, PII)
- **💻 SDK Instrumentation**: Per-language setup guides (Node.js, Go, Python, Java, .NET)
- **📋 Sprint-Ready Epics**: Generate observability epics for BMAD sprint planning
- **🏁 Last Mile**: SLI/SLO/KPI definition + Dynatrace dashboards, SLOs, workflows via dtctl

## 🚀 Quick Start

### Prerequisites

- [B-MAD Method](https://github.com/bmad-code-org/BMAD-METHOD) installed (v6+)
- Node.js v20+
- AI assistant (Claude Code, Cursor, Windsurf, etc.)

### Installation

```bash
# Install via BMad CLI (requires BMad Method v6.3+ installed)
npx bmad-method install --custom-source https://github.com/henrikrexed/bmad-observability-agent
```

The installer will:
- Install 6 skills to `.claude/skills/` (o11y-setup, o11y-engineer, o11y-write-ottl, o11y-generate-epics, o11y-instrument-app, o11y-redact-pii)
- Run the setup skill to configure your observability backend, collector deployment, and language preferences
- Register capabilities in the BMad help system

### First Use

Invoke the O11y Engineer agent:
```
/o11y-engineer
```

Or run a specific capability directly:
```
/o11y-write-ottl        # Generate OTTL expressions
/o11y-generate-epics    # Create sprint-ready epics
/o11y-instrument-app    # Add OTel to your app
/o11y-redact-pii        # Configure PII redaction
```

## 🏗️ Architecture: The Observability Architect

The O11y Engineer acts as an **Observability Architect** — it designs and plans but does not implement code directly. It generates epics and stories for the BMAD agent team:

```
O11y Architect                    BMAD Agent Team
     │                                 │
     ├── Assess maturity               │
     ├── Design observability spec     │
     ├── Design collector pipeline     │
     ├── Generate epics ──────────────►│ Bob (Scrum Master) plans sprints
     │                                 ├──► Amelia (Developer) implements
     │                                 ├──► Murat (Test Architect) tests
     │◄── Quality gate (score ≥ 90) ──┤
     │                                 │
     └── Last Mile (direct):           │
         → Define SLI/SLO/KPI         │
         → dtctl apply dashboards     │
         → dtctl apply SLOs           │
         → dtctl apply workflows      │
```

### Generated Epics

Running `/o11y-generate-epics` produces 6 epics across 4 sprints:

| Sprint | Epic | Owner |
|--------|------|-------|
| 1 | Assessment & Observability Spec | O11y Architect |
| 1-2 | Collector Pipeline (OTTL, PII, sampling) | O11y Architect → Amelia |
| 2 | Custom Collector Distribution (OCB) | O11y Architect → Amelia |
| 2-3 | Application Instrumentation (per-service) | Amelia |
| 3 | Observability Test Suite | Murat |
| 4 | **Last Mile**: SLI/SLO/KPI + Dynatrace | O11y Architect (direct) |

The Last Mile epic is a **quality gate** — it only starts after all tests pass (score ≥ 90).

## 📚 Documentation

**Full documentation:** [https://henrikrexed.github.io/bmad-observability-agent/](https://henrikrexed.github.io/bmad-observability-agent/)

- [Installation Guide](docs/installation.md)
- [Quick Start Tutorial](docs/quick-start.md)
- [Recommended 8-Phase Workflow](docs/workflow/recommended-workflow.md)
- [OTTL Transformation Guide](docs/features/ottl-guide.md)
- [Sensitive Data & PII](docs/features/sensitive-data.md)
- SDK Instrumentation: [Node.js](docs/features/sdk-instrumentation/nodejs.md) | [Go](docs/features/sdk-instrumentation/go.md) | [Python](docs/features/sdk-instrumentation/python.md) | [Java](docs/features/sdk-instrumentation/java.md) | [.NET](docs/features/sdk-instrumentation/dotnet.md)
- [Dynatrace Assets](docs/features/dynatrace-assets.md)
- [Cross-Agent Integration](docs/integration/bmad-agents.md)
- [Collector Best Practices](docs/features/collector-best-practices.md)
- [All Commands Reference](docs/reference/commands.md)
- [Examples](docs/examples/)

## 🎯 Key Features

### Intelligent Intent Detection

Ask natural questions via `/o11y-engineer` and get the right workflow:
```
You: "How do I know if my observability is good?"
Agent: Runs comprehensive quality checks and provides roadmap (QC menu)

You: "I need to create custom metrics"
Agent: Guides you through semantic convention design with Weaver (SC menu)

You: "My collector keeps crashing"
Agent: Identifies issues and provides fixes (DP menu)
```

### Comprehensive Quality Checks

Select `QC` from the O11y Engineer menu to assess:
- ✅ Signal coverage (traces, metrics, logs)
- ✅ Semantic convention compliance
- ✅ Cardinality management
- ✅ Production readiness
- ✅ Operational maturity

Score: 0-100 with actionable recommendations

### Production-Grade Workflows

| Capability | Purpose | Time |
|------------|---------|------|
| `/o11y-engineer` → `QS` | Complete observability setup from scratch | 2-4 weeks |
| `/o11y-engineer` → `AM` | Maturity assessment + improvement roadmap | 30 min |
| `/o11y-engineer` → `CP` | Design OTel Collector pipeline | 1-2 hours |
| `/o11y-engineer` → `BD` | Build custom collector with OCB | 2-4 hours |
| `/o11y-engineer` → `SC` | Validate against semantic conventions | 1 hour |
| `/o11y-engineer` → `DD` | Create Dynatrace dashboard as code | 30 min |
| `/o11y-engineer` → `PD` | Build dashboard with discovered metrics (MCP) | 15 min |
| `/o11y-engineer` → `DB` | Build diagnostic notebook (MCP) | 15 min |
| `/o11y-engineer` → `SW` | AI-suggested automation workflows (MCP) | 10 min |

## 💡 Use Cases

### For Homelab Enthusiasts
- Set up observability for Kubernetes clusters
- Monitor Proxmox infrastructure
- Build custom collectors for specific needs
- Integrate with Vault, TrueNAS, service meshes

### For Content Creators
- Create demo environments for videos
- Document observability best practices
- Show real-world configurations
- Build workshop materials

### For Production Environments
- Ensure production readiness (90+ quality score)
- Implement SLOs and alerting
- Automate incident response
- Reduce observability costs by 30-50%

## 🤝 Multi-Agent Collaboration (BMAD)

This agent supports seamless handoff to other BMAD agents via `/o11y-engineer`:

```bash
# Generate handoff for next agent
Select HO from the O11y Engineer menu

# Create epics/stories for tracking
/o11y-generate-epics

# Get machine-readable status
Select SR from the O11y Engineer menu

# Sync from previous agent session
Select SS from the O11y Engineer menu
```

**Handoff Output Example:**
```yaml
handoff:
  agent: "o11y-engineer"
  observability_status:
    overall_score: 78
    production_ready: false
  completed_actions:
    - action: "Configured OTel Collector"
      result: "success"
  pending_tasks:
    - task: "Add memory_limiter"
      priority: "critical"
  recommendations:
    immediate:
      - "Scale collector to 3 replicas"
```

## 🛠️ Agent Capabilities

### OpenTelemetry Collector
- Configure receivers, processors, exporters
- Build custom distributions with OCB
- Optimize for size and performance
- Multi-arch container images
- Version comparison and upgrades

### Instrumentation
- Auto-instrumentation (K8s Operator, eBPF)
- Manual SDK configuration
- Quality scoring (0-100)
- Semantic convention validation
- Best practices enforcement

### Semantic Conventions
- Create custom conventions with Weaver
- Generate type-safe code (Go, Python, Java, TypeScript)
- Validate telemetry data
- Schema versioning and migration
- Documentation generation

### Dynatrace Automation
- dtctl (kubectl-style CLI) configuration as code
- Dashboard creation and management
- Notebook generation
- Workflow automation (auto-remediation, incident response)
- DQL query execution
- SLO and alerting configuration
- Synthetic monitoring

### MCP-Powered Features (Recommended)
With the [Dynatrace MCP server](https://github.com/dynatrace-oss/dynatrace-mcp), the agent can:
- **Discover your environment** - Find actual services, hosts, and entities
- **Generate context-aware DQL** - Queries use real metric names and attributes
- **Build smart dashboards** - Based on metrics that exist in your environment
- **Create diagnostic notebooks** - With log/trace attributes from your data
- **Suggest workflows** - Based on recurring problems and patterns

```bash
# MCP-powered capabilities (via /o11y-engineer menu)
PD  # Build dashboard with real metrics
DB  # Build troubleshooting notebook
SW  # Get AI-suggested automations
```

### OTTL Transformations
- Write OTTL expressions for transform, filter, tail sampling, and routing
- All contexts: resource, scope, span, spanevent, metric, datapoint, log
- Cache/temp map patterns for complex parsing
- PII redaction, K8s enrichment, cardinality control, routing
- Debugging with `service.telemetry.logs.level: debug`

### Sensitive Data & PII Protection
- Identify PII, credentials, financial data in telemetry
- OTTL-based redaction (emails, credit cards, IPs, auth headers)
- Attribute allow/deny lists
- Log body sanitization and DB statement scrubbing
- GDPR, HIPAA, PCI-DSS compliance strategies

### Per-Language SDK Instrumentation
- **Node.js**: Auto-instrumentation, Express/Fastify/NestJS
- **Go**: SDK setup, context propagation, net/http/gin/echo
- **Python**: Auto-instrumentation, Flask/Django/FastAPI
- **Java**: Javaagent, Spring Boot, JVM properties
- **.NET**: Auto-instrumentation, ASP.NET Core

### Sprint-Ready Epic Generation
- Dynamic epic generation based on assessment findings
- 6 epics covering full observability lifecycle
- Stories in BMAD standard format (assignee, acceptance criteria, DQL assertions)
- Handoff to Bob (Scrum Master), Amelia (Developer), Murat (Test Architect)
- Quality gate before Last Mile (score ≥ 90)

## 📊 Example Output
```
/o11y-engineer → select QC

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OBSERVABILITY QUALITY REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Overall Score: 78/100 ⚠️  NEEDS IMPROVEMENT

✅ PASSED (18 checks):
  ✓ Traces Present (15/15 pts)
  ✓ Metrics Present (15/15 pts)
  ✓ Collector HA - 3 replicas (10/10 pts)
  ...

⚠️  WARNINGS (5 checks):
  ! Semantic Convention Compliance - 87% (12/15 pts)
    Target: 95%+
    Fix: /o11y-engineer → SC

❌ FAILURES (3 checks):
  ✗ SLOs Not Configured (0/10 pts) 🚨 CRITICAL
    Fix: /o11y-engineer → DA

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRIORITY ACTIONS TO REACH 95+ (PRODUCTION-READY)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. [CRITICAL] Configure SLOs (+10 pts)
   /o11y-engineer → DA
   Effort: 1 day
```

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- Built on [B-MAD Method](https://github.com/bmad-code-org/BMAD-METHOD)
- Created by [Henrik](https://github.com/henrikrexed) from [isiobservable](https://youtube.com/@isiobservable)
- OpenTelemetry community for semantic conventions and best practices

## 📺 Resources

- [isiobservable YouTube Channel](https://youtube.com/@isiobservable) - OpenTelemetry tutorials and deep dives
- [B-MAD Documentation](http://docs.bmad-method.org)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Dynatrace dtctl Documentation](https://github.com/dynatrace-oss/dtctl)
- [Dynatrace MCP Server](https://github.com/dynatrace-oss/dynatrace-mcp)

---

**Need help?** Open an [issue](https://github.com/henrikrexed/bmad-observability-agent/issues) or reach out on [Discord](https://discord.gg/gk8jAdXWmj)
