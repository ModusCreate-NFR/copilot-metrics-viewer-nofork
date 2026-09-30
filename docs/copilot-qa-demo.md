# Copilot for QA: demo workflow

This repo is set up to show how QA engineers can use GitHub Copilot in VS Code, for manual testing and for Playwright automation. Everything lives in plain files in the repo, so you can read, review and copy it.

## What is in the repo

| Level | Where | What it does |
|---|---|---|
| Instructions | `.github/copilot-instructions.md` | Project facts, safety rules and code review guidelines. Sent with every request. |
| Scoped instructions | `.github/instructions/*.instructions.md` | Playwright rules, loaded only for matching files (`applyTo: 'e2e-tests/**'`). |
| Skills | `.github/skills/<name>/SKILL.md` | Repeatable workflows. Copilot loads a skill when your request matches it, or when you type `/<name>`. |
| Agent | `.github/agents/test-fixer.md` | A role with its own tools. The `Copilot Test Fixer` workflow uses it to analyze failing Playwright tests (the workflow is disabled by default, because each run uses paid requests). |
| MCP servers | `.vscode/mcp.json` | Connections to GitHub, Jira (read-only), Context7 docs and a Playwright browser. |

Skills used in the demos:

| Skill | Use it for |
|---|---|
| `check-acceptance-criteria` | Grade each acceptance criterion of a ticket: testable, vague or untestable, with a suggested rewrite. |
| `create-manual-test-cases` | Write manual test cases from a ticket, using `case-template.md` (one action and one visible result per step). |
| `create-playwright-test` | Create a Playwright test: search for existing tests and page objects first, then write, run and report. |
| `investigate-test-failure` | Investigate a failing test or CI check: read the logs and the diff, then say whether the test or the app is wrong. It changes nothing until you agree. |

## Setup

1. Install dependencies and the Playwright browsers:
   ```bash
   npm install
   npx playwright install
   ```
2. Start the app with mock data (no GitHub token needed):
   ```bash
   npm run dev
   ```
   Open http://localhost:3000/orgs/octo-demo-org?mock=true once, so the first test run does not hit a cold server.
3. Jira MCP server (optional, for the manual QA demo). It runs locally with `uvx mcp-atlassian` and reads its settings from `.demo/jira.env`, which is git-ignored. Create that file yourself:
   ```
   JIRA_URL=https://<your-site>.atlassian.net
   JIRA_USERNAME=<your email>
   JIRA_API_TOKEN=<your Jira API token>
   READ_ONLY_MODE=true
   JIRA_PROJECTS_FILTER=<your project key>
   ```
   Never commit this file. `READ_ONLY_MODE` makes sure Copilot can only read Jira.
4. In VS Code, open **MCP: List Servers** and start the servers you need.

## Run the demos

Work on a throwaway branch, never on `main`:

```bash
git checkout main && git pull
git checkout -b demo/run-1
```

Open Copilot Chat in **Agent** mode.

1. **Review acceptance criteria:** `/check-acceptance-criteria <TICKET-KEY>`
2. **Write manual test cases:** in the same chat, `yes, write the manual test cases`
3. **Create a Playwright test:** `/create-playwright-test <TICKET-KEY>: <the behaviour to test>`. Copilot asks before it runs `npx playwright test`.
4. **Review the new test:** use Copilot code review on your uncommitted changes in the Source Control view. It checks the code against the review guidelines in `.github/copilot-instructions.md`.
5. **Investigate a failing CI check:** `/investigate-test-failure PR #<number> has a failing Playwright check on CI`

After the demo, throw the changes away:

```bash
git checkout main
git branch -D demo/run-1
```

## Safety rules we follow

- Humans review every change. Nothing merges without a person.
- Keep approval prompts on for anything that writes, pushes or deletes.
- Never skip or weaken a failing test to make it pass.
- `main` is protected: changes go through a pull request with a review and passing CI checks.
