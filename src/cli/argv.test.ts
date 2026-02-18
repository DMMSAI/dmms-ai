import { describe, expect, it } from "vitest";
import {
  buildParseArgv,
  getFlagValue,
  getCommandPath,
  getPrimaryCommand,
  getPositiveIntFlagValue,
  getVerboseFlag,
  hasHelpOrVersion,
  hasFlag,
  shouldMigrateState,
  shouldMigrateStateFromPath,
} from "./argv.js";

describe("argv helpers", () => {
  it("detects help/version flags", () => {
    expect(hasHelpOrVersion(["node", "dmms-ai", "--help"])).toBe(true);
    expect(hasHelpOrVersion(["node", "dmms-ai", "-V"])).toBe(true);
    expect(hasHelpOrVersion(["node", "dmms-ai", "status"])).toBe(false);
  });

  it("extracts command path ignoring flags and terminator", () => {
    expect(getCommandPath(["node", "dmms-ai", "status", "--json"], 2)).toEqual(["status"]);
    expect(getCommandPath(["node", "dmms-ai", "agents", "list"], 2)).toEqual(["agents", "list"]);
    expect(getCommandPath(["node", "dmms-ai", "status", "--", "ignored"], 2)).toEqual(["status"]);
  });

  it("returns primary command", () => {
    expect(getPrimaryCommand(["node", "dmms-ai", "agents", "list"])).toBe("agents");
    expect(getPrimaryCommand(["node", "dmms-ai"])).toBeNull();
  });

  it("parses boolean flags and ignores terminator", () => {
    expect(hasFlag(["node", "dmms-ai", "status", "--json"], "--json")).toBe(true);
    expect(hasFlag(["node", "dmms-ai", "--", "--json"], "--json")).toBe(false);
  });

  it("extracts flag values with equals and missing values", () => {
    expect(getFlagValue(["node", "dmms-ai", "status", "--timeout", "5000"], "--timeout")).toBe(
      "5000",
    );
    expect(getFlagValue(["node", "dmms-ai", "status", "--timeout=2500"], "--timeout")).toBe("2500");
    expect(getFlagValue(["node", "dmms-ai", "status", "--timeout"], "--timeout")).toBeNull();
    expect(getFlagValue(["node", "dmms-ai", "status", "--timeout", "--json"], "--timeout")).toBe(
      null,
    );
    expect(getFlagValue(["node", "dmms-ai", "--", "--timeout=99"], "--timeout")).toBeUndefined();
  });

  it("parses verbose flags", () => {
    expect(getVerboseFlag(["node", "dmms-ai", "status", "--verbose"])).toBe(true);
    expect(getVerboseFlag(["node", "dmms-ai", "status", "--debug"])).toBe(false);
    expect(getVerboseFlag(["node", "dmms-ai", "status", "--debug"], { includeDebug: true })).toBe(
      true,
    );
  });

  it("parses positive integer flag values", () => {
    expect(getPositiveIntFlagValue(["node", "dmms-ai", "status"], "--timeout")).toBeUndefined();
    expect(
      getPositiveIntFlagValue(["node", "dmms-ai", "status", "--timeout"], "--timeout"),
    ).toBeNull();
    expect(
      getPositiveIntFlagValue(["node", "dmms-ai", "status", "--timeout", "5000"], "--timeout"),
    ).toBe(5000);
    expect(
      getPositiveIntFlagValue(["node", "dmms-ai", "status", "--timeout", "nope"], "--timeout"),
    ).toBeUndefined();
  });

  it("builds parse argv from raw args", () => {
    const nodeArgv = buildParseArgv({
      programName: "dmms-ai",
      rawArgs: ["node", "dmms-ai", "status"],
    });
    expect(nodeArgv).toEqual(["node", "dmms-ai", "status"]);

    const versionedNodeArgv = buildParseArgv({
      programName: "dmms-ai",
      rawArgs: ["node-22", "dmms-ai", "status"],
    });
    expect(versionedNodeArgv).toEqual(["node-22", "dmms-ai", "status"]);

    const versionedNodeWindowsArgv = buildParseArgv({
      programName: "dmms-ai",
      rawArgs: ["node-22.2.0.exe", "dmms-ai", "status"],
    });
    expect(versionedNodeWindowsArgv).toEqual(["node-22.2.0.exe", "dmms-ai", "status"]);

    const versionedNodePatchlessArgv = buildParseArgv({
      programName: "dmms-ai",
      rawArgs: ["node-22.2", "dmms-ai", "status"],
    });
    expect(versionedNodePatchlessArgv).toEqual(["node-22.2", "dmms-ai", "status"]);

    const versionedNodeWindowsPatchlessArgv = buildParseArgv({
      programName: "dmms-ai",
      rawArgs: ["node-22.2.exe", "dmms-ai", "status"],
    });
    expect(versionedNodeWindowsPatchlessArgv).toEqual(["node-22.2.exe", "dmms-ai", "status"]);

    const versionedNodeWithPathArgv = buildParseArgv({
      programName: "dmms-ai",
      rawArgs: ["/usr/bin/node-22.2.0", "dmms-ai", "status"],
    });
    expect(versionedNodeWithPathArgv).toEqual(["/usr/bin/node-22.2.0", "dmms-ai", "status"]);

    const nodejsArgv = buildParseArgv({
      programName: "dmms-ai",
      rawArgs: ["nodejs", "dmms-ai", "status"],
    });
    expect(nodejsArgv).toEqual(["nodejs", "dmms-ai", "status"]);

    const nonVersionedNodeArgv = buildParseArgv({
      programName: "dmms-ai",
      rawArgs: ["node-dev", "dmms-ai", "status"],
    });
    expect(nonVersionedNodeArgv).toEqual(["node", "dmms-ai", "node-dev", "dmms-ai", "status"]);

    const directArgv = buildParseArgv({
      programName: "dmms-ai",
      rawArgs: ["dmms-ai", "status"],
    });
    expect(directArgv).toEqual(["node", "dmms-ai", "status"]);

    const bunArgv = buildParseArgv({
      programName: "dmms-ai",
      rawArgs: ["bun", "src/entry.ts", "status"],
    });
    expect(bunArgv).toEqual(["bun", "src/entry.ts", "status"]);
  });

  it("builds parse argv from fallback args", () => {
    const fallbackArgv = buildParseArgv({
      programName: "dmms-ai",
      fallbackArgv: ["status"],
    });
    expect(fallbackArgv).toEqual(["node", "dmms-ai", "status"]);
  });

  it("decides when to migrate state", () => {
    expect(shouldMigrateState(["node", "dmms-ai", "status"])).toBe(false);
    expect(shouldMigrateState(["node", "dmms-ai", "health"])).toBe(false);
    expect(shouldMigrateState(["node", "dmms-ai", "sessions"])).toBe(false);
    expect(shouldMigrateState(["node", "dmms-ai", "config", "get", "update"])).toBe(false);
    expect(shouldMigrateState(["node", "dmms-ai", "config", "unset", "update"])).toBe(false);
    expect(shouldMigrateState(["node", "dmms-ai", "models", "list"])).toBe(false);
    expect(shouldMigrateState(["node", "dmms-ai", "models", "status"])).toBe(false);
    expect(shouldMigrateState(["node", "dmms-ai", "memory", "status"])).toBe(false);
    expect(shouldMigrateState(["node", "dmms-ai", "agent", "--message", "hi"])).toBe(false);
    expect(shouldMigrateState(["node", "dmms-ai", "agents", "list"])).toBe(true);
    expect(shouldMigrateState(["node", "dmms-ai", "message", "send"])).toBe(true);
  });

  it("reuses command path for migrate state decisions", () => {
    expect(shouldMigrateStateFromPath(["status"])).toBe(false);
    expect(shouldMigrateStateFromPath(["config", "get"])).toBe(false);
    expect(shouldMigrateStateFromPath(["models", "status"])).toBe(false);
    expect(shouldMigrateStateFromPath(["agents", "list"])).toBe(true);
  });
});
