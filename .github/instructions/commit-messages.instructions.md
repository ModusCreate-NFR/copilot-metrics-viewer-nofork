---
applyTo: '**'
---

# Commit Message Guidelines

Follow the Conventional Commits specification for all commit messages in this project.

## Commit Message Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Required Elements

### Type (Required)
The type MUST be one of the following:

- **feat**: A new feature (triggers MINOR version bump)
- **fix**: A bug fix (triggers PATCH version bump)
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, white-space, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **build**: Changes to build system or dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files
- **revert**: Reverts a previous commit

### Description (Required)
- MUST be a short summary of the code change
- MUST immediately follow the colon and space after the type/scope prefix
- MUST use imperative, present tense (e.g., "add" not "added" or "adds")
- MUST be lowercase
- MUST NOT end with a period

## Optional Elements

### Scope (Optional)
- MAY be provided after the type in parentheses
- MUST describe a section of the codebase
- Examples: `feat(api):`, `fix(parser):`, `docs(readme):`
- For this project, common scopes include:
  - `api`: Server-side API endpoints
  - `ui`: Frontend components and UI
  - `metrics`: Metrics calculation and processing
  - `auth`: Authentication and authorization
  - `config`: Configuration files
  - `deps`: Dependency updates
  - `docker`: Docker-related changes
  - `tests`: Test-related changes

### Body (Optional)
- MAY provide additional context about the code change
- MUST begin one blank line after the description
- MAY consist of multiple paragraphs
- SHOULD explain the motivation for the change
- SHOULD explain what changed and why

### Footer(s) (Optional)
- MAY be provided one blank line after the body
- MUST consist of token-value pairs
- Common footers:
  - `BREAKING CHANGE:` or `BREAKING-CHANGE:` - describes breaking changes
  - `Refs:` - references related issues or commits
  - `Reviewed-by:` - indicates reviewers
  - `Closes:` or `Fixes:` - automatically closes issues (e.g., `Fixes #123`)

## Breaking Changes

Breaking changes MUST be indicated in one of two ways:

### Method 1: Using '!' after type/scope
```
feat!: send email notification when product is shipped
```

```
feat(api)!: change user endpoint response format
```

### Method 2: Using BREAKING CHANGE footer
```
feat: allow config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

**Note**: You can use both methods together for maximum clarity.

Breaking changes trigger a MAJOR version bump and indicate backward-incompatible changes.

## Examples

### Simple commit (type + description only)
```
docs: correct spelling in CHANGELOG
```

### Commit with scope
```
feat(lang): add Polish language support
```

### Commit with body
```
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.
```

### Commit with multiple footers
```
fix: correct minor typos in code

see the issue for details on the typos fixed

Reviewed-by: Z
Refs: #123
Closes: #456
```

### Breaking change with '!' notation
```
feat!: send email to customer when product is shipped
```

### Breaking change with footer
```
chore: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6
```

### Breaking change with scope and '!'
```
feat(api)!: change authentication response format

BREAKING CHANGE: API now returns tokens in 'accessToken' field instead of 'token'
```

### Revert commit
```
revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```

## Project-Specific Conventions

### For this Copilot Metrics Viewer project:

1. **Health endpoint changes**: Use `feat(api):` or `fix(api):` scope
   ```
   feat(api): add memory usage to health endpoint
   ```

2. **Metrics visualization changes**: Use `feat(ui):` or `fix(ui):` scope
   ```
   fix(ui): correct chart rendering for seat analysis
   ```

3. **Dependency updates**: Use `chore(deps):` scope
   ```
   chore(deps): update nuxt to v3.12.0
   ```

4. **Docker changes**: Use `build(docker):` or `chore(docker):` scope
   ```
   build(docker): optimize multi-stage build process
   ```

5. **Test updates**: Use `test:` type
   ```
   test: add unit tests for metrics validation
   ```

6. **CI/CD changes**: Use `ci:` type
   ```
   ci: add playwright browser caching
   ```

## Validation

Before committing:
1. Ensure the type is one of the allowed types
2. Verify the description is concise and in present tense
3. If adding breaking changes, ensure they are properly indicated
4. Reference related issues in footers when applicable
5. Keep the first line under 72 characters when possible

## Tools

Consider using these tools to help with commit message formatting:
- `commitlint` - Validates commit messages
- `commitizen` - Interactive commit message builder
- Git hooks (via `husky`) - Automatic validation on commit

## References

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

