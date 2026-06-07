/**
 * hide-cursor — replace the fake cursor with the system (hardware) cursor
 *
 * The editor renders the cursor as a reverse-video block (\x1b[7m…\x1b[0m)
 * plus a zero-width CURSOR_MARKER used to position the hardware cursor.
 * This extension strips the fake block but keeps CURSOR_MARKER so the
 * terminal's real cursor tracks the caret position.
 */

import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Reverse-video wrap around a single grapheme (or a trailing space at EOL).
// Strip it — the hardware cursor takes its place.
const FAKE_CURSOR_RE = /\x1b\[7m([\s\S])\x1b\[0m/g;

class SystemCursorEditor extends CustomEditor {
	render(width: number): string[] {
		// Keep CURSOR_MARKER in the output so the TUI can position the
		// hardware cursor correctly; only strip the fake reverse-video block.
		return super.render(width).map((line) => line.replace(FAKE_CURSOR_RE, "$1"));
	}
}

export default function (pi: ExtensionAPI) {
	let tuiRef: { setShowHardwareCursor: (enabled: boolean) => void } | undefined;

	// Last-resort restore: runs after all TUI teardown is complete.
	const restoreCursor = () => process.stdout.write("\x1b[?25h");
	process.once("exit", restoreCursor);

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
