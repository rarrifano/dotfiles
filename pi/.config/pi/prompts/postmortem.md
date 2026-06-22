---
description: Write a blameless postmortem from an incident summary
argument-hint: "<incident summary>"
---
Write a blameless postmortem for: ${@:-the incident described above}

Format:
## Postmortem: <incident title>

**Date:** <date>
**Severity:** <P1/P2/P3>
**Duration:** <how long the incident lasted>
**Author:** <leave blank>

## Summary
<2-3 sentences: what happened, impact, how it was resolved>

## Timeline
| Time | Event |
|---|---|
| HH:MM | <event> |

## Root Cause
<technical root cause — no blame, no names>

## Contributing Factors
- <factor>

## Impact
- <who/what was affected and how>

## What Went Well
- <things that helped contain or resolve the incident>

## Action Items
| Action | Owner | Due |
|---|---|---|
| <item> | <team> | <date> |
