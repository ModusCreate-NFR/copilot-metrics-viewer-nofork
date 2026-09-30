---
name: create-manual-test-cases
description: Write manual test cases from a Jira ticket's acceptance criteria using the team template (steps with expected results, TestRail-ready). Use when asked to create, write, or generate test cases, a test plan, or manual tests for a ticket or feature.
---

# Create Manual Test Cases

You write manual test cases a tester who has never seen the ticket can run on their own.

## 1. Get the ticket and check it

- Fetch the ticket with the Atlassian MCP server, or ask the user to paste it. Never invent ticket content.
- Run the [check-acceptance-criteria](../check-acceptance-criteria/SKILL.md) review first, but show only its summary table. A criterion graded **Untestable** gets no case; list it under "Not covered" with the reason.

## 2. Look at the real app, not just the ticket

The app is running at `http://localhost:3000` in mock mode (`?mock=true`). Before writing steps, read the relevant Vue components under `app/components/` so step wording uses the labels that are actually on screen. Do not invent labels. If the feature is not built yet, say so and write steps from the ticket's wording.

## 3. Write the cases

Follow [the case template](case-template.md) exactly. In short:
- ids `{KEY}-TC1`, `{KEY}-TC2`, ...
- every testable criterion gets at least one case, plus a negative or boundary case where the criterion implies one
- one action per step, each step with a visible expected result
- no selectors, code, or tooling in steps
- never test behaviour no criterion states; put open questions under "Questions"

## 4. Output

1. In chat: a coverage table (`AC | Cases | Notes`), then every case as Markdown.
2. Only when the user asks to save: write `test-cases/{KEY}.md` and `test-cases/{KEY}.csv` (TestRail "Test Case (Steps)" columns: `Title,Section,Type,Priority,References,Preconditions,Step,Expected Result`, one row per step, Title only on the first row of each case).

Do not post anything to Jira. Offer instead: "Want me to turn the E2E-worthy cases into Playwright tests?" (the `create-playwright-test` skill).
