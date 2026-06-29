import { execFileSync } from "node:child_process";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, describe, expect, it } from "vitest";

const tempRoots: string[] = [];

afterEach(() => {
  while (tempRoots.length > 0) {
    const tempRoot = tempRoots.pop();
    if (tempRoot) {
      rmSync(tempRoot, { force: true, recursive: true });
    }
  }
});

describe("frontend boundary lint", () => {
  it("allows valid presentation-to-application imports", () => {
    const tempRoot = createFixtureProject({
      "monitoring-workspace/frontend/src/presentation/screen.tsx":
        'import { useDashboard } from "../application/use-dashboard.js";\nexport const screen = useDashboard;\n',
    });

    expect(() => runBiomeLint(tempRoot, ["monitoring-workspace/frontend/src/presentation/screen.tsx"])).not.toThrow();
  });

  it("rejects forbidden presentation-to-infrastructure imports", () => {
    const tempRoot = createFixtureProject({
      "monitoring-workspace/frontend/src/presentation/screen.tsx":
        'import { DashboardClient } from "../infrastructure/api/dashboard-client.js";\nexport const screen = DashboardClient;\n',
    });

    expect(() => runBiomeLint(tempRoot, ["monitoring-workspace/frontend/src/presentation/screen.tsx"])).toThrow(
      /Frontend presentation layer may only import presentation, application, and domain code./,
    );
  });
});

function createFixtureProject(files: Record<string, string>): string {
  const tempRoot = mkdtempSync(join(tmpdir(), "cicada-frontend-boundaries-"));
  tempRoots.push(tempRoot);

  const configPath = join(process.cwd(), "../biome.json");
  const projectConfigPath = join(tempRoot, "application", "biome.json");
  const appRoot = join(tempRoot, "application");

  mkdirSync(join(tempRoot, "application"), { recursive: true });
  writeFileSync(projectConfigPath, readFileSync(configPath, "utf8"));

  for (const [relativePath, content] of Object.entries(files)) {
    const absolutePath = join(appRoot, relativePath);
    const directory = absolutePath.slice(0, absolutePath.lastIndexOf("/"));
    mkdirSync(directory, { recursive: true });
    writeFileSync(absolutePath, content);
  }

  return appRoot;
}

function runBiomeLint(appRoot: string, relativePaths: string[]): string {
  return execFileSync(
    "npm",
    [
      "exec",
      "--yes",
      "--package",
      "@biomejs/biome@2.5.0",
      "--",
      "biome",
      "lint",
      "--config-path",
      join(appRoot, "biome.json"),
      ...relativePaths.map((relativePath) => join(appRoot, relativePath)),
    ],
    {
      encoding: "utf8",
      stdio: "pipe",
    },
  );
}
