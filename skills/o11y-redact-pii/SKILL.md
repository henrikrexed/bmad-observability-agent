---
name: o11y-redact-pii
description: Configure PII and sensitive data redaction for OpenTelemetry pipelines. Use when the user says 'redact pii', 'protect sensitive data', or 'configure data masking'.
---

# Redact PII & Sensitive Data

## Overview

Configure PII and sensitive data redaction for your OpenTelemetry pipeline. This skill helps you identify, design, and validate redaction strategies across all telemetry signals.

## On Activation

1. Load config from `{project-root}/_bmad/config.yaml` — read the `o11y` section for `observability_backend` and `o11y_artifacts`.
2. Load and execute the workflow file at `{project-root}/.claude/skills/o11y-engineer/assets/workflows/configure-pii-redaction.yaml`.
3. If the workflow file is not available, follow the redaction process below.

## Redaction Process

1. **Identify** sensitive data in your telemetry (PII, credentials, financial data)
2. **Design** OTTL-based redaction patterns in the transform processor
3. **Configure** attribute allow/deny lists
4. **Sanitize** log bodies and database statements
5. **Validate** redaction is working correctly

## Data Categories

| Category | Examples | Risk Level |
|----------|----------|------------|
| PII | Email, phone, name, SSN | Critical |
| Credentials | API keys, tokens, passwords | Critical |
| Financial | Credit card numbers, bank accounts | Critical |
| Session | Session IDs, cookies | High |
| Infrastructure | Internal IPs, hostnames | Medium |

## Redaction Techniques

- **OTTL `replace_pattern`** — Regex-based redaction of attribute values
- **OTTL `set`** — Replace entire attribute with "REDACTED"
- **OTTL `SHA256`** — Hash values for correlation without exposing data
- **OTTL `delete_key`** — Remove attributes entirely
- **OTTL `delete_matching_keys`** — Remove attributes matching a pattern
- **Attribute allow/deny lists** — Filter attributes at the processor level

## Compliance Standards

- GDPR (General Data Protection Regulation)
- HIPAA (Health Insurance Portability and Accountability Act)
- PCI DSS (Payment Card Industry Data Security Standard)
- SOX (Sarbanes-Oxley Act)

## Usage

Describe what sensitive data you need to protect and which signals (traces, logs, metrics) need redaction.
