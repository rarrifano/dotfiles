---
description: Review a terraform plan output for risks before applying
---
Review the terraform plan output below (from the GitHub Actions pipeline).

Check for:
- Any `forces replacement` — will destroy and recreate; flag explicitly
- Unexpected deletions — anything being destroyed that wasn't requested
- Sensitive value changes
- Resource count drift (unexpected additions/removals)
- Data source reads that may behave differently in apply vs plan

Format output as:
RISK    <resource.name> — <reason>
WARN    <resource.name> — <reason>
OK      <resource.name> — looks correct

End with a one-line verdict: SAFE TO APPLY / REVIEW REQUIRED / DO NOT APPLY
