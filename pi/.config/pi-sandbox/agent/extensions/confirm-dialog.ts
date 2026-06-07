/**
 * confirm-dialog — TUI approval dialog
 *
 * Registers a `request_approval` tool the LLM can call whenever it needs
 * explicit user consent before proceeding with a sensitive action.
 * Also auto-intercepts bash commands matching known danger patterns.
 *
 * Usage: the LLM calls `request_approval` with a title and description.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { DynamicBorder } from "@earendil-works/pi-coding-agent";
import { Container, type SelectItem, SelectList, Spacer, Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";

// ---------------------------------------------------------------------------
// Dialog helper
// ---------------------------------------------------------------------------

async function showApprovalDialog(
  ctx: ExtensionContext,
  title: string,
  description: string,
): Promise<boolean> {
  if (ctx.mode !== "tui") {
    return ctx.ui.confirm(title, description);
  }

  const items: SelectItem[] = [
    { value: "yes", label: "Yes, proceed" },
    { value: "no", label: "No, cancel" },
  ];

  const result = await ctx.ui.custom<string | null>(
    (tui, theme, _kb, done) => {
      const container = new Container();

      container.addChild(new DynamicBorder((s) => theme.fg("borderAccent", s)));
      container.addChild(new Text(theme.fg("warning", theme.bold("  Approval Required")), 0, 1));
      container.addChild(new Text(theme.fg("text", theme.bold(`  ${title}`)), 0, 0));
      container.addChild(new Spacer(1));
      container.addChild(new Text(theme.fg("muted", `  ${description}`), 0, 0));
      container.addChild(new Spacer(1));

      const selectList = new SelectList(items, items.length, {
        selectedPrefix: (t) => theme.fg("accent", t),
        selectedText: (t) => theme.fg("accent", t),
      });
      selectList.onSelect = (item) => done(item.value);
      selectList.onCancel = () => done("no");
      container.addChild(selectList);

      container.addChild(
        new Text(theme.fg("dim", "  arrow keys navigate   enter confirm   esc cancel"), 0, 1),
      );
      container.addChild(new DynamicBorder((s) => theme.fg("borderAccent", s)));

      return {
        render: (w: number) => container.render(w),
        invalidate: () => container.invalidate(),
        handleInput: (data: string) => {
          selectList.handleInput(data);
          tui.requestRender();
        },
      };
    },
    {
      overlay: true,
      overlayOptions: {
        width: "60%",
        minWidth: 52,
        maxWidth: 80,
        anchor: "center",
      },
    },
  );

  return result === "yes";
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function confirmDialogExtension(pi: ExtensionAPI) {
  // ── Tool: request_approval ──────────────────────────────────────────────
  pi.registerTool({
    name: "request_approval",
    label: "Request Approval",
    description:
      "Show a confirmation dialog to the user and wait for their decision before proceeding with a sensitive or irreversible action.",
    promptSnippet: "Show a dialog asking the user to approve or reject an action",
    promptGuidelines: [
      "Use request_approval before any action requiring explicit consent: destructive operations, irreversible changes, writes to production-like paths, git push, terraform apply/destroy, or anything listed in AGENTS.md as needing approval.",
      "Pass a concise title (the action) and a clear description of exactly what will happen, including which files, commands, or systems are affected.",
      "If request_approval returns 'Rejected', stop immediately — do not perform the action.",
    ],
    parameters: Type.Object({
      title: Type.String({
        description:
          "Short title of the action requiring approval (e.g. 'Delete all migration files')",
      }),
      description: Type.String({
        description:
          "What will happen if the user approves — be specific about paths, commands, and scope.",
      }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const approved = await showApprovalDialog(ctx, params.title, params.description);
      return {
        content: [
          {
            type: "text",
            text: approved
              ? "Approved. You may proceed."
              : "Rejected. Do not proceed with this action.",
          },
        ],
        details: { approved },
      };
    },
  });

  // ── Auto-guard: dangerous bash patterns ─────────────────────────────────
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

    const approved = await showApprovalDialog(ctx, `Approve: ${matched.label}`, cmd);

    if (!approved) {
      return { block: true, reason: `Blocked — ${matched.label} rejected by user.` };
    }
  });
}
