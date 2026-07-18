# Global Agent Instructions

## Language

- Always respond to the user in **English**, regardless of the language used in documents, runbooks, or any generated artifacts.
- Documents and deliverables may be written in pt-BR (or any other requested language) — but all agent responses and explanations must be in English.

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
- Comments: plain and simple only — no decorative lines, banners, or separators (no `---`, `===`, `***`, or similar). One short line that describes what follows.

## Shell & Commands

- Prefer non-destructive commands; add `--dry-run` or `-n` where available.
- Chain related read-only commands (`ls`, `grep`, `find`) into one bash call.
- Never run anything that modifies production data without explicit confirmation.

## Error Handling

- If a command fails, diagnose before retrying.
- Show the actual error output, not just "it failed".

## Environment

- Running inside a **Docker container** with **Debian 12 (bookworm)**
- Extra packages available: `git`, `gh`, `curl`, `jq`, `unzip`, `openssl`, `vim`, `taskwarrior`, `wl-clipboard`, `xclip`
- Runtimes available: `node` v24, `npm` v11, `terraform`, `kubectl`, `helm`
- No Python runtime installed by default — install via `apt` or `pipx` if needed
- Use `apt-get` for system packages; prefer tools already present before installing new ones

## Neovim

- Version: **v0.12**
- Always prefer native Neovim APIs and built-ins over plugins (e.g. `vim.lsp.*`, `vim.diagnostic.*`, `vim.treesitter.*`, native completion via `vim.lsp.completion.enable`)
- Only suggest a plugin when there is no native equivalent or the native API is clearly insufficient
- Keep config lean — no nvim-cmp, no mason auto-install, no deprecated `require('lspconfig')` patterns unless already present

## Stack

- IaC: Terraform (modules, remote state, workspaces)
- Orchestration: Kubernetes (kubectl, Helm, Kustomize)
- CI/CD: GitHub Actions
- Shell: Bash -- CLI-first, no GUI tooling

## Hard Constraints

- Never run terraform apply, kubectl delete, or any destructive cloud command without explicit confirmation
- Secrets never in code -- always via vault/sealed secrets/env injection

## Conventions

- Terraform: modules in modules/, environments in environments/<env>/
- Always run terraform fmt and terraform validate before plan
- K8s: Kustomize base + overlays pattern preferred over raw manifests
- CI: jobs should be idempotent and re-runnable without side effects
