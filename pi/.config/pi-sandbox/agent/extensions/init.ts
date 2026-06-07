/**
 * /init — Generate or update a project-level AGENTS.md
 *
 * Probes the current working directory to detect stack, commands,
 * structure, key files, and patterns, then writes a tight AGENTS.md
 * the agent can rely on in future sessions.
 *
 * Usage: /init
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function exists(p: string): boolean {
  return fs.existsSync(p);
}

function read(p: string): string {
  try {
    return fs.readFileSync(p, "utf8");
  } catch {
    return "";
  }
}

function readJson(p: string): Record<string, unknown> {
  try {
    return JSON.parse(read(p));
  } catch {
    return {};
  }
}

function exec(cmd: string, cwd: string): string {
  try {
    return execSync(cmd, { cwd, encoding: "utf8", stdio: ["pipe", "pipe", "pipe"] }).trim();
  } catch {
    return "";
  }
}

function listDir(p: string): string[] {
  try {
    return fs.readdirSync(p);
  } catch {
    return [];
  }
}

function firstExisting(cwd: string, candidates: string[]): string | undefined {
  return candidates.find((c) => exists(path.join(cwd, c)));
}

// ---------------------------------------------------------------------------
// Probe
// ---------------------------------------------------------------------------

interface ProjectInfo {
  name: string;
  runtime: string;
  packageManager: string | null;
  frameworks: string[];
  testFramework: string | null;
  testPattern: string | null;
  linter: string | null;
  formatter: string | null;
  commands: Array<{ cmd: string; purpose: string }>;
  structure: Array<{ p: string; purpose: string }>;
  keyFiles: Array<{ file: string; note: string }>;
  ci: string | null;
  iac: string | null;
  containerized: boolean;
  composeFile: string | null;
  language: string;
  notes: string[];
}

function probe(cwd: string): ProjectInfo {
  const info: ProjectInfo = {
    name: path.basename(cwd),
    runtime: "unknown",
    packageManager: null,
    frameworks: [],
    testFramework: null,
    testPattern: null,
    linter: null,
    formatter: null,
    commands: [],
    structure: [],
    keyFiles: [],
    ci: null,
    iac: null,
    containerized: false,
    composeFile: null,
    language: "unknown",
    notes: [],
  };

  const top = listDir(cwd);

  // ── Git ──────────────────────────────────────────────────────────────────
  const isGit = exists(path.join(cwd, ".git"));
  if (isGit) {
    const branch = exec("git rev-parse --abbrev-ref HEAD", cwd);
    if (branch) info.notes.push(`Default branch: \`${branch}\``);
    // Detect conventional commits
    const commitlint = firstExisting(cwd, [
      "commitlint.config.js",
      "commitlint.config.ts",
      ".commitlintrc.json",
      ".commitlintrc.yml",
    ]);
    if (commitlint) info.notes.push("Conventional commits enforced (commitlint)");
  }

  // ── Node / JS / TS ───────────────────────────────────────────────────────
  const pkgJsonPath = path.join(cwd, "package.json");
  if (exists(pkgJsonPath)) {
    const pkg = readJson(pkgJsonPath) as {
      name?: string;
      scripts?: Record<string, string>;
      dependencies?: Record<string, string>;
      devDependencies?: Record<string, string>;
    };

    if (pkg.name) info.name = pkg.name;

    // Runtime version
    const nvmrc = firstExisting(cwd, [".nvmrc", ".node-version"]);
    const nodeVer = nvmrc ? read(path.join(cwd, nvmrc)).trim() : exec("node --version", cwd);
    const tsConfig = exists(path.join(cwd, "tsconfig.json"));
    info.language = tsConfig ? "TypeScript" : "JavaScript";
    info.runtime = `Node.js${nodeVer ? ` ${nodeVer.replace(/^v/, "")}` : ""}`;

    // Package manager
    if (exists(path.join(cwd, "pnpm-lock.yaml"))) info.packageManager = "pnpm";
    else if (exists(path.join(cwd, "yarn.lock"))) info.packageManager = "yarn";
    else if (exists(path.join(cwd, "bun.lockb")) || exists(path.join(cwd, "bun.lock")))
      info.packageManager = "bun";
    else if (exists(path.join(cwd, "package-lock.json"))) info.packageManager = "npm";

    const pm = info.packageManager ?? "npm";
    const allDeps = { ...pkg.dependencies, ...pkg.devDependencies };

    // Frameworks
    if (allDeps["next"]) info.frameworks.push("Next.js");
    if (allDeps["nuxt"] || allDeps["nuxt3"]) info.frameworks.push("Nuxt");
    if (allDeps["react"] && !allDeps["next"]) info.frameworks.push("React");
    if (allDeps["vue"] && !allDeps["nuxt"]) info.frameworks.push("Vue");
    if (allDeps["svelte"]) info.frameworks.push("Svelte");
    if (allDeps["express"]) info.frameworks.push("Express");
    if (allDeps["fastify"]) info.frameworks.push("Fastify");
    if (allDeps["hono"]) info.frameworks.push("Hono");
    if (allDeps["nestjs"] || allDeps["@nestjs/core"]) info.frameworks.push("NestJS");

    // Test framework
    if (allDeps["vitest"]) {
      info.testFramework = "Vitest";
      info.testPattern = "*.test.ts / *.spec.ts";
    } else if (allDeps["jest"] || allDeps["@jest/core"]) {
      info.testFramework = "Jest";
      info.testPattern = "*.test.ts / *.spec.ts";
    } else if (allDeps["mocha"]) {
      info.testFramework = "Mocha";
      info.testPattern = "test/*.ts";
    }

    // Linter / formatter
    if (allDeps["eslint"]) info.linter = "ESLint";
    if (allDeps["biome"]) {
      info.linter = "Biome";
      info.formatter = "Biome";
    }
    if (allDeps["prettier"] && !allDeps["biome"]) info.formatter = "Prettier";
    if (allDeps["oxlint"]) info.linter = "OxLint";

    // Scripts → commands
    const scripts = pkg.scripts ?? {};
    const scriptMap: Record<string, string> = {
      dev: "Start dev server",
      start: "Start production server",
      build: "Build for production",
      test: "Run tests",
      "test:watch": "Run tests in watch mode",
      "test:coverage": "Run tests with coverage",
      lint: "Lint source",
      "lint:fix": "Lint and auto-fix",
      format: "Format source",
      typecheck: "Type-check without emitting",
      "type-check": "Type-check without emitting",
      migrate: "Run DB migrations",
      "db:migrate": "Run DB migrations",
      "db:seed": "Seed database",
      generate: "Run codegen",
      prepare: "Prepare (husky / codegen)",
    };
    for (const [script, purpose] of Object.entries(scriptMap)) {
      if (scripts[script]) {
        info.commands.push({ cmd: `${pm} run ${script}`, purpose });
      }
    }

    // Install command
    info.commands.unshift({ cmd: `${pm} install`, purpose: "Install dependencies" });

    // Key files
    if (tsConfig) info.keyFiles.push({ file: "tsconfig.json", note: "TypeScript config" });
    const eslintConfig = firstExisting(cwd, [
      ".eslintrc.json",
      ".eslintrc.js",
      "eslint.config.js",
      "eslint.config.ts",
      ".eslintrc.cjs",
    ]);
    if (eslintConfig) info.keyFiles.push({ file: eslintConfig, note: "ESLint config" });
    const prettierConfig = firstExisting(cwd, [
      ".prettierrc",
      ".prettierrc.json",
      "prettier.config.js",
      ".prettierrc.js",
    ]);
    if (prettierConfig) info.keyFiles.push({ file: prettierConfig, note: "Prettier config" });
    const biomeConfig = firstExisting(cwd, ["biome.json", "biome.jsonc"]);
    if (biomeConfig) info.keyFiles.push({ file: biomeConfig, note: "Biome config" });
  }

  // ── Go ───────────────────────────────────────────────────────────────────
  if (exists(path.join(cwd, "go.mod"))) {
    info.language = "Go";
    const goMod = read(path.join(cwd, "go.mod"));
    const goVer = goMod.match(/^go\s+([\d.]+)/m)?.[1];
    info.runtime = `Go${goVer ? ` ${goVer}` : ""}`;
    info.testFramework = "go test";
    info.testPattern = "*_test.go";
    info.commands.push(
      { cmd: "go build ./...", purpose: "Build all packages" },
      { cmd: "go test ./...", purpose: "Run all tests" },
      { cmd: "go vet ./...", purpose: "Lint" },
      { cmd: "go mod tidy", purpose: "Tidy dependencies" }
    );
    if (exists(path.join(cwd, "Makefile"))) {
      info.keyFiles.push({ file: "Makefile", note: "Build targets" });
    }
    const moduleName = goMod.match(/^module\s+(\S+)/m)?.[1];
    if (moduleName) info.notes.push(`Go module: \`${moduleName}\``);
  }

  // ── Python ───────────────────────────────────────────────────────────────
  const pyProject = exists(path.join(cwd, "pyproject.toml"));
  const reqTxt = exists(path.join(cwd, "requirements.txt"));
  if (pyProject || reqTxt || exists(path.join(cwd, "setup.py"))) {
    info.language = "Python";
    const pyVer = exec("python3 --version", cwd) || exec("python --version", cwd);
    info.runtime = `Python${pyVer ? ` ${pyVer.replace("Python ", "")}` : ""}`;

    if (exists(path.join(cwd, "uv.lock"))) info.packageManager = "uv";
    else if (exists(path.join(cwd, "poetry.lock"))) info.packageManager = "poetry";
    else if (exists(path.join(cwd, "Pipfile"))) info.packageManager = "pipenv";
    else info.packageManager = "pip";

    const pm = info.packageManager;
    const installCmd =
      pm === "uv" ? "uv sync" : pm === "poetry" ? "poetry install" : pm === "pipenv" ? "pipenv install" : "pip install -r requirements.txt";
    info.commands.push({ cmd: installCmd, purpose: "Install dependencies" });

    // Detect test framework from pyproject or presence
    if (exists(path.join(cwd, "pytest.ini")) || exec("grep -r pytest pyproject.toml", cwd)) {
      info.testFramework = "pytest";
      info.testPattern = "test_*.py / *_test.py";
      const testCmd = pm === "uv" ? "uv run pytest" : pm === "poetry" ? "poetry run pytest" : "pytest";
      info.commands.push({ cmd: testCmd, purpose: "Run tests" });
    }

    if (pyProject) info.keyFiles.push({ file: "pyproject.toml", note: "Project config and deps" });
    if (reqTxt) info.keyFiles.push({ file: "requirements.txt", note: "Runtime dependencies" });
    const reqDev = firstExisting(cwd, ["requirements-dev.txt", "requirements.dev.txt"]);
    if (reqDev) info.keyFiles.push({ file: reqDev, note: "Dev dependencies" });
  }

  // ── Rust ─────────────────────────────────────────────────────────────────
  if (exists(path.join(cwd, "Cargo.toml"))) {
    info.language = "Rust";
    info.runtime = "Rust / Cargo";
    info.testFramework = "cargo test";
    info.testPattern = "inline #[test] / tests/";
    info.commands.push(
      { cmd: "cargo build", purpose: "Build" },
      { cmd: "cargo test", purpose: "Run tests" },
      { cmd: "cargo clippy", purpose: "Lint" },
      { cmd: "cargo fmt", purpose: "Format" }
    );
    info.keyFiles.push({ file: "Cargo.toml", note: "Workspace/package manifest" });
  }

  // ── CI ───────────────────────────────────────────────────────────────────
  if (exists(path.join(cwd, ".github/workflows"))) {
    const wfs = listDir(path.join(cwd, ".github/workflows")).filter((f) => f.endsWith(".yml") || f.endsWith(".yaml"));
    info.ci = `GitHub Actions (${wfs.length} workflow${wfs.length !== 1 ? "s" : ""})`;
    info.keyFiles.push({ file: ".github/workflows/", note: "CI/CD pipelines" });
  } else if (exists(path.join(cwd, ".gitlab-ci.yml"))) {
    info.ci = "GitLab CI";
    info.keyFiles.push({ file: ".gitlab-ci.yml", note: "CI/CD pipeline" });
  } else if (exists(path.join(cwd, "Jenkinsfile"))) {
    info.ci = "Jenkins";
    info.keyFiles.push({ file: "Jenkinsfile", note: "Pipeline definition" });
  } else if (exists(path.join(cwd, ".circleci/config.yml"))) {
    info.ci = "CircleCI";
    info.keyFiles.push({ file: ".circleci/config.yml", note: "CI pipeline" });
  }

  // ── IaC ──────────────────────────────────────────────────────────────────
  const tfDir = firstExisting(cwd, ["terraform", "infra", "tf"]);
  if (tfDir && listDir(path.join(cwd, tfDir)).some((f) => f.endsWith(".tf"))) {
    info.iac = `Terraform (${tfDir}/)`;;
    info.keyFiles.push({ file: `${tfDir}/`, note: "Terraform root" });
    info.notes.push("Never run `terraform apply` — that's the user's call");
  } else if (exists(path.join(cwd, "Pulumi.yaml"))) {
    info.iac = "Pulumi";
    info.keyFiles.push({ file: "Pulumi.yaml", note: "Pulumi project config" });
  } else if (exists(path.join(cwd, "ansible.cfg")) || exists(path.join(cwd, "playbook.yml"))) {
    info.iac = "Ansible";
  } else if (exists(path.join(cwd, "cdk.json"))) {
    info.iac = "AWS CDK";
    info.keyFiles.push({ file: "cdk.json", note: "CDK project config" });
  }

  // ── Container ────────────────────────────────────────────────────────────
  if (exists(path.join(cwd, "Dockerfile"))) {
    info.containerized = true;
    info.keyFiles.push({ file: "Dockerfile", note: "Container image definition" });
  }
  const compose = firstExisting(cwd, [
    "docker-compose.yml",
    "docker-compose.yaml",
    "compose.yml",
    "compose.yaml",
  ]);
  if (compose) {
    info.composeFile = compose;
    info.keyFiles.push({ file: compose, note: "Local service orchestration" });
  }

  // ── Makefile (generic) ───────────────────────────────────────────────────
  if (exists(path.join(cwd, "Makefile")) && info.language !== "Go") {
    // Extract targets with comments
    const targets = exec("make -qp 2>/dev/null | grep -E '^[a-zA-Z_-]+:' | head -20", cwd)
      .split("\n")
      .map((l) => l.replace(/:.*/, "").trim())
      .filter(Boolean)
      .slice(0, 10);
    if (targets.length) {
      info.keyFiles.push({ file: "Makefile", note: `Build targets: ${targets.join(", ")}` });
    }
  }

  // ── Env vars ─────────────────────────────────────────────────────────────
  const envExample = firstExisting(cwd, [".env.example", ".env.sample", ".env.template"]);
  if (envExample) {
    info.keyFiles.push({ file: envExample, note: "Required environment variables (template)" });
    info.notes.push("Copy `.env.example` → `.env` and fill in values before running");
  }

  // ── Directory structure ───────────────────────────────────────────────────
  const structureMap: Record<string, string> = {
    src: "Application source",
    lib: "Shared libraries / utilities",
    app: "Application source (Next.js / NestJS)",
    pages: "Pages (Next.js pages router)",
    components: "UI components",
    hooks: "React hooks",
    utils: "Utility functions",
    helpers: "Helper functions",
    services: "Service layer / business logic",
    controllers: "HTTP controllers",
    routes: "Route definitions",
    middleware: "Middleware",
    models: "Data models / schemas",
    db: "Database layer",
    migrations: "Database migrations",
    scripts: "One-off / maintenance scripts",
    bin: "CLI entry points",
    cmd: "CLI entry points (Go convention)",
    internal: "Internal packages (Go convention)",
    pkg: "Public packages (Go convention)",
    api: "API handlers / OpenAPI spec",
    proto: "Protobuf definitions",
    test: "Tests",
    tests: "Tests",
    __tests__: "Tests",
    spec: "Test specs",
    docs: "Documentation",
    config: "Configuration files",
    deploy: "Deployment manifests",
    k8s: "Kubernetes manifests",
    charts: "Helm charts",
    terraform: "Terraform modules",
    infra: "Infrastructure code",
    tf: "Terraform modules",
    ".github": "GitHub config and workflows",
  };

  for (const dir of top) {
    if (structureMap[dir] && fs.statSync(path.join(cwd, dir)).isDirectory()) {
      info.structure.push({ p: `${dir}/`, purpose: structureMap[dir] });
    }
  }

  // ── package.json key files ───────────────────────────────────────────────
  info.keyFiles.unshift({ file: "package.json", note: "Scripts, dependencies, project metadata" });

  // Remove duplicates (package.json may have been added twice)
  const seen = new Set<string>();
  info.keyFiles = info.keyFiles.filter((kf) => {
    if (seen.has(kf.file)) return false;
    seen.add(kf.file);
    return true;
  });

  return info;
}

// ---------------------------------------------------------------------------
// Render AGENTS.md
// ---------------------------------------------------------------------------

function renderAgentsMd(info: ProjectInfo): string {
  const lines: string[] = [];

  lines.push(`# Project: ${info.name}`);
  lines.push("");

  // Stack
  lines.push("## Stack");
  lines.push("");
  lines.push(`- **Language:** ${info.language}`);
  lines.push(`- **Runtime:** ${info.runtime}`);
  if (info.packageManager) lines.push(`- **Package manager:** ${info.packageManager}`);
  if (info.frameworks.length) lines.push(`- **Frameworks:** ${info.frameworks.join(", ")}`);
  if (info.testFramework) lines.push(`- **Tests:** ${info.testFramework}${info.testPattern ? ` — \`${info.testPattern}\`` : ""}`);
  if (info.linter) lines.push(`- **Linter:** ${info.linter}`);
  if (info.formatter && info.formatter !== info.linter) lines.push(`- **Formatter:** ${info.formatter}`);
  if (info.ci) lines.push(`- **CI:** ${info.ci}`);
  if (info.iac) lines.push(`- **IaC:** ${info.iac}`);
  if (info.containerized || info.composeFile) {
    const parts = [];
    if (info.containerized) parts.push("Docker");
    if (info.composeFile) parts.push(`Compose (\`${info.composeFile}\`)`);
    lines.push(`- **Container:** ${parts.join(", ")}`);
  }
  lines.push("");

  // Commands
  if (info.commands.length) {
    lines.push("## Commands");
    lines.push("");
    lines.push("| Command | Purpose |");
    lines.push("|---------|---------|");
    for (const { cmd, purpose } of info.commands) {
      lines.push(`| \`${cmd}\` | ${purpose} |`);
    }
    lines.push("");
  }

  // Structure
  if (info.structure.length) {
    lines.push("## Structure");
    lines.push("");
    lines.push("| Path | Purpose |");
    lines.push("|------|---------|");
    for (const { p, purpose } of info.structure) {
      lines.push(`| \`${p}\` | ${purpose} |`);
    }
    lines.push("");
  }

  // Key files
  if (info.keyFiles.length) {
    lines.push("## Key Files");
    lines.push("");
    for (const { file, note } of info.keyFiles) {
      lines.push(`- \`${file}\` — ${note}`);
    }
    lines.push("");
  }

  // Notes
  if (info.notes.length) {
    lines.push("## Notes");
    lines.push("");
    for (const note of info.notes) {
      lines.push(`- ${note}`);
    }
    lines.push("");
  }

  return lines.join("\n");
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function initExtension(pi: ExtensionAPI) {
  pi.registerCommand("init", {
    description: "Generate or update AGENTS.md for this project",
    handler: async (_args, ctx) => {
      const cwd = ctx.cwd;
      const outPath = path.join(cwd, "AGENTS.md");

      ctx.ui.setStatus("init", "Probing project...");

      let info: ProjectInfo;
      try {
        info = probe(cwd);
      } catch (err) {
        ctx.ui.notify(`Probe failed: ${String(err)}`, "error");
        ctx.ui.setStatus("init", "");
        return;
      }

      ctx.ui.setStatus("init", "");

      const content = renderAgentsMd(info);

      // If file exists, show diff summary and confirm
      if (exists(outPath)) {
        const existing = read(outPath);
        if (existing === content) {
          ctx.ui.notify("AGENTS.md is already up to date.", "info");
          return;
        }
        const ok = await ctx.ui.confirm(
          "AGENTS.md already exists",
          `Overwrite ${outPath} with updated content?`
        );
        if (!ok) {
          ctx.ui.notify("Aborted — AGENTS.md unchanged.", "info");
          return;
        }
      }

      try {
        fs.writeFileSync(outPath, content, "utf8");
        ctx.ui.notify(`AGENTS.md written → ${outPath}`, "info");
      } catch (err) {
        ctx.ui.notify(`Write failed: ${String(err)}`, "error");
      }
    },
  });
}
