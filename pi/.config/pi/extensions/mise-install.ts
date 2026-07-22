/**
 * Auto-installs mise tools when a mise config file is present in the project.
 * Runs once per session start, silently on success, notifies on failure.
 */

import { execFile } from "node:child_process";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const exec = promisify(execFile);

const MISE_CONFIG_FILES = [
  "mise.toml",
  ".mise.toml",
  ".mise/config.toml",
  ".tool-versions",
];

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    const hasMiseConfig = MISE_CONFIG_FILES.some((f) =>
      existsSync(join(ctx.cwd, f))
    );

    if (!hasMiseConfig) return;

    try {
      await exec("mise", ["trust", "--all"], { cwd: ctx.cwd });
      await exec("mise", ["install", "--quiet"], { cwd: ctx.cwd });
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      ctx.ui.notify(`mise install failed: ${msg}`, "error");
    }
  });
}
