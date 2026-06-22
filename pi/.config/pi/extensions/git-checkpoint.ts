import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (!["edit", "write"].includes(event.toolName)) return;
    await ctx
      .runBash(
        "git rev-parse --is-inside-work-tree >/dev/null 2>&1 && " +
          "{ git diff --quiet && git diff --cached --quiet; } || " +
          "git stash push -m 'pi: pre-edit checkpoint' --include-untracked >/dev/null 2>&1"
      )
      .catch(() => {}); // non-fatal — no git repo, clean tree, etc.
  });
}
