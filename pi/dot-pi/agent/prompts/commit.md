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
- For a complex diff, always include a structured body. Consider a diff
  complex when it spans multiple concerns, components, or behavior changes.
  Use concise bullets grouped by concern; state what changed and why, and
  hard-wrap each line at 72 characters.
- For a simple diff, include a body only when it adds useful context.
- Include `BREAKING CHANGE: <description>`, `Fixes #<issue>`, or
  `Closes #<issue>` footers when applicable.

Output only the raw commit message text, without Markdown fences or commentary.
