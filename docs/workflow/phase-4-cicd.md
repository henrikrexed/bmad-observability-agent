# Phase 4: CI/CD with Weaver

**Command:** `*validate-semconv`

**Goal:** Integrate OpenTelemetry Weaver into the CI/CD pipeline for automated semantic convention validation.

## What Is Weaver?

[OpenTelemetry Weaver](https://github.com/open-telemetry/weaver) is a tool for managing semantic conventions. It can:

- Validate telemetry schemas against OTel semantic conventions
- Generate type-safe code from convention definitions
- Enforce naming standards in CI/CD pipelines
- Detect breaking changes in custom conventions

## Workflow

### Step 1: Create Weaver Schema

Define your service's semantic conventions in Weaver format:

```yaml
# semconv/registry/http-server.yaml
groups:
  - id: registry.http.server
    type: attribute_group
    brief: "HTTP server semantic conventions"
    attributes:
      - id: http.route
        type: string
        brief: "The matched route template"
        examples: ["/api/users/{id}", "/api/register"]
        requirement_level: required
      - id: http.method
        type: string
        brief: "HTTP request method"
        examples: ["GET", "POST", "PUT"]
        requirement_level: required
```

### Step 2: Configure Weaver Validation

Create a Weaver configuration file:

```yaml
# .weaver/weaver.yaml
templates:
  - source: semconv/registry/
    output: docs/semconv/
    format: markdown

policies:
  - name: require-brief
    rule: "All attributes must have a brief description"
  - name: require-examples
    rule: "All string attributes must have examples"
  - name: no-deprecated
    rule: "No deprecated attributes allowed"
```

### Step 3: Add to CI/CD Pipeline

=== "GitHub Actions"

    ```yaml
    name: Validate Semantic Conventions
    on: [push, pull_request]

    jobs:
      validate-semconv:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Install Weaver
            run: |
              curl -L https://github.com/open-telemetry/weaver/releases/latest/download/weaver-linux-amd64 -o weaver
              chmod +x weaver

          - name: Validate conventions
            run: ./weaver registry check semconv/registry/

          - name: Generate documentation
            run: ./weaver registry generate --templates .weaver/templates/ --output docs/semconv/
    ```

=== "GitLab CI"

    ```yaml
    validate-semconv:
      stage: validate
      script:
        - curl -L https://github.com/open-telemetry/weaver/releases/latest/download/weaver-linux-amd64 -o weaver
        - chmod +x weaver
        - ./weaver registry check semconv/registry/
    ```

### Step 4: Generate Type-Safe Code

Weaver can generate instrumentation helpers in multiple languages:

```bash
# Generate Go code
weaver registry generate \
  --templates .weaver/templates/go/ \
  --output pkg/telemetry/

# Generate TypeScript code
weaver registry generate \
  --templates .weaver/templates/typescript/ \
  --output src/telemetry/
```

## Benefits

- **Catch convention violations** before they reach production
- **Auto-generate documentation** from convention definitions
- **Type-safe instrumentation** reduces runtime errors
- **Breaking change detection** when updating conventions

## Output

- Weaver configuration file
- CI/CD pipeline configuration
- Generated type-safe instrumentation code (optional)
- Semantic convention documentation

## Next Step

After setting up CI/CD validation, proceed to [Phase 5: SLO Definition](phase-5-slos.md) to define performance, reliability, and availability targets.
