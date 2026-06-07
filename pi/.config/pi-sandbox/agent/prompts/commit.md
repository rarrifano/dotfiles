---
description: Stage, review, and commit changes with a properly formatted commit message
argument-hint: "[instructions or context]"
---
Create a well-formed git commit for the current changes.

Steps:
1. Run `git diff --cached` (and `git diff` if nothing is staged) to understand what changed.
2. Determine the correct commit type and scope from the changes:
   - Types: `feat` `fix` `refactor` `docs` `chore` `perf` `ci` `build` `test`
   - Scope: the affected module, service, or subsystem (omit if truly global)
3. Write a subject line in imperative mood, lowercase, no trailing period, max 72 chars.
4. If the change is non-trivial, add a short body (one blank line after subject) explaining *why*, not *what*.
5. Never include secrets, tokens, personal names, internal URLs, or sensitive context in the message.
6. Present the final commit message for approval before running `git commit`.

Additional context from user: $@
