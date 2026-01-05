---
agent: agent
---

# Create Jira Bug/Investigation Subtask

You are tasked with creating a Jira subtask (Bug or Investigation type) under the parent story **GHC-1392**.

## Requirements

1. **Analyze the current context** to determine what bug or issue needs to be tracked
   - Check recent test failures from GitHub Actions workflow runs
   - Review recent git commits for breaking changes
   - Examine current PR or branch for issues

2. **Automatically create a Jira subtask** with:
   - **Parent:** GHC-1392 (Create Custom QA session)
   - **Project:** GHC (GitHub Copilot Enablement)
   - **Issue Type:** Sub-task (since Bugs can't be children of Stories in this Jira hierarchy)
   - **Cloud ID:** 4c609fb1-ed57-4449-a5b4-d897fd7e3da8

3. **Populate the subtask with comprehensive details:**
   - **Summary:** Clear, concise title describing the issue
   - **Description:** Include:
     - Issue description and impact
     - Failing tests or error details (if applicable)
     - Root cause analysis (commit SHA, file changes, author)
     - Required fixes with specific file paths and line numbers
     - Links to workflow runs, PRs, or commits
     - Related issues or repository information

4. **Add context-specific information:**
   - If test failures: Include test names, browsers, error messages
   - If code changes: Include commit details, diffs, affected files
   - If workflow failures: Include workflow run URL and job details

## Success Criteria

- Subtask is created under GHC-1392
- All relevant technical details are included
- Issue is actionable with clear steps to fix
- Links to supporting resources (GitHub, workflow runs) are included
- Title is descriptive and professional

## Instructions

Using the Atlassian MCP tools:
1. Use `gh cli` or GitHub API to gather context about recent issues
2. Use `mcp_atlassian_createJiraIssue` to create the subtask with parent "GHC-1392"
3. Confirm creation and provide the issue URL

**Note:** Use "Sub-task" as the issue type name, not "Bug", due to Jira hierarchy constraints.