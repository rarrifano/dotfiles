// Move the pi-rewind checkpoint counter from the bottom status strip to the
// first footer line (same line as the cwd / git branch), flush right.
// All other footer lines (token stats, model) are preserved as-is.

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function fmt(n: number): string {
  if (n < 1000) return `${n}`;
  if (n < 10000) return `${(n / 1000).toFixed(1)}k`;
  if (n < 1_000_000) return `${Math.round(n / 1000)}k`;
  if (n < 10_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  return `${Math.round(n / 1_000_000)}M`;
}

function sanitize(text: string): string {
  return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

function formatCwd(cwd: string): string {
  const home = process.env.HOME ?? process.env.USERPROFILE ?? "";
  if (!home) return cwd;
  if (cwd === home) return "~";
  if (cwd.startsWith(home + "/")) return "~" + cwd.slice(home.length);
  return cwd;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const disposeBranch = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: disposeBranch,
        invalidate() {},
        render(width: number): string[] {
          const branch = footerData.getGitBranch();
          const statuses = footerData.getExtensionStatuses();
          // Strip the leading "◆ " glyph that pi-rewind prepends, keep only the count text.
          const rawRewind = statuses.get("rewind") ?? "";
          const rewindStatus = rawRewind.replace(/\x1b\[[\d;]*m/g, "").replace(/^◆\s*/, "").trim();

          // Line 1: cwd (branch) [session] and rewind checkpoint count flush-right
          let pwd = formatCwd(ctx.cwd ?? "");
          if (branch) pwd += ` (${branch})`;

          const sessionName = ctx.sessionManager.getSessionName?.();
          if (sessionName) pwd += ` • ${sessionName}`;

          const left1 = theme.fg("dim", pwd);
          const right1 = rewindStatus ? theme.fg("dim", rewindStatus) : "";

          let pwdLine: string;
          if (!right1) {
            pwdLine = truncateToWidth(left1, width, theme.fg("dim", "..."));
          } else {
            const gap = width - visibleWidth(left1) - visibleWidth(right1);
            const pad = " ".repeat(Math.max(1, gap));
            pwdLine = truncateToWidth(left1 + pad + right1, width, theme.fg("dim", "..."));
          }

          // Line 2: token stats + model (replicate default footer)
          let totalInput = 0, totalOutput = 0, totalCacheRead = 0,
              totalCacheWrite = 0, totalCost = 0;
          let latestCacheHitRate: number | undefined;

          for (const entry of ctx.sessionManager.getEntries()) {
            if (entry.type === "message" && entry.message.role === "assistant") {
              const m = entry.message as any;
              totalInput += m.usage?.input ?? 0;
              totalOutput += m.usage?.output ?? 0;
              totalCacheRead += m.usage?.cacheRead ?? 0;
              totalCacheWrite += m.usage?.cacheWrite ?? 0;
              totalCost += m.usage?.cost?.total ?? 0;
              const latestPrompt = (m.usage?.input ?? 0) + (m.usage?.cacheRead ?? 0) + (m.usage?.cacheWrite ?? 0);
              if (latestPrompt > 0)
                latestCacheHitRate = ((m.usage?.cacheRead ?? 0) / latestPrompt) * 100;
            }
          }

          const statsParts: string[] = [];
          if (totalInput) statsParts.push(`↑${fmt(totalInput)}`);
          if (totalOutput) statsParts.push(`↓${fmt(totalOutput)}`);
          if (totalCacheRead) statsParts.push(`R${fmt(totalCacheRead)}`);
          if (totalCacheWrite) statsParts.push(`W${fmt(totalCacheWrite)}`);
          if ((totalCacheRead > 0 || totalCacheWrite > 0) && latestCacheHitRate !== undefined)
            statsParts.push(`CH${latestCacheHitRate.toFixed(1)}%`);
          if (totalCost) statsParts.push(`$${totalCost.toFixed(3)}`);

          const statsLeft = statsParts.join(" ");
          const model = (ctx as any).model;
          const modelName = model?.id ?? "no-model";
          const thinkingLevel = ctx.getThinkingLevel?.() ?? "off";
          const modelRight = model?.reasoning
            ? `${modelName} • ${thinkingLevel === "off" ? "thinking off" : thinkingLevel}`
            : modelName;
          const statsLeftW = visibleWidth(statsLeft);
          const modelRightW = visibleWidth(modelRight);
          const minPad = 2;

          let statsLine: string;
          if (statsLeftW + minPad + modelRightW <= width) {
            const padding = " ".repeat(width - statsLeftW - modelRightW);
            statsLine = statsLeft + padding + modelRight;
          } else {
            const avail = width - statsLeftW - minPad;
            if (avail > 0) {
              const trunc = truncateToWidth(modelRight, avail, "");
              const padding = " ".repeat(Math.max(0, width - statsLeftW - visibleWidth(trunc)));
              statsLine = statsLeft + padding + trunc;
            } else {
              statsLine = truncateToWidth(statsLeft, width);
            }
          }
          const dimStatsLeft = theme.fg("dim", statsLeft);
          const remainder = statsLine.slice(statsLeft.length);
          const statsLineStyled = dimStatsLeft + theme.fg("dim", remainder);

          const lines = [pwdLine, statsLineStyled];

          // Line 3: remaining extension statuses (everything except rewind)
          const otherStatuses = Array.from(statuses.entries())
            .filter(([key]) => key !== "rewind")
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([, text]) => sanitize(text));

          if (otherStatuses.length > 0) {
            const statusLine = otherStatuses.join(" ");
            lines.push(truncateToWidth(statusLine, width, theme.fg("dim", "...")));
          }

          return lines;
        },
      };
    });
  });
}
