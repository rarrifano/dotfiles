---
name: security-audit
description: Audit the workspace or repository for exposed credentials, unignored API secrets, local cache bloat, oversized VM sizes, unoptimized container layers, and untagged cloud infrastructure assets. Use when the user requests a security check, a credential audit, or wants to check costs and resource optimization.
---

# security-cost-auditor — Security and Cost Audit Assistant

## Purpose

To identify security risks (such as exposed credentials, unignored key files, or leaked passwords) and financial inefficiencies (such as oversized VM types, unoptimized container images, missing cloud cost tags, and unignored local cache directories) across active codebases. This skill ensures your workspaces are leak-free, build pipelines are lean, and cloud expenditures are tightly managed.

---

## Workflow

### 1. Execute Scan
Upon trigger, run the helper audit script on the target directory (defaulting to the current working directory).
```bash
./scripts/audit.sh [path]
```

### 1b. Codebase sweep

After the audit script, sweep directly for patterns it may miss —
especially secrets in less common file types and infrastructure configs.

Sweep areas:
- Grep for `password`, `secret`, `token`, `api_key`, `private_key` across all non-test source
- Find `.env*` files not listed in `.gitignore`
- Identify large directories (>50 MB) absent from `.gitignore`

Pass these findings into the classification step below.

### 2. Parse and Classify Findings
Analyze the output of the scan, classifying findings into one of four distinct categories:
- **[CRITICAL] Critical Security Risk:** Unignored private keys, credentials files, or `.env` templates containing active values.
- **[SECRETS] Exposed Secrets:** Hardcoded passwords, API tokens, webhook addresses, or connection strings in tracked code.
- **[BLOAT] Workspace Bloat:** Heavy directories (e.g. `node_modules`, `.venv`, `.terraform`) or files (>50MB) that are not present in `.gitignore`, causing pipelines to crawl and storage to swell.
- **[INFRA] Infrastructure & Build Inefficiencies:** Unoptimized dockerfiles (non-alpine/non-slim bases, single-stage builds) or cloud designs (oversized VM types, resources missing billing tags).

### 3. Generate Actionable Report
Present findings to Arri using a clean, well-structured format (defined below). Ensure that any discovered secret strings or tokens are **fully masked** in the display (e.g., `AKIA*********`). Do not expose raw credentials back in the chat.

### 4. Provide Remediation Paths
For every finding reported, outline the exact shell commands, config tweaks, or git updates needed to resolve it. Examples:
- To ignore bloat: `echo "node_modules/" >> .gitignore`
- To purge a committed secret from history: suggest standard remediation (e.g., rotation, using secret managers, or using tools like `git-filter-repo`).

---

## Output Format

The report must be concise, technical, and formatted as follows:

```markdown
### Security & Cost-Efficiency Report

#### Critical Security Risks
* **[Severity] [Title]**: <Short description of the exposure>
  * *Location:* `path/to/file:line`
  * *Suggested Fix:* <Clear step-by-step resolution>

#### Exposed Secrets (Masked)
* **[Type]**: `<masked-token-signature>` found in `path/to/file:line`
  * *Suggested Fix:* <Rotate secret and add config to environment manager>

#### Workspace Bloat & Pipeline Costs
* **[Bloat Item]**: <Oversized file or unignored cache folder> (Size: `XX MB`)
  * *Suggested Fix:* `git rm --cached <path>` and update `.gitignore`

#### Infrastructure & Build Optimizations
* **[Optimization]**: <Container or cloud cost observation>
  * *Suggested Fix:* <Example configuration change or tag block to append>
```

If everything is completely clean, reply with a warm, playful confirmation of perfect health!

---

## Guardrails

- **NEVER print raw secrets:** Always apply regex masking (e.g., `ghp_xxxxxxxx`) to protect credentials in chat logs.
- **NEVER delete files automatically:** Remediation must be proposed to Arri and performed only with explicit consent.
- **NEVER suggest credentials rotation without warning:** Remind Arri to deactivate leaked keys immediately at the provider (e.g., AWS, GitHub, Slack) when a leak is discovered.
