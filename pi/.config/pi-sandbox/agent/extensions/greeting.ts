/**
 * Greeting Extension
 *
 * Sends a warm opening message from Ferri-chan on fresh startup.
 * Rate-limited to once every 3 hours via a timestamp file.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

const COOLDOWN_MS = 3 * 60 * 60 * 1000; // 3 hours
const STAMP_FILE = path.join(os.homedir(), ".ferri-greeting-last");

function shouldGreet(): boolean {
	try {
		const raw = fs.readFileSync(STAMP_FILE, "utf8").trim();
		const last = parseInt(raw, 10);
		if (!isNaN(last) && Date.now() - last < COOLDOWN_MS) return false;
	} catch {
		// file missing or unreadable — greet
	}
	return true;
}

function markGreeted(): void {
	try {
		fs.writeFileSync(STAMP_FILE, String(Date.now()), "utf8");
	} catch {
		// best-effort
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (event, ctx) => {
		if (event.reason === "startup" && ctx.isIdle() && shouldGreet()) {
			markGreeted();
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
