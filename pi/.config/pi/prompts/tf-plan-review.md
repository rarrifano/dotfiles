---
description: Fetch the latest PR Terraform plan from GitHub Actions and review it for risks
---

Fetch the Terraform plan output from the last PR's GitHub Actions run and review it.

## Step 1 — Discover the latest PR run

Run the following commands using the `bash` tool:

```bash
# Get the most recent PR-triggered deploy run ID
gh run list \
  --workflow="deploy_aws.yml" \
  --event=pull_request \
  --limit=1 \
  --json databaseId,headBranch,status,conclusion
```

Then get the plan job IDs from that run:

```bash
gh run view <run_id> --json jobs \
  | node -e "const j=require('fs').readFileSync('/dev/stdin','utf8'); \
             const jobs=JSON.parse(j).jobs; \
             jobs.forEach(j=>console.log(j.databaseId, j.name))"
```

Identify the jobs whose name contains "Plan" (both npe and prd if present).

## Step 2 — Fetch the plan log

For each plan job ID, strip ANSI codes and extract only the relevant plan diff:

```bash
gh run view --log --job <job_id> 2>/dev/null \
  | sed 's/\x1b\[[0-9;]*m//g' \
  | awk '/Terraform will perform the following actions/,/Plan: [0-9]/' \
  | sed 's/^.*UNKNOWN STEP\s*//'
```

If the run hasn't produced a "Terraform will perform" block (e.g. no changes), look for `No changes. Your infrastructure matches the configuration.`

## Step 3 — Review the plan

With the extracted plan text, check for:

- Any `forces replacement` — will destroy and recreate; flag explicitly
- Unexpected deletions — anything being destroyed that wasn't requested
- Sensitive value changes (`(sensitive value)` appearing where it wasn't before)
- Resource count drift (unexpected additions/removals vs the PR description)
- Data source reads that may behave differently in apply vs plan

Format the output as:

```
RISK    <resource.address> — <reason>
WARN    <resource.address> — <reason>
OK      <resource.address> — looks correct
```

Include a section header for each environment reviewed (npe / prd).

End with a one-line verdict per environment:
**npe:** SAFE TO APPLY / REVIEW REQUIRED / DO NOT APPLY
**prd:** SAFE TO APPLY / REVIEW REQUIRED / DO NOT APPLY
