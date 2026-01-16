# Scripts Summary

All helper scripts for setting up the B-MAD Observability Agent repository.

## 🎯 Quick Reference

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `complete_setup.sh` | 🎬 Master script | First time setup |
| `create_all_workflows.sh` | Create all 10 workflow files | Setup workflows |
| `build_agent_interactive.sh` | Interactive agent file builder | Build agent file |
| `create_agent_part6.sh` | Add OCB prompts (Part 6) | After Parts 1-5 |
| `create_agent_part7.sh` | Add Dynatrace prompts (Part 7) | After Parts 1-6 |
| `create_complete_agent.sh` | Add Parts 6+7 together | After Parts 1-5 |

## 📝 Detailed Descriptions

### `complete_setup.sh` - Master Setup Script

**What it does:**
- Orchestrates the entire setup process
- Creates all workflow files
- Guides through agent file creation
- Provides next steps

**Usage:**
```bash
./complete_setup.sh
```

**When to use:** First time setting up the repository

---

### `create_all_workflows.sh` - Workflow Generator

**What it does:**
- Creates all 10 workflow YAML files
- Places them in `workflows/` directory
- Validates creation

**Workflows created:**
1. observability-quick-start.yaml
2. assess-observability-maturity.yaml
3. configure-collector-pipeline.yaml
4. validate-observability.yaml
5. validate-semantic-conventions.yaml
6. create-custom-semconv.yaml
7. build-collector-distro.yaml
8. setup-dynatrace.yaml
9. create-dynatrace-dashboard.yaml
10. create-dynatrace-workflow.yaml

**Usage:**
```bash
./create_all_workflows.sh
```

---

### `build_agent_interactive.sh` - Interactive Agent Builder

**What it does:**
- Guides you through building the complete agent file
- Prompts you to add Parts 3-5 (copy/paste from conversation)
- Automatically runs Part 6 and Part 7 scripts
- Validates the final file

**Usage:**
```bash
./build_agent_interactive.sh
```

**Prerequisites:** Have conversation open to copy Parts 3-5

---

### `create_agent_part6.sh` - OCB Prompts

**What it does:**
- Appends Part 6 (OpenTelemetry Collector Builder prompts)
- Adds 7 OCB-related prompts

**Prompts added:**
- ocb-add-component
- ocb-list-components
- ocb-validate-manifest
- ocb-build-binary
- ocb-build-image
- ocb-optimize-build
- ocb-version-comparison

**Usage:**
```bash
./create_agent_part6.sh
```

**Prerequisites:** Parts 1-5 must be in agent file

---

### `create_agent_part7.sh` - Dynatrace Prompts

**What it does:**
- Appends Part 7 (Dynatrace automation prompts)
- Adds 8 Dynatrace-related prompts

**Prompts added:**
- dtctl-setup
- dtctl-create-dashboard
- dtctl-create-notebook
- dtctl-run-query
- dtctl-configure-alerting
- dtctl-export-config
- dtctl-validate-config
- dtctl-synthetic-monitoring

**Usage:**
```bash
./create_agent_part7.sh
```

**Prerequisites:** Parts 1-6 must be in agent file

---

### `create_complete_agent.sh` - Combined Part 6+7

**What it does:**
- Runs both Part 6 and Part 7 scripts
- Validates final file
- Shows summary

**Usage:**
```bash
./create_complete_agent.sh
```

**Prerequisites:** Parts 1-5 in agent file, Part 6 & 7 scripts available

## 🔄 Typical Workflow

### First Time Setup
```bash
# 1. Run master setup
./complete_setup.sh

# 2. It will run create_all_workflows.sh automatically

# 3. It will offer to run build_agent_interactive.sh

# 4. Follow prompts to add Parts 3-5

# 5. Scripts automatically add Parts 6-7
```

### Manual Step-by-Step
```bash
# 1. Create workflows
./create_all_workflows.sh

# 2. Create agent base (Parts 1-2)
# Manually create agent/o11y-engineer.agent.yaml with structure

# 3. Add Parts 3-5
# Copy/paste from conversation into agent file

# 4. Add Part 6
./create_agent_part6.sh

# 5. Add Part 7
./create_agent_part7.sh

# OR combine steps 4-5:
./create_complete_agent.sh
```

## ✅ Validation

After running scripts:
```bash
# Check workflow files exist
ls -l workflows/*.yaml

# Check agent file
ls -lh agent/o11y-engineer.agent.yaml

# Validate YAML
python3 -c "import yaml; yaml.safe_load(open('agent/o11y-engineer.agent.yaml'))"

# Check line count (should be 5000+)
wc -l agent/o11y-engineer.agent.yaml
```

## 🐛 Troubleshooting

### Scripts won't run
```bash
chmod +x *.sh
```

### Agent file too small

Parts 3-5 are missing. You need to copy them from the conversation.

### Workflows not created

Run `create_all_workflows.sh` separately.

### YAML errors

Use yamllint or Python to find syntax errors:
```bash
yamllint agent/o11y-engineer.agent.yaml
```

## 📚 Additional Resources

- See `SETUP_GUIDE.md` for complete setup instructions
- See `SCRIPTS_README.md` for detailed script documentation
- Check conversation for Parts 3-5 content

## 🎉 Success Criteria

Your setup is complete when:
- ✅ All 10 workflow files created
- ✅ Agent file is 150-200KB
- ✅ Agent file has 5000+ lines
- ✅ YAML validates without errors
- ✅ All scripts executed successfully

