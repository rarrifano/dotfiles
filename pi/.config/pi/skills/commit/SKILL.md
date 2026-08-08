---
name: commit
description: Generate a conventional commit message from staged changes. Use when asked to write, draft, or suggest a commit message, or when asked to commit staged changes.
---

Run `git diff --cached` and write a commit message for the staged changes.

Follow these rules:

**Format**
```
<type>[optional scope]: <subject>

[optional body]

[optional footer(s)]
```

**Types** (choose the most specific):
- `feat` — new feature
- `fix` — bug fix
- `refactor` — code restructure with no behaviour change
- `perf` — performance improvement
- `test` — adding or updating tests
- `docs` — documentation only
- `style` — formatting, whitespace (no logic change)
- `build` — build system, dependencies
- `ci` — CI/CD configuration
- `chore` — anything else that doesn't affect production code

**Subject line**
- Imperative mood ("Add x", not "Added x" or "Adds x")
- Lowercase after the colon
- 50 chars max, no trailing period
- Scope is lowercase, e.g. `feat(auth): add OAuth2 flow`

**Body** (include when the diff warrants it)
- Explain *what* and *why*, not *how*
- Hard-wrap at 72 characters
- Separate from subject with a blank line

**Footers**
- `BREAKING CHANGE: <description>` if the change breaks an existing API
- `Fixes #<issue>` or `Closes #<issue>` if applicable

Output only the raw commit message text — no markdown fences, no commentary.
