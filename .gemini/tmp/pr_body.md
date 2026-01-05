What: This pull request corrects the path resolution for mock data in the seats API.

Why: Previously, the application was encountering a 500 Internal Server Error when attempting to load mock data for the seats API in deployed environments. This was due to the `resolve(mockedDataPath)` function not correctly locating the mock data file when `public/mock-data/` was used as a relative path.

How: The fix involves modifying `server/api/seats.ts` to use `resolve(process.cwd(), mockedDataPath)`. This ensures that the mock data file is always resolved using an absolute path relative to the project's root directory, preventing file not found errors in serverless environments like Vercel.