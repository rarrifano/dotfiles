---
name: gh-actions
description: GitHub Actions — writing workflows, debugging failing jobs, optimizing pipeline speed, managing secrets and environments, reusable workflows, and matrix builds. Use for any CI/CD task involving GitHub Actions.
---

# gh-actions — GitHub Actions Skill

## Guardrails

- Never hardcode secrets in workflow files — always use `${{ secrets.NAME }}`.
- Avoid `pull_request_target` with `${{ github.event.pull_request.head.sha }}` — it's a common injection vector.
- Pin third-party actions to a full commit SHA, not a tag.

## Workflow structure

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read   # least privilege by default

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Descriptive step name
        run: make build
```

## Debugging a failing job

1. Read the raw logs — look for the first `Error` or non-zero exit, not the last.
2. Check the step that failed, then the step before it (setup steps silently affect later steps).
3. Add `ACTIONS_STEP_DEBUG=true` as a repo secret to enable verbose runner logs.
4. Reproduce locally with [`act`](https://github.com/nektos/act):
   ```bash
   act push -j <job-id> --secret-file .secrets
   ```

Common failures:
| Symptom | Cause |
|---|---|
| `Process completed with exit code 1` | Check the actual command output above |
| `Resource not accessible by integration` | Missing `permissions:` block |
| `Context access might be invalid` | Typo in `${{ }}` expression |
| Job skipped silently | `if:` condition evaluated to false — add debug step to print context |
| Cache miss every run | Cache key includes a volatile value — use stable key + restore-keys fallback |

## Secrets and environments

- Repo secrets: `Settings > Secrets > Actions`
- Environment secrets (with approval gates): use `environment: production` on the job
- Reference: `${{ secrets.MY_SECRET }}`
- Never echo secrets; GitHub masks known secret values but custom patterns may leak

## Caching dependencies

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-npm-
```

For Terraform providers:
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.terraform.d/plugin-cache
    key: ${{ runner.os }}-tf-${{ hashFiles('**/.terraform.lock.hcl') }}
```

## Reusable workflows

Caller:
```yaml
jobs:
  deploy:
    uses: ./.github/workflows/deploy.yml
    with:
      environment: staging
    secrets: inherit
```

Called workflow must declare `on: workflow_call:` with `inputs:` and `secrets:`.

## Matrix builds

```yaml
strategy:
  fail-fast: false
  matrix:
    env: [dev, staging, prod]
    region: [eastus, westeurope]
```

Access values: `${{ matrix.env }}`, `${{ matrix.region }}`

Use `fail-fast: false` when you want all matrix jobs to finish even if one fails.
