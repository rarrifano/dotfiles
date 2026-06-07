/**
 * Greeting Extension
 *
 * Sends a warm opening message from Ferri-chan on fresh startup.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (event, ctx) => {
		if (event.reason === "startup" && ctx.isIdle()) {
			pi.sendMessage(
				{
					customType: "greeting",
					content:
						"greet arri with a short, warm opening message — you're Ferri-chan, Arri just opened pi",
					display: false,
				},
				{ triggerTurn: true }
			);
		}
	});
}
