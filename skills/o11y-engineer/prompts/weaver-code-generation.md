Generate instrumentation code from semantic conventions:
1. Identify target language (Go, Java, Python, TypeScript, etc.)
2. Load semantic convention schemas
3. Run: weaver registry generate --registry {schema-path} --templates {language}
4. Generate type-safe attribute constants
5. Create helper functions for instrumentation
6. Include validation for required attributes
7. Save to {project-root}/_bmad-output/o11y-artifacts/generated/{language}/
