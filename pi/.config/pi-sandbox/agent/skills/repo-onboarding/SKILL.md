---
name: repo-onboarding
description: "Rapidly map an unfamiliar codebase to produce a mental model: entrypoints, environment variables, deploy path, test commands, dangerous areas, and open questions. Use when the user opens a new repository and wants to understand how it works, where things are, and how to run it."
---

# repo-onboarding — Repository Onboarding Skill

## Purpose

Read a new repository and produce a concise, useful map of it. The output should let
someone get productive in minutes, not hours.

Do not summarize every file. Find the signal, skip the noise.

## Workflow

### 1. Locate the root

Confirm the repository root. If not obvious, ask.

```bash
ls -la
git rev-parse --show-toplevel
```

### 2. Read high-signal files first

In this order:

1. `README.md` — project purpose, quickstart, architecture notes
2. `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` / `Gemfile` — language, dependencies, scripts
3. `Makefile` or `Taskfile.yml` — common commands
4. `.env.example` / `.env.sample` / `config/` — environment variables
5. `docker-compose.yml` / `Dockerfile` — how it runs
6. CI config: `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile` — how it builds and deploys
7. `CONTRIBUTING.md` — dev workflow rules

Read only what exists. Skip missing files without comment.

### 3. Map the entrypoints

Find where execution begins:

```bash
# Common entrypoint patterns
grep -r "if __name__" --include="*.py" -l .
grep -r "func main()" --include="*.go" -l .
find . -name "main.*" -not -path "*/node_modules/*" -not -path "*/.git/*"
find . -name "index.*" -maxdepth 3 -not -path "*/node_modules/*"
find . -name "app.*" -maxdepth 3 -not -path "*/node_modules/*"
cat package.json 2>/dev/null | grep -A5 '"scripts"'
```

List what you find. Do not explain every file.

### 4. Identify environment variables

```bash
# Env var references in code
grep -rE "(process\.env\.|os\.environ|os\.getenv|ENV\[|getenv)" \
  --include="*.py" --include="*.js" --include="*.ts" --include="*.go" --include="*.rb" \
  -h . | grep -oE '[A-Z_]{3,}' | sort -u

# Env example files
find . -name ".env*" -not -path "*/.git/*" | head -10
```

List: variable name, what it controls (if inferable), whether it looks required.

### 5. Find the deploy path

Check in order:
- CI/CD config for deploy jobs
- `Makefile` for `deploy` / `release` / `push` targets
- `Dockerfile` for multi-stage build hints
- `helm/` or `k8s/` or `infra/` directories
- `terraform/` or `.tf` files

Summarize: how does code get from commit to running system?

### 6. Find the test commands

```bash
grep -E "(test|spec|check)" Makefile 2>/dev/null
cat package.json 2>/dev/null | grep -A10 '"scripts"'
find . -name "pytest.ini" -o -name "jest.config*" -o -name "vitest.config*" \
  -o -name ".rspec" 2>/dev/null | head -5
```

Produce the exact command(s) to run tests locally.

### 7. Flag risky areas

Look for:
- Hardcoded credentials or tokens (grep for `password`, `secret`, `token`, `key` in non-test code)
- TODOs marked FIXME or HACK
- Migrations directory (schema change risk)
- Cron jobs or scheduled tasks
- External API integrations
- Large monolith vs microservice boundaries

```bash
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.py" --include="*.go" \
  --include="*.ts" --include="*.js" . | grep -v "node_modules" | head -20
grep -rn "password\|secret\|token\|apikey\|api_key" \
  --include="*.py" --include="*.go" --include="*.ts" --include="*.js" \
  . | grep -v "node_modules" | grep -v "test\|spec\|mock" | head -20
```

List risks as short bullets. Do not alarm about boilerplate.

### 8. Identify open questions

List 2-5 things that are not clear from the repo itself and would require asking
a maintainer. Examples:
- "What does the `FEATURE_X_ENABLED` flag do in production?"
- "Is the `legacy/` directory still in use?"
- "Are there secrets stored outside `.env.example`?"

---

## Output Format

```
## Repo Map: <repo name>

**Language / Stack:** <primary language, framework>
**Purpose:** <one sentence from README or inferred>

### Run It
<exact commands to install deps and start the service>

### Test It
<exact commands to run the test suite>

### Environment Variables
| Variable | Required | Purpose |
|---|---|---|
| VAR_NAME | yes/no | short description |

### Deploy Path
<summary: commit → CI → deploy mechanism → target environment>

### Entrypoints
- `path/to/main.go` — <what it does>
- `src/index.ts` — <what it does>

### Risky Areas
- <file or area> — <risk>

### Open Questions
1. ...
2. ...
```

---

## Guardrails

- Do not read or summarize every file — find the signal.
- Do not print raw file contents; synthesize.
- If you find hardcoded secrets, flag them clearly but do not print the secret value.
- Do not suggest changes during onboarding — this is read-only discovery.
