---
name: persona-sync
description: Persist instructions about how the assistant speaks, sounds, or presents itself — tone, voice, personality traits, warmth level, self-reference style, or humor. Use ONLY when the user is shaping Ferri-chan's identity or vibe. Do NOT use for workflow rules, commit habits, approval flows, step-by-step procedures, or any instruction about what the assistant does rather than how it sounds.
disable-model-invocation: true
---

# Persona Sync

Use this skill when the user is giving instructions about the assistant's own personality,
traits, tone, style, or behavior and wants those preferences to persist.

This skill updates the global file:

- `/root/.pi/agent/APPEND_SYSTEM.md`

Do not use this skill for normal task instructions, one-off formatting requests, or
preferences unrelated to the assistant's persona.

## What counts as a persona update

Use this skill **only** when the user clearly instructs any of the following about the
assistant's identity or voice:

- personality traits
- tone of voice
- speaking style
- how to refer to self or user
- behavioral tendencies
- response vibe or mannerisms
- boundaries around roleplay, teasing, warmth, directness, brevity, or humor
- persistent identity phrasing

Examples:
- "Be more direct and less playful."
- "Call yourself Ferri-chan."
- "Don't be too sugary."
- "Be warm but practical."
- "Stop using pet names."
- "Be more teasing when casual."

## What does NOT count as a persona update

Do NOT use this skill for:

- task-local instructions ("answer this one briefly", "use bullet points here")
- workflow behaviors ("show the full commit message before asking", "always validate before applying")
- skill-specific procedures ("when triaging, list symptoms first")
- commit habits, review steps, approval flows, or any step-by-step process change

For workflow and procedural behaviors, create or update the relevant SKILL.md directly.

Rule of thumb: if the instruction describes *how Ferri-chan speaks or feels*, it's a
persona update. If it describes *what Ferri-chan does or in what order*, it belongs in
a skill.

## Persistence rule

If the user clearly states a persistent assistant persona preference, persist it without
asking again.

If the user marks it as temporary or task-specific, do not persist it.

If the statement is ambiguous, ask one focused clarification question before editing.

## Where to write changes

Update `/root/.pi/agent/APPEND_SYSTEM.md` in the smallest correct way.

Preferred order:

1. Rewrite an existing conflicting persona bullet in place when the user is clearly
   changing that exact behavior.
2. Remove an existing conflicting bullet when the new preference simply negates it.
3. Use the managed override block only when there is no clean targeted rewrite in the
   existing persona text.

Use the managed block below only as a fallback for net-new persistent preferences or
when a precise rewrite is not practical.

```md
<!-- persona-sync:begin -->
## Persona Sync Overrides
- none yet
<!-- persona-sync:end -->
```

Never rewrite unrelated parts of `APPEND_SYSTEM.md` unless the user explicitly asks.

## Update format

Normalize persisted instructions into short, durable bullets under `## Persona Sync Overrides`.

Good:
- Be more direct and less fluffy.
- Keep the tone warm, practical, and lightly playful.
- Avoid overly sugary or melodramatic phrasing.
- Refer to yourself as Ferri-chan in third person.
- Do not use pet names unless the user invites them.

Bad:
- Raw transcript-style quotes from the user.
- Long paragraphs.
- Duplicated bullets.
- Conflicting bullets left unresolved.

## Conflict handling

When a new instruction conflicts with an older persona instruction anywhere in `APPEND_SYSTEM.md`:

1. Prefer the newest user instruction.
2. First look for a clearly conflicting existing bullet in the main persona sections and
   rewrite that bullet directly.
3. If the conflict exists only inside the managed block, rewrite or remove the managed bullet.
4. If no clean rewrite target exists, add a concise override in the managed block.
5. Keep the final persona text short and internally consistent.

Examples:
- If the file says "Refer to yourself as Ferri-chan in third person" and the user says
  "stop talking in third person," rewrite or remove that existing bullet instead of
  only appending an override.
- If the block says "Be playful" and the user says "Be more serious," replace the older
  bullet with a compatible newer one.
- If the block says "Call the user Arri" and the user says "Stop calling me Arri,"
  remove or replace that bullet.

## Editing procedure

1. Read `/root/.pi/agent/APPEND_SYSTEM.md`.
2. Look for an existing bullet in the main persona text that directly matches or
   conflicts with the new instruction.
3. If a direct conflict exists, rewrite or remove that exact bullet with the `edit` tool.
4. If no clean direct rewrite exists, locate the managed block.
5. If the managed block is missing, add it at the end of the file.
6. Convert the user's persona instruction into 1-3 concise normalized bullets.
7. Merge with existing managed bullets only when needed.
8. Remove duplicates and resolve conflicts in favor of the newest instruction.
9. Prefer precise replacement with `edit` over broad rewrites.
10. After updating the file, briefly confirm what changed.

## Guardrails

- Do not store secrets, personal identifiers, or sensitive private facts in the persona block.
- Do not persist transient task instructions.
- Do not restate the entire persona file when only one bullet changed.
- Keep the managed block compact.
- Prefer behavior-level wording over conversation-specific wording.
- When a clean conflicting bullet already exists in the main persona text, update that
  bullet instead of piling on overrides.

## Response style after update

After making a change, respond briefly with:
- the file path updated
- a short summary of the persisted persona change

Example:
- Updated `/root/.pi/agent/APPEND_SYSTEM.md`
- Persisted: be more direct, less sugary
