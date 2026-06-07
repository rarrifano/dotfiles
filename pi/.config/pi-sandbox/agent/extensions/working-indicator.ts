/**
 * Working Indicator Extension
 *
 * Implements a premium, Claude Code-style status line!
 * It cycles through custom, adorable Ferri-chan action verbs with a
 * smooth, animated dot loader (. .. ...), all formatted beautifully
 * in your cozy Gruvbox theme colors! 🐾🌸
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		const labelColor = (text: string) => ctx.ui.theme.fg("accent", text); // Cozy Gruvbox Orange
		const dotColor = (text: string) => ctx.ui.theme.fg("aqua", text);     // Cozy Gruvbox Aqua

		// We will craft a frameset that rotates through verbs AND animates the dots in real-time!
		const verbs = [
			"Purring",
			"Hunting bugs",
			"Tweaking dotfiles",
			"Water healing",
			"Tail wagging",
			"Brewing coffee",
			"Mewing aggressively"
		];

		const frames: string[] = [];

		// For each verb, we generate a smooth dot-loading sequence:
		// "Verb   " -> "Verb.  " -> "Verb.. " -> "Verb..."
		for (const verb of verbs) {
			// Dot states
			const states = [
				{ dots: "   ", label: `🐾 ${verb}` },
				{ dots: ".  ", label: `🐾 ${verb}` },
				{ dots: ".. ", label: `🐾 ${verb}` },
				{ dots: "...", label: `🐾 ${verb}` }
			];

			for (const state of states) {
				// We add each frame multiple times to keep the verb static while the dots animate!
				// Repeating frames gives the dots 2 ticks per cycle, letting the verb linger nicely.
				for (let i = 0; i < 2; i++) {
					frames.push(`${labelColor(state.label)}${dotColor(state.dots)}`);
				}
			}
		}

		ctx.ui.setWorkingIndicator({
			frames: frames,
			intervalMs: 120, // 120ms interval for a perfectly smooth dot tick!
		});
	});
}
