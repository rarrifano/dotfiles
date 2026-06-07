/**
 * /init — Generate or update a project-level AGENTS.md
 *
 * Delegates all discovery and writing to the LLM. The agent probes the
 * current working directory using its normal tools (bash, read, write)
 * and produces an AGENTS.md it can rely on in future sessions.
 *
 * Usage: /init
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const INIT_PROMPT = `
Probe the current project and write an AGENTS.md file for it.

Discovery steps — run each in order, skip files that don't exist:
1. \`ls -la\` and \`git rev-parse --abbrev-ref HEAD\` — structure and default branch
2. \`package.json\` / \`go.mod\` / \`pyproject.toml\` / \`Cargo.toml\` — language, runtime, scripts, deps
3. \`Makefile\` / \`Taskfile.yml\` — build/run commands
4. \`.env.example\` / \`.env.sample\` — required environment variables
5. \`Dockerfile\` / \`docker-compose.yml\` / \`compose.yml\` — containerization
6. \`.github/workflows/\` / \`.gitlab-ci.yml\` / \`Jenkinsfile\` — CI/CD
7. \`terraform/\` / \`infra/\` / \`cdk.json\` / \`Pulumi.yaml\` — IaC

Write AGENTS.md with these sections (omit any that have nothing to say):
- **Stack** — language, runtime, package manager, frameworks, test framework, linter/formatter, CI, IaC
- **Commands** — table of exact commands and their purpose
- **Structure** — table of notable directories and what lives there
- **Key Files** — bullet list of files the agent should know about
- **Notes** — anything important that doesn't fit above (branch name, conventions, warnings)

If AGENTS.md already exists, show a brief diff summary and ask before overwriting.
Keep the output tight — no filler, no sections with nothing in them.
`.trim();

export default function initExtension(pi: ExtensionAPI) {
  pi.registerCommand("init", {
    description: "Generate or update AGENTS.md for this project",
    handler: async (_args, ctx) => {
      await ctx.waitForIdle();
      pi.sendUserMessage(INIT_PROMPT, { deliverAs: "followUp" });
    },
  });
}
