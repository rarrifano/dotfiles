/**
 * Ollama provider registration extension
 *
 * Dynamically fetches available models from Ollama and registers them
 * as a pi provider. The pi container is launched with
 * --add-host=host.containers.internal:host-gateway.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const OLLAMA_BASE_URL = "http://host.containers.internal:11434";

export default async function (pi: ExtensionAPI) {
  let models: Array<{ name: string }> = [];

  try {
    const response = await fetch(`${OLLAMA_BASE_URL}/api/tags`);
    const payload = (await response.json()) as { models: Array<{ name: string }> };
    models = payload.models ?? [];
  } catch (err) {
    console.error("🦙 Ollama: failed to fetch models —", err);
    return;
  }

  if (models.length === 0) {
    console.log("🦙 Ollama: no models found, skipping provider registration");
    return;
  }

  pi.registerProvider("ollama", {
    name: "Ollama",
    baseUrl: `${OLLAMA_BASE_URL}/v1`,
    apiKey: "ollama",
    api: "openai-completions",
    models: models.map((model) => ({
      id: model.name,
      name: model.name,
      reasoning: false,
      input: ["text"],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      contextWindow: 32768,
      maxTokens: 4096,
      compat: {
        supportsDeveloperRole: false,
        maxTokensField: "max_tokens",
      },
    })),
  });

  console.log(
    `🦙 Ollama provider registered with ${models.length} model(s): ${models.map((m) => m.name).join(", ")}`
  );
}
