import { describe, expect, it } from "vitest";
import { resolveIrcInboundTarget } from "./monitor.js";

describe("irc monitor inbound target", () => {
  it("keeps channel target for group messages", () => {
    expect(
      resolveIrcInboundTarget({
        target: "#dryads-ai",
        senderNick: "alice",
      }),
    ).toEqual({
      isGroup: true,
      target: "#dryads-ai",
      rawTarget: "#dryads-ai",
    });
  });

  it("maps DM target to sender nick and preserves raw target", () => {
    expect(
      resolveIrcInboundTarget({
        target: "dryads-ai-bot",
        senderNick: "alice",
      }),
    ).toEqual({
      isGroup: false,
      target: "alice",
      rawTarget: "dryads-ai-bot",
    });
  });

  it("falls back to raw target when sender nick is empty", () => {
    expect(
      resolveIrcInboundTarget({
        target: "dryads-ai-bot",
        senderNick: " ",
      }),
    ).toEqual({
      isGroup: false,
      target: "dryads-ai-bot",
      rawTarget: "dryads-ai-bot",
    });
  });
});
