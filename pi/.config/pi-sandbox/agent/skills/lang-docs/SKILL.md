---
name: lang-docs
description: Explains programming language features, syntax, standard library APIs, and DevOps tool behavior using official documentation. Use when the user asks how something works in a specific language (Python, JavaScript, TypeScript, Rust, Go, Java, Kotlin, Swift, Ruby, PHP, C, C++, C#, Bash, SQL, Lua, Elixir, Haskell, Scala, Dart) or tool (Docker, Kubernetes, Terraform, Ansible, GitHub Actions, Helm).
---

# lang-docs — Official Documentation Skill

## Purpose

Answer questions about programming languages and DevOps tools by fetching content
directly from their official documentation. Never rely on training-data recall alone
when the official source is reachable.

## URL Reference

The canonical docs URL for each language and tool is in
[references/urls.md](references/urls.md). Read that file first.

## Workflow

Follow these steps every time this skill is active.

### 1. Identify the subject

Extract the language or tool from the user's question.
Examples: "how does Go handle errors" → Go; "what is async/await" → JavaScript or Python
(pick the one explicitly mentioned, or ask if ambiguous).

### 2. Look up the canonical URL

Read [references/urls.md](references/urls.md) and select:
- The **Key Entry Point** closest to the topic (stdlib, reference, language spec).
- Prefer a deep link over the root when the topic is specific
  (e.g. for "Python list comprehensions" prefer the reference page over https://docs.python.org/3/).

### 3. Fetch the documentation page

Call `fetch_content` with:
- `url`: the selected entry point URL
- `prompt`: the user's original question, verbatim

### 4. Synthesize the answer

Build your answer **from the fetched content**:
- Quote or paraphrase the relevant sections.
- Include working code examples from the docs where available.
- Cite the exact URL you fetched at the end of the answer.

### 5. Follow one level of links if needed

If the fetched page does not contain enough detail:
- Identify the most relevant in-page link from the rendered content.
- Fetch that one additional page.
- Do not recurse further — synthesize from what you have.

### 6. Fallback

If `fetch_content` fails (network error, bot block, etc.):
- State clearly that the fetch failed.
- Answer from training knowledge, but label it explicitly:
  > ⚠ Could not reach official docs. The following is based on training data and may be outdated.

## Answer Format

```
[answer based on fetched docs]

**Example** (from official docs):
[code block]

Source: <url you fetched>
```

Keep answers concise. Depth should match the question — a quick syntax question
gets a short answer; a concept question gets a fuller explanation.
