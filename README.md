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

## 🚀 Quick Start

### Prerequisites

- [B-MAD Method](https://github.com/bmad-code-org/BMAD-METHOD) installed (v6+)
- Node.js v20+
- AI assistant (Claude Code, Cursor, Windsurf, etc.)

### Installation

**Option 1: BMAD Installer (Recommended)**
```bash
# Install via BMAD CLI (requires BMAD Core installed)
npx bmad install https://github.com/henrikrexed/bmad-observability-agent

# Or if using npm package (coming soon)
npx bmad install @henrikrexed/bmad-o11y
```

The installer will:
- Copy agent and workflows to `_bmad/o11y/`
- Register in agent and workflow manifests
- Create IDE-specific command files (Claude Code, Cursor, Windsurf)
- Set up output directories

**Option 2: Manual Installation**
```bash
# Clone this repository
git clone https://github.com/henrikrexed/bmad-observability-agent.git

# Copy to your BMAD project
cp -r bmad-observability-agent/agents/ <your-project>/_bmad/o11y/agents/
cp -r bmad-observability-agent/.bmad/workflows/ <your-project>/_bmad/o11y/workflows/

# For Claude Code, also copy commands
mkdir -p <your-project>/.claude/commands/bmad/o11y
cp -r bmad-observability-agent/.claude/commands/bmad/o11y/* <your-project>/.claude/commands/bmad/o11y/
```

**Option 3: Git submodule**
```bash
# Add as submodule to your project
git submodule add https://github.com/henrikrexed/bmad-observability-agent.git .bmad-o11y

# Symlink the agent and workflows
ln -s ../.bmad-o11y/agents/o11y-engineer.md _bmad/o11y/agents/
ln -s ../.bmad-o11y/.bmad/workflows/*.yaml _bmad/o11y/workflows/
```

### First Use

**Claude Code:**
```bash
# Invoke the agent
/bmad:o11y:agents:o11y-engineer

# Or run a workflow directly
/bmad:o11y:workflows:observability-quick-start
```

**Other AI Assistants:**
```bash
# Invoke the agent
*o11y-engineer

# Start with quick-start for new projects
*quick-start

# Or assess existing observability
*assess-observability
```

## 📚 Documentation

**Full documentation:** [https://henrikrexed.github.io/bmad-observability-agent/](https://henrikrexed.github.io/bmad-observability-agent/)

- [Installation Guide](docs/installation.md)
- [Quick Start Tutorial](docs/quick-start.md)
- [Recommended 8-Phase Workflow](docs/workflow/recommended-workflow.md)
- [Cross-Agent Integration](docs/integration/bmad-agents.md)
- [Collector Best Practices](docs/features/collector-best-practices.md)
- [Dynatrace Assets](docs/features/dynatrace-assets.md)
- [All Commands Reference](docs/reference/commands.md)
- [Examples](docs/examples/)

## 🎯 Key Features

### Intelligent Intent Detection

Ask natural questions and get the right workflow:
```
You: "How do I know if my observability is good?"
Agent: *assess-observability
        Runs comprehensive quality checks and provides roadmap

You: "I need to create custom metrics"
Agent: *create-custom-semconv
        Guides you through semantic convention design with Weaver

You: "My collector keeps crashing"
Agent: *diagnose-pipeline
        Identifies issues and provides fixes
```

### Comprehensive Quality Checks

Run `*check-quality` to assess:
- ✅ Signal coverage (traces, metrics, logs)
- ✅ Semantic convention compliance
- ✅ Cardinality management
- ✅ Production readiness
- ✅ Operational maturity

Score: 0-100 with actionable recommendations

### Production-Grade Workflows

| Workflow | Purpose | Time |
|----------|---------|------|
| `*quick-start` | Complete observability setup from scratch | 2-4 weeks |
| `*assess-observability` | Maturity assessment + improvement roadmap | 30 min |
| `*configure-pipeline` | Design OTel Collector pipeline | 1-2 hours |
| `*build-collector-distro` | Build custom collector with OCB | 2-4 hours |
| `*validate-semconv` | Validate against semantic conventions | 1 hour |
| `*create-dt-dashboard` | Create Dynatrace dashboard as code | 30 min |
| `*build-project-dashboard` | Build dashboard with discovered metrics (MCP) | 15 min |
| `*build-diagnostic-notebook` | Build diagnostic notebook (MCP) | 15 min |
| `*suggest-workflows` | AI-suggested automation workflows (MCP) | 10 min |

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

This agent supports seamless handoff to other BMAD agents:

```bash
# Generate handoff for next agent
*generate-handoff

# Create epics/stories for tracking
*create-epic

# Get machine-readable status
*status-report

# Sync from previous agent session
*sync-status
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
# MCP-powered commands
*discover-services       # Find services in Dynatrace
*discover-metrics        # Find available metrics
*analyze-logs           # Analyze log patterns
*build-project-dashboard # Build dashboard with real metrics
*build-diagnostic-notebook # Build troubleshooting notebook
*suggest-workflows       # Get AI-suggested automations
```

## 📊 Example Output
```
*check-quality

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
    Fix: *validate-semconv

❌ FAILURES (3 checks):
  ✗ SLOs Not Configured (0/10 pts) 🚨 CRITICAL
    Fix: *configure-dt-alerting

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRIORITY ACTIONS TO REACH 95+ (PRODUCTION-READY)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. [CRITICAL] Configure SLOs (+10 pts)
   *configure-dt-alerting
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
