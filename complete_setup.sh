#!/bin/bash

# Complete setup script for B-MAD Observability Agent repository
# This creates ALL files needed and guides you through the process

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  B-MAD Observability Agent - Complete Repository Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -f "LICENSE" ]; then
    echo "⚠️  It looks like base files haven't been created yet."
    echo "   Make sure README.md and LICENSE exist first."
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Step 1: Create all workflows
echo "Step 1: Creating workflow files..."
if [ -f "create_all_workflows.sh" ]; then
    ./create_all_workflows.sh
else
    echo "❌ Error: create_all_workflows.sh not found"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 2: Guide for agent file
echo "Step 2: Agent file setup"
echo ""
echo "The agent file needs to be created in parts because it's very large."
echo ""
echo "You have two options:"
echo ""
echo "Option A - Interactive (Recommended):"
echo "  ./build_agent_interactive.sh"
echo ""
echo "Option B - Manual:"
echo "  1. Copy Parts 3-5 content from conversation"
echo "  2. Paste into agent/o11y-engineer.agent.yaml"
echo "  3. Run: ./create_agent_part6.sh"
echo "  4. Run: ./create_agent_part7.sh"
echo ""

read -p "Would you like to run the interactive agent builder now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "build_agent_interactive.sh" ]; then
        ./build_agent_interactive.sh
    else
        echo "❌ Error: build_agent_interactive.sh not found"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Repository structure:"
echo ""
echo "  ✅ README.md, LICENSE, .gitignore, CONTRIBUTING.md"
echo "  ✅ docs/installation.md"
echo "  ✅ workflows/ (10 workflow files)"
echo "  ✅ agent/o11y-engineer.agent.yaml (if completed)"
echo ""
echo "Next steps:"
echo ""
echo "  1. Review all files"
echo "  2. Customize as needed"
echo "  3. Initialize Git:"
echo "       git init"
echo "       git branch -M main"
echo "       git add ."
echo "       git commit -m 'feat: complete B-MAD observability agent'"
echo ""
echo "  4. Add GitHub remote:"
echo "       git remote add origin https://github.com/henrikrexed/bmad-observability-agent.git"
echo ""
echo "  5. Push to GitHub:"
echo "       git push -u origin main"
echo ""
echo "  6. Create issues for enhancements"
echo ""
echo "🎉 You're ready to go!"

