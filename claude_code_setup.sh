#!/bin/bash

# Claude Code specific setup script
# This script is optimized for running in Claude Code

set -e

clear

cat << 'BANNER'
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   B-MAD Observability Agent Setup for Claude Code       ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
BANNER

echo ""
echo "This script will guide you through the complete setup."
echo "Optimized for Claude Code workflow."
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."
echo ""

if ! command_exists git; then
    echo "❌ Git is not installed"
    exit 1
else
    echo "✅ Git found"
fi

if ! command_exists python3; then
    echo "⚠️  Python3 not found (needed for YAML validation)"
else
    echo "✅ Python3 found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Initialize git if needed
if [ ! -d ".git" ]; then
    echo "📁 Initializing git repository..."
    git init
    git branch -M main
    echo "✅ Git initialized"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Create Workflows"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -f "create_all_workflows.sh" ]; then
    echo "❌ create_all_workflows.sh not found"
    exit 1
fi

chmod +x create_all_workflows.sh
./create_all_workflows.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Assemble Agent File"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "build_agent_interactive.sh" ]; then
    echo "Found interactive agent builder!"
    echo ""
    read -p "Run interactive agent builder? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        chmod +x build_agent_interactive.sh
        ./build_agent_interactive.sh
    else
        echo ""
        echo "Skipping interactive builder."
        echo "You'll need to manually assemble the agent file."
        echo ""
        echo "Files to copy:"
        echo "  1. agent_part3_prompts.yaml → agent/o11y-engineer.agent.yaml"
        echo "  2. agent_part4_prompts.yaml → agent/o11y-engineer.agent.yaml"
        echo "  3. agent_part5_prompts.yaml → agent/o11y-engineer.agent.yaml"
        echo ""
        echo "Then run:"
        echo "  ./create_agent_part6.sh"
        echo "  ./create_agent_part7.sh"
        echo ""
        read -p "Press Enter to continue..."
    fi
else
    echo "⚠️  Interactive builder not found"
    echo "You'll need to manually assemble the agent file"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -f "agent/o11y-engineer.agent.yaml" ]; then
    echo "⚠️  Agent file not found yet"
    echo "Complete Steps 2 before validation"
else
    echo "Running validation checks..."
    echo ""
    
    # Check file size
    FILE_SIZE=$(du -h agent/o11y-engineer.agent.yaml | awk '{print $1}')
    LINE_COUNT=$(wc -l < agent/o11y-engineer.agent.yaml)
    
    echo "📊 File Statistics:"
    echo "   Size: $FILE_SIZE"
    echo "   Lines: $LINE_COUNT"
    
    if [ "$LINE_COUNT" -lt 3000 ]; then
        echo "   ⚠️  Warning: File seems small (expected 5000+ lines)"
    else
        echo "   ✅ File size looks good"
    fi
    
    # Check prompt count
    PROMPT_COUNT=$(grep -c "^  - id:" agent/o11y-engineer.agent.yaml || echo "0")
    echo "   Prompts: $PROMPT_COUNT"
    
    if [ "$PROMPT_COUNT" -eq 19 ]; then
        echo "   ✅ Correct number of prompts"
    else
        echo "   ⚠️  Expected 19 prompts, found $PROMPT_COUNT"
    fi
    
    # Validate YAML
    echo ""
    echo "Validating YAML syntax..."
    if command_exists python3; then
        if python3 -c "import yaml; yaml.safe_load(open('agent/o11y-engineer.agent.yaml'))" 2>/dev/null; then
            echo "✅ YAML syntax is valid"
        else
            echo "❌ YAML syntax error detected"
            echo "Run: python3 -c \"import yaml; yaml.safe_load(open('agent/o11y-engineer.agent.yaml'))\""
            echo "to see the error"
        fi
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Setup Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check what's completed
WORKFLOW_COUNT=$(ls -1 workflows/*.yaml 2>/dev/null | wc -l)

echo "✅ Directory structure created"
echo "✅ Workflow files: $WORKFLOW_COUNT/10"

if [ -f "agent/o11y-engineer.agent.yaml" ]; then
    if [ "$PROMPT_COUNT" -eq 19 ]; then
        echo "✅ Agent file: Complete (19 prompts)"
    else
        echo "⚠️  Agent file: Incomplete ($PROMPT_COUNT/19 prompts)"
    fi
else
    echo "⚠️  Agent file: Not created yet"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -f "agent/o11y-engineer.agent.yaml" ] || [ "$PROMPT_COUNT" -ne 19 ]; then
    echo "Complete agent assembly:"
    echo "  1. Copy Parts 3-5 content to agent file"
    echo "  2. Run: ./create_agent_part6.sh"
    echo "  3. Run: ./create_agent_part7.sh"
    echo "  4. Validate again"
    echo ""
fi

echo "When ready to commit:"
echo "  git add ."
echo "  git commit -m 'feat: complete B-MAD observability agent'"
echo ""
echo "To push to GitHub:"
echo "  git remote add origin https://github.com/henrikrexed/bmad-observability-agent.git"
echo "  git push -u origin main"
echo ""
echo "For detailed help, see: SETUP_GUIDE.md"
echo ""

