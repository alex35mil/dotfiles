# Debug Third-Party Dependencies Before Working Around Them

Before working around or reporting an apparent dependency bug:

1. Reproduce it minimally against the project's pinned version.
2. Check the dependency's latest documentation, releases, and upstream issues.
3. Reproduce the same case against the latest compatible version.
4. Prefer upgrading when upstream already fixed it. Report only when the latest version still fails and no existing issue covers it.
