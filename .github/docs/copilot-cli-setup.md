# GitHub Copilot CLI Setup for CI/CD

This guide explains how to configure GitHub Copilot CLI to automatically investigate and fix Playwright test failures in CI/CD.

## Overview

When Playwright tests fail, the **Copilot Test Fixer** workflow:
1. ✅ Analyzes the test failure using Copilot CLI
2. ✅ Identifies root cause (UI changes, selector changes, etc.)
3. ✅ Fixes the test code (not application code)
4. ✅ Creates Jira Sub-task under GHC-1392
5. ✅ Creates GitHub issue linked to Jira
6. ✅ Delegates to Copilot coding agent to create fix PR
7. ✅ Human reviews and approves the PR

## Prerequisites

- ✅ GitHub Copilot Enterprise subscription
- ✅ Copilot CLI enabled in organization settings
- ✅ Atlassian (Jira) account with API access
- ✅ GitHub Personal Access Token with Copilot permissions

## Required GitHub Secrets

Configure these secrets in your repository settings:

### 1. COPILOT_CLI_TOKEN

**What it is:** Personal Access Token (PAT) with GitHub Copilot permissions

**How to create:**
1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Set note: `Copilot CLI for CI/CD`
4. Set expiration: Choose appropriate duration
5. Select scopes:
   - ✅ `copilot` - Full Copilot access
   - ✅ `repo` - Full repository access (needed for creating PRs)
   - ✅ `workflow` - Workflow access
6. Click "Generate token" and copy it
7. Add to repository secrets as `COPILOT_CLI_TOKEN`

**GitHub CLI command:**
```bash
gh secret set COPILOT_CLI_TOKEN --body "ghp_your_token_here"
```

### 2. JIRA_API_TOKEN

**What it is:** Atlassian API token for Jira integration

**How to create:**
1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Set label: `Copilot CLI CI/CD`
4. Copy the generated token
5. Add to repository secrets as `JIRA_API_TOKEN`

**GitHub CLI command:**
```bash
gh secret set JIRA_API_TOKEN --body "your_jira_api_token"
```

### 3. JIRA_USER_EMAIL

**What it is:** Email address associated with your Jira account

**How to set:**
```bash
gh secret set JIRA_USER_EMAIL --body "your-email@example.com"
```

## Configuration Files

### Custom Agent: `.github/agents/test-fixer.md`

The custom Copilot agent specialized in fixing Playwright tests. This file:
- Defines agent behavior and decision logic
- Specifies tools (filesystem, shell, github, mcp:atlassian)
- Provides instructions for analyzing failures
- Guides test fix implementation

**Location:** Already created in `.github/agents/test-fixer.md`

### Workflow: `.github/workflows/copilot-test-fixer.yml`

GitHub Actions workflow that:
- Triggers when "Playwright Tests" workflow fails
- Downloads test results and artifacts
- Runs Copilot CLI with test-fixer agent
- Creates Jira tickets and GitHub issues
- Delegates PR creation to Copilot coding agent

**Location:** Already created in `.github/workflows/copilot-test-fixer.yml`

### MCP Configuration

The workflow automatically creates `~/.copilot/mcp-config.json` with Atlassian MCP server:

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@janhq/mcp-server-atlassian"],
      "env": {
        "JIRA_API_TOKEN": "from-secret",
        "JIRA_USER_EMAIL": "from-secret",
        "JIRA_CLOUD_ID": "4c609fb1-ed57-4449-a5b4-d897fd7e3da8"
      }
    }
  }
}
```

**Note:** This is created dynamically in the workflow, no manual setup needed.

## Local Testing (Optional)

To test the Copilot CLI agent locally before pushing:

### 1. Install Copilot CLI
```bash
npm install -g @github/copilot-cli@latest
```

### 2. Authenticate
```bash
copilot /login
```

### 3. Configure MCP Server Locally

Create `~/.copilot/mcp-config.json`:
```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@janhq/mcp-server-atlassian"],
      "env": {
        "JIRA_API_TOKEN": "your-token",
        "JIRA_USER_EMAIL": "your-email@example.com",
        "JIRA_CLOUD_ID": "4c609fb1-ed57-4449-a5b4-d897fd7e3da8"
      }
    }
  }
}
```

### 4. Trust Repository
```bash
cd /path/to/copilot-metrics-viewer
copilot  # Will prompt to trust directory
```

### 5. Test the Agent
```bash
copilot --agent=test-fixer --prompt="Analyze the failed test in e2e-tests/copilot.org.spec.ts and suggest a fix"
```

## Testing the POC Workflow

### Step 1: Introduce a Breaking Change

Modify the UI to change "Organisation" to "Org":

```typescript
// File: app/components/MainComponent.vue (example location)
// Change this line:
<span>Organisation</span>

// To:
<span>Org</span>
```

### Step 2: Push to Trigger Tests

```bash
git checkout -b test/copilot-cli-poc
git add .
git commit -m "test: change Organisation to Org to test Copilot CLI"
git push origin test/copilot-cli-poc
```

### Step 3: Monitor Workflows

1. **First workflow runs:** "Playwright Tests" - This should **fail** ❌
2. **Second workflow triggers:** "Copilot Test Fixer" - This investigates and fixes 🤖

### Step 4: Expected Outcomes

After workflow completes, you should see:

✅ **Jira Ticket Created**
- Sub-task under GHC-1392
- Contains failure details and root cause
- Links to GitHub workflow and commit

✅ **GitHub Issue Created**
- Labeled with `bug`, `ci-failure`, `playwright`, `automated`
- Links to Jira ticket
- Describes the failure and proposed fix

✅ **Fix PR Created**
- Branch: `fix/copilot-test-fix-*`
- Updates test assertions from "Organisation" to "Org"
- Links to Jira and GitHub issue
- Ready for human review

✅ **Commit Comment**
- Posted on the commit that broke tests
- Contains investigation summary
- Links to artifacts and workflow run

### Step 5: Review and Approve

1. Review the PR created by Copilot
2. Verify the test fix is correct
3. Approve and merge the PR
4. Tests should pass ✅

## Troubleshooting

### Issue: Copilot CLI authentication fails

**Solution:**
- Verify `COPILOT_CLI_TOKEN` secret is set correctly
- Ensure token has `copilot` scope
- Check token hasn't expired

### Issue: MCP server fails to connect to Jira

**Solution:**
- Verify `JIRA_API_TOKEN` and `JIRA_USER_EMAIL` secrets
- Check Jira Cloud ID is correct: `4c609fb1-ed57-4449-a5b4-d897fd7e3da8`
- Ensure MCP server package is available: `@janhq/mcp-server-atlassian`

### Issue: Agent doesn't create PR

**Solution:**
- Check if `/delegate` command worked in Copilot output
- Verify `GH_TOKEN` has sufficient permissions
- Review copilot-output.log artifact for errors

### Issue: Workflow doesn't trigger

**Solution:**
- Ensure "Playwright Tests" workflow name matches exactly
- Check workflow permissions are set correctly
- Verify `workflow_run` trigger is allowed in repository settings

## Workflow Permissions

The workflow requires these permissions:
- ✅ `contents: write` - To create branches
- ✅ `issues: write` - To create GitHub issues
- ✅ `pull-requests: write` - To create PRs
- ✅ `actions: read` - To read workflow run artifacts

These are configured in `.github/workflows/copilot-test-fixer.yml`.

## Customization

### Change Jira Parent Ticket

Edit `.github/agents/test-fixer.md`:
```markdown
- **parent:** `GHC-XXXX`  # Change this
```

### Adjust Workflow Timeout

Edit `.github/workflows/copilot-test-fixer.yml`:
```yaml
jobs:
  investigate-and-fix:
    timeout-minutes: 20  # Increase if needed
```

### Add More MCP Servers

Edit the MCP configuration step in workflow to add more servers:
```yaml
- name: Configure Additional MCP Servers
  run: |
    # Add more servers to mcp-config.json
```

## Cost Considerations

**GitHub Actions:**
- ~5-10 minutes per investigation run
- Uses standard GitHub Actions runners

**Copilot API:**
- Uses premium Copilot requests
- Each investigation consumes tokens based on context size
- Typical usage: 5,000-20,000 tokens per investigation

**Recommendations:**
- Start with manual approval for PRs (current setup)
- Monitor Copilot usage in organization settings
- Consider limiting to specific branches or conditions

## Security Best Practices

1. ✅ Use repository secrets for all credentials
2. ✅ Rotate tokens regularly (every 90 days)
3. ✅ Limit token scopes to minimum required
4. ✅ Review auto-generated PRs before merging
5. ✅ Use branch protection rules
6. ✅ Enable audit logging for Copilot usage

## Next Steps

After successful POC:
1. Expand to handle more test failure types
2. Add support for multiple parent Jira tickets
3. Implement auto-merge for trusted fix types
4. Add Slack/Teams notifications
5. Create metrics dashboard for fix success rate

## Support

**GitHub Copilot CLI Docs:**
- https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli

**Atlassian MCP Server:**
- https://github.com/janhq/mcp-server-atlassian

**Issues:**
- File issues in this repository
- Tag with `copilot-cli` label
