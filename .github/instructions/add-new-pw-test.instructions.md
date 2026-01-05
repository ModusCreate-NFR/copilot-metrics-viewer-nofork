---
applyTo: '**'
---

# Playwright Test Creation Instructions

Guidelines for adding new Playwright E2E tests while avoiding duplication and maintaining consistency.

## Existing Page Objects

**CRITICAL: Search before creating! Existing page objects:**

- **DashboardPage.ts** - Main page with navigation (`goto*Tab()` methods, `expectMetricLabelsVisible()`, `close()`)
- **LanguagesTab.ts** - Language metrics (`expectTop5LanguagesVisible()`, `expectNumberOfLanguagesReturned()`)
- **EditorsTab.ts** - Editor metrics (`expectNumberOfEditorsVisible()`)
- **CopilotChatTab.ts** - Chat metrics (`expectCumulativeNumberOfTurnsVisible()`)
- **SeatAnalysisTab.ts** - Seat analysis (`expectTotalAssignedVisible()`)
- **GitHubTab.ts** - GitHub stats with 30+ methods (charts, cards, performance testing)
- **ApiResponseTab.ts** - Minimal page object

**Search commands before creating:**
```bash
ls e2e-tests/pages/                          # List page objects
grep -r "async expect" e2e-tests/pages/      # Find assertion methods
grep -r "getByRole\|getByText" e2e-tests/    # Find locator patterns
```

## Page Object Structure

```typescript
import { expect, type Locator, type Page } from '@playwright/test';

export class YourPageName {
    readonly page: Page;
    readonly submitButton: Locator;
    readonly resultText: Locator;

    constructor(page: Page) {
        this.page = page;
        this.submitButton = page.getByRole('button', { name: 'Submit' });
        this.resultText = page.locator('.result-text');
    }

    async expectResultVisible(timeout = 10000) {
        await expect(this.resultText).toBeVisible({ timeout });
    }
}
```

### Locator Priority (most to least resilient)

1. **Role-based**: `page.getByRole('button', { name: 'Submit' })`
2. **Text-based**: `page.getByText('Exact Text')`
3. **CSS with filters**: `page.locator('.v-card').filter({ hasText: 'Title' })`
4. **CSS selectors**: `page.locator('.class')` (last resort)

### Method Naming

| Type | Prefix | Example |
|------|--------|---------|
| Assertions | `expect` | `expectTitleVisible()` |
| Navigation | `goto` | `gotoLanguagesTab()` |
| Actions | verb | `clickSubmit()` |
| Data | `get` | `getChartCount()` |

## Test File Template

```typescript
import { expect, test } from '@playwright/test';
import { DashboardPage } from './pages/DashboardPage';

const tag = { tag: ['@your-tag'] };

test.describe('Feature Description', () => {
    let dashboard: DashboardPage;

    test.beforeAll(async ({ browser }) => {
        const page = await browser.newPage();
        await page.goto('/orgs/octo-demo-org?mock=true');  // ALWAYS use ?mock=true
        dashboard = new DashboardPage(page);
        await dashboard.expectMetricLabelsVisible();
    });

    test.afterAll(async () => {
        await dashboard?.close();
    });

    test('should verify functionality', tag, async () => {
        const yourPage = await dashboard.gotoYourTab();
        await yourPage.expectMainElementVisible();
    });
});
```

### Parameterized Test Pattern

```typescript
[
    { name: 'Teams', url: '/orgs/octodemo-org/teams/the-a-team?mock=true' },
    { name: 'Orgs', url: '/orgs/octodemo-org?mock=true' },
    { name: 'Enterprises', url: '/enterprises/octo-enterprise?mock=true' },
].forEach(({ name, url }) => {
    test.describe(`tests for ${name}`, () => {
        let dashboard: DashboardPage;
        
        test.beforeAll(async ({ browser }) => {
            const page = await browser.newPage();
            await page.goto(url);
            dashboard = new DashboardPage(page);
        });
        
        test.afterAll(async () => await dashboard.close());
        
        test('your test', async () => { /* ... */ });
    });
});
```

## Common Patterns

### Data Validation
```typescript
async expectDataReturned() {
    const value = await this.valueLocator.textContent();
    expect(value).toBeDefined();
    expect(parseInt(value as string)).toBeGreaterThan(0);
}
```

### Dropdown Selection
```typescript
const dropdown = page.locator('[role="combobox"]').first();
await dropdown.click();
await expect(page.locator('[role="listbox"]')).toBeVisible();
const option = page.locator('[role="listbox"]').getByText('Option').first();
await option.click();
```

### Web-First Assertions
```typescript
// ✓ GOOD - Auto-waits
await expect(page.getByText('welcome')).toBeVisible();

// ✗ BAD - Manual check
expect(await page.getByText('welcome').isVisible()).toBe(true);
```

## TypeScript Best Practices

```typescript
// ✓ Use type imports
import { expect, test, type Locator, type Page } from '@playwright/test';

// ✓ Avoid 'any'
async getData(): Promise<string | null> {
    return await this.element.textContent();
}

// ✓ Optional chaining for cleanup
test.afterAll(async () => {
    await dashboard?.close();
});
```

## Pre-Creation Checklist

**Search Phase:**
- [ ] Listed existing page objects in `e2e-tests/pages/`
- [ ] Searched for similar methods/locators in existing files
- [ ] Verified no duplicate functionality exists

**Implementation Phase:**
- [ ] Used role-based locators (first choice)
- [ ] Followed naming conventions (`expect*`, `goto*`, `get*`)
- [ ] Used `readonly` for locators
- [ ] Added configurable timeouts (default 10000ms)
- [ ] Used web-first assertions
- [ ] Included `?mock=true` in URLs
- [ ] Added `beforeAll`/`afterAll` hooks
- [ ] Used TypeScript types (no `any`)

**Validation Phase:**
- [ ] Ran: `npx playwright test e2e-tests/your-test.spec.ts`
- [ ] Checked: `npm run lint` (no new errors)
- [ ] Verified: No unused imports or type errors

## Common Pitfalls

1. ❌ Creating duplicate page objects → Search first!
2. ❌ Fragile CSS selectors → Use role/text-based
3. ❌ Manual assertions → Use web-first `expect().toBeVisible()`
4. ❌ Missing `?mock=true` → Tests will fail
5. ❌ Not calling `page.close()` → Resource leaks
6. ❌ Using `any` type → Be explicit with types

## Summary

**Key Principles:**
1. ✅ **Search extensively** before creating
2. ✅ **Reuse page objects** when possible
3. ✅ **Use role-based locators** first
4. ✅ **Test with mock data** (`?mock=true`)
5. ✅ **Follow TypeScript best practices** (no `any`)
6. ✅ **Complete checklist** before implementation

**Running Tests:**
```bash
npm run test:e2e                             # All tests
npx playwright test e2e-tests/your.spec.ts   # Specific file
npx playwright test --grep @org              # By tag
npx playwright test --headed                 # See browser
npx playwright test --debug                  # Debug mode
```

## Project Test Organization

### Directory Structure

```
e2e-tests/
├── *.spec.ts          # Test specification files
└── pages/             # Page Object Model classes
    ├── DashboardPage.ts
    ├── LanguagesTab.ts
    ├── EditorsTab.ts
    ├── CopilotChatTab.ts
    ├── SeatAnalysisTab.ts
    ├── ApiResponseTab.ts
    └── GitHubTab.ts
```

### Existing Test Files

- **copilot.org.spec.ts** - Organization-level tests
- **copilot.ent.spec.ts** - Enterprise-level tests
- **copilot.team.spec.ts** - Team-level tests
- **metrics.spec.ts** - Cross-scope metrics tests (parameterized)
- **github-tab.spec.ts** - GitHub statistics tab tests
- **teams-comparison.spec.ts** - Teams comparison functionality tests

### Existing Page Objects

Before creating new page objects, **ALWAYS search for existing ones**:

1. **DashboardPage.ts** - Main dashboard page with tab navigation
   - Methods: `expectToHaveTitle()`, `expectMetricLabelsVisible()`, `expectDataReturned()`
   - Navigation: `gotoLanguagesTab()`, `gotoEditorsTab()`, `gotoSeatAnalysisTab()`, `gotoCopilotChatTab()`, `gotoGitHubTab()`, `gotoTeamsTab()`
   - Tab visibility: `expectTeamsTabVisible()`, `expectTeamTabVisible()`, `expectOrgTabVisible()`, `expectEnterpriseTabVisible()`
   - Lifecycle: `close()`

2. **LanguagesTab.ts** - Language breakdown functionality
   - Locators: `top5Languages`, `numberOfLanguagesValue`
   - Methods: `expectTop5LanguagesVisible()`, `expectNumberOfLanguagesReturned()`

3. **EditorsTab.ts** - Editor metrics
   - Locators: `numberOfEditorsLabel`, `numberOfEditorsValue`
   - Methods: `expectNumberOfEditorsVisible()`, `expectNumberOfEditorsReturned()`

4. **CopilotChatTab.ts** - Copilot Chat metrics
   - Locators: `cumulativeNumberOfTurnsLabel`, `cumulativeNumberOfTurnsValue`
   - Methods: `expectCumulativeNumberOfTurnsVisible()`, `expectCumulativeNumberOfTurnsReturned()`

5. **SeatAnalysisTab.ts** - Seat analysis functionality
   - Locators: `totalAssignedLabel`, `totalAssignedValue`
   - Methods: `expectTotalAssignedVisible()`, `expectTotalAssignedReturned()`

6. **ApiResponseTab.ts** - API response display
   - Minimal page object (structure only)

7. **GitHubTab.ts** - GitHub statistics and agent mode viewer
   - Extensive locators for charts, cards, expansion panels
   - Performance testing methods: `measureRenderTime()`, `expectRenderTimeUnderLimit()`
   - Interaction methods: `clickFirstExpansionPanel()`, `expectTooltipInteraction()`
   - Methods: 30+ assertion methods for various UI components

## CRITICAL: Search Before Creating

### Step 1: Search for Existing Page Objects

**ALWAYS run these searches before creating a new page object:**

```bash
# Search for existing page objects
ls e2e-tests/pages/

# Search for methods by functionality
grep -r "async expect" e2e-tests/pages/
grep -r "async goto" e2e-tests/pages/
grep -r "readonly.*Locator" e2e-tests/pages/

# Search for specific UI element patterns
grep -r "getByRole\|getByText\|locator" e2e-tests/pages/
```

### Step 2: Search for Existing Locators

Before adding new locators to a page object, check if similar ones exist:

```typescript
// Search patterns in existing page objects:
// - Text-based: page.getByText('...')
// - Role-based: page.getByRole('button', { name: '...' })
// - CSS selectors: page.locator('.v-card')
// - Filter chains: page.locator('.v-card').filter({ hasText: '...' })
```

### Step 3: Search for Existing Test Patterns

Check existing test files for similar test scenarios:

```bash
# Find tests with similar functionality
grep -r "test.describe\|test(" e2e-tests/*.spec.ts

# Find beforeAll/afterAll patterns
grep -r "beforeAll\|afterAll" e2e-tests/*.spec.ts

# Find parameterized test patterns
grep -A 5 "forEach" e2e-tests/*.spec.ts
```

## Page Object Model (POM) Best Practices

### 1. Page Object Class Structure

```typescript
import { expect, type Locator, type Page } from '@playwright/test';

export class YourPageName {
    readonly page: Page;
    
    // Define all locators as readonly properties
    readonly mainElement: Locator;
    readonly submitButton: Locator;
    readonly resultText: Locator;

    constructor(page: Page) {
        this.page = page;
        
        // Initialize locators in constructor
        this.mainElement = page.locator('.main-container');
        this.submitButton = page.getByRole('button', { name: 'Submit' });
        this.resultText = page.locator('.result-text');
    }

    // Action methods (prefix: no prefix, just verb)
    async clickSubmit() {
        await this.submitButton.click();
    }

    // Navigation methods (prefix: goto)
    async goto() {
        await this.page.goto('/your-path');
    }

    // Assertion methods (prefix: expect)
    async expectMainElementVisible() {
        await expect(this.mainElement).toBeVisible();
    }

    async expectResultText(expectedText: string) {
        await expect(this.resultText).toHaveText(expectedText);
    }

    // Data extraction methods (prefix: get)
    async getResultCount() {
        const text = await this.resultText.textContent();
        return parseInt(text as string);
    }
}
```

### 2. Locator Selection Priority

**Use this order of preference:**

1. **Role-based locators** (most resilient to UI changes)
   ```typescript
   page.getByRole('button', { name: 'Submit' })
   page.getByRole('heading', { name: 'Title' })
   page.getByRole('tab', { name: 'languages' })
   ```

2. **Text-based locators** (good for static text)
   ```typescript
   page.getByText('Exact Text')
   page.getByText(/Regex Pattern/)
   ```

3. **Test ID locators** (if data-testid attributes exist)
   ```typescript
   page.getByTestId('element-id')
   ```

4. **CSS selectors with filters** (when above options aren't available)
   ```typescript
   page.locator('.v-card').filter({ hasText: 'Card Title' })
   page.locator('.v-card-item').filter({ has: page.getByText('Label') }).locator('.text-h4')
   ```

5. **CSS selectors** (last resort)
   ```typescript
   page.locator('.specific-class')
   ```

**AVOID:**
- Fragile CSS selectors based on styling classes
- XPath selectors (prefer CSS)
- Positional selectors without semantic meaning (nth-child)

### 3. Method Naming Conventions

| Method Type | Prefix | Example |
|-------------|--------|---------|
| Assertions | `expect` | `expectTitleVisible()`, `expectDataReturned()` |
| Navigation | `goto` | `gotoLanguagesTab()`, `goto()` |
| Actions | (verb) | `clickSubmit()`, `fillForm()`, `selectOption()` |
| Data retrieval | `get` | `getChartCount()`, `getResultValue()` |

### 4. Timeout Configuration

```typescript
// Provide configurable timeouts with sensible defaults
async expectElementVisible(timeout = 10000) {
    await expect(this.element).toBeVisible({ timeout });
}

// Use longer timeouts for slow-rendering components
async expectChartRendered(timeout = 15000) {
    await expect(this.chartContainer).toBeVisible({ timeout });
}
```

## Test File Structure

### 1. Basic Test File Template

```typescript
import { expect, test } from '@playwright/test';
import { YourPageObject } from './pages/YourPageObject';
import { DashboardPage } from './pages/DashboardPage';

const tag = { tag: ['@your-tag'] };

test.describe('Your Feature Description', () => {

    let dashboard: DashboardPage;

    test.beforeAll(async ({ browser }) => {
        const page = await browser.newPage();
        await page.goto('/orgs/octo-demo-org?mock=true');

        dashboard = new DashboardPage(page);

        // Wait for initial data load
        await dashboard.expectMetricLabelsVisible();
    });

    test.afterAll(async () => {
        await dashboard?.close();
    });

    test('should verify basic functionality', tag, async () => {
        const yourPage = await dashboard.gotoYourTab();
        await yourPage.expectMainElementVisible();
    });
});
```

### 2. Parameterized Test Pattern

Use this pattern to test multiple scopes (org, enterprise, team):

```typescript
import { expect, test } from '@playwright/test';
import { DashboardPage } from './pages/DashboardPage';

const tag = { tag: ['@ent', '@org', '@team'] };

[
    { name: 'Teams', url: '/orgs/octodemo-org/teams/the-a-team?mock=true' },
    { name: 'Orgs', url: '/orgs/octodemo-org?mock=true' },
    { name: 'Enterprises', url: '/enterprises/octo-enterprise?mock=true' },
].forEach(({ name, url }) => {

    test.describe(`tests for ${name}`, () => {

        let dashboard: DashboardPage;

        test.beforeAll(async ({ browser }) => {
            const page = await browser.newPage();
            await page.goto(url);

            dashboard = new DashboardPage(page);
            await dashboard.expectMetricLabelsVisible();
        });

        test.afterAll(async () => {
            await dashboard.close();
        });

        test('your test name', tag, async () => {
            // Test implementation
        });
    });
});
```

### 3. Test Organization

```typescript
test.describe('Feature Group Name', () => {
    // Group related tests together

    test.beforeAll(async ({ browser }) => {
        // Setup once for all tests
    });

    test.afterAll(async () => {
        // Cleanup once after all tests
    });

    test('test case 1', async () => {
        // Individual test
    });

    test('test case 2', async () => {
        // Individual test
    });
});
```

## Mock Data Configuration

### Using Mock Data in Tests

**ALWAYS use mock data for E2E tests:**

```typescript
// Append ?mock=true to URLs
await page.goto('/orgs/octo-demo-org?mock=true');
await page.goto('/enterprises/octo-enterprise?mock=true');
await page.goto('/orgs/octodemo-org/teams/the-a-team?mock=true');
```

**Mock data is configured globally in `playwright.config.ts`:**

```typescript
process.env.NUXT_PUBLIC_IS_DATA_MOCKED = 'true'
```

### Mock Data Paths

Mock data files are located in `/public/mock-data/`:
- Organization data
- Enterprise data
- Team data
- Metrics responses
- Seat analysis data

## Common Patterns and Examples

### 1. Tab Navigation Pattern

```typescript
test('navigate to tab and verify content', async () => {
    const yourTab = await dashboard.gotoYourTab();
    await yourTab.expectContentVisible();
    await yourTab.expectDataReturned();
});
```

### 2. Data Validation Pattern

```typescript
async expectDataReturned() {
    const value = await this.valueLocator.textContent();
    expect(value).toBeDefined();
    expect(parseInt(value as string)).toBeGreaterThan(0);
}
```

### 3. Chart Rendering Pattern

```typescript
async expectChartRendered() {
    const chartCount = await this.chartContainers.count();
    expect(chartCount).toBeGreaterThan(0);
    await expect(this.chartContainers.first()).toBeVisible();
}
```

### 4. Performance Testing Pattern

```typescript
async measureRenderTime() {
    const startTime = Date.now();
    await this.page.waitForLoadState('networkidle');
    const endTime = Date.now();
    return endTime - startTime;
}

async expectRenderTimeUnderLimit(maxTime = 5000) {
    const renderTime = await this.measureRenderTime();
    expect(renderTime).toBeLessThan(maxTime);
    return renderTime;
}
```

### 5. Dropdown/Combobox Selection Pattern

```typescript
test('select from dropdown', async () => {
    const dropdown = page.locator('[role="combobox"]').first();
    await expect(dropdown).toBeVisible();
    await dropdown.click();

    await expect(page.locator('[role="listbox"]')).toBeVisible();

    const option = page.locator('[role="listbox"]').getByText('Option Name').first();
    await expect(option).toBeVisible();
    await option.click();
});
```

### 6. Expansion Panel Pattern

```typescript
async clickFirstExpansionPanel() {
    const panelCount = await this.expansionPanel.count();
    if (panelCount > 0) {
        await this.expansionPanel.first().click();
        await expect(this.dataTables.first()).toBeVisible({ timeout: 5000 });
    } else {
        expect(panelCount).toBe(0);
    }
}
```

### 7. Empty State Testing Pattern

```typescript
test('verify empty state message', async () => {
    await dashboard.gotoYourTab();

    const emptyStateMessage = page.getByText('No Data Available');
    await expect(emptyStateMessage).toBeVisible();

    const emptyStateDescription = page.getByText('Description of empty state');
    await expect(emptyStateDescription).toBeVisible();
});
```

## TypeScript Best Practices

### 1. Type Imports

```typescript
import { expect, test, type Locator, type Page } from '@playwright/test';
```

**Always use `type` keyword for type-only imports.**

### 2. Avoid `any` Type

```typescript
// ✗ BAD
async getData(): any {
    return await this.element.textContent();
}

// ✓ GOOD
async getData(): Promise<string | null> {
    return await this.element.textContent();
}
```

### 3. Optional Chaining

```typescript
test.afterAll(async () => {
    await dashboard?.close();  // Safe cleanup
});
```

## Testing Best Practices

### 1. Web-First Assertions

```typescript
// ✓ GOOD - Auto-waits for condition
await expect(page.getByText('welcome')).toBeVisible();

// ✗ BAD - Manual check, no waiting
expect(await page.getByText('welcome').isVisible()).toBe(true);
```

### 2. Test Isolation

Each test should be independent and not rely on previous test state:

```typescript
test.beforeAll(async ({ browser }) => {
    // Fresh page for test suite
    const page = await browser.newPage();
    await page.goto('/your-path?mock=true');
});

test.afterAll(async () => {
    // Clean up resources
    await dashboard?.close();
});
```

### 3. Descriptive Test Names

```typescript
// ✓ GOOD
test('should display loading state initially', async () => {});
test('should show error message when API fails', async () => {});

// ✗ BAD
test('test 1', async () => {});
test('check page', async () => {});
```

### 4. Tagging Tests

```typescript
const tag = { tag: ['@org', '@smoke'] };

test('your test', tag, async () => {
    // Can filter tests by tag when running
});
```

### 5. Screenshots (Optional)

```typescript
// Uncomment when documenting functionality
// await page.screenshot({
//     path: 'images/feature-name.png',
//     fullPage: true
// });
```

## Running Tests

### Local Development

```bash
# Run all tests
npm run test:e2e

# Run specific test file
npx playwright test e2e-tests/copilot.org.spec.ts

# Run tests by tag
npx playwright test --grep @org

# Run tests in headed mode (see browser)
npx playwright test --headed

# Run specific browser
npx playwright test --project=chromium
```

### Debugging Tests

```bash
# Run with Playwright Inspector
npx playwright test --debug

# Run with UI mode
npx playwright test --ui
```

## Configuration Details

### Playwright Config (`playwright.config.ts`)

- **testDir**: `'e2e-tests'`
- **fullyParallel**: `true` (tests run in parallel)
- **retries**: `2` on CI, `0` locally
- **workers**: `1` on CI, `undefined` locally
- **browsers**: chromium, firefox, webkit
- **baseURL**: `http://localhost:3000`
- **webServer**: Automatically starts dev server

### Environment Variables

Tests automatically use mocked data:
```typescript
process.env.NUXT_PUBLIC_USING_GITHUB_AUTH = 'false'
process.env.NUXT_PUBLIC_IS_DATA_MOCKED = 'true'
```

## Pre-Creation Checklist for AI

Before creating any new test or page object, complete this checklist:

### Git Workflow Phase
- [ ] **Checked current branch** using `git branch --show-current`
- [ ] **Confirmed not on main/master** branch
- [ ] **Created feature branch** from main using naming convention: `feature/add-<component>-e2e-test`
  - Example: `git checkout -b feature/add-date-range-selector-e2e-test`
- [ ] **Verified clean working directory** (no uncommitted changes that could interfere)

### Search Phase
- [ ] **Listed all existing page objects** in `e2e-tests/pages/`
- [ ] **Searched for similar test files** in `e2e-tests/*.spec.ts`
- [ ] **Checked for existing locators** that target the same UI elements
- [ ] **Searched for existing methods** that perform similar actions
- [ ] **Verified no duplicate functionality** exists in other page objects

**⚠️ COMMUNICATE TO USER:** Report search findings before proceeding:
- List all page objects found in workspace
- Identify any similar test patterns or existing functionality
- Confirm no duplication exists or explain what will be reused
- Example: "Found 7 page objects: DashboardPage, LanguagesTab, EditorsTab... No existing DateRangeSelector found. No duplicate functionality exists."

### Design Phase

**When to create a NEW page object:**
- Component has **distinct UI elements** (unique buttons, inputs, dropdowns) not shared with other components
- Component has **independent behavior** (e.g., date selection, filtering, form submission)
- Component is **reusable across multiple tests** 
- Component follows **single responsibility principle** (focused on one feature)
- **Example:** DateRangeSelector has its own inputs, buttons, and checkbox - separate from DashboardPage metrics

**When to EXTEND existing page object:**
- Adding simple locators to an existing component (e.g., new button on dashboard)
- Testing small UI variations of existing functionality
- Component is tightly coupled to parent page
- **Example:** Adding a new metric card to DashboardPage - just add locators to DashboardPage.ts

**⚠️ COMMUNICATE TO USER:** Explain design decision before implementation:
- State whether creating NEW page object or EXTENDING existing one
- Provide clear reasoning based on criteria above
- List what will be created (page object, test file, modifications)
- Example: "Creating NEW DateRangeSelector page object because: 1) Has distinct UI elements (date inputs, buttons, checkbox), 2) Independent filtering behavior, 3) Reusable across scopes. Will also add getDateRangeSelector() method to DashboardPage for easy access."

- [ ] **Determined if existing page object can be extended** instead of creating new one
- [ ] **Identified correct locator types** (role-based > text-based > CSS)
- [ ] **Planned method names** following conventions (expect*, goto*, get*)
- [ ] **Considered reusability** of page object across multiple tests
- [ ] **Reviewed similar patterns** in existing tests for consistency

### Implementation Phase
- [ ] **Used TypeScript types correctly** (avoided `any`, used `type` imports)
- [ ] **Followed naming conventions** for methods and properties
- [ ] **Added configurable timeouts** with sensible defaults (10000ms)
- [ ] **Implemented web-first assertions** (auto-waiting)
- [ ] **Used readonly properties** for locators
- [ ] **Added descriptive test names** that explain what is being tested
- [ ] **Included proper beforeAll/afterAll** hooks for setup/cleanup
- [ ] **Used mock data URLs** (`?mock=true`)
- [ ] **Added appropriate tags** for test categorization
- [ ] **Followed Page Object Model** structure and patterns

### Validation Phase
- [ ] **Verified no ESLint errors** introduced (especially @typescript-eslint/no-explicit-any)
- [ ] **Checked for unused imports** (will cause linting errors)
- [ ] **Ensured proper type annotations** for all methods
- [ ] **Confirmed test follows existing patterns** from similar tests
- [ ] **Validated locator selectors** are resilient to UI changes
- [ ] **Tested tab navigation flow** if adding new tab page object

### Documentation Phase
- [ ] **Added code comments** for complex logic or non-obvious patterns
- [ ] **Documented any deviations** from standard patterns
- [ ] **Explained timeout choices** if using non-default values
- [ ] **Noted any assumptions** about page structure or behavior

## Post-Creation Validation

After creating tests, run these validations:

```bash
# 1. Run the new test file
npx playwright test e2e-tests/your-new-test.spec.ts

# 2. Check for linting errors
npm run lint

# 3. Run all tests to ensure no regression
npm run test:e2e

# 4. Type check
npm run typecheck
```

## Common Pitfalls to Avoid

1. **Creating duplicate page objects** - Always search first!
2. **Using fragile CSS selectors** - Prefer role-based and text-based locators
3. **Not using web-first assertions** - Let Playwright auto-wait
4. **Forgetting mock=true parameter** - Tests will fail without it
5. **Missing beforeAll/afterAll hooks** - Tests may not clean up properly
6. **Hardcoded timeouts** - Use configurable parameters
7. **Using `any` type** - Be explicit with TypeScript types
8. **Not calling page.close()** - Resource leaks
9. **Overly specific selectors** - Tests become brittle
10. **Not testing empty states** - Important edge case
11. **Working on main/master branch** - Always create a feature branch first!

## Summary

**Key principles for adding Playwright tests:**

1. ✅ **Create feature branch first** - Never work directly on main/master
2. ✅ **Search extensively** before creating anything new
3. ✅ **Reuse existing page objects** whenever possible
4. ✅ **Follow naming conventions** strictly
5. ✅ **Use role-based locators** as first choice
6. ✅ **Implement web-first assertions** for auto-waiting
6. ✅ **Test with mock data** using `?mock=true`
7. ✅ **Maintain Page Object Model** structure
8. ✅ **Write TypeScript properly** (no `any`, use `type` imports)
9. ✅ **Add descriptive test names** and tags
10. ✅ **Complete the checklist** before and after implementation

**Remember:** The goal is to create maintainable, resilient, and non-duplicative tests that accurately reflect user interactions with the application.