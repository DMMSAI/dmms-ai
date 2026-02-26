import Foundation

public enum DryadsAiCameraCommand: String, Codable, Sendable {
    case list = "camera.list"
    case snap = "camera.snap"
    case clip = "camera.clip"
}

public enum DryadsAiCameraFacing: String, Codable, Sendable {
    case back
    case front
}

public enum DryadsAiCameraImageFormat: String, Codable, Sendable {
    case jpg
    case jpeg
}

public enum DryadsAiCameraVideoFormat: String, Codable, Sendable {
    case mp4
}

public struct DryadsAiCameraSnapParams: Codable, Sendable, Equatable {
    public var facing: DryadsAiCameraFacing?
    public var maxWidth: Int?
    public var quality: Double?
    public var format: DryadsAiCameraImageFormat?
    public var deviceId: String?
    public var delayMs: Int?

    public init(
        facing: DryadsAiCameraFacing? = nil,
        maxWidth: Int? = nil,
        quality: Double? = nil,
        format: DryadsAiCameraImageFormat? = nil,
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

public struct DryadsAiCameraClipParams: Codable, Sendable, Equatable {
    public var facing: DryadsAiCameraFacing?
    public var durationMs: Int?
    public var includeAudio: Bool?
    public var format: DryadsAiCameraVideoFormat?
    public var deviceId: String?

    public init(
        facing: DryadsAiCameraFacing? = nil,
        durationMs: Int? = nil,
        includeAudio: Bool? = nil,
        format: DryadsAiCameraVideoFormat? = nil,
        deviceId: String? = nil)
    {
        self.facing = facing
        self.durationMs = durationMs
        self.includeAudio = includeAudio
        self.format = format
        self.deviceId = deviceId
    }
}
