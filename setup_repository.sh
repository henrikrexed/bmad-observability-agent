#!/bin/bash

# Complete repository setup script
# This creates ALL files needed for the B-MAD Observability Agent repository

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "B-MAD Observability Agent - Repository Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p agent
mkdir -p workflows
mkdir -p docs/examples
mkdir -p .github/workflows

echo "✅ Directory structure created"
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Repository structure created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Files created:"
echo "  ✅ README.md"
echo "  ✅ LICENSE"
echo "  ✅ .gitignore"
echo "  ✅ CONTRIBUTING.md"
echo "  ✅ docs/installation.md"
echo ""
echo "Scripts created:"
echo "  ✅ create_agent_part6.sh"
echo "  ✅ create_agent_part7.sh"
echo "  ✅ create_complete_agent.sh"
echo ""
echo "Next steps:"
echo "  1. Add Parts 1-5 content to agent/o11y-engineer.agent.yaml"
echo "  2. Run: ./create_complete_agent.sh"
echo "  3. Add workflow files"
echo "  4. Initialize git: git init"
echo "  5. Add remote: git remote add origin https://github.com/henrikrexed/bmad-observability-agent.git"
echo "  6. Commit: git add . && git commit -m 'Initial commit'"
echo "  7. Push: git push -u origin main"

