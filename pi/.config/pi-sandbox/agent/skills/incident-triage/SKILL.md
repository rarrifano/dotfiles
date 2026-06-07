---
name: incident-triage
description: "Structured incident triage for production issues. Use when something is broken, degraded, or behaving unexpectedly in a live system. Guides diagnosis from vague report to actionable next steps: symptoms, blast radius, recent changes, log commands, likely root causes, and escalation decision."
---

# incident-triage — Production Incident Triage Skill

## Purpose

Turn a vague "something is broken" report into a structured triage checklist with
concrete commands, a blast radius assessment, and a ranked list of likely root causes.

Do not guess at the fix before completing the checklist. Diagnosis first, remediation second.

## Workflow

Follow every step in order. Do not skip steps.

### 1. Capture the incident report

Extract from the user's message:
- What is broken (service, endpoint, job, feature)
- When it started (approximate time or "unknown")
- Who is affected (all users, subset, one region, internal only)
- Severity signal (complete outage, degraded, elevated errors, slow)
- Any error messages or codes already visible

If any of the four key fields (what, when, who, severity) are missing, ask for them
in one focused question before proceeding.

### 2. Establish blast radius

Estimate impact scope:
- Is this a single service or does it have downstream dependencies?
- Is there data loss risk?
- Is there a customer-facing impact?
- Is there an SLA or SLO breach in progress?

State blast radius as one of: `contained` / `partial` / `wide` / `critical`.

### 3. Check recent changes

Ask or infer:
- Any deploys in the last 2 hours?
- Any config changes, feature flag flips, or infrastructure changes?
- Any upstream dependency changes (third-party APIs, DNS, certs)?

If the user has access to a deployment log or git history, run these commands directly:

```bash
git log --oneline --since="2 hours ago"
```

Or for a Kubernetes environment:

```bash
kubectl rollout history deployment/<name> -n <namespace>
```

### 4. Collect evidence

Run the commands below directly. For high-volume log output, pipe through `grep` or `tail` to keep context clean. Provide the exact commands based on what the user has access to.

**Logs:**

```bash
# Kubernetes
kubectl logs -n <namespace> <pod> --tail=200 --previous
kubectl logs -n <namespace> -l app=<label> --tail=100

# Systemd
journalctl -u <service> -n 200 --no-pager --since "30 min ago"

# Docker
docker logs <container> --tail=200 2>&1

# Grep for errors
journalctl -u <service> | grep -E "ERROR|FATAL|panic|exception" | tail -50
```

**Metrics / health:**

```bash
# Kubernetes pod state
kubectl get pods -n <namespace> -o wide
kubectl describe pod <pod> -n <namespace>

# Recent events
kubectl get events -n <namespace> --sort-by='.lastTimestamp' | tail -30
```

**Connectivity:**

```bash
curl -v --max-time 5 https://<endpoint>/health
```

Ask the user to paste relevant output before forming a hypothesis.

### 5. Rank root causes

After reviewing evidence, produce a ranked list (most to least likely):

```
1. [Most likely] <cause> — evidence: <what in the logs/metrics supports this>
2. [Possible]    <cause> — evidence: <...>
3. [Less likely] <cause> — evidence: <...>
```

Keep to 3 candidates unless evidence clearly narrows to 1.

### 6. Propose next action

Give exactly one next step — the smallest action that confirms or rules out cause #1.
Do not suggest a fix before the cause is confirmed.

```
Next step: <command or action>
Expected result if hypothesis is correct: <what you expect to see>
```

### 7. Escalation decision

State whether to escalate now or continue investigating:

| Condition | Action |
|---|---|
| Blast radius `critical` | Escalate immediately in parallel with investigation |
| Data loss risk | Escalate immediately |
| No evidence after 15 min | Escalate |
| Cause confirmed, fix known | Propose fix, ask before applying |
| Cause unknown, blast radius `contained` | Continue investigation |

---

## Output Format

```
## Incident Triage

**What:** <service/component>
**When:** <time or unknown>
**Affected:** <scope>
**Severity:** <level>
**Blast radius:** <contained / partial / wide / critical>

### Recent Changes
<summary or "none identified">

### Evidence Collected
<paste of relevant log lines or "pending — commands above">

### Root Cause Candidates
1. [Most likely] ...
2. [Possible] ...
3. [Less likely] ...

### Next Step
<single command or action>
Expected: <what a positive signal looks like>

### Escalate?
<yes / no / hold — reason>
```

---

## Guardrails

- Never suggest `restart`, `rollback`, or `delete` without explicit user confirmation.
- Never run destructive commands autonomously.
- If the user asks to "just fix it," slow down and complete the triage first.
- Do not speculate on root cause before reviewing evidence.
