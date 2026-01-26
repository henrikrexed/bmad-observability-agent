const fs = require('fs-extra');
const path = require('node:path');
const chalk = require('chalk');

/**
 * Configure O11y module for Claude Code
 *
 * Creates command files in .claude/commands/bmad/o11y/ for:
 * - Agent invocation
 * - All workflow invocations
 */
async function install(options) {
  const { projectRoot, config, logger } = options;

  try {
    logger.log(chalk.dim('    Configuring Claude Code integration...'));

    const commandsDir = path.join(projectRoot, '.claude', 'commands', 'bmad', 'o11y');

    // Create command directories
    await fs.ensureDir(path.join(commandsDir, 'agents'));
    await fs.ensureDir(path.join(commandsDir, 'workflows'));

    // Generate agent command file
    const agentCommand = `---
name: 'o11y-engineer'
description: 'O11y Engineer agent - OpenTelemetry observability expert'
---

You must fully embody this agent's persona and follow all activation instructions exactly as specified. NEVER break character until given an exit command.

<agent-activation CRITICAL="TRUE">
1. LOAD the FULL agent file from @_bmad/o11y/agents/o11y-engineer.md
2. READ its entire contents - this contains the complete agent persona, menu, and instructions
3. Execute ALL activation steps exactly as written in the agent file
4. Follow the agent's persona and menu system precisely
5. Stay in character throughout the session
</agent-activation>
`;

    await fs.writeFile(
      path.join(commandsDir, 'agents', 'o11y-engineer.md'),
      agentCommand
    );

    // Define workflows with their descriptions
    const workflows = [
      { name: 'observability-quick-start', desc: 'Interactive guide to set up comprehensive observability from scratch' },
      { name: 'configure-collector-pipeline', desc: 'Design and configure OpenTelemetry Collector pipeline' },
      { name: 'assess-observability-maturity', desc: 'Assess current observability maturity and get improvement roadmap' },
      { name: 'validate-observability', desc: 'Validate observability setup against vendor requirements and best practices' },
      { name: 'validate-semantic-conventions', desc: 'Validate telemetry data against OpenTelemetry semantic conventions using Weaver' },
      { name: 'create-custom-semconv', desc: 'Create custom semantic conventions using Weaver schema format' },
      { name: 'build-collector-distro', desc: 'Build custom OpenTelemetry Collector distribution using OCB' },
      { name: 'setup-dynatrace', desc: 'Set up Dynatrace integration with OpenTelemetry' },
      { name: 'create-dynatrace-dashboard', desc: 'Create Dynatrace dashboards for observability metrics' },
      { name: 'create-dynatrace-workflow', desc: 'Create Dynatrace automation workflows' },
      { name: 'build-diagnostic-notebook', desc: 'Build Dynatrace diagnostic notebooks for troubleshooting' },
      { name: 'build-project-dashboard', desc: 'Build project-specific observability dashboards' },
      { name: 'suggest-dynatrace-workflows', desc: 'Get AI-powered suggestions for Dynatrace automation workflows' }
    ];

    // Generate workflow command files
    for (const workflow of workflows) {
      const workflowCommand = `---
name: '${workflow.name}'
description: '${workflow.desc}'
---

IT IS CRITICAL THAT YOU FOLLOW THESE STEPS:

<workflow-activation CRITICAL="TRUE">
1. LOAD the O11y Engineer agent persona from @_bmad/o11y/agents/o11y-engineer.md
2. LOAD the workflow from @_bmad/o11y/workflows/${workflow.name}.yaml
3. READ its entire contents - this contains the complete workflow steps
4. Execute ALL steps exactly as written in the workflow file
5. Stay in O11y Engineer character throughout the session
6. Guide the user through each step interactively
</workflow-activation>
`;

      await fs.writeFile(
        path.join(commandsDir, 'workflows', `${workflow.name}.md`),
        workflowCommand
      );
    }

    logger.log(chalk.green(`    ✓ Created ${workflows.length + 1} Claude Code commands`));
    return true;
  } catch (error) {
    logger.warn(chalk.yellow(`    Warning: Claude Code setup failed: ${error.message}`));
    return false;
  }
}

module.exports = { install };
