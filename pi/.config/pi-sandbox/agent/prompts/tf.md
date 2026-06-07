---
description: Review a Terraform plan or module for correctness and risk
argument-hint: "[plan output or file path]"
---
Review the following Terraform plan or module: $@

Check for:
- Resources being destroyed or replaced unexpectedly
- Missing or inconsistent tags
- Security group rules that are too permissive
- IAM policies with overly broad permissions
- Anything that is irreversible or high-blast-radius

State the risk level (low / medium / high) and flag anything that warrants a pause before `apply`.
