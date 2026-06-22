---
description: Review staged git changes for bugs, logic errors, and security issues
---
Review the staged changes (`git diff --cached`).

Check for:
- Bugs and logic errors
- Security vulnerabilities (injection, auth bypass, secrets in code)
- Unhandled errors or edge cases
- Unnecessary complexity or dead code
- Missing or broken tests

Be concise. List issues as bullet points with file:line references. Skip praise.
