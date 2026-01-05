#!/bin/bash
# Script to run Copilot CLI investigation in CI/CD or locally
# Can be used for manual testing or as part of GitHub Actions

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== GitHub Copilot CLI Test Fixer ===${NC}"
echo ""

# Check required environment variables
check_required_env() {
    local missing=0
    
    if [ -z "$COPILOT_CLI_TOKEN" ]; then
        echo -e "${RED}❌ COPILOT_CLI_TOKEN not set${NC}"
        missing=1
    fi
    
    if [ -z "$JIRA_API_TOKEN" ]; then
        echo -e "${YELLOW}⚠️  JIRA_API_TOKEN not set (Jira integration will not work)${NC}"
    fi
    
    if [ -z "$JIRA_USER_EMAIL" ]; then
        echo -e "${YELLOW}⚠️  JIRA_USER_EMAIL not set (Jira integration will not work)${NC}"
    fi
    
    if [ $missing -eq 1 ]; then
        echo ""
        echo "Required environment variables:"
        echo "  COPILOT_CLI_TOKEN - GitHub PAT with Copilot permissions"
        echo ""
        echo "Optional (for Jira integration):"
        echo "  JIRA_API_TOKEN - Atlassian API token"
        echo "  JIRA_USER_EMAIL - Jira user email"
        exit 1
    fi
}

# Configuration
WORKFLOW_RUN_URL="${1:-https://github.com/github-copilot-resources/copilot-metrics-viewer/actions}"
FAILED_TESTS="${2:-unknown}"
BRANCH="${3:-main}"
COMMIT_SHA="${4:-$(git rev-parse HEAD)}"

echo "Configuration:"
echo "  Workflow: $WORKFLOW_RUN_URL"
echo "  Branch: $BRANCH"
echo "  Commit: $COMMIT_SHA"
echo "  Failed Tests: $FAILED_TESTS"
echo ""

# Check environment
check_required_env

# Check if Copilot CLI is installed
if ! command -v copilot &> /dev/null; then
    echo -e "${YELLOW}Installing Copilot CLI...${NC}"
    npm install -g @github/copilot-cli@latest
fi

echo -e "${GREEN}✅ Copilot CLI version: $(copilot --version)${NC}"
echo ""

# Create Copilot config directory
mkdir -p ~/.copilot

# Configure MCP servers if Jira credentials are available
if [ -n "$JIRA_API_TOKEN" ] && [ -n "$JIRA_USER_EMAIL" ]; then
    echo "Configuring Atlassian MCP server..."
    cat > ~/.copilot/mcp-config.json <<EOF
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@janhq/mcp-server-atlassian"],
      "env": {
        "JIRA_API_TOKEN": "$JIRA_API_TOKEN",
        "JIRA_USER_EMAIL": "$JIRA_USER_EMAIL",
        "JIRA_CLOUD_ID": "4c609fb1-ed57-4449-a5b4-d897fd7e3da8"
      }
    }
  }
}
EOF
    echo -e "${GREEN}✅ Atlassian MCP server configured${NC}"
else
    echo -e "${YELLOW}⚠️  Skipping Jira MCP configuration (credentials not provided)${NC}"
fi

# Trust current directory
echo "Trusting current directory..."
mkdir -p ~/.copilot/trusted
echo "$(pwd)" > ~/.copilot/trusted/dirs.txt
echo -e "${GREEN}✅ Directory trusted${NC}"
echo ""

# Gather context
echo "Gathering failure context..."

# Create failure summary
cat > /tmp/failure-summary.md <<EOF
## Test Failure Analysis

**Workflow Run:** $WORKFLOW_RUN_URL
**Branch:** $BRANCH
**Commit:** $COMMIT_SHA

**Failed Tests:**
$FAILED_TESTS

EOF

# Add recent commits
echo "## Recent Commits" >> /tmp/failure-summary.md
git log --oneline -5 >> /tmp/failure-summary.md || echo "Could not fetch git log" >> /tmp/failure-summary.md

# List test result files if available
if [ -d "test-results" ]; then
    echo "" >> /tmp/failure-summary.md
    echo "## Test Result Files Available" >> /tmp/failure-summary.md
    find test-results -type f -name "*.png" -o -name "*.webm" | head -10 >> /tmp/failure-summary.md || true
fi

echo -e "${GREEN}✅ Context gathered${NC}"
echo ""

# Create investigation prompt
cat > /tmp/investigation-prompt.txt <<'PROMPT'
You are investigating a Playwright test failure in the copilot-metrics-viewer project.

Context:
PROMPT

cat /tmp/failure-summary.md >> /tmp/investigation-prompt.txt

cat >> /tmp/investigation-prompt.txt <<'PROMPT'

Your tasks:
1. Analyze why the Playwright tests failed by reviewing:
   - Test result artifacts in test-results/ (if available)
   - Recent commits to identify UI or code changes
   - Test files in e2e-tests/ to understand what broke
   - Page objects in e2e-tests/pages/ that might need updates

2. Determine root cause:
   - Is it a UI text change? (e.g., "Organisation" → "Org")
   - Is it a selector change? (button class renamed)
   - Is it a timing issue? (element loads slower)
   - Is it a breaking change? (feature removed)

3. Fix the test code (NOT application code):
   - Update test assertions to match new UI behavior
   - Update page object locators if needed
   - Follow patterns from @.github/instructions/add-new-pw-test.instructions.md
   - Maintain proper TypeScript types (no 'any')

4. Create Jira Sub-task under GHC-1392:
   - Use Atlassian MCP if available
   - Include failure details, root cause, fix description
   - Link to workflow run and commit

5. Create GitHub issue:
   - Link to Jira ticket
   - Include labels: bug, ci-failure, playwright, automated
   - Describe failure and proposed fix

6. Use /delegate to create fix PR:
   - Provide clear context about what needs to be fixed
   - Include specific file paths and line numbers
   - Mention test file and assertion that needs updating

Be thorough, professional, and include all relevant links and context.
PROMPT

echo "Investigation prompt created"
echo ""

# Display prompt for review
echo -e "${YELLOW}=== Investigation Prompt ===${NC}"
cat /tmp/investigation-prompt.txt
echo ""

# Run Copilot CLI
echo -e "${GREEN}=== Running Copilot CLI with test-fixer agent ===${NC}"
echo ""

# Set output file
OUTPUT_FILE="${OUTPUT_FILE:-/tmp/copilot-investigation-output.log}"

# Run with appropriate flags based on environment
if [ "${CI}" = "true" ]; then
    # CI environment - non-interactive, auto-approve
    echo "Running in CI mode (non-interactive, auto-approve)"
    copilot --agent=test-fixer \
            --auto-approve \
            --prompt="$(cat /tmp/investigation-prompt.txt)" \
            2>&1 | tee "$OUTPUT_FILE"
else
    # Local environment - interactive
    echo "Running in interactive mode (you can review actions)"
    copilot --agent=test-fixer \
            --prompt="$(cat /tmp/investigation-prompt.txt)" \
            2>&1 | tee "$OUTPUT_FILE"
fi

echo ""
echo -e "${GREEN}=== Investigation Complete ===${NC}"
echo ""
echo "Output saved to: $OUTPUT_FILE"
echo ""

# Check for errors
if grep -q "error\|Error\|ERROR" "$OUTPUT_FILE"; then
    echo -e "${RED}⚠️  Errors detected in output${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Investigation completed successfully${NC}"
fi

# Display summary if available
if grep -q "✅ Analysis Complete" "$OUTPUT_FILE"; then
    echo ""
    echo -e "${GREEN}=== Summary ===${NC}"
    grep -A 10 "✅ Analysis Complete" "$OUTPUT_FILE"
fi

exit 0
