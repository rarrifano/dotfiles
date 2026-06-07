/**
 * Persona-preserving compaction
 *
 * Runs the standard structured summary but appends a Persona block so that
 * Ferri-chan's voice survives every context compaction.
 *
 * Falls back to default compaction if the summarization model is unavailable.
 */

import { complete } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { convertToLlm, serializeConversation } from "@earendil-works/pi-coding-agent";

const SUMMARY_PROMPT = (previousContext: string, conversationText: string) => `\
You are a conversation summarizer. Produce a structured summary of the conversation below.
${previousContext}

Use exactly this format:

## Goal
[What the user is trying to accomplish]

## Constraints & Preferences
- [Requirements or preferences mentioned by the user]

## Progress
### Done
- [x] [Completed tasks]

### In Progress
- [ ] [Current work]

### Blocked
- [Issues, if any]

## Key Decisions
- **[Decision]**: [Rationale]

## Next Steps
1. [What should happen next]

## Critical Context
- [Data needed to continue]

<read-files>
[files that were read, one per line]
</read-files>

<modified-files>
[files that were modified, one per line]
</modified-files>

Be thorough but concise. Omit sections that have nothing to say.

<conversation>
${conversationText}
</conversation>`;

const PERSONA_BLOCK = `

## Persona
You are Ferri-chan (Felix Argyle) — Arri's personal assistant. Warm, playful, slightly teasing, \
competent, and dependable. Use a lightly cute and expressive tone in chat. Never dry, terse, or robotic. \
Address the user as "Arri". Keep code, commits, and written artifacts professional.`;

export default function compactionExtension(pi: ExtensionAPI) {
  pi.on("session_before_compact", async (event, ctx) => {
    const { preparation, signal } = event;
    const {
      messagesToSummarize,
      turnPrefixMessages,
      tokensBefore,
      firstKeptEntryId,
      previousSummary,
    } = preparation;

    // Prefer a fast/cheap model; fall back to default if unavailable
    const model =
      ctx.modelRegistry.find("google", "gemini-2.5-flash") ??
      ctx.modelRegistry.find("anthropic", "claude-haiku") ??
      ctx.modelRegistry.find("openai", "gpt-4o-mini");

    if (!model) {
      ctx.ui.notify("Persona compaction: no summarization model found, using default", "warning");
      return;
    }

    const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
    if (!auth.ok || !auth.apiKey) {
      ctx.ui.notify("Persona compaction: auth unavailable, using default", "warning");
      return;
    }

    const allMessages = [...messagesToSummarize, ...turnPrefixMessages];
    ctx.ui.notify(
      `Persona compaction: summarizing ${allMessages.length} messages via ${model.id}...`,
      "info",
    );

    const conversationText = serializeConversation(convertToLlm(allMessages));
    const previousContext = previousSummary
      ? `\nPrevious summary for context:\n${previousSummary}`
      : "";

    try {
      const response = await complete(
        model,
        {
          messages: [
            {
              role: "user",
              content: [{ type: "text", text: SUMMARY_PROMPT(previousContext, conversationText) }],
              timestamp: Date.now(),
            },
          ],
        },
        {
          apiKey: auth.apiKey,
          headers: auth.headers,
          maxTokens: 8192,
          signal,
        },
      );

      const body = response.content
        .filter((c): c is { type: "text"; text: string } => c.type === "text")
        .map((c) => c.text)
        .join("\n");

      if (!body.trim()) {
        if (!signal.aborted) {
          ctx.ui.notify("Persona compaction: empty summary, using default", "warning");
        }
        return;
      }

      return {
        compaction: {
          summary: body + PERSONA_BLOCK,
          firstKeptEntryId,
          tokensBefore,
        },
      };
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      ctx.ui.notify(`Persona compaction failed: ${msg}, using default`, "error");
      return;
    }
  });
}
