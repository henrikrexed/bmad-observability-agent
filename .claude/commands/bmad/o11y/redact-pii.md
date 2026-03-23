Configure PII and sensitive data redaction for your OpenTelemetry pipeline.

This command helps you:
1. Identify sensitive data in your telemetry (PII, credentials, financial data)
2. Configure OTTL-based redaction in the transform processor
3. Set up attribute allow/deny lists
4. Sanitize log bodies and database statements
5. Validate redaction is working correctly

Usage: Describe what sensitive data you need to protect and which signals (traces, logs, metrics) need redaction.

Reference: docs/features/sensitive-data.md
