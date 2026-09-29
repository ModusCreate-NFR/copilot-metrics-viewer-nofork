---
name: check-acceptance-criteria
description: Review the acceptance criteria of a Jira ticket (or pasted ticket text) for testability before anyone builds or tests it. Grades each criterion testable, vague, or untestable and suggests a concrete rewrite. Use when asked to review, check, grade, or analyze acceptance criteria, or to see if a ticket is ready for testing.
---

# Check Acceptance Criteria

You review requirements the way an experienced QA engineer does in backlog refinement: before code exists, so the author can fix the ticket instead of the tester guessing.

## 1. Get the ticket

- Given a key like `GHC-1695`: fetch it with the Atlassian MCP server (summary, description, acceptance criteria, status).
- MCP not available or not signed in: ask the user to paste the ticket text. Do not guess the content from the key.
- Never edit or comment on the ticket in this skill.

## 2. Find the criteria

Number every acceptance criterion `AC1`, `AC2`, ... in the order the ticket lists them. If the ticket has no explicit criteria section, extract the behaviours the description promises and say that you did.

## 3. Grade each criterion

| Grade | Meaning |
|---|---|
| **Testable** | A tester can set it up, act, and see a pass or fail result without asking anyone. |
| **Vague** | Testable in spirit, but a word leaves room for argument: "fast", "user-friendly", "correctly", "appropriate", "etc.", no numbers, no named data. |
| **Untestable** | No observable outcome, or it describes implementation, not behaviour. |

For every criterion that is not **Testable**, give:
- **Issue**: the exact words that cause the problem.
- **Suggested rewrite**: a Given / When / Then version with concrete values. Use only facts the ticket states; where a value is missing, put a question in `[brackets]` instead of inventing one.

Also check the set as a whole: missing negative paths (empty state, invalid input, no permission), missing scope (which users, which pages), and criteria that contradict each other.

## 4. Report

Reply in this shape and nothing more:

```
## GHC-1695: <summary>
Verdict: Ready | Needs work | Blocked   (Blocked = any untestable criterion)

| AC | Grade | Issue |
|----|-------|-------|
| AC1 | Testable | |
| AC2 | Vague | "quickly" has no threshold |

### Suggested rewrites
**AC2**: Given ..., when ..., then ... within [how many seconds?]

### Gaps
- No criterion covers ...

### Questions for the author
- ...
```

End by offering the next step: "Want me to write manual test cases for the testable criteria?" (the `create-manual-test-cases` skill).
