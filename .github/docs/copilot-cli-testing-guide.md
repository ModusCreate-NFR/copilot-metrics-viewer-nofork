# Testing the Copilot CLI Test Fixer POC

This guide walks you through testing the automated Playwright test fixing workflow.

## 🎯 POC Goal

Demonstrate that Copilot CLI can automatically:
1. Detect a Playwright test failure caused by UI text change
2. Analyze the root cause
3. Fix the test code (not application code)
4. Create Jira ticket and GitHub issue
5. Generate a PR with the fix
6. Human only needs to approve the PR

## 📋 Prerequisites

Before starting, ensure:

- ✅ GitHub secrets configured ([see setup guide](.github/docs/copilot-cli-setup.md)):
  - `COPILOT_CLI_TOKEN` 
  - `JIRA_API_TOKEN`
  - `JIRA_USER_EMAIL`
- ✅ Workflows committed to `main` branch
- ✅ Custom agent file exists: `.github/agents/test-fixer.md`

## 🧪 Test Scenario: Change "Organisation" to "Org"

We'll intentionally break a Playwright test by changing UI text.

### Step 1: Find Where "Organisation" Appears in Tests

Search for test assertions:

```bash
grep -r "Organisation" e2e-tests/
```

**Expected results:**
- Tests checking for "Organisation" text in UI
- Page objects with locators containing "Organisation"

### Step 2: Introduce the Breaking Change

Let's change the UI text to break the test.

#### Option A: Simple Text Change in Component

Find and modify a component that displays "Organisation":

```bash
# Search for UI components with "Organisation"
grep -r "Organisation" app/components/
```

**Example change in `app/components/MainComponent.vue`:**

```diff
- <span>Organisation</span>
+ <span>Org</span>
```

#### Option B: Modify Test Expectation (For Pure Test POC)

Alternatively, just break a test directly:

**File:** `e2e-tests/pages/DashboardPage.ts` (or similar)

```diff
- await expect(this.page.getByText('Organisation')).toBeVisible()
+ await expect(this.page.getByText('Organization')).toBeVisible()  // Wrong spelling
```

### Step 3: Create Test Branch and Push

```bash
# Create test branch
git checkout -b test/copilot-cli-poc-organisation-change

# Stage your changes
git add -A

# Commit with conventional commit message
git commit -m "test: change Organisation to Org to test Copilot CLI auto-fix"

# Push to trigger workflows
git push origin test/copilot-cli-poc-organisation-change
```

### Step 4: Monitor Workflow Execution

#### Workflow 1: Playwright Tests (Should Fail ❌)

1. Go to: https://github.com/github-copilot-resources/copilot-metrics-viewer/actions
2. Find "Playwright Tests" workflow for your branch
3. Wait for it to complete
4. **Expected outcome:** ❌ FAILED

**Example error:**
```
Error: expect(locator).toBeVisible()
Expected: visible
Received: <not found>
Locator: getByText('Organisation')
```

#### Workflow 2: Copilot Test Fixer (Should Trigger Automatically 🤖)

1. Once Playwright Tests fail, "Copilot Test Fixer" should start automatically
2. Monitor progress: https://github.com/github-copilot-resources/copilot-metrics-viewer/actions
3. Check workflow logs for:
   - ✅ Copilot CLI installation
   - ✅ MCP server configuration
   - ✅ Agent execution
   - ✅ Investigation output

**Expected actions:**
- Downloads test results
- Analyzes recent commits
- Identifies "Organisation" → "Org" change
- Fixes test expectations
- Creates Jira Sub-task under GHC-1392
- Creates GitHub issue
- Delegates PR creation to Copilot coding agent

### Step 5: Verify Outputs

#### A. GitHub Commit Comment

Check your commit for an automated comment:

**Location:** On the commit SHA that triggered the failure

**Expected content:**
```markdown
## 🤖 Copilot Test Fixer Investigation

The Playwright test failure has been analyzed by Copilot CLI.

**Workflow Run:** [link]
**Branch:** test/copilot-cli-poc-organisation-change
**Commit:** abc123...

[Investigation Output]
```

#### B. Jira Sub-task Created

1. Go to Jira: https://github-copilot.atlassian.net/
2. Find parent ticket: GHC-1392
3. Check for new Sub-task

**Expected fields:**
- **Summary:** `[Automated] Playwright test failure: should display Organisation text`
- **Parent:** GHC-1392
- **Description:** Contains:
  - Failed test details
  - Root cause: UI text changed from "Organisation" to "Org"
  - Commit SHA
  - Link to workflow run
  - Link to GitHub issue

#### C. GitHub Issue Created

1. Go to: https://github.com/github-copilot-resources/copilot-metrics-viewer/issues
2. Find new issue with label `automated`

**Expected content:**
- **Title:** `[CI] Fix Playwright test after UI change: should display Organisation text`
- **Labels:** `bug`, `ci-failure`, `playwright`, `automated`
- **Body:** 
  - Link to Jira: `GHC-XXXX`
  - Workflow run URL
  - Failure details
  - Proposed fix

#### D. Fix PR Created by Copilot Coding Agent

1. Go to: https://github.com/github-copilot-resources/copilot-metrics-viewer/pulls
2. Find new PR from Copilot

**Expected PR:**
- **Title:** `[Automated] Fix Playwright test: should display Organisation text`
- **Branch:** `fix/copilot-test-fix-*`
- **Changes:** Updates test expectations from "Organisation" to "Org"
- **Links:** References Jira ticket and GitHub issue
- **Status:** ✅ All checks should pass after fix

**Example diff:**
```diff
// e2e-tests/pages/DashboardPage.ts
- await expect(this.page.getByText('Organisation')).toBeVisible()
+ await expect(this.page.getByText('Org')).toBeVisible()
```

### Step 6: Review and Approve PR

This is the only human intervention step!

1. **Review the PR:**
   - Check the test fix is correct
   - Verify it matches the UI change
   - Ensure no unintended changes

2. **Run tests locally (optional):**
   ```bash
   git fetch origin
   git checkout fix/copilot-test-fix-*
   npm run test:e2e
   ```

3. **Approve and merge:**
   - Add review approval
   - Click "Merge pull request"
   - Delete branch

4. **Verify tests pass:**
   - Playwright Tests workflow should now pass ✅

### Step 7: Cleanup

After successful POC:

```bash
# Switch back to main and clean up test branch
git checkout main
git pull
git branch -D test/copilot-cli-poc-organisation-change

# Optionally delete remote branch
git push origin --delete test/copilot-cli-poc-organisation-change
```

## 🐛 Troubleshooting

### Issue: Copilot Test Fixer workflow doesn't trigger

**Checks:**
1. Verify "Playwright Tests" workflow failed
2. Check workflow file is on `main` branch
3. Ensure workflow name matches exactly: `"Playwright Tests"`
4. Review Actions permissions in repository settings

**Solution:**
```bash
# Manually trigger if needed
gh workflow run copilot-test-fixer.yml
```

### Issue: MCP server connection fails

**Checks:**
1. Verify `JIRA_API_TOKEN` secret is set
2. Check `JIRA_USER_EMAIL` is correct
3. Ensure Cloud ID is correct: `4c609fb1-ed57-4449-a5b4-d897fd7e3da8`

**View logs:**
- Check workflow "Configure Atlassian MCP Server" step
- Look for error messages about authentication

### Issue: Copilot CLI authentication fails

**Checks:**
1. Verify `COPILOT_CLI_TOKEN` has required scopes:
   - `copilot`
   - `repo`
   - `workflow`
2. Ensure token hasn't expired
3. Check Copilot CLI is enabled in org settings

**Test locally:**
```bash
export COPILOT_CLI_TOKEN="your-token"
copilot --version
```

### Issue: PR not created

**Checks:**
1. Review copilot-output.log artifact
2. Check if `/delegate` command was executed
3. Verify Copilot coding agent is enabled
4. Ensure repository allows PR creation

**Alternative:**
- Copilot might create the fix suggestion without `/delegate`
- Check investigation output for manual fix instructions

### Issue: Test still fails after fix

**Possible causes:**
1. Multiple places with "Organisation" text
2. Test uses incorrect selector
3. Application code reverted

**Resolution:**
- Review all test assertions manually
- Run tests locally to debug
- Check git history for conflicts

## 📊 Success Metrics

After POC completion, verify:

- ✅ **Automated detection:** Workflow triggered within 1 minute of test failure
- ✅ **Accurate analysis:** Root cause correctly identified (UI text change)
- ✅ **Correct fix:** Test updated to match new UI text
- ✅ **Jira integration:** Sub-task created under GHC-1392
- ✅ **GitHub integration:** Issue created with proper links
- ✅ **PR creation:** Fix PR generated automatically
- ✅ **Tests pass:** After merging fix, all tests green ✅
- ✅ **Time saved:** 15+ minutes of manual investigation automated

## 🎉 What's Next?

After successful POC:

1. **Expand coverage:**
   - Handle more test failure types (selectors, timing, etc.)
   - Support multiple Jira projects
   - Add custom decision logic for different scenarios

2. **Add notifications:**
   - Slack integration for failure alerts
   - Email notifications for PR creation
   - Teams/Discord webhooks

3. **Improve accuracy:**
   - Train custom agent with more examples
   - Add repository-specific fix patterns
   - Implement confidence scoring

4. **Scale to production:**
   - Run on all test failures
   - Add metrics dashboard
   - Implement auto-merge for trusted fixes
   - Add rollback mechanism

## 📚 Additional Resources

- [Copilot CLI Setup Guide](.github/docs/copilot-cli-setup.md)
- [Custom Agent Definition](.github/agents/test-fixer.md)
- [Workflow Configuration](.github/workflows/copilot-test-fixer.yml)
- [GitHub Copilot CLI Docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)
- [Atlassian MCP Server](https://github.com/janhq/mcp-server-atlassian)

## 💡 Tips

1. **Monitor first few runs closely** - Check logs for unexpected behavior
2. **Review PRs thoroughly** - Don't blindly trust automated fixes
3. **Keep agent updated** - Improve test-fixer.md based on learnings
4. **Document edge cases** - Add to agent instructions when found
5. **Celebrate wins** 🎉 - Share successful automation stories with team!

---

**Ready to test?** Start with Step 1 above and follow through the complete POC flow!

**Questions?** Create an issue with label `copilot-cli` for support.
