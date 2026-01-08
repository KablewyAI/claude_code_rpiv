---
description: Generate comprehensive PR description following best practices
---

# Describe PR

You are tasked with generating a comprehensive pull request description.

## Process

### 1. Identify the PR
Check if current branch has an associated PR:
```bash
gh pr view --json url,number,title,state 2>/dev/null
```

If no PR exists:
```bash
# List open PRs
gh pr list --limit 10 --json number,title,headRefName

# Or create one first
gh pr create --draft
```

Ask user which PR to describe if unclear.

### 2. Gather PR Information
```bash
# Get full diff
gh pr diff <number>

# Get commit history
gh pr view <number> --json commits

# Get base branch
gh pr view <number> --json baseRefName

# Get metadata
gh pr view <number> --json url,title,number,state
```

### 3. Find Related Artifacts
Look for related documentation:
- `thoughts/shared/plans/*` — Implementation plan
- `thoughts/shared/research/*` — Research docs
- `thoughts/shared/validations/*` — Validation reports

### 4. Analyze Changes Thoroughly
- Read through the entire diff carefully
- For context, read files referenced but not in diff
- Understand purpose and impact of each change
- Identify user-facing vs internal changes
- Look for breaking changes or migration needs

### 5. Generate Description

Use this template:

```markdown
## Summary

[2-3 sentences describing what this PR does and why]

## Changes

### [Category 1]
- [Change with file reference]
- [Change with file reference]

### [Category 2]
- [Change with file reference]

## Testing

### Automated
- [ ] `npm run lint` — Passes
- [ ] `npm test` — Passes
- [ ] `npm run build` — Passes

### Manual Testing
- [ ] [Manual test step 1]
- [ ] [Manual test step 2]

## Screenshots (if UI changes)

[Include if applicable]

## Breaking Changes

[List any breaking changes, or "None"]

## Related

- Plan: `thoughts/shared/plans/...`
- Research: `thoughts/shared/research/...`
- Issue: #123 (if applicable)

## Checklist

- [ ] Tests pass
- [ ] No console.log or debug code
- [ ] Documentation updated (if needed)
- [ ] Reviewed my own code
```

### 6. Run Verification
Before finalizing, run verification commands:
```bash
npm run lint
npm test
npm run build
```

Mark checkboxes based on results:
- `- [x]` if passes
- `- [ ]` if fails (note what failed)

### 7. Update PR Description
```bash
# Save to file first
cat > /tmp/pr-body.md << 'EOF'
[Generated description]
EOF

# Update PR
gh pr edit <number> --body-file /tmp/pr-body.md
```

Confirm update was successful.

## Description Guidelines

### Summary Section
- Lead with the **what** and **why**
- Be specific about the problem solved
- Mention user impact if applicable

### Changes Section
- Group by logical category (UI, API, Database, etc.)
- Reference specific files
- Note any architectural decisions

### Testing Section
- Include both automated and manual steps
- Be specific about manual testing needed
- Run automated checks and report results

### Breaking Changes
- Call out prominently if any
- Include migration steps if needed
- "None" if no breaking changes

## Good vs Bad Descriptions

### Good
```markdown
## Summary

Add dark mode support to the settings page. Users can now toggle between
light, dark, and system themes. Preference is persisted to localStorage.

## Changes

### UI Components
- `src/components/ThemeToggle.js` — New toggle component
- `src/pages/Settings.js:45-67` — Integrated theme toggle

### Styling
- `src/styles/theme.css` — CSS variables for theme colors
- `src/styles/dark.css` — Dark mode overrides

## Testing

### Automated
- [x] `npm run lint` — Passes
- [x] `npm test` — Passes (3 new tests added)

### Manual Testing
- [ ] Toggle dark mode in settings
- [ ] Verify preference persists after refresh
- [ ] Test system theme detection
```

### Bad
```markdown
Added dark mode

- updated files
- fixed styling
- added tests
```

## What NOT to Do

- Don't leave description empty
- Don't just list files without context
- Don't skip testing section
- Don't ignore breaking changes
- Don't use vague language ("fixed stuff", "updates")
- Don't include implementation details user doesn't need

## Output

A comprehensive PR description that:
- Explains what and why
- Lists changes with context
- Documents testing performed
- Highlights any breaking changes
- Links to related artifacts
