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
    expect(hasHelpOrVersion(["node", "dryads-ai", "--help"])).toBe(true);
    expect(hasHelpOrVersion(["node", "dryads-ai", "-V"])).toBe(true);
    expect(hasHelpOrVersion(["node", "dryads-ai", "status"])).toBe(false);
  });

  it("extracts command path ignoring flags and terminator", () => {
    expect(getCommandPath(["node", "dryads-ai", "status", "--json"], 2)).toEqual(["status"]);
    expect(getCommandPath(["node", "dryads-ai", "agents", "list"], 2)).toEqual(["agents", "list"]);
    expect(getCommandPath(["node", "dryads-ai", "status", "--", "ignored"], 2)).toEqual(["status"]);
  });

  it("returns primary command", () => {
    expect(getPrimaryCommand(["node", "dryads-ai", "agents", "list"])).toBe("agents");
    expect(getPrimaryCommand(["node", "dryads-ai"])).toBeNull();
  });

  it("parses boolean flags and ignores terminator", () => {
    expect(hasFlag(["node", "dryads-ai", "status", "--json"], "--json")).toBe(true);
    expect(hasFlag(["node", "dryads-ai", "--", "--json"], "--json")).toBe(false);
  });

  it("extracts flag values with equals and missing values", () => {
    expect(getFlagValue(["node", "dryads-ai", "status", "--timeout", "5000"], "--timeout")).toBe(
      "5000",
    );
    expect(getFlagValue(["node", "dryads-ai", "status", "--timeout=2500"], "--timeout")).toBe(
      "2500",
    );
    expect(getFlagValue(["node", "dryads-ai", "status", "--timeout"], "--timeout")).toBeNull();
    expect(getFlagValue(["node", "dryads-ai", "status", "--timeout", "--json"], "--timeout")).toBe(
      null,
    );
    expect(getFlagValue(["node", "dryads-ai", "--", "--timeout=99"], "--timeout")).toBeUndefined();
  });

  it("parses verbose flags", () => {
    expect(getVerboseFlag(["node", "dryads-ai", "status", "--verbose"])).toBe(true);
    expect(getVerboseFlag(["node", "dryads-ai", "status", "--debug"])).toBe(false);
    expect(getVerboseFlag(["node", "dryads-ai", "status", "--debug"], { includeDebug: true })).toBe(
      true,
    );
  });

  it("parses positive integer flag values", () => {
    expect(getPositiveIntFlagValue(["node", "dryads-ai", "status"], "--timeout")).toBeUndefined();
    expect(
      getPositiveIntFlagValue(["node", "dryads-ai", "status", "--timeout"], "--timeout"),
    ).toBeNull();
    expect(
      getPositiveIntFlagValue(["node", "dryads-ai", "status", "--timeout", "5000"], "--timeout"),
    ).toBe(5000);
    expect(
      getPositiveIntFlagValue(["node", "dryads-ai", "status", "--timeout", "nope"], "--timeout"),
    ).toBeUndefined();
  });

  it("builds parse argv from raw args", () => {
    const nodeArgv = buildParseArgv({
      programName: "dryads-ai",
      rawArgs: ["node", "dryads-ai", "status"],
    });
    expect(nodeArgv).toEqual(["node", "dryads-ai", "status"]);

    const versionedNodeArgv = buildParseArgv({
      programName: "dryads-ai",
      rawArgs: ["node-22", "dryads-ai", "status"],
    });
    expect(versionedNodeArgv).toEqual(["node-22", "dryads-ai", "status"]);

    const versionedNodeWindowsArgv = buildParseArgv({
      programName: "dryads-ai",
      rawArgs: ["node-22.2.0.exe", "dryads-ai", "status"],
    });
    expect(versionedNodeWindowsArgv).toEqual(["node-22.2.0.exe", "dryads-ai", "status"]);

    const versionedNodePatchlessArgv = buildParseArgv({
      programName: "dryads-ai",
      rawArgs: ["node-22.2", "dryads-ai", "status"],
    });
    expect(versionedNodePatchlessArgv).toEqual(["node-22.2", "dryads-ai", "status"]);

    const versionedNodeWindowsPatchlessArgv = buildParseArgv({
      programName: "dryads-ai",
      rawArgs: ["node-22.2.exe", "dryads-ai", "status"],
    });
    expect(versionedNodeWindowsPatchlessArgv).toEqual(["node-22.2.exe", "dryads-ai", "status"]);

    const versionedNodeWithPathArgv = buildParseArgv({
      programName: "dryads-ai",
      rawArgs: ["/usr/bin/node-22.2.0", "dryads-ai", "status"],
    });
    expect(versionedNodeWithPathArgv).toEqual(["/usr/bin/node-22.2.0", "dryads-ai", "status"]);

    const nodejsArgv = buildParseArgv({
      programName: "dryads-ai",
      rawArgs: ["nodejs", "dryads-ai", "status"],
    });
    expect(nodejsArgv).toEqual(["nodejs", "dryads-ai", "status"]);

    const nonVersionedNodeArgv = buildParseArgv({
      programName: "dryads-ai",
      rawArgs: ["node-dev", "dryads-ai", "status"],
    });
    expect(nonVersionedNodeArgv).toEqual(["node", "dryads-ai", "node-dev", "dryads-ai", "status"]);

    const directArgv = buildParseArgv({
      programName: "dryads-ai",
      rawArgs: ["dryads-ai", "status"],
    });
    expect(directArgv).toEqual(["node", "dryads-ai", "status"]);

    const bunArgv = buildParseArgv({
      programName: "dryads-ai",
      rawArgs: ["bun", "src/entry.ts", "status"],
    });
    expect(bunArgv).toEqual(["bun", "src/entry.ts", "status"]);
  });

  it("builds parse argv from fallback args", () => {
    const fallbackArgv = buildParseArgv({
      programName: "dryads-ai",
      fallbackArgv: ["status"],
    });
    expect(fallbackArgv).toEqual(["node", "dryads-ai", "status"]);
  });

  it("decides when to migrate state", () => {
    expect(shouldMigrateState(["node", "dryads-ai", "status"])).toBe(false);
    expect(shouldMigrateState(["node", "dryads-ai", "health"])).toBe(false);
    expect(shouldMigrateState(["node", "dryads-ai", "sessions"])).toBe(false);
    expect(shouldMigrateState(["node", "dryads-ai", "config", "get", "update"])).toBe(false);
    expect(shouldMigrateState(["node", "dryads-ai", "config", "unset", "update"])).toBe(false);
    expect(shouldMigrateState(["node", "dryads-ai", "models", "list"])).toBe(false);
    expect(shouldMigrateState(["node", "dryads-ai", "models", "status"])).toBe(false);
    expect(shouldMigrateState(["node", "dryads-ai", "memory", "status"])).toBe(false);
    expect(shouldMigrateState(["node", "dryads-ai", "agent", "--message", "hi"])).toBe(false);
    expect(shouldMigrateState(["node", "dryads-ai", "agents", "list"])).toBe(true);
    expect(shouldMigrateState(["node", "dryads-ai", "message", "send"])).toBe(true);
  });

  it("reuses command path for migrate state decisions", () => {
    expect(shouldMigrateStateFromPath(["status"])).toBe(false);
    expect(shouldMigrateStateFromPath(["config", "get"])).toBe(false);
    expect(shouldMigrateStateFromPath(["models", "status"])).toBe(false);
    expect(shouldMigrateStateFromPath(["agents", "list"])).toBe(true);
  });
});
