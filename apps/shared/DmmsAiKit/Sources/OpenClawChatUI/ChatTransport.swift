import Foundation

public enum DryadsAiChatTransportEvent: Sendable {
    case health(ok: Bool)
    case tick
    case chat(DryadsAiChatEventPayload)
    case agent(DryadsAiAgentEventPayload)
    case seqGap
}

public protocol DryadsAiChatTransport: Sendable {
    func requestHistory(sessionKey: String) async throws -> DryadsAiChatHistoryPayload
    func sendMessage(
        sessionKey: String,
        message: String,
        thinking: String,
        idempotencyKey: String,
        attachments: [DryadsAiChatAttachmentPayload]) async throws -> DryadsAiChatSendResponse

    func abortRun(sessionKey: String, runId: String) async throws
    func listSessions(limit: Int?) async throws -> DryadsAiChatSessionsListResponse

    func requestHealth(timeoutMs: Int) async throws -> Bool
    func events() -> AsyncStream<DryadsAiChatTransportEvent>

    func setActiveSessionKey(_ sessionKey: String) async throws
}

extension DryadsAiChatTransport {
    public func setActiveSessionKey(_: String) async throws {}

    public func abortRun(sessionKey _: String, runId _: String) async throws {
        throw NSError(
            domain: "DryadsAiChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "chat.abort not supported by this transport"])
    }

    public func listSessions(limit _: Int?) async throws -> DryadsAiChatSessionsListResponse {
        throw NSError(
            domain: "DryadsAiChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "sessions.list not supported by this transport"])
    }
}
