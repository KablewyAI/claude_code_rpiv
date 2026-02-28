# Claude Code RPIV

A battle-tested methodology for AI-assisted software development. Separates research, planning, implementation, and validation into distinct phases with autonomous "Ralph Mode" for hands-off iteration.

**The core thesis: quality of output is directly tied to the quality of specification.**

When you tell an AI "add feature X," you're giving it an underspecified problem. It will fill in the gaps with assumptions — about your architecture, your conventions, your edge cases, your preferences. Some assumptions will be wrong. The resulting code will *work*, but it won't be *right*. RPIV exists to eliminate that gap between "works" and "right" by forcing specification to happen before implementation.

**Adapted from:**
- [No Vibes Allowed: Solving Hard Problems in Complex Codebases](https://www.youtube.com/watch?v=rmvDxxNubIg) — Dex Horthy, HumanLayer (AI Engineering Summit 2025)
- [HumanLayer's Claude Code setup](https://github.com/humanlayer/humanlayer/tree/main/.claude)
- [Ralph Wiggum Autonomous Loops](https://www.humanlayer.dev/blog/brief-history-of-ralph)

## Table of Contents

- [Why This System Exists](#why-this-system-exists) — The specification problem, why phases matter, DoR/DoD gates, session separation, independent validation
- [Common Failure Modes](#common-failure-modes) — Real examples of what goes wrong without RPIV discipline
- [Your CLAUDE.md Is Your Highest Leverage](#your-claudemd-is-your-highest-leverage) — Instruction budget, nested files, hooks, auto-memory
- [What is RPIV?](#what-is-rpiv) — The four-phase pipeline
- [What is Ralph Mode?](#what-is-ralph-mode) — Autonomous iteration
- [What's Included](#whats-included) — Agents, commands, hooks, skills, scripts
- [Setup](#setup) — Installation and configuration
- [Quick Start](#quick-start) — Interactive, autonomous, and full pipeline flows
- [The Specification Discipline](#the-specification-discipline) — Good vs bad artifacts, Gherkin acceptance criteria, validation quality, FAIL recovery, institutional memory
- [When NOT to Use RPIV](#when-not-to-use-rpiv) — Outages, exploration, trivial changes, greenfield
- [Problem Framing: `/ralph`](#problem-framing-ralph) — Complexity assessment, tier routing, WHO/WHEN/STATUS QUO/WHY
- [Worktree Lifecycle](#worktree-lifecycle-launch_impl--finish_impl) — Git worktrees explained, `/launch_impl`, `/finish_impl`, the full flow
- [Command Reference](#command-reference) — All 18 commands with descriptions
- [Multi-Repo Worktree Support](#multi-repo-worktree-support) — Cross-repo branching
- [Directory Structure](#directory-structure) — Full file tree
- [Design Patterns](#design-patterns) — 8 patterns with "why this matters" explanations
- [Best Practices](#best-practices) — Do/don't, guided vs autonomous, handoff discipline
- [Glossary](#glossary) — All key terms, commands at a glance, scripts reference

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

#### What RPIV Does With the Same Request

Let's trace "add a delete button to the user profile" through the full pipeline:

**Research** discovers the status quo:
```
- User deletion uses soft deletes (is_deleted flag + deleted_at timestamp) — src/services/UserService.ts:89
- Related data: 4 tables with user_id foreign keys (orders, comments, sessions, audit_log)
- Existing destructive action pattern: account deactivation at src/components/AccountSettings.ts:156
  uses a 2-step confirmation modal with re-authentication
- GDPR data export endpoint exists at /v1/user/export but no deletion endpoint
- Design system has a DestructiveButton component — src/components/ui/DestructiveButton.ts
- No existing email template for account deletion confirmation
```

**Plan** makes every decision explicit and reviewable:
```
Phase 1: Add DELETE /v1/user/:id endpoint (soft delete + cascade is_deleted to related tables)
  Verify: curl returns 200, user.is_deleted = true, orders/comments marked deleted

Phase 2: Add re-authentication modal using existing 2-step pattern
  Verify: modal appears, requires password, blocks deletion without auth

Phase 3: Add deletion confirmation email using existing email service
  Verify: email sent to user after successful deletion

Phase 4: GDPR compliance — schedule hard delete of PII after 30-day retention
  Verify: scheduled job exists, respects retention period, audit_log preserved
```

**Implementation** executes each phase, commits after verification passes.

**Validation** (fresh context) catches what the implementer missed:
```
FINDING: Phase 1 cascade deletes orders but doesn't check for pending refunds.
  If a user deletes their account with an in-progress refund, the refund record
  becomes orphaned. The plan didn't address this because the research doc didn't
  catalog the refunds table.

VERDICT: PASS WITH NOTES — add refund check before deletion proceeds.
```

The same task. The same AI. Wildly different outcomes. The first approach ships a button that silently orphans refund records. The second approach catches it before any code reaches `main`.

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

### Definition of Ready / Definition of Done

Each phase transition has explicit quality gates. These prevent half-baked artifacts from cascading errors into the next phase.

#### Research

| Gate | Criteria |
|------|----------|
| **DoR** (ready to start) | Problem frame written: WHO is affected, WHEN it happens, STATUS QUO (how it works today), WHY it needs to change. Complexity tier assessed (Light/Standard/Deep). |
| **DoD** (ready for planning) | All entry points identified with `file:line` refs. Data flow traced end-to-end. Existing patterns and conventions documented. Test infrastructure cataloged. Open questions either resolved or explicitly flagged for the plan phase. No "I think" — only "the code shows." |

#### Plan

| Gate | Criteria |
|------|----------|
| **DoR** (ready to start) | Research doc committed to `main`. All open questions from research resolved or scoped out. User has reviewed research findings. |
| **DoD** (ready for implementation) | Desired end state stated in concrete terms (not "improve X" but "X returns Y when Z"). Every phase is small enough to verify independently. Each phase has runnable verification commands (not "check that it works" but `npm test -- --grep "auth"` or `curl -s localhost:8787/v1/...`). Risk assessment present. Rollback plan exists. All referenced file paths verified to exist. Success criteria are binary (pass/fail, not subjective). User has approved the plan. |

#### Implementation

| Gate | Criteria |
|------|----------|
| **DoR** (ready to start) | Plan committed to `main`. Worktree created (Standard/Deep tier). Plan reviewed and approved by user. Dependencies installed. `thoughts/shared/` symlinked (if in worktree). |
| **DoD** (ready for validation) | All plan phases complete. Verification commands pass for every phase. One commit per phase (traceable). Clean working tree (`git status` shows no untracked/unstaged files). Tests pass. No TODO/FIXME/HACK introduced without matching plan justification. |

#### Validation

| Gate | Criteria |
|------|----------|
| **DoR** (ready to start) | Implementation complete (all phases). Fresh agent context (never the same session that implemented). Plan doc accessible via `@<path>`. All verification commands passing. |
| **DoD** (ready to ship) | Requirements checklist: every plan requirement verified present. Test quality review: tests are high-signal (would fail if feature broke), not just `expect(result).toBeDefined()`. Security review: no new injection vectors, auth boundaries intact. Production failure modes checked: what happens on DB timeout, API 500, network partition? Verdict rendered: **PASS**, **PASS WITH NOTES**, or **FAIL** (with specific findings). |

#### The Gate Principle

> No artifact crosses a phase boundary until its DoD is met. No phase begins until its DoR is met.

This sounds bureaucratic. It isn't. Most DoR/DoD checks take seconds — they're a quick scan of the artifact before moving on. The cost of checking is trivial. The cost of *not* checking is a research doc with gaps that becomes a plan with blind spots that becomes an implementation with bugs that the validator catches too late.

In Ralph Mode, these gates are enforced automatically. The autonomous loop evaluates its own artifact against the DoD criteria before declaring a phase complete. If it doesn't pass, it iterates — that's the whole point of Ralph.

### Why Separate Sessions Matter

A common impulse is to chain everything in one session: research, plan, implement, validate. It feels efficient. It's actually dangerous.

**Context window degradation.** LLMs have a finite context window — the total text they can "see" at once. As a conversation grows longer, three things happen:

1. **Attention dilution**: Early instructions and findings get less weight as newer content pushes them further from the model's focus. Your carefully crafted CLAUDE.md, read at the start, fades as 2,000 lines of research and implementation accumulate.
2. **Anchoring bias**: The model anchors on its own earlier reasoning. Once it concluded "approach A is best" during research, it won't seriously consider approach B during planning — it already has sunk context invested in A.
3. **Error compounding**: A small misunderstanding in research becomes a flawed assumption in the plan, becomes a structural defect in the implementation. In a single session, there's no checkpoint where fresh eyes could catch the original error.

**The fresh-start advantage.** When you start a new session for each phase, the model reads the *artifact* from the previous phase — not its own reasoning process. It sees only the conclusions, not the deliberation. This means:
- A planning session sees the research *document*, not the 47 grep results the researcher waded through
- An implementation session sees the *plan*, not the three alternative approaches that were rejected
- A validation session sees the *plan and code*, not the implementer's justifications for shortcuts

Each phase transition is a natural checkpoint. The artifact must stand on its own. If the research doc doesn't make sense without the conversation that produced it, it's not ready (DoD not met).

**Practical rule: one phase per session.** Don't chain research into planning into implementation. Complete research, commit the artifact, start a new session for planning. The cost is a few minutes of session overhead. The benefit is that each phase starts with maximum attention and zero bias from prior phases.

### Why Separate Validator from Implementer?

This is the single most impactful practice in the entire system. From [Anthropic's Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices):

> "A simple but effective approach is to have one Claude write code while another reviews or tests it. Sometimes having separate context is beneficial."

This isn't a novel concept. It's one of the most well-established practices in software engineering:

- **Code review** works because the reviewer didn't write the code — they read it cold and catch what the author normalized
- **QA teams** exist separately from development teams because testing your own work is fundamentally compromised
- **Security audits** are done by outside firms because internal teams have blind spots about their own architecture
- **Medical device software** (IEC 62304) requires independent verification — the person who verifies can never be the person who implemented

The AI angle is that AI agents don't naturally separate these roles. Left to its defaults, the same context that researched, planned, and implemented will also "validate" — rubber-stamping its own work with tests that confirm its assumptions. RPIV enforces structural separation that the AI won't create on its own.

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

Remember our delete button example? The validator caught orphaned refund records — something the implementer couldn't see because they'd internalized the (incomplete) research doc's list of related tables. Fresh eyes found the table that wasn't cataloged.

---

## Common Failure Modes

These are real patterns we've seen repeatedly. Each one is preventable with RPIV discipline.

### 1. The Wrong Code Path

**What happened:** A bug report said "JIT migration fails for new orgs." The implementer found a migration function, fixed the SQL, shipped it. The bug persisted.

**Root cause:** The migration function they fixed was in the *Worker* code path. New orgs were created through the *Durable Object* code path, which had its own migration logic. The fix was correct but in the wrong file.

**What RPIV prevents:** The research phase would have traced the actual execution path from "new org creation" through the code, identifying *all* code paths that handle migration — not just the first one grep found.

### 2. The Incomplete Fix

**What happened:** "Database error: no such table `workflows`" was reported. The implementer added a CREATE TABLE migration. Tests passed. Deployed. New error: "no such column `status` in table `workflows`."

**Root cause:** The table existed in some orgs (created by an earlier migration) but was missing a column added later. The fix handled the "no table" case but not the "table exists, column missing" case.

**What RPIV prevents:** The plan phase would have required the implementer to enumerate *all* possible database states, not just the one in the bug report. The DoD for planning requires verification commands that cover each state.

### 3. The Diagnosis That Wasn't

**What happened:** "Tool calls are failing for org X." The implementer checked the tool service, found nothing wrong, concluded "the change isn't deployed yet." Waited a day. Still broken.

**Root cause:** The tool service was fine. The issue was in the Durable Object's persistent storage — a cached permission record was stale. The implementer diagnosed a deployment problem because that was the easiest explanation, not the correct one.

**What RPIV prevents:** The research phase requires *ruling out alternatives* — not stopping at the first plausible explanation. "Not deployed" would need verification (`wrangler deployments list`) before being accepted as the root cause.

### 4. The Model ID That Never Existed

**What happened:** A new AI model was added to the catalog with the ID `gemini-3.0-pro-preview`. Every API call returned 404.

**Root cause:** The correct API identifier was `gemini-3-pro-preview` (no `.0`). The implementer assumed the naming convention without checking the provider's documentation.

**What RPIV prevents:** The research phase requires verifying facts against source documentation — not inferring from patterns. A research doc with "API ID: `gemini-3-pro-preview` (verified: [link to provider docs])" would have caught this.

### 5. The Low-Signal Test Suite

**What happened:** Implementation passed all tests. Validation passed. Deployed to staging. Feature didn't work at all.

**Root cause:** The tests mocked the entire service layer and only verified that functions were called with the right arguments. They never tested actual behavior. `expect(mockService.create).toHaveBeenCalledWith(...)` passed, but the real service threw an error the mocks hid.

**What RPIV prevents:** The validation phase explicitly checks test *quality*, not just test *results*. A test that mocks everything and asserts `toHaveBeenCalled` is low-signal — it passes regardless of whether the feature works. Validators are trained to flag these.

### The Pattern

Every failure above shares a common structure: **someone skipped a step that felt unnecessary.** They didn't trace the full code path because they found a plausible one. They didn't check all database states because they reproduced one. They didn't verify the API docs because the naming convention seemed obvious. They didn't question the test quality because the tests passed.

RPIV's phases and gates exist precisely to catch these skips. The cost of each check is minutes. The cost of skipping is hours of debugging in production.

---

## Your CLAUDE.md Is Your Highest Leverage

Before diving into the pipeline itself, there's one meta-level decision that affects every phase: your `CLAUDE.md` file. It sits above the pipeline — every research session, every plan, every implementation reads it first. If it's wrong, everything downstream is wrong. If it's bloated, everything downstream is slower. Getting it right is disproportionately valuable.

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

#### What Good Research Looks Like

**Bad research** (vague, no anchoring):
```
The authentication module handles user login. It checks credentials and
returns tokens. There's middleware that validates tokens on protected routes.
The system supports email and OAuth login methods.
```

**Good research** (precise, verifiable):
```
Authentication flow — 3 entry points:

1. Email/password: POST /v1/auth/login → AuthController.login() at src/controllers/auth.ts:34
   → calls AuthService.validateCredentials() at src/services/auth.ts:89
   → calls TokenService.createPair() at src/services/token.ts:12 (returns {access, refresh})
   → sets HttpOnly cookie 'refresh_token' (7d expiry) + returns access token in body

2. OAuth (Google): GET /v1/auth/google/callback → src/controllers/oauth.ts:67
   → same TokenService.createPair() path after OAuth code exchange

3. Magic link: POST /v1/auth/magic → src/controllers/auth.ts:112
   → creates one-time token in magic_links table (15min expiry)
   → GET /v1/auth/magic/verify?token=X → validates + same token creation path

Token refresh: POST /v1/auth/refresh → src/middleware/auth.ts:45
   → reads refresh_token cookie → calls TokenService.refresh() at src/services/token.ts:56
   → SILENT FAILURE: if DB pool exhausted, returns 401 (should be 503)

Test coverage: 12 tests in tests/auth.test.ts — all mock TokenService
   → NO integration tests that test actual DB interaction
   → refresh token rotation is UNTESTED
```

The bad version tells you nothing you couldn't guess. The good version tells you exactly where to find every piece of the auth flow, and it already surfaced two issues (silent 401 on DB failure, untested refresh rotation) that would become bugs if implementation touched this code without understanding it.

### Plans Make Decisions Reviewable

A plan is a specification. It says:
- "Here's what we're building" (desired end state)
- "Here's how we're building it" (phased approach)
- "Here's how we'll know it works" (verification commands per phase)
- "Here's what could go wrong" (risk assessment)
- "Here's how to undo it" (rollback plan)

You review the plan *before* any code exists. This is orders of magnitude cheaper than reviewing a PR with 500 lines of code that took the wrong approach. If the plan is wrong, you `/iterate_plan` with feedback. If it's right, the implementation is largely mechanical.

#### Acceptance Criteria: Given / When / Then

Plans use **Gherkin-style acceptance criteria** — a format from Behavior-Driven Development (BDD) that forces verification steps to describe *observable behavior*, not vague outcomes.

**Bad verification** (subjective, untestable):
```
Phase 2: Add the notification service
  Verify: Check that notifications work correctly
```

**Good verification** (concrete, runnable):
```
Phase 2: Add notification service
  Given: user has email_notifications=true in preferences
  When: POST /v1/notifications/send with {userId, type: "mention", content: "..."}
  Then: notification record created in notifications table with status="pending"
  And: email queued in jobs table with type="notification_email"

  Given: user has email_notifications=false in preferences
  When: same POST request
  Then: notification record created with status="pending"
  And: NO email queued (in-app only)

  Verify: curl -X POST localhost:8787/v1/notifications/send -d '{"userId":"test-user","type":"mention","content":"test"}' && sqlite3 dev.db "SELECT * FROM notifications ORDER BY created_at DESC LIMIT 1"
```

The bad version lets the implementer decide what "works correctly" means. The good version specifies the exact behavior, including the edge case (notifications disabled), and provides a concrete command to verify it. These Given/When/Then scenarios also become the template for tests during implementation — the red phase of TDD.

#### The Cost of Reviewing a Plan vs. Reviewing Code

A plan is 50-100 lines of structured text. A PR implementing that plan might be 500-2,000 lines of code across 8 files. Reviewing the plan takes 5 minutes and catches architectural mistakes ("why are you adding a new table when the existing queue table already handles this?"). Reviewing the PR after the fact takes 30 minutes and catches the same mistakes, but now unwinding them means throwing away work and rewriting.

The plan is where you catch "we should use the existing event system, not build a new one" — a sentence that saves 300 lines of unnecessary code.

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

### What Happens After a FAIL

A FAIL verdict doesn't mean "start over." It means "specific things need fixing before this can ship." The validation report includes concrete findings with file:line references.

**The recovery flow:**

1. **Read the validation report.** Each FAIL finding specifies what's wrong and where.
2. **Assess scope.** If findings are small (missing error handling, a gap in test coverage), fix them in the same worktree.
3. **Re-validate.** Run `/validate_plan` again with the same plan. The validator starts fresh — it doesn't remember the previous FAIL. It evaluates the code as-is.
4. **If findings are architectural** (wrong approach, missing requirements that require plan changes), go back to `/iterate_plan` with the validation feedback, update the plan, then re-implement the affected phases.

The key insight: **validation failures are cheap.** They happen before the code reaches `main`, before PRs are created, before anyone else sees the code. A FAIL at this stage costs minutes of rework. The same issue caught in production costs hours or days.

**PASS WITH NOTES** is not a soft failure. It means the implementation meets all requirements, but the validator noticed things worth mentioning — minor style inconsistencies, opportunities for follow-up work, or documentation gaps. These notes become input for future tasks, not blockers for the current one.

### Institutional Memory

Over time, the `thoughts/shared/` directory becomes your project's institutional memory.

Six months from now, when a new engineer (human or AI) asks "why do we use soft deletes instead of hard deletes?", the answer is in `thoughts/shared/plans/2025-09-15_user-deletion_plan.md`, in the Alternatives Considered section. It documents that hard deletes would break the audit log requirement discovered during research, that the team considered and rejected a hybrid approach, and that the 30-day retention period was chosen to comply with GDPR Article 17.

Without this trail, the answer would be "I think someone decided that a while ago" or, worse, a new engineer would propose switching to hard deletes without understanding why soft deletes were chosen — repeating the entire investigation.

Plans serve as **Architectural Decision Records (ADRs)** without the ceremony. Research docs catalog the state of the codebase at a point in time. Validation reports document what was checked and what passed. Handoffs capture the context that would otherwise be lost between sessions. Together, they create an audit trail from "why did we build this?" to "what did we check before shipping?"

---

## When NOT to Use RPIV

RPIV is not universally appropriate. Using the full pipeline when it's not warranted wastes time on ceremony instead of progress.

**Don't use RPIV for:**

- **Active outages.** When production is down, fix it first, document later. The priority is restoring service, not writing a research doc. RPIV's discipline is for building things right, not for firefighting. After the fix, consider a post-mortem that feeds into a future RPIV-managed improvement.

- **Pure exploration.** When you're spiking a new technology, evaluating a library, or prototyping an idea, the overhead of formal phases is counterproductive. Exploration is inherently non-linear — you don't know what you're building yet. Use RPIV when exploration concludes and you're ready to build something specific.

- **Trivial changes.** Fixing a typo, updating a dependency version, changing a color value. The Light tier already handles these, but even Light tier's "state assumptions, get confirmation" step may be overkill for truly trivial work. Use your judgment.

- **Greenfield projects with no existing codebase.** The research phase ("how does this work today?") has nothing to research when there's no existing code. Start with a plan and build. Once the codebase exists, RPIV becomes valuable for subsequent changes.

- **Time-critical windows.** If a partner needs a specific API endpoint by tomorrow for a demo, the cost of RPIV's full cycle may exceed the cost of technical debt. Ship it, then use RPIV to clean it up properly.

**RPIV's preconditions:**
1. An existing codebase with meaningful complexity
2. Enough time to invest in research (hours, not minutes)
3. Changes that touch multiple files or have non-obvious interactions
4. Stakes high enough to justify the discipline (not every 2-line fix)

The tier system handles most of this automatically — `/ralph` will assess a trivial change as Light and skip the full pipeline. But it's worth understanding when to bypass the system entirely.

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

### The Problem Frame: WHO / WHEN / STATUS QUO / WHY

Before any investigation, `/ralph` forces the AI to write down its understanding of the problem in four parts. This is the specification discipline applied to the *task itself* — making assumptions visible before they can silently drive investigation.

**WHO** is affected? This seems obvious but often isn't. "Users can't log in" — which users? All of them? Only new signups? Only mobile? Only users who signed up with email (not OAuth)? Naming the affected population forces the investigator to scope the problem correctly. If the answer is "I don't know yet," that's valuable information — it means research needs to start with scoping, not jumping to the login code.

**WHEN** does it happen? Timing is a diagnostic signal. "After the last deploy" points to a code change. "Only on Mondays" points to a scheduled job. "Intermittently" points to a race condition or external dependency. "Always" points to a fundamental logic error. The AI will skip this question if you let it — it wants to start grepping immediately. Making it state when the problem occurs often narrows the search space by 80%.

**STATUS QUO** — how does it work today? This is the most important element. Before proposing any change, describe the *current* behavior precisely. Not "the auth system is broken" but "the auth middleware at `src/middleware/auth.ts:45` checks JWT expiration, calls `TokenService.refresh()` if expired, and returns 401 if refresh fails. Currently, refresh fails silently when the database connection pool is exhausted, returning 401 instead of 503." This forces the AI to understand the system before trying to fix it.

**WHY** is it unacceptable? This prevents fixing things that aren't broken. "The login page loads slowly" — is it actually slow (measured), or does it just feel slow? "Users are complaining about the dashboard" — are they complaining about performance, layout, missing data, or something else? Stating why the status quo is unacceptable forces a concrete problem statement that can be verified as solved.

---

## Worktree Lifecycle: `/launch_impl` + `/finish_impl`

These two commands bookend the implementation phase and handle all the branch/worktree complexity so you don't have to.

### What Is a Git Worktree?

A git worktree is a second (or third, or fourth) checkout of the same repository at a different filesystem path. Unlike branches — which switch the *same* directory between different versions — worktrees give you *separate directories* for different branches simultaneously.

```
# Normal branching: one directory, switch back and forth
~/project/  (main)
git checkout feature/dark-mode    # ~/project/ is now feature/dark-mode
git checkout main                 # ~/project/ is now main again

# Worktrees: separate directories, both exist at once
~/project/                        # main branch (your working directory)
~/project/.claude/worktrees/dark-mode/  # feature/dark-mode (isolated)
```

**Why this matters for AI-assisted development:** When an autonomous agent implements a feature, it modifies files, runs tests, potentially breaks things, and may need to retry. If this happens in your main working directory, your work-in-progress is at risk. With a worktree, the agent works in an isolated copy — if it goes sideways, you `rm -rf` the worktree and try again. Your main directory is untouched.

Worktrees also let you keep researching and planning on `main` while implementation runs in the worktree. Two Claude sessions, two directories, zero conflicts.

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

These patterns emerged from hundreds of real implementation cycles. Each one addresses a specific failure mode we observed in AI-assisted development.

### 1. "Documentarian, not critic"

All agents describe what IS, not what SHOULD BE. No unsolicited suggestions, no "improvements," no "you should." Just precise documentation of the existing codebase.

**Why this matters:** AI models have strong opinions about code quality. Left unconstrained, a research agent will spend half its output suggesting refactoring opportunities, pointing out "code smells," and recommending "better" patterns. This noise obscures the actual findings — which is how the code works *today*, not how it *could* work. The person reading the research doc needs facts to make decisions, not the AI's aesthetic preferences. Save opinions for the plan phase, where they can be evaluated explicitly.

### 2. Parallel sub-agents

Research spawns multiple agents simultaneously for efficiency. The main context stays clean while sub-agents do the heavy lifting.

**Why this matters:** A single agent researching a feature might need to read 30+ files, trace 5 data flows, and catalog 3 test suites. Doing this sequentially fills the context window with raw file contents, leaving less room for synthesis. By spawning sub-agents (one per data flow, one for test infrastructure, one for dependencies), each agent works with focused context and returns a summary. The main agent synthesizes these summaries without being polluted by thousands of lines of raw code. This is the same reason human research teams divide work — parallel exploration with centralized synthesis.

### 3. File:line references for everything

All claims must be anchored to specific code locations. No vague "the authentication module" — it's `src/middleware/auth.ts:45-67`.

**Why this matters:** Vague references are unfalsifiable. "The auth module validates tokens" — is that true? You'd have to go read the code to find out, which defeats the purpose of the research doc. `src/middleware/auth.ts:45` — you can open that file, go to that line, and verify in seconds. File:line references also serve as links between artifacts: when the plan says "modify the validation logic at `src/middleware/auth.ts:45`," the implementer knows exactly where to go. And when the validator checks "did Phase 2 modify the correct file?", the reference makes verification trivial. Without anchoring, every claim requires re-investigation.

### 4. Artifacts as contracts

Research docs, plans, and validation reports aren't just documentation — they're contracts between phases. The plan is a contract between human and AI. The validation report is a contract between implementation and `main`.

**Why this matters:** Without a written contract, there's nothing to hold the implementation accountable to. The AI will drift — adding features the plan didn't specify, skipping requirements it finds inconvenient, optimizing for elegance over correctness. The plan is the specification: "build *this*, verify with *these commands*, stop at *this boundary*." If the implementation adds something not in the plan, the validator flags it. If it skips something in the plan, the validator flags that too. The artifact is the single source of truth, not the AI's memory of what it intended.

### 5. No AI attribution in commits

Commits should appear human-authored. The human is responsible for the code, not the AI. The plan and validation docs provide the audit trail.

**Why this matters:** This is about accountability, not credit. When a commit says "Co-authored-by: AI," it creates ambiguity about who is responsible for the code. If a bug ships, who owns it? The human who approved it? The AI that wrote it? The answer should always be the human — the human reviewed the plan, approved the approach, and accepted the implementation. AI is a tool, like a compiler or a linter. You don't credit your linter in commits, and you don't blame it when bugs ship. The audit trail exists in `thoughts/shared/` — the research doc, plan, validation report, and any handoff docs. That's where the AI's contribution is documented and traceable.

### 6. Interactive confirmation

The AI presents its understanding before taking action. "Here's what I'm going to do" before "I did it."

**Why this matters:** The specification problem applies at every scale. "Fix the bug" has the same ambiguity as "add user notifications" — the AI will fill gaps with assumptions. Interactive confirmation creates micro-specification points: "I understand the bug is X, caused by Y, and I plan to fix it by modifying Z. Correct?" This catches misunderstandings before they become wrong code. It also creates a record of intent — when reviewing the implementation later, you can trace back to "the AI said it would do X, and it did X" rather than trying to reverse-engineer intent from code.

### 7. Fresh context for verification

The validator has never seen the implementation reasoning. It only has the plan (what was promised) and the code (what was delivered). This eliminates the implementer's confirmation bias.

**Why this matters:** This is the structural separation principle in action. The implementer has context the validator doesn't: "I considered handling the edge case differently but decided this was simpler." That reasoning may be correct — or it may be a rationalization for cutting corners. The validator can't tell the difference, so it evaluates the code on its merits. If the edge case handling is actually fine, the validator will PASS it. If it's a gap, the validator will flag it. The implementer's reasoning is irrelevant to the validator's assessment — and that's the point.

### 8. State assumptions before investigating

Before opening any file, the AI writes down what it *believes* about the problem. What layer is affected? What data flow is involved? What's the likely root cause?

**Why this matters:** AI agents anchor on the first evidence they find. If the first grep result looks relevant, they'll build their entire investigation around it — even if it's the wrong code path (see Common Failure Mode #1). By writing down assumptions *before* investigating, those assumptions become visible and testable. "I believe the bug is in the auth middleware" is an explicit hypothesis that can be confirmed or refuted. Without this step, the assumption is implicit — the AI starts grepping for auth-related code without admitting that it's guessing where the problem is.

---

## Best Practices

### Do
- **Complete each phase before moving on** — Don't skip research. The 15 minutes you save skipping research becomes 2 hours of debugging an implementation built on wrong assumptions.
- **Reference artifacts by path** — `@thoughts/shared/plans/2026-01-10_feature_plan.md`. This creates a navigable paper trail. Six months from now, you can trace any feature from plan to PR.
- **Use sub-agents for heavy lifting** — Keeps main context clean and focused on synthesis rather than raw investigation.
- **Include file:line references** — Makes verification concrete and falsifiable. "The auth module" is a claim. `src/middleware/auth.ts:45` is a fact.
- **Run verification commands** — Don't assume success. "It should work" is not evidence. A passing `curl` command or test output is.
- **Use worktrees for autonomous mode** — Isolates experimental changes from your working directory. If the AI goes sideways, your main branch is untouched.
- **Commit plans to main before creating worktrees** — `@<path>` refs resolve at invocation time. If the plan isn't committed, the worktree session can't find it.
- **End every session with a commit or handoff** — Uncommitted work is lost context. Either commit progress or create a handoff doc so the next session can continue.

### Don't
- **Don't improvise during implementation** — Stick to the plan. If you discover something the plan didn't anticipate, go back to `/iterate_plan` rather than ad-libbing.
- **Don't validate your own work** — Fresh context catches biases. The implementer is constitutionally incapable of objectively reviewing their own output.
- **Don't skip the security phase** — It's mandatory in validation. Security issues are invisible to the implementer who didn't think about them.
- **Don't batch completions** — Mark things done as you go. Verification is cheaper when the change is small and fresh in context.
- **Don't run Ralph without limits** — Always set max iterations. Autonomous loops burn tokens. Start with lower limits and increase as you gain confidence.

### Guided vs. Autonomous: When to Choose Which

| Scenario | Use Guided (`/implement_plan`) | Use Autonomous (`/ralph_impl`) |
|----------|-------------------------------|-------------------------------|
| You want to watch each step | Yes | No |
| You'll be away from keyboard | No | Yes |
| Codebase is small and familiar | Either works | Either works |
| Codebase is large and unfamiliar | No — autonomous handles exploration better | Yes |
| Changes touch auth or payments | Yes — review each phase | No — too risky for unsupervised |
| You're learning the codebase | Yes — see how the AI navigates it | No — you'll miss the educational value |
| Token budget is tight | Yes — fewer iterations, less waste | No — autonomous retries cost tokens |

The same tradeoff applies to research (`/research_codebase` vs `/ralph_research`) and planning (`/create_plan` vs `/ralph_plan`). Guided gives you control and visibility. Autonomous gives you throughput and handles complexity you'd find tedious to manage manually.

### The Handoff Discipline

Handoffs aren't just a recovery tool — they're a session management practice. Every session has a finite useful lifespan (context window limits, attention degradation). Rather than pushing a session until it degrades, proactively create handoffs at natural breakpoints:

- After completing a major phase (research done, plan done)
- When you're about to step away (meeting, end of day)
- When the AI seems to be losing track of earlier context
- When switching from one sub-task to another

A handoff captures: what was done, what was learned, what's next, and any context that would be lost if the session ended. The next session reads the handoff and continues from a clean, informed starting point — better than a degraded continuation of the previous session.

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
| **DoR (Definition of Ready)** | The criteria that must be met before a phase can begin. Prevents starting work on incomplete inputs. |
| **DoD (Definition of Done)** | The criteria that must be met before a phase's output can feed into the next phase. Prevents shipping half-baked artifacts downstream. |
| **Quality Gate** | A DoR/DoD checkpoint between phases. In Ralph Mode, gates are evaluated automatically; the loop iterates until the gate passes. |
| **Gherkin / BDD** | Given/When/Then acceptance criteria format from Behavior-Driven Development. Forces verification steps to describe observable behavior, not vague outcomes. Plan acceptance criteria become test templates during implementation. |
| **Context degradation** | The progressive loss of attention and accuracy as an LLM's context window fills up. Why phases should be separate sessions — each starts fresh with maximum attention. |
| **Anchoring bias** | The tendency to anchor on the first plausible explanation or approach found. Countered by the "state assumptions before investigating" pattern and fresh-context validation. |
| **Session** | A single Claude Code conversation. One phase per session is the recommended practice. Sessions are connected by artifacts (research docs, plans, handoffs), not by shared context. |

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
