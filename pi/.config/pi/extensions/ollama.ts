import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const OLLAMA_PORT = process.env.OLLAMA_PORT ?? "11434";
// Inside the pi Podman container, the host is reachable via host.containers.internal
const OLLAMA_HOST = process.env.OLLAMA_HOST ?? "host.containers.internal";
const BASE_URL = `http://${OLLAMA_HOST}:${OLLAMA_PORT}/v1`;

export default async function (pi: ExtensionAPI) {
  let models: Array<{ id: string; name: string }> = [];

  try {
    const response = await fetch(`${BASE_URL}/models`);
    const payload = (await response.json()) as {
      data: Array<{ id: string }>;
    };

    models = payload.data.map((m) => ({
      id: m.id,
      name: m.id,
    }));
  } catch {
    // Ollama not running — register no models silently
    return;
  }

  if (models.length === 0) return;

  pi.registerProvider("ollama", {
    name: "Ollama (local)",
    baseUrl: BASE_URL,
    apiKey: "ollama",
    api: "openai-completions",
    models: models.map((m) => {
      const isQwen = /qwen/i.test(m.id);
      const isThinking = /thinking/i.test(m.id);

      return {
        id: m.id,
        name: m.name,
        reasoning: isQwen && isThinking,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: isQwen ? 8192 : 4096,
        compat: {
          maxTokensField: "max_tokens" as const,
          requiresToolResultName: true,
          ...(isQwen && isThinking
            ? { thinkingFormat: "qwen-chat-template" as const }
            : {}),
        },
      };
    }),
  });
}
