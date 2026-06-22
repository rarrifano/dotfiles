---
description: Write a structured operational runbook for a procedure
argument-hint: "<procedure name>"
---
Write a runbook for: ${@:-the procedure described above}

Format:
## Runbook: <name>

**Purpose:** <one sentence>
**Owner:** <team or role>
**Frequency:** <when this is run>

## Prerequisites
- <access, tools, or context required>

## Steps
1. **<step name>**
   ```bash
   <exact command>
   ```
   Expected: <what success looks like>

## Verification
<how to confirm the procedure completed correctly>

## Rollback
<what to do if something goes wrong>

## Escalation
<who to contact if this runbook fails>
