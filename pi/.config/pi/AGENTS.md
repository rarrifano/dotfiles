# Global Agent Instructions

## General Behaviour
- Be concise. Prefer code and diffs over long explanations.
- Never truncate files when writing — always write the full content.
- Prefer editing existing files over rewriting them from scratch.
- When unsure about scope, ask one focused question before proceeding.
- After completing a task, briefly summarise what changed and why.

## Code Style
- Match the conventions already present in the file being edited.
- Leave no debugging artefacts (console.log, print, TODO) unless explicitly asked.
- Keep functions small and single-purpose.

## Shell & Commands
- Prefer non-destructive commands; add `--dry-run` or `-n` where available.
- Chain related read-only commands (`ls`, `grep`, `find`) into one bash call.
- Never run anything that modifies production data without explicit confirmation.

## Error Handling
- If a command fails, diagnose before retrying.
- Show the actual error output, not just "it failed".
