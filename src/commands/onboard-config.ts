import type { DryadsAiConfig } from "../config/config.js";

export function applyOnboardingLocalWorkspaceConfig(
  baseConfig: DryadsAiConfig,
  workspaceDir: string,
): DryadsAiConfig {
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
