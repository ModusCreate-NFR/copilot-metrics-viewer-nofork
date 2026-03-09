---
name: pr-creator
description: Creates pull requests for copilot-metrics-viewer project with intelligent analysis of changes. Use whenever the user wants to create a PR, open a pull request, push their changes for review, submit code, make a merge request, or asks "how do I PR this" or similar. Also use when they mention being ready to merge, wanting feedback on their code, or needing to get changes reviewed. Automatically analyzes git history, generates conventional commit titles, fills PR descriptions, and handles edge cases like uncommitted changes or existing PRs.
---

# PR Creator for Copilot Metrics Viewer

This skill helps create well-formatted pull requests for the copilot-metrics-viewer project by automatically analyzing changes, generating conventional commit titles, and filling PR descriptions intelligently.

## Why This Matters

Pull requests are the gateway to code review and collaboration. A well-crafted PR with clear context helps reviewers understand your changes quickly, leading to faster approvals and better feedback. This skill automates the tedious parts (formatting, conventions, checking prerequisites) so you can focus on explaining the "why" behind your changes.

## Workflow Overview

1. **Pre-flight checks** - Verify branch state, commits, uncommitted changes
2. **Analyze changes** - Examine git diff, file types, commit messages to understand what changed
3. **Generate PR metadata** - Create conventional commit title and descriptive body
4. **Create PR** - Use GitHub CLI, MCP, browser, or markdown fallback
5. **Handle edge cases** - Update existing PRs, handle force pushes, etc.

## Step 1: Pre-Flight Checks

Before creating a PR, verify the environment is ready. These checks prevent common mistakes that waste time.

### Check Current Branch

**Why**: Never create PRs from `main` - it's the protected default branch. Feature branches isolate your changes.

Run:
```bash
git branch --show-current
```

If the output is `main`:
- **STOP immediately** - do not proceed with PR creation
- Tell the user: "You're on the `main` branch. You need a feature branch to create a PR."
- Ask if they want to create a feature branch from their changes:
  - If yes: `git checkout -b feat/descriptive-name` (suggest a name based on their changes)
  - If no: Exit gracefully

### Check for Commits

**Why**: A PR needs commits to show. No commits = nothing to review.

Run:
```bash
git log origin/main..HEAD --oneline
```

If empty:
- Check for uncommitted changes: `git status --short`
- If uncommitted changes exist, go to "Handle Uncommitted Changes" section below
- If no uncommitted changes either: Tell user "No commits or changes to push. Make some changes first, then come back."

### Handle Uncommitted Changes

**Why**: Users often forget to commit before trying to PR. Give them the choice to commit now or exit.

Run:
```bash
git status --short
```

If output shows unstaged or uncommitted files:
- List the files to the user
- Ask: "You have uncommitted changes. Do you want to commit them before creating the PR?"
- If **yes**:
  - Analyze the changed files to suggest a commit message (see "Generate Commit Message" section below)
  - Run: `git add .`
  - Run: `git commit -m "suggested message"`
- If **no**: Remind them "Your PR will only include already-committed changes, not these unstaged files" and continue

## Step 2: Analyze Changes

This is where intelligence happens. Understand what the user changed so you can generate meaningful PR content.

### Gather Information

Run these commands in parallel to build a complete picture:

```bash
# Get commit messages
git log origin/main..HEAD --pretty=format:"%s"

# Get changed files with stats
git diff origin/main..HEAD --stat

# Get actual code changes (limited to avoid overwhelming context)
git diff origin/main..HEAD --unified=3 | head -n 500
```

### Categorize Changes

Based on the files changed, determine the change type:

- **feat** (new feature):
  - New `.vue` components in `app/components/`
  - New API endpoints in `server/api/`
  - New pages in `app/pages/`
  - New utility functions that add capabilities

- **fix** (bug fix):
  - Changes that fix errors, bugs, or incorrect behavior
  - Commit messages containing "fix", "resolve", "bug"

- **test** (testing):
  - New or modified `.spec.ts` files in `e2e-tests/` or `tests/`
  - Changes primarily in test files

- **docs** (documentation):
  - Changes to `.md` files in `.github/instructions/` or root
  - README updates
  - Comment additions

- **refactor** (code restructuring):
  - Moving code without changing behavior
  - Renaming, reorganizing

- **chore** (maintenance):
  - Dependency updates in `package.json`
  - Config file changes
  - Build/tooling updates

**Priority**: If multiple categories apply, choose in this order: feat > fix > test > refactor > docs > chore

### Detect UI Changes

**Why**: UI changes need screenshots in the PR description.

Check if any of these patterns appear in changed files:
- `app/components/*.vue`
- `app/pages/*.vue`
- `app/assets/*.css` or `*.scss`
- `vuetify.config.ts`

If detected: Set `ui_changes = true` (you'll remind about screenshots later)

### Detect Test Changes

Check if test files were added or modified:
- `e2e-tests/*.spec.ts`
- `tests/*.spec.ts`
- `e2e-tests/pages/*.ts` (page objects)

If detected: Set `test_changes = true` (you'll emphasize testing section later)

## Step 3: Generate PR Metadata

### Generate PR Title

**Format**: `<type>: <description>`

**Rules**:
- Under 72 characters
- Imperative mood ("add" not "added", "fix" not "fixed")
- Lowercase after colon
- No period at end

**Process**:
1. Use the category determined in Step 2 as `<type>`
2. For `<description>`:
   - If there's only one commit, use that commit message (cleaned up if needed)
   - If multiple commits on the same topic, summarize the common theme
   - If commits are varied, describe the overarching change based on git diff

**Examples**:
- `feat: add date range selector component`
- `fix: resolve caching issue for team metrics`
- `test: add playwright tests for GitHub tab`
- `docs: update PR creation instructions`

### Generate PR Description

Use this template structure and fill it intelligently:

```markdown
## Summary
[What changed and why - 2-3 sentences based on commits and diff]

## Changes
[Bullet list of key changes - extracted from commit messages and file changes]

## Testing
[How to verify the changes work]

## Screenshots
[If ui_changes = true, remind user to add screenshots; otherwise omit this section]
```

**How to fill each section**:

#### Summary
- Parse commit messages to understand intent
- Check git diff for context (e.g., new functions, modified logic)
- Explain WHAT changed and WHY (infer from context)
- Example: "Adds a new date range selector component to allow users to filter metrics by custom date ranges. This improves flexibility compared to the previous fixed 28-day window."

#### Changes
- Extract from commit messages (each commit = potential bullet point)
- Group related changes (e.g., "Added DateRangeSelector.vue and corresponding Playwright tests")
- List file additions/deletions if significant
- Example:
  ```markdown
  - Added `DateRangeSelector.vue` component with calendar picker
  - Integrated date range selector into `MainComponent.vue`
  - Added Playwright tests for date selection functionality
  - Updated mock data to support custom date ranges
  ```

#### Testing
- **Default steps** (always include):
  ```markdown
  1. Run `npm run dev`
  2. Navigate to http://localhost:3000/orgs/mocked-org?mock=true
  3. [Specific test steps based on changes]
  4. Verify [expected behavior]
  ```
- For test file changes: Add "Run `npm test` or `npm run test:e2e` to verify tests pass"
- For UI changes: Add specific interaction steps ("Click the date picker, select a range, verify metrics update")
- For API changes: Add curl examples or API endpoint testing steps

#### Screenshots
- If `ui_changes = true`: Add `## Screenshots\n[Please add screenshots showing before/after or the new UI]`
- If `ui_changes = false`: Omit this section entirely

## Step 4: Create the Pull Request

Try these methods in order of preference until one succeeds.

### Method 1: GitHub CLI (Preferred)

**Why**: Fastest, most reliable, works in terminal.

Check if available:
```bash
which gh
```

If available:
1. Push the branch first:
   ```bash
   git push -u origin $(git branch --show-current)
   ```
   
   If this fails with "rejected" (branch exists remotely with different history):
   - Ask user: "The remote branch has diverged. Do you want to force push? (This will overwrite remote changes)"
   - If yes: `git push -u origin $(git branch --show-current) --force-with-lease`
   - If no: Exit and explain they need to resolve the divergence first

2. Check if PR already exists:
   ```bash
   gh pr list --head $(git branch --show-current) --json number,title
   ```
   
   If PR exists (output is not empty):
   - Parse the PR number from JSON
   - Tell user: "PR #[number] already exists for this branch. Updating it with latest commits."
   - Run: `git push` (to update the existing PR with new commits)
   - Run: `gh pr view [number] --web` to open it
   - Exit successfully

3. Create new PR:
   ```bash
   gh pr create --title "[generated title]" --body "[generated description]"
   ```
   
   This will open the PR in the browser automatically for final review.

### Method 2: GitHub MCP (If CLI unavailable)

**Why**: Alternative integration if user has MCP server configured.

Check for GitHub MCP tools (you'll need to search for them first).

If available, use the appropriate MCP tool to create the PR with the generated title and description.

### Method 3: Browser (If neither CLI nor MCP available)

**Why**: Fallback for users without CLI/MCP but with browser access.

1. Push the branch:
   ```bash
   git push -u origin $(git branch --show-current)
   ```

2. Construct the GitHub PR creation URL:
   ```
   https://github.com/github-copilot-resources/copilot-metrics-viewer/compare/main...[branch-name]?expand=1
   ```

3. Open the URL in the browser
4. Tell the user: "I've opened GitHub in your browser. The PR title and description are shown below - copy them into the form:"
   ```
   Title: [generated title]
   
   Description:
   [generated description]
   ```

### Method 4: Markdown File (Last Resort)

**Why**: When nothing else works, give the user everything they need in a file.

Create a file `/tmp/pr-content-[branch-name].md`:

```markdown
# Pull Request for [branch-name]

## 📋 Copy this content to GitHub

### PR Title
[generated title]

### PR Description
[generated description]

## 🔗 Links

**Create PR manually**: https://github.com/github-copilot-resources/copilot-metrics-viewer/compare/main...[branch-name]?expand=1

## ⚠️ Before submitting:

- [ ] Run `npm run lint` (expect 60 baseline errors - don't add new ones)
- [ ] Run `npm test` to verify tests pass
- [ ] Test the app with `npm run dev` at http://localhost:3000?mock=true
- [ ] Add screenshots if you made UI changes
- [ ] Review the PR yourself before requesting reviews

## 📝 Instructions

1. Push your branch: `git push -u origin [branch-name]`
2. Open the "Create PR manually" link above
3. Copy the title and description into the GitHub form
4. Complete the checklist above
5. Submit the PR
```

Tell the user where to find this file and explain they'll need to create the PR manually.

## Step 5: Final Reminders

After successfully creating or opening the PR, remind the user about project-specific conventions:

**For copilot-metrics-viewer**:
- "The project has 60 baseline linting errors - run `npm run lint` to make sure you haven't added new ones"
- "Test your changes with `?mock=true` parameter to use mock data"
- If `ui_changes = true`: "Don't forget to add screenshots to the PR showing your UI changes"
- If `test_changes = true`: "Great job adding tests! Make sure they pass with `npm test` or `npm run test:e2e`"

## Edge Case Reference

### Generate Commit Message (for uncommitted changes)

When the user has uncommitted changes and wants to commit them:

1. Run `git diff --stat` to see what changed
2. Categorize the changes (same logic as PR title generation)
3. Create a short commit message:
   - Format: `<type>: <brief description>`
   - Example: `feat: add date range selector` or `fix: resolve caching bug`
4. Show the message to the user and ask for confirmation before committing

### Force Push Decision

When `git push` fails due to diverged history:

- Explain: "Your local branch and the remote branch have different histories. This usually happens after rebasing or amending commits."
- Show the divergence: `git log origin/[branch]..HEAD --oneline` (your commits) and `git log HEAD..origin/[branch] --oneline` (remote commits)
- Ask: "Do you want to force push (overwrite remote) or pull and merge (combine histories)?"
- Recommend `--force-with-lease` over `--force` for safety: "This ensures you don't accidentally overwrite someone else's work"

### Updating Existing PRs

When a PR already exists for the branch:

- Notify the user clearly: "PR #123 already exists for this branch"
- Explain: "Pushing new commits will automatically update the PR - no need to create a new one"
- Show what changed since last push: `git diff origin/[branch]..HEAD --stat`
- Push the updates: `git push`
- Open the PR for them to review: `gh pr view [number] --web`

## Best Practices

**PR Size**: Aim for < 400 lines changed. If your PR is larger:
- Consider breaking it into smaller, focused PRs
- If that's not possible, add extra context in the description to help reviewers

**Self-Review**: Before creating the PR, review your own changes:
```bash
git diff origin/main..HEAD
```
Look for:
- Leftover debug code (`console.log`, commented code)
- Sensitive data (tokens, passwords, internal URLs)
- Unintended file changes

**Conventional Commits**: The project uses this format project-wide. Consistent formatting helps with changelog generation and makes git history scannable.

## Summary Checklist

Before submitting the PR, verify:
- [ ] Not on `main` branch
- [ ] All changes committed
- [ ] PR title follows `type: description` format
- [ ] PR description is clear and complete
- [ ] Tested locally with mock data
- [ ] Linting errors not increased
- [ ] Screenshots added (if UI changes)
- [ ] PR created successfully and opened for review
