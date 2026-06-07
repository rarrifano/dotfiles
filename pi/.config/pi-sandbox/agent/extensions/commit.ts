/**
 * /commit — Interactive conventional commit helper (Option B: AI-powered)
 *
 * Flow:
 *   1. Verify git repository
 *   2. Read git status — bail if working tree is clean
 *   3. Collect diffs (cached & unstaged) and last 5 commits
 *   4. Construct a prompt instructing the LLM to write the message
 *   5. Send prompt to user session to initiate turn
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MAX_DIFF_CHARS = 10000;

export default function commitExtension(pi: ExtensionAPI) {
  pi.registerCommand("commit", {
    description: "Analyse git changes and propose a commit message via AI",
    handler: async (_args, ctx) => {
      // ── 1. Check git repo ──────────────────────────────────────────────────
      const { code: repoCode } = await pi.exec("git", ["rev-parse", "--git-dir"]);
      if (repoCode !== 0) {
        ctx.ui.notify("Not a git repository", "error");
        return;
      }

      // ── 2. Read git status ─────────────────────────────────────────────────
      const { stdout: statusOut, code: statusCode } = await pi.exec("git", [
        "status",
        "--porcelain",
      ]);
      if (statusCode !== 0) {
        ctx.ui.notify("git status failed", "error");
        return;
      }

      if (!statusOut.trim()) {
        ctx.ui.notify("Nothing to commit — working tree is clean", "info");
        return;
      }

      // ── 3. Collect diffs ──────────────────────────────────────────────────
      const { stdout: stagedDiff } = await pi.exec("git", ["diff", "--cached"]);
      const { stdout: unstagedDiff } = await pi.exec("git", ["diff"]);

      const hasStagedChanges = stagedDiff.trim().length > 0;
      const diffContent = (hasStagedChanges ? stagedDiff : unstagedDiff).trim();

      const diffTruncated = diffContent.length > MAX_DIFF_CHARS;
      const diffSlice = diffContent.slice(0, MAX_DIFF_CHARS);

      // ── 4. Collect recent commits for style context ────────────────────────
      const { stdout: logOut } = await pi.exec("git", [
        "log",
        "--oneline",
        "-5",
      ]);

      // ── 5. Detect if we are in dotfiles mode ────────────────────────────────
      const isDotfiles = ctx.cwd.endsWith("/dotfiles") || ctx.cwd === "/dotfiles";

      // ── 6. Build the AI handoff prompt ─────────────────────────────────────
      const stagingNote = hasStagedChanges
        ? "Staged changes exist. Treat those as the primary changes to commit."
        : "No changes are staged yet. You should stage them (e.g., git add -A) during or after approval.";

      const prompt = [
        "## AI Commit Proposal Request",
        "",
        "Please analyze the git changes below and propose a commit message.",
        "",
        isDotfiles
          ? [
              "### Dotfiles Mode Rules",
              "- You are in Ferri-chan's personal playground (dotfiles)!",
              "- Commit messages can be chaotic, expressive, and authored by Ferri-chan.",
              "- Style: warm, playful, and expressive.",
              "- When running `git commit`, you MUST override the author using:",
              '  `git commit --author="Ferri-chan <ferri@dotfiles.local>" -m "<message>"`',
              '  (or pass appropriate env vars: `GIT_AUTHOR_NAME="Ferri-chan" GIT_AUTHOR_EMAIL="ferri@dotfiles.local"` etc.)',
            ].join("\n")
          : [
              "### Professional Mode Rules",
              "- Use the conventional commit standard: `type(scope): subject`",
              "  - Types: `feat` `fix` `refactor` `docs` `chore` `perf` `ci` `build` `test`",
              "  - Subject: imperative mood, lowercase, no trailing period, ≤ 72 chars",
              "- Add a short body if non-trivial explaining *why*, not *what*.",
              "- Keep it professional and concise.",
            ].join("\n"),
        "",
        "### Instructions for the Agent",
        "1. Present the proposed commit message exactly as it will be passed to git in a fenced code block.",
        "2. Explain your reasoning briefly in your persona.",
        "3. Ask for explicit approval before executing the commit.",
        '4. DO NOT commit until the user confirms (e.g. "yes", "y", "looks good").',
        "5. Once confirmed, execute the commit using the proper options (and proper author override if in dotfiles mode!) and display the resulting commit SHA.",
        "",
        `> Note: ${stagingNote}`,
        "",
        "### git status",
        "```",
        statusOut.trim(),
        "```",
        "",
        logOut.trim()
          ? ["### Recent Commits", "```", logOut.trim(), "```", ""].join("\n")
          : "",
        "### git diff",
        diffTruncated ? `*Warning: Diff was truncated to ${MAX_DIFF_CHARS} chars*` : "",
        "```diff",
        diffSlice,
        diffTruncated ? "\n... (truncated)" : "",
        "```",
      ].join("\n").trim();

      // ── 7. Send user message to trigger AI turn ────────────────────────────
      await ctx.waitForIdle();
      pi.sendUserMessage(prompt);
    },
  });
}
