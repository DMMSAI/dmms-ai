import type { DryadsAiConfig } from "./config.js";

export function ensurePluginAllowlisted(cfg: DryadsAiConfig, pluginId: string): DryadsAiConfig {
  const allow = cfg.plugins?.allow;
  if (!Array.isArray(allow) || allow.includes(pluginId)) {
    return cfg;
  }
  return {
    ...cfg,
    plugins: {
      ...cfg.plugins,
      allow: [...allow, pluginId],
    },
  };
}
