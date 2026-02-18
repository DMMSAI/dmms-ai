import Foundation

public enum DmmsAiDeviceCommand: String, Codable, Sendable {
    case status = "device.status"
    case info = "device.info"
}

public enum DmmsAiBatteryState: String, Codable, Sendable {
    case unknown
    case unplugged
    case charging
    case full
}

public enum DmmsAiThermalState: String, Codable, Sendable {
    case nominal
    case fair
    case serious
    case critical
}

public enum DmmsAiNetworkPathStatus: String, Codable, Sendable {
    case satisfied
    case unsatisfied
    case requiresConnection
}

public enum DmmsAiNetworkInterfaceType: String, Codable, Sendable {
    case wifi
    case cellular
    case wired
    case other
}

public struct DmmsAiBatteryStatusPayload: Codable, Sendable, Equatable {
    public var level: Double?
    public var state: DmmsAiBatteryState
    public var lowPowerModeEnabled: Bool

    public init(level: Double?, state: DmmsAiBatteryState, lowPowerModeEnabled: Bool) {
        self.level = level
        self.state = state
        self.lowPowerModeEnabled = lowPowerModeEnabled
    }
}

public struct DmmsAiThermalStatusPayload: Codable, Sendable, Equatable {
    public var state: DmmsAiThermalState

    public init(state: DmmsAiThermalState) {
        self.state = state
    }
}

public struct DmmsAiStorageStatusPayload: Codable, Sendable, Equatable {
    public var totalBytes: Int64
    public var freeBytes: Int64
    public var usedBytes: Int64

    public init(totalBytes: Int64, freeBytes: Int64, usedBytes: Int64) {
        self.totalBytes = totalBytes
        self.freeBytes = freeBytes
        self.usedBytes = usedBytes
    }
}

public struct DmmsAiNetworkStatusPayload: Codable, Sendable, Equatable {
    public var status: DmmsAiNetworkPathStatus
    public var isExpensive: Bool
    public var isConstrained: Bool
    public var interfaces: [DmmsAiNetworkInterfaceType]

    public init(
        status: DmmsAiNetworkPathStatus,
        isExpensive: Bool,
        isConstrained: Bool,
        interfaces: [DmmsAiNetworkInterfaceType])
    {
        self.status = status
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
        self.interfaces = interfaces
    }
}

public struct DmmsAiDeviceStatusPayload: Codable, Sendable, Equatable {
    public var battery: DmmsAiBatteryStatusPayload
    public var thermal: DmmsAiThermalStatusPayload
    public var storage: DmmsAiStorageStatusPayload
    public var network: DmmsAiNetworkStatusPayload
    public var uptimeSeconds: Double

    public init(
        battery: DmmsAiBatteryStatusPayload,
        thermal: DmmsAiThermalStatusPayload,
        storage: DmmsAiStorageStatusPayload,
        network: DmmsAiNetworkStatusPayload,
        uptimeSeconds: Double)
    {
        self.battery = battery
        self.thermal = thermal
        self.storage = storage
        self.network = network
        self.uptimeSeconds = uptimeSeconds
    }
}

public struct DmmsAiDeviceInfoPayload: Codable, Sendable, Equatable {
    public var deviceName: String
    public var modelIdentifier: String
    public var systemName: String
    public var systemVersion: String
    public var appVersion: String
    public var appBuild: String
    public var locale: String

    public init(
        deviceName: String,
        modelIdentifier: String,
        systemName: String,
        systemVersion: String,
        appVersion: String,
        appBuild: String,
        locale: String)
    {
        self.deviceName = deviceName
        self.modelIdentifier = modelIdentifier
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.appVersion = appVersion
        self.appBuild = appBuild
        self.locale = locale
    }
}
