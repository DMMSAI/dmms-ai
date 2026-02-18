import os from "node:os";
import path from "node:path";
import type { PluginRuntime } from "dmms-ai/plugin-sdk";

export const msteamsRuntimeStub = {
  state: {
    resolveStateDir: (env: NodeJS.ProcessEnv = process.env, homedir?: () => string) => {
      const override = env.DMMS_AI_STATE_DIR?.trim() || env.DMMS_AI_STATE_DIR?.trim();
      if (override) {
        return override;
      }
      const resolvedHome = homedir ? homedir() : os.homedir();
      return path.join(resolvedHome, ".dmms-ai");
    },
  },
} as unknown as PluginRuntime;
