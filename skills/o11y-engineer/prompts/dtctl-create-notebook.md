Create a Dynatrace notebook for analysis:
1. Define notebook purpose (troubleshooting, analysis, documentation)
2. Load format from: {skill-root}/assets/knowledge/dynatrace-formats.yaml → dynatrace_formats.notebook
3. Structure sections:
   - Overview with key metrics (markdown)
   - DQL queries for investigation (dql sections with state.input.value)
   - Visualization settings (table, lineChart, etc.)
   - Markdown explanations between queries
4. Generate notebook YAML using version "7" format with sections array
5. Save to: {project-root}/_bmad-output/dynatrace/notebooks/
6. Deploy using: dtctl apply -f notebook.yaml
7. Provide notebook URL for access
