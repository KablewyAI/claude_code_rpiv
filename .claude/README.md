# .claude Directory

This directory contains Claude Code configurations: custom agents, commands, hooks, resources, and skills.

## Directory Structure

```
.claude/
├── README.md              # This file
├── settings.json          # Hook configurations
├── agents/                # Custom agent definitions (sub-agents)
├── commands/              # Slash commands (e.g., /commit, /ralph_research)
├── hooks/                 # Safety hooks (block destructive git, prod deploy, sensitive files)
├── resources/             # Knowledge base documents (add your own)
└── skills/                # Reusable skill bundles
```

## Agents

Custom agents that can be invoked via the Agent tool with `subagent_type`.

**Location:** `.claude/agents/<agent-name>.md`

| Agent | Purpose |
|-------|---------|
| `codebase-analyzer` | Deep analysis of how code works (implementation details, data flow) |
| `codebase-locator` | Find files and directories by feature/topic ("Super Grep") |
| `codebase-pattern-finder` | Find similar implementations and usage examples with code details |
| `validation-reviewer` | Review code changes against criteria, provide PASS/FAIL verdicts |
| `websearch-researcher` | Web research for up-to-date information |
| `thoughts-analyzer` | Deep dive analysis of thoughts/ documents |
| `thoughts-locator` | Find relevant documents in thoughts/ directory |

All agents follow the "documentarian, not critic" principle — they describe what IS, not what SHOULD BE.

## Commands

Slash commands that users invoke directly. See the top-level README for the full pipeline.

**Location:** `.claude/commands/<command-name>.md`

### RPIV Pipeline
| Command | Phase | Description |
|---------|-------|-------------|
| `/research_codebase` | Research | Single-pass codebase research |
| `/create_plan` | Plan | Interactive planning with user |
| `/implement_plan` | Implement | Guided phase-by-phase implementation |
| `/validate_plan` | Validate | Independent verification (PASS/FAIL) |
| `/iterate_plan` | Plan | Update existing plan with feedback |

### Ralph (Autonomous) Pipeline
| Command | Phase | Description |
|---------|-------|-------------|
| `/ralph` | Router | Smart entry point — assesses complexity, routes to right tier |
| `/ralph_research` | Research | Autonomous research — keeps iterating until thorough |
| `/ralph_plan` | Plan | Autonomous planning — iterates until bulletproof |
| `/ralph_impl` | Implement | Autonomous implementation — auto-retries, commits per phase |

### Supporting Commands
| Command | Description |
|---------|-------------|
| `/commit` | Create git commits with user approval (no AI attribution) |
| `/describe_pr` | Generate comprehensive PR description |
| `/finish_impl` | Push branches, create PRs, wrap up worktree |
| `/launch_impl` | Create isolated worktree and launch implementation |
| `/create_handoff` | Save session context for continuation |
| `/resume_handoff` | Continue from a previous handoff |
| `/debug` | Investigation only — read-only troubleshooting |
| `/tdd` | Test-driven development workflow |
| `/creative_thinking` | Structured creative thinking and ideation |

## Hooks

Safety hooks that block dangerous operations. Configured in `settings.json`.

| Hook | Blocks |
|------|--------|
| `block-destructive-git.sh` | Force push, hard reset, branch -D on protected branches, git clean -f, push to main |
| `block-prod-deploy.sh` | Bare `wrangler deploy` (must use `-e staging`) |
| `block-sensitive-files.sh` | Edits to .env, credentials, secrets, private keys |

## Skills

Reusable skill bundles providing specialized workflows.

**Location:** `.claude/skills/<skill-name>/SKILL.md`

| Skill | Description |
|-------|-------------|
| `skill-creator` | Guide for creating new skills |
| `template` | Starter template for new skills |
| `first-principles-review` | Challenge direction before planning (Hammock Driven Development) |
| `bugfix` | Structured bug investigation and fix workflow |
| `analyze-logs` | Parse and analyze log files |
| `ast-grep` | Structural code search using AST patterns |
| `agent-browser` | Browser automation for testing and data extraction |

## Adding Your Own

### New Agent
Create `.claude/agents/my-agent.md`:
```yaml
---
name: my-agent
description: What this agent does and when to use it.
tools: Read, Grep, Glob, LS
model: opus
---

Your agent instructions here...
```

### New Command
Create `.claude/commands/my_command.md`:
```yaml
---
description: Brief description of what this command does.
---

Your command instructions here...
```

### New Skill
Create `.claude/skills/my-skill/SKILL.md`:
```yaml
---
name: my-skill
description: What this skill does and when to use it.
---

Your skill instructions here...
```
