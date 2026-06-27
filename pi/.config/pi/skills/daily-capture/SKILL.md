---
name: daily-capture
description: "Morning GTD inbox triage — pull all pending inbox tasks and help the user process each one interactively: assign a project, pick a tag (next/waiting/someday), and optionally set a due date. Ends with a batch modify. Use when Arri asks to triage inbox, process captures, or do morning GTD."
---

# Daily Capture — GTD Inbox Triage

## Goal

Process every task in `project:inbox` one by one. For each task, decide:

1. **Project** — which project does it belong to?
2. **Tag** — `+next` (do it), `+waiting` (blocked/delegated), `+someday` (backlog)
3. **Due date** — optional, only if it has a real deadline

At the end, apply all decisions in a single batch.

## Steps

### 1. Load the inbox

```
task project:inbox status:pending list
```

If the inbox is empty, tell the user and stop — nothing to triage~

### 2. Process each task interactively

For each task, show:
- ID and description
- Current project and tags

Then ask the user to decide. Accept shorthand answers:
- `sre next` → `project:SRE +next`
- `infra waiting` → `project:infra +waiting`
- `someday` → keep project:inbox, add `+someday` and remove `+inbox`
- `skip` → leave it untouched
- `done` → mark it completed

### 3. Apply all decisions

Build and show the full list of `task modify` commands before running anything.
Ask for confirmation (`lgtm` / `ok` / `go-ahead`) before executing.

Example batch:
```
task 12 modify project:SRE +next -inbox
task 13 modify project:infra +waiting -inbox
task 14 done
```

### 4. Summary

After applying, show:
- How many tasks were processed
- Count by tag (next / waiting / someday / done)
- Remaining inbox count (should be 0)

## Rules

- Never delete tasks — only modify or complete them
- Always remove `+inbox` tag and `project:inbox` when moving a task to a real project
- If the user says `someday`, keep project as-is but add `+someday` and remove `+inbox`
- Prefer one confirmation round for the whole batch, not per-task
