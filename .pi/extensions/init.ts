import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { promises as fs } from "node:fs";
import path from "node:path";

const DEFAULT_MAX_DEPTH = 4;
const MAX_DEPTH = 6;
const MAX_ENTRIES_PER_DIR = 16;
const MAX_FILES_PER_DIR = 10;
const IMPORTANT_PATHS_SECTION = /^##\s+Important paths\s*$/i;
const SECTION_HEADER = /^##\s+/;
const EXCLUDED_DIRS = new Set([
	".git",
	"node_modules",
	"dist",
	"build",
	"coverage",
	".next",
	".turbo",
	".cache",
]);
const ALWAYS_INCLUDE_FILES = new Set([
	"AGENTS.md",
	"README.md",
	"package.json",
	"tsconfig.json",
	"go.mod",
	"Cargo.toml",
	"pyproject.toml",
	"Makefile",
	"Dockerfile",
	"docker-compose.yml",
	"docker-compose.yaml",
]);
const INTERESTING_EXTENSIONS = new Set([
	".ts",
	".tsx",
	".js",
	".jsx",
	".json",
	".lua",
	".md",
	".sh",
	".yaml",
	".yml",
	".toml",
	".tf",
	".go",
	".py",
	".rs",
]);

type TreeState = {
	truncated: boolean;
};

function parseDepth(args: string): number | undefined {
	const trimmed = args.trim();
	if (!trimmed) return DEFAULT_MAX_DEPTH;

	const depth = Number.parseInt(trimmed, 10);
	if (!Number.isFinite(depth) || depth < 1 || depth > MAX_DEPTH) {
		return undefined;
	}

	return depth;
}

function sortNames(a: { name: string }, b: { name: string }): number {
	return a.name.localeCompare(b.name, undefined, { numeric: true, sensitivity: "base" });
}

function shouldIncludeFile(name: string, depth: number): boolean {
	if (ALWAYS_INCLUDE_FILES.has(name)) return true;
	if (name.startsWith(".")) return depth <= 1;
	if (depth <= 1) return true;
	return INTERESTING_EXTENSIONS.has(path.extname(name));
}

async function readDirSafe(dirPath: string) {
	try {
		return await fs.readdir(dirPath, { withFileTypes: true });
	} catch {
		return [];
	}
}

async function extractImportantPaths(cwd: string): Promise<string[]> {
	const agentsPath = path.join(cwd, "AGENTS.md");
	let content = "";

	try {
		content = await fs.readFile(agentsPath, "utf8");
	} catch {
		return [];
	}

	const lines = content.split(/\r?\n/);
	const start = lines.findIndex((line) => IMPORTANT_PATHS_SECTION.test(line.trim()));
	if (start === -1) return [];

	const paths: string[] = [];
	for (let index = start + 1; index < lines.length; index += 1) {
		const line = lines[index].trim();
		if (SECTION_HEADER.test(line)) break;
		const match = line.match(/^[-*]\s+`?([^`]+?)`?\s*$/);
		if (match) {
			const relativePath = match[1];
			try {
				await fs.access(path.join(cwd, relativePath));
				paths.push(relativePath);
			} catch {
				// Skip stale paths from docs.
			}
		}
	}

	return paths;
}

async function buildTreeLines(
	currentPath: string,
	depth: number,
	maxDepth: number,
	state: TreeState,
): Promise<string[]> {
	if (depth > maxDepth) {
		state.truncated = true;
		return [];
	}

	const entries = await readDirSafe(currentPath);
	const excludedDirectories = entries.filter((entry) => entry.isDirectory() && EXCLUDED_DIRS.has(entry.name)).length;
	const directories = entries
		.filter((entry) => entry.isDirectory() && !EXCLUDED_DIRS.has(entry.name))
		.sort(sortNames)
		.slice(0, MAX_ENTRIES_PER_DIR);
	const visibleFiles = entries
		.filter((entry) => entry.isFile() && shouldIncludeFile(entry.name, depth))
		.sort(sortNames)
		.slice(0, MAX_FILES_PER_DIR);

	const hiddenCount = Math.max(0, entries.length - excludedDirectories - directories.length - visibleFiles.length);
	const indent = "  ".repeat(depth);
	const lines: string[] = [];

	for (const directory of directories) {
		const directoryPath = path.join(currentPath, directory.name);
		lines.push(`${indent}- ${directory.name}/`);
		lines.push(...(await buildTreeLines(directoryPath, depth + 1, maxDepth, state)));
	}

	for (const file of visibleFiles) {
		lines.push(`${indent}- ${file.name}`);
	}

	if (hiddenCount > 0) {
		lines.push(`${indent}- … (${hiddenCount} more entries omitted)`);
		state.truncated = true;
	}

	return lines;
}

async function buildProjectMap(cwd: string, maxDepth: number): Promise<string> {
	const importantPaths = await extractImportantPaths(cwd);
	const state: TreeState = { truncated: false };
	const treeLines = await buildTreeLines(cwd, 0, maxDepth, state);
	const workspaceName = path.basename(cwd) || cwd;
	const lines = [
		`Project navigation map for ${workspaceName}`,
		"",
		"Use this as a quick guide to the workspace layout before reading or editing files.",
	];

	if (importantPaths.length > 0) {
		lines.push("", "Navigation highlights");
		for (const importantPath of importantPaths) {
			lines.push(`- ${importantPath}`);
		}
	}

	lines.push("", `Folder map (depth ${maxDepth})`);
	lines.push(...treeLines);

	if (state.truncated) {
		lines.push("", "Some entries were omitted to keep the map compact.");
	}

	return lines.join("\n");
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("init", {
		description: "Map the project structure into the session for easier navigation",
		handler: async (args, ctx) => {
			const maxDepth = parseDepth(args);
			if (!maxDepth) {
				ctx.ui.notify(`Usage: /init [depth 1-${MAX_DEPTH}]`, "warning");
				return;
			}

			const projectMap = await buildProjectMap(ctx.cwd, maxDepth);
			pi.sendMessage({
				customType: "project-map",
				content: projectMap,
				display: true,
				details: {
					cwd: ctx.cwd,
					maxDepth,
					generatedAt: Date.now(),
				},
			});
			ctx.ui.notify(`Added project map to the session (depth ${maxDepth})`, "success");
		},
	});
}
