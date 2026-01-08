You are doing **VALIDATION ONLY**. Do NOT implement changes. Do NOT write code.

## Goal

Independently verify that the implementation matches requirements and meets quality standards. Provide a clear PASS/FAIL verdict.

## Inputs
- Plan: @<PATH_TO_PLAN_MD>
- Research: @<PATH_TO_RESEARCH_MD> (optional)
- Commit range: <COMMIT_RANGE or "all uncommitted changes">

## Output (single markdown file)
Write to: `thoughts/shared/validations/<YYYY-MM-DD>_<short-topic>_validation.md`

## Validation Phases

Execute each phase in order. Use sub-agents to avoid bloating context.

### Phase 1: Requirements Alignment
- [ ] Read the plan's "Desired end state"
- [ ] Compare each requirement against actual implementation
- [ ] Flag any deviations or missing items
- [ ] Note any scope creep (work done beyond plan)

Use `@.claude/agents/validation-reviewer.md` for detailed code inspection.

### Phase 2: Test Verification
- [ ] Run test suite: `cd worker && npm test`
- [ ] Verify new/modified tests exist for changes
- [ ] Check test coverage is adequate for the change
- [ ] Confirm tests are meaningful (not just mocking success)

### Phase 3: Code Quality
- [ ] Check for leftover debug logs (`console.log`, `print`, etc.)
- [ ] Check for TODO/FIXME placeholders
- [ ] Check for commented-out code
- [ ] Check for unused imports/variables
- [ ] Verify pattern consistency with existing codebase

### Phase 4: Security (MANDATORY)
- [ ] Check for hardcoded secrets or credentials
- [ ] Verify input validation on new endpoints
- [ ] Check for SQL injection vulnerabilities
- [ ] Check for XSS vulnerabilities in frontend changes
- [ ] Flag any authentication/authorization gaps

If significant security concerns exist, recommend running `/security-review` for deep analysis.

### Phase 5: Final Verdict
Based on findings, provide one of:
- **PASS**: All requirements met, tests pass, no blocking issues
- **PASS WITH NOTES**: Requirements met, but minor observations exist
- **FAIL**: Requirements not met, tests failing, or blocking issues found

## Output Format

Write the validation report with this structure:

```markdown
---
date: <ISO8601>
topic: <short topic>
status: <PASS | PASS WITH NOTES | FAIL>
plan: <path to plan file>
branch: <branch name>
git_commit: <commit hash>
---

# Validation: <topic>

## Summary
[2-3 sentence overview of validation results]

## Requirements Checklist
| Requirement | Status | Notes |
|-------------|--------|-------|
| [From plan] | PASS/FAIL | [Finding] |

## Test Results
- **Command**: `npm test`
- **Result**: X passing, Y failing
- **New tests added**: [Yes/No - list if yes]

## Issues Found

### Blocking (MUST FIX)
[Numbered list with file:line references, or "None"]

### Non-Blocking (Observations)
[Numbered list, or "None"]

## Code Quality Checks
- [ ] No debug logs remaining
- [ ] No TODO placeholders
- [ ] No unused imports
- [ ] Consistent with codebase patterns

## Security Checks
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] No injection vulnerabilities
- [ ] Auth/authz appropriate

## Final Verdict

**VERDICT: [PASS | PASS WITH NOTES | FAIL]**

**Reasoning**: [1-2 sentences]

**Next Steps**:
- [What needs to happen next]
```

## Validation Rules

- **Be objective** - Report facts, not preferences
- **Be specific** - Include file:line references for all findings
- **Be thorough** - Check every requirement from the plan
- **Be fair** - Don't fail for things not in the plan
- **Be actionable** - Blocking issues must have clear fix paths

## What NOT to Do

- Do NOT implement fixes
- Do NOT rewrite code
- Do NOT suggest architectural changes
- Do NOT fail for stylistic preferences
- Do NOT skip running tests
- Do NOT assume requirements are met without verifying

## Agent Delegation

Use these agents to manage context:
- `@.claude/agents/validation-reviewer.md` - For detailed code inspection against criteria
- `@.claude/agents/codebase-analyzer.md` - For understanding existing patterns to compare against
