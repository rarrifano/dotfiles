// Replace the fake reverse-video cursor block with the system cursor.
// CURSOR_MARKER is preserved so the TUI can still position the hardware cursor.

import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const FAKE_CURSOR_RE = /\x1b\[7m([\s\S])\x1b\[0m/g;

class SystemCursorEditor extends CustomEditor {
	render(width: number): string[] {
		return super.render(width).map((line) => line.replace(FAKE_CURSOR_RE, "$1"));
	}
}

export default function (pi: ExtensionAPI) {
	let tuiRef: { setShowHardwareCursor: (enabled: boolean) => void } | undefined;

	process.once("exit", () => process.stdout.write("\x1b[?25h"));

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		ctx.ui.setEditorComponent((tui, theme, kb) => {
			tuiRef = tui;
			tui.setShowHardwareCursor(true);
			return new SystemCursorEditor(tui, theme, kb);
		});
	});

	pi.on("session_shutdown", () => {
		tuiRef?.setShowHardwareCursor(false);
		tuiRef = undefined;
	});
}
