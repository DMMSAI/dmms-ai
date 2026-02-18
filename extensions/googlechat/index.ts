import type { DmmsAiPluginApi } from "dmms-ai/plugin-sdk";
import { emptyPluginConfigSchema } from "dmms-ai/plugin-sdk";
import { googlechatDock, googlechatPlugin } from "./src/channel.js";
import { handleGoogleChatWebhookRequest } from "./src/monitor.js";
import { setGoogleChatRuntime } from "./src/runtime.js";

const plugin = {
  id: "googlechat",
  name: "Google Chat",
  description: "DMMS AI Google Chat channel plugin",
  configSchema: emptyPluginConfigSchema(),
  register(api: DmmsAiPluginApi) {
    setGoogleChatRuntime(api.runtime);
    api.registerChannel({ plugin: googlechatPlugin, dock: googlechatDock });
    api.registerHttpHandler(handleGoogleChatWebhookRequest);
  },
};

export default plugin;
