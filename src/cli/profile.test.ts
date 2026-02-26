import path from "node:path";
import { describe, expect, it } from "vitest";
import { formatCliCommand } from "./command-format.js";
import { applyCliProfileEnv, parseCliProfileArgs } from "./profile.js";

describe("parseCliProfileArgs", () => {
  it("leaves gateway --dev for subcommands", () => {
    const res = parseCliProfileArgs([
      "node",
      "dryads-ai",
      "gateway",
      "--dev",
      "--allow-unconfigured",
    ]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBeNull();
    expect(res.argv).toEqual(["node", "dryads-ai", "gateway", "--dev", "--allow-unconfigured"]);
  });

  it("still accepts global --dev before subcommand", () => {
    const res = parseCliProfileArgs(["node", "dryads-ai", "--dev", "gateway"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("dev");
    expect(res.argv).toEqual(["node", "dryads-ai", "gateway"]);
  });

  it("parses --profile value and strips it", () => {
    const res = parseCliProfileArgs(["node", "dryads-ai", "--profile", "work", "status"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("work");
    expect(res.argv).toEqual(["node", "dryads-ai", "status"]);
  });

  it("rejects missing profile value", () => {
    const res = parseCliProfileArgs(["node", "dryads-ai", "--profile"]);
    expect(res.ok).toBe(false);
  });

  it("rejects combining --dev with --profile (dev first)", () => {
    const res = parseCliProfileArgs(["node", "dryads-ai", "--dev", "--profile", "work", "status"]);
    expect(res.ok).toBe(false);
  });

  it("rejects combining --dev with --profile (profile first)", () => {
    const res = parseCliProfileArgs(["node", "dryads-ai", "--profile", "work", "--dev", "status"]);
    expect(res.ok).toBe(false);
  });
});

describe("applyCliProfileEnv", () => {
  it("fills env defaults for dev profile", () => {
    const env: Record<string, string | undefined> = {};
    applyCliProfileEnv({
      profile: "dev",
      env,
      homedir: () => "/home/peter",
    });
    const expectedStateDir = path.join(path.resolve("/home/peter"), ".dryads-ai-dev");
    expect(env.DRYADS_AI_PROFILE).toBe("dev");
    expect(env.DRYADS_AI_STATE_DIR).toBe(expectedStateDir);
    expect(env.DRYADS_AI_CONFIG_PATH).toBe(path.join(expectedStateDir, "dryads-ai.json"));
    expect(env.DRYADS_AI_GATEWAY_PORT).toBe("19001");
  });

  it("does not override explicit env values", () => {
    const env: Record<string, string | undefined> = {
      DRYADS_AI_STATE_DIR: "/custom",
      DRYADS_AI_GATEWAY_PORT: "19099",
    };
    applyCliProfileEnv({
      profile: "dev",
      env,
      homedir: () => "/home/peter",
    });
    expect(env.DRYADS_AI_STATE_DIR).toBe("/custom");
    expect(env.DRYADS_AI_GATEWAY_PORT).toBe("19099");
    expect(env.DRYADS_AI_CONFIG_PATH).toBe(path.join("/custom", "dryads-ai.json"));
  });

  it("uses DRYADS_AI_HOME when deriving profile state dir", () => {
    const env: Record<string, string | undefined> = {
      DRYADS_AI_HOME: "/srv/dryads-ai-home",
      HOME: "/home/other",
    };
    applyCliProfileEnv({
      profile: "work",
      env,
      homedir: () => "/home/fallback",
    });

    const resolvedHome = path.resolve("/srv/dryads-ai-home");
    expect(env.DRYADS_AI_STATE_DIR).toBe(path.join(resolvedHome, ".dryads-ai-work"));
    expect(env.DRYADS_AI_CONFIG_PATH).toBe(
      path.join(resolvedHome, ".dryads-ai-work", "dryads-ai.json"),
    );
  });
});

describe("formatCliCommand", () => {
  it("returns command unchanged when no profile is set", () => {
    expect(formatCliCommand("dryads-ai doctor --fix", {})).toBe("dryads-ai doctor --fix");
  });

  it("returns command unchanged when profile is default", () => {
    expect(formatCliCommand("dryads-ai doctor --fix", { DRYADS_AI_PROFILE: "default" })).toBe(
      "dryads-ai doctor --fix",
    );
  });

  it("returns command unchanged when profile is Default (case-insensitive)", () => {
    expect(formatCliCommand("dryads-ai doctor --fix", { DRYADS_AI_PROFILE: "Default" })).toBe(
      "dryads-ai doctor --fix",
    );
  });

  it("returns command unchanged when profile is invalid", () => {
    expect(formatCliCommand("dryads-ai doctor --fix", { DRYADS_AI_PROFILE: "bad profile" })).toBe(
      "dryads-ai doctor --fix",
    );
  });

  it("returns command unchanged when --profile is already present", () => {
    expect(
      formatCliCommand("dryads-ai --profile work doctor --fix", { DRYADS_AI_PROFILE: "work" }),
    ).toBe("dryads-ai --profile work doctor --fix");
  });

  it("returns command unchanged when --dev is already present", () => {
    expect(formatCliCommand("dryads-ai --dev doctor", { DRYADS_AI_PROFILE: "dev" })).toBe(
      "dryads-ai --dev doctor",
    );
  });

  it("inserts --profile flag when profile is set", () => {
    expect(formatCliCommand("dryads-ai doctor --fix", { DRYADS_AI_PROFILE: "work" })).toBe(
      "dryads-ai --profile work doctor --fix",
    );
  });

  it("trims whitespace from profile", () => {
    expect(
      formatCliCommand("dryads-ai doctor --fix", { DRYADS_AI_PROFILE: "  jbdryads-ai  " }),
    ).toBe("dryads-ai --profile jbdryads-ai doctor --fix");
  });

  it("handles command with no args after dryads-ai", () => {
    expect(formatCliCommand("dryads-ai", { DRYADS_AI_PROFILE: "test" })).toBe(
      "dryads-ai --profile test",
    );
  });

  it("handles pnpm wrapper", () => {
    expect(formatCliCommand("pnpm dryads-ai doctor", { DRYADS_AI_PROFILE: "work" })).toBe(
      "pnpm dryads-ai --profile work doctor",
    );
  });
});
