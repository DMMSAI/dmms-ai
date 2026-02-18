import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import { captureEnv } from "../test-utils/env.js";
import { resolveDmmsAiAgentDir } from "./agent-paths.js";

describe("resolveDmmsAiAgentDir", () => {
  const env = captureEnv(["DMMS_AI_STATE_DIR", "DMMS_AI_AGENT_DIR", "PI_CODING_AGENT_DIR"]);
  let tempStateDir: string | null = null;

  afterEach(async () => {
    if (tempStateDir) {
      await fs.rm(tempStateDir, { recursive: true, force: true });
      tempStateDir = null;
    }
    env.restore();
  });

  it("defaults to the multi-agent path when no overrides are set", async () => {
    tempStateDir = await fs.mkdtemp(path.join(os.tmpdir(), "dmms-ai-agent-"));
    process.env.DMMS_AI_STATE_DIR = tempStateDir;
    delete process.env.DMMS_AI_AGENT_DIR;
    delete process.env.PI_CODING_AGENT_DIR;

    const resolved = resolveDmmsAiAgentDir();

    expect(resolved).toBe(path.join(tempStateDir, "agents", "main", "agent"));
  });

  it("honors DMMS_AI_AGENT_DIR overrides", async () => {
    tempStateDir = await fs.mkdtemp(path.join(os.tmpdir(), "dmms-ai-agent-"));
    const override = path.join(tempStateDir, "agent");
    process.env.DMMS_AI_AGENT_DIR = override;
    delete process.env.PI_CODING_AGENT_DIR;

    const resolved = resolveDmmsAiAgentDir();

    expect(resolved).toBe(path.resolve(override));
  });
});
