---
name: tf-workflow
description: Terraform workflow — writing modules, planning, reviewing plan output, importing resources, handling state, and debugging provider errors. Use for any Terraform task.
---

# tf-workflow — Terraform Workflow Skill

## Guardrails

- Never run `terraform apply` or `terraform destroy` without explicit confirmation.
- Never modify `.tfstate` files directly.
- Always `fmt` and `validate` before planning.
- Remote state: never run `terraform force-unlock` without confirming no other apply is running.

## Standard workflow

```bash
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
# show plan to user, get confirmation
terraform apply tfplan
```

## Writing modules

Structure:
```
modules/<name>/
  main.tf
  variables.tf
  outputs.tf
  README.md
```

- All input variables must have `description` and `type`.
- All outputs must have `description`.
- No hardcoded environment-specific values inside modules — pass via variables.
- Use `locals` for derived values, not inline expressions repeated across resources.

## Reviewing plan output

When given a `terraform plan` output, check for:
- `forces replacement` — will destroy and recreate a resource; flag this explicitly
- Unexpected deletions — anything being destroyed that wasn't intended
- Sensitive value changes — note them even if values are redacted
- Count/for_each drift — resources being added or removed due to input changes
- Provider version constraints that may conflict

Format findings as:
```
RISK    <resource> — reason
WARN    <resource> — reason
OK      <resource> — looks correct
```

## Importing existing resources

```bash
terraform import <resource_type>.<name> <cloud_resource_id>
```

After import, always run `terraform plan` to confirm state matches config. If there's drift, reconcile the config before applying.

## Debugging common errors

| Error | First step |
|---|---|
| `Error acquiring the state lock` | Check for a stuck apply; use `terraform force-unlock <id>` only after confirming |
| `Provider produced inconsistent result` | Check for computed fields in plan vs apply; often a provider bug — pin version |
| `Error: cycle` | Use `depends_on` or restructure module dependencies |
| `InvalidClientTokenId` / auth errors | Check credentials and assumed role; run `aws sts get-caller-identity` |
| `Resource already exists` | Use `terraform import` to bring it under management |

## State operations (handle with care)

```bash
terraform state list
terraform state show <resource>
terraform state mv <old> <new>   # rename without destroy/recreate
terraform state rm <resource>    # remove from state without destroying
```

Always take a state backup before any `state mv` or `state rm`:
```bash
terraform state pull > backup-$(date +%Y%m%d%H%M%S).tfstate
```
