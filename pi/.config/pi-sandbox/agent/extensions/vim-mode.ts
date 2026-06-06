/**
 * Vim mode for pi's editor.
 *
 * - Escape: insert -> normal mode
 * - i: enter insert mode
 * - a: move right, then enter insert mode
 * - h/j/k/l: move left/down/up/right
 * - 0/$: line start/end
 * - x: delete character under cursor
 */

import { CustomEditor, type ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { matchesKey, truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

const NORMAL_KEYS: Record<string, string | null> = {
	h: "\x1b[D",
	j: "\x1b[B",
	k: "\x1b[A",
	l: "\x1b[C",
	"0": "\x01",
	$: "\x05",
	x: "\x1b[3~",
	i: null,
	a: null,
};

class VimModeEditor extends CustomEditor {
	private mode: "normal" | "insert" = "insert";

	handleInput(data: string): void {
		if (matchesKey(data, "escape")) {
			if (this.mode === "insert") {
				this.mode = "normal";
				this.tui.requestRender();
				return;
			}

			super.handleInput(data);
			return;
		}

		if (this.mode === "insert") {
			super.handleInput(data);
			return;
		}

		if (data in NORMAL_KEYS) {
			const seq = NORMAL_KEYS[data];
			if (data === "i") {
				this.mode = "insert";
				this.tui.requestRender();
				return;
			}

			if (data === "a") {
				this.mode = "insert";
				super.handleInput("\x1b[C");
				this.tui.requestRender();
				return;
			}

			if (seq) {
				super.handleInput(seq);
			}
			return;
		}

		if (data.length === 1 && data.charCodeAt(0) >= 32) return;
		super.handleInput(data);
	}

	render(width: number): string[] {
		const lines = super.render(width);
		if (lines.length === 0) return lines;

		const label = this.mode === "normal" ? " NORMAL " : " INSERT ";
		const last = lines.length - 1;
		if (visibleWidth(lines[last]!) >= label.length) {
			lines[last] = truncateToWidth(lines[last]!, width - label.length, "") + label;
		}
		return lines;
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setEditorComponent((tui, theme, keybindings) =>
			new VimModeEditor(tui, theme, keybindings),
		);
	});
}
