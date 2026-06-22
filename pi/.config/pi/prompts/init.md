---
description: Bootstrap AGENTS.md and .pi/ context for a new repo
argument-hint: "[project-name]"
---
You are initializing a pi coding-agent context for this repository. Your goal is to deeply understand the project and produce a high-quality `AGENTS.md` file (and optionally `.pi/` scaffolding) so that future sessions have rich context from the first message.

## Step 1 — Discover the repo

Run the following to map the project:

```bash
# Top-level layout
ls -la

# Git metadata
git log --oneline -10 2>/dev/null || true
git remote -v 2>/dev/null || true
git branch -a 2>/dev/null || true

# Stack fingerprints
find . -maxdepth 3 \( \
  -name "package.json" -o -name "go.mod" -o -name "Cargo.toml" \
  -o -name "pyproject.toml" -o -name "requirements.txt" \
  -o -name "*.tf" -o -name "Chart.yaml" -o -name "kustomization.yaml" \
  -o -name "Dockerfile" -o -name "docker-compose*.yml" \
  -o -name "Makefile" -o -name "justfile" \
  -o -name ".github" \
\) -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -60
```

Read any top-level `README.md` or `README.rst` you find.

## Step 2 — Identify the stack

Based on what you discover, identify:

- **Primary language(s)** and runtimes
- **Build / package manager** (npm, pnpm, cargo, go, pip, etc.)
- **IaC** (Terraform, Pulumi, CDK, CloudFormation)
- **Container / orchestration** (Docker, K8s, Helm, Kustomize, Compose)
- **CI/CD** (GitHub Actions, GitLab CI, CircleCI, etc.)
- **Test frameworks** (jest, pytest, cargo test, etc.)
- **Key directories** and their purpose
- **Secrets / credential patterns** in use (env vars, vault, sealed secrets)

## Step 3 — Write `AGENTS.md`

Create a file at `./AGENTS.md` (project root) using this structure — fill every section with real details, skip sections that genuinely don't apply:

```markdown
# Project Context

## Overview
<!-- One paragraph: what the project does, who uses it, key constraints -->

## Stack
<!-- Bullet list: language, framework, runtime, key dependencies -->

## Repository Layout
<!-- Short annotated tree of the most important dirs/files -->

## Development Workflow
<!-- How to run, test, build locally. Exact commands. -->

## IaC & Infrastructure
<!-- Terraform layout, K8s structure, cloud provider, environments -->

## CI/CD
<!-- Workflow files, how deploys are triggered, environments -->

## Conventions & Style
<!-- Naming, branch strategy, PR/commit conventions, linting -->

## Hard Constraints
<!-- Production deploy rules, GMUD/change windows, secrets policy, etc. -->

## Key Files
<!-- Files the agent should always read before touching certain areas -->
```

${1:- }

## Step 4 — Scaffold `.pi/` (if missing)

If `.pi/` does not exist yet, create a minimal project-local scaffold:

```
.pi/
├── prompts/       # project-specific prompt templates (empty for now)
└── extensions/    # project-specific extensions (empty for now)
```

Just create the directories — don't add placeholder files unless there's a clear need.

## Step 5 — Report

After writing the files, print a short summary:
- What stack was detected
- What was written and where
- Any gaps you couldn't fill (missing README, unclear structure, etc.)
- Suggested next steps (e.g. "run /review after your first PR")

Be thorough in Steps 1–2 so that AGENTS.md is genuinely useful, not a generic template. The goal is that any future pi session in this repo immediately knows the project without needing to re-explore.
