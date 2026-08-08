---
name: terraform-plan
description: Analyse Terraform plan output for safety risks, destructive changes, financial impact, and configuration hygiene. Use when asked to review, audit, or explain a terraform plan or terraform show result — including plan output extracted from CI logs, GitHub Actions runs, or any other pipeline that executes terraform plan.
---

# Terraform Plan Analyser

Review `terraform plan` output for safety, cost, and hygiene signals. Work through every section below in order and produce a structured report.

## Input Formats

Accept any of:

1. **Raw plan text** — pasted output of `terraform plan` or `terraform show <planfile>`
2. **JSON plan** — output of `terraform show -json <planfile>`
3. **Plan file on disk** — run the commands below to extract it

```bash
# Save a plan file
terraform plan -out=tfplan

# Convert to JSON for structured analysis
terraform show -json tfplan > tfplan.json

# Or show human-readable
terraform show tfplan
```

When a plan file path is provided, prefer JSON for precision:
```bash
terraform show -json <planfile> | jq '.'
```

---

## 1. Change Summary

Extract the headline counts first:

```bash
# From JSON
jq '{
  add:     [.resource_changes[] | select(.change.actions | contains(["create"]))    ] | length,
  change:  [.resource_changes[] | select(.change.actions | contains(["update"]))    ] | length,
  destroy: [.resource_changes[] | select(.change.actions | contains(["delete"]))    ] | length,
  replace: [.resource_changes[] | select(.change.actions == ["delete","create"]
                                      or .change.actions == ["create","delete"])    ] | length,
  noop:    [.resource_changes[] | select(.change.actions == ["no-op"])              ] | length
}' tfplan.json
```

From raw text the summary line looks like:
```
Plan: X to add, Y to change, Z to destroy.
```

State the totals before anything else.

---

## 2. Destructive Change Audit

### 2a. Direct destroys
```bash
jq '[.resource_changes[]
  | select(.change.actions | contains(["delete"]))
  | {address, actions: .change.actions}]' tfplan.json
```

### 2b. Forced replacements (delete + create)
```bash
jq '[.resource_changes[]
  | select(.change.actions == ["delete","create"] or .change.actions == ["create","delete"])
  | {address, actions: .change.actions, replacing: .change.before}]' tfplan.json
```

**Risk flags — treat every matched resource as CRITICAL unless explicitly confirmed safe:**

| Pattern | Risk |
|---|---|
| `aws_db_instance`, `aws_rds_cluster` destroy/replace | 🔴 Data loss |
| `aws_s3_bucket` destroy | 🔴 Data loss if not empty |
| `aws_iam_role`, `aws_iam_policy` destroy/replace | 🔴 Auth breakage |
| `aws_vpc`, `aws_subnet` destroy/replace | 🔴 Network outage |
| `aws_elasticache_*` destroy/replace | 🔴 Cache data loss |
| `aws_elasticsearch_domain` / `aws_opensearch_domain` destroy | 🔴 Index loss |
| `aws_ecs_service`, `aws_eks_*` replace | 🟠 Service disruption |
| `aws_lb`, `aws_alb` destroy/replace | 🟠 Traffic loss |
| `kubernetes_deployment` replace | 🟠 Pod restart / downtime |
| Any stateful resource replace | 🟡 Investigate before applying |

---

## 3. Safety Signals

### 3a. Encryption
Flag resources missing encryption-at-rest:
```bash
# RDS without storage_encrypted
jq '[.resource_changes[]
  | select(.type | test("aws_db_instance|aws_rds_cluster"))
  | select(.change.after.storage_encrypted != true)
  | .address]' tfplan.json

# S3 without server-side encryption rule
jq '[.resource_changes[]
  | select(.type == "aws_s3_bucket_server_side_encryption_configuration")
  | select(.change.actions | contains(["delete"]))
  | .address]' tfplan.json

# EBS volumes without encryption
jq '[.resource_changes[]
  | select(.type == "aws_ebs_volume" or .type == "aws_instance")
  | select((.change.after.encrypted // .change.after.root_block_device[0].encrypted) != true)
  | .address]' tfplan.json
```

### 3b. Public exposure
```bash
# Security groups opening 0.0.0.0/0
jq '[.resource_changes[]
  | select(.type == "aws_security_group" or .type == "aws_security_group_rule")
  | select(
      (.change.after.ingress // [])[]
      | (.cidr_blocks // []) | contains(["0.0.0.0/0"])
    )
  | .address]' tfplan.json

# RDS publicly accessible
jq '[.resource_changes[]
  | select(.type | test("aws_db_instance|aws_rds_cluster"))
  | select(.change.after.publicly_accessible == true)
  | .address]' tfplan.json

# S3 bucket with public ACL or public access block disabled
jq '[.resource_changes[]
  | select(.type == "aws_s3_bucket_public_access_block")
  | select(
      .change.after.block_public_acls != true or
      .change.after.block_public_policy != true or
      .change.after.ignore_public_acls != true or
      .change.after.restrict_public_buckets != true
    )
  | .address]' tfplan.json
```

### 3c. Deletion protection
```bash
# RDS without deletion protection
jq '[.resource_changes[]
  | select(.type | test("aws_db_instance|aws_rds_cluster"))
  | select(.change.after.deletion_protection != true)
  | .address]' tfplan.json

# ALB without deletion protection
jq '[.resource_changes[]
  | select(.type | test("aws_lb|aws_alb"))
  | select(.change.after.enable_deletion_protection != true)
  | .address]' tfplan.json
```

### 3d. Backup and retention
```bash
# RDS with backup_retention_period = 0 (backups disabled)
jq '[.resource_changes[]
  | select(.type | test("aws_db_instance|aws_rds_cluster"))
  | select((.change.after.backup_retention_period // 0) == 0)
  | .address]' tfplan.json
```

### 3e. IAM over-permissions
Flag wildcard IAM statements being created or modified:
```bash
jq '[.resource_changes[]
  | select(.type | test("aws_iam_policy|aws_iam_role_policy"))
  | select(.change.after.policy != null)
  | select(
      (.change.after.policy | fromjson | .Statement[]
        | (.Effect == "Allow") and (.Action | contains(["*"])) and (.Resource | contains(["*"]))
      )
    )
  | .address]' tfplan.json
```

---

## 4. Financial Impact

### 4a. Identify cost-bearing resource types

Always flag when these are **added or resized**:

| Resource type | Cost driver |
|---|---|
| `aws_instance` | Instance type + EBS |
| `aws_db_instance` | Instance class + storage + Multi-AZ |
| `aws_rds_cluster_instance` | Instance class × replica count |
| `aws_nat_gateway` | Per-hour + data transfer |
| `aws_lb` / `aws_alb` / `aws_nlb` | Per-hour + LCU |
| `aws_elasticsearch_domain` / `aws_opensearch_domain` | Instance type × count |
| `aws_elasticache_cluster` | Node type × count |
| `aws_eks_cluster` | Cluster fee + node groups |
| `aws_ecs_service` (Fargate) | vCPU + memory |
| `aws_cloudfront_distribution` | Data transfer + requests |
| `aws_wafv2_web_acl` | Per-rule + requests |
| `aws_transfer_server` | Per-hour + data |
| `aws_sagemaker_*` | Instance type + storage |

```bash
# List all new cost-bearing resources
COST_TYPES='aws_instance|aws_db_instance|aws_rds_cluster_instance|aws_nat_gateway|aws_lb|aws_alb|aws_nlb|aws_elasticsearch_domain|aws_opensearch_domain|aws_elasticache_cluster|aws_eks_cluster|aws_ecs_service'

jq --arg types "$COST_TYPES" '[.resource_changes[]
  | select(.type | test($types))
  | select(.change.actions | contains(["create"]))
  | {address, type, instance_type: (.change.after.instance_type // .change.after.instance_class // .change.after.node_type // "n/a")}
]' tfplan.json
```

### 4b. Resizing existing instances
```bash
jq '[.resource_changes[]
  | select(.change.actions | contains(["update"]))
  | select(.change.before.instance_type != .change.after.instance_type
        or .change.before.instance_class != .change.after.instance_class
        or .change.before.node_type != .change.after.node_type)
  | {
      address,
      before: (.change.before.instance_type // .change.before.instance_class // .change.before.node_type),
      after:  (.change.after.instance_type  // .change.after.instance_class  // .change.after.node_type)
    }]' tfplan.json
```

### 4c. NAT Gateway changes
NAT Gateways are often the most surprising cost line. Flag any adds:
```bash
jq '[.resource_changes[]
  | select(.type == "aws_nat_gateway")
  | select(.change.actions | contains(["create"]))
  | .address]' tfplan.json
```

### 4d. Multi-AZ and replica counts
```bash
jq '[.resource_changes[]
  | select(.type | test("aws_db_instance|aws_rds_cluster"))
  | select(.change.actions | contains(["create","update"]))
  | {address, multi_az: .change.after.multi_az, replicas: .change.after.replica_count}]' tfplan.json
```

---

## 5. Configuration Hygiene

### 5a. Tagging
```bash
# Resources missing required tags (adjust tag keys to match org standard)
REQUIRED_TAGS=("Environment" "Owner" "CostCenter")

jq --argjson required '["Environment","Owner","CostCenter"]' '[
  .resource_changes[]
  | select(.change.actions | contains(["create","update"]))
  | select(.change.after.tags != null)
  | select(
      ($required - (.change.after.tags | keys)) | length > 0
    )
  | {
      address,
      missing: ($required - (.change.after.tags | keys))
    }
]' tfplan.json
```

### 5b. Deprecated or legacy resources
Flag these when they appear:
- `aws_db_security_group` — EC2-Classic only, deprecated
- `aws_vpc_peering_connection` without `auto_accept` policy review
- `aws_instance` without `metadata_options.http_tokens = "required"` (IMDSv2)

```bash
# IMDSv2 not enforced
jq '[.resource_changes[]
  | select(.type == "aws_instance")
  | select((.change.after.metadata_options[0].http_tokens // "optional") != "required")
  | .address]' tfplan.json
```

### 5c. Logging and monitoring
```bash
# S3 buckets without access logging
jq '[.resource_changes[]
  | select(.type == "aws_s3_bucket")
  | select(.change.actions | contains(["create"]))
  | .address]' tfplan.json
# Then cross-check against aws_s3_bucket_logging resources in the same plan

# CloudTrail disabled
jq '[.resource_changes[]
  | select(.type == "aws_cloudtrail")
  | select(.change.after.enable_logging == false)
  | .address]' tfplan.json

# RDS without enhanced monitoring
jq '[.resource_changes[]
  | select(.type == "aws_db_instance")
  | select((.change.after.monitoring_interval // 0) == 0)
  | .address]' tfplan.json
```

---

## 6. Output Report Structure

Always produce a report with these exact sections:

```
## Summary
X to add · Y to change · Z to destroy · W to replace

## 🔴 Critical — requires human sign-off before apply
- List every destroy/replace on stateful resources
- List every critical safety finding

## 🟠 High — investigate before apply
- Replacements on load balancers, compute, services
- IAM wildcard policies
- Public exposure findings

## 🟡 Medium — fix soon
- Encryption gaps
- Missing deletion protection / backup retention
- IMDSv2 not enforced
- Missing required tags

## 🟢 Low / Informational
- New cost-bearing resources (with instance type and estimated tier)
- Instance resizes (before → after)
- New NAT Gateways (flag cost)
- Hygiene findings (logging, monitoring gaps)

## ✅ Safe to apply
Summarise what the plan does that is clearly low-risk (adds, config tweaks, tag updates, etc.)

## Recommended actions
Numbered list of concrete steps the operator should take before running `terraform apply`.
```

---

## Analysis Checklist

Work through every section in order even when the plan looks small:

1. **Headline counts** — total add / change / destroy / replace
2. **Destructive changes** — destroy or replace on any resource; double-check stateful ones
3. **Safety** — encryption, public exposure, deletion protection, backups, IAM wildcards
4. **Financial** — new cost-bearing resources, resizes, NAT gateways, Multi-AZ changes
5. **Hygiene** — tagging, IMDSv2, logging, monitoring, deprecated types
6. **Verdict** — assign each finding a risk level and produce the structured report above
