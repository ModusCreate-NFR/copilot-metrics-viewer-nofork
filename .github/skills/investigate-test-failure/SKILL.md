---
name: investigate-test-failure
description: Investigate a failing Playwright test, locally or on CI (GitHub Actions), find the change that caused it, and decide whether the test is outdated or the app has a bug. Use when a test fails, CI is red, a PR check failed, or asked why a test is broken or flaky.
---

# Investigate a Test Failure

Goal: answer one question with evidence: **is the test wrong, or is the app wrong?** Do not change any file until the user has seen the diagnosis.

## 1. Get the failure

- **CI / PR**: use the GitHub CLI.
  ```bash
  gh pr checks <pr-number>                     # which check failed
  gh run list --branch <branch> --limit 5      # find the run id
  gh run view <run-id> --log-failed            # only the failing log lines
  ```
  If the log has expired, fall back to the run's annotations (`gh run view <run-id>`) or reproduce locally.
- **Local**: `npx playwright test <spec> --project=chromium --reporter=line`.

Extract: the failing test names, the assertion, **Expected** vs **Received**, and how many browsers fail. One browser only, or a pass on retry, points to flakiness. The same failure everywhere points to a real change.

## 2. Find what changed

For a PR, you do not need to check it out:
```bash
gh pr view <pr-number> --json commits,author,title       # commits and author
gh pr diff <pr-number>                                    # what the PR changed
```
For the current branch:
```bash
git log --oneline main..HEAD                              # commits on this branch
git diff main...HEAD --stat                               # files touched
git log -S "<text from Expected>" --oneline -- app shared # who removed that text
```

Match the Received value to a line in the diff. Name the commit, author, and message.

## 3. Classify

| Evidence | Verdict | Next step |
|---|---|---|
| Selector or text changed on purpose (commit message says so, design change) | **Test is outdated** | Update the test assertion or page object |
| Behaviour broke, data wrong, element missing, API error | **App bug** | Draft a bug report |
| Fails intermittently, timing, passes on retry | **Flaky test** | Fix the wait or setup, never add a sleep |
| Unclear whether the change was intended | **Needs a decision** | Ask the author or product owner; do not guess |

## 4. Report, then stop

```
### Failure: <test name>
Expected: ...   Received: ...
Caused by: <commit sha> "<message>" (<author>), <file>:<line>
Verdict: Test outdated | App bug | Flaky | Needs a decision
Why: <one or two sentences of evidence>
Proposed fix: <exact change, not applied yet>
```

Ask: "Apply the fix on this branch?" For an app bug, offer a bug report draft (title, steps to reproduce, expected, actual, commit) instead of editing app code. Never skip or weaken the test to get green.
