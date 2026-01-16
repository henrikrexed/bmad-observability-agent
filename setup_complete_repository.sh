#!/bin/bash
# setup_complete_repository.sh
# Complete setup script for B-MAD Observability Agent

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  B-MAD Observability Agent - Complete Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if we're in the right directory
if [ ! -d ".git" ]; then
    echo "📁 Initializing git repository..."
    git init
    git branch -M main
fi

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p agent
mkdir -p workflows
mkdir -p docs/examples
mkdir -p .github/workflows

# Step 1: Create all workflow files
echo ""
echo "Step 1: Creating workflow files..."
./create_all_workflows.sh

# Step 2: Show instructions for agent assembly
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Agent File Assembly"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "The agent file requires manual assembly of Parts 3-5."
echo ""
echo "In Claude Code, you can:"
echo ""
echo "1. Open agent_part3_prompts.yaml"
echo "2. Open agent_part4_prompts.yaml"
echo "3. Open agent_part5_prompts.yaml"
echo "4. Open agent/o11y-engineer.agent.yaml"
echo ""
echo "Then copy the content from each part file into the agent file."
echo ""
echo "OR use the interactive builder:"
echo "   ./build_agent_interactive.sh"
echo ""

read -p "Would you like to run the interactive agent builder now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./build_agent_interactive.sh
else
    echo ""
    echo "You can run it later with: ./build_agent_interactive.sh"
    echo ""
    echo "After assembling the agent file:"
    echo "  1. Run: ./create_agent_part6.sh"
    echo "  2. Run: ./create_agent_part7.sh"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Setup Progress"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Directory structure created"
echo "✅ Workflow files created (10 files)"
echo "✅ Helper scripts ready"
echo "✅ Documentation created"
echo ""
echo "⚠️  Pending: Agent file assembly (Parts 3-5)"
echo ""
echo "Next steps:"
echo "  1. Complete agent file assembly"
echo "  2. Validate: python3 -c \"import yaml; yaml.safe_load(open('agent/o11y-engineer.agent.yaml'))\""
echo "  3. Commit: git add . && git commit -m 'feat: complete B-MAD observability agent'"
echo "  4. Push: git push -u origin main"
echo ""
echo "See SETUP_GUIDE.md for detailed instructions"
