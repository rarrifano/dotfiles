---
name: ci-debug
description: Diagnose failing CI pipelines and GitHub Actions workflows. Use when a CI run has failed and the user wants to know why and what the smallest correct fix is. Classifies the failure type, pinpoints the cause, and proposes a targeted fix — without touching unrelated code.
---

# ci-failure-investigator — CI Failure Investigation Skill

## Purpose

Given a failing CI run, classify the failure, identify the root cause with evidence,
and propose the smallest correct fix.

Do not propose broad refactors. One failure, one fix.

## Workflow

### 1. Collect the failure

Ask the user to provide one of:
- The full failing job log (paste or file)
- The GitHub Actions run URL
- The workflow file and the error output

If none is provided, ask for the log output before proceeding.

### 2. Classify the failure type

Scan the log for the failure signature and classify into exactly one category:

| Class | Signature |
|---|---|
| `test-failure` | Test assertions failed, test runner exited non-zero |
| `lint-failure` | Linter, formatter, or type checker reported errors |
| `build-failure` | Compiler error, missing module, import error, asset build failed |
| `dependency-failure` | `npm install`, `pip install`, `go mod`, `bundle install` failed |
| `auth-failure` | Missing secret, invalid token, permission denied on registry/API |
| `infra-failure` | Runner OOM, disk full, network timeout, flaky external service |
| `config-error` | Workflow YAML invalid, action not found, step misconfigured |
| `env-mismatch` | Works locally, fails in CI — env var, OS, or version mismatch |
| `flake` | No code change, random failure, retry likely fixes it |

State the class before investigating further.

### 3. Pinpoint the cause

Find the first line in the log where the failure originates — not the cascade, the origin.

Common patterns to grep for:

```
Error:
FAILED
fatal:
error[
Cannot find module
ImportError
ModuleNotFoundError
permission denied
401 Unauthorized
403 Forbidden
exit code 1
Process completed with exit code
```

Quote the exact failing line(s). Do not paraphrase.

### 3a. Locate source (code failures only)

If the failure class is `test-failure`, `lint-failure`, or `build-failure`,
locate the failing file and its context directly before proposing a fix.

Use `read`, `grep`, or `bash` to:
- Find the exact file path or module name extracted from the log
- Read the failing code, its dependencies, and any related config or test files

Skip this step for `auth-failure`, `infra-failure`, `config-error`, and `flake` —
those don't require source reading.

### 4. Determine the fix category

| Failure Class | Likely Fix |
|---|---|
| `test-failure` | Fix the code or update the test (check if test is wrong first) |
| `lint-failure` | Auto-format, fix lint rule violation, or update lint config |
| `build-failure` | Fix import, add missing dep, fix syntax |
| `dependency-failure` | Pin version, update lockfile, fix registry config |
| `auth-failure` | Add or rotate secret in repo/org settings; check `permissions:` in workflow |
| `infra-failure` | Retry; if persistent, increase runner resources or switch runner |
| `config-error` | Fix YAML indentation, update action ref, fix step syntax |
| `env-mismatch` | Pin runtime version, add missing env var to CI, replicate CI env locally |
| `flake` | Re-run the job; if recurring, add retry logic or isolate the flaky step |

### 5. Propose the fix

State exactly what to change and where. Show a diff or the corrected snippet.

Rules:
- Change only what is broken.
- If the fix touches a workflow file, validate YAML structure mentally before proposing.
- If the fix requires adding a secret, specify the exact secret name and where to set it (repo settings, org settings, environment).
- If the fix requires a dependency change, show the exact version to pin.
- Do not suggest "upgrade everything" or "refactor this."

### 6. Verify the fix is safe

Before presenting:
- Does the fix break anything else? Check if the changed value/file is referenced elsewhere.
- Does the fix introduce a new secret, token, or credential? If yes, flag it.
- Does the fix touch a shared workflow used by other repos? If yes, flag the blast radius.
- Is this a third-party action change? If yes, confirm it is pinned to a commit SHA.

### 7. State confidence

End with a confidence level and reason:

| Level | Meaning |
|---|---|
| `high` | Root cause is clear in the log, fix is direct |
| `medium` | Root cause is likely but log is incomplete; fix should be tested |
| `low` | Log is truncated or ambiguous; fix is a hypothesis — needs local reproduction |

---

## Output Format

```
## CI Failure Report

**Failure class:** <class>
**Job / step:** <job name and step where it failed>
**First failing line:**
\`\`\`
<exact log line>
\`\`\`

### Root Cause
<one paragraph, evidence-based>

### Fix
<file to change>
\`\`\`diff
- old line
+ new line
\`\`\`
or
> Add secret `SECRET_NAME` to repository Settings → Secrets → Actions.

### Risks
<any blast radius or side effect — or "none identified">

### Confidence
<high / medium / low> — <reason>
```

---

## GitHub Actions Specific Checks

When the failure is in a GitHub Actions workflow file, also check:

- Third-party actions pinned to a tag instead of a full SHA
  - Flag as a security/reliability risk
  - Suggest pinning to SHA: `uses: owner/action@<full-sha>`
- Missing `permissions:` block at job or workflow level
  - Default is broad — suggest least-privilege explicit permissions
- Secrets referenced with wrong casing or wrong name
  - `${{ secrets.MY_SECRET }}` is case-sensitive
- `if:` conditions that silently skip steps
  - A "passed" step that was actually skipped can hide failures
- `continue-on-error: true` masking a real failure

---

## Guardrails

- Never modify a test to make it pass. If a test is wrong, say so explicitly and ask.
- Never suggest `--force` flags to bypass checks.
- Never suggest disabling lint, security scanning, or required status checks.
- If a secret needs rotating, say so — do not suggest hardcoding values.
- If the log is truncated, say so and ask for the full output before concluding.
