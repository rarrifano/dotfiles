---
name: gh-actions
description: Analyse GitHub Actions workflow runs and jobs. Use when asked to debug CI failures, inspect slow or flaky jobs, summarise run history, or extract step-level error logs for a repository.
---

# GitHub Actions Analyser

Diagnose GitHub Actions workflows: failures, slow jobs, flaky steps, and log extraction.

## Prerequisites

Check for the GitHub CLI:
```bash
gh auth status
```

If `gh` is unavailable, fall back to the REST API with `$GITHUB_TOKEN`.

## Workflow

### 1. Detect the repo

If no repo is specified, derive it from the git remote:
```bash
git remote get-url origin | sed 's|.*github\.com[:/]\(.*\)\(\.git\)\?$|\1|'
```

### 2. List recent runs

```bash
gh run list --repo <owner/repo> --limit 20 \
  --json databaseId,displayTitle,status,conclusion,workflowName,createdAt,url
```

Filter to failures only:
```bash
gh run list --repo <owner/repo> --status failure --limit 10 \
  --json databaseId,displayTitle,workflowName,createdAt,url
```

### 3. Inspect a run

```bash
gh run view <run-id> --repo <owner/repo> --json jobs,status,conclusion,url
```

### 4. Summarise jobs and durations

```bash
gh run view <run-id> --repo <owner/repo> --json jobs | jq '
  .jobs[] | {
    name,
    conclusion,
    duration_s: (
      if .completedAt and .startedAt
      then ((.completedAt | fromdateiso8601) - (.startedAt | fromdateiso8601))
      else null end
    ),
    failed_steps: [.steps[] | select(.conclusion == "failure") | .name]
  }'
```

### 5. Fetch logs for failed jobs

```bash
gh run view <run-id> --repo <owner/repo> --log-failed
```

All logs:
```bash
gh run view <run-id> --repo <owner/repo> --log
```

### 6. Detect flaky jobs

Jobs that appear as both failure and success across recent runs for the same workflow:
```bash
gh run list --repo <owner/repo> --limit 50 \
  --json databaseId,displayTitle,conclusion,workflowName | jq '
  group_by(.displayTitle)[]
  | select(map(.conclusion) | (contains(["failure"]) and contains(["success"])))
  | .[] | {databaseId, displayTitle, conclusion}'
```

### 7. Step-level failure summary

```bash
gh run view <run-id> --repo <owner/repo> --json jobs | jq '
  [.jobs[] | select(.conclusion == "failure") | {
    job: .name,
    failed_steps: [.steps[] | select(.conclusion == "failure") | .name]
  }]'
```

## REST API Fallback (no gh CLI)

List recent runs:
```bash
curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/<owner/repo>/actions/runs?per_page=20" | \
  jq '.workflow_runs[] | {id, name, status, conclusion, created_at, html_url}'
```

Jobs for a run:
```bash
curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/<owner/repo>/actions/runs/<run-id>/jobs" | \
  jq '.jobs[] | {id, name, status, conclusion, started_at, completed_at,
    failed_steps: [.steps[] | select(.conclusion == "failure") | .name]}'
```

Job log download URL (returns redirect to signed S3 URL):
```bash
curl -fsSLI -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/<owner/repo>/actions/jobs/<job-id>/logs" | \
  grep -i location
```

## Analysis Checklist

Work through these in order when analysing CI:

1. **Status overview** — success / failure / cancelled counts across recent runs
2. **Failure breakdown** — which workflows and jobs fail, and how often
3. **Timing** — slowest jobs by duration; flag anything over 10 minutes
4. **Step-level failures** — exact failing step name and relevant log lines
5. **Flakiness** — runs that failed then passed without a code change
6. **Actionable summary** — one short paragraph per distinct problem with the most likely root cause
