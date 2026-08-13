---
description: Generate a Conventional Commit message from staged changes
---
Run `git diff --cached` and write a commit message for the staged changes.

Follow Conventional Commits:

- Format: `<type>[optional scope]: <subject>`
- Use the most specific type: `feat`, `fix`, `refactor`, `perf`, `test`,
  `docs`, `style`, `build`, `ci`, or `chore`.
- Write an imperative subject, lowercase after the colon, at most 50
  characters, with no trailing period.
- Use a lowercase scope when useful.
- Include a body only when warranted; explain what and why, hard-wrapped at
  72 characters.
- Include `BREAKING CHANGE: <description>`, `Fixes #<issue>`, or
  `Closes #<issue>` footers when applicable.

Output only the raw commit message text, without Markdown fences or commentary.
