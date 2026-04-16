import { rm } from "node:fs/promises";
import { resolve } from "node:path";

import { GENERATED_DIR } from "./_lib/paths.ts";

const GENERATED_ROOT_ENTRIES_TO_REMOVE = new Set([
  ".gitignore",
  ".gitlab-ci.yml",
  ".openapi-generator-ignore",
  ".rspec",
  ".rubocop.yml",
  ".travis.yml",
  "README.md",
  "docs",
  "Gemfile",
  "Rakefile",
  "git_push.sh",
  "imgwire-generated.gemspec",
  "spec",
]);

export async function runPostprocess(options?: {
  generatedDir?: string;
}): Promise<void> {
  const generatedDir = options?.generatedDir ?? GENERATED_DIR;

  for (const name of GENERATED_ROOT_ENTRIES_TO_REMOVE) {
    await rm(resolve(generatedDir, name), { force: true, recursive: true });
  }

  await rm(resolve(generatedDir, ".openapi-generator"), {
    force: true,
    recursive: true,
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  await runPostprocess();
}
