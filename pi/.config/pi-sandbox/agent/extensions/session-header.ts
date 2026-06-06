import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI) return;

		ctx.ui.setHeader(undefined);
		ctx.ui.setWidget(
			"session-title",
			(_tui, theme) => ({
				render(width: number): string[] {
					const name = pi.getSessionName() ?? "unnamed session";
					const text = `${theme.fg("dim", "session: ")}${theme.fg("accent", theme.bold(name))}`;
					const padding = " ".repeat(Math.max(0, width - visibleWidth(text)));
					return [truncateToWidth(padding + text, width)];
				},
				invalidate() {},
			}),
			{ placement: "belowEditor" },
		);
	});
}
