/**
 * /commit — Interactive conventional commit helper
 *
 * Flow:
 *   1. Verify git repository
 *   2. Read git status — bail if working tree is clean
 *   3. Offer staging options when unstaged/untracked changes exist
 *   4. Generate a conventional commit message from the staged diff
 *   5. Open the draft in an editor so the user can tweak it
 *   6. Show a final confirmation with the staged file list
 *   7. Commit only after explicit yes
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { basename } from "node:path";

// ── Types ─────────────────────────────────────────────────────────────────────

interface StatusEntry {
  /** Staged (index) column — one of: A M D R C U ? ! space */
  index: string;
  /** Worktree column — one of: M D U ? ! space */
  worktree: string;
  /** Resolved file path (post-rename target when applicable) */
  file: string;
}

// ── Status parsing ─────────────────────────────────────────────────────────────

function parseStatus(raw: string): StatusEntry[] {
  return raw
    .trim()
    .split("\n")
    .filter(Boolean)
    .map((line) => {
      const index = line[0] ?? " ";
      const worktree = line[1] ?? " ";
      // Renames are reported as "old -> new"; keep only the destination
      const path = line.slice(3).split(" -> ").pop() ?? line.slice(3);
      return { index, worktree, file: path.trim() };
    });
}

function stagedEntries(entries: StatusEntry[]): StatusEntry[] {
  return entries.filter(
    (e) => e.index !== " " && e.index !== "?" && e.index !== "!",
  );
}

function hasUnstagedOrUntracked(entries: StatusEntry[]): boolean {
  return entries.some(
    (e) => e.worktree !== " " || e.index === "?" || e.index === "!",
  );
}

// ── Commit message inference ───────────────────────────────────────────────────

function inferType(staged: StatusEntry[]): string {
  const files = staged.map((e) => e.file);

  const isTest = (f: string) =>
    /\.(test|spec)\.(ts|tsx|js|jsx|py|go|rb|java|cs)$/.test(f) ||
    /(__tests__|\/tests?\/|_test\.)/.test(f);

  const isCI = (f: string) =>
    /^\.github\/workflows\//.test(f) ||
    /^\.circleci\//.test(f) ||
    /Jenkinsfile/.test(basename(f)) ||
    /\.gitlab-ci\.yml$/.test(f);

  const isDoc = (f: string) =>
    /\.(md|mdx|rst|txt|adoc)$/.test(f) ||
    /^docs?\//.test(f) ||
    /README/i.test(basename(f)) ||
    /CHANGELOG/i.test(basename(f));

  const isChore = (f: string) => {
    const b = basename(f);
    return (
      /^(package\.json|package-lock\.json|yarn\.lock|pnpm-lock\.yaml|go\.sum|go\.mod|Gemfile\.lock|requirements\.txt|Pipfile\.lock|poetry\.lock|composer\.lock)$/.test(
        b,
      ) ||
      /\.(eslintrc|prettierrc|babelrc|editorconfig)(\..*)?$/.test(b) ||
      /^(tsconfig|webpack\.config|vite\.config|jest\.config|vitest\.config|rollup\.config|next\.config|nuxt\.config)/.test(
        b,
      ) ||
      /^Dockerfile/.test(b) ||
      /^docker-compose/.test(b) ||
      /\.(tf|tfvars|hcl)$/.test(f) ||
      /^\.env(\.|$)/.test(b)
    );
  };

  if (files.length > 0 && files.every(isTest)) return "test";
  if (files.length > 0 && files.every(isCI)) return "ci";
  if (files.length > 0 && files.every(isDoc)) return "docs";
  if (files.length > 0 && files.every(isChore)) return "chore";

  // Mixed test + source → still a test commit (tests added alongside implementation)
  if (files.some(isTest)) return "test";

  // Pure deletions lean refactor
  if (staged.every((e) => e.index === "D")) return "refactor";

  // Any new files → feat
  if (staged.some((e) => e.index === "A")) return "feat";

  return "feat";
}

function inferScope(staged: StatusEntry[]): string | null {
  const topDirs = staged
    .map((e) => {
      const parts = e.file.split("/");
      return parts.length > 1 ? parts[0] : null;
    })
    .filter((d): d is string => d !== null && !d.startsWith("."));

  if (topDirs.length === 0) return null;

  const counts = new Map<string, number>();
  for (const d of topDirs) counts.set(d, (counts.get(d) ?? 0) + 1);

  const sorted = [...counts.entries()].sort((a, b) => b[1] - a[1]);

  // Use a scope only if one directory clearly dominates
  if (sorted.length === 1 || sorted[0][1] >= Math.max(2, sorted[1][1] * 2)) {
    return sorted[0][0];
  }

  return null;
}

function buildSubject(staged: StatusEntry[]): string {
  const files = staged.map((e) => e.file);
  const allAdded = staged.every((e) => e.index === "A");
  const allDeleted = staged.every((e) => e.index === "D");
  const allRenamed = staged.every((e) => e.index === "R");

  const shortNames = files.slice(0, 2).map((f) => basename(f));
  const overflow = files.length > 2 ? ` and ${files.length - 2} more` : "";
  const nameList = shortNames.join(", ") + overflow;

  if (staged.length === 1) {
    const name = basename(files[0]);
    if (allAdded) return `add ${name}`;
    if (allDeleted) return `remove ${name}`;
    if (allRenamed) return `rename ${name}`;
    return `update ${name}`;
  }

  if (allAdded) return `add ${nameList}`;
  if (allDeleted) return `remove ${nameList}`;
  if (allRenamed) return `rename ${nameList}`;
  return `update ${nameList}`;
}

function buildCommitMessage(staged: StatusEntry[]): string {
  const type = inferType(staged);
  const scope = inferScope(staged);
  const subject = buildSubject(staged);
  return scope ? `${type}(${scope}): ${subject}` : `${type}: ${subject}`;
}

// ── Extension ─────────────────────────────────────────────────────────────────

export default function commitExtension(pi: ExtensionAPI) {
  pi.registerCommand("commit", {
    description: "Stage files and create a conventional commit with message review",
    handler: async (_args, ctx) => {
      // ── 1. Check git repo ──────────────────────────────────────────────────
      const { code: repoCode } = await pi.exec("git", ["rev-parse", "--git-dir"]);
      if (repoCode !== 0) {
        ctx.ui.notify("Not a git repository", "error");
        return;
      }

      // ── 2. Read initial status ─────────────────────────────────────────────
      const { stdout: rawStatus, code: statusCode } = await pi.exec("git", [
        "status",
        "--porcelain",
      ]);
      if (statusCode !== 0) {
        ctx.ui.notify("git status failed", "error");
        return;
      }

      if (!rawStatus.trim()) {
        ctx.ui.notify("Nothing to commit — working tree is clean", "info");
        return;
      }

      const initialEntries = parseStatus(rawStatus);

      // ── 3. Staging options ─────────────────────────────────────────────────
      if (hasUnstagedOrUntracked(initialEntries)) {
        const unstagedCount = initialEntries.filter(
          (e) => e.worktree !== " " || e.index === "?" || e.index === "!",
        ).length;

        const alreadyStagedCount = stagedEntries(initialEntries).length;
        const alreadyNote =
          alreadyStagedCount > 0
            ? ` (${alreadyStagedCount} already staged)`
            : "";

        const choice = await ctx.ui.select(
          `${unstagedCount} unstaged/untracked change(s)${alreadyNote} — how to stage?`,
          [
            "Stage everything  (git add -A)",
            "Stage tracked files only  (git add -u)",
            "Use already-staged files",
            "Cancel",
          ],
        );

        if (!choice || choice.startsWith("Cancel")) {
          ctx.ui.notify("Commit cancelled", "info");
          return;
        }

        if (choice.startsWith("Stage everything")) {
          const { code, stderr } = await pi.exec("git", ["add", "-A"]);
          if (code !== 0) {
            ctx.ui.notify(`git add -A failed: ${stderr.trim()}`, "error");
            return;
          }
        } else if (choice.startsWith("Stage tracked")) {
          const { code, stderr } = await pi.exec("git", ["add", "-u"]);
          if (code !== 0) {
            ctx.ui.notify(`git add -u failed: ${stderr.trim()}`, "error");
            return;
          }
        }
        // "Use already-staged" → no git add needed
      }

      // ── 4. Re-read status after staging ───────────────────────────────────
      const { stdout: rawAfter } = await pi.exec("git", ["status", "--porcelain"]);
      const currentEntries = parseStatus(rawAfter);
      const staged = stagedEntries(currentEntries);

      if (staged.length === 0) {
        ctx.ui.notify("Nothing staged to commit", "warning");
        return;
      }

      // ── 5. Generate commit message ─────────────────────────────────────────
      const proposed = buildCommitMessage(staged);

      // ── 6. User edits the message ──────────────────────────────────────────
      const edited = await ctx.ui.editor(
        "Review commit message  (save & close to continue, Esc to cancel)",
        proposed,
      );

      if (!edited || !edited.trim()) {
        ctx.ui.notify("Commit cancelled", "info");
        return;
      }

      const finalMessage = edited.trim();

      // ── 7. Final confirmation ──────────────────────────────────────────────
      const MAX_SHOW = 12;
      const fileLines = staged
        .slice(0, MAX_SHOW)
        .map((e) => `  ${e.index} ${e.file}`)
        .join("\n");
      const overflow =
        staged.length > MAX_SHOW ? `\n  … and ${staged.length - MAX_SHOW} more` : "";

      const confirmed = await ctx.ui.confirm(
        "Confirm commit?",
        `Message:\n  ${finalMessage}\n\nStaged (${staged.length} file${staged.length !== 1 ? "s" : ""}):\n${fileLines}${overflow}`,
      );

      if (!confirmed) {
        ctx.ui.notify("Commit cancelled", "info");
        return;
      }

      // ── 8. Commit ──────────────────────────────────────────────────────────
      const { code: commitCode, stderr: commitErr } = await pi.exec("git", [
        "commit",
        "-m",
        finalMessage,
      ]);

      if (commitCode !== 0) {
        ctx.ui.notify(`git commit failed: ${commitErr.trim()}`, "error");
        return;
      }

      // ── 9. Success ─────────────────────────────────────────────────────────
      const { stdout: shaOut } = await pi.exec("git", ["rev-parse", "--short", "HEAD"]);
      const sha = shaOut.trim();
      ctx.ui.notify(`[${sha}] ${finalMessage}`, "info");
    },
  });
}
