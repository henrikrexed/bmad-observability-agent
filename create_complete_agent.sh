#!/bin/bash

# Master script to create the complete agent file with all parts
# This will create the full o11y-engineer.agent.yaml with all 7 parts

set -e  # Exit on error

AGENT_FILE="agent/o11y-engineer.agent.yaml"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Creating Complete B-MAD Observability Agent"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if agent directory exists
if [ ! -d "agent" ]; then
    echo "Creating agent directory..."
    mkdir -p agent
fi

# Backup existing file if it exists
if [ -f "$AGENT_FILE" ]; then
    BACKUP_FILE="${AGENT_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "⚠️  Backing up existing agent file to: $BACKUP_FILE"
    cp "$AGENT_FILE" "$BACKUP_FILE"
fi

echo "📝 Creating agent file with all parts..."
echo ""

# Note: Parts 1-5 need to be added manually or via another script
# This script assumes you'll paste Parts 1-5 content first

echo "Step 1: Create base file with Parts 1-5 (metadata, menu, core prompts, Weaver)"
echo "        You need to add this content manually first"
echo ""
echo "Step 2: Run ./create_agent_part6.sh to add OCB prompts"
echo "Step 3: Run ./create_agent_part7.sh to add Dynatrace prompts"
echo ""
echo "Or run this script after pasting Parts 1-5 into $AGENT_FILE"
echo ""

read -p "Have you added Parts 1-5 to $AGENT_FILE? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please add Parts 1-5 first, then run this script again."
    exit 1
fi

# Run Part 6 script
if [ -f "create_agent_part6.sh" ]; then
    echo "Adding Part 6 (OCB Prompts)..."
    ./create_agent_part6.sh
else
    echo "❌ Error: create_agent_part6.sh not found"
    exit 1
fi

echo ""

# Run Part 7 script
if [ -f "create_agent_part7.sh" ]; then
    echo "Adding Part 7 (Dynatrace Prompts)..."
    ./create_agent_part7.sh
else
    echo "❌ Error: create_agent_part7.sh not found"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Complete agent file created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "File: $AGENT_FILE"
echo "Size: $(du -h $AGENT_FILE | awk '{print $1}')"
echo "Lines: $(wc -l < $AGENT_FILE)"
echo ""
echo "Next steps:"
echo "  1. Review the complete agent file"
echo "  2. Validate YAML syntax: yamllint $AGENT_FILE"
echo "  3. Add workflow files"
echo "  4. Commit and push to GitHub"

