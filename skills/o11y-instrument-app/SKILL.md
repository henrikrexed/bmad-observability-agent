---
name: o11y-instrument-app
description: Add OpenTelemetry instrumentation to applications with per-language guidance. Use when the user says 'instrument app', 'add telemetry', or 'setup opentelemetry sdk'.
---

# Instrument Application

## Overview

Add OpenTelemetry instrumentation to your application. This skill provides per-language guidance for both auto-instrumentation and manual SDK setup, covering traces, metrics, and logs.

## On Activation

1. Load config from `{project-root}/_bmad/config.yaml` — read the `o11y` section for `observability_backend`, `collector_deployment`, and `primary_language`.
2. Load and execute the workflow file at `{project-root}/.claude/skills/o11y-engineer/assets/workflows/instrument-application.yaml`.
3. If the workflow file is not available, follow the instrumentation process below.

## Instrumentation Process

1. **Detect** your application's language and framework
2. **Configure** auto-instrumentation or manual SDK setup
3. **Set up** proper resource attributes (service.name, environment, K8s metadata)
4. **Configure** exporters for your backend (Dynatrace, Grafana, Jaeger, etc.)
5. **Validate** instrumentation is producing correct telemetry

## Supported Languages

- **Node.js** — Auto-instrumentation, Express/Fastify/NestJS
- **Go** — SDK setup, context propagation, net/http/gin/echo
- **Python** — Auto-instrumentation, Flask/Django/FastAPI
- **Java** — Javaagent, Spring Boot, JVM properties
- **.NET** — Auto-instrumentation, ASP.NET Core

## Instrumentation Approaches

| Approach | Best For | Effort |
|----------|----------|--------|
| K8s Operator (Instrumentation CRD) | Kubernetes workloads | Low |
| eBPF (Odigos, Beyla) | Zero-code instrumentation | Low |
| Auto-instrumentation packages | Language-specific setup | Medium |
| Manual SDK | Custom spans and metrics | High |

## Usage

Describe your application (language, framework, deployment target) and desired signals (traces, metrics, logs).

## Reference

Per-language guides are available in the documentation:
- Node.js, Go, Python, Java, .NET
