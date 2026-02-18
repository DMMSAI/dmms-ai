import { describe, expect, it } from "vitest";
import { resolveIrcInboundTarget } from "./monitor.js";

describe("irc monitor inbound target", () => {
  it("keeps channel target for group messages", () => {
    expect(
      resolveIrcInboundTarget({
        target: "#dmms-ai",
        senderNick: "alice",
      }),
    ).toEqual({
      isGroup: true,
      target: "#dmms-ai",
      rawTarget: "#dmms-ai",
    });
  });

  it("maps DM target to sender nick and preserves raw target", () => {
    expect(
      resolveIrcInboundTarget({
        target: "dmms-ai-bot",
        senderNick: "alice",
      }),
    ).toEqual({
      isGroup: false,
      target: "alice",
      rawTarget: "dmms-ai-bot",
    });
  });

  it("falls back to raw target when sender nick is empty", () => {
    expect(
      resolveIrcInboundTarget({
        target: "dmms-ai-bot",
        senderNick: " ",
      }),
    ).toEqual({
      isGroup: false,
      target: "dmms-ai-bot",
      rawTarget: "dmms-ai-bot",
    });
  });
});
