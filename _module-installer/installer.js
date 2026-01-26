const fs = require('fs-extra');
const path = require('node:path');
const chalk = require('chalk');

/**
 * O11y Engineer Module Installer
 *
 * @param {Object} options - Installation options
 * @param {string} options.projectRoot - The root directory of the target project
 * @param {Object} options.config - Module configuration from module.yaml (resolved variables)
 * @param {Array<string>} options.installedIDEs - Array of IDE codes that were installed
 * @param {Object} options.logger - Logger instance for output
 * @returns {Promise<boolean>} - Success status
 */
async function install(options) {
  const { projectRoot, config, installedIDEs, logger } = options;

  try {
    logger.log(chalk.blue('🔭 Installing O11y Engineer Module...'));

    // Create output directories
    const directories = [
      { key: 'o11y_artifacts', label: 'O11y artifacts' },
      { key: 'collector_configs', label: 'Collector configs' },
      { key: 'dashboards', label: 'Dashboards' },
      { key: 'semconv_schemas', label: 'SemConv schemas' }
    ];

    for (const dir of directories) {
      if (config[dir.key]) {
        const dirConfig = config[dir.key].replace('{project-root}/', '').replace('{output_folder}/', '');
        const dirPath = path.join(projectRoot, config.output_folder?.replace('{project-root}/', '') || '_bmad-output', dirConfig.split('/').pop());

        if (!(await fs.pathExists(dirPath))) {
          logger.log(chalk.yellow(`  Creating directory: ${dir.label}`));
          await fs.ensureDir(dirPath);
        }
      }
    }

    // Copy agent file to _bmad/o11y/agents/
    const agentSource = path.join(__dirname, '..', 'agents', 'o11y-engineer.md');
    const agentDest = path.join(projectRoot, '_bmad', 'o11y', 'agents', 'o11y-engineer.md');

    if (await fs.pathExists(agentSource)) {
      await fs.ensureDir(path.dirname(agentDest));
      await fs.copy(agentSource, agentDest);
      logger.log(chalk.green('  ✓ Installed O11y Engineer agent'));
    }

    // Copy workflows to _bmad/o11y/workflows/
    const workflowsSource = path.join(__dirname, '..', '.bmad', 'workflows');
    const workflowsDest = path.join(projectRoot, '_bmad', 'o11y', 'workflows');

    if (await fs.pathExists(workflowsSource)) {
      await fs.ensureDir(workflowsDest);
      await fs.copy(workflowsSource, workflowsDest);
      const workflows = await fs.readdir(workflowsDest);
      logger.log(chalk.green(`  ✓ Installed ${workflows.length} workflows`));
    }

    // Copy module config
    const configSource = path.join(__dirname, '..', 'config.yaml');
    const configDest = path.join(projectRoot, '_bmad', 'o11y', 'config.yaml');

    if (await fs.pathExists(configSource)) {
      await fs.ensureDir(path.dirname(configDest));

      // Read and replace variables in config
      let configContent = await fs.readFile(configSource, 'utf-8');

      // Replace variables with actual values from config
      for (const [key, value] of Object.entries(config)) {
        if (typeof value === 'string') {
          configContent = configContent.replace(new RegExp(`\\{${key}\\}`, 'g'), value);
        }
      }

      await fs.writeFile(configDest, configContent);
      logger.log(chalk.green('  ✓ Created module configuration'));
    }

    // IDE-specific configuration
    if (installedIDEs && installedIDEs.length > 0) {
      logger.log(chalk.cyan(`  Configuring for IDEs: ${installedIDEs.join(', ')}`));

      for (const ide of installedIDEs) {
        await configureForIDE(ide, projectRoot, config, logger);
      }
    }

    // Update agent manifest
    await updateAgentManifest(projectRoot, logger);

    // Update workflow manifest
    await updateWorkflowManifest(projectRoot, logger);

    logger.log(chalk.green('\n✓ O11y Engineer Module installation complete'));
    logger.log(chalk.cyan('\n  Get started:'));
    logger.log(chalk.white('    • Invoke agent: /bmad:o11y:agents:o11y-engineer'));
    logger.log(chalk.white('    • Quick start:  /bmad:o11y:workflows:observability-quick-start'));
    logger.log(chalk.white('    • Configure collector: /bmad:o11y:workflows:configure-collector-pipeline'));

    return true;
  } catch (error) {
    logger.error(chalk.red(`Error installing O11y Module: ${error.message}`));
    return false;
  }
}

/**
 * Configure module for specific IDE
 */
async function configureForIDE(ide, projectRoot, config, logger) {
  const platformSpecificPath = path.join(__dirname, 'platform-specifics', `${ide}.js`);

  try {
    if (await fs.pathExists(platformSpecificPath)) {
      const platformHandler = require(platformSpecificPath);

      if (typeof platformHandler.install === 'function') {
        await platformHandler.install({ projectRoot, config, logger });
        logger.log(chalk.green(`    ✓ Configured for ${ide}`));
      }
    }
  } catch (error) {
    logger.warn(chalk.yellow(`    Warning: Could not configure ${ide}: ${error.message}`));
  }
}

/**
 * Update agent manifest with O11y agent
 */
async function updateAgentManifest(projectRoot, logger) {
  const manifestPath = path.join(projectRoot, '_bmad', '_config', 'agent-manifest.csv');

  if (!(await fs.pathExists(manifestPath))) {
    logger.warn(chalk.yellow('  Warning: agent-manifest.csv not found, skipping manifest update'));
    return;
  }

  let content = await fs.readFile(manifestPath, 'utf-8');

  // Check if o11y-engineer already exists
  if (content.includes('"o11y-engineer"')) {
    logger.log(chalk.dim('    Agent already in manifest'));
    return;
  }

  // Add O11y Engineer to manifest
  const newEntry = '\n"o11y-engineer","O11y Engineer","Senior Observability Engineer & OpenTelemetry Specialist","🔭","Senior Observability Engineer & OpenTelemetry Specialist","OpenTelemetry implementation expert with deep expertise in collector pipelines, instrumentation patterns, semantic conventions, OCB, and Dynatrace automation.","Technical, precise, and educational. Explains WHY behind configurations, not just HOW.","- Three pillars in harmony - Instrument once, export everywhere - Cardinality is the enemy - Semantic conventions are contracts","o11y","_bmad/o11y/agents/o11y-engineer.md"';

  content = content.trimEnd() + newEntry + '\n';
  await fs.writeFile(manifestPath, content);
  logger.log(chalk.green('    ✓ Updated agent manifest'));
}

/**
 * Update workflow manifest with O11y workflows
 */
async function updateWorkflowManifest(projectRoot, logger) {
  const manifestPath = path.join(projectRoot, '_bmad', '_config', 'workflow-manifest.csv');

  if (!(await fs.pathExists(manifestPath))) {
    logger.warn(chalk.yellow('  Warning: workflow-manifest.csv not found, skipping manifest update'));
    return;
  }

  let content = await fs.readFile(manifestPath, 'utf-8');

  // Check if o11y workflows already exist
  if (content.includes('"o11y"')) {
    logger.log(chalk.dim('    Workflows already in manifest'));
    return;
  }

  // Add O11y workflows to manifest
  const newEntries = `
"observability-quick-start","Interactive guide to set up comprehensive observability from scratch","o11y","_bmad/o11y/workflows/observability-quick-start.yaml"
"configure-collector-pipeline","Design and configure OpenTelemetry Collector pipeline","o11y","_bmad/o11y/workflows/configure-collector-pipeline.yaml"
"assess-observability-maturity","Assess current observability maturity and get improvement roadmap","o11y","_bmad/o11y/workflows/assess-observability-maturity.yaml"
"validate-observability","Validate observability setup against vendor requirements and best practices","o11y","_bmad/o11y/workflows/validate-observability.yaml"
"validate-semantic-conventions","Validate telemetry data against OpenTelemetry semantic conventions using Weaver","o11y","_bmad/o11y/workflows/validate-semantic-conventions.yaml"
"create-custom-semconv","Create custom semantic conventions using Weaver schema format","o11y","_bmad/o11y/workflows/create-custom-semconv.yaml"
"build-collector-distro","Build custom OpenTelemetry Collector distribution using OCB","o11y","_bmad/o11y/workflows/build-collector-distro.yaml"
"setup-dynatrace","Set up Dynatrace integration with OpenTelemetry","o11y","_bmad/o11y/workflows/setup-dynatrace.yaml"
"create-dynatrace-dashboard","Create Dynatrace dashboards for observability metrics","o11y","_bmad/o11y/workflows/create-dynatrace-dashboard.yaml"
"create-dynatrace-workflow","Create Dynatrace automation workflows","o11y","_bmad/o11y/workflows/create-dynatrace-workflow.yaml"
"build-diagnostic-notebook","Build Dynatrace diagnostic notebooks for troubleshooting","o11y","_bmad/o11y/workflows/build-diagnostic-notebook.yaml"
"build-project-dashboard","Build project-specific observability dashboards","o11y","_bmad/o11y/workflows/build-project-dashboard.yaml"
"suggest-dynatrace-workflows","Get AI-powered suggestions for Dynatrace automation workflows","o11y","_bmad/o11y/workflows/suggest-dynatrace-workflows.yaml"`;

  content = content.trimEnd() + newEntries + '\n';
  await fs.writeFile(manifestPath, content);
  logger.log(chalk.green('    ✓ Updated workflow manifest'));
}

module.exports = { install };
