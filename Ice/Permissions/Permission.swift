//
//  Permission.swift
//  Ice
//

import Combine
import Cocoa

// MARK: - Permission

/// An object that encapsulates the behavior of checking for and requesting
/// a specific permission for the app.
@MainActor
class Permission: ObservableObject, Identifiable {
    /// A Boolean value that indicates whether the app has this permission.
    @Published private(set) var hasPermission = false

    /// The title of the permission.
    let title: String

    /// Descriptive details for the permission.
    let details: [String]

    /// A Boolean value that indicates if the app can work without this permission.
    let isRequired: Bool

    /// The title shown by buttons that initiate the permission flow.
    let requestButtonTitle: String

    /// The URL of the settings pane to open.
    private let settingsURL: URL?

    /// The function that checks permissions.
    private let check: () -> Bool

    /// The function that requests permissions.
    private let request: () -> Void

    /// Observer that runs on a timer to check permissions.
    private var timerCancellable: AnyCancellable?

    /// Observer that observes the ``hasPermission`` property.
    private var hasPermissionCancellable: AnyCancellable?

    /// Creates a permission.
    ///
    /// - Parameters:
    ///   - title: The title of the permission.
    ///   - details: Descriptive details for the permission.
    ///   - isRequired: A Boolean value that indicates if the app can work without this permission.
    ///   - requestButtonTitle: The title shown by buttons that initiate the permission flow.
    ///   - settingsURL: The URL of the settings pane to open.
    ///   - check: A function that checks permissions.
    ///   - request: A function that requests permissions.
    init(
        title: String,
        details: [String],
        isRequired: Bool,
        requestButtonTitle: String = "Grant Permission",
        settingsURL: URL?,
        check: @escaping () -> Bool,
        request: @escaping () -> Void
    ) {
        self.title = title
        self.details = details
        self.isRequired = isRequired
        self.requestButtonTitle = requestButtonTitle
        self.settingsURL = settingsURL
        self.check = check
        self.request = request
        self.hasPermission = check()
    }

    /// Refreshes the current permission state.
    func refreshPermissionState() {
        hasPermission = check()
    }

    /// Starts polling the permission state.
    func startCheck() {
        refreshPermissionState()

        guard timerCancellable == nil else {
            return
        }

        let timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()

        let appDidBecomeActive = NotificationCenter.default
            .publisher(for: NSApplication.didBecomeActiveNotification)
            .map { _ in Date() }

        timerCancellable = timer
            .merge(with: appDidBecomeActive)
            .sink { [weak self] _ in
                self?.refreshPermissionState()
            }
    }

    /// Performs the request and opens the System Settings app to the appropriate pane.
    func performRequest() {
        // Start observing before macOS moves focus to the consent dialog or
        // System Settings, so accepting a permission is reflected immediately.
        startCheck()
        request()
        if let settingsURL {
            NSWorkspace.shared.open(settingsURL)
        }
    }

    /// Asynchronously waits for the app to be granted this permission.
    func waitForPermission() async {
        startCheck()
        guard !hasPermission else {
            return
        }
        return await withCheckedContinuation { continuation in
            hasPermissionCancellable = $hasPermission.sink { [weak self] hasPermission in
                guard let self else {
                    continuation.resume()
                    return
                }
                if hasPermission {
                    hasPermissionCancellable?.cancel()
                    continuation.resume()
                }
            }
        }
    }

    /// Stops running the permission check.
    func stopCheck() {
        timerCancellable?.cancel()
        timerCancellable = nil
        hasPermissionCancellable?.cancel()
        hasPermissionCancellable = nil
    }
}

// MARK: - AccessibilityPermission

final class AccessibilityPermission: Permission {
    init() {
        super.init(
            title: "Accessibility",
            details: [
                "Get real-time information about the menu bar.",
                "Arrange menu bar items.",
            ],
            isRequired: true,
            settingsURL: URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"),
            check: {
                AXHelpers.isProcessTrusted()
            },
            request: {
                AXHelpers.isProcessTrusted(prompt: true)
            }
        )
    }
}

// MARK: - ScreenRecordingPermission

final class ScreenRecordingPermission: Permission {
    init() {
        let details: [String]
        let requestButtonTitle: String

        if #available(macOS 26.0, *) {
            details = [
                "Change the menu bar's appearance.",
                "Display images of individual menu bar items.",
                "Use the + button in System Settings to add this app.",
            ]
            requestButtonTitle = "Open System Settings"
        } else {
            details = [
                "Change the menu bar's appearance.",
                "Display images of individual menu bar items.",
            ]
            requestButtonTitle = "Grant Permission"
        }

        super.init(
            title: "Screen Recording",
            details: details,
            isRequired: false,
            requestButtonTitle: requestButtonTitle,
            settingsURL: URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"),
            check: {
                // Keep the shared capture cache synchronized with changes made
                // in System Settings while this screen is open.
                ScreenCapture.cachedCheckPermissions(reset: true)
            },
            request: {
                ScreenCapture.requestPermissions()
            }
        )
    }
}
