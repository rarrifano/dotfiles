/**
 * /commit Extension
 *
 * Checks the git state of the current repo, handles staging, then hands off
 * to the LLM to inspect the full diff and create a well-crafted Conventional
 * Commit message before running `git commit`.
 *
 * Usage:
 *   /commit              — auto-detect everything
 *   /commit fix auth bug — pass extra context/hint to the LLM
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("commit", {
		description: "Check git status and create a well-crafted Conventional Commit",

		handler: async (args, ctx) => {
			// ── 1. Must be inside a git repo ─────────────────────────────────
			const { code: repoCode } = await pi.exec("git", ["rev-parse", "--is-inside-work-tree"]);
			if (repoCode !== 0) {
				ctx.ui.notify("Not inside a git repository.", "error");
				return;
			}

			// ── 2. Overall status ─────────────────────────────────────────────
			const { stdout: porcelain } = await pi.exec("git", ["status", "--porcelain"]);
			if (!porcelain.trim()) {
				ctx.ui.notify("Nothing to commit — working tree is clean.", "info");
				return;
			}

			// ── 3. Categorise changes ─────────────────────────────────────────
			const { stdout: stagedStat } = await pi.exec("git", ["diff", "--cached", "--stat"]);
			const { stdout: unstagedDiff } = await pi.exec("git", ["diff", "--stat"]);
			const { stdout: untrackedRaw } = await pi.exec("git", [
				"ls-files",
				"--others",
				"--exclude-standard",
			]);

			const hasStaged = stagedStat.trim().length > 0;
			const hasUnstaged = unstagedDiff.trim().length > 0 || untrackedRaw.trim().length > 0;

			// ── 4. Staging decisions ──────────────────────────────────────────
			if (!hasStaged && hasUnstaged) {
				// Nothing staged at all → offer to stage everything
				const doStage = await ctx.ui.confirm(
					"Nothing staged",
					"No staged changes found.\nStage all changes now? (git add -A)",
				);
				if (!doStage) {
					ctx.ui.notify("Commit cancelled. Run `git add` to stage files first.", "info");
					return;
				}
				await pi.exec("git", ["add", "-A"]);
			} else if (hasStaged && hasUnstaged) {
				// Partially staged → ask whether to pull in the rest
				const stageRest = await ctx.ui.confirm(
					"Unstaged changes detected",
					"Some changes are not staged.\nInclude ALL changes in this commit? (git add -A)",
				);
				if (stageRest) {
					await pi.exec("git", ["add", "-A"]);
				}
			}

			// ── 5. Quick sanity check: something must be staged now ───────────
			const { stdout: stagedNames } = await pi.exec("git", ["diff", "--cached", "--name-only"]);
			if (!stagedNames.trim()) {
				ctx.ui.notify("No staged changes after all — aborting.", "error");
				return;
			}

			// ── 6. Gather context for the LLM ─────────────────────────────────
			const { stdout: branchRaw } = await pi.exec("git", ["branch", "--show-current"]);
			const branch = branchRaw.trim();

			const { stdout: logRaw } = await pi.exec("git", ["log", "--oneline", "-5"]);

			// ── 7. Hand off to the LLM ────────────────────────────────────────
			const userHint = args.trim() ? `\n\nUser hint: "${args.trim()}"` : "";

			const prompt = `\
## /commit task

I need you to create a well-crafted git commit for the currently staged changes.

### Context
- **Branch:** ${branch || "(detached HEAD)"}
- **Recent commits (for style reference):**
\`\`\`
${logRaw.trim() || "(no previous commits)"}
\`\`\`
- **Staged files:**
\`\`\`
${stagedNames.trim()}
\`\`\`${userHint}

### Steps
1. Run \`git diff --cached\` to read the full staged diff.
2. Analyse *what* changed and, more importantly, *why* it matters.
3. Compose a **Conventional Commit** message:
   - Format: \`<type>(<optional scope>): <imperative subject>\`
   - Types: \`feat\`, \`fix\`, \`refactor\`, \`docs\`, \`style\`, \`test\`, \`chore\`, \`perf\`, \`ci\`, \`build\`
   - Subject: ≤ 72 characters, lowercase, no trailing period, imperative mood
   - Body (optional but preferred for non-trivial changes): blank line after subject,
     wrap at 72 chars, explain *why* not *what*, reference issues if relevant
   - Footer (optional): \`BREAKING CHANGE:\`, \`Closes #123\`, etc.
4. Run \`git commit -m "<subject>" -m "<body>"\` (use separate \`-m\` flags for
   subject and body so git formats them correctly; omit the body flag if there
   is nothing meaningful to add).
5. Show the resulting \`git log --oneline -1\` output to confirm.

Do **not** ask for confirmation — just do it.`;

			pi.sendUserMessage(prompt, { deliverAs: "followUp" });
		},
	});
}
