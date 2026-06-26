---
name: meeting-prep
description: Prepare Arri for the [PE IT] Sync Up recurring meeting — Pessoas, Estratégia e Execução. Pulls Taskwarrior project status, structures talking points per agenda segment, and drafts executive updates for leadership. Use when Arri asks to prepare for the sync, needs talking points, or wants a status summary before the meeting.
---

# meeting-prep — PE IT Sync Up Preparation Skill

## Purpose

Help Arri (Cloud Engineer, Prime Energy) prepare for the recurring [PE IT] Sync Up meeting.
Pull real project data from Taskwarrior, map to the meeting agenda, and produce structured talking points.

---

## Fixed Agenda Reference

Total duration: 1h40min

### Bloco 1 — Estratégia e Projetos (~1h)
| Segment | Duration |
|---|---|
| Warm Up | 5' |
| Alinhamentos | 15' |
| Evolução dos projetos | 30' |
| Liderança | 10' |
| PMO | 10' |
| Open Mic | 10' |

### Bloco 2 — Operação e Manutenção (~30')
| Segment | Duration |
|---|---|
| Liderança | 5' |
| Time (Infra e Sistemas) | 15' |
| Open Mic | 10' |

### Bloco 3 — Pessoas (~20')
| Segment | Duration |
|---|---|
| Feedbacks e People Care | 20' |

---

## Workflow

### Step 1 — Pull Taskwarrior data

Run the following to get current state:

```bash
# All pending tasks with project grouping
task projects

# Tasks due soon or with urgency
task next

# Tasks modified recently (likely to report)
task modified:week list
```

### Step 2 — Map tasks to agenda segments

| Agenda segment | What to look for in Taskwarrior |
|---|---|
| **Evolução dos projetos** | All active projects — summarize status per project |
| **PMO** | Tasks with due dates, blocked tasks, or high urgency score |
| **Time (Infra e Sistemas)** | Infra-related projects (k8s, terraform, pipelines, systems) |
| **Open Mic** | Anything notable, blocked, or needing visibility |

### Step 3 — Generate talking points

For each relevant segment produce:

```
## [Segment Name] — Arri's talking points

Projects / Topics:
- <project name>: <one-line status> — <next action or blocker>

Highlight (if any):
- <anything leadership should know>

Ask / Decision needed (if any):
- <what you need from the room>
```

### Step 4 — Open Mic suggestion

Based on Taskwarrior data, suggest 1–2 items worth raising in Open Mic:
- Blocked tasks needing escalation
- Projects at risk of missing deadlines
- Wins worth recognizing

### Step 5 — PMO flags

Flag any task that:
- Has a due date within 7 days
- Is overdue
- Has no progress (no annotations, no subtasks done) for more than 2 weeks

---

## Output Format

Produce a single structured brief:

```
# PE IT Sync Up — Prep Brief
Date: <today>

## Evolução dos projetos
<talking points>

## PMO
<flags and dates>

## Time — Infra e Sistemas
<technical status>

## Open Mic suggestions
<1-2 items>

## People Care (optional)
<any recognition worth mentioning>
```

---

## Notes

- Arri is direct — keep talking points short, one line per project max.
- Flag blockers explicitly — he needs to know what to escalate.
- If a project has no Taskwarrior tasks, note the gap (might be undocumented work).
- For GMUD-related items, cross-reference with the `gmud-checklist` skill.
