import type { DmmsAiConfig } from "./config.js";

export function ensurePluginAllowlisted(cfg: DmmsAiConfig, pluginId: string): DmmsAiConfig {
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
