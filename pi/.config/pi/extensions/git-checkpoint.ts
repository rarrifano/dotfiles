/**
 * Git Checkpoint Extension
 *
 * Creates a git stash ref at each turn start so /fork can offer to restore
 * the working tree to that point in history. Uses `git stash create` which
 * records a stash object without touching the working tree.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  const checkpoints = new Map<string, string>();
  let currentEntryId: string | undefined;

  // Track the leaf entry ID so we can key checkpoints to session positions
  pi.on("tool_result", async (_event, ctx) => {
    const leaf = ctx.sessionManager.getLeafEntry();
    if (leaf) currentEntryId = leaf.id;
  });

  // Before the LLM starts a turn, snapshot the working tree (non-destructive)
  pi.on("turn_start", async () => {
    const { stdout } = await pi.exec("git", ["stash", "create"]).catch(() => ({ stdout: "" }));
    const ref = stdout.trim();
    if (ref && currentEntryId) {
      checkpoints.set(currentEntryId, ref);
    }
  });

  // On /fork, offer to restore the code state at that point
  pi.on("session_before_fork", async (event, ctx) => {
    const ref = checkpoints.get(event.entryId);
    if (!ref || !ctx.hasUI) return;

    const choice = await ctx.ui.select("Restore code state?", [
      "Yes, restore code to that point",
      "No, keep current code",
    ]);

    if (choice?.startsWith("Yes")) {
      // Stash any current dirty state so apply has a clean target
      await pi.exec("git", ["stash"]).catch(() => {});
      await pi.exec("git", ["stash", "apply", ref]).catch(() => {});
      ctx.ui.notify("Code restored to checkpoint", "info");
    }
  });

  // Clean up in-memory refs after the agent finishes
  pi.on("agent_end", () => {
    checkpoints.clear();
  });
}
