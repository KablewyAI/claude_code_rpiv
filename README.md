# Claude Code RPIV

A battle-tested methodology for AI-assisted software development. Separates research, planning, implementation, and validation into distinct phases with autonomous "Ralph Mode" for hands-off iteration.

**The core thesis: quality of output is directly tied to the quality of specification.**

When you tell an AI "add feature X," you're giving it an underspecified problem. It will fill in the gaps with assumptions — about your architecture, your conventions, your edge cases, your preferences. Some assumptions will be wrong. The resulting code will *work*, but it won't be *right*. RPIV exists to eliminate that gap between "works" and "right" by forcing specification to happen before implementation.

**Adapted from:**
- [No Vibes Allowed: Solving Hard Problems in Complex Codebases](https://www.youtube.com/watch?v=rmvDxxNubIg) — Dex Horthy, HumanLayer (AI Engineering Summit 2025)
- [HumanLayer's Claude Code setup](https://github.com/humanlayer/humanlayer/tree/main/.claude)
- [Ralph Wiggum Autonomous Loops](https://www.humanlayer.dev/blog/brief-history-of-ralph)

---

## Why This System Exists

### The Specification Problem

Most AI coding failures aren't intelligence failures — they're *specification* failures. The AI is smart enough to build what you ask for. The problem is that what you *ask for* and what you *actually need* are often different things.

Consider: "Add a delete button to the user profile page."

An AI hearing this will:
1. Find the profile page
2. Add a button
3. Wire it to a delete endpoint
4. Maybe add a confirmation dialog
5. Ship it

What it won't think about:
- Does your app use soft deletes or hard deletes?
- What happens to the user's data in other tables?
- Is there an admin audit trail requirement?
- Does your design system have a destructive-action button variant?
- Do you need to send a confirmation email?
- What about GDPR data deletion requirements?
- Does the user need to re-authenticate before deletion?
- What's the error state if deletion fails?

Each of these is an assumption the AI will make *silently*. Some will be right. Some will be wrong. You won't know which until you review the PR — and by then, the AI has already committed to an architecture that may be hard to undo.

**RPIV forces these assumptions to become explicit *before* a single line of code is written.**

### Why Phases Matter

When humans solve complex problems, we naturally separate thinking from doing. An architect doesn't start laying bricks while still deciding the floor plan. A surgeon doesn't cut while still reading the MRI. But when we work with AI, we collapse everything into a single prompt: "do this thing."

The research shows this doesn't work well:

- **Context contamination**: When an AI researches and implements simultaneously, its early findings bias its later investigation. It anchors on the first plausible approach and stops looking.
- **Sunk cost in code**: Once the AI has written 200 lines toward approach A, it's psychologically committed (and you've burned the tokens). It won't pivot to approach B even if B is clearly better.
- **Invisible assumptions**: Without a written plan, the AI's decisions are embedded in code. You can only review them by reverse-engineering the implementation — which is exactly the kind of work you hired the AI to avoid.
- **No objective verification**: The agent that wrote the code is constitutionally incapable of objectively reviewing it. It has all the context that makes its choices seem reasonable, including the reasoning it used to dismiss edge cases.

RPIV solves these by making each phase a discrete step with its own artifact:

| Phase | What It Does | Why It Matters |
|-------|-------------|----------------|
| **Research** | Documents how the codebase works *today* | Eliminates assumptions about existing architecture |
| **Plan** | Designs small, verifiable phases with explicit verification steps | Makes every decision reviewable *before* code exists |
| **Implement** | Executes the plan exactly, verifying each phase | Prevents drift from the agreed-upon approach |
| **Validate** | Fresh agent independently verifies against requirements | Catches what the implementer rationalizes away |

### The Compound Effect

Each artifact feeds the next:
- Research informs planning (no guessing about architecture)
- Plans constrain implementation (no improvisation)
- Implementation generates artifacts for validation (test results, diffs)
- Validation catches deviations before they reach `main`

Over time, these artifacts accumulate into an institutional memory:
- New team members (human or AI) can read past research docs
- Plans serve as architectural decision records (ADRs)
- Validation reports document what was checked and when
- Handoffs enable seamless session continuation

**The result: every significant change has a paper trail from "why" to "what" to "does it work."**

### Why Separate Validator from Implementer?

This is the single most impactful practice in the entire system. From [Anthropic's Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices):

> "A simple but effective approach is to have one Claude write code while another reviews or tests it. Sometimes having separate context is beneficial."

The implementer suffers from three biases:
1. **Confirmation bias**: "I know this works because I just wrote it"
2. **Context bias**: "This edge case doesn't apply because..." (citing reasoning the validator can't see)
3. **Completeness illusion**: "The tests prove it's correct" (but do they test what matters?)

The validator starts with *only* the plan's requirements. It reads the implementation cold. It runs tests without assumptions. It's looking for gaps between "what was promised" and "what was delivered."

In practice, validators catch:
- Tests that pass but assert nothing meaningful (mocking everything, testing implementation details)
- Missing error handling on failure paths
- Security issues the implementer didn't think about
- Requirements from the plan that were accidentally skipped
- Production failure modes (returning 401 when the database is down)

---

## Your CLAUDE.md Is Your Highest Leverage

RPIV gives you the pipeline. But the thing that sits *above* the pipeline — affecting every phase — is your `CLAUDE.md` file.

### The Leverage Hierarchy

```
  CLAUDE.md          1 bad line  →  cascades into everything below
    ↓
  Specification      1 bad line  →  many bad lines of research
    ↓
  Research           1 bad line  →  many bad lines of plan
    ↓
  Plan               1 bad line  →  hundreds of bad lines of code
    ↓
  Code               1 bad line  →  1 bad line of code
```

Your `CLAUDE.md` is loaded on **every single request**. It's the one thing you control that has the highest leverage after the model itself. One unnecessary or misleading line here can silently degrade everything downstream.

### The Instruction Budget

LLMs have a finite instruction-following capacity. Research shows accuracy degrades after roughly 150-250 instructions (depending on the model). The Claude Code system prompt uses about 50. That leaves approximately **200 instructions** for your `CLAUDE.md` + your plan + your prompt + anything else the agent reads.

This means every line of your `CLAUDE.md` is competing for a limited budget. Lines that don't pull their weight aren't just wasted — they're actively harmful, displacing instructions that matter.

### How to Write a Good CLAUDE.md

**Start small.** A new project's `CLAUDE.md` might be 10 lines: project description, key commands, one or two constraints that aren't obvious from the code. That's it.

**Add reactively.** When the model makes a specific mistake, add a rule to prevent it. When it doesn't make mistakes, don't add rules "just in case." Every rule you add that the model already follows natively is a wasted instruction.

**Remove proactively.** With every model release, audit your `CLAUDE.md` and remove instructions that newer models handle natively. If you wrote "always use TypeScript strict mode" for an older model that kept using `any`, the newer model probably doesn't need that reminder. Over-constraining a capable model makes it perform *worse* — you're overriding its better built-in practices with your potentially outdated ones.

**Use hooks instead of instructions.** If you write "never run `db push`" in your `CLAUDE.md`, the model will respect it ~97% of the time. If you write a pre-tool-use hook that blocks `db push`, it works 100% of the time. Convert hard constraints into hooks (see `.claude/hooks/`).

**Position matters.** LLMs weigh the beginning and end of instructions more than the middle. Put project description and key commands at the top. Put rarely-needed context in nested `CLAUDE.md` files.

### Split Into Nested CLAUDE.md Files

Your root `CLAUDE.md` is always loaded. But Claude Code also reads `CLAUDE.md` files from subdirectories when it reads files in those directories. This means:

```
project/
├── CLAUDE.md                    # Always loaded (keep lightweight)
├── backend/
│   └── CLAUDE.md                # Loaded when reading backend/ files
├── database/migrations/
│   └── CLAUDE.md                # Loaded when reading migration files
└── frontend/
    └── CLAUDE.md                # Loaded when reading frontend/ files
```

**Root `CLAUDE.md`**: Project overview, key commands, universal constraints. Keep it under 50 lines.

**Nested `CLAUDE.md` files**: Context-specific instructions. Migration workflows go in the database directory. API conventions go in the API directory. Build instructions go in the build directory. These are lazy-loaded — they only consume instruction budget when Claude is actually working in that part of the codebase.

This is powerful because your root `CLAUDE.md` can fade from attention late in a long conversation, but a nested `CLAUDE.md` is injected at exactly the right moment — when the model is reading files in that directory.

### What Does NOT Belong in CLAUDE.md

- **Things the model already knows**: "Use encryption for passwords," "validate user input," "handle errors gracefully." These waste instruction budget on things baked into the model.
- **Example code**: The model can read your actual codebase. Don't duplicate it.
- **Detailed API documentation**: Put it in a nested `CLAUDE.md` near the relevant code.
- **History of changes**: This isn't a changelog. Remove stale entries.
- **Random prompt tips from the internet**: Most viral tips add instructions the model already follows, or constrain it in ways that make it worse.

### The Audit Cycle

1. **On every model release**: Review each line. Can you remove it? Newer models may handle it natively.
2. **Weekly**: Check for conflicting instructions, outdated entries, things that should be in nested files.
3. **Version control**: Commit every `CLAUDE.md` change to git. If the model starts performing worse, you can `git bisect` to find which line caused it.

See `CLAUDE.md.template` for a ready-to-use starting point that embodies these principles.

### Auto-Memory vs CLAUDE.md

Claude Code has an auto-memory feature that stores per-user notes in `~/.claude/projects/<path>/memory/MEMORY.md`. This is loaded into context alongside your `CLAUDE.md`.

Key differences:

| | `CLAUDE.md` | Auto-Memory (`MEMORY.md`) |
|---|---|---|
| **Scope** | Shared (committed to git) | Personal (per-user, per-machine) |
| **Purpose** | Project conventions & constraints | User preferences & session learnings |
| **Management** | Manual, deliberate edits | Auto-updated by Claude (review periodically) |
| **Team use** | Everyone sees the same instructions | Each team member has their own |

**Best practice**: Manually review auto-memory periodically. The model doesn't always have the introspectiveness to decide what's truly worth remembering. Move architecture-level insights into your `CLAUDE.md` (shared with the team). Keep personal preferences (verbosity, explanation depth) in auto-memory.

You can also use `CLAUDE.local.md` for personal project-specific preferences that shouldn't be committed to git (add it to `.gitignore`).

---

## What is RPIV?

**RPIV** = **R**esearch -> **P**lan -> **I**mplement -> **V**alidate

```
                    ┌─────────────┐
                    │   Research   │  Understand the codebase today
                    │              │  Output: research doc
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │    Plan      │  Design verifiable phases
                    │              │  Output: plan doc (committed to main)
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Implement   │  Execute plan in isolated worktree
                    │              │  Output: code + passing tests
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Validate    │  Independent verification (fresh context)
                    │              │  Output: PASS / FAIL verdict
                    └─────────────┘
```

---

## What is Ralph Mode?

**Ralph Mode** adds autonomous iteration to each RPIV phase. Named after Ralph Wiggum from The Simpsons ("dim-witted but relentlessly optimistic and undeterred"), it keeps trying until the job is done.

| Standard RPIV | Ralph Mode |
|---------------|------------|
| Single-pass execution | Iterates until complete |
| Stops on uncertainty | Keeps exploring gaps |
| Manual phase transitions | Auto-chains to next phase |
| Human checks each step | Autonomous with safety limits |

**Origin:** Created by [Geoffrey Huntley](https://www.humanlayer.dev/blog/brief-history-of-ralph), formalized by Anthropic as an [official plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum).

---

## What's Included

This repo is a ready-to-use seed for any project. It includes:

### Agents (7 custom sub-agents)
Specialized agents that follow the "documentarian, not critic" principle — they describe what IS, not what SHOULD BE.

| Agent | Purpose |
|-------|---------|
| `codebase-analyzer` | Deep analysis of implementation details and data flow |
| `codebase-locator` | Find files by feature/topic ("Super Grep/Glob") |
| `codebase-pattern-finder` | Find similar implementations with concrete code examples |
| `validation-reviewer` | Review changes against criteria, PASS/FAIL verdicts |
| `websearch-researcher` | Web research for up-to-date information |
| `thoughts-analyzer` | Deep analysis of thoughts/ documents |
| `thoughts-locator` | Find relevant documents in thoughts/ directory |

### Commands (18 slash commands)

**Core RPIV Pipeline:**
- `/research_codebase` — Single-pass codebase research
- `/create_plan` — Interactive planning with user collaboration
- `/implement_plan` — Guided phase-by-phase implementation
- `/validate_plan` — Independent verification (PASS/FAIL verdict)
- `/iterate_plan` — Update existing plan with feedback

**Ralph (Autonomous) Pipeline:**
- `/ralph` — Smart router: assesses complexity, routes to right tier
- `/ralph_research` — Autonomous research (iterates until thorough)
- `/ralph_plan` — Autonomous planning (iterates until bulletproof)
- `/ralph_impl` — Autonomous implementation (auto-retries, commits per phase)

**Supporting Commands:**
- `/commit` — Create commits with user approval (no AI attribution)
- `/describe_pr` — Generate comprehensive PR description
- `/finish_impl` — Push branches, create PRs, wrap up worktree
- `/launch_impl` — Create isolated worktree and launch implementation
- `/create_handoff` — Save session context for continuation
- `/resume_handoff` — Continue from a previous handoff
- `/debug` — Investigation only (read-only troubleshooting)
- `/tdd` — Test-driven development workflow
- `/creative_thinking` — Structured creative thinking and ideation

### Safety Hooks (3 pre-tool-use hooks)
Configured in `settings.json`, these block dangerous operations *before* they execute:

| Hook | Blocks |
|------|--------|
| `block-destructive-git.sh` | Force push, hard reset, branch -D on protected branches, git clean -f, push to main |
| `block-prod-deploy.sh` | Bare `wrangler deploy` without `-e staging` |
| `block-sensitive-files.sh` | Edits to `.env`, credentials, secrets, private keys |

### Skills (7 reusable skill bundles)
- `skill-creator` — Guide for creating new skills
- `template` — Starter template for custom skills
- `first-principles-review` — Challenge direction before planning (Hammock Driven Development)
- `bugfix` — Structured bug investigation workflow
- `analyze-logs` — Parse and analyze log files
- `ast-grep` — Structural code search using AST patterns
- `agent-browser` — Browser automation for testing and data extraction

### Scripts (3 worktree management scripts)
- `create-impl-worktree.sh` — Create isolated implementation environment
- `cleanup-impl-worktree.sh` — Remove worktree and optionally delete branches
- `setup-worktree-thoughts.sh` — Symlink thoughts/ to share across worktrees

---

## Setup

### 1. Copy to Your Project

```bash
# Clone this repo
git clone https://github.com/KablewyAI/claude_code_rpiv.git

# Copy everything to your project
cp -r claude_code_rpiv/.claude /path/to/your/project/
cp -r claude_code_rpiv/scripts /path/to/your/project/
cp -r claude_code_rpiv/thoughts /path/to/your/project/

# Or use it as a starting point for a new project
cp -r claude_code_rpiv my-new-project
cd my-new-project && rm -rf .git && git init
```

### 2. Create Your CLAUDE.md

Copy and customize the template:
```bash
cp CLAUDE.md.template CLAUDE.md
```

The `CLAUDE.md` file is your project's instruction manual for Claude. It overrides default behavior. Be specific and opinionated — this is where you encode your project's conventions, constraints, and architectural decisions.

### 3. Initialize Thoughts Directory

```bash
mkdir -p thoughts/shared/{research,plans,validations,handoffs}
```

### 4. (Recommended) Add Playwright MCP

From [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices):

```bash
claude mcp add playwright -- npx @playwright/mcp@latest
```

Enables browser interaction during validation: screenshots, form testing, visual verification.

### 5. (Optional) Ralph Plugin for Autonomous Loops

```bash
/plugin marketplace add anthropics/claude-code
/plugin install ralph-wiggum@claude-plugins-official
```

---

## Quick Start

### Standard RPIV Flow (Interactive)
```bash
/research_codebase      # Understand what exists
/create_plan            # Design verifiable phases
/implement_plan         # Execute step by step
/validate_plan          # Independent verification
/commit                 # Stage and commit
/describe_pr            # Generate PR description
```

### Ralph Autonomous Flow
```bash
/ralph_research         # Keep iterating until thorough
/ralph_plan             # Keep refining until bulletproof
/ralph_impl             # Keep implementing until complete
/validate_plan          # Fresh agent verifies (always separate)
/finish_impl            # Push, create PRs
```

### Full Pipeline (Worktree Isolation)
```bash
# 1. Research and plan on main branch
/ralph_research "add user notifications"
/ralph_plan @thoughts/shared/research/2026-03-01_user-notifications.md
/commit  # Commit plan to main

# 2. Create isolated worktree for implementation
/launch_impl @thoughts/shared/plans/2026-03-01_user-notifications_plan.md

# 3. In the worktree session:
/ralph_impl @thoughts/shared/plans/2026-03-01_user-notifications_plan.md
/validate_plan @thoughts/shared/plans/2026-03-01_user-notifications_plan.md
/finish_impl  # Push branches, create PRs

# 4. Merge PRs on GitHub, then clean up
./scripts/cleanup-impl-worktree.sh user-notifications --delete-branches
```

### Supporting Commands
```bash
/create_handoff         # Save context for later
/resume_handoff         # Continue from handoff
/iterate_plan           # Update existing plan
/debug                  # Investigation only (no edits)
/tdd                    # Test-driven development
/creative_thinking      # Structured ideation
```

---

## The Specification Discipline

The most important thing this system does is force you (and the AI) to write things down.

### Research Forces Understanding

Before the AI touches your code, it documents how things work *today*:
- What components exist and how they connect
- What patterns and conventions are already established
- What test infrastructure exists
- What the actual data flow looks like (not what you *think* it looks like)

This catches the most common failure mode: the AI assuming your codebase works like a typical tutorial project when it actually has years of accumulated design decisions.

### Plans Make Decisions Reviewable

A plan is a specification. It says:
- "Here's what we're building" (desired end state)
- "Here's how we're building it" (phased approach)
- "Here's how we'll know it works" (verification commands per phase)
- "Here's what could go wrong" (risk assessment)
- "Here's how to undo it" (rollback plan)

You review the plan *before* any code exists. This is orders of magnitude cheaper than reviewing a PR with 500 lines of code that took the wrong approach. If the plan is wrong, you `/iterate_plan` with feedback. If it's right, the implementation is largely mechanical.

### Validation Closes the Loop

The validator doesn't just run tests — it reviews test quality:

```
HIGH SIGNAL: Tests verify behavior, would catch regressions → PASS
MEDIUM SIGNAL: Tests exist but have gaps → PASS WITH NOTES
LOW SIGNAL: Tests pass but don't verify anything → FAIL
NO TESTS: Missing test coverage → FAIL
```

It also checks production failure modes:
- Does a database outage return "Authentication failed"? (causes retry storms)
- Are generic `catch` blocks swallowing error types?
- Do service failures return 503 with `Retry-After` headers?

These are the kinds of issues that ship to production when the implementer is too close to the code to see them.

---

## Problem Framing: `/ralph`

Before RPIV even starts, there's a step most people skip: **framing the problem correctly.**

The `/ralph` command is the single entry point for all development tasks. Instead of jumping straight into research, it first asks: *how complex is this actually?*

### The Complexity Assessment

```
## Complexity Assessment: STANDARD

- Files: ~6 (estimated)
- Pattern: partial — similar auth flow exists but not for WebAuthn
- Arch decisions: 1 (token storage approach)
- Risk: medium (auth changes can break all users)
- Confidence: medium — clear goal, some implementation unknowns

Multi-file auth change with one architectural decision. Standard pipeline.
```

| Signal | Light | Standard | Deep |
|--------|-------|----------|------|
| Files likely touched | 1-3 | 4-10 | 10+ or unknown |
| Pattern exists | Clear precedent | Partial | No precedent |
| Architectural decisions | None | 1-2 | Multiple |
| Risk if wrong | Low (easy revert) | Medium | High (data loss, breaking) |
| Confidence | High | Medium | Low |

### Three Tiers, Three Workflows

**Light** — Just do it. No research doc, no plan doc, no worktree. State assumptions in 3-5 bullets, get confirmation, implement, commit. For typos, small bugs, 1-3 file changes.

**Standard** — Full RPIV pipeline: `/ralph_research` -> `/ralph_plan` -> `/launch_impl` -> `/ralph_impl` -> `/validate_plan` -> `/finish_impl`. For multi-file features, moderate unknowns.

**Deep** — Full pipeline with adversarial review: adds `/first-principles-review` after research to challenge assumptions before planning. For new systems, architectural decisions, irreversible changes.

### Why This Matters

Without tier assessment, every task gets the same treatment. Small bug fixes get burdened with formal research docs. Complex architectural changes get "just do it" treatment. Both waste time — one through ceremony, the other through rework.

The problem frame also forces a WHO/WHEN/STATUS QUO/WHY statement before any code exploration. This is the specification discipline applied to the *task itself* — making the AI state what it thinks the problem is before investigating, so its assumptions are visible and correctable.

---

## Worktree Lifecycle: `/launch_impl` + `/finish_impl`

These two commands bookend the implementation phase and handle all the branch/worktree complexity so you don't have to.

### The Problem They Solve

In a multi-repo project, implementing a feature means:
- Creating branches in multiple repos
- Keeping them in sync
- Not polluting your main working directory
- Managing git worktrees correctly
- Pushing branches, creating PRs, cross-linking them
- Cleaning up afterward

Doing this manually is error-prone and tedious. These commands + the worktree scripts automate it end-to-end.

### `/launch_impl` — Set Up

Takes a plan file, auto-detects which repos are needed (by scanning the plan for file path references), creates an isolated worktree environment, and gives you the exact commands to paste:

```
════════════════════════════════════════════════════════════
  Ready to launch: user-notifications
════════════════════════════════════════════════════════════

  Paste this into a new terminal:

    cd .claude/worktrees/user-notifications && claude --dangerously-skip-permissions

  Then inside that session, run:

    /ralph_impl @thoughts/shared/plans/2026-03-01_user-notifications_plan.md

  When done, clean up:

    ./scripts/cleanup-impl-worktree.sh user-notifications --delete-branches
════════════════════════════════════════════════════════════
```

Key behaviors:
- **Auto-detects repos**: Scans the plan for backend/frontend/desktop file references
- **Commits plan to main first**: Ensures `@<path>` references resolve in the worktree
- **Checks for existing worktrees**: Won't create duplicates
- **Uses scripts**: `create-impl-worktree.sh` handles git worktree creation, branch setup, dependency installation, thoughts symlink

### `/finish_impl` — Tear Down

When implementation and validation are done, this command:

1. **Validates readiness** — Reads `.worktree-info`, checks for clean working trees, verifies validation report status (blocks on FAIL)
2. **Pushes branches** — Each sub-repo's feature branch gets pushed to remote
3. **Creates PRs** — Generates PR bodies from the plan + validation report + diff, with proper structure (Summary, Changes by phase, Testing, Related artifacts)
4. **Cross-links** — If multiple repos have PRs, each PR references the others
5. **Commits validation** — Pushes the validation report to the main workspace

What it does NOT do:
- **Does NOT merge PRs** — Branch protection requires human approval on GitHub
- **Does NOT deploy** — Requires explicit user permission
- **Does NOT delete worktrees** — User does cleanup after merge

### The Full Flow

```
Main branch                          Worktree
──────────                           ────────
/ralph_research
/ralph_plan
/commit (plan to main)
/launch_impl ──────────────────────> Creates worktree
                                     /ralph_impl (implement)
                                     /validate_plan (verify)
                                     /finish_impl (push + PRs)
                                     ←──────────────────────
Merge PRs on GitHub
./scripts/cleanup-impl-worktree.sh
```

This separation is critical: research and planning happen on main (where they're committed and visible to future worktrees), while implementation happens in isolation (where experimental changes can't corrupt your working directory).

---

## Command Reference

### Problem Framing

#### `/ralph` — Smart Entry Point
```
Assesses task complexity (Light/Standard/Deep), then executes or routes.
Light: direct implementation. Standard: full RPIV. Deep: RPIV + adversarial review.
```

### Research Phase

#### `/research_codebase` — Single-Pass Research
```
Output: thoughts/shared/research/YYYY-MM-DD_<topic>.md
Sections: Summary, components with file:line refs, data flow, test commands, open questions
```

#### `/ralph_research` — Autonomous Research
```
Same output, but iterates multiple passes until exhaustive.
Completion criteria: all entry points identified, data flow traced, no gaps remaining.
```

### Planning Phase

#### `/create_plan` — Interactive Planning
```
Output: thoughts/shared/plans/YYYY-MM-DD_<topic>_plan.md
Sections: Desired end state, risk assessment, Phase 0 (safety), Phase N (changes + verification), rollback, success criteria
```

#### `/ralph_plan` — Autonomous Planning
```
Same output, but self-stress-tests each phase, verifies file paths exist, removes all ambiguity.
```

#### `/iterate_plan` — Update Existing Plan
```
Surgically update plan based on feedback without starting over.
```

### Implementation Phase

#### `/implement_plan` — Guided Implementation
```
Executes plan phases in order. Runs verification after each phase.
Pauses for manual verification steps. Stops on mismatch.
```

#### `/ralph_impl` — Autonomous Implementation
```
Executes all phases. Auto-retries failures (up to 3x).
Commits after each successful phase. Creates handoff if stuck.
```

#### `/tdd` — Test-Driven Development
```
Phase 1: Write failing tests (red). Phase 2: Minimal implementation (green).
Phase 3: Refactor. Phase 4: Validation report.
```

### Validation Phase

#### `/validate_plan` — Independent Verification
```
Output: thoughts/shared/validations/YYYY-MM-DD_<topic>_validation.md
Phases: Requirements check, test verification, test quality review, code quality, security, production failure modes
Verdict: PASS / PASS WITH NOTES / FAIL
```

### Handoff & Recovery

#### `/create_handoff` — Save Session Context
```
Output: thoughts/shared/handoffs/YYYY-MM-DD_HH-MM-SS_<topic>.md
Captures: tasks, recent changes, learnings, action items
```

#### `/resume_handoff` — Continue from Handoff
```
Verifies state, presents summary, executes next steps.
```

#### `/debug` — Investigation Only
```
Read-only troubleshooting. Reports findings, suggests fixes, doesn't apply them.
```

### Git & PR

#### `/commit` — Create Commits
```
No AI attribution. Specific file staging. User confirms before commit.
```

#### `/describe_pr` — Generate PR Description
```
Summary, changes, testing, breaking changes, related artifacts.
```

#### `/launch_impl` — Create Worktree Environment
```
Auto-detects repos from plan. Creates worktree with scripts/create-impl-worktree.sh.
Commits plan to main first. Outputs exact commands to paste for the worktree session.
```

#### `/finish_impl` — Wrap Up Worktree
```
Reads .worktree-info. Validates clean working trees and passing validation.
Pushes branches. Creates PRs with plan/validation context. Cross-links multi-repo PRs.
Does NOT merge (branch protection) or deploy (requires permission).
```

---

## Multi-Repo Worktree Support

For projects with multiple repositories (e.g., backend + frontend), the worktree scripts create isolated environments where each sub-repo gets its own branch:

```bash
# Create worktree with backend and frontend sub-repos
./scripts/create-impl-worktree.sh dark-mode feature backend frontend

# Result:
# .claude/worktrees/dark-mode/
# ├── CLAUDE.md, .claude/commands/     (workspace)
# ├── thoughts/shared/                 (symlink -> main)
# ├── backend/                         (feature/dark-mode branch)
# └── frontend/                        (feature/dark-mode branch)
```

Configure the sub-repo directory prefix with `RPIV_REPO_PREFIX`:
```bash
export RPIV_REPO_PREFIX="myproject-"
# Now scripts look for myproject-backend/, myproject-frontend/, etc.
```

---

## Directory Structure

```
your-project/
├── CLAUDE.md                          # Project instructions (customize this!)
├── .claude/
│   ├── settings.json                  # Hook configurations
│   ├── agents/
│   │   ├── codebase-analyzer.md       # Analyze implementation details
│   │   ├── codebase-locator.md        # Find files by feature/topic
│   │   ├── codebase-pattern-finder.md # Find similar patterns
│   │   ├── validation-reviewer.md     # Review against criteria
│   │   ├── websearch-researcher.md    # Web research
│   │   ├── thoughts-analyzer.md       # Analyze thoughts docs
│   │   └── thoughts-locator.md        # Find thoughts docs
│   ├── commands/
│   │   ├── research_codebase.md       # /research_codebase
│   │   ├── create_plan.md             # /create_plan
│   │   ├── implement_plan.md          # /implement_plan
│   │   ├── validate_plan.md           # /validate_plan
│   │   ├── iterate_plan.md            # /iterate_plan
│   │   ├── ralph.md                   # /ralph (smart router)
│   │   ├── ralph_research.md          # /ralph_research
│   │   ├── ralph_plan.md              # /ralph_plan
│   │   ├── ralph_impl.md              # /ralph_impl
│   │   ├── commit.md                  # /commit
│   │   ├── describe_pr.md             # /describe_pr
│   │   ├── finish_impl.md             # /finish_impl
│   │   ├── launch_impl.md             # /launch_impl
│   │   ├── create_handoff.md          # /create_handoff
│   │   ├── resume_handoff.md          # /resume_handoff
│   │   ├── debug.md                   # /debug
│   │   ├── tdd.md                     # /tdd
│   │   └── creative_thinking.md       # /creative_thinking
│   ├── hooks/
│   │   ├── block-destructive-git.sh   # Block force push, hard reset, etc.
│   │   ├── block-prod-deploy.sh       # Block bare wrangler deploy
│   │   └── block-sensitive-files.sh   # Block edits to secrets/credentials
│   └── skills/
│       ├── skill-creator/SKILL.md     # Guide for creating skills
│       ├── template/SKILL.md          # Starter template
│       ├── first-principles-review/   # Challenge direction before planning
│       ├── bugfix/SKILL.md            # Structured bug investigation
│       ├── analyze-logs/SKILL.md      # Log analysis
│       ├── ast-grep/SKILL.md          # AST-based code search
│       └── agent-browser/SKILL.md     # Browser automation
├── scripts/
│   ├── create-impl-worktree.sh        # Create isolated worktree
│   ├── cleanup-impl-worktree.sh       # Remove worktree
│   └── setup-worktree-thoughts.sh     # Symlink thoughts/ in worktree
└── thoughts/
    └── shared/
        ├── research/                  # Research documents
        ├── plans/                     # Implementation plans
        ├── validations/               # Validation reports
        └── handoffs/                  # Session handoff docs
```

---

## Design Patterns

### 1. "Documentarian, not critic"
All agents describe what IS, not what SHOULD BE. No unsolicited suggestions, no "improvements," no "you should." Just precise documentation of the existing codebase.

### 2. Parallel sub-agents
Research spawns multiple agents simultaneously for efficiency. The main context stays clean while sub-agents do the heavy lifting.

### 3. File:line references for everything
All claims must be anchored to specific code locations. No vague "the authentication module" — it's `src/middleware/auth.ts:45-67`.

### 4. Artifacts as contracts
Research docs, plans, and validation reports aren't just documentation — they're contracts between phases. The plan is a contract between human and AI. The validation report is a contract between implementation and `main`.

### 5. No AI attribution in commits
Commits should appear human-authored. The human is responsible for the code, not the AI. The plan and validation docs provide the audit trail.

### 6. Interactive confirmation
The AI presents its understanding before taking action. "Here's what I'm going to do" before "I did it."

### 7. Fresh context for verification
The validator has never seen the implementation reasoning. It only has the plan (what was promised) and the code (what was delivered). This eliminates the implementer's confirmation bias.

---

## Best Practices

### Do
- **Complete each phase before moving on** — Don't skip research
- **Reference artifacts by path** — `@thoughts/shared/plans/2026-01-10_feature_plan.md`
- **Use sub-agents for heavy lifting** — Keeps main context clean
- **Include file:line references** — Makes verification concrete
- **Run verification commands** — Don't assume success
- **Use worktrees for autonomous mode** — Isolates experimental changes
- **Commit plans to main before creating worktrees** — `@<path>` refs resolve at invocation time

### Don't
- **Don't improvise during implementation** — Stick to the plan
- **Don't validate your own work** — Fresh context catches biases
- **Don't skip the security phase** — It's mandatory in validation
- **Don't batch completions** — Mark things done as you go
- **Don't run Ralph without limits** — Always set max iterations

---

## Glossary

| Term | What It Is |
|------|------------|
| **RPIV** | Research -> Plan -> Implement -> Validate. The four-phase development methodology. |
| **Ralph Mode** | Autonomous iteration within any RPIV phase. Named after Ralph Wiggum — relentlessly optimistic, keeps trying until done. |
| **Tier** | Complexity level assessed by `/ralph`: Light (just do it), Standard (full RPIV), Deep (RPIV + adversarial review). |
| **Problem Frame** | A WHO/WHEN/STATUS QUO/WHY statement written before investigation begins. Forces assumptions to be visible and correctable. |
| **Thoughts** | The `thoughts/shared/` directory containing all research docs, plans, validations, and handoffs. The institutional memory of the project. |
| **Artifact** | Any output document from an RPIV phase — research doc, plan, validation report, handoff. Artifacts feed into the next phase and serve as contracts. |
| **Slug** | A short kebab-case identifier (e.g., `user-notifications`) that flows through the entire pipeline: plan filename -> worktree name -> branch name -> PR title. |
| **Worktree** | A git worktree — an isolated copy of the repo with its own branch. Implementation happens here so experimental changes can't corrupt your main working directory. |
| **Handoff** | A document capturing session context (tasks, changes, learnings, action items) so a fresh agent can continue where the previous one left off. |
| **Validator** | A fresh agent context that independently verifies implementation against the plan. Never the same context that implemented the code — fresh perspective catches what the implementer rationalizes. |
| **High-signal test** | A test that verifies actual behavior and would fail if the feature broke. Contrasted with low-signal tests that pass but assert nothing meaningful (e.g., `expect(result).toBeDefined()`). |
| **Instruction budget** | The finite number of instructions (~150-250) an LLM can follow before accuracy degrades. Your CLAUDE.md consumes part of this budget on every request. |
| **Nested CLAUDE.md** | A `CLAUDE.md` file in a subdirectory. Only loaded when Claude reads files in that directory. Keeps the root file lightweight while providing context-specific instructions where needed. |
| **Hook** | A shell script that runs before a tool use (pre-tool-use hook). Enforces constraints 100% of the time, unlike CLAUDE.md instructions which can be ignored ~3% of the time. |

### Key Commands at a Glance

| Command | Phase | What It Does |
|---------|-------|-------------|
| `/ralph` | Entry | Assesses complexity, picks tier, routes to right workflow |
| `/ralph_research` | Research | Autonomous codebase research — iterates until exhaustive |
| `/ralph_plan` | Plan | Autonomous planning — stress-tests each phase, removes ambiguity |
| `/launch_impl` | Setup | Creates isolated worktree, auto-detects repos, outputs launch commands |
| `/ralph_impl` | Implement | Autonomous implementation — executes phases, auto-retries, commits per phase |
| `/validate_plan` | Validate | Independent verification — fresh context, PASS/FAIL verdict |
| `/finish_impl` | Ship | Pushes branches, creates cross-linked PRs, commits validation |
| `/commit` | Git | Stages and commits with user approval, no AI attribution |
| `/create_handoff` | Recovery | Saves session context for continuation by a fresh agent |
| `/resume_handoff` | Recovery | Picks up where previous session left off |
| `/debug` | Investigation | Read-only troubleshooting — reports findings, doesn't edit |
| `/tdd` | Implement | Test-driven development: red -> green -> refactor -> report |
| `/iterate_plan` | Plan | Updates existing plan with feedback without starting over |
| `/describe_pr` | Git | Generates comprehensive PR description from changes |
| `/research_codebase` | Research | Single-pass research (non-autonomous version) |
| `/create_plan` | Plan | Interactive planning with user collaboration |
| `/implement_plan` | Implement | Guided implementation (non-autonomous version) |
| `/creative_thinking` | Ideation | Structured creative thinking using metacognitive strategies |

### Key Scripts

| Script | What It Does |
|--------|-------------|
| `scripts/create-impl-worktree.sh` | Creates isolated worktree environment with sub-repo branches, dependency installation, and thoughts symlink |
| `scripts/cleanup-impl-worktree.sh` | Removes worktree and optionally deletes feature branches (use after PR merge) |
| `scripts/setup-worktree-thoughts.sh` | Symlinks `thoughts/shared/` in a worktree to the main repo's canonical copy |

---

## The Ralph Mindset

> "Me fail English? That's unpossible!" — Ralph Wiggum

Ralph Mode embodies relentless optimism:
- Errors are learning opportunities, not stopping points
- Each iteration gets closer to success
- Giving up is not an option (until safety limits)
- Trust the process — the methodology works even when individual steps stumble

**Cost warning:** Autonomous loops burn tokens. Use `--max-iterations` as a safety net. Start with lower limits and increase as you gain confidence in the system.

---

## Credits

- **Original RPI methodology:** [Dex Horthy, HumanLayer](https://www.youtube.com/watch?v=rmvDxxNubIg)
- **Ralph Wiggum technique:** [Geoffrey Huntley](https://www.humanlayer.dev/blog/brief-history-of-ralph)
- **HumanLayer Claude setup:** [github.com/humanlayer/humanlayer](https://github.com/humanlayer/humanlayer/tree/main/.claude)
- **Validation separation insight:** [Anthropic Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- **Ralph Wiggum plugin:** [Anthropic Official](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)
- **Production battle-testing:** [KablewyAI](https://github.com/KablewyAI) — this system has been refined through hundreds of real implementation cycles

---

## License

MIT — See [LICENSE](LICENSE) for details.
