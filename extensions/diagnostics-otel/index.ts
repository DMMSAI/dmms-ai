import type { DmmsAiPluginApi } from "dmms-ai/plugin-sdk";
import { emptyPluginConfigSchema } from "dmms-ai/plugin-sdk";
import { createDiagnosticsOtelService } from "./src/service.js";

const plugin = {
  id: "diagnostics-otel",
  name: "Diagnostics OpenTelemetry",
  description: "Export diagnostics events to OpenTelemetry",
  configSchema: emptyPluginConfigSchema(),
  register(api: DmmsAiPluginApi) {
    api.registerService(createDiagnosticsOtelService());
  },
};

export default plugin;
