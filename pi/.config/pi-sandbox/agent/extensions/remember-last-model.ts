/**
 * Persist the last selected model by updating pi's settings.json.
 *
 * This makes new pi sessions start on the most recently used model,
 * without needing to re-select it manually.
 */

import { mkdir, readFile, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";

const agentDir = process.env.PI_CODING_AGENT_DIR ?? path.join(os.homedir(), ".pi", "agent");
const settingsPath = path.join(agentDir, "settings.json");

async function loadSettings(): Promise<Record<string, unknown>> {
	try {
		const raw = await readFile(settingsPath, "utf8");
		const parsed = JSON.parse(raw);
		return parsed && typeof parsed === "object" && !Array.isArray(parsed) ? parsed : {};
	} catch {
		return {};
	}
}

async function saveLastModel(provider: string, model: string): Promise<void> {
	const settings = await loadSettings();
	if (settings.defaultProvider === provider && settings.defaultModel === model) {
		return;
	}

	await mkdir(path.dirname(settingsPath), { recursive: true });
	await writeFile(
		settingsPath,
		JSON.stringify(
			{
				...settings,
				defaultProvider: provider,
				defaultModel: model,
			},
			null,
			2,
		) + "\n",
		"utf8",
	);
}

export default function (pi: any) {
	pi.on("model_select", async (event: { model: { provider: string; id: string } }) => {
		try {
			await saveLastModel(event.model.provider, event.model.id);
		} catch (error) {
			console.error("Failed to persist last model:", error);
		}
	});
}
