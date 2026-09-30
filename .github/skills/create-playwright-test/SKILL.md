---
name: create-playwright-test
description: Create a new Playwright e2e test in this repo from a manual test case file (test-cases/<KEY>.md), a ticket, an acceptance criterion, or a plain description, reusing existing page objects and running it until it passes. Use when asked to add, write, create, or automate an e2e, UI, or Playwright test.
---

# Create a Playwright Test

The detailed conventions live in [add-new-pw-test.instructions.md](../../instructions/add-new-pw-test.instructions.md) and [run-pw-test.instructions.md](../../instructions/run-pw-test.instructions.md). Read both before writing code. This skill is the workflow around them.

## 1. Confirm scope (one short message)

- **Test case file** (`test-cases/<KEY>.md`, written by the create-manual-test-cases skill): read every case marked `Automate?: E2E`. Use the `.md` file, not the `.csv` (the CSV is only for TestRail import).
- **Anything else** (a ticket key, a criterion, a description): restate in one or two lines what the test will prove. If the request is ambiguous (which scope, which data), ask once, then proceed.

## 2. Search before you write (mandatory)

Show the user what you found before creating anything.

For a test case file, start with a coverage table, one row per E2E case: case ID, title, and the existing test that already covers it, or **Not covered**. Automate only the cases that are not covered, at most 2 per run unless the user asks for more.

For every request:
- Existing specs in `e2e-tests/` that already cover this behaviour. If one does, say so and extend it instead of adding a duplicate.
- Page objects in `e2e-tests/pages/` with methods you can reuse (for example `DashboardPage.gotoTeamsTab()`).
- The Vue component that renders the feature (`app/components/`), to get real labels, roles, and `data-testid`s. Never guess a locator.

## 3. Write the test

- Put new locators and actions in the page object, not in the spec. Add a page object only if none fits.
- Locator priority: `getByRole` / `getByLabel` / `getByText` with real on-screen text, then `data-testid`. No CSS chains, no XPath.
- Use `?mock=true` URLs and the mock data in `public/mock-data/`. No real GitHub calls.
- Web-first assertions only (`await expect(locator).toBeVisible()`); never `waitForTimeout`.
- Tag the test like its neighbours (`{ tag: ['@teams-comparison'] }`) and name it after the behaviour. When it comes from a test case, start the name with the case ID: `GHC-1695-TC6: adding a third team updates the comparison`.

## 4. Run it

```bash
npx playwright test <spec-file> --project=chromium --reporter=line
```

If it fails, read the error, fix the test, and run again (up to 3 rounds). If it fails because the app does not do what the criterion says, stop and report a possible bug instead of bending the test.

## 5. Report

List the files changed, the command you ran, and the final result. For a test case file, repeat the coverage table with the new tests filled in. Do not commit or push unless asked.
