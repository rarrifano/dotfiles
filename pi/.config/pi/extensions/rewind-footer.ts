import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function fmt(n: number): string {
  if (n < 1000) return `${n}`;
  if (n < 10000) return `${(n / 1000).toFixed(1)}k`;
  if (n < 1_000_000) return `${Math.round(n / 1000)}k`;
  if (n < 10_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  return `${Math.round(n / 1_000_000)}M`;
}

function formatCwd(cwd: string): string {
  const home = process.env.HOME ?? process.env.USERPROFILE ?? "";
  if (!home) return cwd;
  if (cwd === home) return "~";
  if (cwd.startsWith(home + "/")) return "~" + cwd.slice(home.length);
  return cwd;
}

function stripAnsi(text: string): string {
  return text.replace(/\x1b\[[\d;]*m/g, "");
}

function spread(left: string, right: string, width: number): string {
  if (!right) return truncateToWidth(left, width);
  const gap = Math.max(1, width - visibleWidth(left) - visibleWidth(right));
  return truncateToWidth(left + " ".repeat(gap) + right, width);
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const disposeBranch = footerData.onBranchChange(() => tui.requestRender());

      function renderCwdLine(width: number): string {
        const statuses = footerData.getExtensionStatuses();
        const rewindStatus = stripAnsi(statuses.get("rewind") ?? "")
          .replace(/^◆\s*/, "")
          .trim();

        let pwd = formatCwd(ctx.cwd ?? "");
        const branch = footerData.getGitBranch();
        if (branch) pwd += ` (${branch})`;
        const sessionName = ctx.sessionManager.getSessionName?.();
        if (sessionName) pwd += ` • ${sessionName}`;

        return spread(
          theme.fg("dim", pwd),
          rewindStatus ? theme.fg("dim", rewindStatus) : "",
          width,
        );
      }

      function renderStatsLine(width: number): string {
        let totalInput = 0, totalOutput = 0, totalCacheRead = 0,
            totalCacheWrite = 0, totalCost = 0;
        let latestCacheHitRate: number | undefined;

        for (const entry of ctx.sessionManager.getEntries()) {
          if (entry.type !== "message" || entry.message.role !== "assistant") continue;
          const m = entry.message as any;
          totalInput += m.usage?.input ?? 0;
          totalOutput += m.usage?.output ?? 0;
          totalCacheRead += m.usage?.cacheRead ?? 0;
          totalCacheWrite += m.usage?.cacheWrite ?? 0;
          totalCost += m.usage?.cost?.total ?? 0;
          const promptTokens = (m.usage?.input ?? 0) + (m.usage?.cacheRead ?? 0) + (m.usage?.cacheWrite ?? 0);
          if (promptTokens > 0) latestCacheHitRate = (m.usage?.cacheRead ?? 0) / promptTokens * 100;
        }

        const parts: string[] = [];
        if (totalInput) parts.push(`↑${fmt(totalInput)}`);
        if (totalOutput) parts.push(`↓${fmt(totalOutput)}`);
        if (totalCacheRead) parts.push(`R${fmt(totalCacheRead)}`);
        if (totalCacheWrite) parts.push(`W${fmt(totalCacheWrite)}`);
        if ((totalCacheRead > 0 || totalCacheWrite > 0) && latestCacheHitRate !== undefined)
          parts.push(`CH${latestCacheHitRate.toFixed(1)}%`);
        if (totalCost) parts.push(`$${totalCost.toFixed(3)}`);

        const model = (ctx as any).model;
        const modelName = model?.id ?? "no-model";
        const thinkingLevel = ctx.getThinkingLevel?.() ?? "off";
        const modelLabel = model?.reasoning
          ? `${modelName} • ${thinkingLevel === "off" ? "thinking off" : thinkingLevel}`
          : modelName;

        return theme.fg("dim", spread(parts.join(" "), modelLabel, width));
      }

      function renderStatusLine(width: number): string | null {
        const statuses = footerData.getExtensionStatuses();
        const others = Array.from(statuses.entries())
          .filter(([key]) => key !== "rewind")
          .sort(([a], [b]) => a.localeCompare(b))
          .map(([, text]) => text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim());

        if (others.length === 0) return null;
        return truncateToWidth(others.join(" "), width);
      }

      return {
        dispose: disposeBranch,
        invalidate() {},
        render(width: number): string[] {
          const lines = [renderCwdLine(width), renderStatsLine(width)];
          const statusLine = renderStatusLine(width);
          if (statusLine !== null) lines.push(statusLine);
          return lines;
        },
      };
    });
  });
}
