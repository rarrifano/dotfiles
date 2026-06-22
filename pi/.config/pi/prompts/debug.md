---
description: Structured diagnosis for a bug or unexpected behaviour
argument-hint: "<symptom>"
---
Debug: ${@:-the issue described above}

1. State what the code *should* do vs. what it *actually* does
2. Identify the smallest reproducing case
3. Trace the execution path to the fault
4. Propose a fix — show the diff, not a rewrite
