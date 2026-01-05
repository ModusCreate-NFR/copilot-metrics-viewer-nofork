# Copilot CLI Test Fixer - Quick Reference

## 🚀 Setup (One-time)

```bash
# Set GitHub secrets
gh secret set COPILOT_CLI_TOKEN --body "ghp_your_token"
gh secret set JIRA_API_TOKEN --body "your_jira_token"
gh secret set JIRA_USER_EMAIL --body "your@email.com"
```

## 🧪 Run POC

```bash
# 1. Create test branch
git checkout -b test/copilot-cli-poc

# 2. Introduce breaking change (e.g., change "Organisation" to "Org")
# Edit app/components/MainComponent.vue or similar

# 3. Commit and push
git add -A
git commit -m "test: change Organisation to Org for Copilot CLI POC"
git push origin test/copilot-cli-poc

# 4. Watch workflows at:
# https://github.com/github-copilot-resources/copilot-metrics-viewer/actions

# 5. Review PR created by Copilot and approve
```

## 📊 What Happens Automatically

| Step | Time | Actor |
|------|------|-------|
| 1. Playwright Tests fail | ~3 min | GitHub Actions |
| 2. Copilot Test Fixer triggers | Instant | Workflow |
| 3. Downloads test artifacts | ~30 sec | GitHub Actions |
| 4. Analyzes with Copilot CLI | ~2-5 min | Copilot Agent |
| 5. Creates Jira Sub-task (GHC-1392) | ~10 sec | Atlassian MCP |
| 6. Creates GitHub Issue | ~5 sec | GitHub MCP |
| 7. Generates Fix PR | ~2 min | Copilot Coding Agent |
| **Total** | **~8-12 min** | **All automated** |
| 8. Human reviews PR | ~2 min | **YOU** ✋ |
| 9. Merge and validate | ~1 min | **YOU** ✋ |

## 🔍 Where to Check Results

| Item | Location |
|------|----------|
| Workflow runs | [Actions tab](https://github.com/github-copilot-resources/copilot-metrics-viewer/actions) |
| Investigation logs | Workflow artifacts → `copilot-investigation` |
| Commit comment | On the commit that broke tests |
| Jira ticket | [GHC-1392 subtasks](https://github-copilot.atlassian.net/browse/GHC-1392) |
| GitHub issue | [Issues](https://github.com/github-copilot-resources/copilot-metrics-viewer/issues) with `automated` label |
| Fix PR | [Pull Requests](https://github.com/github-copilot-resources/copilot-metrics-viewer/pulls) |

## 🧰 Local Testing

```bash
# Export credentials
export COPILOT_CLI_TOKEN="ghp_your_token"
export JIRA_API_TOKEN="your_jira_token"
export JIRA_USER_EMAIL="your@email.com"

# Run investigation script
./.github/scripts/run-copilot-investigation.sh \
  "https://github.com/org/repo/actions/runs/123" \
  "failed-test-name" \
  "branch-name" \
  "$(git rev-parse HEAD)"

# Or run agent directly
copilot --agent=test-fixer --prompt="Analyze test failure in e2e-tests/copilot.org.spec.ts"
```

## 🐛 Quick Troubleshooting

| Issue | Fix |
|-------|-----|
| Workflow doesn't trigger | Check "Playwright Tests" failed and workflow is on main |
| MCP connection fails | Verify JIRA secrets are correct |
| Copilot auth fails | Check COPILOT_CLI_TOKEN scope: `copilot`, `repo`, `workflow` |
| PR not created | Check copilot-output.log in artifacts |
| Agent not found | Ensure `.github/agents/test-fixer.md` is on main branch |

## 📱 Notifications (Future)

Add to workflow for alerts:
- Slack webhook on failure
- Teams card on PR creation
- Email digest of fixes

## 📈 Metrics to Track

After running POC:
- ✅ Time saved per investigation (target: 15+ min)
- ✅ Fix accuracy rate (target: >80%)
- ✅ Auto-fix vs manual review ratio
- ✅ Jira ticket quality score
- ✅ PR approval time

## 🎯 Success Checklist

After POC run, verify:
- [ ] Copilot Test Fixer workflow ran
- [ ] Root cause identified correctly
- [ ] Test fix was accurate
- [ ] Jira Sub-task created under GHC-1392
- [ ] GitHub issue created and linked
- [ ] PR generated with working fix
- [ ] Tests pass after merge
- [ ] Total time < 15 minutes

## 📚 Documentation Links

- [Full Setup Guide](docs/copilot-cli-setup.md)
- [Testing Guide](docs/copilot-cli-testing-guide.md)
- [Custom Agent](agents/test-fixer.md)
- [Workflow](workflows/copilot-test-fixer.yml)
- [Main README](COPILOT_CLI_README.md)

## 💡 Pro Tips

1. **First run:** Watch logs closely to understand behavior
2. **Debug mode:** Add `--debug` flag to copilot commands in workflow
3. **Dry run:** Test agent locally before pushing
4. **Iterate fast:** Update agent based on first few failures
5. **Monitor costs:** Check Copilot usage in org settings
6. **Share wins:** Document successful automations for team

## 🔧 Customization

```yaml
# Change Jira parent in agent
parent: GHC-XXXX

# Adjust timeout in workflow
timeout-minutes: 30

# Add more MCP servers in workflow
mcpServers:
  slack: {...}
  datadog: {...}
```

## 🆘 Get Help

**File issue with:** `copilot-cli` label

**Slack:** #copilot-cli-help (if available)

**Docs:** https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli

---

**Remember:** Human reviews all PRs ✋ - Copilot speeds up investigation, not replacement for judgment!
