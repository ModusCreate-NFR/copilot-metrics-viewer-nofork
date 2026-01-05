What: This pull request refactors the mock data loading mechanism to directly import JSON files instead of using `readFileSync` and path resolution. It also removes the no-longer-needed `getMockDataPath()` and `getSeatsMockDataPath()` functions from `app/model/Options.ts`.

Why: This change addresses the persistent `ENOENT: no such file or directory` errors encountered in Vercel serverless functions when trying to access mock data files. Directly importing JSON files ensures they are correctly bundled and accessible within the serverless function environment, providing a more robust solution for mock data handling.

How:
1.  `shared/utils/metrics-util.ts` and `server/api/seats.ts` have been updated to directly import `organization_metrics_response_sample.json`, `enterprise_metrics_response_sample.json`, `organization_seats_response_sample.json`, and `enterprise_seats_response_sample.json`.
2.  The logic in `getMetricsData()` and the default event handler in `server/api/seats.ts` now directly use these imported JSON objects based on the `scope`.
3.  The `readFileSync`, `resolve`, `dirname`, and `fileURLToPath` imports have been removed from `shared/utils/metrics-util.ts` and `server/api/seats.ts` where they are no longer needed.
4.  The `getMockDataPath()` and `getSeatsMockDataPath()` functions have been removed from `app/model/Options.ts`.