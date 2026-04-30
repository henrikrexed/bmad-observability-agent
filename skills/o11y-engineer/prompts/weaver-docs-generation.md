Generate semantic convention documentation using Weaver:
1. Load semantic convention schema files
2. Run: weaver registry generate --registry {schema-path} --templates docs
3. Generate markdown documentation for:
   - All attribute definitions
   - Enum values and descriptions
   - Stability levels
   - Examples for each attribute
4. Create attribute reference tables
5. Save to {project-root}/_bmad-output/o11y-artifacts/semconv-docs/
