---
agent: agent
---

# Create Pull Request

Quick guide for creating PRs in this demo project.

## Prerequisites

```bash
# Verify not on main branch
git branch --show-current

# Check you have commits
git log origin/main..HEAD --oneline
```

**CRITICAL**: Never create PR from `main` branch.

## Quick PR Creation

### 1. Push Branch
```bash
git push -u origin $(git branch --show-current)
```

### 2. Create PR (GitHub CLI)
```bash
# Interactive (recommended)
gh pr create

# Quick with title
gh pr create --title "feat: your description"

# Open in browser
gh pr create --web
```

## PR Title Format

Use Conventional Commits:
```
feat: add new feature
fix: resolve bug
docs: update documentation
refactor: restructure code
test: add tests
chore: update dependencies
```

**Rules**:
- Under 72 characters
- Imperative mood ("add" not "added")
- No period at end

## PR Description Template

```markdown
## Summary
[What and why]

## Changes
- Change 1
- Change 2

## Testing
1. Run `npm run dev`
2. Test at http://localhost:3000?mock=true
3. Verify feature works

## Screenshots
[If UI changes]
```

## Key Practices

**DO** ✅:
- Keep PRs small (< 400 lines)
- Self-review before submitting
- Include screenshots for UI changes
- Use conventional commit format

**DON'T** ❌:
- Mix unrelated changes
- Leave debug code/console.logs
- Write vague descriptions
- Include sensitive data

## Project-Specific Notes

- **Linting**: Run `npm run lint` (expect 60 baseline errors - don't add new ones)
- **Mock data**: Test with `?mock=true` parameter
- **Branch names**: Use `feat/`, `fix/`, `docs/` prefixes

## Quick Commands

```bash
# Complete workflow
git checkout -b feat/my-feature
git add .
git commit -m "feat: add feature"
git push -u origin feat/my-feature
gh pr create

# After review feedback
git add .
git commit -m "fix: address feedback"
git push
```