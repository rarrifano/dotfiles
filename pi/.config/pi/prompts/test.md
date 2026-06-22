---
description: Write or fix tests for the current file or a named symbol
argument-hint: "[file or function name]"
---
Write tests for ${@:-the current file}.

Requirements:
- Use the test framework already present in the project
- Cover happy path, edge cases, and expected errors
- Keep tests independent — no shared mutable state between them
- Use descriptive test names that read as sentences
- Mock external I/O (network, filesystem, DB) unless an integration test is explicitly requested

Output only the test code, ready to run.
