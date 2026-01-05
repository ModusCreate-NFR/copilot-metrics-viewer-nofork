---
agent: agent
---

# Deploy Copilot Metrics Viewer to Vercel

## Task Overview
Deploy the Copilot Metrics Viewer application to Vercel using the CLI. This project is a Nuxt 3 application that displays GitHub Copilot usage metrics and analytics.

## ⚠️ CRITICAL: Branch Check (MUST DO FIRST)
**Before any deployment, verify the current branch:**

```bash
# Check current branch
git branch --show-current
```

**Important Decision Points:**
- ✅ **If on `main` branch**: Proceed with deployment
- ⚠️ **If on feature branch** (e.g., `fix/test-mock-data-paths`):
  - **For Preview Deploy**: Usually OK - just testing changes
  - **For Production Deploy**: **ASK USER FIRST**
    - "Currently on branch `[branch-name]`. This will deploy feature branch code to production. OK to proceed? (yes/no)"
    - If NO: Instruct user to switch to main: `git checkout main`
    - If YES: Proceed but document in deployment notes

**Best Practice**: Production deployments should typically come from `main` branch only.

## Prerequisites Verification (Optional - Recommended for Production)
Before deploying to production, verify:
1. **Current branch**: `git branch --show-current` (should be `main` for production)
2. **Vercel CLI installed**: `vercel --version` (should show v48.6+)
3. **Authenticated**: `vercel whoami` (should show your account)
4. **Project linked**: `.vercel/project.json` exists with correct project ID
5. **Environment variables configured**: Check required env vars are set
6. **Build passes locally**: `npm run build` completes successfully (optional for quick deploy)
7. **Tests pass**: `npm test -- --run` shows 97/97 tests passing (optional for quick deploy)

**💡 Tip**: For quick/demo deployments, you can skip steps 6-7 and deploy directly.

## Required Environment Variables
Ensure these environment variables are set in Vercel project:

### Essential (Required)
- `NUXT_SESSION_PASSWORD` - Minimum 32 characters for session encryption
  - Example: `something_long_and_random_thats_at_least_32_characters`

### GitHub Integration (Optional - for real data)
- `NUXT_GITHUB_TOKEN` - GitHub Personal Access Token with scopes:
  - `copilot`, `manage_billing:copilot`, `manage_billing:enterprise`
  - `read:enterprise`, `read:org`

### Scope Configuration (Optional)
- `NUXT_PUBLIC_SCOPE` - Default scope: 'organization', 'enterprise', 'team-organization', 'team-enterprise'
- `NUXT_PUBLIC_GITHUB_ORG` - Target organization name
- `NUXT_PUBLIC_GITHUB_ENT` - Target enterprise name
- `NUXT_PUBLIC_GITHUB_TEAM` - Target team name (optional)

### Mock Data Mode (Recommended for testing)
- `NUXT_PUBLIC_IS_DATA_MOCKED=true` - Use sample data without GitHub token

### OAuth (Optional)
- `NUXT_PUBLIC_USING_GITHUB_AUTH` - Enable GitHub OAuth (default: false)
- `NUXT_OAUTH_GITHUB_CLIENT_ID` - GitHub App client ID
- `NUXT_OAUTH_GITHUB_CLIENT_SECRET` - GitHub App client secret

## Deployment Commands

### Quick Deploy (Skip Prerequisites)
For urgent deployments or when you need to push quickly:
```bash
# 0. Check current branch first!
git branch --show-current

# Quick preview deploy (skips tests)
vercel deploy

# Quick production deploy (skips tests) - USE WITH CAUTION
# ⚠️ Only if user confirms it's OK to deploy current branch
vercel deploy --prod
```
**⚠️ Note**: Quick deploy skips verification steps. Only use for:
- Urgent hotfixes
- Configuration-only changes
- When you're confident tests will pass
- Demo/testing purposes
- **User has confirmed branch is OK to deploy**

### Standard Deployment (Recommended)
Full deployment with all verification steps:

#### Preview Deployment (Testing)
```bash
# 0. Verify branch
git branch --show-current

# 1. Run tests first
npm test -- --run

# 2. Deploy to preview URL
vercel deploy

# This creates a unique preview URL like:
# https://copilot-metrics-viewer-[hash].vercel.app
```

#### Production Deployment
```bash
# 1. Run full verification
npm test -- --run
npm run build

# 2. Deploy to production
vercel deploy --prod

# This updates your production URL:
# https://copilot-metrics-viewer-chi.vercel.app
```

### Set Environment Variables (if needed)
```bash
# Add a single environment variable
vercel env add NUXT_SESSION_PASSWORD

# Pull environment variables to local .env file
vercel env pull

# List all environment variables
vercel env ls
```

## Deployment Validation Steps

After deployment, verify the following:

### Important Note: Deployment Protection
Preview deployments have Vercel's deployment protection enabled by default, which requires authentication. For validation:
- **Option 1**: Use production URL instead: `https://copilot-metrics-viewer-chi.vercel.app`
- **Option 2**: Check deployment status with: `vercel list`
- **Option 3**: Disable protection in Vercel dashboard: Project Settings → Deployment Protection

### 1. Verify Deployment Status
```bash
# Check recent deployments
vercel list | head -10

# Look for:
# - Status: ● Ready (green)
# - Environment: Preview or Production
# - No error indicators
```

### 2. Health Endpoints (Critical - Use Production URL)
```bash
# Check health endpoint (use production URL to avoid auth)
curl https://copilot-metrics-viewer-chi.vercel.app/api/health

# Expected response:
# {
#   "status": "healthy",
#   "timestamp": "...",
#   "version": "...",
#   "uptime": ...
# }

# Check readiness
curl https://copilot-metrics-viewer-chi.vercel.app/api/ready

# Check liveness
curl https://copilot-metrics-viewer-chi.vercel.app/api/live
```

### 3. Mock Data Functionality
```bash
# Test with mock data (use production URL)
curl https://copilot-metrics-viewer-chi.vercel.app/orgs/mocked-org?mock=true

# Should return HTML page with status 200
# Look for signs of successful rendering (no 404/500 errors)
```

### 4. Application Routes (Browser Testing)
Test these URLs in browser (production URLs):
- `https://copilot-metrics-viewer-chi.vercel.app/` - Homepage
- `https://copilot-metrics-viewer-chi.vercel.app/orgs/octodemo` - Organization view
- `https://copilot-metrics-viewer-chi.vercel.app/enterprises/octo-demo-ent` - Enterprise view
- `https://copilot-metrics-viewer-chi.vercel.app/orgs/octodemo/teams/team-name` - Team view

**For Preview URLs**: You'll need to authenticate via browser first due to deployment protection.

### 5. Check Logs
```bash
# View deployment logs (use full deployment URL)
vercel logs https://copilot-metrics-viewer-pkko5ziun-dmitry-ms-projects-53319a9d.vercel.app

# Or view logs from Vercel dashboard:
# https://vercel.com/dmitry-ms-projects-53319a9d/copilot-metrics-viewer

# Look for:
# ✓ "Using mocked data" (if mock mode enabled)
# ✓ No "ENOENT" errors
# ✓ No "module not found" errors
# ✓ Server started successfully
```

## Common Issues & Solutions

### Issue: Preview URL shows "Authentication Required" page
**Solution**: This is Vercel's deployment protection (normal behavior)
- Use production URL for testing: `https://copilot-metrics-viewer-chi.vercel.app`
- Or authenticate in browser first, then test
- Or disable in Project Settings → Deployment Protection → Standard Protection → Off

### Issue: "NUXT_SESSION_PASSWORD must be at least 32 characters"
**Solution**: Set a longer password
```bash
vercel env add NUXT_SESSION_PASSWORD
# Enter a string with 32+ characters
```

### Issue: Mock data returns 404/500 errors
**Solution**: Verify server assets are bundled
- Check build logs for "server/assets/mock-data" inclusion
- Ensure `NUXT_PUBLIC_IS_DATA_MOCKED=true` is set

### Issue: Health endpoints return 404
**Solution**: 
- Verify `server/api/health.ts` is included in build
- Check Vercel function logs for errors
- Ensure running in development mode works: `npm run dev`

### Issue: Font provider warnings
**Solution**: These are non-blocking warnings in restricted networks
- Application works correctly despite these warnings
- Safe to ignore: "Could not fetch fonts from ..."

## Deployment Best Practices

### Pre-Deployment Checklist
- [ ] All tests passing: `npm test`
- [ ] Build succeeds: `npm run build`
- [ ] Linting clean: `npm run lint` (expect 43 known errors)
- [ ] Environment variables configured in Vercel
- [ ] Mock mode tested locally
- [ ] Health endpoints respond correctly locally

### Testing Strategy
1. **Preview first**: Always deploy to preview before production
2. **Validate preview**: Test all critical paths on preview URL
3. **Check logs**: Review deployment logs for errors
4. **Test mock data**: Verify mock data works on preview
5. **Production deploy**: Only after preview validation passes

### Rollback Strategy
If issues occur after production deployment:
```bash
# List recent deployments
vercel list

# Inspect a specific deployment
vercel inspect [deployment-url]

# Promote a previous deployment to production
vercel promote [previous-deployment-url]

# Or remove bad deployment and redeploy
vercel remove [bad-deployment-url] --yes
```

## Monitoring & Maintenance

### Regular Checks
- Monitor Vercel dashboard for deployment health
- Check logs periodically: `vercel logs --follow`
- Verify health endpoints remain responsive
- Monitor GitHub Copilot API rate limits (if using real data)

### Cleanup Old Deployments
```bash
# List all deployments
vercel list

# Remove old/failed deployments (keep last 2-3 for rollback)
vercel remove [deployment-url] --yes
```

## Success Criteria

Deployment is successful when:
- ✅ Health endpoint responds with `status: "healthy"`
- ✅ Mock data loads correctly (if enabled)
- ✅ All application routes accessible
- ✅ No errors in deployment logs
- ✅ Charts and visualizations render properly
- ✅ Navigation between tabs works
- ✅ No console errors in browser
- ✅ Build time under 2 minutes
- ✅ Cold start time under 5 seconds

## Project-Specific Notes

### Architecture
- **Framework**: Nuxt 3 (SSR)
- **Runtime**: Node.js 22.x
- **Build Command**: `npm run build`
- **Output**: `.output/` directory (serverless functions)

### Key Features
- Server-side rendering with Nuxt
- Mock data in `server/assets/mock-data/` (bundled)
- GitHub API integration (optional)
- Chart.js visualizations
- Vuetify UI components

### Repository Configuration
- **Private repository**: Git integration disabled
- **Deployment method**: CLI-only (manual)
- **No auto-deployments**: Push to main does NOT trigger deployment

## Additional Resources

### Documentation
- Vercel CLI: https://vercel.com/docs/cli
- Nuxt Deployment: https://nuxt.com/docs/getting-started/deployment
- Project README: See `/README.md` for full details
- Deployment Guide: See `/DEPLOYMENT.md` for comprehensive guide

### Support Commands
```bash
# Get help with Vercel CLI
vercel --help
vercel deploy --help

# Check project settings
vercel project inspect

# View team/account info
vercel teams list
vercel whoami
```

## Notes
- This project uses **manual CLI deployments only** (no Git integration)
- Repository is **private** - automatic deployments disabled
- Mock data mode recommended for testing without GitHub tokens
- Health endpoints may not work correctly in built mode in some environments - use `npm run dev` for development testing