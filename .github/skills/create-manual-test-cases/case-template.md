# Manual test case template

Reader: a manual tester who has never seen the ticket and runs the case from the test management entry alone. Second reader: an automation engineer who turns each step into an action and each expected result into an assertion.

## Fields

| Field | Rule |
|---|---|
| **ID** | `{KEY}-TC1`, `{KEY}-TC2`, ... in the order written. Never reused inside a set. |
| **Title** | What the user does and what happens, under 120 characters. "Removing the last team shows the empty state", not "Verify teams functionality". |
| **Section** | `Feature > Area`: the screen or flow. Cases on the same screen use the same spelling. |
| **Type** | `Functional` for behaviour a criterion states. `Usability`, `Accessibility`, `Security`, `Performance`, `Compatibility` when the criterion is about that quality. |
| **Priority** | `High` for a criterion's main path. `Medium` for negative or boundary cases. `Low` for cosmetic checks. `Critical` only if the ticket says it blocks a release or loses data. |
| **References** | The ticket key. |
| **Covers** | The criterion ids the case checks (`AC2`). At least one. |
| **Automate?** | `E2E` if a browser test should cover it, `Manual only` if it needs human judgement (visual, exploratory). |
| **Preconditions** | The starting state and data, named concretely: which scope, which teams, which date range. Use data the ticket or the mock data names; never an invented name. `None` for a fresh app. |
| **Steps** | One action per step, each with its own expected result. |

## Steps

- **One action per step**, imperative, using the words on screen: "Click **Teams**", "Select **the-a-team** in the Teams list". Two actions joined by "and" are two steps.
- **Every step has an expected result the tester can see.** "The chart shows two lines", "The message reads *No teams selected*". Never "works correctly", "as expected", "no errors".
- When a step only navigates, the expected result is where the tester lands: "The Teams tab opens".
- **No selectors, code, or tooling.**
- The last step's expected result is the one the criterion is about.

## Coverage

- Every criterion not graded Untestable gets **at least one case**.
- Add a **negative or boundary case** where the criterion implies one: nothing selected, one item, the maximum, invalid input.
- **Never write a case for behaviour no criterion states.** Undecided behaviour becomes a question for the author, not a case that guesses.
- One case, one scenario.

## Example

```markdown
### GHC-1695-TC3: Removing the only selected team shows the empty state
- **Section:** Dashboard > Teams comparison
- **Type:** Functional | **Priority:** Medium | **References:** GHC-1695 | **Covers:** AC4 | **Automate?:** E2E
- **Preconditions:** Organization dashboard in mock mode, one team selected for comparison

| # | Action | Expected result |
|---|---|---|
| 1 | Open the **Teams** tab | The comparison shows one team |
| 2 | Remove the selected team chip | The chip disappears |
| 3 | Look at the comparison area | An empty-state message asks you to select teams |
```
