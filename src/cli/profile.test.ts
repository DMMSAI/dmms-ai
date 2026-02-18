import path from "node:path";
import { describe, expect, it } from "vitest";
import { formatCliCommand } from "./command-format.js";
import { applyCliProfileEnv, parseCliProfileArgs } from "./profile.js";

describe("parseCliProfileArgs", () => {
  it("leaves gateway --dev for subcommands", () => {
    const res = parseCliProfileArgs([
      "node",
      "dmms-ai",
      "gateway",
      "--dev",
      "--allow-unconfigured",
    ]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBeNull();
    expect(res.argv).toEqual(["node", "dmms-ai", "gateway", "--dev", "--allow-unconfigured"]);
  });

  it("still accepts global --dev before subcommand", () => {
    const res = parseCliProfileArgs(["node", "dmms-ai", "--dev", "gateway"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("dev");
    expect(res.argv).toEqual(["node", "dmms-ai", "gateway"]);
  });

  it("parses --profile value and strips it", () => {
    const res = parseCliProfileArgs(["node", "dmms-ai", "--profile", "work", "status"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("work");
    expect(res.argv).toEqual(["node", "dmms-ai", "status"]);
  });

  it("rejects missing profile value", () => {
    const res = parseCliProfileArgs(["node", "dmms-ai", "--profile"]);
    expect(res.ok).toBe(false);
  });

  it("rejects combining --dev with --profile (dev first)", () => {
    const res = parseCliProfileArgs(["node", "dmms-ai", "--dev", "--profile", "work", "status"]);
    expect(res.ok).toBe(false);
  });

  it("rejects combining --dev with --profile (profile first)", () => {
    const res = parseCliProfileArgs(["node", "dmms-ai", "--profile", "work", "--dev", "status"]);
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
    const expectedStateDir = path.join(path.resolve("/home/peter"), ".dmms-ai-dev");
    expect(env.DMMS_AI_PROFILE).toBe("dev");
    expect(env.DMMS_AI_STATE_DIR).toBe(expectedStateDir);
    expect(env.DMMS_AI_CONFIG_PATH).toBe(path.join(expectedStateDir, "dmms-ai.json"));
    expect(env.DMMS_AI_GATEWAY_PORT).toBe("19001");
  });

  it("does not override explicit env values", () => {
    const env: Record<string, string | undefined> = {
      DMMS_AI_STATE_DIR: "/custom",
      DMMS_AI_GATEWAY_PORT: "19099",
    };
    applyCliProfileEnv({
      profile: "dev",
      env,
      homedir: () => "/home/peter",
    });
    expect(env.DMMS_AI_STATE_DIR).toBe("/custom");
    expect(env.DMMS_AI_GATEWAY_PORT).toBe("19099");
    expect(env.DMMS_AI_CONFIG_PATH).toBe(path.join("/custom", "dmms-ai.json"));
  });

  it("uses DMMS_AI_HOME when deriving profile state dir", () => {
    const env: Record<string, string | undefined> = {
      DMMS_AI_HOME: "/srv/dmms-ai-home",
      HOME: "/home/other",
    };
    applyCliProfileEnv({
      profile: "work",
      env,
      homedir: () => "/home/fallback",
    });

    const resolvedHome = path.resolve("/srv/dmms-ai-home");
    expect(env.DMMS_AI_STATE_DIR).toBe(path.join(resolvedHome, ".dmms-ai-work"));
    expect(env.DMMS_AI_CONFIG_PATH).toBe(path.join(resolvedHome, ".dmms-ai-work", "dmms-ai.json"));
  });
});

describe("formatCliCommand", () => {
  it("returns command unchanged when no profile is set", () => {
    expect(formatCliCommand("dmms-ai doctor --fix", {})).toBe("dmms-ai doctor --fix");
  });

  it("returns command unchanged when profile is default", () => {
    expect(formatCliCommand("dmms-ai doctor --fix", { DMMS_AI_PROFILE: "default" })).toBe(
      "dmms-ai doctor --fix",
    );
  });

  it("returns command unchanged when profile is Default (case-insensitive)", () => {
    expect(formatCliCommand("dmms-ai doctor --fix", { DMMS_AI_PROFILE: "Default" })).toBe(
      "dmms-ai doctor --fix",
    );
  });

  it("returns command unchanged when profile is invalid", () => {
    expect(formatCliCommand("dmms-ai doctor --fix", { DMMS_AI_PROFILE: "bad profile" })).toBe(
      "dmms-ai doctor --fix",
    );
  });

  it("returns command unchanged when --profile is already present", () => {
    expect(
      formatCliCommand("dmms-ai --profile work doctor --fix", { DMMS_AI_PROFILE: "work" }),
    ).toBe("dmms-ai --profile work doctor --fix");
  });

  it("returns command unchanged when --dev is already present", () => {
    expect(formatCliCommand("dmms-ai --dev doctor", { DMMS_AI_PROFILE: "dev" })).toBe(
      "dmms-ai --dev doctor",
    );
  });

  it("inserts --profile flag when profile is set", () => {
    expect(formatCliCommand("dmms-ai doctor --fix", { DMMS_AI_PROFILE: "work" })).toBe(
      "dmms-ai --profile work doctor --fix",
    );
  });

  it("trims whitespace from profile", () => {
    expect(formatCliCommand("dmms-ai doctor --fix", { DMMS_AI_PROFILE: "  jbdmms-ai  " })).toBe(
      "dmms-ai --profile jbdmms-ai doctor --fix",
    );
  });

  it("handles command with no args after dmms-ai", () => {
    expect(formatCliCommand("dmms-ai", { DMMS_AI_PROFILE: "test" })).toBe("dmms-ai --profile test");
  });

  it("handles pnpm wrapper", () => {
    expect(formatCliCommand("pnpm dmms-ai doctor", { DMMS_AI_PROFILE: "work" })).toBe(
      "pnpm dmms-ai --profile work doctor",
    );
  });
});
