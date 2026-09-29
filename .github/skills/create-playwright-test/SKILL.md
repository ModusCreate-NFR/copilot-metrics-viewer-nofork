---
name: create-playwright-test
description: Create a new Playwright e2e test in this repo from a ticket, an acceptance criterion, a manual test case, or a plain description, reusing existing page objects and running it until it passes. Use when asked to add, write, create, or automate an e2e, UI, or Playwright test.
---

# Create a Playwright Test

The detailed conventions live in [add-new-pw-test.instructions.md](../../instructions/add-new-pw-test.instructions.md) and [run-pw-test.instructions.md](../../instructions/run-pw-test.instructions.md). Read both before writing code. This skill is the workflow around them.

## 1. Confirm scope (one short message)

Restate in one or two lines what the test will prove and which criterion or case it covers. If the request is ambiguous (which scope, which data), ask once, then proceed.

## 2. Search before you write (mandatory)

Show the user what you found before creating anything:
- Existing specs in `e2e-tests/` that already cover this behaviour. If one does, say so and extend it instead of adding a duplicate.
- Page objects in `e2e-tests/pages/` with methods you can reuse (for example `DashboardPage.gotoTeamsTab()`).
- The Vue component that renders the feature (`app/components/`), to get real labels, roles, and `data-testid`s. Never guess a locator.

## 3. Write the test

- Put new locators and actions in the page object, not in the spec. Add a page object only if none fits.
- Locator priority: `getByRole` / `getByLabel` / `getByText` with real on-screen text, then `data-testid`. No CSS chains, no XPath.
- Use `?mock=true` URLs and the mock data in `public/mock-data/`. No real GitHub calls.
- Web-first assertions only (`await expect(locator).toBeVisible()`); never `waitForTimeout`.
- Tag the test like its neighbours (`{ tag: ['@teams-comparison'] }`) and name it after the behaviour, not the ticket.

## 4. Run it

```bash
npx playwright test <spec-file> --project=chromium --reporter=line
```

If it fails, read the error, fix the test, and run again (up to 3 rounds). If it fails because the app does not do what the criterion says, stop and report a possible bug instead of bending the test.

## 5. Report

List the files changed, the command you ran, and the final result. Do not commit or push unless asked.
