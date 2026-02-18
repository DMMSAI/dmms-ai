import type { DmmsAiConfig } from "../config/config.js";

export function applyOnboardingLocalWorkspaceConfig(
  baseConfig: DmmsAiConfig,
  workspaceDir: string,
): DmmsAiConfig {
  return {
    ...baseConfig,
    agents: {
      ...baseConfig.agents,
      defaults: {
        ...baseConfig.agents?.defaults,
        workspace: workspaceDir,
      },
    },
    gateway: {
      ...baseConfig.gateway,
      mode: "local",
    },
  };
}
