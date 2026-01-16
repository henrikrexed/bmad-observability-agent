#!/bin/bash

# Interactive script to build the complete agent file
# This guides you through adding all parts

set -e

AGENT_FILE="agent/o11y-engineer.agent.yaml"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Interactive Agent File Builder"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create agent directory
mkdir -p agent

echo "This script will help you build the complete agent file in parts."
echo ""
echo "You'll need to copy content from the conversation for:"
echo "  - Part 3: Core observability prompts"
echo "  - Part 4: Collector & instrumentation prompts"
echo "  - Part 5: Weaver prompts"
echo ""
echo "Parts 6 and 7 will be added automatically by scripts."
echo ""

read -p "Ready to begin? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Exiting..."
    exit 0
fi

# Step 1: Copy base structure
echo ""
echo "Step 1: Creating base file structure..."
cp agent_parts_1_to_5.yaml "$AGENT_FILE"
echo "✅ Base structure created"

# Step 2: Guide user to add Part 3
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Add Part 3 (Core Observability Prompts)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Required prompts:"
echo "  - intent-detection"
echo "  - observability-quality-check"
echo "  - observability-issue-remediation"
echo "  - observability-best-practices"
echo ""
echo "Instructions:"
echo "  1. Go back to the conversation and find 'Part 3/7'"
echo "  2. Copy the YAML content for these prompts"
echo "  3. Open $AGENT_FILE in your editor"
echo "  4. Replace the 'placeholder' prompt with the real content"
echo ""

read -p "Press Enter when you've added Part 3 prompts..."

# Step 3: Guide user to add Part 4
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Add Part 4 (Collector & Instrumentation)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Required prompts:"
echo "  - adjust-instrumentation"
echo "  - auto-instrumentation"
echo "  - instrumentation-score"
echo "  - add-scrape-configuration"
echo "  - pipeline-diagnostics"
echo "  - cardinality-optimization"
echo "  - vendor-compatibility"
echo "  - export-configuration"
echo "  - config-comparison"
echo ""

read -p "Press Enter when you've added Part 4 prompts..."

# Step 4: Guide user to add Part 5
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Add Part 5 (Weaver Prompts)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Required prompts:"
echo "  - weaver-docs-generation"
echo "  - weaver-code-generation"
echo "  - weaver-registry-check"
echo "  - weaver-schema-diff"
echo "  - validate-telemetry-data"
echo ""

read -p "Press Enter when you've added Part 5 prompts..."

# Step 5: Add Part 6 automatically
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5: Adding Part 6 (OCB Prompts) - Automatic"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "create_agent_part6.sh" ]; then
    ./create_agent_part6.sh
else
    echo "⚠️  Warning: create_agent_part6.sh not found"
    echo "   Part 6 will need to be added manually"
fi

# Step 6: Add Part 7 automatically  
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 6: Adding Part 7 (Dynatrace Prompts) - Automatic"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "create_agent_part7.sh" ]; then
    ./create_agent_part7.sh
else
    echo "⚠️  Warning: create_agent_part7.sh not found"
    echo "   Part 7 will need to be added manually"
fi

# Final validation
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

FILE_SIZE=$(du -h "$AGENT_FILE" | awk '{print $1}')
LINE_COUNT=$(wc -l < "$AGENT_FILE")

echo "File: $AGENT_FILE"
echo "Size: $FILE_SIZE"
echo "Lines: $LINE_COUNT"
echo ""

if [ "$LINE_COUNT" -lt 1000 ]; then
    echo "⚠️  Warning: File seems small ($LINE_COUNT lines)"
    echo "   Expected: 5000+ lines for complete agent"
    echo "   Make sure you added all prompts from Parts 3-5"
else
    echo "✅ File size looks good!"
fi

echo ""
echo "Next step: Validate YAML syntax"
echo "  python3 -c \"import yaml; yaml.safe_load(open('$AGENT_FILE'))\""

