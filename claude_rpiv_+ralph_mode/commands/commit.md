---
description: Create git commits with user approval and no Claude attribution
---

# Commit Changes

You are tasked with creating git commits for changes made during this session.

## Process

### 1. Understand What Changed
- Review conversation history and understand what was accomplished
- Run `git status` to see current changes
- Run `git diff` to understand modifications
- Consider whether changes should be one commit or multiple logical commits

### 2. Plan Your Commit(s)
- Identify which files belong together logically
- Draft clear, descriptive commit messages
- Use **imperative mood** in commit messages ("Add feature" not "Added feature")
- Focus on **why** the changes were made, not just what

Good commit messages:
```
Add dark mode toggle to settings page

Implement user preference for dark/light theme with
system default detection. Stores preference in localStorage.
```

Bad commit messages:
```
updated files
fixed stuff
WIP
```

### 3. Present Plan to User
Before committing, show your plan:

```
## Proposed Commits

**Commit 1**: `src/components/` changes
- Files: Feature.js, Feature.test.js
- Message: "Add Feature component with test coverage"

**Commit 2**: `src/utils/` changes
- Files: helpers.js
- Message: "Add helper function for feature validation"

I plan to create 2 commit(s) with these changes. Shall I proceed?
```

Wait for user confirmation.

### 4. Execute Upon Confirmation
```bash
# Add specific files (NEVER use -A or .)
git add src/components/Feature.js src/components/Feature.test.js

# Create commit
git commit -m "Add Feature component with test coverage"

# Show result
git log --oneline -n 2
```

Repeat for each planned commit.

### 5. Report Results
```
## Commits Created

1. `abc1234` - Add Feature component with test coverage
2. `def5678` - Add helper function for feature validation

Branch `feature/dark-mode` is now 2 commits ahead of `main`.
```

## Important Rules

### NEVER Add Claude Attribution
- **NO** co-author information
- **NO** "Generated with Claude" messages
- **NO** "Co-Authored-By" lines
- Commits should be authored solely by the user
- Write commit messages as if the user wrote them

### Commit Hygiene
- Use `git add` with specific files (never `-A` or `.`)
- Keep commits focused and atomic
- Group related changes together
- One logical change = one commit

### Message Format
```
<type>: <short summary in imperative mood>

<optional body explaining why, not what>

<optional footer for breaking changes, issues, etc>
```

Types (optional but helpful):
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change that neither fixes bug nor adds feature
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

## Handling Edge Cases

### Partial Commits
If user only wants some changes committed:
```
You have changes in 5 files. Which should I commit?
- [ ] src/components/Feature.js (new component)
- [ ] src/utils/helpers.js (helper function)
- [ ] src/styles/theme.css (styling)
- [ ] tests/feature.test.js (tests)
- [ ] package.json (new dependency)
```

### Unstaged Changes to Keep
```bash
# Stage only specific files
git add src/components/Feature.js

# Commit
git commit -m "Add Feature component"

# Other changes remain unstaged for later
```

### Amending (Only When Asked)
Only amend if user explicitly requests AND:
- The commit hasn't been pushed
- It was created in this session

```bash
git add <new-files>
git commit --amend --no-edit
```

## What NOT to Do

- Don't use `git add -A` or `git add .`
- Don't add Claude/AI attribution
- Don't commit without user confirmation
- Don't amend pushed commits
- Don't force push
- Don't commit sensitive files (.env, credentials, etc.)

## Output

Commits created with user's authorship, ready to push.
