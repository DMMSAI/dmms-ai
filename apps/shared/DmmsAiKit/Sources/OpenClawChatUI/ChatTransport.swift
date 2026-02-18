import Foundation

public enum DmmsAiChatTransportEvent: Sendable {
    case health(ok: Bool)
    case tick
    case chat(DmmsAiChatEventPayload)
    case agent(DmmsAiAgentEventPayload)
    case seqGap
}

public protocol DmmsAiChatTransport: Sendable {
    func requestHistory(sessionKey: String) async throws -> DmmsAiChatHistoryPayload
    func sendMessage(
        sessionKey: String,
        message: String,
        thinking: String,
        idempotencyKey: String,
        attachments: [DmmsAiChatAttachmentPayload]) async throws -> DmmsAiChatSendResponse

    func abortRun(sessionKey: String, runId: String) async throws
    func listSessions(limit: Int?) async throws -> DmmsAiChatSessionsListResponse

    func requestHealth(timeoutMs: Int) async throws -> Bool
    func events() -> AsyncStream<DmmsAiChatTransportEvent>

    func setActiveSessionKey(_ sessionKey: String) async throws
}

extension DmmsAiChatTransport {
    public func setActiveSessionKey(_: String) async throws {}

    public func abortRun(sessionKey _: String, runId _: String) async throws {
        throw NSError(
            domain: "DmmsAiChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "chat.abort not supported by this transport"])
    }

    public func listSessions(limit _: Int?) async throws -> DmmsAiChatSessionsListResponse {
        throw NSError(
            domain: "DmmsAiChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "sessions.list not supported by this transport"])
    }
}
