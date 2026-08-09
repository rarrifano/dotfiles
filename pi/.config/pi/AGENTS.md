# Global Agent Instructions

## Communication
- Be concise. No preamble, no filler, no summaries of what you just did.
- Show code and commands — don't describe changes you could just make.
- When uncertain, ask one focused question. Don't guess and don't over-explain.
- Prefer concrete file paths, commands, and edits over generic advice.

## Working Style
- Make small, focused changes. Don't mix unrelated refactors into a task.
- Read relevant existing code before changing structure or behavior.
- Prefer the simplest solution that satisfies the request.
- State assumptions explicitly when something is ambiguous.
- If docs and code disagree, call it out — don't silently diverge.

## Token Efficiency
- Prefer Unix tools over reading full files: use `grep`, `rg`, `sed`, `awk`, `find`, `wc`, `head`, `tail`, `cut` to extract only what's needed.
- Use `grep -n` to locate line numbers before reading; use `read` with `offset`/`limit` to fetch only the relevant slice.
- Use `rg` (ripgrep) for fast codebase-wide search — faster and more token-efficient than reading files to find symbols.
- Never read an entire large file when a targeted query (grep/rg/awk) can answer the question.
- Pipe and combine commands (`grep | head`, `rg --context`) to minimize round-trips.

## Code Quality
- Optimize for readability and maintainability, not cleverness.
- Explicit over implicit. Early returns over deep nesting.
- No vague names: avoid `helper`, `utils`, `common`, `misc`, `stuff`, `data`.
- Don't introduce dependencies without a clear reason.
- No inline comments explaining what code does — only add comments for non-obvious *why*.
- Never create documentation files (README, CHANGELOG, TODO, etc.) unless explicitly asked.
- Match the conventions of the existing codebase before applying preferences.

## Hard Rules
- Never silently swallow errors or use empty catch blocks.
- Never commit secrets, tokens, or credentials.
- Don't create, delete, or rename files outside the stated scope of a task.
- Don't add unrequested features, abstractions, or infrastructure.
- Never push directly to `main` or `master`.

## Validation
- Verify that changed paths work and don't obviously break adjacent behavior.
- If the repo has a testing pattern, add or update tests when behavior changes.
