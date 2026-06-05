/**
 * Global DevOps commands
 *
 *  /init    — generate a project-level AGENTS.md
 *  /explore — summarise the codebase
 *  /costs   — estimate infrastructure cost impact of current changes
 *  /danger  — flag dangerous operations in current changes / tf plan
 *  /undo    — restore files to pre-turn state (no git required)
 *             + git-level options (unstage / reset) when in a repo
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

// ── Helpers ────────────────────────────────────────────────────────────────

async function tryRead(pi: ExtensionAPI, path: string, maxBytes = 2000): Promise<string> {
	const { code, stdout } = await pi.exec("bash", ["-c", `cat "${path}" 2>/dev/null`]);
	if (code !== 0 || !stdout.trim()) return "";
	return stdout.length > maxBytes ? stdout.slice(0, maxBytes) + "\n…(truncated)" : stdout;
}

async function repoTree(pi: ExtensionAPI): Promise<string> {
	const { code, stdout } = await pi.exec("git", [
		"ls-files", "--cached", "--others", "--exclude-standard",
	]);
	if (code === 0 && stdout.trim()) return stdout.trim();
	const { stdout: found } = await pi.exec("bash", [
		"-c",
		"find . -maxdepth 3 -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/.terraform/*' | sort",
	]);
	return found.trim();
}

// ── Extension ──────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {

	// ── /init ────────────────────────────────────────────────────────────────

	pi.registerCommand("init", {
		description: "Generate a project-level AGENTS.md from codebase analysis",
		handler: async (_args, ctx) => {
			const { code: existsCode } = await pi.exec("bash", ["-c", "test -f AGENTS.md"]);
			if (existsCode === 0) {
				const overwrite = await ctx.ui.confirm(
					"AGENTS.md exists",
					"Overwrite the existing project AGENTS.md?",
				);
				if (!overwrite) return;
			}

			ctx.ui.notify("Gathering project context…", "info");

			const tree = await repoTree(pi);
			const { stdout: gitLog } = await pi.exec("git", ["log", "--oneline", "-10"]);
			const { stdout: remote } = await pi.exec("git", ["remote", "-v"]);

			const manifests: string[] = [];
			for (const f of [
				"package.json", "go.mod", "requirements.txt",
				"pyproject.toml", "Makefile", "Taskfile.yml",
			]) {
				const content = await tryRead(pi, f, 600);
				if (content) manifests.push(`**${f}**\n\`\`\`\n${content}\n\`\`\``);
			}

			const { stdout: workflowList } = await pi.exec("bash", [
				"-c", "ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null",
			]);
			const workflows: string[] = [];
			for (const wf of workflowList.trim().split("\n").filter(Boolean).slice(0, 4)) {
				const content = await tryRead(pi, wf, 800);
				if (content) workflows.push(`**${wf}**\n\`\`\`yaml\n${content}\n\`\`\``);
			}

			const { stdout: tfList } = await pi.exec("bash", [
				"-c",
				"find . -name 'main.tf' -not -path '*/.terraform/*' 2>/dev/null | head -5",
			]);
			const tfFiles: string[] = [];
			for (const tf of tfList.trim().split("\n").filter(Boolean)) {
				const content = await tryRead(pi, tf, 600);
				if (content) tfFiles.push(`**${tf}**\n\`\`\`hcl\n${content}\n\`\`\``);
			}

			const prompt = `\
## /init task

Analyse this project and write a **concise, useful \`AGENTS.md\`** for it.
Save the file to \`AGENTS.md\` at the project root (overwrite if present).

### Project context

**File tree:**
\`\`\`
${tree}
\`\`\`

**Recent commits:**
\`\`\`
${gitLog.trim() || "(no commits yet)"}
\`\`\`

**Remote:** ${remote.trim().split("\n")[0] ?? "(none)"}

${manifests.length ? "### Manifests / entrypoints\n" + manifests.join("\n\n") : ""}
${workflows.length ? "### CI workflows\n" + workflows.join("\n\n") : ""}
${tfFiles.length ? "### Terraform entry points\n" + tfFiles.join("\n\n") : ""}

### What a good project AGENTS.md contains

- Project purpose (one line)
- Tech stack + key tools/frameworks
- Repo structure (only non-obvious parts)
- How to run / build / test locally
- Code conventions specific to this project
- Anything an agent must never do here

Keep it under 80 lines. No fluff. Imperative bullets.
Write the file now.`;

			pi.sendUserMessage(prompt, { deliverAs: "followUp" });
		},
	});

	// ── /explore ─────────────────────────────────────────────────────────────

	pi.registerCommand("explore", {
		description: "Summarise the codebase — structure, purpose, key components",
		handler: async (args, ctx) => {
			ctx.ui.notify("Exploring codebase…", "info");

			const tree = await repoTree(pi);
			const readme = await tryRead(pi, "README.md", 1500);
			const { stdout: gitLog } = await pi.exec("git", ["log", "--oneline", "-10"]);
			const focus = args.trim() ? `\n\nUser wants to focus on: **${args.trim()}**` : "";

			const prompt = `\
## /explore task

Give me a clear, concise overview of this codebase.
${focus}

### File tree
\`\`\`
${tree}
\`\`\`

${readme ? `### README\n${readme}` : ""}

**Recent commits:**
\`\`\`
${gitLog.trim() || "(none)"}
\`\`\`

### What I want
1. **Purpose** — what does this project do in one sentence
2. **Architecture** — main components and their roles
3. **Tech stack** — languages, frameworks, key dependencies
4. **Entry points** — where execution starts, main flows
5. **Anything non-obvious** — gotchas, unusual patterns, important context

Read any files you need. Be concise.`;

			pi.sendUserMessage(prompt, { deliverAs: "followUp" });
		},
	});

	// ── /costs ───────────────────────────────────────────────────────────────

	pi.registerCommand("costs", {
		description: "Estimate cloud infrastructure cost impact of current changes",
		handler: async (_args, ctx) => {
			const { code: icCode } = await pi.exec("which", ["infracost"]);

			if (icCode === 0) {
				ctx.ui.notify("Running infracost diff…", "info");
				const { stdout: icOut, stderr: icErr } = await pi.exec("infracost", [
					"diff", "--path", ".", "--format", "table",
				]);
				const output = (icOut + icErr).trim();

				pi.sendUserMessage(`\
## /costs task

\`infracost diff\` output:

\`\`\`
${output || "(no output)"}
\`\`\`

1. Explain the cost delta — what gets more expensive, what gets cheaper
2. Flag any line items that look surprisingly high
3. Suggest cheaper alternatives if obvious ones exist`, { deliverAs: "followUp" });
				return;
			}

			ctx.ui.notify("infracost not found — analysing terraform changes…", "info");

			const { stdout: stagedNames } = await pi.exec("git", ["diff", "--cached", "--name-only"]);
			const { stdout: diff } = await pi.exec("git", ["diff", "--cached"]);
			const { stdout: tfList } = await pi.exec("bash", [
				"-c",
				"find . -name '*.tf' -not -path '*/.terraform/*' 2>/dev/null | head -20",
			]);
			const { stdout: tfPlan } = await pi.exec("bash", [
				"-c",
				"find . -name 'tfplan' -o -name 'plan.out' -o -name '*.tfplan' 2>/dev/null | head -3",
			]);

			pi.sendUserMessage(`\
## /costs task

\`infracost\` is not installed. Analyse manually.

**Staged files:**
\`\`\`
${stagedNames.trim() || "(nothing staged)"}
\`\`\`

**All .tf files:**
\`\`\`
${tfList.trim() || "(none found)"}
\`\`\`

${tfPlan.trim() ? `**Terraform plan files found:** ${tfPlan.trim().replace(/\n/g, ", ")}` : ""}

**Staged diff:**
\`\`\`diff
${diff.trim() || "(no diff)"}
\`\`\`

1. Identify resources being added, changed, or destroyed
2. Estimate monthly cost delta (state cloud + pricing assumptions)
3. Flag anything that could cause unexpected cost spikes
4. Suggest cheaper alternatives if obvious

Read any .tf files you need for full context.`, { deliverAs: "followUp" });
		},
	});

	// ── /danger ──────────────────────────────────────────────────────────────

	pi.registerCommand("danger", {
		description: "Analyse current changes and tf plan for dangerous operations",
		handler: async (_args, ctx) => {
			ctx.ui.notify("Scanning for dangerous changes…", "info");

			const { stdout: stagedNames } = await pi.exec("git", ["diff", "--cached", "--name-only"]);
			const { stdout: stagedDiff } = await pi.exec("git", ["diff", "--cached"]);
			const { stdout: unstagedDiff } = await pi.exec("git", ["diff"]);

			const { stdout: planFiles } = await pi.exec("bash", [
				"-c",
				"find . -name 'tfplan' -o -name 'plan.out' -o -name '*.tfplan' 2>/dev/null | head -5",
			]);

			const planSections: string[] = [];
			for (const pf of planFiles.trim().split("\n").filter(Boolean)) {
				const { stdout: planJson, code } = await pi.exec("terraform", ["show", "-json", pf.trim()]);
				if (code === 0 && planJson.trim()) {
					planSections.push(`**Plan: ${pf.trim()}**\n\`\`\`json\n${planJson.slice(0, 4000)}\n\`\`\``);
				} else {
					planSections.push(`**Plan: ${pf.trim()}** — could not decode (run \`terraform show\` manually)`);
				}
			}

			const allDiff = [
				stagedDiff.trim() && `**Staged:**\n\`\`\`diff\n${stagedDiff.trim()}\n\`\`\``,
				unstagedDiff.trim() && `**Unstaged:**\n\`\`\`diff\n${unstagedDiff.trim()}\n\`\`\``,
			].filter(Boolean).join("\n\n");

			pi.sendUserMessage(`\
## /danger task

Review current changes for dangerous, destructive, or hard-to-reverse operations.

${stagedNames.trim() ? `**Staged files:**\n\`\`\`\n${stagedNames.trim()}\n\`\`\`` : ""}
${planSections.join("\n\n")}
${allDiff || "(no diff available)"}

### What to check for

**Terraform / IaC:**
- Resource deletions or replacements (databases, volumes, clusters)
- IAM changes that broaden permissions
- Security groups opening ports to 0.0.0.0/0
- Removal of encryption, logging, or backup settings

**GitHub Actions:**
- Secrets exposed in logs
- Unpinned third-party actions
- Permissions widened to write-all
- \`pull_request_target\` with access to secrets

**General:**
- Hard or impossible to roll back
- Bypasses staging/review
- Credentials hardcoded anywhere

Rate each finding: 🔴 critical / 🟠 high / 🟡 medium / 🟢 low.
If clean, say so.`, { deliverAs: "followUp" });
		},
	});
}
