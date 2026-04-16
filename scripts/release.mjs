import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const packageJsonPath = resolve(process.cwd(), "package.json");
const rubyVersionPath = resolve(process.cwd(), "lib/imgwire/version.rb");

const command = process.argv[2];

if (!command) {
  printUsageAndExit();
}

if (command === "set-version") {
  const version = process.argv[3];
  setVersion(version);
} else if (command === "verify-tag") {
  const tag = process.argv[3];
  verifyTag(tag);
} else {
  printUsageAndExit();
}

function setVersion(version) {
  if (!isValidSemver(version)) {
    fail(
      `Invalid version "${version}". Expected semver like 0.2.0 or 1.0.0-beta.1.`,
    );
  }

  const packageJson = readJson(packageJsonPath);
  packageJson.version = version;
  writeJson(packageJsonPath, packageJson);

  const rubyVersion = readFileSync(rubyVersionPath, "utf8");
  const currentRubyVersionMatch = rubyVersion.match(/VERSION = ['"]([^'"]+)['"]/);
  if (!currentRubyVersionMatch) {
    fail("Could not parse Imgwire::VERSION in lib/imgwire/version.rb.");
  }

  if (currentRubyVersionMatch[1] === version) {
    console.log(`package.json and lib/imgwire/version.rb are already set to version ${version}.`);
    return;
  }

  const updatedRubyVersion = rubyVersion.replace(
    /VERSION = ['"]([^'"]+)['"]/,
    `VERSION = '${version}'`,
  );

  if (updatedRubyVersion === rubyVersion) {
    fail("Could not update Imgwire::VERSION in lib/imgwire/version.rb.");
  }

  writeFileSync(rubyVersionPath, updatedRubyVersion, "utf8");

  console.log(`Updated package.json and lib/imgwire/version.rb to version ${version}.`);
  console.log("Next steps:");
  console.log("1. Run make ci.");
  console.log("2. Review the diff.");
  console.log("3. Commit and push the version bump.");
  console.log(`4. Tag a release for v${version}.`);
}

function verifyTag(tag) {
  if (!tag) {
    fail("Missing release tag. Usage: yarn release:verify-tag v0.1.0");
  }

  const packageJson = readJson(packageJsonPath);
  const rubyVersion = readRubyVersion();
  const expectedTag = `v${packageJson.version}`;

  if (rubyVersion !== packageJson.version) {
    fail(
      `lib/imgwire/version.rb version ${rubyVersion} does not match package.json version ${packageJson.version}.`,
    );
  }

  if (tag !== expectedTag) {
    fail(
      `Release tag ${tag} does not match package.json version ${packageJson.version}. Expected ${expectedTag}.`,
    );
  }

  console.log(
    `Release tag ${tag} matches package.json and lib/imgwire/version.rb version ${packageJson.version}.`,
  );
}

function readRubyVersion() {
  const rubyVersion = readFileSync(rubyVersionPath, "utf8");
  const match = rubyVersion.match(/VERSION = ['"]([^'"]+)['"]/);

  if (!match) {
    fail("Could not parse Imgwire::VERSION in lib/imgwire/version.rb.");
  }

  return match[1];
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

function writeJson(path, value) {
  writeFileSync(path, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

function isValidSemver(version) {
  return /^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$/.test(
    version,
  );
}

function printUsageAndExit() {
  console.error("Usage:");
  console.error("  yarn release:set-version <version>");
  console.error("  yarn release:verify-tag <tag>");
  process.exit(1);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
