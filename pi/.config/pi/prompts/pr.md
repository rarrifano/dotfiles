---
description: Write a pull request description from the current branch diff
---
Run `git log origin/main...HEAD --oneline` and `git diff origin/main...HEAD` and write a PR description.

Format:
## What
<what changed, 2-3 sentences>

## Why
<motivation or ticket context — infer from commit messages if not provided>

## How to test
<exact steps a reviewer can follow>

Keep it factual and terse. No filler.
