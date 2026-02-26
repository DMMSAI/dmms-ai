import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { describe, expect, it } from "vitest";
import {
  resolveDefaultConfigCandidates,
  resolveConfigPathCandidate,
  resolveConfigPath,
  resolveOAuthDir,
  resolveOAuthPath,
  resolveStateDir,
} from "./paths.js";

describe("oauth paths", () => {
  it("prefers DRYADS_AI_OAUTH_DIR over DRYADS_AI_STATE_DIR", () => {
    const env = {
      DRYADS_AI_OAUTH_DIR: "/custom/oauth",
      DRYADS_AI_STATE_DIR: "/custom/state",
    } as NodeJS.ProcessEnv;

    expect(resolveOAuthDir(env, "/custom/state")).toBe(path.resolve("/custom/oauth"));
    expect(resolveOAuthPath(env, "/custom/state")).toBe(
      path.join(path.resolve("/custom/oauth"), "oauth.json"),
    );
  });

  it("derives oauth path from DRYADS_AI_STATE_DIR when unset", () => {
    const env = {
      DRYADS_AI_STATE_DIR: "/custom/state",
    } as NodeJS.ProcessEnv;

    expect(resolveOAuthDir(env, "/custom/state")).toBe(path.join("/custom/state", "credentials"));
    expect(resolveOAuthPath(env, "/custom/state")).toBe(
      path.join("/custom/state", "credentials", "oauth.json"),
    );
  });
});

describe("state + config path candidates", () => {
  it("uses DRYADS_AI_STATE_DIR when set", () => {
    const env = {
      DRYADS_AI_STATE_DIR: "/new/state",
    } as NodeJS.ProcessEnv;

    expect(resolveStateDir(env, () => "/home/test")).toBe(path.resolve("/new/state"));
  });

  it("uses DRYADS_AI_HOME for default state/config locations", () => {
    const env = {
      DRYADS_AI_HOME: "/srv/dryads-ai-home",
    } as NodeJS.ProcessEnv;

    const resolvedHome = path.resolve("/srv/dryads-ai-home");
    expect(resolveStateDir(env)).toBe(path.join(resolvedHome, ".dryads-ai"));

    const candidates = resolveDefaultConfigCandidates(env);
    expect(candidates[0]).toBe(path.join(resolvedHome, ".dryads-ai", "dryads-ai.json"));
  });

  it("prefers DRYADS_AI_HOME over HOME for default state/config locations", () => {
    const env = {
      DRYADS_AI_HOME: "/srv/dryads-ai-home",
      HOME: "/home/other",
    } as NodeJS.ProcessEnv;

    const resolvedHome = path.resolve("/srv/dryads-ai-home");
    expect(resolveStateDir(env)).toBe(path.join(resolvedHome, ".dryads-ai"));

    const candidates = resolveDefaultConfigCandidates(env);
    expect(candidates[0]).toBe(path.join(resolvedHome, ".dryads-ai", "dryads-ai.json"));
  });

  it("orders default config candidates in a stable order", () => {
    const home = "/home/test";
    const resolvedHome = path.resolve(home);
    const candidates = resolveDefaultConfigCandidates({} as NodeJS.ProcessEnv, () => home);
    const expected = [
      path.join(resolvedHome, ".dryads-ai", "dryads-ai.json"),
      path.join(resolvedHome, ".dryads-ai", "clawdbot.json"),
      path.join(resolvedHome, ".dryads-ai", "moldbot.json"),
      path.join(resolvedHome, ".dryads-ai", "moltbot.json"),
      path.join(resolvedHome, ".clawdbot", "dryads-ai.json"),
      path.join(resolvedHome, ".clawdbot", "clawdbot.json"),
      path.join(resolvedHome, ".clawdbot", "moldbot.json"),
      path.join(resolvedHome, ".clawdbot", "moltbot.json"),
      path.join(resolvedHome, ".moldbot", "dryads-ai.json"),
      path.join(resolvedHome, ".moldbot", "clawdbot.json"),
      path.join(resolvedHome, ".moldbot", "moldbot.json"),
      path.join(resolvedHome, ".moldbot", "moltbot.json"),
      path.join(resolvedHome, ".moltbot", "dryads-ai.json"),
      path.join(resolvedHome, ".moltbot", "clawdbot.json"),
      path.join(resolvedHome, ".moltbot", "moldbot.json"),
      path.join(resolvedHome, ".moltbot", "moltbot.json"),
    ];
    expect(candidates).toEqual(expected);
  });

  it("prefers ~/.dryads-ai when it exists and legacy dir is missing", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "dryads-ai-state-"));
    try {
      const newDir = path.join(root, ".dryads-ai");
      await fs.mkdir(newDir, { recursive: true });
      const resolved = resolveStateDir({} as NodeJS.ProcessEnv, () => root);
      expect(resolved).toBe(newDir);
    } finally {
      await fs.rm(root, { recursive: true, force: true });
    }
  });

  it("CONFIG_PATH prefers existing config when present", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "dryads-ai-config-"));
    try {
      const legacyDir = path.join(root, ".dryads-ai");
      await fs.mkdir(legacyDir, { recursive: true });
      const legacyPath = path.join(legacyDir, "dryads-ai.json");
      await fs.writeFile(legacyPath, "{}", "utf-8");

      const resolved = resolveConfigPathCandidate({} as NodeJS.ProcessEnv, () => root);
      expect(resolved).toBe(legacyPath);
    } finally {
      await fs.rm(root, { recursive: true, force: true });
    }
  });

  it("respects state dir overrides when config is missing", async () => {
    const root = await fs.mkdtemp(path.join(os.tmpdir(), "dryads-ai-config-override-"));
    try {
      const legacyDir = path.join(root, ".dryads-ai");
      await fs.mkdir(legacyDir, { recursive: true });
      const legacyConfig = path.join(legacyDir, "dryads-ai.json");
      await fs.writeFile(legacyConfig, "{}", "utf-8");

      const overrideDir = path.join(root, "override");
      const env = { DRYADS_AI_STATE_DIR: overrideDir } as NodeJS.ProcessEnv;
      const resolved = resolveConfigPath(env, overrideDir, () => root);
      expect(resolved).toBe(path.join(overrideDir, "dryads-ai.json"));
    } finally {
      await fs.rm(root, { recursive: true, force: true });
    }
  });
});
