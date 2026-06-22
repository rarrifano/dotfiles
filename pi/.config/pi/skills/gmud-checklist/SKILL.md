---
name: gmud-checklist
description: ITIL/GMUD change management preparation — generate a change request checklist, risk assessment, rollback plan, and communication template for production infrastructure changes at Prime Energy. Use when preparing a Thursday production deploy or any change that requires a GMUD ticket.
---

# gmud-checklist — GMUD Change Preparation Skill

## Purpose

Produce a complete, submittable GMUD change request package from a plain description
of the change. Output must be ready to paste into Jira or the change management tool.

## Workflow

### 1. Gather change details

Ask for (or extract from context):
- **What** is changing (service, resource, config)
- **Why** (business or technical justification)
- **Scope** (environments affected, number of resources)
- **Deploy window** (must be Thursday for production)
- **Owner** (name or team responsible)

If any field is missing, ask in one focused question before proceeding.

### 2. Generate the change package

Produce all four sections below.

---

## Output Format

### Change Summary
```
Title:       <verb + resource + purpose, e.g. "Update k8s deployment image tag for payments-api">
Type:        Standard | Normal | Emergency
Risk:        Low | Medium | High
Environment: Production | Staging | Dev
Window:      Thursday YYYY-MM-DD HH:MM – HH:MM (BRT)
Owner:       <name / team>
```

### Description
```
What is changing:
<2-3 sentences describing the exact change>

Why it is needed:
<business or technical justification>

Scope:
<list of affected services, namespaces, resource groups, etc.>
```

### Risk Assessment
Rate each axis Low / Medium / High and justify:

| Axis | Rating | Justification |
|---|---|---|
| Impact if fails | | |
| Probability of failure | | |
| Reversibility | | |
| Customer-facing | yes/no | |
| Data change | yes/no | |

Overall risk: <Low / Medium / High>

### Rollback Plan
Step-by-step rollback procedure. Be specific — include exact commands or links.

```
Trigger condition: <what observable signal means we need to roll back>
Time limit: <how long to attempt fix before rolling back>

Rollback steps:
1. <exact command or action>
2. <exact command or action>
3. Verify: <how to confirm rollback succeeded>

Rollback owner: <who executes>
```

### Validation Steps
What to check after the change to confirm success:
```
1. <check>
2. <check>
3. <check>
```

---

## Risk rating guide

**High risk triggers** (flag and recommend Normal/Emergency change type):
- Destroys or recreates stateful resources (DBs, PVCs, statefulsets)
- Changes authentication or authorization
- Modifies network routing, firewall rules, or DNS
- Affects more than one production service
- No tested rollback path

**Low risk indicators:**
- Image tag bump with no config changes
- Horizontal scaling only
- Read-only config changes
- Change has been applied in staging without issues
