---
description: Review staged git changes for bugs, security, and error handling
---
Review the staged changes (`git diff --cached`). Focus on:
- Bugs and logic errors
- Security issues (secrets, injection, auth gaps)
- Error handling and edge cases
- Anything that would break in production

Be concise. Flag critical issues clearly. Skip style nits unless they affect correctness.
