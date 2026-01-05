---
applyTo: '**'
---

# Running Playwright Tests - Instructions for AI

Follow these steps when asked to run Playwright E2E tests locally.

## Prerequisites

Before running tests, ensure:
- [ ] Node.js 20+ is installed
- [ ] Dependencies are installed: `npm install`
- [ ] Environment is configured (tests use mock data by default)

## Quick Start

**Recommended approach**: Let Playwright auto-start the dev server for you.

```bash
# Run all tests (Playwright starts dev server automatically)
npx playwright test

# Run specific test file
npx playwright test e2e-tests/copilot.org.spec.ts

# Run specific test by name
npx playwright test --grep "has title"
```

**That's it!** Playwright will:
1. Automatically start `npm run dev`
2. Wait for `http://localhost:3000` to be ready
3. Run your tests
4. Clean up the dev server when done

## Alternative: Manual Dev Server (for debugging)

If you need to see dev server logs or debug issues:

**Terminal 1** - Start and keep running:
```bash
npm run dev
# Wait for: "✔ Nuxt DevTools is enabled"
```

**Terminal 2** - Run tests:
```bash
npx playwright test e2e-tests/copilot.org.spec.ts --headed
```

**Important**: Keep Terminal 1 running. Don't cancel the dev server or tests will fail.

## Test Commands

Choose the command based on what you need:

## Test Commands

Choose the command based on what you need:

### Run All Tests
```bash
npx playwright test
```

### Run Single Test File
```bash
npx playwright test e2e-tests/copilot.org.spec.ts

# With browser visible
npx playwright test e2e-tests/copilot.org.spec.ts --headed

# Step through with debugger
npx playwright test e2e-tests/copilot.org.spec.ts --debug
```

### Run Single Test by Name
```bash
npx playwright test --grep "has title"

# In specific file
npx playwright test e2e-tests/copilot.org.spec.ts --grep "has title"

# With browser visible
npx playwright test --grep "has title" --headed
```

### Run Tests by Tag
```bash
npx playwright test --grep @org        # Organization tests
npx playwright test --grep @ent        # Enterprise tests  
npx playwright test --grep @team       # Team tests
npx playwright test --grep @smoke      # Smoke tests
```

### Run in UI Mode (Interactive)
```bash
npx playwright test --ui
```

### Run Specific Browser
```bash
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit
```

## Common Use Cases

### Debugging a Failing Test
```bash
# 1. Start dev server manually (Terminal 1)
npm run dev

# 2. Open NEW terminal (Terminal 2), then run test in headed mode to see browser
npx playwright test e2e-tests/copilot.org.spec.ts --headed

# 3. Or use debug mode to step through
npx playwright test e2e-tests/copilot.org.spec.ts --debug
```

### Verifying a Code Change
```bash
# Run tests affected by your change
npx playwright test e2e-tests/metrics.spec.ts --headed

# Or run all tests to ensure no regression
npm run test:e2e
```

### Testing New Page Object
```bash
# Run test file that uses the new page object
npx playwright test e2e-tests/your-new-test.spec.ts --headed --reporter=line
```

## Understanding Test URLs

Tests run against these URLs (with mock data):

| Scope | URL Pattern | Example |
|-------|-------------|---------|
| Organization | `/orgs/{org}?mock=true` | `http://localhost:3000/orgs/octo-demo-org?mock=true` |
| Enterprise | `/enterprises/{ent}?mock=true` | `http://localhost:3000/enterprises/octo-enterprise?mock=true` |
| Team | `/orgs/{org}/teams/{team}?mock=true` | `http://localhost:3000/orgs/octodemo-org/teams/the-a-team?mock=true` |

**Critical**: The `?mock=true` query parameter is required for all tests to use mock data.

## Configuration Details

**Base URL**: `http://localhost:3000` (configured in `playwright.config.ts`)

**Auto-start Server**: Enabled via `webServer` config:
```typescript
webServer: {
  command: 'npm run dev',
  url: 'http://localhost:3000',
  reuseExistingServer: !process.env.CI,
}
```

**Test Directory**: `e2e-tests/`

**Browsers**: Tests run on Chromium, Firefox, and WebKit by default

## Troubleshooting

### "Error: connect ECONNREFUSED"
- **Cause**: Dev server not running
- **Fix**: Start dev server with `npm run dev` in separate terminal

### "Timeout waiting for http://localhost:3000"
- **Cause**: Dev server starting too slowly
- **Fix**: Wait for dev server to fully start before running tests
- **Check**: See "✔ Nuxt DevTools is enabled" message

### "Test failed: expected title to match..."
- **Cause**: Breaking change in app code
- **Fix**: Either fix the app code or update the test expectation
- **Example**: Check PR #10 for breaking change demonstration

### Browser Installation Failed
- **Cause**: Playwright browsers not installed
- **Fix**: Run `npx playwright install`

### Port 3000 Already in Use
- **Cause**: Another process using port 3000
- **Fix**: Stop other process or change port in `nuxt.config.ts`

## Output and Reporting

### Default Reporter (List)
```bash
npx playwright test
# Shows: ✓ passed tests, ✗ failed tests, execution time
```

### HTML Reporter (After Test Run)
```bash
npx playwright show-report
# Opens browser with detailed HTML report
```

### Line Reporter (Minimal)
```bash
npx playwright test --reporter=line
# Shows minimal output, good for CI
```

## Best Practices

1. **Always use mock data**: Ensure `?mock=true` is in test URLs
2. **Run headed mode for debugging**: Use `--headed` to see what's happening
3. **Start server manually when debugging**: Easier to see server logs
4. **Run specific tests during development**: Faster feedback loop
5. **Run all tests before committing**: Ensure no regressions

## Quick Reference

```bash
# Most common commands:

# 1. Debug single test with browser visible
npx playwright test e2e-tests/copilot.org.spec.ts --headed

# 2. Run specific test by name
npx playwright test --grep "has title" --headed

# 3. Run all tests (CI simulation)
npm run test:e2e

# 4. Interactive test selection
npx playwright test --ui

# 5. Run with detailed debugging
npx playwright test e2e-tests/copilot.org.spec.ts --debug
```

## When to Run Tests

**Before committing**:
- Run tests affected by your changes
- Run all tests if changing core functionality

**During development**:
- Run specific test file you're working on
- Use `--headed` mode to verify UI behavior

**After creating new test**:
- Run new test file to verify it works
- Run with different browsers: `--project=chromium,firefox,webkit`

**Before creating PR**:
- Run full test suite: `npm run test:e2e`
- Ensure all tests pass