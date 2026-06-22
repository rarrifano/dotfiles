import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "taskwarrior",
    label: "Taskwarrior",
    description:
      "Query and manage Taskwarrior tasks. Use for listing, adding, completing, modifying, and annotating personal GTD tasks.",
    promptSnippet: "Query and manage personal Taskwarrior tasks",
    promptGuidelines: [
      "Use taskwarrior to list, add, complete, or modify tasks when the user asks about their task list, GTD, or what to work on next.",
    ],
    parameters: Type.Object({
      args: Type.String({
        description:
          'Arguments passed directly to the `task` CLI. Examples: "list", "add Buy milk", "42 done", "project:SRE list", "next"',
      }),
    }),

    async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
      const result = await pi.exec("task", params.args.split(" "), {
        signal,
        timeout: 10000,
      });

      const output =
        result.stdout?.trim() || result.stderr?.trim() || "(no output)";

      return {
        content: [{ type: "text", text: output }],
        details: { args: params.args, code: result.code },
      };
    },
  });
}
