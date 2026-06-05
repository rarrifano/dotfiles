/**
 * /init Extension
 *
 * Creates or updates the project's AGENTS.md file by handing the task off to
 * the LLM with clear instructions to inspect the repository first.
 *
 * Usage:
 *   /init
 *   /init focus on local dev + release workflow
 */

import { existsSync } from "node:fs";
import path from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("init", {
		description: "Create or update the project's AGENTS.md file",

		handler: async (args, ctx) => {
			const { code, stdout } = await pi.exec("git", ["rev-parse", "--show-toplevel"]);
			const projectRoot = code === 0 ? stdout.trim() : ctx.cwd;
			const targetPath = path.join(projectRoot, "AGENTS.md");
			const relativeTargetPath = path.relative(ctx.cwd, targetPath) || "AGENTS.md";
			const fileExists = existsSync(targetPath);
			const userHint = args.trim() ? `\n\nExtra user guidance: ${args.trim()}` : "";

			const prompt = `\
## /init task

Create or update the project instruction file at \`${relativeTargetPath}\`.

### Goal
Write a concise, high-signal \`AGENTS.md\` that helps pi and other coding agents work effectively in this repository.

### Requirements
1. Inspect the repository before writing anything.
2. Base the file only on information you can verify from the repo itself.
3. ${fileExists ? `Read the existing \`${relativeTargetPath}\` first, preserve useful project-specific guidance, and update anything stale or missing.` : `Create \`${relativeTargetPath}\` from scratch.`}
4. Keep it practical and specific to this project.
5. Prefer short sections and bullet points over long prose.
6. Include only commands, workflows, conventions, and paths that you actually confirmed.
7. Do not invent build, test, lint, or deployment commands.
8. After editing the file, briefly summarize what you added or changed.

### Suggested content
Include whatever is truly relevant for this repo, such as:
- project purpose / current scope
- important directories and files
- how to run, test, lint, build, or validate changes
- coding/style conventions visible in the repo
- git or review workflow expectations
- any project-specific gotchas for future agents

### Execution plan
1. Inspect the repo structure and key config/docs files.
2. Review existing agent/context files if present.
3. Draft or update \`${relativeTargetPath}\`.
4. Keep the result compact, accurate, and easy to scan.

Do not ask for confirmation — just inspect the repo and make the file changes.${userHint}`;

			pi.sendUserMessage(prompt, { deliverAs: "followUp" });
		},
	});
}
