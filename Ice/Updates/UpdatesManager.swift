//
//  UpdatesManager.swift
//  Ice
//

import Sparkle
import SwiftUI

/// Manager for app updates.
@MainActor
final class UpdatesManager: NSObject, ObservableObject {
    /// Status for a user-initiated update check.
    enum UpdateCheckStatus: Equatable {
        case idle
        case checking
        case upToDate
        case updateAvailable(String)
        case failed(String)

        /// A string to show in the update settings section.
        var displayString: String? {
            switch self {
            case .idle:
                nil
            case .checking:
                "Checking for updates..."
            case .upToDate:
                "You're up to date."
            case .updateAvailable(let version):
                "Version \(version) is available."
            case .failed(let message):
                message
            }
        }

        /// A Boolean value that indicates whether the status represents an error.
        var isError: Bool {
            switch self {
            case .failed:
                true
            case .idle, .checking, .upToDate, .updateAvailable:
                false
            }
        }
    }

    /// The repository page for Glace releases.
    private static let releasesURL: URL = {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://github.com/scorpion7slayer/Glace/releases/latest")!
    }()

    /// Sparkle's no-update error code.
    ///
    /// `SUNoUpdateError` is declared in Sparkle's C headers, but is not exposed to
    /// Swift as a standalone symbol.
    private static let noUpdateErrorCode = 1001

    /// A Boolean value that indicates whether the user can check for updates.
    @Published var canCheckForUpdates = false

    /// The date of the last update check.
    @Published var lastUpdateCheckDate: Date?

    /// The status of a user-initiated update check.
    @Published var updateCheckStatus = UpdateCheckStatus.idle

    /// The shared app state.
    private(set) weak var appState: AppState?

    /// The underlying updater controller.
    private(set) lazy var updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: self,
        userDriverDelegate: self
    )

    /// The underlying updater.
    var updater: SPUUpdater {
        updaterController.updater
    }

    /// A Boolean value that indicates whether to automatically check for updates.
    var automaticallyChecksForUpdates: Bool {
        get {
            updater.automaticallyChecksForUpdates
        }
        set {
            objectWillChange.send()
            updater.automaticallyChecksForUpdates = newValue
        }
    }

    /// A Boolean value that indicates whether to automatically download updates.
    var automaticallyDownloadsUpdates: Bool {
        get {
            updater.automaticallyDownloadsUpdates
        }
        set {
            objectWillChange.send()
            updater.automaticallyDownloadsUpdates = newValue
        }
    }

    /// Creates an updates manager with the given app state.
    init(appState: AppState) {
        self.appState = appState
        super.init()
    }

    /// Sets up the manager.
    func performSetup() {
        _ = updaterController
        configureCancellables()
    }

    /// Configures the internal observers for the manager.
    private func configureCancellables() {
        canCheckForUpdates = updater.canCheckForUpdates
        lastUpdateCheckDate = updater.lastUpdateCheckDate

        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
        updater.publisher(for: \.lastUpdateCheckDate)
            .assign(to: &$lastUpdateCheckDate)
    }

    /// Checks for app updates.
    @objc func checkForUpdates() {
        if canCheckForUpdates {
            updateCheckStatus = .checking
            updater.checkForUpdates()
        } else {
            updateCheckStatus = .failed("Opening latest release page.")
            NSWorkspace.shared.open(Self.releasesURL)
        }
    }
}

// MARK: UpdatesManager: SPUUpdaterDelegate
extension UpdatesManager: @preconcurrency SPUUpdaterDelegate {
    func updater(_ updater: SPUUpdater, willScheduleUpdateCheckAfterDelay delay: TimeInterval) {
        guard let appState else {
            return
        }
        appState.userNotificationManager.requestAuthorization()
    }

    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        updateCheckStatus = .updateAvailable(item.displayVersionString)
    }

    func updaterDidNotFindUpdate(_ updater: SPUUpdater, error: Error) {
        let nsError = error as NSError
        let userInitiated = nsError.userInfo[SPUNoUpdateFoundUserInitiatedKey] as? Bool ?? false

        guard userInitiated else {
            return
        }

        updateCheckStatus = .upToDate
    }

    func updater(
        _ updater: SPUUpdater,
        didFinishUpdateCycleFor updateCheck: SPUUpdateCheck,
        error: Error?
    ) {
        guard updateCheck == .updates else {
            return
        }

        lastUpdateCheckDate = updater.lastUpdateCheckDate ?? .now

        guard let error else {
            if case .checking = updateCheckStatus {
                updateCheckStatus = .upToDate
            }
            return
        }

        let nsError = error as NSError
        if nsError.domain == SUSparkleErrorDomain, nsError.code == Self.noUpdateErrorCode {
            updateCheckStatus = .upToDate
        } else {
            updateCheckStatus = .failed(error.localizedDescription)
        }
    }
}

// MARK: UpdatesManager: SPUStandardUserDriverDelegate
extension UpdatesManager: @preconcurrency SPUStandardUserDriverDelegate {
    var supportsGentleScheduledUpdateReminders: Bool { true }

    func standardUserDriverShouldHandleShowingScheduledUpdate(
        _ update: SUAppcastItem,
        andInImmediateFocus immediateFocus: Bool
    ) -> Bool {
        if NSApp.isActive {
            return immediateFocus
        } else {
            return false
        }
    }

    func standardUserDriverWillHandleShowingUpdate(
        _ handleShowingUpdate: Bool,
        forUpdate update: SUAppcastItem,
        state: SPUUserUpdateState
    ) {
        guard let appState else {
            return
        }
        if !state.userInitiated {
            appState.userNotificationManager.addRequest(
                with: .updateCheck,
                title: "A new update is available",
                body: "Version \(update.displayVersionString) is now available"
            )
        }
    }

    func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        guard let appState else {
            return
        }
        appState.userNotificationManager.removeDeliveredNotifications(with: [.updateCheck])
    }
}

// MARK: UpdatesManager: BindingExposable
extension UpdatesManager: BindingExposable { }
