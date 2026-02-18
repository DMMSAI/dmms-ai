import Foundation

public enum DmmsAiCameraCommand: String, Codable, Sendable {
    case list = "camera.list"
    case snap = "camera.snap"
    case clip = "camera.clip"
}

public enum DmmsAiCameraFacing: String, Codable, Sendable {
    case back
    case front
}

public enum DmmsAiCameraImageFormat: String, Codable, Sendable {
    case jpg
    case jpeg
}

public enum DmmsAiCameraVideoFormat: String, Codable, Sendable {
    case mp4
}

public struct DmmsAiCameraSnapParams: Codable, Sendable, Equatable {
    public var facing: DmmsAiCameraFacing?
    public var maxWidth: Int?
    public var quality: Double?
    public var format: DmmsAiCameraImageFormat?
    public var deviceId: String?
    public var delayMs: Int?

    public init(
        facing: DmmsAiCameraFacing? = nil,
        maxWidth: Int? = nil,
        quality: Double? = nil,
        format: DmmsAiCameraImageFormat? = nil,
        deviceId: String? = nil,
        delayMs: Int? = nil)
    {
        self.facing = facing
        self.maxWidth = maxWidth
        self.quality = quality
        self.format = format
        self.deviceId = deviceId
        self.delayMs = delayMs
    }
}

public struct DmmsAiCameraClipParams: Codable, Sendable, Equatable {
    public var facing: DmmsAiCameraFacing?
    public var durationMs: Int?
    public var includeAudio: Bool?
    public var format: DmmsAiCameraVideoFormat?
    public var deviceId: String?

    public init(
        facing: DmmsAiCameraFacing? = nil,
        durationMs: Int? = nil,
        includeAudio: Bool? = nil,
        format: DmmsAiCameraVideoFormat? = nil,
        deviceId: String? = nil)
    {
        self.facing = facing
        self.durationMs = durationMs
        self.includeAudio = includeAudio
        self.format = format
        self.deviceId = deviceId
    }
}
