import type {
  AnyAgentTool,
  DryadsAiPluginApi,
  DryadsAiPluginToolFactory,
} from "../../src/plugins/types.js";
import { createLobsterTool } from "./src/lobster-tool.js";

export default function register(api: DryadsAiPluginApi) {
  api.registerTool(
    ((ctx) => {
      if (ctx.sandboxed) {
        return null;
      }
      return createLobsterTool(api) as AnyAgentTool;
    }) as DryadsAiPluginToolFactory,
    { optional: true },
  );
}
