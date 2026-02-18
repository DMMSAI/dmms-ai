import CoreLocation
import Foundation
import DmmsAiKit
import UIKit

protocol CameraServicing: Sendable {
    func listDevices() async -> [CameraController.CameraDeviceInfo]
    func snap(params: DmmsAiCameraSnapParams) async throws -> (format: String, base64: String, width: Int, height: Int)
    func clip(params: DmmsAiCameraClipParams) async throws -> (format: String, base64: String, durationMs: Int, hasAudio: Bool)
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
    func ensureAuthorization(mode: DmmsAiLocationMode) async -> CLAuthorizationStatus
    func currentLocation(
        params: DmmsAiLocationGetParams,
        desiredAccuracy: DmmsAiLocationAccuracy,
        maxAgeMs: Int?,
        timeoutMs: Int?) async throws -> CLLocation
    func startLocationUpdates(
        desiredAccuracy: DmmsAiLocationAccuracy,
        significantChangesOnly: Bool) -> AsyncStream<CLLocation>
    func stopLocationUpdates()
    func startMonitoringSignificantLocationChanges(onUpdate: @escaping @Sendable (CLLocation) -> Void)
    func stopMonitoringSignificantLocationChanges()
}

protocol DeviceStatusServicing: Sendable {
    func status() async throws -> DmmsAiDeviceStatusPayload
    func info() -> DmmsAiDeviceInfoPayload
}

protocol PhotosServicing: Sendable {
    func latest(params: DmmsAiPhotosLatestParams) async throws -> DmmsAiPhotosLatestPayload
}

protocol ContactsServicing: Sendable {
    func search(params: DmmsAiContactsSearchParams) async throws -> DmmsAiContactsSearchPayload
    func add(params: DmmsAiContactsAddParams) async throws -> DmmsAiContactsAddPayload
}

protocol CalendarServicing: Sendable {
    func events(params: DmmsAiCalendarEventsParams) async throws -> DmmsAiCalendarEventsPayload
    func add(params: DmmsAiCalendarAddParams) async throws -> DmmsAiCalendarAddPayload
}

protocol RemindersServicing: Sendable {
    func list(params: DmmsAiRemindersListParams) async throws -> DmmsAiRemindersListPayload
    func add(params: DmmsAiRemindersAddParams) async throws -> DmmsAiRemindersAddPayload
}

protocol MotionServicing: Sendable {
    func activities(params: DmmsAiMotionActivityParams) async throws -> DmmsAiMotionActivityPayload
    func pedometer(params: DmmsAiPedometerParams) async throws -> DmmsAiPedometerPayload
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
        priority: DmmsAiNotificationPriority?) async throws -> WatchNotificationSendResult
}

extension CameraController: CameraServicing {}
extension ScreenRecordService: ScreenRecordingServicing {}
extension LocationService: LocationServicing {}
