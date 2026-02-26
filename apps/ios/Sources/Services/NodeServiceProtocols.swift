import CoreLocation
import Foundation
import DryadsAiKit
import UIKit

protocol CameraServicing: Sendable {
    func listDevices() async -> [CameraController.CameraDeviceInfo]
    func snap(params: DryadsAiCameraSnapParams) async throws -> (format: String, base64: String, width: Int, height: Int)
    func clip(params: DryadsAiCameraClipParams) async throws -> (format: String, base64: String, durationMs: Int, hasAudio: Bool)
}

protocol ScreenRecordingServicing: Sendable {
    func record(
        screenIndex: Int?,
        durationMs: Int?,
        fps: Double?,
        includeAudio: Bool?,
        outPath: String?) async throws -> String
}

@MainActor
protocol LocationServicing: Sendable {
    func authorizationStatus() -> CLAuthorizationStatus
    func accuracyAuthorization() -> CLAccuracyAuthorization
    func ensureAuthorization(mode: DryadsAiLocationMode) async -> CLAuthorizationStatus
    func currentLocation(
        params: DryadsAiLocationGetParams,
        desiredAccuracy: DryadsAiLocationAccuracy,
        maxAgeMs: Int?,
        timeoutMs: Int?) async throws -> CLLocation
    func startLocationUpdates(
        desiredAccuracy: DryadsAiLocationAccuracy,
        significantChangesOnly: Bool) -> AsyncStream<CLLocation>
    func stopLocationUpdates()
    func startMonitoringSignificantLocationChanges(onUpdate: @escaping @Sendable (CLLocation) -> Void)
    func stopMonitoringSignificantLocationChanges()
}

protocol DeviceStatusServicing: Sendable {
    func status() async throws -> DryadsAiDeviceStatusPayload
    func info() -> DryadsAiDeviceInfoPayload
}

protocol PhotosServicing: Sendable {
    func latest(params: DryadsAiPhotosLatestParams) async throws -> DryadsAiPhotosLatestPayload
}

protocol ContactsServicing: Sendable {
    func search(params: DryadsAiContactsSearchParams) async throws -> DryadsAiContactsSearchPayload
    func add(params: DryadsAiContactsAddParams) async throws -> DryadsAiContactsAddPayload
}

protocol CalendarServicing: Sendable {
    func events(params: DryadsAiCalendarEventsParams) async throws -> DryadsAiCalendarEventsPayload
    func add(params: DryadsAiCalendarAddParams) async throws -> DryadsAiCalendarAddPayload
}

protocol RemindersServicing: Sendable {
    func list(params: DryadsAiRemindersListParams) async throws -> DryadsAiRemindersListPayload
    func add(params: DryadsAiRemindersAddParams) async throws -> DryadsAiRemindersAddPayload
}

protocol MotionServicing: Sendable {
    func activities(params: DryadsAiMotionActivityParams) async throws -> DryadsAiMotionActivityPayload
    func pedometer(params: DryadsAiPedometerParams) async throws -> DryadsAiPedometerPayload
}

struct WatchMessagingStatus: Sendable, Equatable {
    var supported: Bool
    var paired: Bool
    var appInstalled: Bool
    var reachable: Bool
    var activationState: String
}

struct WatchNotificationSendResult: Sendable, Equatable {
    var deliveredImmediately: Bool
    var queuedForDelivery: Bool
    var transport: String
}

protocol WatchMessagingServicing: AnyObject, Sendable {
    func status() async -> WatchMessagingStatus
    func sendNotification(
        id: String,
        title: String,
        body: String,
        priority: DryadsAiNotificationPriority?) async throws -> WatchNotificationSendResult
}

extension CameraController: CameraServicing {}
extension ScreenRecordService: ScreenRecordingServicing {}
extension LocationService: LocationServicing {}
