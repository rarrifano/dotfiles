---
name: skill-forge
description: Create, refactor, or improve pi skills. Use when the user asks to build, write, or add a new skill, refactor an existing skill, turn a workflow into a reusable skill, or package repeated instructions into a skill — including scaffolding SKILL.md, supporting scripts, reference docs, and choosing the right install location.
---

# skill-forge — Skill Authoring Skill

## Purpose

Guide the creation of a complete, well-structured pi skill from a user's idea or
description, following the Agent Skills standard. Output a ready-to-use skill
directory with SKILL.md and any supporting files.

---

## Workflow

### 1. Gather intent

If the user has not provided enough to work with, ask exactly one question to
resolve the most critical unknown. Stop after that question.

Minimum needed before writing anything:

| Field | Question to ask |
|---|---|
| What does it do | "What task should this skill handle?" |
| When to trigger | "When should the agent load this skill — what does the user say or do?" |

Nice to have (infer if not stated):

- Does it need helper scripts?
- Does it need reference documentation files?
- Should it be global (`~/.pi/agent/skills/`) or project-local (`.pi/skills/`)?

Default to **global** unless the skill is clearly project-specific.

### 2. Choose a name

Rules (from the Agent Skills spec):

- 1-64 characters
- Lowercase letters, numbers, hyphens only
- No leading/trailing hyphens, no consecutive hyphens
- Should match the parent directory name

Good names: `pdf-extractor`, `release-drafter`, `db-migration-helper`
Bad names: `PDF_Extractor`, `mySkill`, `-draft`, `release--notes`

If the user supplies a name, validate it. If it violates the spec, suggest the
corrected form.

### 3. Write the description

The description is the only thing the agent sees when deciding whether to load
the skill. It must be specific about:

- What the skill does
- When to use it (trigger conditions, user phrases)

Max 1024 characters.

Template:

```
<One sentence: what the skill does>.
Use when <trigger condition 1>, <trigger condition 2>.
<Optional: what it does NOT cover.>
```

### 4. Plan the skill directory

Decide what files are needed:

```
<skill-name>/
├── SKILL.md              # Always required
├── scripts/              # Include if the skill runs commands or automation
│   └── *.sh / *.js / *.py
├── references/           # Include if the skill has large reference material
│   └── *.md
└── assets/               # Include if the skill uses templates, schemas, or fixtures
    └── *
```

Only include directories that are actually needed. A simple instructional skill
needs only `SKILL.md`.

### 5. Write SKILL.md

Structure:

````markdown
---
name: <skill-name>
description: <specific description>
---

# <skill-name> — <Human Title>

## Purpose
<One paragraph. What problem this solves and for whom.>

## Workflow

### 1. <First step>
<Instructions>

### 2. <Second step>
<Instructions>

...

## Output Format
<If the skill produces structured output, define the format here.>

## Guardrails
<What the skill must never do.>
````

Rules for SKILL.md content:

- Use numbered workflow steps — skills are procedures, not prose.
- Every action step must be concrete and executable.
- Reference supporting files with relative paths: `./scripts/run.sh`, `./references/api.md`.
- If scripts are involved, show exact invocation with arguments.
- Include a Guardrails section for every skill that touches files, systems, or
  external services.
- Keep the total file under ~400 lines. If it grows larger, extract reference
  material into `references/`.

### 6. Write supporting scripts (if needed)

Script rules:

- Shebang: `#!/usr/bin/env bash` (or appropriate interpreter)
- Bash scripts: `set -euo pipefail` at the top
- Quote every variable: `"${var}"`
- Run `shellcheck` before finalizing any `.sh` file
- Node scripts: ES modules preferred, no extra deps unless clearly justified
- Python scripts: use stdlib unless the user's project already has the dep

### 7. Choose install location

| Condition | Location |
|---|---|
| Useful across all projects | `~/.pi/agent/skills/<skill-name>/` |
| Specific to current repo | `.pi/skills/<skill-name>/` (relative to repo root) |
| User explicitly specifies | Respect the user's choice |

State the chosen path and confirm before writing files.

### 8. Write the files

After confirmation, write all files using the `write` tool. Then verify:

```bash
ls -la <install-path>/<skill-name>/
```

### 9. Validate

Check the skill is discoverable:

```bash
# In pi interactive mode, the skill should appear in:
/skills
```

Manually verify SKILL.md frontmatter:
- `name` field present and valid
- `description` field present and specific
- No invalid frontmatter keys

---

## Output Format

After writing the skill, report:

```
## Skill Created

**Name:** <skill-name>
**Location:** <full path>
**Files written:**
- SKILL.md
- scripts/run.sh   (if applicable)
- references/*.md  (if applicable)

**Trigger:** <when this skill will load>
```

---

## Guardrails

- Never write a skill with a vague description — a vague description means the
  agent will never load it at the right time.
- Never overwrite an existing skill without confirming with the user first.
- Never include secrets, tokens, credentials, or personal identifiers in any
  skill file.
- Never write a skill that instructs the agent to skip confirmation on
  destructive or irreversible actions.
- If a script would be run with elevated permissions or touches production
  systems, add an explicit warning in the skill's Guardrails section.
- Do not create skills in `.pi/skills/` of a project Ferri-chan does not
  recognize — confirm the target repo first.
