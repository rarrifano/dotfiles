/**
 * confirm-dialog — Auto-guard for dangerous bash commands
 *
 * Intercepts bash commands matching known danger patterns and asks for
 * confirmation in chat before allowing them to proceed.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function confirmDialogExtension(pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;

    const cmd = (event.input as { command?: string }).command ?? "";

    const dangerPatterns = [
      { pattern: /\bgit\s+push\b/i, label: "git push" },
      { pattern: /\brm\s+(-[a-z]*r[a-z]*|-[a-z]*f[a-z]*|--recursive|--force)\b/i, label: "rm (recursive/force)" },
      { pattern: /\bterraform\s+(apply|destroy)\b/i, label: "terraform apply/destroy" },
      { pattern: /\bgit\s+reset\s+--hard\b/i, label: "git reset --hard" },
      { pattern: /\bkubectl\s+(delete|drain)\b/i, label: "kubectl delete/drain" },
      { pattern: /\bdocker\s+(rm|rmi|system\s+prune)\b/i, label: "docker rm/prune" },
    ];

    const matched = dangerPatterns.find((p) => p.pattern.test(cmd));
    if (!matched) return;

    const approved = await ctx.ui.confirm(`Approve: ${matched.label}`, cmd);

    if (!approved) {
      return { block: true, reason: `Blocked — ${matched.label} rejected by user.` };
    }
  });
}
