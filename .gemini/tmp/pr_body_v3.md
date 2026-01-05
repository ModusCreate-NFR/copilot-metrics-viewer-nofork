What: This pull request moves the mock data directory from `public/mock-data` to `server/mock-data` and updates the paths in `app/model/Options.ts` accordingly.

Why: This change addresses the `ENOENT: no such file or directory` error encountered in Vercel deployments when trying to access mock data files. By moving the mock data to the `server/` directory, these files are correctly bundled with the serverless functions, ensuring they are accessible at runtime.

How:
1.  The `mock-data` directory has been moved from `public/` to `server/`.
2.  The `getMockDataPath()` and `getSeatsMockDataPath()` functions in `app/model/Options.ts` have been updated to reflect the new `server/mock-data` location.