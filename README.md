# Claude Code RPIV + Ralph Loop

A structured methodology for AI-assisted development that separates research, planning, implementation, and validation into distinct phases—with optional autonomous "Ralph Mode" for hands-off iteration.

**Adapted from:**
- [No Vibes Allowed: Solving Hard Problems in Complex Codebases – Dex Horthy, HumanLayer](https://www.youtube.com/watch?v=rmvDxxNubIg) (AI Engineering Summit 2025)
- [HumanLayer's Claude Code setup](https://github.com/humanlayer/humanlayer/tree/main/.claude)
- [Ralph Wiggum Autonomous Loops](https://www.humanlayer.dev/blog/brief-history-of-ralph)

---

## What is RPIV?

**RPIV** = **R**esearch → **P**lan → **I**mplement → **V**alidate

The core insight: **separating concerns reduces errors**. When an AI agent tries to research, plan, and implement simultaneously, it makes mistakes. RPIV enforces discipline:

| Phase | Focus | Output |
|-------|-------|--------|
| **Research** | Understand the codebase *today* | `thoughts/shared/research/*.md` |
| **Plan** | Design small, verifiable phases | `thoughts/shared/plans/*.md` |
| **Implement** | Execute the plan exactly | Working code + passing tests |
| **Validate** | Independent verification | `thoughts/shared/validations/*.md` |

Each phase produces artifacts that feed into the next, creating an auditable trail and enabling handoffs between sessions.

---

## What is Ralph Mode?

**Ralph Mode** adds autonomous iteration to RPIV. Named after Ralph Wiggum from The Simpsons ("dim-witted but relentlessly optimistic and undeterred"), it keeps trying until the job is done.

| Standard RPIV | Ralph Mode |
|---------------|------------|
| Single-pass execution | Iterates until complete |
| Stops on uncertainty | Keeps exploring gaps |
| Manual phase transitions | Auto-chains to next phase |
| Human checks each step | Autonomous with safety limits |

**Origin:** Created by [Geoffrey Huntley](https://www.humanlayer.dev/blog/brief-history-of-ralph), formalized by Anthropic as an [official plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum).

---

## Setup

### Required: Copy Commands & Agents

```bash
# Copy the .claude directory to your project
cp -r .claude/ /path/to/your/project/

# Create thoughts directory structure
mkdir -p thoughts/shared/{research,plans,validations,handoffs}
```

### Recommended: Playwright MCP for Browser Testing

From [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices):

```bash
claude mcp add playwright -- npx @playwright/mcp@latest
```

This enables Claude to:
- Interact with web pages during validation
- Take screenshots for visual verification
- Test UI changes in a real browser
- Debug frontend issues with live inspection

### Optional: Ralph Plugin for Autonomous Mode

```bash
# Add Anthropic's plugin marketplace
/plugin marketplace add anthropics/claude-code

# Install Ralph Wiggum
/plugin install ralph-wiggum@claude-plugins-official
```

---

## Quick Start

### Standard RPIV Flow
```bash
/research_codebase      # Understand what exists
/create_plan            # Design verifiable phases
/implement_plan         # Execute step by step
/validate_plan          # Independent verification
```

### Ralph Autonomous Flow
```bash
/ralph_research         # Keep iterating until thorough
/ralph_plan             # Keep refining until bulletproof
/ralph_impl             # Keep implementing until complete
/validate_plan          # Fresh agent verifies (always separate)
```

### Supporting Commands
```bash
/create_handoff         # Save context for later
/resume_handoff         # Continue from handoff
/iterate_plan           # Update existing plan
/debug                  # Investigation only (no edits)
/commit                 # Create commits (no AI attribution)
/describe_pr            # Generate PR description
```

---

## Why This Works

### The Problem with "Just Do It"

When you ask an AI to "add feature X," it often:
- Misunderstands existing code patterns
- Makes changes that break other things
- Skips edge cases
- Can't verify its own work objectively

### The RPIV Solution

1. **Research** forces understanding before action
2. **Plan** creates checkpoints and verification steps
3. **Implement** follows the plan exactly (no improvisation)
4. **Validate** uses a fresh agent context for objectivity

### Why Separate Validator from Implementer?

From [Anthropic's Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices):

> "A simple but effective approach is to have one Claude write code while another reviews or tests it. Similar to working with multiple engineers, sometimes having separate context is beneficial."

> "This separation often yields better results than having a single Claude handle everything."

The implementer has context that can bias its judgment:
- "I know this works because I just wrote it"
- "This edge case doesn't apply because..."
- "The tests prove it's correct"

The validator starts fresh:
- Reads the plan's requirements
- Checks if implementation actually meets them
- Runs tests without assumptions
- Flags issues the implementer might rationalize away

---

## Command Reference

### Research Phase

#### `/research_codebase` — Single-Pass Research
```
Goal: Document how the codebase works today for a specific topic.
Output: thoughts/shared/research/YYYY-MM-DD_<topic>.md

Key sections:
- Summary (5-12 bullets)
- Relevant components with file:line references
- Data flow and patterns
- How to run tests
- Open questions / Non-goals
```

#### `/ralph_research` — Autonomous Research
```
Goal: Keep iterating until nothing is unknown.
Difference: Multiple passes, self-assessment checkpoints, exhaustive coverage.

Completion criteria:
- All entry points identified
- Data flow fully traced
- Patterns documented
- No gaps remaining (or explicitly marked as unknowns)
```

### Planning Phase

#### `/create_plan` — Interactive Planning
```
Goal: Create phased implementation plan with user collaboration.
Output: thoughts/shared/plans/YYYY-MM-DD_<topic>_plan.md

Key sections:
- Desired end state
- Risk assessment
- Phase 0: Safety/setup
- Phase N: Changes, files, verification commands
- Rollback plan
- Success criteria (automated + manual)
```

#### `/ralph_plan` — Autonomous Planning
```
Goal: Keep refining until plan is bulletproof.
Difference: Self-stress-tests each phase, verifies file paths exist,
            removes all ambiguity before declaring complete.

Completion criteria:
- Every phase independently verifiable
- All file paths confirmed to exist
- No TBD items remain
- Could be implemented without questions
```

#### `/iterate_plan` — Update Existing Plan
```
Goal: Surgically update plan based on feedback.
Use when: Requirements changed, gaps discovered during implementation.
```

### Implementation Phase

#### `/implement_plan` — Guided Implementation
```
Goal: Execute plan phases in order with verification.
Rules:
- Make smallest change per checkbox
- Run verification after each phase
- Pause for manual verification steps
- Update plan checkboxes as you go
- Stop and report on mismatch
```

#### `/ralph_impl` — Autonomous Implementation
```
Goal: Keep implementing until all phases complete.
Difference: Auto-retries failures (up to 3x), creates handoff if stuck.

Safety limits:
- Max 3 attempts per phase
- Commits after each successful phase
- Creates handoff on failure
- Never force-pushes
```

### Validation Phase

#### `/validate_plan` — Independent Verification
```
Goal: Fresh agent verifies implementation matches requirements.
Output: thoughts/shared/validations/YYYY-MM-DD_<topic>_validation.md

Phases:
1. Requirements alignment
2. Test verification (run tests)
3. Test quality review (are tests high-signal?)
4. Code quality (debug logs, TODOs)
5. Security (mandatory)
6. Final verdict: PASS / PASS WITH NOTES / FAIL

Test Quality Verdicts:
- HIGH SIGNAL: Tests verify behavior, catch regressions → PASS
- MEDIUM SIGNAL: Tests adequate but have gaps → PASS WITH NOTES
- LOW SIGNAL: Tests pass but don't verify anything → FAIL
- NO TESTS: Missing test coverage → FAIL
```

### Handoff & Recovery

#### `/create_handoff` — Save Session Context
```
Goal: Document context so fresh agent can continue.
Output: thoughts/shared/handoffs/YYYY-MM-DD_HH-MM-SS_<topic>.md

Key sections:
- Tasks and status
- Recent changes (file:line)
- Learnings
- Action items
```

#### `/resume_handoff` — Continue from Handoff
```
Goal: Pick up where previous session left off.
Process: Verify state, present summary, execute next steps.
```

#### `/debug` — Investigation Only
```
Goal: Troubleshoot without editing files.
Use when: Something's broken during manual testing.
Constraint: Read-only. Reports findings, suggests fixes, but doesn't apply them.
```

### Git & PR

#### `/commit` — Create Commits
```
Goal: Stage and commit with user approval.
Rules:
- NO Claude/AI attribution
- NO Co-Authored-By lines
- Specific file staging (never git add -A)
- User confirms before commit
```

#### `/describe_pr` — Generate PR Description
```
Goal: Comprehensive PR description with context.
Includes: Summary, changes, testing, breaking changes, related artifacts.
```

---

## Directory Structure

```
.claude/
├── agents/
│   ├── codebase-locator.md        # Find files by feature/topic
│   ├── codebase-analyzer.md       # Analyze how code works
│   ├── codebase-pattern-finder.md # Find similar patterns
│   ├── validation-reviewer.md     # Review against criteria
│   ├── web-search-researcher.md   # External web research
│   ├── thoughts-analyzer.md       # Analyze thoughts docs
│   └── thoughts-locator.md        # Find thoughts docs
└── commands/
    ├── research_codebase.md       # /research_codebase
    ├── create_plan.md             # /create_plan
    ├── implement_plan.md          # /implement_plan
    ├── validate_plan.md           # /validate_plan
    ├── iterate_plan.md            # /iterate_plan
    ├── create_handoff.md          # /create_handoff
    ├── resume_handoff.md          # /resume_handoff
    ├── debug.md                   # /debug
    ├── commit.md                  # /commit
    ├── describe_pr.md             # /describe_pr
    ├── ralph_research.md          # /ralph_research
    ├── ralph_plan.md              # /ralph_plan
    └── ralph_impl.md              # /ralph_impl

thoughts/shared/
├── research/      # Research documents
├── plans/         # Implementation plans
├── validations/   # Validation reports
└── handoffs/      # Session handoff docs
```

---

## Workflows

### Standard RPIV Workflow

```
User: "Add dark mode toggle to settings page"

/research_codebase
 → thoughts/shared/research/2026-01-10_dark-mode.md
 → Documents: theme system, settings structure, CSS patterns

/create_plan
 → thoughts/shared/plans/2026-01-10_dark-mode_plan.md
 → Phases: toggle UI → theme context → CSS vars → tests

/implement_plan
 → Executes phases in order
 → Runs verification after each
 → Updates checkboxes

/validate_plan
 → thoughts/shared/validations/2026-01-10_dark-mode_validation.md
 → Verdict: PASS / PASS WITH NOTES / FAIL

/commit → /describe_pr
 → Ready for review
```

### Ralph Autonomous Workflow

```
User: "Add dark mode toggle to settings page"

/ralph_research
 → Iterates 3x until exhaustive
 → thoughts/shared/research/2026-01-10_dark-mode.md

/ralph_plan
 → Iterates 4x until bulletproof
 → thoughts/shared/plans/2026-01-10_dark-mode_plan.md

/ralph_impl
 → Implements all phases
 → Auto-retries failures
 → Commits after each phase

/validate_plan  ← Always use fresh agent for validation
 → Independent verification
 → Verdict: PASS
```

### True Autonomous Mode (Worktree)

For completely hands-off implementation:

```bash
# 1. Create isolated worktree
git worktree add ~/worktrees/dark-mode feature/dark-mode

# 2. Launch autonomous session
cd ~/worktrees/dark-mode
claude --dangerously-skip-permissions \
       --model opus \
       "/ralph_impl @thoughts/shared/plans/2026-01-10_dark-mode_plan.md"
```

Or with the official Ralph plugin:
```bash
/ralph-loop "/ralph_impl @thoughts/shared/plans/..." --max-iterations 20
```

**Cost warning:** Autonomous loops burn tokens. Set `--max-iterations` as a safety net.

---

## Best Practices

### Do

- **Complete each phase before moving on** — Don't skip research
- **Reference artifacts by path** — `@thoughts/shared/plans/2026-01-10_feature_plan.md`
- **Use sub-agents for heavy lifting** — Keeps main context clean
- **Include file:line references** — Makes verification concrete
- **Run verification commands** — Don't assume success
- **Use worktrees for autonomous mode** — Isolates experimental changes

### Don't

- **Don't improvise during implementation** — Stick to the plan
- **Don't validate your own work** — Fresh context catches biases
- **Don't skip the security phase** — It's mandatory
- **Don't batch completions** — Mark things done as you go
- **Don't run Ralph without limits** — Always set max iterations

---

## Design Patterns

These patterns are borrowed from [HumanLayer's setup](https://github.com/humanlayer/humanlayer/tree/main/.claude):

### 1. "Documentarian, not critic"
Agents describe what IS, not what SHOULD BE. No unsolicited suggestions.

### 2. Parallel sub-agents
Research spawns multiple agents simultaneously for efficiency.

### 3. Read files COMPLETELY
Never use limit/offset. Full context always.

### 4. File:line references for everything
All claims must be anchored to specific code locations.

### 5. No Claude attribution in commits
Commits should appear human-authored.

### 6. Interactive confirmation
Present understanding before taking action.

---

## The Ralph Mindset

> "Me fail English? That's unpossible!" — Ralph Wiggum

Ralph Mode embodies relentless optimism:
- Errors are learning opportunities
- Each iteration gets closer to success
- Giving up is not an option (until safety limits)
- Trust the process

---

## Credits

- **Original RPI methodology:** [Dex Horthy, HumanLayer](https://www.youtube.com/watch?v=rmvDxxNubIg)
- **Ralph Wiggum technique:** [Geoffrey Huntley](https://www.humanlayer.dev/blog/brief-history-of-ralph)
- **HumanLayer Claude setup:** [github.com/humanlayer/humanlayer](https://github.com/humanlayer/humanlayer/tree/main/.claude)
- **Validation separation insight:** [Anthropic Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- **Ralph Wiggum plugin:** [Anthropic Official](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)
